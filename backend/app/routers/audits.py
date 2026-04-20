"""Audit CRUD endpoints + responses."""

import uuid
from datetime import datetime, timezone
from typing import List

from fastapi import APIRouter, Depends, HTTPException, UploadFile, File

from app.models.audit import AuditCreate, AuditOut, AuditStatus, AuditUpdate
from app.models.response import ResponseOut, ResponseUpdate
from app.services.auth_service import get_current_user
from app.services.firebase_service import get_db

router = APIRouter()


# --------------- Audits ---------------


@router.get("", response_model=List[AuditOut])
async def list_audits(user: dict = Depends(get_current_user)):
    """List audits filtered by role."""
    db = get_db()
    query = db.collection("audits")

    # Branch managers only see released audits
    if user["role"] in ("branch_manager", "district_manager"):
        query = query.where("status", "==", "released")

    docs = query.order_by("created_at", direction="DESCENDING").stream()

    audits = []  # type: List[AuditOut]
    for doc in docs:
        data = doc.to_dict()
        data["id"] = doc.id
        audits.append(AuditOut(**data))
    return audits


@router.post("", response_model=AuditOut, status_code=201)
async def create_audit(
    body: AuditCreate,
    user: dict = Depends(get_current_user),
):
    """Create a new audit."""
    if user["role"] in ("branch_manager", "district_manager"):
        raise HTTPException(status_code=403, detail="Not allowed to create audits")

    db = get_db()
    audit_id = str(uuid.uuid4())
    now = datetime.now(timezone.utc)

    data = body.dict()
    data.update(
        id=audit_id,
        status=AuditStatus.draft.value,
        result_percent=None,
        count_yes=0,
        count_no=0,
        count_na=0,
        management_summary=None,
        created_at=now.isoformat(),
        completed_at=None,
    )

    db.collection("audits").document(audit_id).set(data)
    return AuditOut(**data, created_at=now)


@router.get("/{audit_id}", response_model=AuditOut)
async def get_audit(audit_id: str, user: dict = Depends(get_current_user)):
    """Get a single audit."""
    db = get_db()
    doc = db.collection("audits").document(audit_id).get()
    if not doc.exists:
        raise HTTPException(status_code=404, detail="Audit not found")

    data = doc.to_dict()
    data["id"] = doc.id

    # Access control
    if user["role"] in ("branch_manager", "district_manager"):
        if data.get("status") != "released":
            raise HTTPException(status_code=403, detail="Audit not released yet")

    return AuditOut(**data)


@router.put("/{audit_id}", response_model=AuditOut)
async def update_audit(
    audit_id: str,
    body: AuditUpdate,
    user: dict = Depends(get_current_user),
):
    """Update audit fields (management summary, status)."""
    db = get_db()
    ref = db.collection("audits").document(audit_id)
    doc = ref.get()
    if not doc.exists:
        raise HTTPException(status_code=404, detail="Audit not found")

    updates = body.dict(exclude_none=True)
    ref.update(updates)

    data = doc.to_dict()
    data.update(updates)
    data["id"] = doc.id
    return AuditOut(**data)


@router.post("/{audit_id}/complete", response_model=AuditOut)
async def complete_audit(audit_id: str, user: dict = Depends(get_current_user)):
    """Complete an audit – calculate result percentage."""
    db = get_db()
    ref = db.collection("audits").document(audit_id)
    doc = ref.get()
    if not doc.exists:
        raise HTTPException(status_code=404, detail="Audit not found")

    # Count responses
    responses = ref.collection("responses").stream()
    count_yes = 0
    count_no = 0
    count_na = 0
    for r in responses:
        rating = r.to_dict().get("rating")
        if rating == "yes":
            count_yes += 1
        elif rating == "no":
            count_no += 1
        elif rating == "na":
            count_na += 1

    total = count_yes + count_no
    result_percent = (count_yes / total * 100) if total > 0 else 0.0
    now = datetime.now(timezone.utc)

    updates = {
        "status": AuditStatus.completed.value,
        "count_yes": count_yes,
        "count_no": count_no,
        "count_na": count_na,
        "result_percent": round(result_percent, 1),
        "completed_at": now.isoformat(),
    }
    ref.update(updates)

    data = doc.to_dict()
    data.update(updates)
    data["id"] = doc.id
    return AuditOut(**data)


@router.post("/{audit_id}/release", response_model=AuditOut)
async def release_audit(audit_id: str, user: dict = Depends(get_current_user)):
    """Release audit – make visible to branch."""
    if user["role"] not in ("admin", "auditor"):
        raise HTTPException(status_code=403, detail="Only revision can release audits")

    db = get_db()
    ref = db.collection("audits").document(audit_id)
    doc = ref.get()
    if not doc.exists:
        raise HTTPException(status_code=404, detail="Audit not found")

    data = doc.to_dict()
    if data.get("status") != AuditStatus.completed.value:
        raise HTTPException(status_code=400, detail="Audit must be completed first")

    ref.update({"status": AuditStatus.released.value})

    data["status"] = AuditStatus.released.value
    data["id"] = doc.id
    return AuditOut(**data)


@router.post("/{audit_id}/reopen", response_model=AuditOut)
async def reopen_audit(audit_id: str, user: dict = Depends(get_current_user)):
    """Reopen a completed audit."""
    if user["role"] not in ("admin", "auditor"):
        raise HTTPException(status_code=403, detail="Only revision can reopen audits")

    db = get_db()
    ref = db.collection("audits").document(audit_id)
    doc = ref.get()
    if not doc.exists:
        raise HTTPException(status_code=404, detail="Audit not found")

    ref.update({"status": AuditStatus.in_progress.value, "completed_at": None})

    data = doc.to_dict()
    data["status"] = AuditStatus.in_progress.value
    data["completed_at"] = None
    data["id"] = doc.id
    return AuditOut(**data)


# --------------- Responses ---------------


@router.get("/{audit_id}/responses", response_model=List[ResponseOut])
async def list_responses(audit_id: str, user: dict = Depends(get_current_user)):
    """Get all responses for an audit."""
    db = get_db()
    docs = (
        db.collection("audits")
        .document(audit_id)
        .collection("responses")
        .stream()
    )
    responses = []  # type: List[ResponseOut]
    for doc in docs:
        data = doc.to_dict()
        data["question_id"] = doc.id
        responses.append(ResponseOut(**data))
    return responses


@router.put("/{audit_id}/responses/{question_id}", response_model=ResponseOut)
async def save_response(
    audit_id: str,
    question_id: str,
    body: ResponseUpdate,
    user: dict = Depends(get_current_user),
):
    """Save or update a single audit response (auto-save).

    If rating is 'no' and measure is empty, fills in the default measure
    from the question catalog.
    """
    db = get_db()

    # If rating is "no" and no measure provided, look up default
    data = body.dict()
    if body.rating == "no" and not body.measure:
        audit_doc = db.collection("audits").document(audit_id).get()
        if audit_doc.exists:
            catalog_id = audit_doc.to_dict().get("catalog_id")
            if catalog_id:
                q_doc = db.collection("questions").document(question_id).get()
                if q_doc.exists:
                    q_data = q_doc.to_dict()
                    data["measure"] = q_data.get("default_measure_de", "")

    data["updated_at"] = datetime.now(timezone.utc).isoformat()
    data["question_id"] = question_id

    (
        db.collection("audits")
        .document(audit_id)
        .collection("responses")
        .document(question_id)
        .set(data, merge=True)
    )

    return ResponseOut(**data)


@router.post("/{audit_id}/responses/{question_id}/attachments")
async def upload_attachment(
    audit_id: str,
    question_id: str,
    file: UploadFile = File(...),
    is_report_relevant: bool = True,
    user: dict = Depends(get_current_user),
):
    """Upload an attachment for a question response.

    TODO: Store file in Firebase Storage and save URL in response.
    """
    attachment_id = str(uuid.uuid4())
    # Placeholder – in production upload to Firebase Storage
    return {
        "id": attachment_id,
        "filename": file.filename,
        "type": file.content_type,
        "is_report_relevant": is_report_relevant,
        "message": "Upload placeholder – integrate Firebase Storage",
    }

"""Audit CRUD endpoints + responses."""

import io
import os
import uuid
from datetime import datetime, timezone
from typing import List

from fastapi import APIRouter, Depends, HTTPException, UploadFile, File, Form
from fastapi.responses import StreamingResponse, FileResponse
from fpdf import FPDF

from app.models.audit import AuditCreate, AuditOut, AuditStatus, AuditUpdate
from app.models.response import ResponseOut, ResponseUpdate
from app.services.auth_service import get_current_user
from app.routers.catalogs import _normalize_question
from app.services.firebase_service import get_db

router = APIRouter()

# Directory for uploaded attachments
UPLOAD_DIR = os.path.join(os.path.dirname(os.path.dirname(os.path.dirname(__file__))), "uploads")
os.makedirs(UPLOAD_DIR, exist_ok=True)

ALLOWED_EXTENSIONS = {
    ".jpg", ".jpeg", ".png", ".gif", ".bmp", ".webp",
    ".pdf", ".docx", ".xlsx",
}
MAX_FILE_SIZE = 10 * 1024 * 1024  # 10 MB


# --------------- Audits ---------------


@router.get("", response_model=List[AuditOut])
async def list_audits(user: dict = Depends(get_current_user)):
    """List audits filtered by role."""
    db = get_db()
    query = db.collection("audits")

    _VIEWER_ROLES = ("branch_manager", "district_manager", "department_head")

    # These roles only see released audits (no drafts/in-progress/completed)
    if user["role"] in _VIEWER_ROLES:
        query = query.where("status", "==", "released")

    # Branch managers only see audits for their own branch
    user_branch_id = None
    user_country = None
    if user["role"] in ("branch_manager", "department_head"):
        # Branch-login tokens use "branch:<id>" as user ID
        if user["id"].startswith("branch:"):
            user_branch_id = user["id"][len("branch:"):]
        else:
            user_doc = db.collection("users").document(user["id"]).get()
            if user_doc.exists:
                u_data = user_doc.to_dict()
                user_branch_id = u_data.get("branch_id")
                user_country = (u_data.get("country_code") or "").upper()

    # Build branch→country map for department_head filtering
    branch_country = {}  # type: dict
    if user["role"] == "department_head" and user_country:
        for b in db.collection("branches").stream():
            b_data = b.to_dict()
            branch_country[b.id] = (b_data.get("country_code") or "").upper()

    docs = query.stream()

    audits = []  # type: List[AuditOut]
    for doc in docs:
        data = doc.to_dict()
        data["id"] = doc.id
        # Viewer roles must not see Nachrevisionen
        if user["role"] in _VIEWER_ROLES and data.get("is_nachrevision"):
            continue
        # Branch managers only see their own branch
        if user["role"] == "branch_manager" and user_branch_id and data.get("branch_id") != user_branch_id:
            continue
        # Department heads only see audits from their country
        if user["role"] == "department_head" and user_country:
            audit_country = branch_country.get(data.get("branch_id", ""), "")
            if audit_country != user_country:
                continue
        audits.append(AuditOut(**data))
    audits.sort(key=lambda a: a.created_at, reverse=True)
    return audits


@router.post("", response_model=AuditOut, status_code=201)
async def create_audit(
    body: AuditCreate,
    user: dict = Depends(get_current_user),
):
    """Create a new audit."""
    if user["role"] in ("branch_manager", "district_manager", "department_head"):
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
    return AuditOut(**data)


@router.get("/{audit_id}", response_model=AuditOut)
async def get_audit(audit_id: str, user: dict = Depends(get_current_user)):
    """Get a single audit."""
    db = get_db()
    doc = db.collection("audits").document(audit_id).get()
    if not doc.exists:
        raise HTTPException(status_code=404, detail="Audit not found")

    data = doc.to_dict()
    data["id"] = doc.id

    # Access control – viewer roles only see released, non-Nachrevision audits
    if user["role"] in ("branch_manager", "district_manager", "department_head"):
        if data.get("status") != "released":
            raise HTTPException(status_code=403, detail="Audit not released yet")
        if data.get("is_nachrevision"):
            raise HTTPException(status_code=403, detail="Not allowed to view Nachrevision")

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


@router.post("/{audit_id}/acknowledge", response_model=AuditOut)
async def acknowledge_audit(audit_id: str, user: dict = Depends(get_current_user)):
    """Branch acknowledges that they have read a released audit."""
    if user["role"] not in ("branch_manager",):
        raise HTTPException(status_code=403, detail="Only branch managers can acknowledge audits")

    db = get_db()
    ref = db.collection("audits").document(audit_id)
    doc = ref.get()
    if not doc.exists:
        raise HTTPException(status_code=404, detail="Audit not found")

    data = doc.to_dict()
    if data.get("status") != AuditStatus.released.value:
        raise HTTPException(status_code=400, detail="Only released audits can be acknowledged")

    now = datetime.now(timezone.utc).isoformat()
    ref.update({"acknowledged_at": now})

    data["acknowledged_at"] = now
    data["id"] = doc.id
    return AuditOut(**data)


@router.post("/{audit_id}/nachrevision", response_model=AuditOut, status_code=201)
async def create_nachrevision(audit_id: str, user: dict = Depends(get_current_user)):
    """Create a follow-up audit (Nachrevision) based on a completed/released audit.

    Copies the original audit's responses as previous_rating / previous_finding
    into the new audit's responses so the auditor can compare.
    """
    if user["role"] not in ("admin", "auditor"):
        raise HTTPException(status_code=403, detail="Only revision can create Nachrevision")

    db = get_db()

    # Load original audit
    orig_ref = db.collection("audits").document(audit_id)
    orig_doc = orig_ref.get()
    if not orig_doc.exists:
        raise HTTPException(status_code=404, detail="Original audit not found")

    orig = orig_doc.to_dict()
    if orig.get("status") not in (AuditStatus.completed.value, AuditStatus.released.value):
        raise HTTPException(status_code=400, detail="Original audit must be completed or released")

    # Create new audit
    new_id = str(uuid.uuid4())
    now = datetime.now(timezone.utc)

    # Look up auditor name from users collection
    user_doc = db.collection("users").document(user["id"]).get()
    auditor_name = user_doc.to_dict().get("name", user["id"]) if user_doc.exists else user["id"]

    new_audit = {
        "id": new_id,
        "type": "nachrevision",
        "catalog_id": orig["catalog_id"],
        "branch_id": orig["branch_id"],
        "branch_name": orig.get("branch_name", ""),
        "auditor_id": user["id"],
        "auditor_name": auditor_name,
        "preparer_id": None,
        "status": AuditStatus.in_progress.value,
        "result_percent": None,
        "count_yes": 0,
        "count_no": 0,
        "count_na": 0,
        "management_summary": None,
        "created_at": now.isoformat(),
        "completed_at": None,
        "is_nachrevision": True,
        "linked_audit_id": audit_id,
    }
    db.collection("audits").document(new_id).set(new_audit)

    # Copy original responses as previous data
    orig_responses = orig_ref.collection("responses").stream()
    for resp_doc in orig_responses:
        r_data = resp_doc.to_dict()
        new_resp = {
            "question_id": resp_doc.id,
            "rating": None,
            "finding": "",
            "measure": "",
            "attachments": [],
            "previous_rating": r_data.get("rating"),
            "previous_finding": r_data.get("finding", ""),
            "comparison_result": None,
            "updated_at": now.isoformat(),
        }
        (
            db.collection("audits")
            .document(new_id)
            .collection("responses")
            .document(resp_doc.id)
            .set(new_resp)
        )

    return AuditOut(**new_audit)


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


@router.delete("/{audit_id}", status_code=200)
async def delete_audit(audit_id: str, user: dict = Depends(get_current_user)):
    """Delete an audit and all its responses (admin only)."""
    if user["role"] != "admin":
        raise HTTPException(status_code=403, detail="Only admins can delete audits")

    db = get_db()
    ref = db.collection("audits").document(audit_id)
    doc = ref.get()
    if not doc.exists:
        raise HTTPException(status_code=404, detail="Audit not found")

    # Delete all responses (sub-collection)
    responses = ref.collection("responses").stream()
    for resp_doc in responses:
        # Delete attachment files from disk
        attachments = resp_doc.to_dict().get("attachments", [])
        for att in attachments:
            file_path = os.path.join(UPLOAD_DIR, att.get("stored_name", ""))
            if os.path.isfile(file_path):
                os.remove(file_path)
        resp_doc.reference.delete()

    # Delete the audit document
    ref.delete()

    return {"message": "Audit deleted", "id": audit_id}


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
                q_doc = db.collection("auditCatalogs").document(catalog_id).collection("questions").document(question_id).get()
                if q_doc.exists:
                    q_data = _normalize_question(q_doc.id, q_doc.to_dict())
                    data["measure"] = q_data.get("default_measure_de", "")

    existing_doc = (
        db.collection("audits")
        .document(audit_id)
        .collection("responses")
        .document(question_id)
        .get()
    )
    data["updated_at"] = datetime.now(timezone.utc).isoformat()
    data["question_id"] = question_id

    if existing_doc.exists:
        existing = existing_doc.to_dict()

        # Preserve attachment metadata the client does not know about,
        # especially stored_name which is required for PDF image export.
        existing_attachments = {
            att.get("id"): att for att in existing.get("attachments", [])
            if att.get("id")
        }
        merged_attachments = []
        for attachment in data.get("attachments", []):
            previous = existing_attachments.get(attachment.get("id"), {})
            merged = dict(previous)
            merged.update(attachment)
            merged_attachments.append(merged)
        data["attachments"] = merged_attachments

    # Auto-calculate comparison_result for Nachrevision audits
    if existing_doc.exists:
        existing = existing_doc.to_dict()
        prev_rating = existing.get("previous_rating") or data.get("previous_rating")
        if prev_rating and data.get("rating"):
            new_rating = data["rating"]
            if prev_rating == "no" and new_rating == "yes":
                data["comparison_result"] = "improved"
            elif prev_rating == "yes" and new_rating == "no":
                data["comparison_result"] = "worsened"
            elif prev_rating == new_rating:
                data["comparison_result"] = "unchanged"
            else:
                data["comparison_result"] = "unchanged"
        # Preserve previous_* fields from existing response
        if "previous_rating" not in data or data.get("previous_rating") is None:
            data["previous_rating"] = existing.get("previous_rating")
        if "previous_finding" not in data or data.get("previous_finding") is None:
            data["previous_finding"] = existing.get("previous_finding")

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
    is_report_relevant: bool = Form(True),
    user: dict = Depends(get_current_user),
):
    """Upload an attachment for a question response."""
    # Validate file extension
    _, ext = os.path.splitext(file.filename or "")
    ext = ext.lower()
    if ext not in ALLOWED_EXTENSIONS:
        raise HTTPException(
            status_code=400,
            detail="File type not allowed. Allowed: " + ", ".join(sorted(ALLOWED_EXTENSIONS)),
        )

    # Read file content with size check
    content = await file.read()
    if len(content) > MAX_FILE_SIZE:
        raise HTTPException(status_code=400, detail="File too large. Max 10 MB.")

    attachment_id = str(uuid.uuid4())
    safe_filename = attachment_id + ext
    file_path = os.path.join(UPLOAD_DIR, safe_filename)

    with open(file_path, "wb") as f:
        f.write(content)

    # Determine file type
    if ext in {".jpg", ".jpeg", ".png", ".gif", ".bmp", ".webp"}:
        file_type = "image"
    elif ext == ".pdf":
        file_type = "pdf"
    else:
        file_type = "document"
    download_url = "/audits/{}/responses/{}/attachments/{}/download".format(audit_id, question_id, attachment_id)

    # Save attachment reference in Firestore response
    db = get_db()
    resp_ref = (
        db.collection("audits")
        .document(audit_id)
        .collection("responses")
        .document(question_id)
    )
    resp_doc = resp_ref.get()
    attachments = []
    if resp_doc.exists:
        attachments = resp_doc.to_dict().get("attachments", [])

    attachment_data = {
        "id": attachment_id,
        "url": download_url,
        "type": file_type,
        "is_report_relevant": is_report_relevant,
        "filename": file.filename or safe_filename,
        "stored_name": safe_filename,
    }
    attachments.append(attachment_data)
    resp_ref.set({"attachments": attachments, "question_id": question_id}, merge=True)

    return attachment_data


@router.put("/{audit_id}/responses/{question_id}/attachments/{attachment_id}")
async def update_attachment(
    audit_id: str,
    question_id: str,
    attachment_id: str,
    is_report_relevant: bool = Form(...),
    user: dict = Depends(get_current_user),
):
    """Update attachment metadata such as report relevance."""
    db = get_db()
    resp_ref = (
        db.collection("audits")
        .document(audit_id)
        .collection("responses")
        .document(question_id)
    )
    resp_doc = resp_ref.get()
    if not resp_doc.exists:
        raise HTTPException(status_code=404, detail="Response not found")

    attachments = resp_doc.to_dict().get("attachments", [])
    updated_attachment = None
    for attachment in attachments:
        if attachment.get("id") == attachment_id:
            attachment["is_report_relevant"] = is_report_relevant
            updated_attachment = attachment
            break

    if updated_attachment is None:
        raise HTTPException(status_code=404, detail="Attachment not found")

    resp_ref.update({"attachments": attachments})
    return updated_attachment


@router.get("/{audit_id}/responses/{question_id}/attachments/{attachment_id}/download")
async def download_attachment(
    audit_id: str,
    question_id: str,
    attachment_id: str,
    user: dict = Depends(get_current_user),
):
    """Download an attachment file."""
    db = get_db()
    resp_doc = (
        db.collection("audits")
        .document(audit_id)
        .collection("responses")
        .document(question_id)
        .get()
    )
    if not resp_doc.exists:
        raise HTTPException(status_code=404, detail="Response not found")

    attachments = resp_doc.to_dict().get("attachments", [])
    attachment = None
    for a in attachments:
        if a.get("id") == attachment_id:
            attachment = a
            break

    if attachment is None:
        raise HTTPException(status_code=404, detail="Attachment not found")

    file_path = os.path.join(UPLOAD_DIR, attachment["stored_name"])
    if not os.path.isfile(file_path):
        raise HTTPException(status_code=404, detail="File not found on disk")

    return FileResponse(
        path=file_path,
        filename=attachment.get("filename", attachment["stored_name"]),
    )


@router.delete("/{audit_id}/responses/{question_id}/attachments/{attachment_id}")
async def delete_attachment(
    audit_id: str,
    question_id: str,
    attachment_id: str,
    user: dict = Depends(get_current_user),
):
    """Delete an attachment from a question response."""
    db = get_db()
    resp_ref = (
        db.collection("audits")
        .document(audit_id)
        .collection("responses")
        .document(question_id)
    )
    resp_doc = resp_ref.get()
    if not resp_doc.exists:
        raise HTTPException(status_code=404, detail="Response not found")

    attachments = resp_doc.to_dict().get("attachments", [])
    new_attachments = []
    removed = None
    for a in attachments:
        if a.get("id") == attachment_id:
            removed = a
        else:
            new_attachments.append(a)

    if removed is None:
        raise HTTPException(status_code=404, detail="Attachment not found")

    # Delete file from disk
    file_path = os.path.join(UPLOAD_DIR, removed.get("stored_name", ""))
    if os.path.isfile(file_path):
        os.remove(file_path)

    # Update Firestore
    resp_ref.update({"attachments": new_attachments})

    return {"message": "Attachment deleted", "id": attachment_id}


# --------------- PDF Export ---------------


def _safe(text):
    """Replace problematic characters for fpdf latin-1 encoding."""
    if not text:
        return ""
    replacements = {
        u'\u2013': '-', u'\u2014': '-', u'\u2018': "'", u'\u2019': "'",
        u'\u201c': '"', u'\u201d': '"', u'\u2026': '...', u'\u00fc': 'ue',
        u'\u00f6': 'oe', u'\u00e4': 'ae', u'\u00dc': 'Ue', u'\u00d6': 'Oe',
        u'\u00c4': 'Ae', u'\u00df': 'ss',
    }
    for orig, repl in replacements.items():
        text = text.replace(orig, repl)
    return text.encode('latin-1', 'replace').decode('latin-1')


def _resolve_attachment_file(att):
    """Resolve attachment file path even if stored_name was lost in Firestore."""
    stored_name = att.get("stored_name", "")
    if stored_name:
        file_path = os.path.join(UPLOAD_DIR, stored_name)
        if os.path.isfile(file_path):
            return stored_name, file_path

    attachment_id = att.get("id", "")
    filename = att.get("filename", "") or ""
    _, ext = os.path.splitext(filename)
    if attachment_id and ext:
        fallback_name = "{}{}".format(attachment_id, ext.lower())
        file_path = os.path.join(UPLOAD_DIR, fallback_name)
        if os.path.isfile(file_path):
            return fallback_name, file_path

    return "", ""


@router.get("/{audit_id}/export/pdf")
async def export_audit_pdf(audit_id: str, user: dict = Depends(get_current_user)):
    """Generate a PDF report for the audit."""
    db = get_db()

    # Load audit
    audit_doc = db.collection("audits").document(audit_id).get()
    if not audit_doc.exists:
        raise HTTPException(status_code=404, detail="Audit not found")
    audit = audit_doc.to_dict()
    audit["id"] = audit_doc.id

    # Load responses
    resp_docs = (
        db.collection("audits").document(audit_id).collection("responses").stream()
    )
    responses = {}
    for doc in resp_docs:
        data = doc.to_dict()
        responses[doc.id] = data

    # Load questions
    catalog_id = audit.get("catalog_id", "")
    q_docs = db.collection("auditCatalogs").document(catalog_id).collection("questions").stream()
    questions = []
    for doc in q_docs:
        questions.append(_normalize_question(doc.id, doc.to_dict()))
    questions.sort(key=lambda q: q.get("order", 0))

    # Count ratings
    count_yes = sum(1 for r in responses.values() if r.get("rating") == "yes")
    count_no = sum(1 for r in responses.values() if r.get("rating") == "no")
    count_na = sum(1 for r in responses.values() if r.get("rating") == "na")
    total = count_yes + count_no
    result_pct = (count_yes / total * 100) if total > 0 else 0.0

    # Build PDF
    pdf = FPDF()
    pdf.add_page()
    pdf.set_auto_page_break(auto=True, margin=15)

    # Title
    pdf.set_font("Arial", "B", 18)
    pdf.cell(0, 12, _safe("Revisionsbericht"), ln=True, align="C")
    pdf.ln(4)

    # Audit info
    pdf.set_font("Arial", "B", 12)
    pdf.cell(0, 8, _safe("Audit-Informationen"), ln=True)
    pdf.set_font("Arial", "", 10)

    branch = audit.get("branch_name", "")
    auditor = audit.get("auditor_name", "")
    status = audit.get("status", "")
    created = audit.get("created_at", "")
    if hasattr(created, 'strftime'):
        created = created.strftime("%d.%m.%Y")
    else:
        created = str(created)[:10] if created else ""

    info_rows = [
        ("Filiale:", branch),
        ("Pruefer:", auditor),
        ("Datum:", created),
        ("Status:", status),
    ]
    for label, val in info_rows:
        pdf.cell(40, 7, _safe(label), border=0)
        pdf.cell(0, 7, _safe(str(val)), border=0, ln=True)

    pdf.ln(4)

    # Statistics
    pdf.set_font("Arial", "B", 12)
    pdf.cell(0, 8, _safe("Ergebnis"), ln=True)
    pdf.set_font("Arial", "", 10)
    pdf.cell(40, 7, "Ja:", border=0)
    pdf.cell(0, 7, str(count_yes), border=0, ln=True)
    pdf.cell(40, 7, "Nein:", border=0)
    pdf.cell(0, 7, str(count_no), border=0, ln=True)
    pdf.cell(40, 7, _safe("Entfaellt:"), border=0)
    pdf.cell(0, 7, str(count_na), border=0, ln=True)
    pdf.cell(40, 7, _safe("Ergebnis:"), border=0)
    pdf.cell(0, 7, "{:.1f}%".format(result_pct), border=0, ln=True)
    pdf.ln(6)

    # Questions table
    pdf.set_font("Arial", "B", 12)
    pdf.cell(0, 8, _safe("Fragen und Antworten"), ln=True)
    pdf.ln(2)

    # Group by category
    categories = {}
    for q in questions:
        cat = q.get("category", "Sonstiges")
        categories.setdefault(cat, []).append(q)

    for cat_name, cat_questions in categories.items():
        # Category header
        pdf.set_font("Arial", "B", 11)
        pdf.set_fill_color(230, 230, 230)
        pdf.cell(0, 8, _safe(cat_name), ln=True, fill=True)
        pdf.ln(1)

        for q in cat_questions:
            qid = q["id"]
            resp = responses.get(qid, {})
            rating = resp.get("rating", "-")
            finding = resp.get("finding", "")
            measure = resp.get("measure", "")

            rating_display = {"yes": "Ja", "no": "Nein", "na": "Entf."}.get(rating, "-")

            # Question text + rating
            pdf.set_font("Arial", "B", 9)
            q_text = q.get("text_de", q.get("text", ""))
            pdf.cell(150, 6, _safe(q_text[:95]), border=0)
            pdf.set_font("Arial", "", 9)
            pdf.cell(0, 6, _safe(rating_display), border=0, ln=True)

            # Finding & Measure (if any)
            if finding:
                pdf.set_font("Arial", "I", 8)
                pdf.cell(10, 5, "", border=0)
                pdf.cell(0, 5, _safe("Feststellung: " + finding[:120]), border=0, ln=True)
            if measure:
                pdf.set_font("Arial", "I", 8)
                pdf.cell(10, 5, "", border=0)
                pdf.cell(0, 5, _safe("Massnahme: " + measure[:120]), border=0, ln=True)

            # Report-relevant attachments
            attachments = resp.get("attachments", [])
            for att in attachments:
                if not att.get("is_report_relevant", False):
                    continue
                filename = att.get("filename") or att.get("stored_name") or "Anhang"
                att_type = att.get("type", "document")

                if att_type != "image":
                    pdf.set_font("Arial", "I", 8)
                    pdf.cell(10, 5, "", border=0)
                    pdf.cell(
                        0,
                        5,
                        _safe("Report-Anhang: {} ({})".format(filename[:80], att_type)),
                        border=0,
                        ln=True,
                    )
                    continue
                stored, img_path = _resolve_attachment_file(att)
                if not stored or not img_path:
                    continue
                # Embed image – max width 80mm, auto height
                pdf.cell(10, 5, "", border=0)
                try:
                    pdf.image(img_path, x=pdf.get_x(), w=80)
                    pdf.ln(1)
                    pdf.set_font("Arial", "I", 8)
                    pdf.cell(10, 5, "", border=0)
                    pdf.cell(
                        0,
                        5,
                        _safe("Bild-Anhang: {}".format(filename[:80])),
                        border=0,
                        ln=True,
                    )
                except Exception:
                    pdf.set_font("Arial", "I", 8)
                    pdf.cell(0, 5, _safe("[Bild konnte nicht geladen werden]"), border=0, ln=True)
                pdf.ln(2)

            pdf.ln(1)

    management_summary = (audit.get("management_summary") or "").strip()
    pdf.ln(4)
    pdf.set_font("Arial", "B", 12)
    pdf.cell(0, 8, _safe("Zusaetzliche Bemerkungen"), ln=True)
    pdf.ln(1)
    pdf.set_font("Arial", "", 10)
    pdf.multi_cell(0, 6, _safe(management_summary or "-"))

    # Output
    pdf_bytes = pdf.output(dest="S")
    if isinstance(pdf_bytes, str):
        pdf_bytes = pdf_bytes.encode("latin-1")

    buf = io.BytesIO(pdf_bytes)
    filename = "audit-{}.pdf".format(audit_id)

    return StreamingResponse(
        buf,
        media_type="application/pdf",
        headers={"Content-Disposition": "attachment; filename={}".format(filename)},
    )

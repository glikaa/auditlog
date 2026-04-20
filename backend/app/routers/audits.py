"""Audit CRUD endpoints + responses."""

import io
import uuid
from datetime import datetime, timezone
from typing import List

from fastapi import APIRouter, Depends, HTTPException, UploadFile, File
from fastapi.responses import StreamingResponse
from fpdf import FPDF

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

    docs = query.stream()

    audits = []  # type: List[AuditOut]
    for doc in docs:
        data = doc.to_dict()
        data["id"] = doc.id
        audits.append(AuditOut(**data))
    audits.sort(key=lambda a: a.created_at, reverse=True)
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
    q_docs = db.collection("questions").where("catalog_id", "==", catalog_id).stream()
    questions = []
    for doc in q_docs:
        qdata = doc.to_dict()
        qdata["id"] = doc.id
        questions.append(qdata)
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

            pdf.ln(1)

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

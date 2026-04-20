"""Catalog & Question endpoints."""

import uuid
from datetime import datetime, timezone
from typing import List, Optional

from fastapi import APIRouter, Depends, HTTPException

from app.models.question import CatalogCreate, CatalogOut, QuestionCreate, QuestionOut
from app.services.auth_service import get_current_user
from app.services.firebase_service import get_db

router = APIRouter()


# --------------- Catalogs ---------------


@router.get("", response_model=List[CatalogOut])
async def list_catalogs(
    country: Optional[str] = None,
    year: Optional[int] = None,
    user: dict = Depends(get_current_user),
):
    """List audit catalogs, optionally filtered by country and year."""
    db = get_db()
    query = db.collection("auditCatalogs")

    if country:
        query = query.where("country_code", "==", country)
    if year:
        query = query.where("year", "==", year)

    docs = query.stream()
    catalogs = []  # type: List[CatalogOut]
    for doc in docs:
        data = doc.to_dict()
        data["id"] = doc.id
        catalogs.append(CatalogOut(**data))
    return catalogs


@router.post("", response_model=CatalogOut, status_code=201)
async def create_catalog(
    body: CatalogCreate,
    user: dict = Depends(get_current_user),
):
    """Create a new audit catalog (admin only)."""
    if user["role"] != "admin":
        raise HTTPException(status_code=403, detail="Admin only")

    db = get_db()
    catalog_id = str(uuid.uuid4())
    data = body.dict()
    data["id"] = catalog_id
    data["question_count"] = 0
    data["created_at"] = datetime.now(timezone.utc).isoformat()

    db.collection("auditCatalogs").document(catalog_id).set(data)
    return CatalogOut(**data)


@router.put("/{catalog_id}", response_model=CatalogOut)
async def update_catalog(
    catalog_id: str,
    body: CatalogCreate,
    user: dict = Depends(get_current_user),
):
    """Update a catalog (admin only)."""
    if user["role"] != "admin":
        raise HTTPException(status_code=403, detail="Admin only")

    db = get_db()
    ref = db.collection("auditCatalogs").document(catalog_id)
    doc = ref.get()
    if not doc.exists:
        raise HTTPException(status_code=404, detail="Catalog not found")

    updates = body.dict()
    ref.update(updates)

    data = doc.to_dict()
    data.update(updates)
    data["id"] = doc.id
    return CatalogOut(**data)


# --------------- Questions ---------------


@router.get("/{catalog_id}/questions", response_model=List[QuestionOut])
async def list_questions(
    catalog_id: str,
    user: dict = Depends(get_current_user),
):
    """Get all questions for a catalog, ordered by 'order' field."""
    db = get_db()
    docs = (
        db.collection("questions")
        .where("catalog_id", "==", catalog_id)
        .order_by("order")
        .stream()
    )

    questions = []  # type: List[QuestionOut]
    for doc in docs:
        data = doc.to_dict()
        data["id"] = doc.id
        questions.append(QuestionOut(**data))
    return questions


@router.post("/{catalog_id}/questions", response_model=QuestionOut, status_code=201)
async def create_question(
    catalog_id: str,
    body: QuestionCreate,
    user: dict = Depends(get_current_user),
):
    """Add a question to a catalog (admin only)."""
    if user["role"] != "admin":
        raise HTTPException(status_code=403, detail="Admin only")

    db = get_db()
    question_id = str(uuid.uuid4())

    data = body.dict()
    data["id"] = question_id
    data["catalog_id"] = catalog_id

    db.collection("questions").document(question_id).set(data)

    # Update question count
    catalog_ref = db.collection("auditCatalogs").document(catalog_id)
    catalog_doc = catalog_ref.get()
    if catalog_doc.exists:
        current_count = catalog_doc.to_dict().get("question_count", 0)
        catalog_ref.update({"question_count": current_count + 1})

    return QuestionOut(**data)


@router.put("/questions/{question_id}", response_model=QuestionOut)
async def update_question(
    question_id: str,
    body: QuestionCreate,
    user: dict = Depends(get_current_user),
):
    """Update a question (admin only)."""
    if user["role"] != "admin":
        raise HTTPException(status_code=403, detail="Admin only")

    db = get_db()
    ref = db.collection("questions").document(question_id)
    doc = ref.get()
    if not doc.exists:
        raise HTTPException(status_code=404, detail="Question not found")

    updates = body.dict()
    ref.update(updates)

    data = doc.to_dict()
    data.update(updates)
    data["id"] = doc.id
    return QuestionOut(**data)

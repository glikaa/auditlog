"""Catalog & Question endpoints."""

import uuid
from datetime import datetime, timezone
from typing import Any, Dict, List, Optional

from fastapi import APIRouter, Depends, HTTPException, Query

from app.models.question import CatalogClone, CatalogCreate, CatalogOut, QuestionCreate, QuestionOut, QuestionReorder
from app.services.auth_service import get_current_user
from app.services.firebase_service import get_db

router = APIRouter()


def _normalize_question(doc_id: str, data: Dict[str, Any]) -> Dict[str, Any]:
    """Normalize a Firestore question document to the flat snake_case API format.

    Handles documents written by the old flat schema as well as the new
    migration format that uses camelCase keys and nested translation objects.
    """
    d = dict(data)
    d["id"] = doc_id

    # catalogId (camelCase) → catalog_id
    if "catalogId" in d and "catalog_id" not in d:
        d["catalog_id"] = d.pop("catalogId")

    # Nested category object → flat fields
    if isinstance(d.get("category"), dict):
        cat = d.pop("category")
        d["category"] = cat.get("de") or ""
        d.setdefault("category_en", cat.get("en"))
        d.setdefault("category_hr", cat.get("hr"))

    # Nested default_finding object → flat fields
    if isinstance(d.get("default_finding"), dict):
        df = d.pop("default_finding")
        d.setdefault("default_finding_de", df.get("de"))
        d.setdefault("default_finding_en", df.get("en"))
        d.setdefault("default_finding_hr", df.get("hr"))

    # Nested default_measure object → flat fields
    if isinstance(d.get("default_measure"), dict):
        dm = d.pop("default_measure")
        d.setdefault("default_measure_de", dm.get("de"))
        d.setdefault("default_measure_en", dm.get("en"))
        d.setdefault("default_measure_hr", dm.get("hr"))

    # Ensure required fields have a fallback so Pydantic doesn't reject the doc.
    # Use direct assignment (not setdefault) because Firestore returns stored null
    # values as present keys with None — setdefault won't override those.
    if not d.get("catalog_id"):
        d["catalog_id"] = ""
    if d.get("order") is None:
        d["order"] = 0
    if not d.get("category"):
        d["category"] = ""

    return d


# --------------- Helpers ---------------


def _catalog_ref(db, catalog_id: str, version: Optional[str] = None):
    """Return (catalog_doc_ref, questions_collection_ref) for a catalog_id.

    Resolves in priority order:
    1. Explicit ``version`` arg (e.g. ``version="2025-v2"``)
    2. Slash-encoded path ID (e.g. ``catalog-de/versions/2025-v2``)
    3. Plain top-level doc ID (e.g. ``catalog-de``)
    """
    if version:
        doc_ref = (
            db.collection("auditCatalogs")
            .document(catalog_id)
            .collection("versions")
            .document(version)
        )
    elif "/versions/" in catalog_id:
        parent_id, version_id = catalog_id.split("/versions/", 1)
        doc_ref = (
            db.collection("auditCatalogs")
            .document(parent_id)
            .collection("versions")
            .document(version_id)
        )
    else:
        doc_ref = db.collection("auditCatalogs").document(catalog_id)
    return doc_ref, doc_ref.collection("questions")


# --------------- Catalogs ---------------


@router.get("", response_model=List[CatalogOut])
async def list_catalogs(
    country: Optional[str] = None,
    year: Optional[int] = None,
    user: dict = Depends(get_current_user),
):
    """List audit catalogs, optionally filtered by country and year.

    Returns both top-level catalog documents and any version subcollection
    documents (path IDs like ``catalog-de/versions/2025-v2``).
    """
    db = get_db()

    top_docs = list(db.collection("auditCatalogs").stream())
    catalogs = []  # type: List[CatalogOut]

    for doc in top_docs:
        data = doc.to_dict()
        data["id"] = doc.id
        top_country = data.get("country_code", "")

        # Enumerate version subcollection docs first.
        v_docs = list(doc.reference.collection("versions").stream())

        if v_docs:
            # Catalog has versions — return only the versions, not the top-level doc,
            # to avoid showing a duplicate empty entry alongside versioned entries.
            for v_doc in v_docs:
                v_data = v_doc.to_dict()
                if not v_data.get("country_code"):
                    v_data["country_code"] = top_country
                v_data["id"] = f"{doc.id}/versions/{v_doc.id}"
                v_country = v_data.get("country_code", "")
                v_year = v_data.get("year")
                if country and v_country.upper() != country.upper():
                    continue
                if year and v_year != year:
                    continue
                try:
                    catalogs.append(CatalogOut(**v_data))
                except Exception:
                    pass
        else:
            # No versions yet — return the top-level doc directly.
            top_year = data.get("year")
            if country and top_country.upper() != country.upper():
                continue
            if year and top_year != year:
                continue
            try:
                catalogs.append(CatalogOut(**data))
            except Exception:
                pass

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


@router.post("/{catalog_id}/clone", response_model=CatalogOut, status_code=201)
async def clone_catalog(
    catalog_id: str,
    body: CatalogClone,
    base_version: Optional[str] = None,
    user: dict = Depends(get_current_user),
):
    """Create a new version of a catalog stored at
    ``auditCatalogs/{catalog_id}/versions/{year}-{version}`` (admin only).

    ``catalog_id`` must be the **parent** catalog id (e.g. ``catalog-de``).
    When ``base_version`` query param is supplied (e.g. ``2025-v1``), questions
    are read from that version subcollection document; otherwise they are read
    from the parent catalog's flat ``questions`` subcollection.

    The source is left completely unchanged.
    """
    if user["role"] != "admin":
        raise HTTPException(status_code=403, detail="Admin only")

    db = get_db()
    BATCH_SIZE = 490  # stay safely under Firestore's 500-write limit per batch

    # ── Fetch parent catalog for country_code ─────────────────────────────
    parent_ref = db.collection("auditCatalogs").document(catalog_id)
    parent_doc = parent_ref.get()
    if not parent_doc.exists:
        raise HTTPException(status_code=404, detail="Catalog not found")
    country_code: str = parent_doc.to_dict().get("country_code", "")

    # ── Determine the source for question documents ────────────────────────
    if base_version:
        src_ref = parent_ref.collection("versions").document(base_version)
        if not src_ref.get().exists:
            raise HTTPException(status_code=404, detail=f"Version '{base_version}' not found")
    else:
        src_ref = parent_ref

    # ── Build new version document ID and reference ───────────────────────
    version_doc_id = f"{body.year}-{body.version}"
    new_version_ref = parent_ref.collection("versions").document(version_doc_id)
    if new_version_ref.get().exists:
        raise HTTPException(
            status_code=409,
            detail=f"Version '{version_doc_id}' already exists in '{catalog_id}'.",
        )

    # The virtual path ID used by the API to address this version.
    new_catalog_id = f"{catalog_id}/versions/{version_doc_id}"

    # ── Create the version document ────────────────────────────────────────
    new_catalog_data: Dict[str, Any] = {
        "id": new_catalog_id,
        "country_code": country_code,
        "version": body.version,
        "year": body.year,
        "language": body.language,
        "question_count": 0,
        "created_at": datetime.now(timezone.utc).isoformat(),
    }
    new_version_ref.set(new_catalog_data)

    # ── Copy questions, preserving lineage ────────────────────────────────
    q_docs = list(src_ref.collection("questions").stream())
    count = len(q_docs)

    for chunk_start in range(0, max(count, 1), BATCH_SIZE):
        chunk = q_docs[chunk_start: chunk_start + BATCH_SIZE]
        batch = db.batch()
        for q_doc in chunk:
            q_data = dict(q_doc.to_dict())
            new_q_id = str(uuid.uuid4())
            q_data["id"] = new_q_id
            q_data["catalog_id"] = new_catalog_id
            q_data["master_question_id"] = q_doc.id
            batch.set(new_version_ref.collection("questions").document(new_q_id), q_data)
        batch.commit()

    # ── Persist final question count ───────────────────────────────────────
    new_version_ref.update({"question_count": count})
    new_catalog_data["question_count"] = count

    return CatalogOut(**new_catalog_data)


# --------------- Questions ---------------


@router.get("/{catalog_id}/questions", response_model=List[QuestionOut])
async def list_questions(
    catalog_id: str,
    version: Optional[str] = Query(None),
    user: dict = Depends(get_current_user),
):
    """Get all questions for a catalog, ordered by 'order' field.

    Pass ``?version=2025-v2`` to read from a version subcollection.
    """
    db = get_db()
    _, q_ref = _catalog_ref(db, catalog_id, version)
    docs = q_ref.stream()

    questions = []  # type: List[QuestionOut]
    for doc in docs:
        data = _normalize_question(doc.id, doc.to_dict())
        questions.append(QuestionOut(**data))
    questions.sort(key=lambda q: q.order)
    return questions


@router.post("/{catalog_id}/questions", response_model=QuestionOut, status_code=201)
async def create_question(
    catalog_id: str,
    body: QuestionCreate,
    version: Optional[str] = Query(None),
    user: dict = Depends(get_current_user),
):
    """Add a question to a catalog (admin only).

    Pass ``?version=2025-v2`` to add into a version subcollection.
    """
    if user["role"] != "admin":
        raise HTTPException(status_code=403, detail="Admin only")

    db = get_db()
    question_id = str(uuid.uuid4())

    catalog_ref, q_collection = _catalog_ref(db, catalog_id, version)
    catalog_doc = catalog_ref.get()
    if not catalog_doc.exists:
        raise HTTPException(status_code=404, detail="Catalog not found")

    catalog_data = catalog_doc.to_dict()
    version_id = catalog_data.get("version", "")
    try:
        version_number = int(version_id.split("-v")[-1]) if "-v" in version_id else 1
    except (ValueError, IndexError):
        version_number = 1

    resolved_catalog_id = f"{catalog_id}/versions/{version}" if version else catalog_id

    data = body.dict()
    data["id"] = question_id
    data["catalog_id"] = resolved_catalog_id
    data["introducedInVersionId"] = version_id
    data["introducedInVersionNumber"] = version_number

    q_collection.document(question_id).set(data)

    current_count = catalog_data.get("question_count", 0)
    catalog_ref.update({"question_count": current_count + 1})

    return QuestionOut(**data)


@router.patch("/{catalog_id}/questions/reorder")
async def reorder_questions(
    catalog_id: str,
    body: List[QuestionReorder],
    version: Optional[str] = Query(None),
    user: dict = Depends(get_current_user),
):
    """Bulk-update question order values (admin only)."""
    if user["role"] != "admin":
        raise HTTPException(status_code=403, detail="Admin only")

    db = get_db()
    _, q_collection = _catalog_ref(db, catalog_id, version)
    batch = db.batch()
    for item in body:
        batch.update(q_collection.document(item.id), {"order": item.order})
    batch.commit()
    return {"updated": len(body)}


@router.put("/{catalog_id}/questions/{question_id}", response_model=QuestionOut)
async def update_question(
    catalog_id: str,
    question_id: str,
    body: QuestionCreate,
    user: dict = Depends(get_current_user),
):
    """Update a question (admin only)."""
    if user["role"] != "admin":
        raise HTTPException(status_code=403, detail="Admin only")

    db = get_db()
    _, q_collection = _catalog_ref(db, catalog_id)
    ref = q_collection.document(question_id)
    doc = ref.get()
    if not doc.exists:
        raise HTTPException(status_code=404, detail="Question not found")

    updates = body.dict()
    ref.update(updates)

    merged = _normalize_question(doc.id, doc.to_dict())
    merged.update(updates)
    merged["id"] = doc.id
    return QuestionOut(**merged)

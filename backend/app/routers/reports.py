"""Reporting endpoints."""

from typing import Dict, List, Optional

from fastapi import APIRouter, Depends, Query

from app.services.auth_service import get_current_user
from app.services.firebase_service import get_db

router = APIRouter()


@router.get("/branches")
async def report_branches(
    country: Optional[str] = None,
    user: dict = Depends(get_current_user),
):
    """Audit results per branch over time."""
    db = get_db()
    query = db.collection("audits").where("status", "==", "released")

    if country:
        # Would need branch lookup for country filter in production
        pass

    docs = query.stream()

    branch_results = {}  # type: Dict[str, List[dict]]
    for doc in docs:
        data = doc.to_dict()
        branch_name = data.get("branch_name", "Unknown")
        branch_results.setdefault(branch_name, []).append({
            "audit_id": doc.id,
            "result_percent": data.get("result_percent"),
            "completed_at": data.get("completed_at"),
            "type": data.get("type"),
        })

    return branch_results


@router.get("/questions/top5")
async def report_top5_questions(
    country: Optional[str] = None,
    year: Optional[int] = None,
    user: dict = Depends(get_current_user),
):
    """Top 5 questions with most 'yes' and most 'no' ratings."""
    db = get_db()

    # Get all released/completed audits
    audit_docs = list(
        db.collection("audits").where("status", "in", ["released", "completed"]).stream()
    )

    # Build catalog→country map so we can filter by country
    catalog_country = {}  # catalog_id → country_code
    for cat in db.collection("auditCatalogs").stream():
        cat_data = cat.to_dict()
        catalog_country[cat.id] = (cat_data.get("country_code") or "").upper()

    # Filter audits by country and year
    filtered_audits = []
    for audit_doc in audit_docs:
        data = audit_doc.to_dict()

        # Country filter via catalog
        if country:
            cat_id = data.get("catalog_id", "")
            if catalog_country.get(cat_id, "").upper() != country.upper():
                continue

        # Year filter via created_at
        if year:
            created_at = data.get("created_at", "")
            if not created_at or str(year) not in created_at[:4]:
                continue

        filtered_audits.append(audit_doc)

    question_stats = {}  # type: Dict[str, Dict[str, int]]

    for audit_doc in filtered_audits:
        responses = (
            db.collection("audits")
            .document(audit_doc.id)
            .collection("responses")
            .stream()
        )
        for resp in responses:
            r_data = resp.to_dict()
            q_id = resp.id
            rating = r_data.get("rating")
            if q_id not in question_stats:
                question_stats[q_id] = {"yes": 0, "no": 0, "na": 0}
            if rating in ("yes", "no", "na"):
                question_stats[q_id][rating] += 1

    # Resolve question texts (question_id → text_de)
    q_ids = set(question_stats.keys())
    question_texts = {}
    for q_id in q_ids:
        q_doc = db.collection("questions").document(q_id).get()
        if q_doc.exists:
            q_data = q_doc.to_dict()
            question_texts[q_id] = q_data.get("text_de", q_id)
        else:
            question_texts[q_id] = q_id

    # Sort for top 5 yes and top 5 no
    sorted_by_yes = sorted(
        question_stats.items(), key=lambda x: x[1]["yes"], reverse=True
    )[:5]
    sorted_by_no = sorted(
        question_stats.items(), key=lambda x: x[1]["no"], reverse=True
    )[:5]

    return {
        "top5_yes": [
            {"question_id": q_id, "question_text": question_texts.get(q_id, q_id), **stats}
            for q_id, stats in sorted_by_yes
        ],
        "top5_no": [
            {"question_id": q_id, "question_text": question_texts.get(q_id, q_id), **stats}
            for q_id, stats in sorted_by_no
        ],
    }


@router.get("/compare")
async def report_compare(
    master_question_id: str = Query(..., description="Master question ID for cross-country comparison"),
    user: dict = Depends(get_current_user),
):
    """Compare the same question across countries via master_question_id."""
    db = get_db()

    # Find all questions with this master ID
    q_docs = (
        db.collection("questions")
        .where("master_question_id", "==", master_question_id)
        .stream()
    )

    question_ids = {}  # type: Dict[str, str]
    for q_doc in q_docs:
        q_data = q_doc.to_dict()
        catalog_id = q_data.get("catalog_id")
        # Look up country from catalog
        cat_doc = db.collection("auditCatalogs").document(catalog_id).get()
        if cat_doc.exists:
            country = cat_doc.to_dict().get("country_code", "??")
            question_ids[q_doc.id] = country

    # Now gather ratings per country
    country_stats = {}  # type: Dict[str, Dict[str, int]]
    audit_docs = list(
        db.collection("audits").where("status", "==", "released").stream()
    )

    for audit_doc in audit_docs:
        for q_id, country in question_ids.items():
            resp_doc = (
                db.collection("audits")
                .document(audit_doc.id)
                .collection("responses")
                .document(q_id)
                .get()
            )
            if resp_doc.exists:
                rating = resp_doc.to_dict().get("rating")
                if country not in country_stats:
                    country_stats[country] = {"yes": 0, "no": 0, "na": 0}
                if rating in ("yes", "no", "na"):
                    country_stats[country][rating] += 1

    return {
        "master_question_id": master_question_id,
        "countries": country_stats,
    }

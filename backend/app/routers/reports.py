"""Reporting endpoints."""

from __future__ import annotations

from fastapi import APIRouter, Depends, Query

from app.services.auth_service import get_current_user
from app.services.firebase_service import get_db

router = APIRouter()


@router.get("/branches")
async def report_branches(
    country: str | None = None,
    user: dict = Depends(get_current_user),
):
    """Audit results per branch over time."""
    db = get_db()
    query = db.collection("audits").where("status", "==", "released")

    if country:
        # Would need branch lookup for country filter in production
        pass

    docs = query.stream()

    branch_results: dict[str, list[dict]] = {}
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
    country: str | None = None,
    year: int | None = None,
    user: dict = Depends(get_current_user),
):
    """Top 5 questions with most 'yes' and most 'no' ratings."""
    db = get_db()

    # Get all released audits
    query = db.collection("audits").where("status", "==", "released")
    audit_docs = list(query.stream())

    question_stats: dict[str, dict[str, int]] = {}

    for audit_doc in audit_docs:
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

    # Sort for top 5 yes and top 5 no
    sorted_by_yes = sorted(
        question_stats.items(), key=lambda x: x[1]["yes"], reverse=True
    )[:5]
    sorted_by_no = sorted(
        question_stats.items(), key=lambda x: x[1]["no"], reverse=True
    )[:5]

    return {
        "top5_yes": [
            {"question_id": q_id, **stats} for q_id, stats in sorted_by_yes
        ],
        "top5_no": [
            {"question_id": q_id, **stats} for q_id, stats in sorted_by_no
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

    question_ids: dict[str, str] = {}  # question_id -> catalog country
    for q_doc in q_docs:
        q_data = q_doc.to_dict()
        catalog_id = q_data.get("catalog_id")
        # Look up country from catalog
        cat_doc = db.collection("auditCatalogs").document(catalog_id).get()
        if cat_doc.exists:
            country = cat_doc.to_dict().get("country_code", "??")
            question_ids[q_doc.id] = country

    # Now gather ratings per country
    country_stats: dict[str, dict[str, int]] = {}
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

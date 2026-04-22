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
    query = db.collection("audits").where("status", "in", ["released", "completed"])
    audit_docs = list(query.stream())

    # Build branch→country map for filtering
    branch_country = {}
    for b in db.collection("branches").stream():
        b_data = b.to_dict()
        branch_country[b.id] = (b_data.get("country_code") or "").upper()

    # Also build catalog→country as fallback
    catalog_country = {}
    for cat in db.collection("auditCatalogs").stream():
        cat_data = cat.to_dict()
        catalog_country[cat.id] = (cat_data.get("country_code") or "").upper()

    branch_results = {}  # type: Dict[str, List[dict]]
    for doc in audit_docs:
        data = doc.to_dict()

        # Country filter
        if country:
            branch_id = data.get("branch_id", "")
            catalog_id = data.get("catalog_id", "")
            audit_country = branch_country.get(branch_id, "") or catalog_country.get(catalog_id, "")
            if audit_country.upper() != country.upper():
                continue

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
    q_docs = list(
        db.collection("questions")
        .where("master_question_id", "==", master_question_id)
        .stream()
    )

    # Build catalog→country map
    catalog_country = {}
    for cat in db.collection("auditCatalogs").stream():
        cat_data = cat.to_dict()
        catalog_country[cat.id] = (cat_data.get("country_code") or "").upper()

    # Map question_id → (country, order, text_de)
    question_info = {}  # type: Dict[str, dict]
    master_text = ""
    for q_doc in q_docs:
        q_data = q_doc.to_dict()
        catalog_id = q_data.get("catalog_id", "")
        country = catalog_country.get(catalog_id, "??")
        question_info[q_doc.id] = {
            "country": country,
            "order": q_data.get("order", 0),
            "text_de": q_data.get("text_de", ""),
        }
        if not master_text:
            master_text = q_data.get("text_de", "")

    # Gather ratings per country from released/completed audits
    country_stats = {}  # type: Dict[str, Dict[str, int]]
    audit_docs = list(
        db.collection("audits").where("status", "in", ["released", "completed"]).stream()
    )

    for audit_doc in audit_docs:
        for q_id, info in question_info.items():
            resp_doc = (
                db.collection("audits")
                .document(audit_doc.id)
                .collection("responses")
                .document(q_id)
                .get()
            )
            if resp_doc.exists:
                rating = resp_doc.to_dict().get("rating")
                country = info["country"]
                if country not in country_stats:
                    country_stats[country] = {"yes": 0, "no": 0, "na": 0}
                if rating in ("yes", "no", "na"):
                    country_stats[country][rating] += 1

    # Build structured results list matching Flutter model
    results = []
    for q_id, info in question_info.items():
        country = info["country"]
        stats = country_stats.get(country, {"yes": 0, "no": 0, "na": 0})
        results.append({
            "country_code": country,
            "local_question_id": q_id,
            "local_question_order": info["order"],
            "yes": stats["yes"],
            "no": stats["no"],
            "na": stats["na"],
        })

    # Sort by country code
    results.sort(key=lambda r: r["country_code"])

    return {
        "master_question_id": master_question_id,
        "master_question_text": master_text,
        "results": results,
    }


@router.get("/master-questions")
async def list_master_questions(
    user: dict = Depends(get_current_user),
):
    """List all unique master questions with their text (for dropdown)."""
    db = get_db()

    master_map = {}  # master_id → {text, country_count}
    for q_doc in db.collection("questions").stream():
        q_data = q_doc.to_dict()
        mid = q_data.get("master_question_id", "")
        if not mid:
            continue
        if mid not in master_map:
            master_map[mid] = {
                "master_question_id": mid,
                "text_de": q_data.get("text_de", mid),
                "country_count": 0,
            }
        master_map[mid]["country_count"] += 1

    # Only return master questions that appear in more than 1 catalog (cross-country)
    result = [v for v in master_map.values() if v["country_count"] > 1]
    result.sort(key=lambda x: x["master_question_id"])

    return result

"""
Idempotent migration: write questions directly into auditCatalogs/{catalogId}/questions.

Why this script exists
----------------------
migrate.js reads from a flat `questions` collection that is now empty.
The question data lives in seed_catalog.py.  This script imports that data and
writes it straight to the correct Firestore subcollections.

Safe to re-run: every document is written with set() (upsert) using a stable
document ID derived from the catalog and order number, so re-running never
creates duplicates.

Usage:
    python migrate-questions.py           # migrate all catalogs
    python migrate-questions.py catalog-de # migrate one catalog only
"""

import sys
import os

sys.path.insert(0, os.path.dirname(__file__))

from app.services.firebase_service import get_db
from seed_catalog import QUESTIONS, _questions_for, _CAT, MULTI_COUNTRY_DATA, _LANG_MAP

# ---------------------------------------------------------------------------
# Catalog ID mapping
#   key   : catalog document ID in Firestore (WITHOUT year suffix)
#   value : how to get questions for it
# ---------------------------------------------------------------------------

_MASTER_MAP = {1: 1, 2: 3, 3: 8, 4: 9, 5: 12, 6: 13, 7: 16, 8: 17, 9: 20, 10: 21}


def _build_catalog_questions():
    """
    Returns a dict:  catalog_id  ->  list of flat question dicts ready for Firestore.
    """
    german_questions = _questions_for("de")
    croatian_questions = _questions_for("hr")

    result = {}

    # --- German catalog (25 full questions) ---
    de_questions = []
    for q in QUESTIONS:
        doc = dict(q)
        doc["catalog_id"] = "catalog-de"
        doc.setdefault("master_question_id", "master-{}".format(q["order"]))
        de_questions.append(doc)
    result["catalog-de"] = de_questions

    # --- Multi-country catalogs (10 questions each) ---
    for country_code, data in MULTI_COUNTRY_DATA.items():
        lang = _LANG_MAP[country_code]
        catalog_id_with_year = data["catalog_id"]        # e.g. "catalog-hr-2025"
        catalog_id = "-".join(catalog_id_with_year.split("-")[:2])  # "catalog-hr"

        questions = _questions_for(lang)

        for i, q in enumerate(questions):
            hr_q = croatian_questions[i]

            if lang not in ("de", "at", "ch"):
                de_q = german_questions[i]

                if lang == "hr":
                    q["text_hr"] = q["text_de"]
                    q["category_hr"] = q["category"]
                    q["default_finding_hr"] = q.get("default_finding_de")
                    q["default_measure_hr"] = q.get("default_measure_de")
                    q["internal_note_hr"] = q.get("internal_note_de")
                else:
                    q["text_hr"] = hr_q["text_de"]
                    q["category_hr"] = hr_q["category"]
                    q["default_finding_hr"] = hr_q.get("default_finding_de")
                    q["default_measure_hr"] = hr_q.get("default_measure_de")
                    q["internal_note_hr"] = hr_q.get("internal_note_de")

                q["text_de"] = de_q["text_de"]
                q["category"] = de_q["category"]
                q["default_finding_de"] = de_q.get("default_finding_de")
                q["default_measure_de"] = de_q.get("default_measure_de")
                q["internal_note_de"] = de_q.get("internal_note_de")
            else:
                q["text_hr"] = hr_q["text_de"]
                q["category_hr"] = hr_q["category"]
                q["default_finding_hr"] = hr_q.get("default_finding_de")
                q["default_measure_hr"] = hr_q.get("default_measure_de")
                q["internal_note_hr"] = hr_q.get("internal_note_de")

            q["catalog_id"] = catalog_id
            q["master_question_id"] = "master-{}".format(
                _MASTER_MAP.get(q["order"], q["order"])
            )

        result[catalog_id] = questions

    return result


def migrate(target_catalog: str = None):
    db = get_db()
    all_catalogs = _build_catalog_questions()

    catalogs_to_process = (
        {target_catalog: all_catalogs[target_catalog]}
        if target_catalog and target_catalog in all_catalogs
        else all_catalogs
    )

    if target_catalog and target_catalog not in all_catalogs:
        print("ERROR: unknown catalog '{}'. Known: {}".format(
            target_catalog, ", ".join(all_catalogs.keys())
        ))
        sys.exit(1)

    version_id = "2025-v1"
    version_number = 1

    for catalog_id, questions in catalogs_to_process.items():
        print("\n[{}]  {} questions".format(catalog_id, len(questions)))

        cat_ref = db.collection("auditCatalogs").document(catalog_id)
        cat_doc = cat_ref.get()
        if not cat_doc.exists:
            print("  WARN  Catalog document does not exist in Firestore – skipping.")
            continue

        # Ensure version sub-document exists
        ver_ref = cat_ref.collection("versions").document(version_id)
        if not ver_ref.get().exists:
            cat_data = cat_doc.to_dict()
            ver_ref.set({
                "version": version_id,
                "versionNumber": version_number,
                "year": cat_data.get("year", 2025),
                "createdAt": __import__("datetime").datetime.now(
                    __import__("datetime").timezone.utc
                ).isoformat(),
            })
            print("  OK    Version '{}' created.".format(version_id))

        written = 0
        for q in questions:
            country_prefix = catalog_id.split("-")[1]  # "de", "hr", etc.
            q_id = "q-{}-{}".format(country_prefix, q["order"])

            doc = dict(q)
            doc["id"] = q_id
            doc["catalog_id"] = catalog_id
            doc["introducedInVersionId"] = version_id
            doc["introducedInVersionNumber"] = version_number

            cat_ref.collection("questions").document(q_id).set(doc)
            written += 1

        # Keep question_count in sync
        cat_ref.update({"question_count": written})
        print("  OK    {} questions written, question_count updated.".format(written))

    print("\nMigration complete.")


if __name__ == "__main__":
    target = sys.argv[1] if len(sys.argv) > 1 else None
    migrate(target)

"""
Migration: flat questions → versioned structure

For every top-level catalog in auditCatalogs/ that has questions in its flat
``questions`` subcollection but NO ``versions`` subcollection yet, this script:

1. Creates  auditCatalogs/{id}/versions/{version_id}  with the catalog metadata.
2. Copies   auditCatalogs/{id}/questions/*
       →    auditCatalogs/{id}/versions/{version_id}/questions/*
            (each copy gets master_question_id = original question doc id)
3. Does NOT delete the original flat questions (safe / non-destructive).

Usage:
    python migrate-to-versions.py               # all catalogs, default version
    python migrate-to-versions.py catalog-de    # one catalog only
    python migrate-to-versions.py catalog-de 2025-v1  # explicit version id

Safe to re-run: skips catalogs that already have a versions subcollection.
"""

import sys
import os
import uuid
from datetime import datetime, timezone

sys.path.insert(0, os.path.dirname(__file__))

from app.services.firebase_service import get_db

BATCH_SIZE = 490  # stay safely under Firestore's 500-op batch limit


def migrate(only_catalog: str | None = None, version_id: str = "2025-v1"):
    db = get_db()

    catalog_docs = (
        [db.collection("auditCatalogs").document(only_catalog).get()]
        if only_catalog
        else list(db.collection("auditCatalogs").stream())
    )

    for cat_doc in catalog_docs:
        if not cat_doc.exists:
            print(f"  SKIP  '{cat_doc.id}' — document not found")
            continue

        cat_id = cat_doc.id
        cat_data = cat_doc.to_dict()
        cat_ref = db.collection("auditCatalogs").document(cat_id)

        # ── Check whether the target version already has questions ────────
        version_ref = cat_ref.collection("versions").document(version_id)
        existing_q = list(version_ref.collection("questions").limit(1).stream())
        if existing_q:
            print(f"  SKIP  '{cat_id}' — versions/{version_id} already has questions")
            continue

        # ── Load flat questions ───────────────────────────────────────────
        q_docs = list(cat_ref.collection("questions").stream())
        if not q_docs:
            print(f"  SKIP  '{cat_id}' — no flat questions found")
            continue

        print(f"  MIGRATE  '{cat_id}' ({len(q_docs)} questions) → versions/{version_id}")

        # ── Create / overwrite version document ──────────────────────────
        version_ref.set({
            "id": f"{cat_id}/versions/{version_id}",
            "country_code": cat_data.get("country_code", ""),
            "version": cat_data.get("version", version_id),
            "year": cat_data.get("year", 2025),
            "language": cat_data.get("language", "de"),
            "question_count": len(q_docs),
            "created_at": cat_data.get("created_at") or datetime.now(timezone.utc).isoformat(),
        })

        # ── Copy questions in batches ─────────────────────────────────────
        for chunk_start in range(0, len(q_docs), BATCH_SIZE):
            chunk = q_docs[chunk_start: chunk_start + BATCH_SIZE]
            batch = db.batch()
            for q_doc in chunk:
                q_data = dict(q_doc.to_dict())
                new_q_id = str(uuid.uuid4())
                q_data["id"] = new_q_id
                q_data["catalog_id"] = f"{cat_id}/versions/{version_id}"
                q_data.setdefault("master_question_id", q_doc.id)
                new_q_ref = version_ref.collection("questions").document(new_q_id)
                batch.set(new_q_ref, q_data)
            batch.commit()

        print(f"  OK    '{cat_id}/versions/{version_id}' created with {len(q_docs)} questions")

    print("\nDone.")


if __name__ == "__main__":
    args = sys.argv[1:]
    only = args[0] if len(args) >= 1 else None
    ver  = args[1] if len(args) >= 2 else "2025-v1"
    migrate(only_catalog=only, version_id=ver)

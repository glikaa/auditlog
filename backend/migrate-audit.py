"""
Migration: audits -> add catalog versioning

- Adds:
    catalog_version_id
    catalog_version_number

- Optional:
    normalize catalog_id (remove year suffix)

- Updates:
    audits
    audits/{auditId}/responses

SAFE:
- does not overwrite existing versioned audits
"""

import sys
import os
from datetime import datetime, timezone

sys.path.insert(0, os.path.dirname(__file__))

from app.services.firebase_service import get_db


VERSION_ID = "2025-v1"
VERSION_NUMBER = 1

# toggle this if you want to clean catalog_id
NORMALIZE_CATALOG_ID = True


def normalize_catalog_id(old_id: str) -> str:
    """
    catalog-hr-2025 -> catalog-hr
    """
    if not old_id:
        return old_id

    parts = old_id.split("-")
    if parts[-1].isdigit():
        return "-".join(parts[:-1])
    return old_id


def migrate():
    db = get_db()

    audits_ref = db.collection("audits")
    audits = list(audits_ref.stream())

    print(f"Found {len(audits)} audits")

    updated = 0

    for audit_doc in audits:
        audit = audit_doc.to_dict()
        audit_id = audit_doc.id

        # skip if already migrated
        if "catalog_version_id" in audit:
            print(f"  SKIP  {audit_id} already migrated")
            continue

        old_catalog_id = audit.get("catalog_id")
        new_catalog_id = normalize_catalog_id(old_catalog_id) if NORMALIZE_CATALOG_ID else old_catalog_id

        update_data = {
            "catalog_version_id": VERSION_ID,
            "catalog_version_number": VERSION_NUMBER,
            "migrated_at": datetime.now(timezone.utc).isoformat(),
        }

        if NORMALIZE_CATALOG_ID and new_catalog_id != old_catalog_id:
            update_data["catalog_id"] = new_catalog_id

        # --- update audit ---
        audit_doc.reference.update(update_data)
        print(f"  OK    audit {audit_id} updated")

        # --- update responses ---
        responses_ref = audit_doc.reference.collection("responses")
        responses = list(responses_ref.stream())

        for resp_doc in responses:
            resp = resp_doc.to_dict()

            # skip if already migrated
            if "version_id" in resp:
                continue

            resp_doc.reference.update({
                "version_id": VERSION_ID,
                "version_number": VERSION_NUMBER,
            })

        print(f"        {len(responses)} responses updated")

        updated += 1

    print(f"\nDone. {updated} audits migrated.")


if __name__ == "__main__":
    migrate()
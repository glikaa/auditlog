"""Seed script – creates demo users in Firestore."""
import sys
import os
sys.path.insert(0, os.path.dirname(__file__))

from app.services.firebase_service import get_db


DEMO_USERS = [
    {
        "name": "Admin User",
        "email": "admin@audit.de",
        "password": "admin123",
        "role": "admin",
        "language": "de",
        "country_code": "DE",
    },
    {
        "name": "Max Auditor",
        "email": "auditor@audit.de",
        "password": "auditor123",
        "role": "auditor",
        "language": "de",
        "country_code": "DE",
    },
    {
        "name": "Lisa Preparer",
        "email": "preparer@audit.de",
        "password": "preparer123",
        "role": "preparer",
        "language": "de",
        "country_code": "DE",
    },
    {
        "name": "Klaus Abteilungsleiter",
        "email": "department@audit.de",
        "password": "department123",
        "role": "department_head",
        "language": "de",
        "country_code": "DE",
    },
    {
        "name": "Anna Filialleiter",
        "email": "branch_berlin@audit.de",
        "password": "branch123",
        "role": "branch_manager",
        "language": "de",
        "country_code": "DE",
    },
    {
        "name": "Peter Bezirksleiter",
        "email": "district@audit.de",
        "password": "district123",
        "role": "district_manager",
        "language": "de",
        "country_code": "DE",
    },
]


def seed():
    db = get_db()
    for user in DEMO_USERS:
        # Check if user already exists
        existing = db.collection("users").where("email", "==", user["email"]).limit(1).stream()
        if next(existing, None) is not None:
            print("  SKIP  {} (exists)".format(user["email"]))
            continue

        doc_ref = db.collection("users").document()
        doc_ref.set(user)
        print("  OK    {} -> role={}".format(user["email"], user["role"]))

    print("\nDone! You can now log in with any of these emails.")


if __name__ == "__main__":
    seed()

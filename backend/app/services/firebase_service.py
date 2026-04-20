"""Firebase Admin SDK wrapper for Firestore operations."""

import os
from pathlib import Path

try:
    import firebase_admin
    from firebase_admin import credentials, firestore
    _HAS_FIREBASE = True
except ImportError:
    _HAS_FIREBASE = False

from dotenv import load_dotenv

load_dotenv()

_app = None


def _get_app():
    global _app
    if not _HAS_FIREBASE:
        raise RuntimeError(
            "firebase-admin is not installed. "
            "Run: pip install firebase-admin"
        )
    if _app is not None:
        return _app

    cred_path = os.getenv("FIREBASE_CREDENTIALS_PATH", "serviceAccountKey.json")
    if Path(cred_path).exists():
        cred = credentials.Certificate(cred_path)
        _app = firebase_admin.initialize_app(cred)
    else:
        # Running on Cloud Run – uses default credentials
        _app = firebase_admin.initialize_app()
    return _app


def get_db():
    """Return Firestore client (lazy-initialised)."""
    _get_app()
    return firestore.client()

"""Firebase Admin SDK wrapper for Firestore operations."""

from __future__ import annotations

import os
from pathlib import Path

import firebase_admin
from firebase_admin import credentials, firestore
from dotenv import load_dotenv

load_dotenv()

_app: firebase_admin.App | None = None


def _get_app() -> firebase_admin.App:
    global _app
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


def get_db() -> firestore.firestore.Client:
    """Return Firestore client (lazy-initialised)."""
    _get_app()
    return firestore.client()

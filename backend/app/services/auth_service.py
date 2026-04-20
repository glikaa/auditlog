"""Lightweight auth helpers.

In production this verifies Firebase ID tokens.
For local development it issues/verifies simple JWTs.
"""

import os
from datetime import datetime, timedelta, timezone

from jose import JWTError, jwt
from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer
from dotenv import load_dotenv

from app.models.user import UserOut, UserRole

load_dotenv()

_SECRET = os.getenv("JWT_SECRET", "change-me-in-production")
_ALGORITHM = os.getenv("JWT_ALGORITHM", "HS256")
_EXPIRY_HOURS = int(os.getenv("JWT_EXPIRY_HOURS", "24"))

_bearer = HTTPBearer()


def create_token(user_id: str, role: str) -> str:
    """Create a signed JWT for local dev."""
    payload = {
        "sub": user_id,
        "role": role,
        "exp": datetime.now(timezone.utc) + timedelta(hours=_EXPIRY_HOURS),
    }
    return jwt.encode(payload, _SECRET, algorithm=_ALGORITHM)


def _decode_token(token: str) -> dict:
    try:
        return jwt.decode(token, _SECRET, algorithms=[_ALGORITHM])
    except JWTError as exc:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid or expired token",
        ) from exc


async def get_current_user(
    creds: HTTPAuthorizationCredentials = Depends(_bearer),
) -> dict:
    """Dependency that extracts the current user from the Bearer token."""
    payload = _decode_token(creds.credentials)
    return {
        "id": payload["sub"],
        "role": payload.get("role", "auditor"),
    }


async def require_role(*roles: str):
    """Factory that returns a dependency requiring one of the given roles."""

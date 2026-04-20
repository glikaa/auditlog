"""Auth endpoints – login, logout, current user."""

from __future__ import annotations

from fastapi import APIRouter, Depends, HTTPException, status

from app.models.user import TokenResponse, UserCreate, UserOut, UserRole
from app.services.auth_service import create_token, get_current_user
from app.services.firebase_service import get_db

router = APIRouter()


@router.post("/login", response_model=TokenResponse)
async def login(email: str, password: str):
    """Authenticate and return a JWT.

    For now uses Firestore user lookup.
    Replace with Firebase Auth `verify_id_token` in production.
    """
    db = get_db()
    users_ref = db.collection("users").where("email", "==", email).limit(1)
    docs = users_ref.stream()

    user_doc = next(docs, None)
    if user_doc is None:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid credentials",
        )

    user_data = user_doc.to_dict()
    # In production, verify password hash – this is a simplified demo
    token = create_token(user_doc.id, user_data.get("role", "auditor"))

    return TokenResponse(
        access_token=token,
        user=UserOut(
            id=user_doc.id,
            name=user_data.get("name", ""),
            email=user_data.get("email", ""),
            role=user_data.get("role", "auditor"),
            language=user_data.get("language", "de"),
            country_code=user_data.get("country_code", "DE"),
        ),
    )


@router.post("/logout")
async def logout(user: dict = Depends(get_current_user)):
    """Logout – client should discard the token."""
    return {"message": "Logged out"}


@router.get("/me", response_model=UserOut)
async def get_me(user: dict = Depends(get_current_user)):
    """Return the current user's profile."""
    db = get_db()
    doc = db.collection("users").document(user["id"]).get()
    if not doc.exists:
        raise HTTPException(status_code=404, detail="User not found")

    data = doc.to_dict()
    return UserOut(
        id=doc.id,
        name=data.get("name", ""),
        email=data.get("email", ""),
        role=data.get("role", "auditor"),
        language=data.get("language", "de"),
        country_code=data.get("country_code", "DE"),
    )

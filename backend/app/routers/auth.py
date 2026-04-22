"""Auth endpoints – login, logout, current user."""

import uuid
from typing import List

from fastapi import APIRouter, Depends, HTTPException, Query, status

from app.models.user import LoginRequest, TokenResponse, UserCreate, UserOut, UserRole
from app.services.auth_service import create_token, get_current_user
from app.services.firebase_service import get_db

router = APIRouter()


@router.post("/login", response_model=TokenResponse)
async def login(body: LoginRequest):
    """Authenticate and return a JWT.

    For now uses Firestore user lookup.
    Replace with Firebase Auth `verify_id_token` in production.
    """
    db = get_db()
    users_ref = db.collection("users").where("email", "==", body.email).limit(1)
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
            branch_id=user_data.get("branch_id"),
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
        branch_id=data.get("branch_id"),
    )


@router.post("/users", response_model=UserOut, status_code=201)
async def create_user(
    body: UserCreate,
    user: dict = Depends(get_current_user),
):
    """Create a new user (admin only)."""
    if user["role"] != "admin":
        raise HTTPException(status_code=403, detail="Admin only")

    db = get_db()
    existing = db.collection("users").where("email", "==", body.email).limit(1).stream()
    if next(existing, None) is not None:
        raise HTTPException(status_code=409, detail="Email already exists")

    user_id = str(uuid.uuid4())
    data = body.dict()
    db.collection("users").document(user_id).set(data)

    return UserOut(
        id=user_id,
        name=data["name"],
        email=data["email"],
        role=data["role"],
        language=data["language"],
        country_code=data["country_code"],
    )


@router.get("/users", response_model=List[UserOut])
async def get_users_by_role(
    roles: str = Query(default="auditor,preparer"),
    user: dict = Depends(get_current_user),
):
    """Return users filtered by role (comma-separated list)."""
    db = get_db()
    role_list = [r.strip() for r in roles.split(",") if r.strip()]
    results: List[UserOut] = []
    seen_ids: set = set()
    for role in role_list:
        docs = db.collection("users").where("role", "==", role).stream()
        for doc in docs:
            if doc.id in seen_ids:
                continue
            seen_ids.add(doc.id)
            data = doc.to_dict()
            results.append(
                UserOut(
                    id=doc.id,
                    name=data.get("name", ""),
                    email=data.get("email", ""),
                    role=data.get("role", role),
                    language=data.get("language", "de"),
                    country_code=data.get("country_code", "DE"),
                )
            )
    return results

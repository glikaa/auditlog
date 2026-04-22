"""Branch list endpoint."""

from typing import List, Optional

from fastapi import APIRouter, Depends

from app.models.branch import BranchOut
from app.services.auth_service import get_current_user
from app.services.firebase_service import get_db

router = APIRouter()


@router.get("", response_model=List[BranchOut])
async def list_branches(
    country: Optional[str] = None,
    user: dict = Depends(get_current_user),
):
    """List all branches, optionally filtered by country_code."""
    db = get_db()
    query = db.collection("branches")

    if country:
        query = query.where("country_code", "==", country)

    docs = query.stream()
    branches = []
    for doc in docs:
        data = doc.to_dict()
        data["id"] = doc.id
        branches.append(BranchOut(**data))
    return branches

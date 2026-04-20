from datetime import datetime
from enum import Enum
from typing import Optional

from pydantic import BaseModel, Field


class UserRole(str, Enum):
    admin = "admin"
    auditor = "auditor"
    preparer = "preparer"
    department_head = "department_head"
    branch_manager = "branch_manager"
    district_manager = "district_manager"


class UserBase(BaseModel):
    name: str
    email: str
    role: UserRole
    language: str = "de"
    country_code: str = "DE"


class UserCreate(UserBase):
    password: str = Field(..., min_length=8)


class UserOut(UserBase):
    id: str


class TokenResponse(BaseModel):
    access_token: str
    token_type: str = "bearer"
    user: UserOut

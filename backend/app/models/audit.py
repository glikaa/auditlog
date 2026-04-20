from __future__ import annotations

from datetime import datetime
from enum import Enum

from pydantic import BaseModel, Field


class AuditType(str, Enum):
    filialrevision = "filialrevision"
    nachrevision = "nachrevision"


class AuditStatus(str, Enum):
    draft = "draft"
    in_progress = "in_progress"
    completed = "completed"
    released = "released"


class AuditCreate(BaseModel):
    type: AuditType = AuditType.filialrevision
    catalog_id: str
    branch_id: str
    branch_name: str
    auditor_id: str
    auditor_name: str
    preparer_id: str | None = None
    is_nachrevision: bool = False
    linked_audit_id: str | None = None


class AuditUpdate(BaseModel):
    management_summary: str | None = None
    status: AuditStatus | None = None


class AuditOut(BaseModel):
    id: str
    type: AuditType
    catalog_id: str
    branch_id: str
    branch_name: str
    auditor_id: str
    auditor_name: str
    preparer_id: str | None = None
    status: AuditStatus
    result_percent: float | None = None
    count_yes: int = 0
    count_no: int = 0
    count_na: int = 0
    management_summary: str | None = None
    created_at: datetime
    completed_at: datetime | None = None
    is_nachrevision: bool = False
    linked_audit_id: str | None = None

from datetime import datetime
from enum import Enum
from typing import Optional

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
    preparer_id: Optional[str] = None
    is_nachrevision: bool = False
    linked_audit_id: Optional[str] = None


class AuditUpdate(BaseModel):
    management_summary: Optional[str] = None
    status: Optional[AuditStatus] = None


class AuditOut(BaseModel):
    id: str
    type: AuditType
    catalog_id: str
    branch_id: str
    branch_name: str
    auditor_id: str
    auditor_name: str
    preparer_id: Optional[str] = None
    status: AuditStatus
    result_percent: Optional[float] = None
    count_yes: int = 0
    count_no: int = 0
    count_na: int = 0
    management_summary: Optional[str] = None
    created_at: datetime
    completed_at: Optional[datetime] = None
    is_nachrevision: bool = False
    linked_audit_id: Optional[str] = None
    acknowledged_at: Optional[datetime] = None

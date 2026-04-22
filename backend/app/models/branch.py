from typing import Optional

from pydantic import BaseModel


class BranchOut(BaseModel):
    id: str
    name: str
    country_code: str
    address: str
    manager_id: Optional[str] = None
    district_manager_id: Optional[str] = None

from datetime import datetime
from enum import Enum
from typing import List, Optional

from pydantic import BaseModel


class Rating(str, Enum):
    yes = "yes"
    no = "no"
    na = "na"


class ComparisonResult(str, Enum):
    improved = "improved"
    worsened = "worsened"
    unchanged = "unchanged"


class AttachmentData(BaseModel):
    id: str
    url: str
    type: str  # "image" or "pdf"
    is_report_relevant: bool = True


class ResponseUpdate(BaseModel):
    question_id: str
    rating: Optional[Rating] = None
    finding: str = ""
    measure: str = ""
    attachments: List[AttachmentData] = []
    comparison_result: Optional[ComparisonResult] = None
    previous_rating: Optional[Rating] = None
    previous_finding: Optional[str] = None


class ResponseOut(ResponseUpdate):
    updated_at: Optional[datetime] = None

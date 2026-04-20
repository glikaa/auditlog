from __future__ import annotations

from datetime import datetime
from enum import Enum

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
    rating: Rating | None = None
    finding: str = ""
    measure: str = ""
    attachments: list[AttachmentData] = []
    comparison_result: ComparisonResult | None = None
    previous_rating: Rating | None = None
    previous_finding: str | None = None


class ResponseOut(ResponseUpdate):
    updated_at: datetime | None = None

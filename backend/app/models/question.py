from __future__ import annotations

from pydantic import BaseModel


class QuestionCreate(BaseModel):
    catalog_id: str
    master_question_id: str | None = None
    order: int
    category: str
    text_de: str
    text_hr: str | None = None
    explanation_text_de: str | None = None
    explanation_text_hr: str | None = None
    internal_note_de: str | None = None
    internal_note_hr: str | None = None
    default_finding_de: str | None = None
    default_finding_hr: str | None = None
    default_measure_de: str | None = None
    default_measure_hr: str | None = None


class QuestionOut(QuestionCreate):
    id: str


class CatalogCreate(BaseModel):
    country_code: str
    version: str
    year: int
    language: str = "de"


class CatalogOut(CatalogCreate):
    id: str
    question_count: int = 0
    created_at: str | None = None

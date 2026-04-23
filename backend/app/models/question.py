from typing import Optional

from pydantic import BaseModel


class QuestionCreate(BaseModel):
    catalog_id: str
    master_question_id: Optional[str] = None
    order: int
    category: str
    category_en: Optional[str] = None
    category_hr: Optional[str] = None
    text_de: Optional[str] = None
    text_en: Optional[str] = None
    text_hr: Optional[str] = None
    explanation_text_de: Optional[str] = None
    explanation_text_en: Optional[str] = None
    explanation_text_hr: Optional[str] = None
    internal_note_de: Optional[str] = None
    internal_note_en: Optional[str] = None
    internal_note_hr: Optional[str] = None
    default_finding_de: Optional[str] = None
    default_finding_en: Optional[str] = None
    default_finding_hr: Optional[str] = None
    default_measure_de: Optional[str] = None
    default_measure_en: Optional[str] = None
    default_measure_hr: Optional[str] = None


class QuestionOut(QuestionCreate):
    id: str


class QuestionReorder(BaseModel):
    id: str
    order: int


class CatalogCreate(BaseModel):
    country_code: str
    version: str
    year: int
    language: str = "de"


class CatalogClone(BaseModel):
    """Payload for cloning an existing catalog into a new version."""
    version: str
    year: int
    language: str = "de"


class CatalogOut(CatalogCreate):
    id: str
    question_count: int = 0
    created_at: Optional[str] = None

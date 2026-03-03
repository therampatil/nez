from pydantic import BaseModel
from datetime import datetime
from typing import Optional


class ArticleCreate(BaseModel):
    title: str
    description: Optional[str] = None
    content: Optional[str] = None
    image_url: Optional[str] = None
    source: Optional[str] = None
    published_at: Optional[datetime] = None
    category_id: Optional[int] = None


class ArticleResponse(BaseModel):
    id: int
    title: str
    description: Optional[str] = None
    content: Optional[str] = None
    image_url: Optional[str] = None
    source: Optional[str] = None
    published_at: Optional[datetime] = None
    category_id: Optional[int] = None
    created_at: datetime

    # ── AI-generated intelligence fields ──────────────────────────────────
    overview: Optional[str] = None
    in_context: Optional[str] = None          # background / why it's happening
    why_it_matters: Optional[str] = None      # newline-separated bullet points
    category: Optional[str] = None            # AI-assigned topic (e.g. "Politics")
    is_high_quality: Optional[bool] = None    # AI quality gate result
    is_processed: bool = False                # whether AI has run on this article

    class Config:
        from_attributes = True

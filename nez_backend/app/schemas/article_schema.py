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

    # ── Pre-analysed intelligence fields (from the news backend) ─────────
    overview: Optional[str] = None
    in_context: Optional[str] = None
    why_it_matters: Optional[str] = None
    category: Optional[str] = None
    is_high_quality: Optional[bool] = None
    is_processed: bool = False

    class Config:
        from_attributes = True

"""Pydantic schemas for news articles (read from the shared news database)."""

from pydantic import BaseModel
from datetime import datetime
from typing import Optional


class NewsArticleResponse(BaseModel):
    """Response schema for a single news article."""
    id: int
    title: str
    url: str
    source: Optional[str] = None
    overview: Optional[str] = None
    why_this_matters: Optional[str] = None
    impact: Optional[str] = None
    category: Optional[str] = None
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True

"""Pydantic schemas for news headlines (read from the shared news database)."""

from pydantic import BaseModel
from datetime import datetime
from typing import Optional


class NewsHeadlineResponse(BaseModel):
    """Response schema for a single news headline."""
    id: int
    headline: str
    article_url: str
    source: Optional[str] = None
    image_url: Optional[str] = None
    category: Optional[str] = None
    overview: Optional[str] = None
    why_this_matters: Optional[str] = None
    impact: Optional[str] = None
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True

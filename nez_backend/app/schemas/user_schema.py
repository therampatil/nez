from pydantic import BaseModel, EmailStr
from datetime import datetime
from typing import Optional, List, Dict


class UserCreate(BaseModel):
    email: str


class UserResponse(BaseModel):
    id: int
    email: str
    username: Optional[str] = None
    created_at: datetime

    class Config:
        from_attributes = True


class UpdateProfilePayload(BaseModel):
    """Request body for PATCH /users/me — update display name."""
    username: Optional[str] = None


class PreferencesPayload(BaseModel):
    """Request body for PUT /users/me/preferences."""
    categories: List[str]


class PreferencesResponse(BaseModel):
    """Response for GET and PUT /users/me/preferences."""
    categories: List[str]


# ── Insights ────────────────────────────────────────────
class CategoryStat(BaseModel):
    label: str
    count: int
    pct: float


class InsightsResponse(BaseModel):
    total_articles_read: int
    current_streak: int
    longest_streak: int
    total_read_seconds: float
    this_week_read_seconds: float
    today_read_seconds: float
    weekly_reads: List[int]        # Mon–Sun counts for current week
    streak_grid: List[bool]        # last 35 days (oldest first)
    top_categories: List[CategoryStat]

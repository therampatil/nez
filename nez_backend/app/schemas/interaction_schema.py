from pydantic import BaseModel
from datetime import datetime
from typing import Optional


class InteractionCreate(BaseModel):
    user_id: Optional[int] = None   # ignored if set by client; server overrides with JWT user
    article_id: int
    interaction_type: str = "read"  # "view", "read", "like", "share", "bookmark"
    read_time: float = 0.0  # seconds


class InteractionResponse(BaseModel):
    id: int
    user_id: int
    article_id: int
    interaction_type: str
    read_time: float
    created_at: datetime

    class Config:
        from_attributes = True

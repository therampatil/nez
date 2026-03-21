from pydantic import BaseModel, ConfigDict
from datetime import datetime
from typing import Optional, List


class FollowStoryCreate(BaseModel):
    """Request to follow a news story."""
    article_id: int
    story_key: str  # Identifier for grouping related articles
    story_title: str


class FollowStoryResponse(BaseModel):
    """Response after following a story."""
    model_config = ConfigDict(from_attributes=True)
    
    id: int
    user_id: int
    original_article_id: int
    story_key: str
    story_title: str
    created_at: datetime


class FollowedStoryWithUpdates(BaseModel):
    """A followed story with its updates."""
    model_config = ConfigDict(from_attributes=True)
    
    id: int
    original_article_id: int
    story_key: str
    story_title: str
    created_at: datetime
    last_checked_at: datetime
    
    # List of new article IDs that are updates to this story
    updates: List[int]
    unread_count: int  # Number of updates since last_checked_at


class UnfollowStoryRequest(BaseModel):
    """Request to unfollow a story."""
    story_id: int

from typing import Optional

from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from app.api.deps import get_db, get_current_user
from app.models.user import User
from app.services.feed_service import get_feed as service_get_feed
from app.schemas.feed_schema import FeedResponse

router = APIRouter()


@router.get("/", response_model=FeedResponse)
def get_feed(
    limit: int = 20,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """Get personalized feed for the authenticated user."""
    articles = service_get_feed(db, user_id=current_user.id, limit=limit)
    return FeedResponse(articles=articles, count=len(articles))

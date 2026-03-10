"""Personalised feed endpoint.

Reads user preferences from the user DB, fetches articles from the news DB,
and ranks them using recency + preference scores.
"""

from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from app.api.deps import get_db, get_news_db, get_current_user
from app.models.user import User
from app.services.feed_service import get_feed as service_get_feed
from app.schemas.feed_schema import FeedResponse

router = APIRouter()


@router.get("/", response_model=FeedResponse)
def get_feed(
    limit: int = 20,
    current_user: User = Depends(get_current_user),
    user_db: Session = Depends(get_db),
    news_db: Session = Depends(get_news_db),
):
    """Get personalised feed for the authenticated user."""
    articles = service_get_feed(
        user_db=user_db,
        news_db=news_db,
        user_id=current_user.id,
        limit=limit,
    )
    return FeedResponse(articles=articles, count=len(articles))

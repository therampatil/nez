import logging
from typing import Optional

from sqlalchemy.orm import Session

from app.repositories.feed_repo import get_latest_articles as repo_get_latest
from app.services.interaction_service import get_user_preferences
from app.services.ranking_service import rank_articles
from app.core.constants.ranking import DEFAULT_FEED_LIMIT

logger = logging.getLogger(__name__)


def get_feed(db: Session, user_id: Optional[int] = None, limit: int = DEFAULT_FEED_LIMIT):
    """Get feed — personalized if user_id provided, otherwise chronological."""

    if user_id:
        # Personalized feed
        preferences = get_user_preferences(db, user_id)
        logger.info(f"Personalized feed for user={user_id}, preferences={preferences}")
        return rank_articles(db, user_preferences=preferences, limit=limit)
    else:
        # Generic feed — latest articles by recency
        logger.info("Generic feed — no user_id provided")
        return repo_get_latest(db, limit=limit)


# Keep backward compatibility
def get_latest_articles(db: Session, limit: int = DEFAULT_FEED_LIMIT):
    return get_feed(db, user_id=None, limit=limit)

"""Feed service — fetches articles from the news DB, ranked by user preferences.

User preferences live in the user DB; articles live in the news DB.
"""

import logging
from typing import Optional

from sqlalchemy.orm import Session

from app.models.news_article import NewsArticle
from app.services.interaction_service import get_user_preferences
from app.services.ranking_service import rank_articles
from app.core.constants.ranking import DEFAULT_FEED_LIMIT

logger = logging.getLogger(__name__)


def get_feed(
    *,
    user_db: Session,
    news_db: Session,
    user_id: Optional[int] = None,
    limit: int = DEFAULT_FEED_LIMIT,
):
    """Get personalised feed — preferences from user_db, articles from news_db."""

    if user_id:
        preferences = get_user_preferences(user_db, user_id)
        logger.info("Personalised feed for user=%s, preferences=%s", user_id, preferences)
        return rank_articles(news_db, user_preferences=preferences, limit=limit)
    else:
        logger.info("Generic feed — no user_id provided")
        return _get_latest(news_db, limit=limit)


def _get_latest(news_db: Session, limit: int = DEFAULT_FEED_LIMIT):
    """Return the latest articles from the news database, ordered by recency."""
    return (
        news_db.query(NewsArticle)
        .order_by(NewsArticle.created_at.desc())
        .limit(limit)
        .all()
    )

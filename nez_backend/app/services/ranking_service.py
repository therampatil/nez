"""Ranking service — scores and sorts articles from the news DB by
recency and user category preferences."""

import logging
from datetime import datetime, timedelta, timezone
from typing import List

from sqlalchemy.orm import Session

from app.models.news_article import NewsArticle
from app.core.constants.ranking import (
    RECENCY_SCORE_TODAY,
    RECENCY_SCORE_1_DAY,
    RECENCY_SCORE_2_DAYS,
    RECENCY_SCORE_OLD,
    DEFAULT_CATEGORY_WEIGHT,
    DEFAULT_FEED_LIMIT,
    MAX_FEED_LIMIT,
)

logger = logging.getLogger(__name__)


def _recency_score(created_at: datetime) -> float:
    """Score based on how recently an article was created."""
    if not created_at:
        return RECENCY_SCORE_OLD

    now = datetime.now(timezone.utc)
    # Handle naive datetimes from DB
    if created_at.tzinfo is None:
        created_at = created_at.replace(tzinfo=timezone.utc)
    age = now - created_at

    if age < timedelta(hours=12):
        return RECENCY_SCORE_TODAY
    elif age < timedelta(days=1):
        return RECENCY_SCORE_1_DAY
    elif age < timedelta(days=2):
        return RECENCY_SCORE_2_DAYS
    else:
        return RECENCY_SCORE_OLD


def _category_score(category: str, user_preferences: dict) -> float:
    """Score based on user's preference for this category."""
    if not category or not user_preferences:
        return DEFAULT_CATEGORY_WEIGHT
    return user_preferences.get(category, DEFAULT_CATEGORY_WEIGHT)


def rank_articles(
    news_db: Session,
    user_preferences: dict,
    limit: int = DEFAULT_FEED_LIMIT,
) -> List[NewsArticle]:
    """Fetch articles from the news DB and rank them with personalised scoring."""
    limit = min(limit, MAX_FEED_LIMIT)

    # Fetch a larger pool to rank from (3x limit for good variety).
    pool_size = min(limit * 3, MAX_FEED_LIMIT)
    articles = (
        news_db.query(NewsArticle)
        .order_by(NewsArticle.created_at.desc())
        .limit(pool_size)
        .all()
    )

    # Score each article
    scored = []
    for article in articles:
        recency = _recency_score(article.created_at)
        category = _category_score(article.category, user_preferences)
        total_score = recency + category
        scored.append((total_score, article))

    # Sort by total score descending
    scored.sort(key=lambda x: x[0], reverse=True)

    ranked_articles = [article for _, article in scored[:limit]]

    logger.debug(
        "Ranked %d articles from pool of %d with %d preference weights",
        len(ranked_articles), len(articles), len(user_preferences),
    )

    return ranked_articles

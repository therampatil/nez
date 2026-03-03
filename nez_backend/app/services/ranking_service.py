import logging
from datetime import datetime, timedelta
from typing import List

from sqlalchemy.orm import Session

from app.models.article import Article
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


def _recency_score(published_at: datetime) -> float:
    """Score based on how recently an article was published."""
    if not published_at:
        return RECENCY_SCORE_OLD

    now = datetime.utcnow()
    age = now - published_at

    if age < timedelta(hours=12):
        return RECENCY_SCORE_TODAY
    elif age < timedelta(days=1):
        return RECENCY_SCORE_1_DAY
    elif age < timedelta(days=2):
        return RECENCY_SCORE_2_DAYS
    else:
        return RECENCY_SCORE_OLD


def _category_score(article_source: str, user_preferences: dict) -> float:
    """Score based on user's preference for this source/category."""
    if not article_source or not user_preferences:
        return DEFAULT_CATEGORY_WEIGHT
    return user_preferences.get(article_source, DEFAULT_CATEGORY_WEIGHT)


def rank_articles(
    db: Session,
    user_preferences: dict,
    limit: int = DEFAULT_FEED_LIMIT,
) -> List[Article]:
    """Fetch articles and rank them with personalized scoring."""
    limit = min(limit, MAX_FEED_LIMIT)

    # Fetch a larger pool to rank from (3x limit for good variety).
    # No quality gate here — filtering is done by the news backend before
    # articles land in the shared database.
    pool_size = min(limit * 3, MAX_FEED_LIMIT)
    articles = (
        db.query(Article)
        .order_by(Article.published_at.desc())
        .limit(pool_size)
        .all()
    )

    # Score each article
    scored = []
    for article in articles:
        recency = _recency_score(article.published_at)
        category = _category_score(article.source, user_preferences)
        total_score = recency + category

        scored.append((total_score, article))

    # Sort by total score descending
    scored.sort(key=lambda x: x[0], reverse=True)

    ranked_articles = [article for _, article in scored[:limit]]

    logger.debug(
        f"Ranked {len(ranked_articles)} articles from pool of {len(articles)} "
        f"with {len(user_preferences)} preference weights"
    )

    return ranked_articles

"""Interaction service — records user interactions and updates preference weights.

Uses two DB sessions:
  - user_db  for interactions, bookmarks, user_preferences (read/write)
  - news_db  for looking up the article's category (read-only)
"""

import logging
from sqlalchemy.orm import Session

from app.models.interaction import Interaction
from app.models.news_article import NewsArticle
from app.models.user_preference import UserPreference
from app.schemas.interaction_schema import InteractionCreate
from app.core.constants.ranking import (
    CATEGORY_WEIGHT_MULTIPLIER,
    CATEGORY_WEIGHT_MAX,
    MIN_READ_TIME_SECONDS,
    DEEP_READ_THRESHOLD,
    DEEP_READ_BONUS,
    ENGAGEMENT_VIEW_WEIGHT,
    ENGAGEMENT_READ_WEIGHT,
    ENGAGEMENT_LIKE_WEIGHT,
    ENGAGEMENT_SHARE_WEIGHT,
    ENGAGEMENT_BOOKMARK_WEIGHT,
)

logger = logging.getLogger(__name__)

INTERACTION_WEIGHTS = {
    "view": ENGAGEMENT_VIEW_WEIGHT,
    "read": ENGAGEMENT_READ_WEIGHT,
    "like": ENGAGEMENT_LIKE_WEIGHT,
    "share": ENGAGEMENT_SHARE_WEIGHT,
    "bookmark": ENGAGEMENT_BOOKMARK_WEIGHT,
}


def record_interaction(
    *,
    user_db: Session,
    news_db: Session,
    data: InteractionCreate,
) -> Interaction:
    """Record an interaction and update user preferences.

    Looks up the article in the news DB to get its category, then stores
    the interaction (with denormalised category) in the user DB.
    """

    # Skip noise (accidental taps)
    if data.read_time > 0 and data.read_time < MIN_READ_TIME_SECONDS:
        logger.debug("Skipping interaction: read_time %ss < threshold", data.read_time)

    # 1. Look up the article in the news DB to get its category
    article = news_db.query(NewsArticle).filter(NewsArticle.id == data.article_id).first()
    article_category = article.category if article else None

    # 2. Save the interaction in the user DB
    interaction = Interaction(
        user_id=data.user_id,
        article_id=data.article_id,
        article_category=article_category,
        interaction_type=data.interaction_type,
        read_time=data.read_time,
    )
    user_db.add(interaction)

    if not article_category:
        user_db.commit()
        user_db.refresh(interaction)
        return interaction

    # 3. Calculate weight to add
    base_weight = INTERACTION_WEIGHTS.get(data.interaction_type, 1.0)
    read_weight = data.read_time * CATEGORY_WEIGHT_MULTIPLIER
    deep_read_bonus = DEEP_READ_BONUS if data.read_time >= DEEP_READ_THRESHOLD else 0.0
    total_weight = base_weight + read_weight + deep_read_bonus

    # 4. Update or create user preference
    pref = (
        user_db.query(UserPreference)
        .filter(
            UserPreference.user_id == data.user_id,
            UserPreference.source == article_category,
        )
        .first()
    )

    if pref:
        pref.weight = min(pref.weight + total_weight, CATEGORY_WEIGHT_MAX)
        pref.interaction_count += 1
    else:
        pref = UserPreference(
            user_id=data.user_id,
            source=article_category,
            weight=min(total_weight, CATEGORY_WEIGHT_MAX),
            interaction_count=1,
        )
        user_db.add(pref)

    user_db.commit()
    user_db.refresh(interaction)

    logger.info(
        "Interaction recorded: user=%s, article=%s, type=%s, weight_added=%.2f, category=%s",
        data.user_id, data.article_id, data.interaction_type, total_weight, article_category,
    )

    return interaction


def get_user_preferences(db: Session, user_id: int) -> dict:
    """Get user's preference weights as a dict: {category: weight}."""
    prefs = (
        db.query(UserPreference)
        .filter(UserPreference.user_id == user_id)
        .all()
    )
    return {p.source: p.weight for p in prefs}

import logging
from sqlalchemy.orm import Session

from app.models.interaction import Interaction
from app.models.article import Article
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


def record_interaction(db: Session, data: InteractionCreate) -> Interaction:
    """Record an interaction and update user preferences."""

    # Skip noise (accidental taps)
    if data.read_time > 0 and data.read_time < MIN_READ_TIME_SECONDS:
        logger.debug(f"Skipping interaction: read_time {data.read_time}s < threshold")

    # 1. Save the interaction
    interaction = Interaction(
        user_id=data.user_id,
        article_id=data.article_id,
        interaction_type=data.interaction_type,
        read_time=data.read_time,
    )
    db.add(interaction)

    # 2. Look up the article to get its source (proxy for category)
    article = db.query(Article).filter(Article.id == data.article_id).first()
    if not article or not article.source:
        db.commit()
        return interaction

    # 3. Calculate weight to add
    base_weight = INTERACTION_WEIGHTS.get(data.interaction_type, 1.0)
    read_weight = data.read_time * CATEGORY_WEIGHT_MULTIPLIER
    deep_read_bonus = DEEP_READ_BONUS if data.read_time >= DEEP_READ_THRESHOLD else 0.0
    total_weight = base_weight + read_weight + deep_read_bonus

    # 4. Update or create user preference
    pref = (
        db.query(UserPreference)
        .filter(
            UserPreference.user_id == data.user_id,
            UserPreference.source == article.source,
        )
        .first()
    )

    if pref:
        pref.weight = min(pref.weight + total_weight, CATEGORY_WEIGHT_MAX)
        pref.interaction_count += 1
    else:
        pref = UserPreference(
            user_id=data.user_id,
            source=article.source,
            weight=min(total_weight, CATEGORY_WEIGHT_MAX),
            interaction_count=1,
        )
        db.add(pref)

    db.commit()
    db.refresh(interaction)

    logger.info(
        f"Interaction recorded: user={data.user_id}, article={data.article_id}, "
        f"type={data.interaction_type}, weight_added={total_weight:.2f}, "
        f"source={article.source}"
    )

    return interaction


def get_user_preferences(db: Session, user_id: int) -> dict:
    """Get user's preference weights as a dict: {source: weight}."""
    prefs = (
        db.query(UserPreference)
        .filter(UserPreference.user_id == user_id)
        .all()
    )
    return {p.source: p.weight for p in prefs}

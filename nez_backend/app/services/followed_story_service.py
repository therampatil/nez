"""Service for managing followed stories and their updates."""

import logging
from typing import List
from sqlalchemy.orm import Session
from sqlalchemy import and_
from datetime import datetime

from app.models.followed_story import FollowedStory, StoryUpdate
from app.models.news_article import NewsArticle
from app.schemas.followed_story_schema import FollowStoryCreate, FollowedStoryWithUpdates
from app.schemas.article_schema import NewsArticleResponse

logger = logging.getLogger(__name__)


def follow_story(
    user_db: Session,
    user_id: int,
    data: FollowStoryCreate,
) -> FollowedStory:
    """Create a followed story for a user."""
    
    # Check if already following
    existing = (
        user_db.query(FollowedStory)
        .filter(
            and_(
                FollowedStory.user_id == user_id,
                FollowedStory.story_key == data.story_key,
            )
        )
        .first()
    )
    
    if existing:
        return existing
    
    followed = FollowedStory(
        user_id=user_id,
        original_article_id=data.article_id,
        story_key=data.story_key,
        story_title=data.story_title,
    )
    
    user_db.add(followed)
    user_db.commit()
    user_db.refresh(followed)
    
    logger.info(
        "User %s following story: %s (article %s)",
        user_id, data.story_key, data.article_id
    )
    
    return followed


def unfollow_story(
    user_db: Session,
    user_id: int,
    story_id: int,
) -> bool:
    """Unfollow a story. Returns True if deleted, False if not found."""
    followed = (
        user_db.query(FollowedStory)
        .filter(
            and_(
                FollowedStory.id == story_id,
                FollowedStory.user_id == user_id,
            )
        )
        .first()
    )
    
    if not followed:
        return False
    
    user_db.delete(followed)
    user_db.commit()
    
    logger.info("User %s unfollowed story %s", user_id, story_id)
    return True


def get_followed_stories(
    user_db: Session,
    news_db: Session,
    user_id: int,
) -> List[FollowedStoryWithUpdates]:
    """Get all stories the user is following with their updates."""
    
    followed_stories = (
        user_db.query(FollowedStory)
        .filter(FollowedStory.user_id == user_id)
        .order_by(FollowedStory.created_at.desc())
        .all()
    )
    
    result = []
    for story in followed_stories:
        # Get all updates for this story
        updates = (
            user_db.query(StoryUpdate)
            .filter(StoryUpdate.story_key == story.story_key)
            .filter(StoryUpdate.created_at > story.created_at)
            .all()
        )
        
        # Count unread updates (created after last_checked_at)
        unread = sum(
            1 for u in updates
            if u.created_at > story.last_checked_at
        )
        
        result.append(
            FollowedStoryWithUpdates(
                id=story.id,
                original_article_id=story.original_article_id,
                story_key=story.story_key,
                story_title=story.story_title,
                created_at=story.created_at,
                last_checked_at=story.last_checked_at,
                updates=[u.article_id for u in updates],
                unread_count=unread,
            )
        )
    
    return result


def get_followed_news_feed(
    user_db: Session,
    news_db: Session,
    user_id: int,
    limit: int = 50,
) -> List[NewsArticleResponse]:
    """Get a feed of updates for all followed stories.
    
    Returns the most recent articles that are updates to stories the user follows,
    ordered by recency.
    """
    
    # Get all story keys the user is following
    followed_stories = (
        user_db.query(FollowedStory)
        .filter(FollowedStory.user_id == user_id)
        .all()
    )
    
    if not followed_stories:
        return []
    
    story_keys = [s.story_key for s in followed_stories]
    
    # Get all updates for these stories
    updates = (
        user_db.query(StoryUpdate)
        .filter(StoryUpdate.story_key.in_(story_keys))
        .order_by(StoryUpdate.created_at.desc())
        .limit(limit)
        .all()
    )
    
    if not updates:
        return []
    
    # Fetch the actual articles from news DB
    article_ids = [u.article_id for u in updates]
    articles = (
        news_db.query(NewsArticle)
        .filter(NewsArticle.id.in_(article_ids))
        .all()
    )
    
    # Convert to response schema, maintaining the order from updates
    article_map = {a.id: a for a in articles}
    result = []
    for update in updates:
        if update.article_id in article_map:
            article = article_map[update.article_id]
            result.append(
                NewsArticleResponse(
                    id=article.id,
                    title=article.title,
                    url=article.url,
                    source=article.source,
                    image_url=article.image_url,
                    overview=article.overview,
                    why_this_matters=article.why_this_matters,
                    impact=article.impact,
                    category=article.category,
                    created_at=article.created_at,
                    updated_at=article.updated_at,
                )
            )
    
    return result


def mark_story_checked(
    user_db: Session,
    user_id: int,
    story_id: int,
) -> bool:
    """Mark a followed story as checked (updates last_checked_at)."""
    
    story = (
        user_db.query(FollowedStory)
        .filter(
            and_(
                FollowedStory.id == story_id,
                FollowedStory.user_id == user_id,
            )
        )
        .first()
    )
    
    if not story:
        return False
    
    story.last_checked_at = datetime.utcnow()
    user_db.commit()
    
    return True


def is_story_followed(
    user_db: Session,
    user_id: int,
    story_key: str,
) -> bool:
    """Check if a user is following a specific story."""
    
    exists = (
        user_db.query(FollowedStory)
        .filter(
            and_(
                FollowedStory.user_id == user_id,
                FollowedStory.story_key == story_key,
            )
        )
        .first()
    )
    
    return exists is not None

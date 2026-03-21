"""Background service to detect and link story updates.

This service runs periodically to:
1. Scan new articles in the news DB
2. Match them to existing followed stories based on keywords, categories, etc.
3. Create StoryUpdate records to link updates to original stories
"""

import logging
from typing import List, Set
from sqlalchemy.orm import Session
from datetime import datetime, timedelta

from app.models.followed_story import FollowedStory, StoryUpdate
from app.models.news_article import NewsArticle

logger = logging.getLogger(__name__)


def extract_keywords(text: str) -> Set[str]:
    """Extract meaningful keywords from text for matching."""
    # Simple keyword extraction - remove common words
    stop_words = {
        'the', 'a', 'an', 'and', 'or', 'but', 'in', 'on', 'at', 'to', 'for',
        'of', 'with', 'by', 'from', 'is', 'are', 'was', 'were', 'been', 'be',
        'have', 'has', 'had', 'this', 'that', 'these', 'those', 'it', 'its',
    }
    
    words = text.lower().split()
    keywords = {
        w.strip('.,!?;:') for w in words
        if len(w) > 3 and w.lower() not in stop_words
    }
    return keywords


def calculate_similarity(story_key: str, article_title: str, article_category: str) -> float:
    """Calculate how similar an article is to a story.
    
    Returns a score from 0.0 to 1.0.
    """
    story_keywords = extract_keywords(story_key.replace('-', ' '))
    title_keywords = extract_keywords(article_title)
    
    if not story_keywords or not title_keywords:
        return 0.0
    
    # Calculate keyword overlap
    common = story_keywords.intersection(title_keywords)
    similarity = len(common) / len(story_keywords)
    
    # Boost if category matches
    if article_category and article_category.lower() in story_key.lower():
        similarity += 0.3
    
    return min(similarity, 1.0)


def detect_story_updates(
    user_db: Session,
    news_db: Session,
    hours_lookback: int = 24,
    similarity_threshold: float = 0.4,
) -> int:
    """Detect new articles that are updates to followed stories.
    
    Returns the number of new updates detected.
    """
    
    # Get all unique story keys being followed
    all_stories = user_db.query(FollowedStory).all()
    if not all_stories:
        return 0
    
    story_keys = list({s.story_key for s in all_stories})
    
    # Get recent articles that might be updates
    cutoff = datetime.utcnow() - timedelta(hours=hours_lookback)
    recent_articles = (
        news_db.query(NewsArticle)
        .filter(NewsArticle.created_at >= cutoff)
        .all()
    )
    
    if not recent_articles:
        return 0
    
    # Check each story for potential updates
    updates_added = 0
    
    for story_key in story_keys:
        # Get existing update IDs for this story to avoid duplicates
        existing = (
            user_db.query(StoryUpdate.article_id)
            .filter(StoryUpdate.story_key == story_key)
            .all()
        )
        existing_ids = {row[0] for row in existing}
        
        # Find matching articles
        for article in recent_articles:
            if article.id in existing_ids:
                continue
            
            # Calculate similarity
            similarity = calculate_similarity(
                story_key,
                article.title,
                article.category or '',
            )
            
            if similarity >= similarity_threshold:
                # Create story update link
                update = StoryUpdate(
                    story_key=story_key,
                    article_id=article.id,
                    update_type='related',
                )
                user_db.add(update)
                updates_added += 1
                
                logger.info(
                    "Linked article %s to story %s (similarity: %.2f)",
                    article.id, story_key, similarity
                )
    
    if updates_added > 0:
        user_db.commit()
        logger.info("Detected %d new story updates", updates_added)
    
    return updates_added


def manually_link_update(
    user_db: Session,
    story_key: str,
    article_id: int,
    update_type: str = 'related',
) -> StoryUpdate:
    """Manually link an article as an update to a story."""
    
    # Check if already linked
    existing = (
        user_db.query(StoryUpdate)
        .filter(
            StoryUpdate.story_key == story_key,
            StoryUpdate.article_id == article_id,
        )
        .first()
    )
    
    if existing:
        return existing
    
    update = StoryUpdate(
        story_key=story_key,
        article_id=article_id,
        update_type=update_type,
    )
    
    user_db.add(update)
    user_db.commit()
    user_db.refresh(update)
    
    logger.info("Manually linked article %s to story %s", article_id, story_key)
    return update

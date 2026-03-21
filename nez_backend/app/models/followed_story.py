from sqlalchemy import Column, Integer, String, DateTime, Boolean
from sqlalchemy.sql import func
from app.core.database import Base


class FollowedStory(Base):
    """Tracks news stories that users are following for updates.
    
    When a user follows a story (e.g., "Law 66 for AI"), they'll receive
    updates about any future articles related to that story.
    """
    __tablename__ = "followed_stories"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, index=True, nullable=False)
    
    # The original article that started the story
    original_article_id = Column(Integer, index=True, nullable=False)
    
    # Story identifier - used to match related articles
    # Could be a category, topic, or specific event identifier
    story_key = Column(String, index=True, nullable=False)
    story_title = Column(String, nullable=False)  # e.g., "Law 66 for AI"
    
    # Track when user last checked for updates
    last_checked_at = Column(DateTime(timezone=True), server_default=func.now())
    
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    
    # Whether the user has muted notifications for this story
    is_muted = Column(Boolean, default=False, nullable=False)


class StoryUpdate(Base):
    """Tracks updates to followed stories.
    
    Links new articles to the original story that users are following.
    """
    __tablename__ = "story_updates"

    id = Column(Integer, primary_key=True, index=True)
    
    # The original story being followed
    story_key = Column(String, index=True, nullable=False)
    
    # The new article that is an update
    article_id = Column(Integer, index=True, nullable=False)
    
    # When this update was detected/added
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    
    # Type of update: "development", "related", "conclusion", etc.
    update_type = Column(String, nullable=True)

from sqlalchemy import Column, Integer, DateTime
from sqlalchemy.sql import func
from app.core.database import Base


class Bookmark(Base):
    __tablename__ = "bookmarks"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, index=True, nullable=False)
    article_id = Column(Integer, index=True, nullable=False)  # references news_articles.id in news DB
    created_at = Column(DateTime(timezone=True), server_default=func.now())

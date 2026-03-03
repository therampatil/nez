from sqlalchemy import Column, Integer, DateTime, ForeignKey
from sqlalchemy.sql import func
from app.core.database import Base


class Bookmark(Base):
    __tablename__ = "bookmarks"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), index=True)
    article_id = Column(Integer, ForeignKey("articles.id"), index=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now())

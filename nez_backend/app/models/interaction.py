from sqlalchemy import Column, Integer, Float, String, DateTime, ForeignKey
from sqlalchemy.sql import func
from app.core.database import Base


class Interaction(Base):
    __tablename__ = "interactions"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), index=True)
    article_id = Column(Integer, ForeignKey("articles.id"), index=True)
    interaction_type = Column(String)  # "view", "like", "share", "read"
    read_time = Column(Float, default=0.0)  # seconds spent reading
    created_at = Column(DateTime(timezone=True), server_default=func.now())

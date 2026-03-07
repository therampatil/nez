from sqlalchemy import Column, Integer, String, Text, DateTime, Boolean, ForeignKey, Index
from sqlalchemy.sql import func
from app.core.database import Base


class Article(Base):
    """Read-only mirror of the shared articles table.

    Articles are ingested and AI-processed by a separate backend.
    This backend only *reads* them to build personalised user feeds.
    """

    __tablename__ = "articles"

    id = Column(Integer, primary_key=True, index=True)
    title = Column(String)
    description = Column(Text)
    content = Column(Text)
    image_url = Column(String)
    source = Column(String)
    published_at = Column(DateTime, index=True)
    category_id = Column(Integer, ForeignKey("categories.id"))
    created_at = Column(DateTime(timezone=True), server_default=func.now())

    # ── Pre-analysed intelligence fields (written by the news backend) ────
    overview = Column(Text, nullable=True)
    in_context = Column(Text, nullable=True)
    why_it_matters = Column(Text, nullable=True)
    category = Column(String(50), nullable=True)

    # ── Processing state (managed by the news backend) ────────────────────
    is_processed = Column(Boolean, default=False, nullable=False)
    is_high_quality = Column(Boolean, nullable=True)
    processed_at = Column(DateTime(timezone=True), nullable=True)

    __table_args__ = (
        Index("ix_articles_published_at_desc", published_at.desc()),
        Index("ix_articles_is_processed", "is_processed"),
    )

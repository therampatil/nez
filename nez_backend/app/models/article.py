from sqlalchemy import Column, Integer, String, Text, DateTime, Boolean, ForeignKey, Index
from sqlalchemy.sql import func
from app.core.database import Base


class Article(Base):
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

    # ── AI-generated intelligence fields ──────────────────────────────────
    overview = Column(Text, nullable=True)           # What happened (plain prose)
    in_context = Column(Text, nullable=True)         # Background / what you should know
    why_it_matters = Column(Text, nullable=True)     # Newline-separated bullet points
    category = Column(String(50), nullable=True)     # AI-assigned topic category

    # ── Processing state ───────────────────────────────────────────────────
    is_processed = Column(Boolean, default=False, nullable=False)  # AI has run
    is_high_quality = Column(Boolean, nullable=True)               # AI quality gate
    processed_at = Column(DateTime(timezone=True), nullable=True)  # When AI ran

    __table_args__ = (
        Index("ix_articles_published_at_desc", published_at.desc()),
        Index("ix_articles_is_processed", "is_processed"),
    )

"""Read-only model for the shared news database.

Maps to the ``news_articles`` table in the separate news Supabase instance.
This backend never writes to this table — it only reads pre-analysed articles.
"""

from sqlalchemy import Column, BigInteger, Text, DateTime
from sqlalchemy.sql import func
from app.core.database import NewsBase


class NewsArticle(NewsBase):
    __tablename__ = "news_articles"

    id = Column(BigInteger, primary_key=True, index=True)
    title = Column(Text, nullable=False)
    url = Column(Text, nullable=False)
    source = Column(Text, nullable=True)
    overview = Column(Text, nullable=True)
    why_this_matters = Column(Text, nullable=True)
    impact = Column(Text, nullable=True)
    category = Column(Text, nullable=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), server_default=func.now())

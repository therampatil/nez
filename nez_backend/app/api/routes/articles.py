"""Article endpoints — read-only from the shared news database."""

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List

from app.api.deps import get_news_db
from app.models.news_article import NewsArticle
from app.schemas.article_schema import NewsArticleResponse

router = APIRouter()


@router.get("/", response_model=List[NewsArticleResponse], response_model_exclude_none=False)
def list_articles(
    skip: int = 0,
    limit: int = 20,
    db: Session = Depends(get_news_db),
):
    """Return paginated articles from the news database."""
    return (
        db.query(NewsArticle)
        .order_by(NewsArticle.created_at.desc())
        .offset(skip)
        .limit(limit)
        .all()
    )


@router.get("/{article_id}", response_model=NewsArticleResponse, response_model_exclude_none=False)
def read_article(article_id: int, db: Session = Depends(get_news_db)):
    """Return a single article by ID."""
    article = db.query(NewsArticle).filter(NewsArticle.id == article_id).first()
    if not article:
        raise HTTPException(status_code=404, detail="Article not found")
    return article

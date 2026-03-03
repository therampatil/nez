from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from app.api.deps import get_db
from app.schemas.article_schema import ArticleCreate, ArticleResponse
from app.repositories.article_repo import create_article, get_articles, get_article_by_id
from typing import List

router = APIRouter()


@router.get("/", response_model=List[ArticleResponse])
def list_articles(skip: int = 0, limit: int = 20, db: Session = Depends(get_db)):
    return get_articles(db, skip=skip, limit=limit)


@router.get("/{article_id}", response_model=ArticleResponse)
def read_article(article_id: int, db: Session = Depends(get_db)):
    article = get_article_by_id(db, article_id)
    if not article:
        from fastapi import HTTPException
        raise HTTPException(status_code=404, detail="Article not found")
    return article


@router.post("/", response_model=ArticleResponse)
def add_article(article: ArticleCreate, db: Session = Depends(get_db)):
    return create_article(db, article)

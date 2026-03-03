from sqlalchemy.orm import Session
from app.models.article import Article
from app.schemas.article_schema import ArticleCreate


def get_articles(db: Session, skip: int = 0, limit: int = 20):
    return db.query(Article).offset(skip).limit(limit).all()


def get_article_by_id(db: Session, article_id: int):
    return db.query(Article).filter(Article.id == article_id).first()


def create_article(db: Session, article: ArticleCreate):
    db_article = Article(**article.model_dump())
    db.add(db_article)
    db.commit()
    db.refresh(db_article)
    return db_article

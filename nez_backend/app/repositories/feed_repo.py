from sqlalchemy.orm import Session
from app.models.article import Article


def get_latest_articles(db: Session, limit: int = 20):
    """Return the latest articles from the shared news database, ordered by recency."""
    return (
        db.query(Article)
        .order_by(Article.published_at.desc())
        .limit(limit)
        .all()
    )

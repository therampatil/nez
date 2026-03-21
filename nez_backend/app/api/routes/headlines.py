"""Headlines endpoints — read-only from the shared news database."""

from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session
from typing import List, Optional

from app.api.deps import get_news_db
from app.models.headline import NewsHeadline
from app.schemas.headline_schema import NewsHeadlineResponse

router = APIRouter()


@router.get("/", response_model=List[NewsHeadlineResponse], response_model_exclude_none=False)
def list_headlines(
    skip: int = Query(0, ge=0),
    limit: int = Query(20, ge=1, le=100),
    category: Optional[str] = Query(None, description="Filter by category"),
    db: Session = Depends(get_news_db),
):
    """Return paginated headlines from the news database.
    
    Args:
        skip: Number of records to skip (for pagination)
        limit: Maximum number of records to return (1-100)
        category: Optional category filter
        db: Database session
    
    Returns:
        List of news headlines ordered by creation date (newest first)
    """
    query = db.query(NewsHeadline)
    
    if category:
        query = query.filter(NewsHeadline.category == category)
    
    return (
        query
        .order_by(NewsHeadline.created_at.desc())
        .offset(skip)
        .limit(limit)
        .all()
    )


@router.get("/latest/", response_model=List[NewsHeadlineResponse], response_model_exclude_none=False)
def get_latest_headlines(
    limit: int = Query(10, ge=1, le=50),
    db: Session = Depends(get_news_db),
):
    """Get the most recent headlines.

    Args:
        limit: Maximum number of headlines to return (1-50)
        db: Database session

    Returns:
        List of most recent headlines
    """
    return (
        db.query(NewsHeadline)
        .order_by(NewsHeadline.created_at.desc())
        .limit(limit)
        .all()
    )


@router.get("/{headline_id}", response_model=NewsHeadlineResponse, response_model_exclude_none=False)
def read_headline(headline_id: int, db: Session = Depends(get_news_db)):
    """Return a single headline by ID.
    
    Args:
        headline_id: The ID of the headline to retrieve
        db: Database session
    
    Returns:
        The requested headline
        
    Raises:
        HTTPException: 404 if headline not found
    """
    headline = db.query(NewsHeadline).filter(NewsHeadline.id == headline_id).first()
    if not headline:
        raise HTTPException(status_code=404, detail="Headline not found")
    return headline

"""Admin/utility routes for story management."""

from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from app.api.deps import get_db, get_news_db
from app.services.story_update_detection_service import detect_story_updates

router = APIRouter()


@router.post("/detect-updates")
def trigger_update_detection(
    hours_lookback: int = 24,
    user_db: Session = Depends(get_db),
    news_db: Session = Depends(get_news_db),
):
    """Manually trigger story update detection.
    
    Scans recent articles and links them to followed stories.
    This would normally run as a background job.
    """
    count = detect_story_updates(
        user_db=user_db,
        news_db=news_db,
        hours_lookback=hours_lookback,
    )
    return {
        "message": f"Detected {count} new story updates",
        "count": count,
    }

"""API routes for following news stories and getting updates."""

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List

from app.api.deps import get_db, get_news_db, get_current_user
from app.models.user import User
from app.schemas.followed_story_schema import (
    FollowStoryCreate,
    FollowStoryResponse,
    FollowedStoryWithUpdates,
    UnfollowStoryRequest,
)
from app.schemas.article_schema import NewsArticleResponse
from app.services.followed_story_service import (
    follow_story,
    unfollow_story,
    get_followed_stories,
    get_followed_news_feed,
    mark_story_checked,
    is_story_followed,
)

router = APIRouter()


@router.post("/", response_model=FollowStoryResponse)
def follow_news_story(
    data: FollowStoryCreate,
    current_user: User = Depends(get_current_user),
    user_db: Session = Depends(get_db),
):
    """Follow a news story to receive future updates."""
    story = follow_story(
        user_db=user_db,
        user_id=current_user.id,
        data=data,
    )
    return story


@router.delete("/{story_id}")
def unfollow_news_story(
    story_id: int,
    current_user: User = Depends(get_current_user),
    user_db: Session = Depends(get_db),
):
    """Unfollow a news story."""
    success = unfollow_story(
        user_db=user_db,
        user_id=current_user.id,
        story_id=story_id,
    )
    
    if not success:
        raise HTTPException(status_code=404, detail="Story not found")
    
    return {"message": "Story unfollowed successfully"}


@router.get("/", response_model=List[FollowedStoryWithUpdates])
def list_followed_stories(
    current_user: User = Depends(get_current_user),
    user_db: Session = Depends(get_db),
    news_db: Session = Depends(get_news_db),
):
    """Get all stories the user is following with update counts."""
    return get_followed_stories(
        user_db=user_db,
        news_db=news_db,
        user_id=current_user.id,
    )


@router.get("/feed", response_model=List[NewsArticleResponse])
def get_followed_updates_feed(
    limit: int = 50,
    current_user: User = Depends(get_current_user),
    user_db: Session = Depends(get_db),
    news_db: Session = Depends(get_news_db),
):
    """Get a feed of all updates to followed stories."""
    return get_followed_news_feed(
        user_db=user_db,
        news_db=news_db,
        user_id=current_user.id,
        limit=limit,
    )


@router.post("/{story_id}/mark-read")
def mark_story_as_checked(
    story_id: int,
    current_user: User = Depends(get_current_user),
    user_db: Session = Depends(get_db),
):
    """Mark a story as checked (resets unread count)."""
    success = mark_story_checked(
        user_db=user_db,
        user_id=current_user.id,
        story_id=story_id,
    )
    
    if not success:
        raise HTTPException(status_code=404, detail="Story not found")
    
    return {"message": "Story marked as checked"}


@router.get("/check/{story_key}")
def check_if_following(
    story_key: str,
    current_user: User = Depends(get_current_user),
    user_db: Session = Depends(get_db),
):
    """Check if user is following a specific story."""
    is_following = is_story_followed(
        user_db=user_db,
        user_id=current_user.id,
        story_key=story_key,
    )
    return {"is_following": is_following}

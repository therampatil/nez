from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from app.api.deps import get_db, get_news_db, get_current_user
from app.models.user import User
from app.schemas.interaction_schema import InteractionCreate, InteractionResponse
from app.services.interaction_service import record_interaction

router = APIRouter()


@router.post("/", response_model=InteractionResponse)
def create_interaction(
    data: InteractionCreate,
    user_db: Session = Depends(get_db),
    news_db: Session = Depends(get_news_db),
    current_user: User = Depends(get_current_user),
):
    """Record a user interaction (view, read, like, share, bookmark).
    Requires a valid Bearer JWT. The user_id is always taken from the JWT —
    any user_id in the request body is ignored for security.
    Updates user preferences for personalised feed ranking.
    """
    # Always use the authenticated user's id — never trust the client's user_id
    data = InteractionCreate(
        user_id=current_user.id,
        article_id=data.article_id,
        interaction_type=data.interaction_type,
        read_time=data.read_time,
    )
    return record_interaction(user_db=user_db, news_db=news_db, data=data)

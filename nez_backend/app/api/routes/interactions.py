from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from app.api.deps import get_db, get_current_user
from app.models.user import User
from app.schemas.interaction_schema import InteractionCreate, InteractionResponse
from app.services.interaction_service import record_interaction

router = APIRouter()


@router.post("/", response_model=InteractionResponse)
def create_interaction(
    data: InteractionCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """Record a user interaction (view, read, like, share, bookmark).
    Requires a valid Bearer JWT. Updates user preferences for personalized feed ranking.
    """
    return record_interaction(db, data)

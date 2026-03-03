from datetime import datetime, timedelta, timezone

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy import func
from sqlalchemy.orm import Session

from app.api.deps import get_db, get_current_user
from app.models.article import Article
from app.models.interaction import Interaction
from app.models.user import User
from app.models.user_preference import UserPreference
from app.schemas.user_schema import (
    UserResponse,
    UpdateProfilePayload,
    PreferencesPayload,
    PreferencesResponse,
    InsightsResponse,
    CategoryStat,
)
from app.core.constants.ranking import CATEGORY_WEIGHT_MAX

router = APIRouter()


@router.get("/me", response_model=UserResponse)
def get_me(current_user: User = Depends(get_current_user)):
    """Return the currently authenticated user's profile."""
    return current_user


@router.patch("/me", response_model=UserResponse)
def update_me(
    payload: UpdateProfilePayload,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """Update the authenticated user's display name (username)."""
    if payload.username is not None:
        current_user.username = payload.username.strip() or None
        db.add(current_user)
        db.commit()
        db.refresh(current_user)
    return current_user


@router.get("/me/preferences", response_model=PreferencesResponse)
def get_preferences(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """Return the authenticated user's explicit category preferences."""
    prefs = (
        db.query(UserPreference)
        .filter(UserPreference.user_id == current_user.id)
        .all()
    )
    return PreferencesResponse(categories=[p.source for p in prefs])


@router.put("/me/preferences", response_model=PreferencesResponse)
def update_preferences(
    payload: PreferencesPayload,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """
    Replace the user's explicit category preferences.
    Each selected category gets a high baseline weight so the feed
    immediately reflects the user's stated interests.
    """
    # Delete all existing explicit preferences for this user
    db.query(UserPreference).filter(
        UserPreference.user_id == current_user.id
    ).delete()

    # Re-insert one row per selected category with a strong baseline weight
    INITIAL_PREFERENCE_WEIGHT = CATEGORY_WEIGHT_MAX * 0.6  # 60 % of max
    for category in payload.categories:
        pref = UserPreference(
            user_id=current_user.id,
            source=category,
            weight=INITIAL_PREFERENCE_WEIGHT,
            interaction_count=0,
        )
        db.add(pref)

    db.commit()
    return PreferencesResponse(categories=payload.categories)


# ── Insights ────────────────────────────────────────────────────────────────

@router.get("/me/insights", response_model=InsightsResponse)
def get_insights(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """Return reading stats for the authenticated user (real data from interactions)."""
    uid = current_user.id
    now = datetime.now(timezone.utc)
    today_start = now.replace(hour=0, minute=0, second=0, microsecond=0)

    # ── All "read" interactions for this user ────────────────
    all_reads = (
        db.query(Interaction)
        .filter(
            Interaction.user_id == uid,
            Interaction.interaction_type.in_(["read", "view"]),
        )
        .all()
    )

    total_articles_read = len(all_reads)
    total_read_seconds = sum(r.read_time or 0.0 for r in all_reads)

    # ── Time-filtered aggregates ─────────────────────────────
    week_start = today_start - timedelta(days=today_start.weekday())  # Monday

    this_week_seconds = sum(
        r.read_time or 0.0
        for r in all_reads
        if r.created_at and r.created_at.replace(tzinfo=timezone.utc) >= week_start
    )
    today_seconds = sum(
        r.read_time or 0.0
        for r in all_reads
        if r.created_at and r.created_at.replace(tzinfo=timezone.utc) >= today_start
    )

    # ── Weekly reads (Mon–Sun counts for the current week) ───
    weekly_reads = [0] * 7
    for r in all_reads:
        if r.created_at:
            ts = r.created_at.replace(tzinfo=timezone.utc)
            if week_start <= ts < week_start + timedelta(days=7):
                day_idx = ts.weekday()  # 0=Mon, 6=Sun
                weekly_reads[day_idx] += 1

    # ── Streak grid — last 35 days (oldest first) ────────────
    streak_grid: list[bool] = []
    for i in range(34, -1, -1):
        day_start = today_start - timedelta(days=i)
        day_end = day_start + timedelta(days=1)
        read_that_day = any(
            r.created_at
            and day_start <= r.created_at.replace(tzinfo=timezone.utc) < day_end
            for r in all_reads
        )
        streak_grid.append(read_that_day)

    # ── Current streak (consecutive days ending today) ───────
    current_streak = 0
    for i in range(34, -1, -1):
        if streak_grid[i]:
            current_streak += 1
        else:
            break

    # ── Longest streak ────────────────────────────────────────
    longest_streak = 0
    run = 0
    for active in streak_grid:
        if active:
            run += 1
            longest_streak = max(longest_streak, run)
        else:
            run = 0

    # ── Category breakdown (join via Article.source as proxy) ─
    cat_rows = (
        db.query(Article.source, func.count(Interaction.id).label("cnt"))
        .join(Article, Article.id == Interaction.article_id)
        .filter(Interaction.user_id == uid)
        .filter(Interaction.interaction_type.in_(["read", "view"]))
        .group_by(Article.source)
        .order_by(func.count(Interaction.id).desc())
        .limit(5)
        .all()
    )
    total_cat = sum(r.cnt for r in cat_rows) or 1
    top_categories = [
        CategoryStat(label=r.source or "Other", count=r.cnt, pct=round(r.cnt / total_cat, 2))
        for r in cat_rows
    ]

    return InsightsResponse(
        total_articles_read=total_articles_read,
        current_streak=current_streak,
        longest_streak=longest_streak,
        total_read_seconds=total_read_seconds,
        this_week_read_seconds=this_week_seconds,
        today_read_seconds=today_seconds,
        weekly_reads=weekly_reads,
        streak_grid=streak_grid,
        top_categories=top_categories,
    )


@router.delete("/me", status_code=status.HTTP_200_OK)
def delete_me(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """Permanently delete the authenticated user's account and all associated data."""
    uid = current_user.id
    # Remove interactions, preferences, then user
    db.query(Interaction).filter(Interaction.user_id == uid).delete()
    db.query(UserPreference).filter(UserPreference.user_id == uid).delete()
    db.delete(current_user)
    db.commit()
    return {"detail": "Account deleted successfully."}

"""Nez user-facing backend.

Handles auth, profiles, preferences, feed ranking, interactions, and insights.
Articles are read from a shared database populated by a separate news backend.
"""

import logging

from fastapi import FastAPI

from app.api.routes import feed, articles, users, interactions, followed_stories, admin, headlines
from app.api.routes import auth
from app.core.database import engine, Base
from app.core.migrations import run_migrations

# Import all user-DB models so Base.metadata knows about them
from app.models import user, interaction, bookmark  # noqa: F401
from app.models import user_preference, followed_story  # noqa: F401

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s  %(levelname)-8s  %(name)s — %(message)s",
)
logger = logging.getLogger(__name__)

# ── DB setup ──────────────────────────────────────────────────────────────────
Base.metadata.create_all(bind=engine)
run_migrations()

# ── FastAPI app ───────────────────────────────────────────────────────────────
app = FastAPI(title="Nez API", version="0.3.0")

app.include_router(feed.router, prefix="/feed", tags=["Feed"])
app.include_router(articles.router, prefix="/articles", tags=["Articles"])
app.include_router(headlines.router, prefix="/headlines", tags=["Headlines"])
app.include_router(users.router, prefix="/users", tags=["Users"])
app.include_router(interactions.router, prefix="/interactions", tags=["Interactions"])
app.include_router(followed_stories.router, prefix="/followed-stories", tags=["Followed Stories"])
app.include_router(admin.router, prefix="/admin", tags=["Admin"])
app.include_router(auth.router, prefix="/auth", tags=["Auth"])


@app.get("/")
def root():
    return {"message": "Nez API is running", "version": "0.3.0"}


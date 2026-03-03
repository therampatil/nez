import logging

from fastapi import FastAPI

from app.api.routes import feed, articles, users, interactions
from app.api.routes import auth
from app.core.database import engine, Base
from app.core.migrations import run_migrations

# Import all models so Base.metadata knows about them
from app.models import user, category, article, interaction, bookmark  # noqa: F401
from app.models import user_preference  # noqa: F401

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
app.include_router(users.router, prefix="/users", tags=["Users"])
app.include_router(interactions.router, prefix="/interactions", tags=["Interactions"])
app.include_router(auth.router, prefix="/auth", tags=["Auth"])


@app.get("/")
def root():
    return {"message": "Nez API is running", "version": "0.3.0"}


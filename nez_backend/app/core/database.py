from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker, declarative_base
from app.core.config import settings

# ── User DB (auth, preferences, interactions, bookmarks) ─────────────────────
engine = create_engine(
    settings.DATABASE_URL,
    pool_pre_ping=True,
)
SessionLocal = sessionmaker(bind=engine, autoflush=False, autocommit=False)

Base = declarative_base()

# ── News DB (pre-analysed articles — read-only) ─────────────────────────────
news_engine = create_engine(
    settings.NEWS_DATABASE_URL,
    pool_pre_ping=True,
)
NewsSessionLocal = sessionmaker(bind=news_engine, autoflush=False, autocommit=False)

NewsBase = declarative_base()

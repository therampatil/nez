"""Run lightweight database column migrations at startup.

Since we use ``Base.metadata.create_all`` (not Alembic), new columns on
existing tables must be added manually via ALTER TABLE.  This module runs
idempotent ``ADD COLUMN IF NOT EXISTS`` statements so the app can safely
be redeployed without a separate migration step.

Called once at application startup from ``app/main.py``.
"""

import logging
from sqlalchemy import text
from app.core.database import engine

logger = logging.getLogger(__name__)


def run_migrations() -> None:
    """Apply any pending column additions to existing tables."""
    migrations = [
        # ── v2: Email verification ─────────────────────────────────────────
        (
            "users",
            "is_email_verified",
            "ALTER TABLE users ADD COLUMN IF NOT EXISTS is_email_verified BOOLEAN NOT NULL DEFAULT FALSE",
        ),
        (
            "users",
            "email_verification_token",
            "ALTER TABLE users ADD COLUMN IF NOT EXISTS email_verification_token VARCHAR UNIQUE",
        ),
        # ── v3: Denormalised article category on interactions ──────────────
        (
            "interactions",
            "article_category",
            "ALTER TABLE interactions ADD COLUMN IF NOT EXISTS article_category VARCHAR",
        ),
        # ── v4: Drop cross-DB FK constraints ──────────────────────────────
        # Articles now live in a separate news DB, so FKs to articles(id)
        # in the user DB are invalid and must be removed.
        (
            "interactions",
            "drop_fk_article_id",
            "ALTER TABLE interactions DROP CONSTRAINT IF EXISTS interactions_article_id_fkey",
        ),
        (
            "bookmarks",
            "drop_fk_article_id",
            "ALTER TABLE bookmarks DROP CONSTRAINT IF EXISTS bookmarks_article_id_fkey",
        ),
        # ── v5: Drop legacy articles/categories tables from user DB ───────
        # These tables are no longer used; articles live in the news DB.
        (
            "articles",
            "drop_table",
            "DROP TABLE IF EXISTS articles CASCADE",
        ),
        (
            "categories",
            "drop_table",
            "DROP TABLE IF EXISTS categories CASCADE",
        ),
    ]

    with engine.connect() as conn:
        for table, column, ddl in migrations:
            try:
                conn.execute(text(ddl))
                conn.commit()
                logger.info("[migration] Applied: %s.%s", table, column)
            except Exception as exc:
                conn.rollback()
                logger.warning(
                    "[migration] Skipped %s.%s: %s", table, column, exc
                )

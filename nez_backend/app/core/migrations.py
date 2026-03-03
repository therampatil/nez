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

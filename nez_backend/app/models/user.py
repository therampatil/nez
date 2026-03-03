from sqlalchemy import Column, Integer, String, DateTime, Boolean
from sqlalchemy.sql import func
from app.core.database import Base


class User(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, index=True)
    email = Column(String, unique=True, index=True, nullable=False)
    hashed_password = Column(String, nullable=False)
    username = Column(String, nullable=True)           # display name, optional
    created_at = Column(DateTime(timezone=True), server_default=func.now())

    # ── Email verification ────────────────────────────────────
    # Google/OAuth users are auto-verified; manual signup users start unverified.
    is_email_verified = Column(Boolean, nullable=False, server_default="false", default=False)
    email_verification_token = Column(String, nullable=True, unique=True, index=True)

"""Pydantic schemas for authentication endpoints."""

from typing import Optional
from pydantic import BaseModel, EmailStr


class UserSignup(BaseModel):
    """Request body for POST /auth/signup."""
    email: EmailStr
    password: str


class UserLogin(BaseModel):
    """Request body for POST /auth/login."""
    email: EmailStr
    password: str


class TokenResponse(BaseModel):
    """Response returned after successful signup or login."""
    access_token: str
    token_type: str = "bearer"


class TokenData(BaseModel):
    """Decoded token payload carried through the request lifecycle."""
    email: Optional[str] = None

"""Authentication routes: signup, login, change-password, change-email, google,
verify-email, resend-verification."""

import secrets
from datetime import datetime, timezone

from fastapi import APIRouter, Depends, HTTPException, Query, status
from fastapi.responses import HTMLResponse
from sqlalchemy.orm import Session
from pydantic import BaseModel, EmailStr
import httpx

from app.api.deps import get_db, get_current_user
from app.core.config import settings
from app.core.security import hash_password, verify_password, create_access_token
from app.models.user import User
from app.schemas.auth_schema import UserSignup, UserLogin, TokenResponse
from app.utils.email import send_verification_email

router = APIRouter()


# ── Payload models ─────────────────────────────────────────────────────────────

class ChangePasswordPayload(BaseModel):
    current_password: str
    new_password: str


class ChangeEmailPayload(BaseModel):
    new_email: EmailStr
    password: str


class GoogleSignInPayload(BaseModel):
    id_token: str
    email: EmailStr
    name: str = ""


class ResendVerificationPayload(BaseModel):
    email: EmailStr


class SignupResponse(BaseModel):
    detail: str
    email: str
    needs_verification: bool = True


# ── Google token verification ──────────────────────────────────────────────────

async def verify_google_token(id_token: str) -> dict:
    """Verify Google ID token using Google's tokeninfo endpoint."""
    try:
        async with httpx.AsyncClient(timeout=10.0) as client:
            response = await client.get(
                "https://oauth2.googleapis.com/tokeninfo",
                params={"id_token": id_token},
            )
    except httpx.HTTPError:
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="Google token verification service unavailable.",
        )

    if response.status_code != 200:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid Google token.",
        )

    token_data = response.json()

    if "error" in token_data or "error_description" in token_data:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail=f"Google token error: {token_data.get('error_description', 'invalid token')}",
        )

    if token_data.get("email_verified") not in (True, "true"):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Google account email is not verified.",
        )

    issuer = token_data.get("iss")
    if issuer not in {"accounts.google.com", "https://accounts.google.com"}:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid Google token issuer.",
        )

    allowed_client_ids = {
        cid.strip()
        for cid in settings.GOOGLE_CLIENT_IDS.split(",")
        if cid.strip()
    }
    if not allowed_client_ids:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Google sign-in is not configured on the server.",
        )

    audience = token_data.get("aud", "")
    if audience not in allowed_client_ids:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Google token audience mismatch.",
        )

    exp_value = token_data.get("exp")
    try:
        exp_ts = int(exp_value)
    except (TypeError, ValueError):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid Google token expiry.",
        )

    if exp_ts <= int(datetime.now(timezone.utc).timestamp()):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Google token has expired.",
        )

    return token_data


# ── Signup ─────────────────────────────────────────────────────────────────────

@router.post(
    "/signup",
    response_model=SignupResponse,
    status_code=status.HTTP_201_CREATED,
)
def signup(payload: UserSignup, db: Session = Depends(get_db)):
    """Register a new user and send a verification email.

    Returns 201 with ``needs_verification: true``.  The user cannot log in
    until they click the verification link sent to their inbox.

    Raises:
        400: If the email is already registered.
    """
    existing = db.query(User).filter(User.email == payload.email).first()
    if existing:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Email already registered.",
        )

    verification_token = secrets.token_urlsafe(32)

    user = User(
        email=payload.email,
        hashed_password=hash_password(payload.password),
        is_email_verified=False,
        email_verification_token=verification_token,
    )
    db.add(user)
    db.commit()
    db.refresh(user)

    # Send verification email (failure is logged, not raised).
    send_verification_email(to_email=payload.email, token=verification_token)

    return SignupResponse(
        detail=(
            "Account created! Please check your inbox and verify your email "
            "before logging in."
        ),
        email=payload.email,
        needs_verification=True,
    )


# ── Email verification ─────────────────────────────────────────────────────────

@router.get("/verify-email", response_class=HTMLResponse)
def verify_email(token: str = Query(...), db: Session = Depends(get_db)):
    """Verify a user's email using the one-time token from their inbox.

    Returns a styled HTML page — this endpoint is opened in a browser from
    the verification email link.
    """
    user = (
        db.query(User)
        .filter(User.email_verification_token == token)
        .first()
    )
    if not user:
        return HTMLResponse(
            content=_html_page(
                success=False,
                title="Link expired or invalid",
                message=(
                    "This verification link is invalid or has already been used. "
                    "Please request a new one from the Nez app."
                ),
            ),
            status_code=400,
        )

    user.is_email_verified = True
    user.email_verification_token = None  # one-time use
    db.add(user)
    db.commit()

    return HTMLResponse(
        content=_html_page(
            success=True,
            title="Email verified!",
            message=(
                "Your Nez account is now active. "
                "Go back to the app and log in."
            ),
        ),
        status_code=200,
    )


def _html_page(*, success: bool, title: str, message: str) -> str:
    icon = "✓" if success else "✕"
    icon_color = "#2E7D32" if success else "#C62828"
    border_color = "#2E7D32" if success else "#C62828"
    return f"""<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8"/>
  <meta name="viewport" content="width=device-width,initial-scale=1"/>
  <title>{title} — Nez</title>
  <style>
    *{{box-sizing:border-box;margin:0;padding:0}}
    body{{background:#f5f5f5;font-family:sans-serif;display:flex;
         align-items:center;justify-content:center;min-height:100vh;padding:24px}}
    .card{{background:#fff;border:1.5px solid #e5e5e5;
           box-shadow:4px 4px 0 #000;padding:48px 40px;max-width:440px;
           width:100%;text-align:center}}
    .logo{{font-size:28px;font-weight:900;letter-spacing:-1px;
           color:#111;margin-bottom:32px}}
    .icon{{width:64px;height:64px;border-radius:50%;
           border:2px solid {border_color};display:flex;align-items:center;
           justify-content:center;margin:0 auto 24px;
           font-size:28px;color:{icon_color}}}
    h1{{font-size:22px;font-weight:700;color:#111;margin-bottom:12px}}
    p{{font-size:15px;color:#555;line-height:1.6}}
  </style>
</head>
<body>
  <div class="card">
    <div class="logo">NEZ</div>
    <div class="icon">{icon}</div>
    <h1>{title}</h1>
    <p>{message}</p>
  </div>
</body>
</html>"""


# ── Resend verification email ──────────────────────────────────────────────────

@router.post("/resend-verification", status_code=status.HTTP_200_OK)
def resend_verification(
    payload: ResendVerificationPayload, db: Session = Depends(get_db)
):
    """Re-send a verification email for accounts that haven't verified yet.

    Always returns 200 to prevent email enumeration.
    """
    user = db.query(User).filter(User.email == payload.email).first()

    if user and not user.is_email_verified:
        new_token = secrets.token_urlsafe(32)
        user.email_verification_token = new_token
        db.add(user)
        db.commit()
        send_verification_email(to_email=user.email, token=new_token)

    return {
        "detail": (
            "If that email is registered and unverified, "
            "a new verification link has been sent."
        )
    }


# ── Login ──────────────────────────────────────────────────────────────────────

@router.post("/login", response_model=TokenResponse)
def login(payload: UserLogin, db: Session = Depends(get_db)):
    """Authenticate an existing user and return a JWT access token.

    Raises:
        401: If credentials are invalid.
        403: If the email has not been verified yet.
    """
    user = db.query(User).filter(User.email == payload.email).first()
    if not user or not verify_password(payload.password, user.hashed_password):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid email or password.",
            headers={"WWW-Authenticate": "Bearer"},
        )

    if not user.is_email_verified:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Please verify your email before logging in.",
        )

    token = create_access_token(subject=user.email)
    return TokenResponse(access_token=token)


# ── Change password ────────────────────────────────────────────────────────────

@router.post("/change-password", status_code=status.HTTP_200_OK)
def change_password(
    payload: ChangePasswordPayload,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """Change the authenticated user's password."""
    if not verify_password(payload.current_password, current_user.hashed_password):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Current password is incorrect.",
        )
    if len(payload.new_password) < 6:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="New password must be at least 6 characters.",
        )
    current_user.hashed_password = hash_password(payload.new_password)
    db.add(current_user)
    db.commit()
    return {"detail": "Password changed successfully."}


# ── Change email ───────────────────────────────────────────────────────────────

@router.post("/change-email", status_code=status.HTTP_200_OK)
def change_email(
    payload: ChangeEmailPayload,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """Change the authenticated user's email address."""
    if not verify_password(payload.password, current_user.hashed_password):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Password is incorrect.",
        )
    existing = db.query(User).filter(User.email == payload.new_email).first()
    if existing and existing.id != current_user.id:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Email already in use.",
        )
    current_user.email = payload.new_email
    db.add(current_user)
    db.commit()
    db.refresh(current_user)
    return {"detail": "Email updated successfully.", "email": current_user.email}


# ── Google Sign-In ─────────────────────────────────────────────────────────────

@router.post("/google", response_model=TokenResponse, status_code=status.HTTP_200_OK)
async def google_sign_in(payload: GoogleSignInPayload, db: Session = Depends(get_db)):
    """Sign in or sign up with a Google ID token.

    Google accounts are pre-verified — no email verification step needed.
    """
    token_data = await verify_google_token(payload.id_token)

    email = token_data.get("email", "").lower().strip()
    payload_email = payload.email.lower().strip()
    if payload_email and payload_email != email:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Google account email mismatch.",
        )

    name = token_data.get("name", "") or payload.name or email.split("@")[0]

    if not email:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="No email returned from Google.",
        )

    user = db.query(User).filter(User.email == email).first()

    if not user:
        user = User(
            email=email,
            username=name,
            hashed_password=hash_password(f"google_oauth_{token_data.get('sub', '')}"),
            is_email_verified=True,  # Google already verified the email
        )
        db.add(user)
        db.commit()
        db.refresh(user)
    elif not user.is_email_verified:
        # Edge case: manual user is now signing in with Google on same email.
        user.is_email_verified = True
        user.email_verification_token = None
        db.add(user)
        db.commit()

    token = create_access_token(subject=user.email)
    return TokenResponse(access_token=token)

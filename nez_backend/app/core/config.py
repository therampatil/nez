from pydantic_settings import BaseSettings


class Settings(BaseSettings):
    DATABASE_URL: str
    SECRET_KEY: str
    ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 60

    # ── Email — Option A: Resend (recommended) ─────────────────────────────
    # Sign up at https://resend.com — free tier: 3 000 emails/month.
    RESEND_API_KEY: str = ""
    RESEND_FROM: str = "Nez <noreply@mail.getnez.app>"

    # ── Email — Option B: SMTP (Gmail App Password, SendGrid, etc.) ────────
    # Leave blank to fall back to logging the verify URL in dev mode.
    SMTP_HOST: str = ""
    SMTP_PORT: int = 587
    SMTP_USER: str = ""
    SMTP_PASSWORD: str = ""

    # Public-facing base URL of this backend (used in email links).
    APP_BASE_URL: str = "http://localhost:8000"

    class Config:
        env_file = ".env"


settings = Settings()

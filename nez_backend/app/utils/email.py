"""Email sending utility for Nez backend.

Sends transactional emails (e.g. verification) via Resend API or SMTP.
Priority: Resend (if RESEND_API_KEY is set) -> SMTP -> dev-log fallback.

Environment variables:

  # Option A -- Resend (recommended, free tier: 3 000 emails/month)
  RESEND_API_KEY    -- Resend API key (re_xxxxxxxxx)
  RESEND_FROM       -- Sender address (must be from a verified domain)
                       e.g. "Nez <noreply@yourdomain.com>"

  # Option B -- SMTP (Gmail App Password, SendGrid, etc.)
  SMTP_HOST         -- SMTP server hostname  (e.g. smtp.gmail.com)
  SMTP_PORT         -- SMTP port             (default 587 for STARTTLS)
  SMTP_USER         -- Login username / sender address
  SMTP_PASSWORD     -- Login password or app password

  # Shared
  APP_BASE_URL      -- Public URL of the Nez backend, used to build verify link
                       e.g. https://nez-production.up.railway.app
"""

import logging
import os
import smtplib
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText

logger = logging.getLogger(__name__)

# -- Resend config --------------------------------------------------------------
RESEND_API_KEY: str = os.getenv("RESEND_API_KEY", "")
RESEND_FROM: str = os.getenv("RESEND_FROM", "Nez <noreply@getnez.app>")

# -- SMTP config ---------------------------------------------------------------
SMTP_HOST: str = os.getenv("SMTP_HOST", "")
SMTP_PORT: int = int(os.getenv("SMTP_PORT", "587"))
SMTP_USER: str = os.getenv("SMTP_USER", "")
SMTP_PASSWORD: str = os.getenv("SMTP_PASSWORD", "")

# Base URL used to construct verification links.
APP_BASE_URL: str = os.getenv(
    "APP_BASE_URL", "http://localhost:8000"
).rstrip("/")


# -- Provider detection --------------------------------------------------------

def _resend_configured() -> bool:
    return bool(RESEND_API_KEY)


def _smtp_configured() -> bool:
    return bool(SMTP_HOST and SMTP_USER and SMTP_PASSWORD)


# -- Public API ----------------------------------------------------------------

def send_verification_email(to_email: str, token: str) -> None:
    """Send an account-verification email with the one-time magic link.

    The link hits ``GET /auth/verify-email?token=<token>`` on the backend,
    which marks the account as verified.

    A failed send is logged but never propagated -- the user can request a
    resend via ``POST /auth/resend-verification``.
    """
    verify_url = f"{APP_BASE_URL}/auth/verify-email?token={token}"

    if _resend_configured():
        _send_via_resend(to_email, verify_url)
        return

    if _smtp_configured():
        _send_via_smtp(to_email, verify_url)
        return

    # Dev fallback -- log the raw link so developers can test without email.
    logger.warning(
        "[email] No email provider configured -- skipping send. "
        "Verify manually: GET %s",
        verify_url,
    )


# -- Resend API ----------------------------------------------------------------

def _send_via_resend(to_email: str, verify_url: str) -> None:
    """POST to https://api.resend.com/emails using the Resend REST API."""
    try:
        import httpx  # already in requirements.txt

        plain_body, html_body = _build_bodies(verify_url)
        resp = httpx.post(
            "https://api.resend.com/emails",
            headers={"Authorization": f"Bearer {RESEND_API_KEY}"},
            json={
                "from": RESEND_FROM,
                "to": [to_email],
                "subject": "Verify your Nez account",
                "text": plain_body,
                "html": html_body,
            },
            timeout=10,
        )
        if resp.status_code not in (200, 201):
            logger.error(
                "[email] Resend API error %s: %s", resp.status_code, resp.text
            )
        else:
            logger.info("[email] Verification email sent via Resend to %s", to_email)
    except Exception as exc:
        logger.error("[email] Resend send failed: %s", exc)


# -- SMTP ----------------------------------------------------------------------

def _send_via_smtp(to_email: str, verify_url: str) -> None:
    """Send via STARTTLS SMTP (Gmail App Password, SendGrid, etc.)."""
    plain_body, html_body = _build_bodies(verify_url)

    msg = MIMEMultipart("alternative")
    msg["Subject"] = "Verify your Nez account"
    msg["From"] = f"Nez <{SMTP_USER}>"
    msg["To"] = to_email
    msg.attach(MIMEText(plain_body, "plain"))
    msg.attach(MIMEText(html_body, "html"))

    try:
        with smtplib.SMTP(SMTP_HOST, SMTP_PORT) as server:
            server.ehlo()
            server.starttls()
            server.login(SMTP_USER, SMTP_PASSWORD)
            server.sendmail(SMTP_USER, to_email, msg.as_string())
        logger.info("[email] Verification email sent via SMTP to %s", to_email)
    except Exception as exc:
        logger.error("[email] SMTP send failed: %s", exc)


# -- Email body builder --------------------------------------------------------

def _build_bodies(verify_url: str) -> tuple:
    """Return (plain_text, html) tuple for the verification email."""
    plain = (
        "Welcome to Nez!\n\n"
        "Click the link below to verify your email address:\n"
        f"{verify_url}\n\n"
        "This link expires in 24 hours.\n\n"
        "If you didn't create a Nez account, you can safely ignore this email."
    )

    html = (
        "<!DOCTYPE html>"
        '<html lang="en">'
        "<head>"
        '<meta charset="UTF-8" />'
        '<meta name="viewport" content="width=device-width, initial-scale=1.0"/>'
        "<title>Verify your Nez account</title>"
        "</head>"
        '<body style="margin:0;padding:0;background:#f5f5f5;font-family:sans-serif;">'
        '<table width="100%" cellpadding="0" cellspacing="0" style="background:#f5f5f5;padding:40px 0;">'
        "<tr><td align=\"center\">"
        '<table width="480" cellpadding="0" cellspacing="0" style="background:#ffffff;border:1.5px solid #e5e5e5;box-shadow:4px 4px 0 #000;padding:40px;">'
        "<tr><td align=\"center\" style=\"padding-bottom:24px;\">"
        '<span style="font-size:28px;font-weight:900;letter-spacing:-1px;color:#111111;">NEZ</span>'
        "</td></tr>"
        "<tr><td style=\"color:#111111;font-size:22px;font-weight:700;padding-bottom:12px;\">Verify your email</td></tr>"
        "<tr><td style=\"color:#555555;font-size:15px;line-height:1.6;padding-bottom:28px;\">Thanks for signing up! Click the button below to confirm your email address and activate your account.</td></tr>"
        "<tr><td align=\"center\" style=\"padding-bottom:28px;\">"
        f'<a href="{verify_url}" style="display:inline-block;background:#111111;color:#ffffff;font-size:15px;font-weight:700;text-decoration:none;padding:14px 32px;border:1.5px solid #000;box-shadow:4px 4px 0 #555;">Verify Email</a>'
        "</td></tr>"
        "<tr><td style=\"color:#888888;font-size:12px;line-height:1.6;padding-bottom:8px;\">Or copy and paste this link in your browser:<br/>"
        f'<a href="{verify_url}" style="color:#555555;word-break:break-all;">{verify_url}</a>'
        "</td></tr>"
        "<tr><td style=\"color:#aaaaaa;font-size:11px;padding-top:24px;border-top:1px solid #eeeeee;\">This link expires in 24 hours. If you didn't sign up for Nez, you can safely ignore this email.</td></tr>"
        "</table></td></tr></table>"
        "</body></html>"
    )

    return plain, html

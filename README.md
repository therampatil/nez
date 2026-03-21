# Nez — News Intelligence App

Nez is a mobile-first news app that delivers personalised, pre-analysed news in a clean, minimal UI.  
Users swipe through a ranked feed, tap _See the Impact_ to get a three-panel deep-dive (What Happened · In Context · Why It Matters), and build a reading habit tracked by streak and insight stats.

> Articles are fetched from a shared database populated by a separate news backend.  
> This repo handles the **user-facing system** — auth, profiles, preferences, feed ranking, interactions, and insights.

---

## Monorepo Structure

```
Nez/
├── nez_app/          # Flutter (Android / iOS) — the user-facing app
└── nez_backend/      # FastAPI — REST API, auth, feed ranking, user preferences
```

---

## nez_app — Flutter

| Tech         | Version                |
| ------------ | ---------------------- |
| Flutter      | ≥ 3.x                  |
| Dart         | ≥ 3.11                 |
| State        | Riverpod 2             |
| Routing      | GoRouter 14            |
| HTTP         | Dio 5                  |
| Auth storage | flutter_secure_storage |

### Key Features

- **Welcome → Login / Signup → Email Verification → Preferences → Home** onboarding flow
- Personalised article feed (JWT-authenticated, ranked by recency + user preferences)
- **Follow News** - Track specific news stories and get updates automatically
- "See the Impact" three-panel deep-dive per article
- Bookmarks, search, notifications, reading insights & streak grid
- Google Sign-In (Android + iOS)
- Side drawer: Profile, Insights, Settings, Help, About

### Running Locally

```bash
cd nez_app
flutter pub get
flutter run
```

The app points to the live Railway backend by default (`api_client.dart → _baseUrl`).  
To use a local backend, change `_baseUrl` to `http://10.0.2.2:8000` (Android emulator) or `http://localhost:8000` (iOS / macOS).

---

## nez_backend — FastAPI

| Tech      | Details                                                    |
| --------- | ---------------------------------------------------------- |
| Framework | FastAPI 0.115+                                             |
| DB        | PostgreSQL (SQLAlchemy 2, no Alembic — startup migrations) |
| Auth      | JWT (python-jose) + bcrypt passwords                       |
| Email     | Resend API (fallback: SMTP)                                |
| Deploy    | Railway (`Procfile` + `railway.toml`)                      |

### Architecture Note

This backend **does not** ingest or process news.  
Articles arrive pre-analysed (with overview, context, and impact) in a **separate Supabase database** (the "news DB"), populated by a separate news pipeline.  
This backend connects to **two databases**:

1. **User DB** — auth, profiles, preferences, interactions, bookmarks, insights.
2. **News DB** — pre-analysed articles (read-only).

Cross-database foreign keys are not used; article IDs are stored as plain integers in the user DB, and `article_category` is denormalised on the interactions table for efficient insights queries.

### API Endpoints

| Method   | Path                                    | Auth | Description                      |
| -------- | --------------------------------------- | ---- | -------------------------------- |
| `GET`    | `/`                                     | —    | Health check                     |
| `POST`   | `/auth/signup`                          | —    | Register new user                |
| `POST`   | `/auth/login`                           | —    | Login, returns JWT               |
| `GET`    | `/auth/verify-email`                    | —    | Verify email via token link      |
| `POST`   | `/auth/resend-verification`             | —    | Resend verification email        |
| `POST`   | `/auth/google`                          | —    | Google Sign-In                   |
| `POST`   | `/auth/change-password`                 | JWT  | Change password                  |
| `POST`   | `/auth/change-email`                    | JWT  | Change email                     |
| `GET`    | `/users/me`                             | JWT  | Get profile                      |
| `PATCH`  | `/users/me`                             | JWT  | Update display name              |
| `GET`    | `/users/me/preferences`                 | JWT  | Get category preferences         |
| `PUT`    | `/users/me/preferences`                 | JWT  | Save category preferences        |
| `GET`    | `/users/me/insights`                    | JWT  | Reading stats & streak           |
| `DELETE` | `/users/me`                             | JWT  | Delete account                   |
| `GET`    | `/feed/`                                | JWT  | Personalised news feed           |
| `GET`    | `/articles/`                            | —    | List articles (paginated)        |
| `GET`    | `/articles/{id}`                        | —    | Get single article               |
| `POST`   | `/interactions/`                        | JWT  | Record user interaction          |
| `POST`   | `/followed-stories/`                    | JWT  | Follow a news story              |
| `DELETE` | `/followed-stories/{story_id}`          | JWT  | Unfollow a story                 |
| `GET`    | `/followed-stories/`                    | JWT  | List followed stories + updates  |
| `GET`    | `/followed-stories/feed`                | JWT  | Feed of followed story updates   |
| `POST`   | `/followed-stories/{story_id}/mark-read`| JWT  | Mark story as checked            |
| `GET`    | `/followed-stories/check/{story_key}`   | JWT  | Check if following a story       |
| `POST`   | `/admin/detect-updates`                 | —    | Trigger story update detection   |

### Running Locally

```bash
cd nez_backend
python -m venv venv
source venv/bin/activate
pip install -r requirements.txt

cp .env.example .env   # fill in DATABASE_URL, SECRET_KEY, etc.
uvicorn app.main:app --reload --port 8000
```

### Environment Variables

| Variable                       | Required | Description                                       |
| ------------------------------ | -------- | ------------------------------------------------- |
| `DATABASE_URL`                 | ✓        | PostgreSQL connection string (user DB)            |
| `NEWS_DATABASE_URL`            | ✓        | PostgreSQL connection string (news DB, read-only) |
| `SECRET_KEY`                   | ✓        | JWT signing secret                                |
| `ALGORITHM`                    | —        | Default: `HS256`                                  |
| `ACCESS_TOKEN_EXPIRE_MINUTES`  | —        | Default: `60`                                     |
| `RESEND_API_KEY`               | —        | Resend email API key                              |
| `RESEND_FROM`                  | —        | Sender address                                    |
| `SMTP_HOST/PORT/USER/PASSWORD` | —        | SMTP fallback                                     |
| `APP_BASE_URL`                 | —        | Used in verification email links                  |

See `nez_backend/.env.example` for the full template.

### Deployment

Deployed on **Railway** at `https://nez-backend-production.up.railway.app`.  
Set all env vars from `.env.example` in the Railway dashboard.

---

## Auth Flow

```
Welcome (splash)
    ↓ auto-navigate
Login ─────────────────────────────────────────→ Home
    │
    └─ Sign Up → Email Verification → auto-login → Preferences → Home
```

- **Login** always goes directly to Home (no preferences step).
- **Sign Up** stores credentials temporarily; after the user clicks the email link and taps _"I've verified — Continue"_, the app auto-logs in and redirects to Preferences (first-time only).
- **Google Sign-In** skips email verification and goes directly to Home.

---

## License

Private — all rights reserved.

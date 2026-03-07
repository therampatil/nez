# Nez — News Intelligence App

Nez is a mobile-first news app that delivers personalised, AI-processed news in a clean, minimal UI.  
Users swipe through a ranked feed, tap _See the Impact_ to get a three-panel deep-dive (What Happened · In Context · Why It Matters), and build a reading habit tracked by streak and insight stats.

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

### Key features

- **Welcome → Login / Signup → Email verification → Preferences → Home** onboarding flow
- Personalised article feed (JWT-authenticated, ranked by recency + user preferences)
- "See the Impact" three-panel deep-dive per article
- Bookmarks, search, notifications, reading insights & streak grid
- Google Sign-In (Android + iOS)
- Side drawer: Profile, Insights, Settings, Help, About

### Running locally

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

### Endpoints

| Method | Path                        | Auth | Description                        |
| ------ | --------------------------- | ---- | ---------------------------------- |
| POST   | `/auth/signup`              | —    | Register, sends verification email |
| POST   | `/auth/login`               | —    | Returns JWT                        |
| GET    | `/auth/verify-email`        | —    | One-time email verification link   |
| POST   | `/auth/resend-verification` | —    | Re-send verification email         |
| POST   | `/auth/google`              | —    | Google Sign-In / Sign-Up           |
| POST   | `/auth/change-password`     | ✓    | Change password                    |
| POST   | `/auth/change-email`        | ✓    | Change email                       |
| GET    | `/users/me`                 | ✓    | Current user profile               |
| PATCH  | `/users/me`                 | ✓    | Update display name                |
| DELETE | `/users/me`                 | ✓    | Delete account                     |
| GET    | `/users/me/preferences`     | ✓    | User category preferences          |
| PUT    | `/users/me/preferences`     | ✓    | Replace preferences                |
| GET    | `/users/me/insights`        | ✓    | Reading stats & streak             |
| GET    | `/feed/`                    | ✓    | Personalised article feed          |
| GET    | `/articles/`                | —    | Paginated article list             |
| GET    | `/articles/{id}`            | —    | Single article                     |
| POST   | `/interactions/`            | ✓    | Record user interaction            |

### Running locally

```bash
cd nez_backend
python -m venv venv
source venv/bin/activate
pip install -r requirements.txt
cp .env.example .env   # fill in DATABASE_URL, SECRET_KEY, etc.
uvicorn app.main:app --reload --port 8000
```

### Environment variables

| Variable                       | Required | Description                      |
| ------------------------------ | -------- | -------------------------------- |
| `DATABASE_URL`                 | ✓        | PostgreSQL connection string     |
| `SECRET_KEY`                   | ✓        | JWT signing secret               |
| `ALGORITHM`                    | —        | Default: `HS256`                 |
| `ACCESS_TOKEN_EXPIRE_MINUTES`  | —        | Default: `60`                    |
| `RESEND_API_KEY`               | —        | Resend email API key             |
| `RESEND_FROM`                  | —        | Sender address                   |
| `SMTP_HOST/PORT/USER/PASSWORD` | —        | SMTP fallback                    |
| `APP_BASE_URL`                 | —        | Used in verification email links |

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
- **Sign Up** stores credentials temporarily; after the user clicks the email link and taps _"I've verified — Continue"_, the app auto-logs in and redirects to the Preferences screen (first-time only).
- **Google Sign-In** skips email verification and goes directly to Home.

---

## Deployment

The backend is deployed on [Railway](https://railway.app).  
Live URL: `https://nez-backend-production.up.railway.app` — News Intelligence App

> News that matters, impact you can see.

Nez is a full-stack mobile news application built with **Flutter** (frontend) and **FastAPI** (backend). It delivers a clean, card-based news feed with AI-powered impact breakdowns so users understand not just _what_ happened, but _why it matters_.

---

## Project Structure

```
nez/
├── nez_app/        # Flutter mobile app (iOS & Android)
└── nez_backend/    # FastAPI REST API (deployed on Railway)
```

---

## nez_backend — FastAPI

### Tech Stack

- **FastAPI** — REST API framework
- **PostgreSQL** — primary database (via Railway)
- **SQLAlchemy** — ORM
- **Passlib / python-jose** — password hashing & JWT auth
- **Resend / SMTP** — transactional email (verification)
- **Gunicorn + Uvicorn** — production ASGI server

### API Endpoints

| Method   | Path                        | Auth | Description                 |
| -------- | --------------------------- | ---- | --------------------------- |
| `GET`    | `/`                         | —    | Health check                |
| `POST`   | `/auth/signup`              | —    | Register new user           |
| `POST`   | `/auth/login`               | —    | Login, returns JWT          |
| `GET`    | `/auth/verify-email`        | —    | Verify email via token link |
| `POST`   | `/auth/resend-verification` | —    | Resend verification email   |
| `POST`   | `/auth/google`              | —    | Google Sign-In              |
| `POST`   | `/auth/change-password`     | JWT  | Change password             |
| `POST`   | `/auth/change-email`        | JWT  | Change email                |
| `GET`    | `/users/me`                 | JWT  | Get profile                 |
| `PATCH`  | `/users/me`                 | JWT  | Update display name         |
| `GET`    | `/users/me/preferences`     | JWT  | Get category preferences    |
| `PUT`    | `/users/me/preferences`     | JWT  | Save category preferences   |
| `GET`    | `/users/me/insights`        | JWT  | Reading stats               |
| `DELETE` | `/users/me`                 | JWT  | Delete account              |
| `GET`    | `/feed/`                    | JWT  | Personalized news feed      |
| `GET`    | `/articles/`                | —    | List all articles           |
| `GET`    | `/articles/{id}`            | —    | Get single article          |
| `POST`   | `/interactions/`            | JWT  | Record a user interaction   |

### Local Setup

```bash
cd nez_backend
python -m venv venv
source venv/bin/activate
pip install -r requirements.txt

cp .env.example .env
# Fill in your DATABASE_URL, SECRET_KEY, etc.

uvicorn app.main:app --reload --port 8000
```

### Deployment

Deployed on **Railway**. Set all environment variables from `.env.example` in the Railway dashboard.

---

## nez_app — Flutter

### Tech Stack

- **Flutter 3.x** — cross-platform mobile (iOS & Android)
- **Riverpod** — state management
- **GoRouter** — declarative routing
- **Dio** — HTTP client with JWT interceptor
- **Flutter Secure Storage** — encrypted token storage
- **Google Sign-In** — OAuth authentication
- **Firebase** — platform services

### Auth Flow

```
Welcome (splash)
    ↓
Login Screen ──────────────────────→ Home
    └── Sign Up → Verify Email → Preferences → Home
```

### Running Locally

```bash
cd nez_app
flutter pub get
flutter run
```

---

## Environment Variables

See `nez_backend/.env.example` for all required backend variables.

---

## License

Private — all rights reserved.

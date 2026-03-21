# Followed News Feature

## Overview
The "Followed News" feature allows users to follow specific news stories and receive updates when new developments occur. For example, if a user follows news about "Law 66 for AI", they'll automatically see any future articles related to that story in their Following feed.

## Architecture

### Backend Components

#### 1. Database Models (`app/models/followed_story.py`)

**FollowedStory**
- Tracks which news stories users are following
- Links to the original article that started the story
- Stores a `story_key` for matching related articles
- Tracks `last_checked_at` to determine unread updates

**StoryUpdate**
- Links new articles to existing followed stories
- Created either manually or automatically via update detection
- Stores the `update_type` for categorization

#### 2. API Endpoints (`app/api/routes/followed_stories.py`)

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/followed-stories/` | POST | Follow a news story |
| `/followed-stories/{story_id}` | DELETE | Unfollow a story |
| `/followed-stories/` | GET | List all followed stories with update counts |
| `/followed-stories/feed` | GET | Get feed of all updates to followed stories |
| `/followed-stories/{story_id}/mark-read` | POST | Mark a story as checked (resets unread count) |
| `/followed-stories/check/{story_key}` | GET | Check if user is following a specific story |

#### 3. Services

**`followed_story_service.py`**
- Core business logic for following/unfollowing
- Fetches followed stories with update counts
- Generates feed of story updates

**`story_update_detection_service.py`**
- Automatically detects new articles related to followed stories
- Uses keyword matching and category similarity
- Can be triggered manually or run as a background job

### Frontend Components

#### 1. Providers (`lib/core/providers/followed_stories_provider.dart`)

- `followStoryProvider` - Service for follow/unfollow actions
- `followedStoriesProvider` - List of stories user is following
- `followedNewsFeedProvider` - Feed of updates to followed stories
- `followedNewsUnreadCountProvider` - Total unread update count

#### 2. UI Screens

**Impact Screen** (`lib/features/impact/presentation/impact_screen.dart`)
- Shows "Follow News" button (changes to "Following" when active)
- Checks if story is already followed on load
- Handles follow/unfollow with user feedback

**Followed News Screen** (`lib/features/followed_news/presentation/followed_news_screen.dart`)
- Shows all updates to followed stories
- Displays "NEW UPDATE" badges for recent articles
- Shows update count (e.g., "update 2 of 5")
- Displays unread count in header badge

**Bottom Navigation** (`lib/shared/widgets/nez_bottom_nav.dart`)
- Shows unread badge on Followed News tab (index 2)
- Badge appears when there are new updates

## How It Works

### Following a Story

1. User views an article and taps "Follow News" button
2. Frontend generates a `story_key` from article category + title keywords
3. API creates a `FollowedStory` record with the story details
4. Button changes to "Following" state

### Detecting Updates

1. Background service scans new articles (last 24 hours)
2. For each followed story, calculates similarity to new articles
3. If similarity > threshold (0.4), creates a `StoryUpdate` link
4. Update appears in user's Following feed

### Viewing Updates

1. User opens Following tab
2. Feed shows all articles linked as updates to their followed stories
3. "NEW UPDATE" badge shows for articles < 6 hours old
4. Unread count shows total updates since last check

## Story Key Generation

Story keys are generated to group related articles:

```dart
// Example: "Law 66 for AI" article in "Laws" category
// becomes: "laws-enforcement-technical-impossible"

category + relevant_title_keywords
```

## Future Enhancements

1. **Smart Grouping**: Use NLP/embeddings for better article matching
2. **Notification Push**: Send push notifications for major updates
3. **Story Threads**: Visual timeline showing story progression
4. **Custom Story Keys**: Let users name and organize followed stories
5. **Scheduled Digests**: Daily/weekly email summaries of followed story updates
6. **Story Completion**: Mark stories as "concluded" when no longer relevant

## Testing

### Backend
```bash
# Start the backend
cd nez_backend
python3 -m uvicorn app.main:app --reload

# Test following a story
curl -X POST http://localhost:8000/followed-stories/ \
  -H "Authorization: Bearer <token>" \
  -H "Content-Type: application/json" \
  -d '{"article_id": 1, "story_key": "laws-ai-regulation", "story_title": "AI Laws"}'

# Trigger update detection
curl -X POST http://localhost:8000/admin/detect-updates

# Get followed feed
curl http://localhost:8000/followed-stories/feed \
  -H "Authorization: Bearer <token>"
```

### Frontend
```bash
cd nez_app
flutter run
```

1. Navigate to any article
2. Tap "Follow News" button - should turn green and say "Following"
3. Go to Following tab (bookmark icon in bottom nav)
4. Should see a badge if there are updates
5. Feed should show articles related to followed stories

## Database Schema

```sql
-- Followed stories table
CREATE TABLE followed_stories (
    id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL,
    original_article_id INTEGER NOT NULL,
    story_key VARCHAR NOT NULL,
    story_title VARCHAR NOT NULL,
    last_checked_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    is_muted BOOLEAN DEFAULT FALSE
);

-- Story updates table
CREATE TABLE story_updates (
    id SERIAL PRIMARY KEY,
    story_key VARCHAR NOT NULL,
    article_id INTEGER NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    update_type VARCHAR
);

-- Indexes
CREATE INDEX idx_followed_stories_user_id ON followed_stories(user_id);
CREATE INDEX idx_followed_stories_story_key ON followed_stories(story_key);
CREATE INDEX idx_story_updates_story_key ON story_updates(story_key);
CREATE INDEX idx_story_updates_article_id ON story_updates(article_id);
```

## Implementation Notes

- Tables are auto-created on first app startup via `Base.metadata.create_all()`
- Story keys should be stable and descriptive for best matching
- Update detection runs with a similarity threshold of 0.4 (40% keyword overlap)
- Articles from the same category get a similarity boost
- Unread counts reset when user opens the Following tab

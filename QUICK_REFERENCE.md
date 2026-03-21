# Followed News - Quick Reference Card

## 🎯 What It Does
Users can follow specific news stories (like "Law 66 for AI") and automatically receive updates when new articles about that story are published.

## 📍 Where to Find It
- **Follow Button**: Impact Screen (after tapping "See the Impact")
- **Updates Feed**: Bottom Nav → Bookmark Icon → "Following" tab
- **Unread Badge**: Red dot on bookmark icon in bottom nav

## 🔑 Key Concepts

| Concept | Description | Example |
|---------|-------------|---------|
| **Story** | A news topic being tracked | "Law 66 for AI" |
| **Story Key** | Unique identifier for matching | `laws-ai-regulation` |
| **Update** | New article related to a followed story | "Court stays Law 66" |
| **Unread Count** | Number of updates since last check | Badge: "2 new" |

## 🛠️ API Endpoints (Quick Copy)

```bash
# Follow a story
POST /followed-stories/
{"article_id": 1, "story_key": "laws-ai-66", "story_title": "Law 66"}

# Get followed stories
GET /followed-stories/

# Get updates feed
GET /followed-stories/feed?limit=50

# Check if following
GET /followed-stories/check/laws-ai-66

# Unfollow
DELETE /followed-stories/{story_id}

# Trigger update detection (admin)
POST /admin/detect-updates?hours_lookback=24
```

## 💻 Code Snippets

### Backend: Manually Link an Update
```python
from app.services.story_update_detection_service import manually_link_update

manually_link_update(
    user_db=db,
    story_key="laws-ai-regulation",
    article_id=123,
    update_type="major_development"
)
```

### Frontend: Access Providers
```dart
// Follow a story
await ref.read(followStoryProvider).followStory(
  articleId: article.id,
  storyKey: 'laws-ai-66',
  storyTitle: 'Law 66 for AI',
);

// Check if following
final isFollowing = await ref.read(followStoryProvider)
  .isFollowing('laws-ai-66');

// Get unread count
final count = ref.watch(followedNewsUnreadCountProvider);
```

## 🎨 UI Components

| Component | Location | Purpose |
|-----------|----------|---------|
| `_FollowNewsButton` | impact_screen.dart | Follow/unfollow toggle |
| `FollowedNewsScreen` | followed_news_screen.dart | Main feed of updates |
| `NezBottomNav` | nez_bottom_nav.dart | Navigation with badge |

## 🔄 Data Flow (Simplified)

```
Follow → API Call → Database Insert → Button Updates

Detect → Match Articles → Create Links → Feed Updates

View → Fetch Updates → Show Badges → Display Articles
```

## 🐛 Common Issues & Solutions

| Issue | Solution |
|-------|----------|
| Button stays grey after following | Check JWT token is valid |
| No updates showing | Run `/admin/detect-updates` |
| Duplicate follows | Backend prevents duplicates automatically |
| Unread count not resetting | Implement mark-read API call |

## 📱 User Actions

| Action | Result |
|--------|--------|
| Tap "Follow News" | Story tracked, button turns green |
| Open Following tab | See all updates, badge count updates |
| Pull down | Refresh for latest updates |
| Tap "read full →" | Open full article in Impact Screen |

## ⚡ Performance Tips

- Fetch followed feed on-demand, not on app startup
- Cache followed stories list locally
- Use pagination for large update lists
- Debounce follow/unfollow actions
- Implement optimistic UI updates

## 🧩 Integration Points

**With Existing Features:**
- ✅ Bookmarks (separate from follows)
- ✅ Feed (main news feed vs followed updates)
- ✅ Notifications (could add follow update notifications)
- ✅ Insights (could track follow engagement)
- ✅ Preferences (categories vs individual stories)

## 📞 Support

For technical questions:
- Architecture: See `FOLLOWED_NEWS_FEATURE.md`
- User guide: See `FOLLOW_NEWS_USAGE.md`
- System flow: See `FOLLOWED_NEWS_FLOW.md`
- Production: See `TODO_PRODUCTION.md`

---

**Version:** 1.0.0 (MVP)  
**Last Updated:** 2026-03-18

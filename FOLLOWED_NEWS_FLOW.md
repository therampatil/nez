# Followed News - System Flow Diagram

## 📱 Frontend → Backend → Database Flow

```
┌─────────────────────────────────────────────────────────────────┐
│                         USER JOURNEY                             │
└─────────────────────────────────────────────────────────────────┘

   USER READS ARTICLE
         │
         ↓
   [Impact Screen Opens]
         │
         ↓
   Check if already following
         │         ↓ API: GET /followed-stories/check/{story_key}
         │         ↓ Backend: is_story_followed()
         │         ↓ Database: Query followed_stories
         │         ↓
         ↓ Response: {is_following: false}
         │
   Button shows: "+ Follow News"
         │
         ↓
   USER TAPS "FOLLOW NEWS"
         │
         ↓ API: POST /followed-stories/
         ↓ Payload: {article_id, story_key, story_title}
         ↓ Backend: follow_story()
         ↓ Database: INSERT into followed_stories
         ↓
   Button updates to "✓ Following"
         │
         ↓
   Snackbar: "Following this story..."


┌─────────────────────────────────────────────────────────────────┐
│                    BACKGROUND PROCESSING                         │
└─────────────────────────────────────────────────────────────────┘

   [New Articles Published]
         │
         ↓
   CRON JOB / MANUAL TRIGGER
         │
         ↓ API: POST /admin/detect-updates
         ↓ Backend: detect_story_updates()
         │
         ↓
   For each followed story:
   ├─ Get recent articles (last 24h)
   ├─ Calculate similarity scores
   ├─ If score > 0.4:
   │  └─ Create StoryUpdate link
   │     └─ Database: INSERT into story_updates
   │
   ↓
   Response: {count: X updates detected}


┌─────────────────────────────────────────────────────────────────┐
│                      VIEWING UPDATES                             │
└─────────────────────────────────────────────────────────────────┘

   USER OPENS FOLLOWING TAB
         │
         ↓
   Load followed stories
         │         ↓ API: GET /followed-stories/
         │         ↓ Backend: get_followed_stories()
         │         ↓ Database: Query followed_stories + story_updates
         │         ↓ Response: [{id, story_key, unread_count: 2}]
         │         ↓
         ↓ Display badge: "2 new"
         │
   Load update feed
         │         ↓ API: GET /followed-stories/feed
         │         ↓ Backend: get_followed_news_feed()
         │         ↓ Database: Query story_updates → news_articles
         │         ↓ Response: [articles array]
         │         ↓
         ↓ Render articles with "NEW UPDATE" badges
         │
   USER SCROLLS THROUGH UPDATES
         │
         ↓
   [Updates are marked as read automatically]
```

## 🔄 Update Detection Algorithm

```
┌──────────────────────────────────────────────────────────────┐
│  Story Key: "laws-ai-regulation-66"                          │
│  Title Keywords: {laws, regulation, enforcement, technical}  │
└──────────────────────────────────────────────────────────────┘
                           ↓
                    [New Article]
                    "Supreme Court grants 
                     30-day stay on enforcement"
                           ↓
                  Extract Keywords
        {supreme, court, grants, stay, enforcement}
                           ↓
                  Calculate Overlap
              common: {enforcement}
              similarity: 1/4 = 0.25
                           ↓
                   Check Category
              Article: "Laws"
              Story: contains "laws"
              ✓ Category boost: +0.3
                           ↓
               Final Score: 0.55
                  (> 0.4 threshold)
                           ↓
                   ✅ MATCH!
                           ↓
              Create StoryUpdate link
```

## 📊 Database Relationships

```
┌─────────────────┐         ┌──────────────────┐
│     User        │         │   NewsArticle    │
│  (user_db)      │         │   (news_db)      │
├─────────────────┤         ├──────────────────┤
│ id              │         │ id               │
│ email           │         │ title            │
│ ...             │         │ category         │
└─────────────────┘         │ created_at       │
        │                   └──────────────────┘
        │                            ▲
        │                            │ reads
        ↓                            │
┌─────────────────┐                 │
│ FollowedStory   │                 │
│  (user_db)      │                 │
├─────────────────┤                 │
│ id              │                 │
│ user_id         │───────┐         │
│ original_article_id     │─────────┘
│ story_key       │       │
│ story_title     │       │
│ last_checked_at │       │
│ created_at      │       │
└─────────────────┘       │
        │                 │
        │ 1:N             │
        ↓                 │
┌─────────────────┐       │
│  StoryUpdate    │       │
│  (user_db)      │       │
├─────────────────┤       │
│ id              │       │
│ story_key       │       │
│ article_id      │───────┘
│ update_type     │
│ created_at      │
└─────────────────┘
```

## 🎨 UI States

### Follow Button States
```
┌──────────────────────────────────────┐
│   UNFOLLOWED (Default)               │
│  ┌─────────────────────────┐         │
│  │  + Follow News      →   │  Grey   │
│  └─────────────────────────┘         │
└──────────────────────────────────────┘

┌──────────────────────────────────────┐
│   FOLLOWING (Active)                 │
│  ┌─────────────────────────┐         │
│  │  ✓ Following            │  Green  │
│  └─────────────────────────┘         │
└──────────────────────────────────────┘
```

### Following Tab Header
```
┌──────────────────────────────────────┐
│  Following              ┌──────────┐ │
│  3 stories tracked ·    │  2 new   │ │
│  2 new updates          └──────────┘ │
└──────────────────────────────────────┘
```

### Article Card (with update)
```
┌─────────────────────────────────────────────┐
│  ● NEW UPDATE · 1H AGO        #LAW 66       │
│                                              │
│  │ Supreme Court grants 30-day               │
│  │ stay on enforcement                       │
│                                              │
│  Tech firms filed joint petition...          │
│                                              │
│  update 2 of 2                               │
│                                              │
│  1h ago · Source - LiveLaw                   │
│                                              │
│  [share] [bookmark]         read full →      │
└─────────────────────────────────────────────┘
```

## 🚀 Deployment Notes

1. **Database Migration**: New tables auto-created on first startup
2. **Update Detection**: Currently manual via `/admin/detect-updates`
3. **Production**: Add cron job or background worker
4. **Monitoring**: Track similarity scores to tune threshold

## 🔮 Future Enhancements

1. **Real-time Updates**: WebSocket notifications
2. **AI Matching**: Use embeddings instead of keywords
3. **Story Timeline**: Visual progression view
4. **Unfollow UI**: Add unfollow option to cards
5. **Story Management**: Dedicated screen to manage follows

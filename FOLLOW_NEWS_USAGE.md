# Follow News - Quick Start Guide

## User Experience

### Following a Story
1. Open any article in the app
2. Tap **"See the Impact"** to view the detailed breakdown
3. At the bottom, tap the **"Follow News"** button
4. Button changes to **"Following"** (green with checkmark)
5. You'll see a confirmation: _"Following this story - you'll see updates in Following tab"_

### Viewing Updates
1. Tap the **bookmark icon** in the bottom navigation bar
2. You'll see the **"Following"** screen with:
   - Badge showing number of new updates (e.g., "2 new")
   - Story count (e.g., "3 stories tracked · 2 new updates")
3. Swipe up to browse through updates
4. Each update shows:
   - **"NEW UPDATE · 1H AGO"** badge for recent articles
   - Category tag (e.g., "LAW 66")
   - Update counter (e.g., "update 2 of 2")
   - Brief description
   - **"read full →"** link to view complete article

### Managing Followed Stories
- Stories are automatically tracked once you follow them
- Updates appear as they're detected by the system
- Pull down to refresh and check for new updates
- Unread count resets when you view the Following tab

## Technical Details

### Story Key Generation
When you follow a story, the app generates a unique `story_key`:
```
category + key-words-from-title
Example: "laws-enforcement-technical" for Law 66 article
```

### Update Detection
The backend automatically:
1. Scans new articles every few hours
2. Matches them to followed stories using:
   - Keyword overlap (40%+ similarity)
   - Category matching
   - Title relevance
3. Links matching articles as updates
4. Users see these in their Following feed

### What Counts as an Update?
An article is considered an update if:
- It shares significant keywords with the story you're following
- It's in the same or related category
- It was published after you started following the story

## Example Flow

**Scenario: Following "Law 66 for AI"**

1. User reads article: _"New Law 66 Proposed for AI Regulation"_ (category: Laws)
2. User taps "Follow News"
3. System creates story key: `"laws-regulation-proposed"`

Later that week:
- New article published: _"Tech Companies Challenge Law 66 Implementation"_
- Backend detects high similarity (keywords: "law", "66")
- Article automatically linked as an update
- User sees badge: "1 new" on Following tab
- Article appears in Following feed with "NEW UPDATE" badge

## Tips
- Follow important stories you want to stay updated on
- Check the Following tab regularly for developments
- Use the "read full" button to dive deeper into updates
- Pull down to refresh and check for latest updates

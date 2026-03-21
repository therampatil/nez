# Backend Testing & TODO Checklist

**Last Updated:** 2026-03-20

---

## 🧪 TESTING CHECKLIST

### 1. Authentication Endpoints

#### Signup & Email Verification
- [ ] `POST /auth/signup` - Create new account
  - [ ] Valid email and password
  - [ ] Duplicate email rejection
  - [ ] Password validation (min length)
  - [ ] Verification email sent
- [ ] `GET /auth/verify-email?token=xxx` - Email verification
  - [ ] Valid token activates account
  - [ ] Expired/invalid token rejected
  - [ ] Already verified token handled
- [ ] `POST /auth/resend-verification` - Resend verification email
  - [ ] Valid unverified email
  - [ ] Already verified user rejection

#### Login
- [ ] `POST /auth/login` - Email/password login
  - [ ] Valid credentials return JWT
  - [ ] Invalid password rejected
  - [ ] Unverified email rejection
  - [ ] Non-existent user rejection
  - [ ] Token expiry works (after 60min)

#### Google Sign-In
- [ ] `POST /auth/google` - Google OAuth
  - [ ] New user auto-creates account
  - [ ] Existing user logs in
  - [ ] Invalid token rejected
  - [ ] Email extraction works

#### Account Security
- [ ] `POST /auth/change-password` - Password change
  - [ ] Valid current password required
  - [ ] New password updated
  - [ ] Invalid current password rejected
- [ ] `POST /auth/change-email` - Email change
  - [ ] Valid password required
  - [ ] New email updated
  - [ ] Duplicate email rejected
  - [ ] Verification email sent to new address

---

### 2. User Management Endpoints

#### Profile
- [ ] `GET /users/me` - Get current user profile
  - [ ] Returns correct user data
  - [ ] JWT validation works
- [ ] `PATCH /users/me` - Update display name
  - [ ] Display name updated
  - [ ] Empty name rejected

#### Preferences
- [ ] `GET /users/me/preferences` - Get category preferences
  - [ ] Returns user's selected categories
  - [ ] Empty preferences handled
- [ ] `PUT /users/me/preferences` - Save preferences
  - [ ] Categories saved correctly
  - [ ] Invalid categories rejected
  - [ ] Duplicate categories handled

#### Insights
- [ ] `GET /users/me/insights` - Reading stats & streak
  - [ ] Total articles read calculated
  - [ ] Category breakdown correct
  - [ ] Streak calculation accurate
  - [ ] Last read date correct

#### Account Deletion
- [ ] `DELETE /users/me` - Delete account
  - [ ] User record deleted
  - [ ] Related data cleaned up
  - [ ] JWT invalidated

---

### 3. News Feed Endpoints

- [ ] `GET /feed/` - Personalized feed
  - [ ] Returns articles matching preferences
  - [ ] Ranked by recency + relevance
  - [ ] JWT authentication required
  - [ ] Pagination works (limit/offset)
  - [ ] Empty feed handled
- [ ] `GET /articles/` - List all articles
  - [ ] Paginated results
  - [ ] No auth required
  - [ ] Category filter works
- [ ] `GET /articles/{id}` - Single article
  - [ ] Returns full article details
  - [ ] Invalid ID returns 404
  - [ ] Overview, context, impact included

---

### 4. Interactions Endpoint

- [ ] `POST /interactions/` - Record interaction
  - [ ] Read interaction recorded
  - [ ] Bookmark interaction recorded
  - [ ] Share interaction recorded
  - [ ] Article category denormalized
  - [ ] Duplicate reads handled
  - [ ] Insights updated correctly

---

### 5. Followed Stories Endpoints

- [ ] `POST /followed-stories/` - Follow story
  - [ ] Creates followed_story record
  - [ ] Story key generated correctly
  - [ ] Duplicate follow rejected (same user + story_key)
  - [ ] Returns follow confirmation
- [ ] `DELETE /followed-stories/{story_id}` - Unfollow story
  - [ ] Removes followed_story record
  - [ ] Non-existent story returns 404
  - [ ] Can't unfollow other user's stories
- [ ] `GET /followed-stories/` - List followed stories
  - [ ] Returns all user's followed stories
  - [ ] Includes unread update counts
  - [ ] Ordered by most recent first
- [ ] `GET /followed-stories/feed` - Get story updates
  - [ ] Returns new articles for followed stories
  - [ ] Filters by last_checked_at
  - [ ] Includes update counter
  - [ ] Ordered by recency
- [ ] `POST /followed-stories/{story_id}/mark-read` - Mark checked
  - [ ] Updates last_checked_at timestamp
  - [ ] Resets unread count to 0
- [ ] `GET /followed-stories/check/{story_key}` - Check follow status
  - [ ] Returns true if following
  - [ ] Returns false if not following

---

### 6. Admin Endpoints

- [ ] `POST /admin/detect-updates` - Trigger update detection
  - [ ] Scans recent articles
  - [ ] Creates story_updates links
  - [ ] Similarity threshold works (40%)
  - [ ] No duplicate updates created
  - [ ] Returns detection summary

---

### 7. Edge Cases & Error Handling

#### Authentication
- [ ] Missing JWT returns 401
- [ ] Invalid JWT returns 401
- [ ] Expired JWT returns 401
- [ ] Missing request body returns 422

#### Database
- [ ] Connection failure handled gracefully
- [ ] Transaction rollback on errors
- [ ] Concurrent requests don't conflict

#### Data Validation
- [ ] SQL injection prevented
- [ ] XSS in story_title sanitized
- [ ] Invalid article_id handled
- [ ] Empty/null values validated

---

### 8. Performance Testing

- [ ] **Load Testing**
  - [ ] 100 concurrent users on /feed/
  - [ ] 50 simultaneous follows
  - [ ] Update detection with 1000+ articles
- [ ] **Response Times**
  - [ ] /feed/ < 500ms
  - [ ] /followed-stories/feed < 300ms
  - [ ] /auth/login < 200ms
  - [ ] /interactions/ < 100ms
- [ ] **Database Queries**
  - [ ] Feed query uses indexes
  - [ ] Insights query optimized
  - [ ] N+1 queries eliminated

---

### 9. Integration Testing

- [ ] **Full User Journey**
  1. Signup → Verify Email → Login
  2. Set Preferences
  3. Browse Feed
  4. Read Article → Record Interaction
  5. Follow Story
  6. Detect Updates (admin endpoint)
  7. View Updates in Feed
  8. Mark as Checked
  9. Unfollow Story
  10. Check Insights

- [ ] **Multi-User Scenarios**
  - [ ] Multiple users follow same story
  - [ ] Updates visible to all followers
  - [ ] Users can't see each other's data

- [ ] **Cross-Database**
  - [ ] Articles from news DB appear in feed
  - [ ] Interactions in user DB link to news DB articles
  - [ ] Story updates detect news DB articles

---

## 📋 TODO LIST (Prioritized)

### 🔥 HIGH PRIORITY (Do First)

#### P0 - Critical for Production
1. **Set Up Automated Update Detection**
   - [ ] Implement cron job/scheduler (Railway Cron or external)
   - [ ] Run every 2-4 hours
   - [ ] Monitor for failures
   - [ ] Add retry logic

2. **Add Rate Limiting**
   - [ ] Limit follow/unfollow actions (e.g., 50/hour per user)
   - [ ] Limit API requests globally (e.g., 1000/min)
   - [ ] Use slowapi or FastAPI middleware

3. **Database Optimization**
   - [ ] Add composite index: `(user_id, story_key)` on followed_stories
   - [ ] Add composite index: `(story_key, created_at)` on story_updates
   - [ ] Add pagination to `/followed-stories/` endpoint

4. **Error Logging & Monitoring**
   - [ ] Set up Sentry or Railway logging
   - [ ] Monitor API error rates
   - [ ] Alert on high failure rates
   - [ ] Track slow query performance

5. **Security Hardening**
   - [ ] Add max limit on stories per user (e.g., 50-100)
   - [ ] Sanitize story_title input (prevent XSS)
   - [ ] Validate story_key format
   - [ ] Add CORS configuration review

---

### ⚡ MEDIUM PRIORITY (Do Soon)

#### P1 - Important Enhancements
6. **Push Notifications**
   - [ ] Integrate Firebase Cloud Messaging (FCM)
   - [ ] Add device token storage in User model
   - [ ] Send notifications on story updates
   - [ ] Add notification preferences (mute/unmute)
   - [ ] Implement notification scheduling

7. **Improved Story Matching**
   - [ ] Use article URLs for exact matches
   - [ ] Extract entities (people, organizations, locations)
   - [ ] Implement TF-IDF or embeddings-based similarity
   - [ ] Add manual article linking endpoint
   - [ ] Let users report missed/wrong updates

8. **Story Management**
   - [ ] Add story grouping/folders
   - [ ] Add story notes/comments
   - [ ] Add story sharing between users
   - [ ] Implement story recommendations

9. **Analytics & Insights**
   - [ ] Track follow/unfollow events
   - [ ] Monitor update detection accuracy
   - [ ] Track engagement with updates
   - [ ] Add admin dashboard for metrics

10. **Email Digests**
    - [ ] Weekly summary of followed story updates
    - [ ] Daily digest option
    - [ ] User preference for digest frequency
    - [ ] HTML email templates

---

### 🎨 LOW PRIORITY (Nice to Have)

#### P2 - Polish & Future Features
11. **API Improvements**
    - [ ] Add GraphQL endpoint (alternative to REST)
    - [ ] Implement API versioning (v1, v2)
    - [ ] Add webhook support for integrations
    - [ ] Add bulk operations (follow multiple stories)

12. **Caching Layer**
    - [ ] Add Redis for feed caching
    - [ ] Cache followed stories per user
    - [ ] Cache article details
    - [ ] Set TTL policies (e.g., 5-15 min)

13. **Search Enhancements**
    - [ ] Full-text search on articles
    - [ ] Search within followed stories
    - [ ] Filter by date range
    - [ ] Advanced filters (source, author)

14. **Social Features**
    - [ ] Follow other users
    - [ ] Share reading lists
    - [ ] Comments on articles
    - [ ] Reactions (like, insightful, etc.)

15. **Export & Backup**
    - [ ] Export user data (GDPR compliance)
    - [ ] Export reading history
    - [ ] Backup followed stories
    - [ ] Import from other news apps

16. **AI Enhancements**
    - [ ] Use Gemini for better story matching
    - [ ] Generate story summaries automatically
    - [ ] Personalized story recommendations
    - [ ] Smart digest curation

17. **Testing Infrastructure**
    - [ ] Write unit tests (pytest)
    - [ ] Write integration tests
    - [ ] Add CI/CD pipeline (GitHub Actions)
    - [ ] Test coverage reports (>80%)

---

## 🎯 PRIORITY SUMMARY

### Must Have (Next 1-2 Weeks)
1. Automated update detection cron
2. Rate limiting
3. Database indexes
4. Error monitoring
5. Security hardening

### Should Have (Next 1 Month)
6. Push notifications
7. Better story matching algorithm
8. Story management UI
9. Analytics tracking
10. Email digests

### Could Have (Future)
11. GraphQL API
12. Redis caching
13. Advanced search
14. Social features
15. Data export
16. AI enhancements
17. Comprehensive testing

---

## 📊 Feature Completeness

| Feature | Status | Priority |
|---------|--------|----------|
| Auth (signup, login, verify) | ✅ Complete | P0 |
| Google Sign-In | ✅ Complete | P0 |
| User profiles & preferences | ✅ Complete | P0 |
| Personalized feed | ✅ Complete | P0 |
| Article interactions | ✅ Complete | P0 |
| Reading insights & streaks | ✅ Complete | P0 |
| Follow specific stories | ✅ Complete | P1 |
| Auto-detect story updates | ✅ Complete | P1 |
| Followed news feed | ✅ Complete | P1 |
| Update detection automation | ⚠️ Manual only | **P0** |
| Rate limiting | ❌ Not implemented | **P0** |
| Push notifications | ❌ Not implemented | P1 |
| Better matching algorithm | ❌ Basic keyword only | P1 |
| Email digests | ❌ Not implemented | P1 |
| Redis caching | ❌ Not implemented | P2 |
| Full-text search | ❌ Not implemented | P2 |
| Social features | ❌ Not implemented | P2 |

---

## 🔍 Testing Tools & Commands

### Manual API Testing

```bash
# Health check
curl http://localhost:8000/

# Signup
curl -X POST http://localhost:8000/auth/signup \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"password123","display_name":"Test User"}'

# Login
curl -X POST http://localhost:8000/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"password123"}'

# Get feed (requires JWT)
curl http://localhost:8000/feed/ \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"

# Follow story (requires JWT)
curl -X POST http://localhost:8000/followed-stories/ \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"original_article_id":123,"story_key":"sample-story","story_title":"Sample Story"}'

# Detect updates
curl -X POST http://localhost:8000/admin/detect-updates
```

### Automated Testing Script
See `test_followed_news_api.sh` for automated endpoint testing.

---

## 🚨 CRITICAL ISSUES TO ADDRESS

1. **No Update Detection Automation** - Updates only detected when manually triggered
2. **No Rate Limiting** - API vulnerable to abuse
3. **No Database Indexes** - Performance may degrade with scale
4. **No Error Monitoring** - No visibility into production issues
5. **No Max Story Limit** - Users could follow unlimited stories

---

## 💡 RECOMMENDATIONS

### Immediate (This Week)
1. Set up Railway Cron for update detection (every 2-4 hours)
2. Add rate limiting with slowapi
3. Add database indexes in migration script
4. Set up basic logging/monitoring

### Short-term (This Month)
1. Implement push notifications for story updates
2. Improve similarity algorithm (use embeddings)
3. Add comprehensive error handling
4. Write automated tests

### Long-term (Next Quarter)
1. Build admin dashboard for monitoring
2. Implement email digest system
3. Add Redis caching layer
4. Expand social features

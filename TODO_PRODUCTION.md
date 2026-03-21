# Followed News - Production Checklist

## 🧪 Testing Required

### Backend API Testing
- [ ] Test all 6 followed-stories endpoints with Postman/curl
- [ ] Verify JWT authentication works correctly
- [ ] Test edge cases (follow same story twice, unfollow non-existent)
- [ ] Test update detection with real articles
- [ ] Verify similarity algorithm accuracy
- [ ] Load test with multiple users and stories

### Frontend Testing
- [ ] Follow button changes state correctly
- [ ] Following tab shows correct unread count
- [ ] Badge appears on bottom navigation
- [ ] Pull-to-refresh works
- [ ] Article cards render properly
- [ ] "NEW UPDATE" badges show for recent articles
- [ ] Navigation between screens works
- [ ] Snackbar messages display correctly
- [ ] Error handling (network failures, empty states)

### Integration Testing
- [ ] End-to-end: Follow → Detect Updates → View Updates
- [ ] Test with multiple followed stories
- [ ] Verify unread count accuracy
- [ ] Test concurrent users following same story
- [ ] Test story key generation consistency

## 🚀 Production Deployment

### Backend
- [ ] Deploy updated code to Railway
- [ ] Verify database tables created (`followed_stories`, `story_updates`)
- [ ] Set up environment variables (if any new ones added)
- [ ] Test `/admin/detect-updates` endpoint manually
- [ ] **Set up automated update detection:**
  - Option 1: Railway Cron Job
  - Option 2: External cron service (cron-job.org)
  - Option 3: Background worker process
  - Recommended schedule: Every 2-4 hours

### Frontend
- [ ] Test on iOS device
- [ ] Test on Android device
- [ ] Verify API calls use correct production URL
- [ ] Test with real backend data
- [ ] Verify navigation flow
- [ ] Check performance with many followed stories

## 🔧 Configuration

### Backend Environment Variables
All existing variables should work. No new environment variables required.

### Update Detection Schedule
Add to Railway or external cron:
```bash
# Run every 2 hours
0 */2 * * * curl -X POST https://nez-backend-production.up.railway.app/admin/detect-updates
```

Or use Railway Cron (if available):
```yaml
# railway.toml
[jobs.detect-updates]
  schedule = "0 */2 * * *"
  command = "python -c 'from app.main import app; from app.services.story_update_detection_service import detect_story_updates; from app.core.database import SessionLocal; db = SessionLocal(); detect_story_updates(db, db, 24); db.close()'"
```

## 🐛 Known Limitations / TODOs

### Current MVP Limitations
1. **No Unfollow UI**: Users can follow but can't easily unfollow from UI
2. **Basic Matching**: Keyword-based matching may miss some updates
3. **No Story Management**: No dedicated screen to view/manage all follows
4. **Manual Detection**: Update detection must be triggered manually
5. **No Notifications**: Users must manually check for updates

### Immediate Improvements
- [ ] Add unfollow button to article cards
- [ ] Add "Manage Followed Stories" screen
- [ ] Improve story key generation (consider manual naming)
- [ ] Add more sophisticated matching (use article URLs, entities)
- [ ] Implement push notifications for important updates

### Polish
- [ ] Loading states for follow/unfollow actions
- [ ] Animations for state changes
- [ ] Better error messages
- [ ] Offline support
- [ ] Cache followed feed locally

## 📈 Monitoring & Analytics

### Metrics to Track
- [ ] Number of stories followed per user (avg, median, max)
- [ ] Follow → Unfollow rate (churn)
- [ ] Update detection accuracy (false positives/negatives)
- [ ] Time spent on Following tab
- [ ] Click-through rate on updates
- [ ] Most followed story keys/categories

### Backend Logging
Already implemented:
```python
logger.info("User %s following story: %s", user_id, story_key)
logger.info("Linked article %s to story %s (similarity: %.2f)", ...)
```

Consider adding:
- User engagement events (open Following tab, tap update)
- Update detection performance metrics
- Error rate monitoring

## 🔒 Security Considerations

### Current Status
- ✅ JWT authentication on all followed-stories endpoints
- ✅ User ID from JWT, not request body
- ✅ Users can only see/modify their own followed stories

### Additional Security
- [ ] Rate limiting on follow/unfollow actions
- [ ] Validate story_key format
- [ ] Sanitize user input in story_title
- [ ] Add pagination to followed-stories list
- [ ] Add max limit on stories per user (e.g., 50)

## 💾 Database Optimization

### Indexes Already in Code
```python
# Models include these indexes:
user_id (index=True)
story_key (index=True)
article_id (index=True)
original_article_id (index=True)
```

### Additional Optimization
- [ ] Add composite index: `(user_id, story_key)` on followed_stories
- [ ] Add composite index: `(story_key, created_at)` on story_updates
- [ ] Monitor query performance
- [ ] Add query result caching (Redis)

## 📱 Mobile App Considerations

### Battery/Performance
- [ ] Batch API calls when possible
- [ ] Cache followed feed locally
- [ ] Implement incremental loading
- [ ] Add background fetch for updates (iOS/Android)

### UX Polish
- [ ] Haptic feedback on follow/unfollow
- [ ] Smooth animations
- [ ] Loading skeletons
- [ ] Swipe actions (swipe to unfollow)
- [ ] Empty state illustrations

## 🎓 Documentation Updates

### API Documentation
- [ ] Add OpenAPI/Swagger docs for new endpoints
- [ ] Update Postman collection
- [ ] Add example requests/responses

### User Documentation
- [ ] Add help section in app
- [ ] Create tutorial/onboarding for Follow News
- [ ] Add FAQ about how updates are detected
- [ ] Update privacy policy (if tracking new data)

## ✅ Sign-off Checklist

Before marking as production-ready:

**Functionality:**
- [ ] All endpoints work correctly
- [ ] UI matches design specs
- [ ] Error handling is robust
- [ ] Edge cases handled

**Performance:**
- [ ] API response times < 500ms
- [ ] UI animations smooth (60fps)
- [ ] No memory leaks
- [ ] Database queries optimized

**Quality:**
- [ ] Code reviewed
- [ ] No console warnings/errors
- [ ] Analytics events tracked
- [ ] Error logging in place

**Deployment:**
- [ ] Backend deployed successfully
- [ ] Database migrated
- [ ] Update detection scheduled
- [ ] Monitoring set up
- [ ] Rollback plan ready

---

**Current Status:** ✅ MVP Implementation Complete - Ready for Testing

**Last Updated:** 2026-03-18

# Headlines API - Quick Reference

## 🚀 Quick Start

### Start the Backend
```bash
cd nez_backend
uvicorn app.main:app --reload
```

### Test Endpoints
```bash
# Get latest headlines
curl http://localhost:8000/headlines/latest/?limit=5

# Get all headlines (paginated)
curl http://localhost:8000/headlines/?limit=10

# Filter by category
curl "http://localhost:8000/headlines/?category=Technology&limit=5"

# Get specific headline
curl http://localhost:8000/headlines/5
```

## 📋 Endpoints Summary

| Endpoint | Method | Purpose |
|----------|--------|---------|
| `/headlines/` | GET | List all headlines with pagination & filtering |
| `/headlines/latest/` | GET | Get most recent headlines |
| `/headlines/{id}` | GET | Get specific headline by ID |

## 🔧 Query Parameters

### `/headlines/`
- `skip` (int, default: 0) - Records to skip
- `limit` (int, default: 20, max: 100) - Records to return
- `category` (string, optional) - Filter by category

### `/headlines/latest/`
- `limit` (int, default: 10, max: 50) - Number of headlines

## 📦 Response Format
```json
{
  "id": 5,
  "headline": "OpenAI Acquires Astral...",
  "article_url": "https://...",
  "source": "The Hindu",
  "category": "Society",
  "overview": "Brief summary...",
  "why_this_matters": "Significance...",
  "impact": "Impact analysis...",
  "created_at": "2026-03-20T08:10:35.963721Z",
  "updated_at": "2026-03-20T08:25:02.158288Z"
}
```

## 🎯 Common Use Cases

### Get Breaking News (Latest 10)
```bash
curl http://localhost:8000/headlines/latest/?limit=10
```

### Get Tech News
```bash
curl "http://localhost:8000/headlines/?category=Technology"
```

### Pagination (Next Page)
```bash
curl "http://localhost:8000/headlines/?skip=20&limit=20"
```

## 📱 Flutter Integration

```dart
// Service
class HeadlinesService {
  final String baseUrl = 'http://your-backend-url';
  
  Future<List<Headline>> getLatest() async {
    final response = await http.get(
      Uri.parse('$baseUrl/headlines/latest/?limit=10')
    );
    return (json.decode(response.body) as List)
      .map((json) => Headline.fromJson(json))
      .toList();
  }
}

// Usage
final headlines = await HeadlinesService().getLatest();
```

## 📚 Documentation
- Full API Docs: `HEADLINES_API_DOCUMENTATION.md`
- Implementation Details: `HEADLINES_FEATURE_SUMMARY.md`
- Swagger UI: `http://localhost:8000/docs`

## ✅ Status
✅ Backend API live and functional
✅ Database connected to `news_headlines` table
✅ Three endpoints available
✅ Fully tested and documented
✅ Ready for Flutter integration

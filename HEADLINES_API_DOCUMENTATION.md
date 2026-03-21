# Headlines API Documentation

## Overview
The Headlines API provides access to news headlines stored in the `news_headlines` table of the news database. This endpoint fetches pre-analyzed headlines with metadata including source, category, overview, and impact analysis.

## Base URL
```
http://localhost:8000/headlines
```

## Endpoints

### 1. List Headlines
Get a paginated list of headlines from the database.

**Endpoint:** `GET /headlines/`

**Query Parameters:**
- `skip` (optional, default: 0) - Number of records to skip for pagination
- `limit` (optional, default: 20, max: 100) - Number of records to return
- `category` (optional) - Filter headlines by category

**Example Request:**
```bash
curl "http://localhost:8000/headlines/?limit=10&category=Society"
```

**Example Response:**
```json
[
  {
    "id": 5,
    "headline": "OpenAI Acquires Astral to Unleash AI-Powered 'Superapp' Rivalry",
    "article_url": "https://www.thehindu.com/sci-tech/technology/openai-chatgpt-revamp-python-buy/article70764152.ece",
    "source": "The Hindu",
    "category": "Society",
    "overview": "OpenAI acquires Astral to boost Codex AI coding system...",
    "why_this_matters": "OpenAI challenges Anthropic with revamped product lineup...",
    "impact": "Acquisition strengthens OpenAI's grip on AI coding...",
    "created_at": "2026-03-20T08:10:35.963721Z",
    "updated_at": "2026-03-20T08:25:02.158288Z"
  }
]
```

---

### 2. Get Latest Headlines
Retrieve the most recent headlines.

**Endpoint:** `GET /headlines/latest/`

**Query Parameters:**
- `limit` (optional, default: 10, max: 50) - Number of recent headlines to return

**Example Request:**
```bash
curl "http://localhost:8000/headlines/latest/?limit=5"
```

---

### 3. Get Single Headline
Retrieve a specific headline by its ID.

**Endpoint:** `GET /headlines/{headline_id}`

**Path Parameters:**
- `headline_id` (required) - The unique ID of the headline

**Example Request:**
```bash
curl "http://localhost:8000/headlines/5"
```

**Example Response:**
```json
{
  "id": 5,
  "headline": "OpenAI Acquires Astral to Unleash AI-Powered 'Superapp' Rivalry",
  "article_url": "https://www.thehindu.com/sci-tech/technology/openai-chatgpt-revamp-python-buy/article70764152.ece",
  "source": "The Hindu",
  "category": "Society",
  "overview": "OpenAI acquires Astral to boost Codex AI coding system...",
  "why_this_matters": "OpenAI challenges Anthropic with revamped product lineup...",
  "impact": "Acquisition strengthens OpenAI's grip on AI coding...",
  "created_at": "2026-03-20T08:10:35.963721Z",
  "updated_at": "2026-03-20T08:25:02.158288Z"
}
```

**Error Response (404):**
```json
{
  "detail": "Headline not found"
}
```

---

## Response Schema

All endpoints return headlines with the following structure:

| Field | Type | Description |
|-------|------|-------------|
| `id` | integer | Unique identifier for the headline |
| `headline` | string | The headline text |
| `article_url` | string | URL to the full article |
| `source` | string | News source (e.g., "The Hindu", "Indian Express") |
| `category` | string | Category of the news (e.g., "Society", "Business", "Technology") |
| `overview` | string | Brief overview of the news |
| `why_this_matters` | string | Explanation of the headline's significance |
| `impact` | string | Analysis of potential impact |
| `created_at` | datetime | Timestamp when the headline was created |
| `updated_at` | datetime | Timestamp when the headline was last updated |

---

## Available Categories
- Agriculture
- Business
- Career
- Environment
- Society
- Technology
- (and more)

---

## Testing

Run the provided test script to verify all endpoints:

```bash
./test_headlines_api.sh
```

---

## Integration with Flutter App

### Basic Example

```dart
import 'package:http/http.dart' as http;
import 'dart:convert';

class HeadlinesService {
  final String baseUrl = 'http://your-backend-url.com';

  Future<List<Headline>> getLatestHeadlines({int limit = 10}) async {
    final response = await http.get(
      Uri.parse('$baseUrl/headlines/latest/?limit=$limit'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Headline.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load headlines');
    }
  }

  Future<List<Headline>> getHeadlinesByCategory(String category, {int limit = 20}) async {
    final response = await http.get(
      Uri.parse('$baseUrl/headlines/?category=$category&limit=$limit'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Headline.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load headlines');
    }
  }
}

class Headline {
  final int id;
  final String headline;
  final String articleUrl;
  final String? source;
  final String? category;
  final String? overview;
  final String? whyThisMatters;
  final String? impact;
  final DateTime createdAt;
  final DateTime updatedAt;

  Headline({
    required this.id,
    required this.headline,
    required this.articleUrl,
    this.source,
    this.category,
    this.overview,
    this.whyThisMatters,
    this.impact,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Headline.fromJson(Map<String, dynamic> json) {
    return Headline(
      id: json['id'],
      headline: json['headline'],
      articleUrl: json['article_url'],
      source: json['source'],
      category: json['category'],
      overview: json['overview'],
      whyThisMatters: json['why_this_matters'],
      impact: json['impact'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}
```

---

## Notes

- All timestamps are in UTC ISO 8601 format
- The headlines are ordered by creation date (newest first) by default
- This is a read-only API - headlines are populated by a separate news ingestion backend
- All endpoints are public and don't require authentication (modify if needed)

---

## API Documentation (Swagger UI)

Visit `http://localhost:8000/docs` for interactive API documentation with Swagger UI.

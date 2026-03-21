#!/bin/bash

# Test script for Followed News API endpoints
# Usage: ./test_followed_news_api.sh <base_url> <jwt_token>

BASE_URL="${1:-http://localhost:8000}"
TOKEN="${2:-your_jwt_token_here}"

echo "🧪 Testing Followed News API"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Base URL: $BASE_URL"
echo ""

# Test 1: Follow a story
echo "1️⃣  Following a story..."
curl -s -X POST "$BASE_URL/followed-stories/" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "article_id": 1,
    "story_key": "laws-ai-regulation-66",
    "story_title": "Law 66 for AI Regulation"
  }' | python3 -m json.tool

echo ""
echo ""

# Test 2: Check if following
echo "2️⃣  Checking follow status..."
curl -s "$BASE_URL/followed-stories/check/laws-ai-regulation-66" \
  -H "Authorization: Bearer $TOKEN" | python3 -m json.tool

echo ""
echo ""

# Test 3: List all followed stories
echo "3️⃣  Listing all followed stories..."
curl -s "$BASE_URL/followed-stories/" \
  -H "Authorization: Bearer $TOKEN" | python3 -m json.tool

echo ""
echo ""

# Test 4: Get followed news feed
echo "4️⃣  Getting followed news feed..."
curl -s "$BASE_URL/followed-stories/feed?limit=10" \
  -H "Authorization: Bearer $TOKEN" | python3 -m json.tool

echo ""
echo ""

# Test 5: Trigger update detection (admin)
echo "5️⃣  Triggering update detection..."
curl -s -X POST "$BASE_URL/admin/detect-updates?hours_lookback=24" | python3 -m json.tool

echo ""
echo ""
echo "✅ Tests complete"

#!/bin/bash
# Test script for Headlines API

BASE_URL="http://localhost:8000"

echo "=== Testing Headlines API ==="
echo

echo "1. Get all headlines (default pagination):"
curl -s "${BASE_URL}/headlines/" | python3 -m json.tool | head -30
echo
echo "---"
echo

echo "2. Get latest 5 headlines:"
curl -s "${BASE_URL}/headlines/latest/?limit=5" | python3 -m json.tool | head -30
echo
echo "---"
echo

echo "3. Get headlines filtered by category (Society):"
curl -s "${BASE_URL}/headlines/?category=Society&limit=3" | python3 -m json.tool
echo
echo "---"
echo

echo "4. Get specific headline by ID (ID=5):"
curl -s "${BASE_URL}/headlines/5" | python3 -m json.tool
echo
echo "---"
echo

echo "✓ All tests completed!"

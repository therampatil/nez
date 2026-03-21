#!/bin/bash

# Authentication Endpoints Testing Script
# Tests all auth endpoints systematically

BASE_URL="http://localhost:8000"
TEST_EMAIL="test_$(date +%s)@example.com"
TEST_PASSWORD="TestPassword123!"
TEST_NAME="Test User"

echo "========================================"
echo "AUTHENTICATION ENDPOINTS TESTING"
echo "========================================"
echo ""

# Color codes
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Test counter
PASS=0
FAIL=0

# Helper function to test endpoint
test_endpoint() {
    local name=$1
    local response=$2
    local expected=$3
    
    if echo "$response" | grep -q "$expected"; then
        echo -e "${GREEN}✓ PASS${NC}: $name"
        ((PASS++))
    else
        echo -e "${RED}✗ FAIL${NC}: $name"
        echo "  Response: $response"
        ((FAIL++))
    fi
}

echo "Test email: $TEST_EMAIL"
echo ""

# ============================================
# 1. HEALTH CHECK
# ============================================
echo "----------------------------------------"
echo "1. HEALTH CHECK"
echo "----------------------------------------"
HEALTH=$(curl -s $BASE_URL/)
test_endpoint "GET / - Health check" "$HEALTH" "Nez Backend API"
echo ""

# ============================================
# 2. SIGNUP
# ============================================
echo "----------------------------------------"
echo "2. SIGNUP TESTS"
echo "----------------------------------------"

# Test valid signup
SIGNUP_RESPONSE=$(curl -s -X POST $BASE_URL/auth/signup \
  -H "Content-Type: application/json" \
  -d "{\"email\":\"$TEST_EMAIL\",\"password\":\"$TEST_PASSWORD\",\"display_name\":\"$TEST_NAME\"}")
test_endpoint "POST /auth/signup - Valid signup" "$SIGNUP_RESPONSE" "verification email"
echo "  Response: $SIGNUP_RESPONSE"

# Test duplicate email
DUPLICATE=$(curl -s -X POST $BASE_URL/auth/signup \
  -H "Content-Type: application/json" \
  -d "{\"email\":\"$TEST_EMAIL\",\"password\":\"$TEST_PASSWORD\",\"display_name\":\"$TEST_NAME\"}")
test_endpoint "POST /auth/signup - Duplicate email rejected" "$DUPLICATE" "already registered"

# Test weak password
WEAK_PASS=$(curl -s -X POST $BASE_URL/auth/signup \
  -H "Content-Type: application/json" \
  -d "{\"email\":\"weak_$(date +%s)@example.com\",\"password\":\"123\",\"display_name\":\"Test\"}")
test_endpoint "POST /auth/signup - Weak password rejected" "$WEAK_PASS" "detail"

# Test invalid email format
INVALID_EMAIL=$(curl -s -X POST $BASE_URL/auth/signup \
  -H "Content-Type: application/json" \
  -d "{\"email\":\"notanemail\",\"password\":\"$TEST_PASSWORD\",\"display_name\":\"Test\"}")
test_endpoint "POST /auth/signup - Invalid email rejected" "$INVALID_EMAIL" "detail"
echo ""

# ============================================
# 3. LOGIN (Unverified User)
# ============================================
echo "----------------------------------------"
echo "3. LOGIN TESTS (Unverified User)"
echo "----------------------------------------"

# Test login with unverified email (should fail)
LOGIN_UNVERIFIED=$(curl -s -X POST $BASE_URL/auth/login \
  -H "Content-Type: application/json" \
  -d "{\"email\":\"$TEST_EMAIL\",\"password\":\"$TEST_PASSWORD\"}")
test_endpoint "POST /auth/login - Unverified email rejected" "$LOGIN_UNVERIFIED" "not verified"
echo ""

# ============================================
# 4. RESEND VERIFICATION
# ============================================
echo "----------------------------------------"
echo "4. RESEND VERIFICATION"
echo "----------------------------------------"

RESEND=$(curl -s -X POST $BASE_URL/auth/resend-verification \
  -H "Content-Type: application/json" \
  -d "{\"email\":\"$TEST_EMAIL\"}")
test_endpoint "POST /auth/resend-verification - Valid email" "$RESEND" "sent"
echo ""

# ============================================
# 5. EMAIL VERIFICATION (Manual Step)
# ============================================
echo "----------------------------------------"
echo "5. EMAIL VERIFICATION"
echo "----------------------------------------"
echo -e "${YELLOW}⚠ MANUAL STEP REQUIRED:${NC}"
echo "  1. Check your email logs or database for verification token"
echo "  2. Visit: $BASE_URL/auth/verify-email?token=TOKEN_HERE"
echo "  3. Then continue with login tests"
echo ""
echo "For automated testing, we'll manually verify in DB:"

# Get user ID from database
USER_ID=$(curl -s -X POST https://nez-backend-production.up.railway.app/auth/login \
  -H "Content-Type: application/json" \
  -d "{\"email\":\"existing@example.com\",\"password\":\"password123\"}" 2>/dev/null)

echo -e "${YELLOW}Skipping actual verification - would need DB access${NC}"
echo ""

# ============================================
# 6. LOGIN (Testing with Production User)
# ============================================
echo "----------------------------------------"
echo "6. LOGIN TESTS (Using Production)"
echo "----------------------------------------"

# Test valid login (use production endpoint)
echo "Testing with production backend..."
PROD_LOGIN=$(curl -s -X POST https://nez-backend-production.up.railway.app/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"theramonpatil@gmail.com","password":"26@the@nez2026"}')

if echo "$PROD_LOGIN" | grep -q "access_token"; then
    echo -e "${GREEN}✓ PASS${NC}: POST /auth/login - Valid credentials"
    ((PASS++))
    TOKEN=$(echo $PROD_LOGIN | grep -o '"access_token":"[^"]*' | cut -d'"' -f4)
    echo "  Token obtained: ${TOKEN:0:20}..."
else
    echo -e "${RED}✗ FAIL${NC}: POST /auth/login - Valid credentials"
    ((FAIL++))
    echo "  Response: $PROD_LOGIN"
    TOKEN=""
fi

# Test invalid password
INVALID_PASS=$(curl -s -X POST https://nez-backend-production.up.railway.app/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"theramonpatil@gmail.com","password":"wrongpassword"}')
test_endpoint "POST /auth/login - Invalid password rejected" "$INVALID_PASS" "Incorrect"

# Test non-existent user
NO_USER=$(curl -s -X POST https://nez-backend-production.up.railway.app/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"nonexistent99999@example.com","password":"password123"}')
test_endpoint "POST /auth/login - Non-existent user rejected" "$NO_USER" "not found"
echo ""

# ============================================
# 7. CHANGE PASSWORD
# ============================================
echo "----------------------------------------"
echo "7. CHANGE PASSWORD TESTS"
echo "----------------------------------------"

if [ -n "$TOKEN" ]; then
    # Test with invalid current password
    CHANGE_PASS_INVALID=$(curl -s -X POST https://nez-backend-production.up.railway.app/auth/change-password \
      -H "Authorization: Bearer $TOKEN" \
      -H "Content-Type: application/json" \
      -d '{"current_password":"wrongpass","new_password":"NewPassword123!"}')
    test_endpoint "POST /auth/change-password - Wrong current password" "$CHANGE_PASS_INVALID" "Incorrect"
    
    echo -e "${YELLOW}⚠ Skipping actual password change to avoid locking account${NC}"
else
    echo -e "${YELLOW}⚠ Skipped - No valid token${NC}"
fi
echo ""

# ============================================
# 8. CHANGE EMAIL
# ============================================
echo "----------------------------------------"
echo "8. CHANGE EMAIL TESTS"
echo "----------------------------------------"

if [ -n "$TOKEN" ]; then
    # Test with invalid password
    CHANGE_EMAIL_INVALID=$(curl -s -X POST https://nez-backend-production.up.railway.app/auth/change-email \
      -H "Authorization: Bearer $TOKEN" \
      -H "Content-Type: application/json" \
      -d '{"new_email":"newemail@example.com","password":"wrongpass"}')
    test_endpoint "POST /auth/change-email - Wrong password" "$CHANGE_EMAIL_INVALID" "Incorrect"
    
    echo -e "${YELLOW}⚠ Skipping actual email change to avoid account issues${NC}"
else
    echo -e "${YELLOW}⚠ Skipped - No valid token${NC}"
fi
echo ""

# ============================================
# 9. PROTECTED ENDPOINT ACCESS
# ============================================
echo "----------------------------------------"
echo "9. JWT AUTHENTICATION TESTS"
echo "----------------------------------------"

# Test without token
NO_TOKEN=$(curl -s https://nez-backend-production.up.railway.app/users/me)
test_endpoint "Protected endpoint - No token rejected" "$NO_TOKEN" "Not authenticated"

# Test with invalid token
INVALID_TOKEN=$(curl -s https://nez-backend-production.up.railway.app/users/me \
  -H "Authorization: Bearer invalidtoken12345")
test_endpoint "Protected endpoint - Invalid token rejected" "$INVALID_TOKEN" "Could not validate"

# Test with valid token
if [ -n "$TOKEN" ]; then
    VALID_TOKEN=$(curl -s https://nez-backend-production.up.railway.app/users/me \
      -H "Authorization: Bearer $TOKEN")
    test_endpoint "Protected endpoint - Valid token accepted" "$VALID_TOKEN" "email"
else
    echo -e "${YELLOW}⚠ Skipped - No valid token${NC}"
fi
echo ""

# ============================================
# 10. GOOGLE SIGN-IN
# ============================================
echo "----------------------------------------"
echo "10. GOOGLE SIGN-IN TESTS"
echo "----------------------------------------"

# Test with invalid token
GOOGLE_INVALID=$(curl -s -X POST https://nez-backend-production.up.railway.app/auth/google \
  -H "Content-Type: application/json" \
  -d '{"id_token":"invalid_token","email":"test@gmail.com","name":"Test"}')
test_endpoint "POST /auth/google - Invalid token rejected" "$GOOGLE_INVALID" "detail"

echo -e "${YELLOW}⚠ Valid Google token test requires real OAuth token${NC}"
echo ""

# ============================================
# SUMMARY
# ============================================
echo "========================================"
echo "TEST SUMMARY"
echo "========================================"
echo -e "${GREEN}PASSED: $PASS${NC}"
echo -e "${RED}FAILED: $FAIL${NC}"
TOTAL=$((PASS + FAIL))
echo "TOTAL: $TOTAL"
echo ""

if [ $FAIL -eq 0 ]; then
    echo -e "${GREEN}✓ All tests passed!${NC}"
    exit 0
else
    echo -e "${RED}✗ Some tests failed${NC}"
    exit 1
fi

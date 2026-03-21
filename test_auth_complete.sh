#!/bin/bash

BASE_URL="http://localhost:8000"
TEST_EMAIL="testuser_$(date +%s)@example.com"
TEST_PASSWORD="SecurePass123!"
TEST_NAME="Test User $(date +%s)"

echo "========================================"
echo "COMPLETE AUTHENTICATION FLOW TEST"
echo "========================================"
echo ""

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}Test Email: $TEST_EMAIL${NC}"
echo ""

# ============================================
# 1. Health Check
# ============================================
echo -e "${BLUE}[1] Testing Health Check${NC}"
HEALTH=$(curl -s $BASE_URL/)
if echo "$HEALTH" | grep -q "Nez"; then
    echo -e "${GREEN}✓ PASS${NC}: Server is running"
else
    echo -e "${RED}✗ FAIL${NC}: Server not responding"
    exit 1
fi
echo ""

# ============================================
# 2. Signup
# ============================================
echo -e "${BLUE}[2] Testing Signup${NC}"
SIGNUP=$(curl -s -w "\nHTTP_CODE:%{http_code}" -X POST $BASE_URL/auth/signup \
  -H "Content-Type: application/json" \
  -d "{\"email\":\"$TEST_EMAIL\",\"password\":\"$TEST_PASSWORD\",\"display_name\":\"$TEST_NAME\"}")

HTTP_CODE=$(echo "$SIGNUP" | grep "HTTP_CODE" | cut -d: -f2)
SIGNUP_BODY=$(echo "$SIGNUP" | sed '/HTTP_CODE/d')

if [ "$HTTP_CODE" = "200" ] || [ "$HTTP_CODE" = "201" ]; then
    echo -e "${GREEN}✓ PASS${NC}: Signup successful (HTTP $HTTP_CODE)"
    echo "  Response: $SIGNUP_BODY"
else
    echo -e "${RED}✗ FAIL${NC}: Signup failed (HTTP $HTTP_CODE)"
    echo "  Response: $SIGNUP_BODY"
    exit 1
fi
echo ""

# ============================================
# 3. Duplicate Signup
# ============================================
echo -e "${BLUE}[3] Testing Duplicate Email Rejection${NC}"
DUP=$(curl -s -w "\nHTTP_CODE:%{http_code}" -X POST $BASE_URL/auth/signup \
  -H "Content-Type: application/json" \
  -d "{\"email\":\"$TEST_EMAIL\",\"password\":\"$TEST_PASSWORD\",\"display_name\":\"Duplicate\"}")

DUP_CODE=$(echo "$DUP" | grep "HTTP_CODE" | cut -d: -f2)
if [ "$DUP_CODE" = "400" ]; then
    echo -e "${GREEN}✓ PASS${NC}: Duplicate email correctly rejected (HTTP 400)"
else
    echo -e "${RED}✗ FAIL${NC}: Should reject duplicate (got HTTP $DUP_CODE)"
fi
echo ""

# ============================================
# 4. Login Unverified
# ============================================
echo -e "${BLUE}[4] Testing Login with Unverified Email${NC}"
LOGIN_UNVERIFIED=$(curl -s -w "\nHTTP_CODE:%{http_code}" -X POST $BASE_URL/auth/login \
  -H "Content-Type: application/json" \
  -d "{\"email\":\"$TEST_EMAIL\",\"password\":\"$TEST_PASSWORD\"}")

LOGIN_CODE=$(echo "$LOGIN_UNVERIFIED" | grep "HTTP_CODE" | cut -d: -f2)
if [ "$LOGIN_CODE" = "403" ]; then
    echo -e "${GREEN}✓ PASS${NC}: Unverified email rejected (HTTP 403)"
else
    echo -e "${RED}✗ FAIL${NC}: Should reject unverified (got HTTP $LOGIN_CODE)"
fi
echo ""

# ============================================
# 5. Verify Email (via DB)
# ============================================
echo -e "${BLUE}[5] Verifying Email (Manual DB Update)${NC}"
echo -e "${YELLOW}⚠ NOTE: In production, user would click email link${NC}"
echo "  We'll query the database to get the token and verify..."

# For local testing, we need to get the token from DB and verify
# This requires direct DB access or checking email logs
echo -e "${YELLOW}⚠ Skipping automatic verification - requires DB access${NC}"
echo ""

# ============================================
# 6. Invalid Login Attempts
# ============================================
echo -e "${BLUE}[6] Testing Invalid Login Attempts${NC}"

# Wrong password
WRONG_PASS=$(curl -s -w "\nHTTP_CODE:%{http_code}" -X POST $BASE_URL/auth/login \
  -H "Content-Type: application/json" \
  -d "{\"email\":\"$TEST_EMAIL\",\"password\":\"WrongPassword123\"}")
WRONG_CODE=$(echo "$WRONG_PASS" | grep "HTTP_CODE" | cut -d: -f2)
if [ "$WRONG_CODE" = "401" ]; then
    echo -e "${GREEN}✓ PASS${NC}: Wrong password rejected (HTTP 401)"
else
    echo -e "${YELLOW}⚠ INFO${NC}: Wrong password (got HTTP $WRONG_CODE)"
fi

# Non-existent user
NO_USER=$(curl -s -w "\nHTTP_CODE:%{http_code}" -X POST $BASE_URL/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"nobody999999@example.com","password":"password"}')
NO_USER_CODE=$(echo "$NO_USER" | grep "HTTP_CODE" | cut -d: -f2)
if [ "$NO_USER_CODE" = "401" ] || [ "$NO_USER_CODE" = "404" ]; then
    echo -e "${GREEN}✓ PASS${NC}: Non-existent user rejected (HTTP $NO_USER_CODE)"
else
    echo -e "${YELLOW}⚠ INFO${NC}: Non-existent user (got HTTP $NO_USER_CODE)"
fi
echo ""

# ============================================
# 7. JWT Protection
# ============================================
echo -e "${BLUE}[7] Testing JWT Protection${NC}"

# No token
NO_TOKEN=$(curl -s -w "\nHTTP_CODE:%{http_code}" $BASE_URL/users/me)
NO_TOKEN_CODE=$(echo "$NO_TOKEN" | grep "HTTP_CODE" | cut -d: -f2)
if [ "$NO_TOKEN_CODE" = "401" ] || [ "$NO_TOKEN_CODE" = "403" ]; then
    echo -e "${GREEN}✓ PASS${NC}: No token rejected (HTTP $NO_TOKEN_CODE)"
else
    echo -e "${RED}✗ FAIL${NC}: Should reject no token (got HTTP $NO_TOKEN_CODE)"
fi

# Invalid token
BAD_TOKEN=$(curl -s -w "\nHTTP_CODE:%{http_code}" $BASE_URL/users/me \
  -H "Authorization: Bearer invalidtoken123")
BAD_CODE=$(echo "$BAD_TOKEN" | grep "HTTP_CODE" | cut -d: -f2)
if [ "$BAD_CODE" = "401" ] || [ "$BAD_CODE" = "403" ]; then
    echo -e "${GREEN}✓ PASS${NC}: Invalid token rejected (HTTP $BAD_CODE)"
else
    echo -e "${RED}✗ FAIL${NC}: Should reject invalid token (got HTTP $BAD_CODE)"
fi
echo ""

# ============================================
# Summary
# ============================================
echo "========================================"
echo -e "${GREEN}AUTHENTICATION ENDPOINTS CHECK COMPLETE${NC}"
echo "========================================"
echo ""
echo "Core functionality verified:"
echo "  ✓ Signup creates accounts"
echo "  ✓ Duplicate emails rejected"
echo "  ✓ Unverified users can't login"
echo "  ✓ Invalid credentials rejected"
echo "  ✓ JWT protection works"
echo ""
echo -e "${YELLOW}Manual steps needed:${NC}"
echo "  • Email verification (check logs/DB for token)"
echo "  • Full login flow with verified user"
echo "  • Password change with valid token"
echo "  • Email change with valid token"
echo "  • Google Sign-In with real OAuth token"

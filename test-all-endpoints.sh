#!/bin/bash

# Test All Critical Endpoints Script
# This script tests all the endpoints that you reported as failing

echo "🧪 Testing Zaryah Backend Endpoints"
echo "====================================="
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Backend URL
BASE_URL="http://localhost:3000"

# Test 1: Backend Health
echo "1️⃣  Testing Backend Health..."
HEALTH_RESPONSE=$(curl -s "$BASE_URL/health")
if [[ $HEALTH_RESPONSE == *'"status":"ok"'* ]]; then
    echo -e "${GREEN}✅ Backend is running${NC}"
    echo "   Response: $HEALTH_RESPONSE"
else
    echo -e "${RED}❌ Backend is NOT running${NC}"
    echo "   Please start backend with: cd backend && node server.js"
    exit 1
fi
echo ""

# Test 2: Login and Get JWT Token
echo "2️⃣  Testing Login..."
LOGIN_RESPONSE=$(curl -s -X POST "$BASE_URL/api/auth/login" \
  -H "Content-Type: application/json" \
  -d '{"email": "ismaielshakir900@gmail.com", "password": "password123"}')

if [[ $LOGIN_RESPONSE == *'"token"'* ]]; then
    echo -e "${GREEN}✅ Login successful${NC}"
    TOKEN=$(echo $LOGIN_RESPONSE | grep -o '"token":"[^"]*' | sed 's/"token":"//')
    echo "   Token: ${TOKEN:0:50}..."
else
    echo -e "${RED}❌ Login failed${NC}"
    echo "   Response: $LOGIN_RESPONSE"
    echo ""
    echo "   💡 Try creating a test user first:"
    echo "   cd backend && node create_main_user.js"
    exit 1
fi
echo ""

# Test 3: Finance Dashboard
echo "3️⃣  Testing Finance Dashboard..."
FINANCE_RESPONSE=$(curl -s "$BASE_URL/api/finance/dashboard" \
  -H "Authorization: Bearer $TOKEN")

if [[ $FINANCE_RESPONSE == *'"indices"'* ]] && [[ $FINANCE_RESPONSE == *'"popularStocks"'* ]]; then
    echo -e "${GREEN}✅ Finance dashboard working${NC}"
    echo "   Has indices: $(echo $FINANCE_RESPONSE | grep -o '"indices":\[[^]]*' | wc -c) chars"
    echo "   Has stocks: $(echo $FINANCE_RESPONSE | grep -o '"popularStocks":\[[^]]*' | wc -c) chars"
else
    echo -e "${RED}❌ Finance dashboard failed${NC}"
    echo "   Response: ${FINANCE_RESPONSE:0:200}..."
    echo ""
    echo "   💡 Check backend logs for TwelveData API errors"
fi
echo ""

# Test 4: Get Current Profile
echo "4️⃣  Testing Get Current Profile..."
PROFILE_RESPONSE=$(curl -s "$BASE_URL/api/profile/me" \
  -H "Authorization: Bearer $TOKEN")

if [[ $PROFILE_RESPONSE == *'"profile"'* ]]; then
    echo -e "${GREEN}✅ Profile fetch working${NC}"
    PROFILE_ID=$(echo $PROFILE_RESPONSE | grep -o '"id":"[^"]*' | head -1 | sed 's/"id":"//')
    echo "   Profile ID: $PROFILE_ID"
else
    echo -e "${RED}❌ Profile fetch failed${NC}"
    echo "   Response: $PROFILE_RESPONSE"
fi
echo ""

# Test 5: Update Profile (without image)
echo "5️⃣  Testing Profile Update (text only)..."
UPDATE_RESPONSE=$(curl -s -X PUT "$BASE_URL/api/profile/me" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"name": "Test User", "bio": "Testing profile update", "city": "Mumbai"}')

if [[ $UPDATE_RESPONSE == *'"message":"Profile updated successfully"'* ]]; then
    echo -e "${GREEN}✅ Profile update working${NC}"
    echo "   Update successful"
else
    echo -e "${RED}❌ Profile update failed${NC}"
    echo "   Response: ${UPDATE_RESPONSE:0:300}..."
fi
echo ""

# Test 6: Profile Picture Upload (small base64 image)
echo "6️⃣  Testing Profile Picture Upload..."
# Create a tiny 1x1 transparent PNG as base64
TINY_PNG="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg=="

PFP_RESPONSE=$(curl -s -X PUT "$BASE_URL/api/profile/me" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d "{\"profilePictureUrl\": \"$TINY_PNG\", \"profilePicture\": \"$TINY_PNG\"}")

if [[ $PFP_RESPONSE == *'"message":"Profile updated successfully"'* ]]; then
    echo -e "${GREEN}✅ Profile picture upload working${NC}"
    echo "   Image upload successful"
else
    echo -e "${RED}❌ Profile picture upload failed${NC}"
    echo "   Response: ${PFP_RESPONSE:0:300}..."
fi
echo ""

# Test 7: Get All Users (for add friend)
echo "7️⃣  Testing Get All Users..."
USERS_RESPONSE=$(curl -s "$BASE_URL/api/users" \
  -H "Authorization: Bearer $TOKEN")

if [[ $USERS_RESPONSE == *'"users"'* ]]; then
    echo -e "${GREEN}✅ Get users working${NC}"
    # Extract first user ID that's not the current user
    TARGET_USER_ID=$(echo $USERS_RESPONSE | grep -o '"id":"[^"]*' | grep -v "$PROFILE_ID" | head -1 | sed 's/"id":"//')
    echo "   Found target user: $TARGET_USER_ID"
else
    echo -e "${RED}❌ Get users failed${NC}"
    echo "   Response: ${USERS_RESPONSE:0:200}..."
    TARGET_USER_ID=""
fi
echo ""

# Test 8: Add Friend (Send Connection Request)
if [ -n "$TARGET_USER_ID" ]; then
    echo "8️⃣  Testing Add Friend (Connection Request)..."
    CONNECTION_RESPONSE=$(curl -s -X POST "$BASE_URL/api/connections" \
      -H "Authorization: Bearer $TOKEN" \
      -H "Content-Type: application/json" \
      -d "{\"targetUserId\": \"$TARGET_USER_ID\"}")

    if [[ $CONNECTION_RESPONSE == *'"message"'* ]] || [[ $CONNECTION_RESPONSE == *'"connection"'* ]]; then
        echo -e "${GREEN}✅ Add friend working${NC}"
        echo "   Connection request sent"
    elif [[ $CONNECTION_RESPONSE == *'"Connection already exists"'* ]]; then
        echo -e "${YELLOW}⚠️  Connection already exists (this is okay)${NC}"
        echo "   Connection was previously created"
    else
        echo -e "${RED}❌ Add friend failed${NC}"
        echo "   Response: ${CONNECTION_RESPONSE:0:300}..."
    fi
else
    echo "8️⃣  Skipping Add Friend test (no target user found)"
fi
echo ""

# Summary
echo "====================================="
echo "📊 Test Summary"
echo "====================================="
echo ""
echo "✅ Passed tests will show in green above"
echo "❌ Failed tests will show in red above"
echo ""
echo "💡 Next Steps:"
echo "   1. If backend health failed: Start backend with 'node backend/server.js'"
echo "   2. If login failed: Run 'node backend/create_main_user.js'"
echo "   3. If finance failed: Check backend logs for TwelveData API errors"
echo "   4. If profile/connections failed: Check backend logs for detailed errors"
echo ""
echo "   Then in Flutter:"
echo "   - Stop the app completely (press 'q' or click stop)"
echo "   - Run: cd flutter-app && flutter run"
echo "   - Test the features in the app"
echo ""

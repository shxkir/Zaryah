#!/bin/bash

echo "Testing finance with Alice's account..."
echo ""

# Login as Alice
ALICE_TOKEN=$(curl -s -X POST http://localhost:3000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email": "alice.smith@example.com", "password": "password123"}' \
  | python3 -c "import sys, json; print(json.load(sys.stdin)['token'])" 2>/dev/null)

if [ -z "$ALICE_TOKEN" ]; then
    echo "❌ Failed to login as Alice"
    exit 1
fi

echo "✅ Logged in as Alice"
echo "Token: ${ALICE_TOKEN:0:50}..."
echo ""

# Test finance dashboard
echo "Fetching finance dashboard..."
RESPONSE=$(curl -s http://localhost:3000/api/finance/dashboard \
  -H "Authorization: Bearer $ALICE_TOKEN")

if [[ $RESPONSE == *'"indices"'* ]] && [[ $RESPONSE == *'"popularStocks"'* ]]; then
    echo "✅ Finance dashboard works for Alice!"
    echo ""
    echo "Response includes:"
    echo "$RESPONSE" | python3 -c "import sys, json; data=json.load(sys.stdin); print('  - Indices:', len(data.get('indices', [])), 'items'); print('  - Stocks:', len(data.get('popularStocks', [])), 'items'); print('  - Currencies:', len(data.get('currencies', [])), 'items'); print('  - Commodities:', len(data.get('commodities', [])), 'items')" 2>/dev/null
else
    echo "❌ Finance dashboard failed for Alice"
    echo "Response: ${RESPONSE:0:200}"
fi

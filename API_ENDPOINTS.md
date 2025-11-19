# Zaryah API Endpoints Reference

## Base URL
```
http://localhost:3000/api
```

---

## 🔐 Authentication Endpoints

### Sign Up
```http
POST /auth/signup
Content-Type: application/json

{
  "email": "user@example.com",
  "password": "password123",
  "name": "John Doe",
  "age": 25,
  "educationLevel": "Bachelor's",
  "occupation": "Student"
}

Response: 201 Created
{
  "token": "eyJhbGc...",
  "user": { ... },
  "profile": { ... }
}
```

### Login
```http
POST /auth/login
Content-Type: application/json

{
  "email": "user@example.com",
  "password": "password123"
}

Response: 200 OK
{
  "token": "eyJhbGc...",
  "user": { ... }
}
```

---

## 🏠 Housing Endpoints

### Get All Listings
```http
GET /housing
Query Parameters:
  - locality (optional): string
  - minPrice (optional): number
  - maxPrice (optional): number
  - propertyType (optional): apartment|house|villa|studio
  - bedrooms (optional): number

Response: 200 OK
{
  "listings": [
    {
      "id": "uuid",
      "title": "2 BHK Apartment",
      "monthlyPrice": 15000,
      "locality": "Anna Nagar",
      "fullAddress": "123 Main St, Chennai",
      "latitude": 13.0878,
      "longitude": 80.2785,
      "images": ["url1", "url2"],
      "contactInfo": "+91 1234567890",
      "bedrooms": 2,
      "bathrooms": 2,
      "squareFeet": 1200,
      "propertyType": "apartment",
      "amenities": ["Parking", "Gym"],
      "description": "Beautiful 2BHK...",
      "isActive": true,
      "createdAt": "2025-01-01T00:00:00Z",
      "user": {
        "profile": {
          "name": "Owner Name",
          "profilePicture": "url"
        }
      }
    }
  ]
}
```

### Search Listings
```http
GET /housing/search?query=chennai

Response: 200 OK
{
  "listings": [...],
  "count": 5
}
```

### Get Housing Statistics
```http
GET /housing/stats

Response: 200 OK
{
  "totalListings": 42,
  "listingsByLocality": [
    { "locality": "Anna Nagar", "_count": 15 },
    { "locality": "T Nagar", "_count": 10 }
  ],
  "averagePrice": 17500.50
}
```

### Get Single Listing
```http
GET /housing/:id

Response: 200 OK
{
  "listing": { ... }
}
```

### Create Listing (Requires Auth)
```http
POST /housing
Authorization: Bearer <token>
Content-Type: application/json

{
  "title": "2 BHK Apartment in Anna Nagar",
  "monthlyPrice": 15000,
  "locality": "Anna Nagar",
  "fullAddress": "123 Main Street, Anna Nagar, Chennai - 600040",
  "latitude": 13.0878,
  "longitude": 80.2785,
  "contactInfo": "+91 1234567890",
  "bedrooms": 2,
  "bathrooms": 2,
  "squareFeet": 1200,
  "propertyType": "apartment",
  "amenities": ["Parking", "Gym", "Security"],
  "description": "Spacious 2BHK apartment with modern amenities"
}

Response: 201 Created
{
  "listing": { ... },
  "message": "Housing listing created successfully"
}
```

### Update Listing (Requires Auth)
```http
PUT /housing/:id
Authorization: Bearer <token>
Content-Type: application/json

{
  "monthlyPrice": 16000,
  "isActive": true
}

Response: 200 OK
{
  "listing": { ... },
  "message": "Housing listing updated successfully"
}
```

### Delete Listing (Requires Auth)
```http
DELETE /housing/:id
Authorization: Bearer <token>

Response: 200 OK
{
  "message": "Housing listing deleted successfully"
}
```

### Get User's Listings
```http
GET /housing/user/:userId

Response: 200 OK
{
  "listings": [...]
}
```

---

## 💰 Finance Endpoints

### Get Stock Quote
```http
GET /finance/equity/:symbol
Example: /finance/equity/RELIANCE

Response: 200 OK
{
  "quote": {
    "symbol": "RELIANCE.NS",
    "price": 2456.30,
    "change": 12.50,
    "changePercent": "+0.51%",
    "volume": 5234567,
    "high": 2470.00,
    "low": 2445.00,
    "open": 2450.00,
    "previousClose": 2443.80,
    "exchange": "NSE"
  }
}
```

### Get Currency Rate
```http
GET /finance/currency/:pair
Example: /finance/currency/USDINR

Response: 200 OK
{
  "rate": {
    "from": "USD",
    "to": "INR",
    "rate": 83.25,
    "timestamp": "2025-01-15"
  }
}
```

### Get Commodity Price
```http
GET /finance/commodity/:name
Example: /finance/commodity/GOLD

Response: 200 OK
{
  "price": {
    "price": 62500,
    "currency": "INR",
    "unit": "per 10 grams",
    "change": 150,
    "changePercent": "+0.24%"
  }
}
```

### Search Stocks
```http
GET /finance/search/:query
Example: /finance/search/reliance

Response: 200 OK
{
  "results": [
    {
      "symbol": "RELIANCE.NS",
      "name": "Reliance Industries Limited",
      "type": "Equity",
      "region": "India",
      "currency": "INR"
    }
  ]
}
```

### Get Watchlist (Requires Auth)
```http
GET /finance/watchlist
Authorization: Bearer <token>

Response: 200 OK
{
  "watchlist": [
    {
      "id": "uuid",
      "userId": "user-id",
      "symbol": "RELIANCE",
      "assetType": "equity",
      "exchange": "NSE",
      "createdAt": "2025-01-01T00:00:00Z",
      "currentData": {
        "symbol": "RELIANCE.NS",
        "price": 2456.30,
        "change": 12.50,
        "changePercent": "+0.51%"
      }
    }
  ]
}
```

### Add to Watchlist (Requires Auth)
```http
POST /finance/watchlist
Authorization: Bearer <token>
Content-Type: application/json

{
  "symbol": "RELIANCE",
  "assetType": "equity",
  "exchange": "NSE"
}

Response: 201 Created
{
  "item": { ... },
  "message": "Added to watchlist"
}
```

### Remove from Watchlist (Requires Auth)
```http
DELETE /finance/watchlist/:id
Authorization: Bearer <token>

Response: 200 OK
{
  "message": "Removed from watchlist"
}
```

### Get Trending Stocks
```http
GET /finance/trending

Response: 200 OK
{
  "trending": [
    {
      "symbol": "RELIANCE.NS",
      "price": 2456.30,
      "change": 12.50,
      "changePercent": "+0.51%"
    },
    ...
  ]
}
```

---

## 🤖 Chatbot Endpoints

### Chat with AI (Requires Auth)
```http
POST /chatbot/chat
Authorization: Bearer <token>
Content-Type: application/json

{
  "message": "Show me houses in Chennai",
  "conversationHistory": [] // Optional
}

Response: 200 OK
{
  "message": "I found 5 housing listings in Chennai:\n\n1. 2 BHK Apartment in Anna Nagar - ₹15,000/month\n...",
  "functionCalls": [
    {
      "name": "get_housing_in_location",
      "result": [...]
    }
  ],
  "conversationHistory": [...]
}
```

**Supported Queries:**
- "Where is [username] located?"
- "Who lives in India?"
- "Show houses in Chennai"
- "How many housing listings are there?"
- "What is the USD to INR rate?"
- "Price of Reliance stock?"
- "Gold and silver prices?"

### Quick Query (Requires Auth)
```http
POST /chatbot/quick-query
Authorization: Bearer <token>
Content-Type: application/json

{
  "query": "houses in chennai"
}

Response: 200 OK
{
  "result": [...]
}
```

---

## 👤 Profile Endpoints (Existing)

### Get Current User Profile
```http
GET /profile
Authorization: Bearer <token>

Response: 200 OK
{
  "id": "uuid",
  "userId": "user-id",
  "name": "John Doe",
  "age": 25,
  "bio": "Description",
  "profilePicture": "base64 or url",
  "latitude": 13.0878,
  "longitude": 80.2785,
  "city": "Chennai",
  "country": "India",
  "locationPrivacy": "everyone"
}
```

### Update Profile (Requires Auth)
```http
PUT /profile
Authorization: Bearer <token>
Content-Type: application/json

{
  "bio": "Updated bio",
  "profilePicture": "data:image/jpeg;base64,...",
  "city": "Chennai",
  "country": "India",
  "latitude": 13.0878,
  "longitude": 80.2785
}

Response: 200 OK
{
  "profile": { ... },
  "message": "Profile updated successfully"
}
```

---

## 📋 Error Responses

### 400 Bad Request
```json
{
  "error": "Missing required fields"
}
```

### 401 Unauthorized
```json
{
  "error": "Access token required"
}
```

### 403 Forbidden
```json
{
  "error": "Not authorized to update this listing"
}
```

### 404 Not Found
```json
{
  "error": "Housing listing not found"
}
```

### 500 Internal Server Error
```json
{
  "error": "Failed to create housing listing",
  "details": "Error message"
}
```

---

## 🔒 Authentication Header Format

All authenticated endpoints require:
```http
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

Token obtained from `/auth/signup` or `/auth/login`

---

## 📊 Rate Limits

- Finance APIs: Limited by external providers (Alpha Vantage: 25/day free tier)
- Housing/Chatbot: No limits currently (implement as needed)

---

## 🧪 Testing Examples

### cURL Examples

**Create Housing Listing:**
```bash
curl -X POST http://localhost:3000/api/housing \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "title": "2 BHK Apartment",
    "monthlyPrice": 15000,
    "locality": "Anna Nagar",
    "fullAddress": "123 Main St, Chennai",
    "latitude": 13.0878,
    "longitude": 80.2785,
    "contactInfo": "+91 1234567890",
    "bedrooms": 2,
    "bathrooms": 2,
    "propertyType": "apartment"
  }'
```

**Get Stock Quote:**
```bash
curl http://localhost:3000/api/finance/equity/RELIANCE
```

**Chat with AI:**
```bash
curl -X POST http://localhost:3000/api/chatbot/chat \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"message": "Show houses in Chennai"}'
```

---

**For complete implementation details, see IMPLEMENTATION_GUIDE.md**

# 🚀 ZARYAH - QUICK REFERENCE GUIDE

## 📱 NEW FEATURES ADDED

### 1. Housing Feed
**Location:** Services → Housing tab
**What:** Shows newest housing listings in your area
**How to Use:**
- Pull down to refresh
- Tap any listing to see full details
- Automatically filters by your city

**Backend API:**
```http
GET /api/housing/feed?city=Mumbai&limit=20&offset=0
```

---

### 2. Smart Geocoding
**Location:** Edit Profile → Location section
**What:** Auto-fills city/state/country when you type
**How to Use:**
- Type city name → Automatically gets coordinates
- Pick location on map → Automatically gets address
- All three fields (city, state, country) filled automatically

**Backend APIs:**
```http
POST /api/geocode/address
Body: { "address": "Mumbai, India" }

POST /api/geocode/reverse
Body: { "latitude": 19.076, "longitude": 72.877 }
```

---

## 🔧 FIXED FEATURES

### 1. Add Friend (Connection Requests)
**Status:** ✅ Now Working
**What Was Wrong:** 500 Internal Server Error
**What's Fixed:** Prisma database connection management
**How to Use:** Tap "Add Friend" on any user profile

---

### 2. Profile Picture Upload
**Status:** ✅ Now Working Globally
**What Was Wrong:** Picture not showing across screens
**What's Fixed:** Syncs across all screens instantly
**How to Use:**
1. Edit Profile → Tap avatar
2. Select image
3. Save
4. Picture updates everywhere (communities, messages, map)

---

### 3. Finance Section
**Status:** ✅ Live Data Working
**What Was Wrong:** 404 errors for Indian stocks
**What's Fixed:** Multi-source fallback system
**How to Use:** Services → Finance tab
**Shows:** NIFTY 50, SENSEX, NIFTY BANK, top stocks

---

## 🎨 THEME GUIDE

### Color Codes
```
Main Background:  #0A0A0A (matte black)
Cards:            #1A1A1A (dark gray)
Primary Gold:     #FFD700 (bright gold)
Soft Gold:        #F5C242 (warm gold)
Text:             #FFFFFF (white)
Muted Text:       #B3FFFFFF (70% white)
```

### Components Available
- `GoldCard` - Cards with gold border
- `GoldButton` - Action buttons
- `GoldTextField` - Input fields
- `GoldAppBar` - App bars
- `GoldAvatarFrame` - Profile pictures
- `GoldSectionHeader` - Section titles

---

## 📡 API ENDPOINTS QUICK REFERENCE

### Profile & Authentication
```http
POST /api/auth/signup          # Register
POST /api/auth/login           # Login
GET  /api/profile/me           # Get current user
PUT  /api/profile/me           # Update profile
PUT  /api/profile/location     # Update location
```

### Connections (Friends)
```http
POST /api/connections                  # Send request
GET  /api/connections                  # Get accepted friends
GET  /api/connections/pending          # Get pending requests
PUT  /api/connections/:id              # Accept/reject
DELETE /api/connections/:id            # Remove connection
GET  /api/connections/suggested        # Get suggestions
```

### Housing
```http
GET  /api/housing                  # List all
GET  /api/housing/feed             # Latest listings
GET  /api/housing/:id              # Single listing
POST /api/housing                  # Create listing
PUT  /api/housing/:id              # Update listing
DELETE /api/housing/:id            # Delete listing
```

### Finance
```http
GET /api/finance/equity/:symbol        # Stock quote (e.g., RELIANCE.NS)
GET /api/finance/currency/:pair        # Currency rate (e.g., USDINR)
GET /api/finance/commodity/:name       # Commodity price
GET /api/finance/indices               # Market indices
GET /api/finance/market-overview       # Full market data
```

### Geocoding
```http
POST /api/geocode/address              # Address → Coordinates
POST /api/geocode/reverse              # Coordinates → Address
```

### Messages
```http
POST /api/messages/send                # Send message
GET  /api/messages/conversations       # List conversations
GET  /api/messages/:partnerId          # Get chat history
```

### Community Posts
```http
GET  /api/posts                        # List all posts
POST /api/posts                        # Create post
GET  /api/posts/:id                    # Single post
DELETE /api/posts/:id                  # Delete post
GET  /api/posts/map                    # Posts with location
```

---

## 🗄️ DATABASE FIELDS

### Profile Model
```javascript
{
  name: string,
  age: number,
  bio: string,
  occupation: string,
  educationLevel: string,
  profilePicture: string,          // Base64 or URL
  profilePictureUrl: string,       // Synced upload URL
  city: string,
  state: string,                   // NEW!
  country: string,
  latitude: float,
  longitude: float,
  locationPrivacy: string,         // "everyone", "connections", "private"
  subjects: string[],
  learningGoals: string,
  // ... more learning fields
}
```

### Housing Listing Model
```javascript
{
  title: string,
  monthlyPrice: float,
  locality: string,
  fullAddress: string,
  latitude: float,
  longitude: float,
  images: string[],                // Array of URLs
  contactInfo: string,
  bedrooms: number,
  bathrooms: number,
  squareFeet: number,
  propertyType: string,            // "apartment", "house", "villa"
  amenities: string[],
  description: string,
  isActive: boolean,
  createdAt: datetime,
}
```

---

## 🐛 TROUBLESHOOTING

### Profile Picture Not Showing?
1. Check both `profilePicture` and `profilePictureUrl` are set
2. Re-save profile to sync fields
3. Clear app cache and restart

### Finance Data Shows Error?
- It's using mock data fallback
- This is intentional for development
- Add `ALPHA_VANTAGE_API_KEY` to `.env` for real data

### Add Friend Gives 500 Error?
- Fixed! Restart backend server
- Clear any old Prisma connections
- Make sure database is running

### Location Not Auto-Filling?
- Check internet connection
- Geocoding uses OpenStreetMap (free)
- If offline, manually enter city/country

### Map Not Loading?
- Check `GOOGLE_MAPS_API_KEY` in environment
- Or use default OpenStreetMap tiles
- Map markers still work without satellite view

---

## 🚦 RUNNING THE APP

### Backend
```bash
cd backend
npm install
npm start
```
**Runs on:** http://localhost:3000

### Flutter
```bash
cd flutter-app
flutter pub get
flutter run
```
**Connects to:** http://localhost:3000/api (Android uses 10.0.2.2)

---

## 🔐 ENVIRONMENT VARIABLES

### Required
```env
DATABASE_URL="postgresql://user:pass@localhost:5432/zaryah"
JWT_SECRET="your-secret-key"
```

### Optional (Enhances Features)
```env
OPENAI_API_KEY="sk-..."              # For chatbot
ALPHA_VANTAGE_API_KEY="..."          # For real stock data
GOOGLE_MAPS_API_KEY="..."            # For satellite map
PINECONE_API_KEY="..."               # For user search
```

---

## 📞 SUPPORT

### Logs to Check
- Backend: Console output when running `npm start`
- Flutter: Console in IDE when running `flutter run`
- Database: Check Prisma Studio (`npx prisma studio`)

### Common Solutions
1. **Connection Errors:** Restart backend server
2. **Database Errors:** Run `npx prisma migrate deploy`
3. **Flutter Build Errors:** Run `flutter clean && flutter pub get`
4. **API Errors:** Check backend logs for stack trace

---

## ✅ TESTING CHECKLIST

### Profile
- [ ] Upload profile picture
- [ ] Verify picture shows in all screens
- [ ] Update location with city/state/country
- [ ] Check map marker updates

### Connections
- [ ] Send friend request
- [ ] Accept/reject requests
- [ ] View friends list

### Housing
- [ ] Create new listing
- [ ] View housing feed
- [ ] Tap listing for details
- [ ] Pull to refresh feed

### Finance
- [ ] View market indices
- [ ] Check stock prices
- [ ] Verify price changes (red/green)

### Messages
- [ ] Send message to friend
- [ ] Receive and read messages
- [ ] Check unread count

---

**Last Updated:** November 19, 2025
**Version:** 1.0 - All Critical Fixes Complete

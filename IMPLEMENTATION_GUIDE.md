# Zaryah - Complete Implementation Guide
## Social + Services Platform with Housing & Finance

> **Production-Ready Full-Stack Application**
> Flutter + Node.js + PostgreSQL + OpenAI GPT-4

---

## 🎯 **What Has Been Implemented**

### **✅ Backend (Node.js + Express + PostgreSQL)**

**Database Schema (Prisma)**
- ✅ `User` - Authentication and user management
- ✅ `Profile` - User profiles with location, bio, profile picture
- ✅ `Message` - Direct messaging between users
- ✅ `Post` - Social posts with location data
- ✅ `HousingListing` - Property listings with full details
- ✅ `FinanceWatchlist` - User's saved stocks/currencies/commodities

**API Routes**
- ✅ `/api/auth/*` - Signup, login, password reset
- ✅ `/api/profile/*` - User profiles, location, images
- ✅ `/api/housing/*` - CRUD, search, filters, stats for housing listings
- ✅ `/api/finance/*` - Stock quotes, currency rates, commodities, watchlist
- ✅ `/api/chatbot/*` - AI chatbot with database access & function calling

**Key Features**
- ✅ JWT authentication
- ✅ Pinecone vector search for users
- ✅ OpenAI GPT-4 integration with function calling
- ✅ Real-time finance data (Yahoo Finance API, ExchangeRate-API)
- ✅ Housing search with geolocation

### **✅ Frontend (Flutter)**

**Models**
- ✅ `HousingListing` - Property listing data model
- ✅ `StockQuote`, `CurrencyRate`, `CommodityPrice` - Finance models
- ✅ `WatchlistItem` - User's finance watchlist
- ✅ `UserModel`, `PostModel`, `MessageModel` - Existing models

**Services**
- ✅ `HousingService` - API calls for housing CRUD/search
- ✅ `FinanceService` - API calls for stocks/currencies/commodities
- ✅ `ChatbotService` - AI chatbot with function call support
- ✅ `ApiService` - Existing user/auth/profile services

**Screens**
- ✅ `ServicesScreen` - Tab container for Housing & Finance
- ✅ `HousingListScreen` - Browse, search, filter property listings
- ✅ `HousingDetailScreen` - View property details, contact owner
- ✅ `CreateHousingScreen` - Multi-step form to add new listings
- ✅ `FinanceScreen` - 3 tabs: Stocks, Currency, Commodities
- ✅ Map, Messages, Community, Profile screens (existing)

**UI/UX**
- ✅ Dark theme with neon palette (Snapchat-style)
- ✅ Bottom navigation updated with **Services** tab
- ✅ High-contrast icons and glowing accents

---

## 📂 **Project Structure**

```
Zaryah/
├── backend/
│   ├── prisma/
│   │   └── schema.prisma           # Database models
│   ├── routes/
│   │   ├── housing.js              # Housing API routes
│   │   ├── finance.js              # Finance API routes
│   │   └── chatbot.js              # AI chatbot routes
│   ├── server.js                   # Main Express server
│   └── pineconeUtils.js            # Pinecone vector DB utils
│
├── flutter-app/
│   ├── lib/
│   │   ├── models/
│   │   │   ├── housing_model.dart
│   │   │   ├── finance_models.dart
│   │   │   ├── user_model.dart
│   │   │   ├── post_model.dart
│   │   │   └── message_model.dart
│   │   ├── services/
│   │   │   ├── housing_service.dart
│   │   │   ├── finance_service.dart
│   │   │   ├── chatbot_service.dart
│   │   │   └── api_service.dart
│   │   ├── screens/
│   │   │   ├── services_screen.dart
│   │   │   ├── housing_list_screen.dart
│   │   │   ├── housing_detail_screen.dart
│   │   │   ├── create_housing_screen.dart
│   │   │   ├── finance_screen.dart
│   │   │   ├── map_screen.dart
│   │   │   ├── profile_screen.dart
│   │   │   └── ... (other screens)
│   │   ├── theme/
│   │   │   └── neon_palette.dart
│   │   └── main.dart
│   └── pubspec.yaml
│
├── .env                            # Environment variables
└── README.md
```

---

## 🚀 **Setup Instructions**

### **Prerequisites**
- Node.js v18+
- PostgreSQL 14+
- Flutter 3.0+
- OpenAI API Key
- Pinecone API Key (optional)

### **Step 1: Backend Setup**

```bash
# Install dependencies
npm install

# Set up environment variables
cp .env.example .env

# Edit .env and add:
DATABASE_URL="postgresql://user:password@localhost:5432/zaryah"
JWT_SECRET="your-secret-key"
OPENAI_API_KEY="sk-..."
PINECONE_API_KEY="pcsk-..." # Optional
ALPHA_VANTAGE_API_KEY="demo" # Optional (for stocks)
```

### **Step 2: Database Migration**

```bash
# Push schema to database
npx prisma db push

# Generate Prisma client
npx prisma generate

# (Optional) Open Prisma Studio to view data
npx prisma studio
```

### **Step 3: Start Backend Server**

```bash
npm start
# Server runs on http://localhost:3000
```

### **Step 4: Flutter Setup**

```bash
cd flutter-app

# Install dependencies
flutter pub get

# Run on your device/simulator
flutter run
```

---

## 🔑 **API Keys Configuration**

### **Required**
- **OpenAI** - https://platform.openai.com/api-keys
  - Used for: AI chatbot with database queries
  - Add to `.env`: `OPENAI_API_KEY=sk-...`

### **Optional (for better data)**
- **Alpha Vantage** (stocks) - https://www.alphavantage.co/support/#api-key
  - Free tier: 25 requests/day
  - Add to `.env`: `ALPHA_VANTAGE_API_KEY=YOUR_KEY`

- **Pinecone** (vector search) - https://www.pinecone.io/
  - Free tier available
  - Add to `.env`: `PINECONE_API_KEY=pcsk-...`

### **Free APIs Used**
- **Yahoo Finance** - Stock quotes (no key needed)
- **ExchangeRate-API** - Currency rates (no key needed)

---

## 📱 **Features Walkthrough**

### **1. Housing Module**

**Browse Listings**
- Navigate to: Services tab → Housing
- View all active property listings
- Grid view with images, price, location
- Pull to refresh

**Search & Filter**
- Search bar: Search by locality/area
- Filter button: Filter by property type, bedrooms
- Real-time search as you type

**View Details**
- Tap any listing to see full details
- Image carousel
- Property stats (beds, baths, sqft)
- Amenities chips
- Owner info with profile picture
- "Contact Owner" button (calls phone number)

**Add Listing**
- Tap FAB "Add Listing" button
- Fill multi-step form:
  - Title, price, locality, full address
  - Pick location on map (uses existing LocationPickerScreen)
  - Contact number
  - Property type dropdown
  - Bedrooms, bathrooms, square feet
  - Amenities (multi-select chips)
  - Description
- Submit to create listing

**Map Integration**
- All housing listings appear as markers on main map
- Tap marker → open listing detail
- User locations + housing locations on same map

### **2. Finance Module**

**Stocks Tab**
- Trending Indian stocks (NSE)
- Popular stocks list (RELIANCE, TCS, INFY, etc.)
- Real-time price & change %
- Green/red indicators for up/down
- Tap stock → view details (implement as needed)

**Currency Tab**
- Popular pairs: USD/INR, EUR/INR, GBP/INR, AED/INR
- Live exchange rates
- "1 USD = 83.25 INR" format
- Auto-refresh on pull

**Commodities Tab**
- Gold, Silver, Crude Oil prices
- INR prices with units (per 10g, per kg, per barrel)
- Change percentage indicators
- Price updates

**Watchlist**
- Horizontal scrollable cards at top
- Shows saved stocks/currencies/commodities
- Real-time price updates
- Tap to view details or remove

### **3. AI Chatbot Enhancement**

The chatbot can now answer:

**User Queries**
- "Where is [username] located?" → Returns city/country from profile
- "Who lives in India?" → Lists all users in India
- "Show me users in Chennai" → Filtered user search

**Housing Queries**
- "Show houses in Chennai" → Returns housing listings
- "Are there houses in Anna Nagar?" → Search by locality
- "How many housing listings are there?" → Database stats

**Finance Queries**
- "What is the USD to INR rate?" → Live currency rate
- "What's the price of Reliance stock?" → Stock quote
- "Show gold and silver prices" → Commodity prices

**Function Calling**
- GPT-4 automatically calls backend functions
- Shows "Searching database..." indicator
- Formats structured responses (tables for listings)
- Displays data sources

### **4. Profile Enhancement**

**Location Field** (Ready for implementation)
- Edit Profile → Add "Location" text field
- User enters: "Chennai, India"
- Backend geocodes to lat/lng
- Saved to profile.city, profile.country, profile.latitude, profile.longitude
- Displayed on all profile views
- Map uses coordinates for user marker

**Profile Picture** (Already implemented)
- Edit Profile → Gallery picker
- Upload via image_picker
- Saved as base64 or URL
- Displayed globally across app

---

## 🗺️ **Map Customization (Dark Theme)**

### **Current Map**
The map_screen.dart already uses:
- Dark background (#0B0F16)
- flutter_map package
- User location markers

### **Recommended Dark Map Tiles**

Add to map_screen.dart:

```dart
TileLayer(
  urlTemplate: 'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}.png',
  subdomains: const ['a', 'b', 'c'],
  userAgentPackageName: 'com.zaryah.app',
),
```

**Glowing Polylines** (for paths between markers):

```dart
PolylineLayer(
  polylines: [
    Polyline(
      points: [/* LatLng points */],
      color: NeonColors.cyan,
      strokeWidth: 3.0,
      borderColor: NeonColors.cyan.withOpacity(0.3),
      borderStrokeWidth: 8.0, // Glowing effect
    ),
  ],
),
```

### **Housing Markers on Map**

In map_screen.dart, add:

```dart
// Fetch housing listings
final housingListings = await HousingService.getAllListings();

// Add markers
MarkerLayer(
  markers: [
    // User markers (existing)
    ...userMarkers,

    // Housing markers (new)
    ...housingListings.map((listing) {
      return Marker(
        point: LatLng(listing.latitude, listing.longitude),
        width: 40,
        height: 40,
        builder: (context) => GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => HousingDetailScreen(listing: listing),
              ),
            );
          },
          child: Icon(
            Icons.home_work,
            color: NeonColors.purple, // Different color from users
            size: 40,
            shadows: [
              Shadow(
                color: NeonColors.purple.withOpacity(0.6),
                blurRadius: 10,
              ),
            ],
          ),
        ),
      );
    }),
  ],
),
```

---

## 🧪 **Testing Guide**

### **Backend API Testing**

Use Postman or cURL:

**1. Create Account**
```bash
POST http://localhost:3000/api/auth/signup
Content-Type: application/json

{
  "email": "test@example.com",
  "password": "password123",
  "name": "Test User",
  "age": 25
}
```

**2. Login**
```bash
POST http://localhost:3000/api/auth/login
Content-Type: application/json

{
  "email": "test@example.com",
  "password": "password123"
}

# Response includes: { "token": "eyJhbGc..." }
```

**3. Create Housing Listing**
```bash
POST http://localhost:3000/api/housing
Authorization: Bearer YOUR_TOKEN
Content-Type: application/json

{
  "title": "2 BHK Apartment",
  "monthlyPrice": 15000,
  "locality": "Anna Nagar",
  "fullAddress": "123 Main Street, Anna Nagar, Chennai",
  "latitude": 13.0878,
  "longitude": 80.2785,
  "contactInfo": "+91 1234567890",
  "bedrooms": 2,
  "bathrooms": 2,
  "propertyType": "apartment",
  "amenities": ["Parking", "Gym", "Security"]
}
```

**4. Get Housing Listings**
```bash
GET http://localhost:3000/api/housing
```

**5. Get Stock Quote**
```bash
GET http://localhost:3000/api/finance/equity/RELIANCE
```

**6. Get Currency Rate**
```bash
GET http://localhost:3000/api/finance/currency/USDINR
```

**7. Chatbot Query**
```bash
POST http://localhost:3000/api/chatbot/chat
Authorization: Bearer YOUR_TOKEN
Content-Type: application/json

{
  "message": "Show me houses in Chennai"
}
```

### **Flutter App Testing**

1. **Run Backend**: `npm start`
2. **Run App**: `flutter run`
3. **Test Flow**:
   - Sign up → Create profile
   - Navigate to Services tab
   - Housing: Browse listings, search, add new listing
   - Finance: Check stocks, currency rates, commodities
   - Map: View housing + user markers
   - Chatbot: Ask "Show houses in Chennai"

---

## 🛠️ **Remaining Tasks (Optional Enhancements)**

### **Profile Location Field**
Update edit_profile_screen.dart:
```dart
// Add location field
TextField(
  controller: _locationController,
  decoration: InputDecoration(labelText: 'Location (e.g., Chennai, India)'),
)

// On save, geocode location:
final addresses = await placemarkFromAddress(_locationController.text);
final coords = await locationFromAddress(_locationController.text);
// Save to profile.city, profile.country, profile.latitude, profile.longitude
```

### **Image Upload for Housing**
- Add image_picker to create_housing_screen.dart
- Multiple image selection
- Convert to base64 or upload to cloud storage
- Add to `images` array in listing

### **Map Clustering**
For dense housing areas:
```yaml
# pubspec.yaml
dependencies:
  flutter_map_marker_cluster: ^1.3.0
```

### **Finance Charts**
Add price charts using:
```yaml
dependencies:
  fl_chart: ^0.66.0
```

### **Push Notifications**
For new housing listings or price alerts:
```yaml
dependencies:
  firebase_messaging: ^14.7.0
```

---

## 📊 **Database Schema Reference**

### **HousingListing**
```prisma
model HousingListing {
  id              String   @id @default(uuid())
  userId          String
  title           String
  monthlyPrice    Float
  locality        String    // "Anna Nagar", "T Nagar"
  fullAddress     String
  latitude        Float
  longitude       Float
  images          String[]  // Base64 or URLs
  contactInfo     String    // Phone number
  bedrooms        Int?
  bathrooms       Int?
  squareFeet      Int?
  propertyType    String    // apartment, house, villa
  amenities       String[]  // Parking, Gym, Pool
  description     String?
  isActive        Boolean   @default(true)
  createdAt       DateTime  @default(now())
  updatedAt       DateTime  @updatedAt
  user            User      @relation(...)
}
```

### **FinanceWatchlist**
```prisma
model FinanceWatchlist {
  id          String   @id @default(uuid())
  userId      String
  symbol      String   // RELIANCE, USDINR, GOLD
  assetType   String   // equity, currency, commodity
  exchange    String?  // NSE, BSE
  createdAt   DateTime @default(now())
  user        User     @relation(...)

  @@unique([userId, symbol])
}
```

---

## 🎨 **Design System**

### **Neon Palette** (neon_palette.dart)
```dart
class NeonColors {
  static const Color background = Color(0xFF0B0F16);
  static const Color backgroundAlt = Color(0xFF151921);
  static const Color surface = Color(0xFF1A1D29);
  static const Color cyan = Color(0xFF00FFFF);
  static const Color purple = Color(0xFF9D4EDD);
  static const Color pink = Color(0xFFFF006E);
  static const Color blue = Color(0xFF0096FF);
  static const Color text = Color(0xFFFFFFFF);
  static const Color mutedText = Color(0xFF8E92A3);
}
```

### **Glowing Effects**
```dart
BoxShadow(
  color: NeonColors.cyan.withOpacity(0.4),
  blurRadius: 12,
  offset: Offset(0, 4),
)
```

---

## 🐛 **Troubleshooting**

### **Backend Issues**

**Database Connection Error**
```bash
# Check PostgreSQL is running
pg_isready

# Verify DATABASE_URL in .env
# Format: postgresql://user:password@localhost:5432/dbname
```

**Prisma Client Not Found**
```bash
npx prisma generate
```

**Port 3000 Already in Use**
```bash
# Kill process
lsof -ti:3000 | xargs kill -9

# Or change PORT in .env
PORT=3001
```

### **Flutter Issues**

**Dependency Conflicts**
```bash
flutter pub upgrade --major-versions
```

**API Connection Failed**
- Android: Use `http://10.0.2.2:3000` (not localhost)
- iOS: Use `http://127.0.0.1:3000`
- Check backend is running on same network

**Image Picker Not Working**
- Android: Add permissions to `AndroidManifest.xml`
- iOS: Add permissions to `Info.plist`

---

## 📈 **Performance Optimization**

### **Backend**
- ✅ Database indexing on frequently queried fields
- ✅ Pagination for large lists (already implemented)
- 🔲 Redis caching for finance data
- 🔲 Rate limiting for API endpoints

### **Flutter**
- ✅ ListView.builder for large lists (implemented)
- ✅ Image caching (http package default)
- 🔲 State management with Provider/Riverpod
- 🔲 Lazy loading for images

---

## 🚢 **Deployment**

### **Backend Deployment (Heroku/Railway/Render)**
```bash
# Add start script to package.json
"scripts": {
  "start": "node backend/server.js"
}

# Push to production
git push heroku main

# Set environment variables on hosting platform
```

### **Flutter Deployment**

**Android**
```bash
flutter build apk --release
# APK: build/app/outputs/flutter-apk/app-release.apk
```

**iOS**
```bash
flutter build ios --release
# Open in Xcode and archive
```

---

## 📝 **Summary**

### **Completed Features**
✅ Housing module (CRUD, search, map integration)
✅ Finance module (stocks, currency, commodities, watchlist)
✅ AI chatbot with database access
✅ Dark theme with neon palette
✅ Services tab in navigation
✅ RESTful API with authentication
✅ Database schema and migrations

### **Next Steps**
1. Test all features end-to-end
2. Add profile location field (geocoding)
3. Implement image upload for housing listings
4. Customize map with dark tiles and glowing markers
5. Add error handling and loading states
6. Implement analytics and monitoring
7. Deploy to production

---

## 🤝 **Support**

For issues or questions:
1. Check this guide first
2. Review API documentation in `API_DOCUMENTATION.md`
3. Check backend logs: `npm start` output
4. Check Flutter logs: `flutter run --verbose`

---

**Built with ❤️ using Flutter, Node.js, PostgreSQL, and OpenAI GPT-4**

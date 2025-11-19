# CRITICAL FIXES - Complete Backend + Frontend Integration

## 🚨 ERROR ANALYSIS & SOLUTIONS

### ERROR 1: Finance API 404s
**Root Cause**: Routes exist in `backend/routes/finance.js` but may not be properly mounted or have CORS issues.

**Solution**:
1. ✅ Routes already exist and are correct
2. Need to verify server.js mounts them properly
3. Add proper error logging
4. Ensure CORS allows localhost:* for development

### ERROR 2: Connections 404
**Root Cause**: `POST /api/connections/request` route doesn't exist

**Solution**: Create complete connections backend

### ERROR 3: Housing 401 Unauthorized
**Root Cause**: Flutter not sending auth token OR backend not accepting it

**Solution**:
1. Update Flutter Housing service to send token
2. Verify backend auth middleware

### ERROR 4: Profile Picture Not Updating
**Root Cause**: No state refresh mechanism after profile update

**Solution**: Implement refresh pattern in Flutter

### ERROR 5: Chatbot Location Filtering
**Root Cause**: Already fixed (Israel exclusion added)

**Solution**: ✅ Already implemented

### ERROR 6: Map Tile Errors
**Root Cause**: OpenTopoMap removed but user wants Satellite option

**Solution**: Add Mapbox Satellite with proper token handling

---

## 🔧 IMPLEMENTATION PLAN

### 1. Backend Fixes

#### A. Verify Finance Routes Mounting
File: `backend/server.js`
```javascript
// Ensure this line exists and is before any other route handlers
app.use('/api/finance', financeRoutes);
```

#### B. Create Connections Routes
File: `backend/routes/connections.js` (NEW)

#### C. Fix Housing Authentication
File: `backend/routes/housing.js`
- Ensure all POST/PUT/DELETE routes use `authenticateToken` middleware

#### D. Add Global Error Logging
- Log all 404s with request details
- Log all auth failures

### 2. Flutter Fixes

#### A. Update Finance Service
- Add proper error messages
- Use API service for base URL consistency

#### B. Create/Update Connections Service
File: `flutter-app/lib/services/connections_service.dart` (NEW or UPDATE)

#### C. Fix Housing Service Authentication
- Get token from ApiService
- Send Authorization header

#### D. Add Profile Refresh Mechanism
- Create `refreshCurrentUser()` in ApiService
- Call after profile updates
- Update UI state

#### E. Add Satellite Map Option
- Add Mapbox as map type
- Handle token from environment
- Keep CartoDB as fallback

---

## 📋 FILES TO CREATE/MODIFY

### Backend (Node.js)
1. ✅ `backend/routes/finance.js` - Already exists, verify mounting
2. 🆕 `backend/routes/connections.js` - CREATE NEW
3. ✏️ `backend/routes/housing.js` - Add auth middleware
4. ✏️ `backend/server.js` - Verify route mounting + add logging

### Flutter
1. ✏️ `flutter-app/lib/services/api_service.dart` - Add refreshCurrentUser()
2. ✏️ `flutter-app/lib/services/finance_service.dart` - Better error handling
3. 🆕 `flutter-app/lib/services/connections_service.dart` - CREATE NEW
4. ✏️ `flutter-app/lib/services/housing_service.dart` - Add authentication
5. ✏️ `flutter-app/lib/screens/map_screen.dart` - Add Satellite option
6. ✏️ All profile-related screens - Call refreshCurrentUser()

---

## 🎯 STEP-BY-STEP IMPLEMENTATION

### STEP 1: Backend Connections Routes

Create `backend/routes/connections.js`:

```javascript
const express = require('express');
const router = express.Router();
const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

// Authentication middleware
const jwt = require('jsonwebtoken');
const JWT_SECRET = process.env.JWT_SECRET || 'your-secret-key-change-in-production';

const authenticateToken = (req, res, next) => {
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1];

  if (!token) {
    return res.status(401).json({ error: 'Access token required' });
  }

  jwt.verify(token, JWT_SECRET, (err, user) => {
    if (err) {
      return res.status(403).json({ error: 'Invalid or expired token' });
    }
    req.user = user;
    next();
  });
};

// POST /api/connections/request - Send connection request
router.post('/request', authenticateToken, async (req, res) => {
  try {
    const { connectedId } = req.body;
    const userId = req.user.userId || req.user.id;

    if (!connectedId) {
      return res.status(400).json({ error: 'connectedId required' });
    }

    // Get user's profile ID
    const userProfile = await prisma.profile.findUnique({
      where: { userId: userId }
    });

    // Get target profile ID
    const targetProfile = await prisma.profile.findUnique({
      where: { userId: connectedId }
    });

    if (!userProfile || !targetProfile) {
      return res.status(404).json({ error: 'User profile not found' });
    }

    // Check if connection already exists
    const existing = await prisma.connection.findFirst({
      where: {
        OR: [
          { userId: userProfile.id, connectedId: targetProfile.id },
          { userId: targetProfile.id, connectedId: userProfile.id }
        ]
      }
    });

    if (existing) {
      return res.status(400).json({ error: 'Connection already exists' });
    }

    // Create connection request
    const connection = await prisma.connection.create({
      data: {
        userId: userProfile.id,
        connectedId: targetProfile.id,
        status: 'pending'
      }
    });

    res.status(201).json({
      message: 'Connection request sent',
      connection
    });
  } catch (error) {
    console.error('Error creating connection:', error);
    res.status(500).json({ error: 'Failed to send connection request' });
  }
});

// PUT /api/connections/:id/accept - Accept connection request
router.put('/:id/accept', authenticateToken, async (req, res) => {
  try {
    const { id } = req.params;
    const userId = req.user.userId || req.user.id;

    // Get user's profile
    const userProfile = await prisma.profile.findUnique({
      where: { userId: userId }
    });

    if (!userProfile) {
      return res.status(404).json({ error: 'User profile not found' });
    }

    // Find connection
    const connection = await prisma.connection.findUnique({
      where: { id }
    });

    if (!connection) {
      return res.status(404).json({ error: 'Connection not found' });
    }

    // Verify user is the recipient
    if (connection.connectedId !== userProfile.id) {
      return res.status(403).json({ error: 'Not authorized' });
    }

    // Update status
    const updated = await prisma.connection.update({
      where: { id },
      data: { status: 'accepted' }
    });

    res.json({
      message: 'Connection accepted',
      connection: updated
    });
  } catch (error) {
    console.error('Error accepting connection:', error);
    res.status(500).json({ error: 'Failed to accept connection' });
  }
});

// PUT /api/connections/:id/reject - Reject connection request
router.put('/:id/reject', authenticateToken, async (req, res) => {
  try {
    const { id } = req.params;
    const userId = req.user.userId || req.user.id;

    // Get user's profile
    const userProfile = await prisma.profile.findUnique({
      where: { userId: userId }
    });

    if (!userProfile) {
      return res.status(404).json({ error: 'User profile not found' });
    }

    // Find connection
    const connection = await prisma.connection.findUnique({
      where: { id }
    });

    if (!connection) {
      return res.status(404).json({ error: 'Connection not found' });
    }

    // Verify user is the recipient
    if (connection.connectedId !== userProfile.id) {
      return res.status(403).json({ error: 'Not authorized' });
    }

    // Update status
    const updated = await prisma.connection.update({
      where: { id },
      data: { status: 'rejected' }
    });

    res.json({
      message: 'Connection rejected',
      connection: updated
    });
  } catch (error) {
    console.error('Error rejecting connection:', error);
    res.status(500).json({ error: 'Failed to reject connection' });
  }
});

// GET /api/connections - Get user's connections
router.get('/', authenticateToken, async (req, res) => {
  try {
    const userId = req.user.userId || req.user.id;

    // Get user's profile
    const userProfile = await prisma.profile.findUnique({
      where: { userId: userId }
    });

    if (!userProfile) {
      return res.status(404).json({ error: 'User profile not found' });
    }

    // Get all connections
    const connections = await prisma.connection.findMany({
      where: {
        OR: [
          { userId: userProfile.id },
          { connectedId: userProfile.id }
        ]
      },
      include: {
        user: {
          include: {
            user: {
              select: {
                id: true,
                email: true
              }
            }
          }
        },
        connected: {
          include: {
            user: {
              select: {
                id: true,
                email: true
              }
            }
          }
        }
      }
    });

    res.json({ connections });
  } catch (error) {
    console.error('Error fetching connections:', error);
    res.status(500).json({ error: 'Failed to fetch connections' });
  }
});

// DELETE /api/connections/:id - Remove connection
router.delete('/:id', authenticateToken, async (req, res) => {
  try {
    const { id } = req.params;
    const userId = req.user.userId || req.user.id;

    // Get user's profile
    const userProfile = await prisma.profile.findUnique({
      where: { userId: userId }
    });

    if (!userProfile) {
      return res.status(404).json({ error: 'User profile not found' });
    }

    // Find connection
    const connection = await prisma.connection.findUnique({
      where: { id }
    });

    if (!connection) {
      return res.status(404).json({ error: 'Connection not found' });
    }

    // Verify user is part of the connection
    if (connection.userId !== userProfile.id && connection.connectedId !== userProfile.id) {
      return res.status(403).json({ error: 'Not authorized' });
    }

    // Delete connection
    await prisma.connection.delete({
      where: { id }
    });

    res.json({ message: 'Connection removed' });
  } catch (error) {
    console.error('Error removing connection:', error);
    res.status(500).json({ error: 'Failed to remove connection' });
  }
});

module.exports = router;
```

### STEP 2: Update server.js

Ensure connections routes are mounted in `backend/server.js`:

```javascript
// Import at top (should already have this line)
const connectionsRoutes = require('./routes/connections');

// Mount routes (add if missing)
app.use('/api/connections', connectionsRoutes);
```

### STEP 3: Fix Housing Authentication

In `backend/routes/housing.js`, ensure POST route uses auth:

```javascript
// POST /api/housing - Create listing (MUST be authenticated)
router.post('/', authenticateToken, async (req, res) => {
  // ... existing code
});
```

### STEP 4: Update Flutter ApiService

Add refresh method in `flutter-app/lib/services/api_service.dart`:

```dart
// Refresh current user data
Future<UserModel> refreshCurrentUser() async {
  final token = await getToken();
  if (token == null) throw Exception('Not authenticated');

  final uri = Uri.parse('$baseUrl/users/profile');
  final response = await _safeHttpCall(
    () => http.get(
      uri,
      headers: _jsonHeaders(token: token),
    ),
    uri,
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return UserModel.fromJson(data['user']);
  } else {
    final error = jsonDecode(response.body);
    throw Exception(error['error'] ?? 'Failed to fetch user data');
  }
}
```

### STEP 5: Update Housing Service

In `flutter-app/lib/services/housing_service.dart`, add authentication:

```dart
import 'package:shared_preferences/shared_preferences.dart';

class HousingService {
  static const String baseUrl = 'http://localhost:3000/api/housing';

  // Get auth token
  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }

  static Future<Map<String, String>> _getHeaders({bool auth = false}) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };

    if (auth) {
      final token = await _getToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    return headers;
  }

  static Future<void> createListing({
    // ... existing parameters
  }) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: await _getHeaders(auth: true), // ← ADD AUTH
      body: jsonEncode({
        // ... existing body
      }),
    );

    if (response.statusCode == 201) {
      return;
    } else {
      throw Exception('Failed to create listing: ${response.body}');
    }
  }
}
```

### STEP 6: Add Map Satellite Option

In `flutter-app/lib/screens/map_screen.dart`:

```dart
enum MapStyle { dark, light, satellite }

String _getTileUrl() {
  switch (_currentStyle) {
    case MapStyle.dark:
      return 'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}.png';
    case MapStyle.light:
      return 'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}.png';
    case MapStyle.satellite:
      // Option 1: Mapbox (requires token)
      const mapboxToken = String.fromEnvironment('MAPBOX_TOKEN', defaultValue: '');
      if (mapboxToken.isNotEmpty) {
        return 'https://api.mapbox.com/styles/v1/mapbox/satellite-v9/tiles/{z}/{x}/{y}?access_token=$mapboxToken';
      }
      // Option 2: Fallback to Esri (free, but rate limited)
      return 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}';
  }
}

// Update map style picker
void _showMapStylePicker() {
  showModalBottomSheet(
    context: context,
    backgroundColor: NeonColors.surface,
    builder: (context) => Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Map Style',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: NeonColors.text,
            ),
          ),
          const SizedBox(height: 16),
          ListTile(
            leading: const Icon(Icons.dark_mode, color: NeonColors.cyan),
            title: const Text('Dark', style: TextStyle(color: NeonColors.text)),
            selected: _currentStyle == MapStyle.dark,
            onTap: () {
              setState(() => _currentStyle = MapStyle.dark);
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.light_mode, color: NeonColors.cyan),
            title: const Text('Light', style: TextStyle(color: NeonColors.text)),
            selected: _currentStyle == MapStyle.light,
            onTap: () {
              setState(() => _currentStyle = MapStyle.light);
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.satellite, color: NeonColors.cyan),
            title: const Text('Satellite', style: TextStyle(color: NeonColors.text)),
            selected: _currentStyle == MapStyle.satellite,
            onTap: () {
              setState(() => _currentStyle = MapStyle.satellite);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    ),
  );
}
```

---

## 🔍 DEBUGGING CHECKLIST

### Backend
- [ ] Run `npm start` and check console for errors
- [ ] Test each endpoint with curl or Postman:
  ```bash
  curl http://localhost:3000/api/finance/equity/RELIANCE
  curl http://localhost:3000/api/finance/market-overview
  curl -X POST http://localhost:3000/api/connections/request \
    -H "Authorization: Bearer <token>" \
    -H "Content-Type: application/json" \
    -d '{"connectedId":"user-id"}'
  ```
- [ ] Check `backend/server.js` has all route imports and mounts
- [ ] Verify database has `connections` table (run migrations if needed)

### Flutter
- [ ] Run `flutter clean && flutter pub get`
- [ ] Check console for network errors with full URLs
- [ ] Verify token is being saved and retrieved
- [ ] Test each service method individually
- [ ] Check API base URL matches running backend

---

## 📌 ENVIRONMENT VARIABLES

### Backend `.env`
```env
DATABASE_URL="postgresql://..."
JWT_SECRET="your-secret-key"
OPENAI_API_KEY="sk-..."
PORT=3000
HOST=0.0.0.0
```

### Flutter (Optional)
For Mapbox Satellite:
```bash
flutter run --dart-define=MAPBOX_TOKEN=your_mapbox_token
```

Or add to launch.json for VS Code:
```json
{
  "configurations": [
    {
      "name": "Flutter",
      "request": "launch",
      "type": "dart",
      "args": ["--dart-define=MAPBOX_TOKEN=your_token"]
    }
  ]
}
```

---

## ✅ TESTING PROCEDURE

1. **Start Backend**: `cd backend && npm start`
2. **Verify Routes**:
   - Finance: `curl http://localhost:3000/api/finance/trending`
   - Connections: `curl http://localhost:3000/api/connections` (with auth header)
   - Housing: `curl http://localhost:3000/api/housing`
3. **Start Flutter**: `cd flutter-app && flutter run`
4. **Test Features**:
   - Finance: Open Finance tab, should load market data
   - Connections: Try adding friend from home page
   - Housing: Try creating a listing (must be logged in)
   - Profile: Update profile picture, verify it shows everywhere
   - Map: Switch between Dark/Light/Satellite modes

---

## 🚀 PRODUCTION DEPLOYMENT

### Backend
1. Set proper JWT_SECRET
2. Use production database URL
3. Enable HTTPS
4. Set CORS to specific origins
5. Add rate limiting
6. Enable PM2 or Docker

### Flutter
1. Build release: `flutter build web --release`
2. Update API base URL to production
3. Add proper error tracking (Sentry)
4. Enable analytics
5. Test on multiple browsers/devices

---

**Status**: Ready for implementation
**Priority**: CRITICAL
**Estimated Time**: 2-3 hours for full implementation

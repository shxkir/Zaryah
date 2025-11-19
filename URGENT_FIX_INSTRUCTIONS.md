# URGENT FIX - Profile Picture & Finance Page

## 🔴 CRITICAL: You Must Restart Flutter App

**Hot reload will NOT work** - you must do a **full restart**:

```bash
# Stop the app completely (press 'q' in terminal or stop from IDE)
# Then restart:
flutter run
```

---

## Issue #1: Profile Picture Upload Failing

### Root Cause
The base64 image string is likely too large for the HTTP request. The backend has a 50MB limit, but there might be a timeout or parsing issue.

### Immediate Fix - Two Options:

#### Option A: Reduce Image Size (RECOMMENDED)
The image picker is already set to compress, but let's make it smaller:

**File**: `flutter-app/lib/screens/edit_profile_screen.dart`
**Line 117-122**: Change image quality settings:

```dart
// CURRENT (might be too large):
final XFile? image = await _picker.pickImage(
  source: ImageSource.gallery,
  maxWidth: 1080,      // ← Change to 800
  maxHeight: 1080,     // ← Change to 800
  imageQuality: 85,    // ← Change to 70
);

// CHANGE TO (smaller size):
final XFile? image = await _picker.pickImage(
  source: ImageSource.gallery,
  maxWidth: 800,       // Smaller dimensions
  maxHeight: 800,      // Smaller dimensions
  imageQuality: 70,    // Lower quality = smaller file
);
```

#### Option B: Check Backend Logs for Actual Error

The backend should show exactly what's failing:

```bash
# In terminal where backend is running, look for:
📝 Profile update request for user ...
Request body: { ... }
✅ Update data prepared: [...]
❌ Update profile error: <-- THIS WILL SHOW THE ACTUAL ERROR
```

**Common Errors**:
1. **"Request entity too large"** → Image is too big
2. **"Profile not found"** → User doesn't have a profile
3. **"Timeout"** → Request is taking too long

---

## Issue #2: Finance Page Not Loading

### Root Cause
Flutter is still calling the OLD method. You **MUST restart the app** (hot reload doesn't refresh service imports).

### Fix Steps:

1. **STOP the Flutter app completely**
   - Press `q` in the terminal, OR
   - Click the stop button in your IDE

2. **Restart the app** (not hot reload):
   ```bash
   cd flutter-app
   flutter run
   ```

3. **Navigate to Finance tab**
   - Backend logs should show:
   ```
   📊 Fetching finance dashboard...
   📊 Fetching quote for: NIFTY
   📊 Fetching quote for: RELIANCE.NSE
   ✅ Dashboard data fetched successfully
   ```

4. **If still failing**, check Flutter console for:
   ```dart
   📊 Fetching finance dashboard...
   ✅ Finance dashboard fetched successfully
   // OR
   ❌ Dashboard failed with status: XXX
   ```

---

## Quick Debug Commands

### Check if backend is running:
```bash
curl http://localhost:3000/health
# Should return: {"status":"ok","message":"Zaryah API is running"}
```

### Test finance endpoint directly:
```bash
# Get your JWT token from Flutter app (check logs or SharedPreferences)
curl http://localhost:3000/api/finance/dashboard \
  -H "Authorization: Bearer YOUR_JWT_TOKEN_HERE"

# Should return JSON with indices, popularStocks, currencies, commodities
```

### Test profile update directly:
```bash
curl -X PUT http://localhost:3000/api/profile/me \
  -H "Authorization: Bearer YOUR_JWT_TOKEN_HERE" \
  -H "Content-Type: application/json" \
  -d '{"name": "Test User", "bio": "Testing"}'

# Should return updated user object
```

---

## Detailed Troubleshooting

### For Profile Picture:

1. **Check image size in Flutter**:
   ```dart
   // After picking image (line 124-126):
   if (image != null) {
     final bytes = await image.readAsBytes();
     print('📊 Image size: ${(bytes.length / (1024 * 1024)).toStringAsFixed(2)}MB');
     // Should be less than 5MB
   ```

2. **Check backend receives the request**:
   - Backend logs should show: `📝 Profile update request for user {id}`
   - If you don't see this, the request isn't reaching backend
   - If you see this but then an error, the issue is in the backend processing

3. **Check for null/empty profile picture**:
   - The image might not be encoded correctly
   - Backend logs show: `Request body: {...}` - check if `profilePictureUrl` is present

### For Finance Page:

1. **Verify Flutter is using new method**:
   ```dart
   // In finance_screen.dart, you should see (line 41):
   final dashboardData = await FinanceService.getFinanceDashboard();
   // NOT:
   final overview = await FinanceService.getMarketOverview(); // ← OLD (wrong)
   ```

2. **Check authentication**:
   - Finance endpoints require authentication
   - If token is expired/invalid, you'll get 401 or 403
   - Solution: Log out and log back in

3. **Check TwelveData API**:
   - Backend logs show responses from TwelveData
   - If you see `❌ TwelveData API error`, the API might be down or rate-limited

---

## Checklist

### Before Testing:
- [ ] Backend is running (`node backend/server.js`)
- [ ] Backend shows: `🚀 Zaryah backend server running on http://localhost:3000`
- [ ] Flutter app is **FULLY RESTARTED** (not hot reload)

### Test Profile Picture:
- [ ] Go to Profile → Edit Profile
- [ ] Tap profile picture circle
- [ ] Select small image (< 2MB recommended)
- [ ] Watch backend terminal for logs
- [ ] If error, note the EXACT error message from backend

### Test Finance Page:
- [ ] Go to Finance tab
- [ ] Should see loading spinner
- [ ] Backend should show: `📊 Fetching finance dashboard...`
- [ ] Flutter console should show: `📊 Fetching finance dashboard...`
- [ ] Page should load with stock data

---

## If Still Failing

### Profile Picture Upload:
Copy the **exact error message** from:
1. Flutter console
2. Backend terminal logs
3. Tell me both error messages

### Finance Page:
Copy the **exact error message** from:
1. Flutter console (what does it print?)
2. Backend terminal logs (any finance-related errors?)
3. What HTTP status code? (401? 403? 500?)

---

## Quick Fixes to Apply NOW

### 1. Reduce Image Size
Edit `flutter-app/lib/screens/edit_profile_screen.dart` line 117-122:
```dart
final XFile? image = await _picker.pickImage(
  source: ImageSource.gallery,
  maxWidth: 800,      // Was 1080
  maxHeight: 800,     // Was 1080
  imageQuality: 70,   // Was 85
);
```

### 2. Add Debug Logging
Edit `flutter-app/lib/screens/edit_profile_screen.dart` after line 126:
```dart
if (image != null) {
  final bytes = await image.readAsBytes();
  print('📊 IMAGE SIZE: ${(bytes.length / (1024 * 1024)).toStringAsFixed(2)}MB');
  final base64Image = 'data:image/${image.path.split('.').last};base64,${base64Encode(bytes)}';
  print('📊 BASE64 LENGTH: ${base64Image.length} characters');
  // ... rest of code
}
```

### 3. Restart Flutter App
```bash
# Stop completely, then:
cd flutter-app
flutter run
```

---

## Expected Behavior

### Profile Picture Success:
```
Flutter Console:
📊 IMAGE SIZE: 1.2MB
📊 BASE64 LENGTH: 1638400 characters
✅ Profile updated successfully!

Backend Logs:
📝 Profile update request for user abc-123
✅ Update data prepared: [name, bio, profilePictureUrl, ...]
📝 Updating existing profile...
✅ Profile updated successfully
✅ Profile update successful for user abc-123
```

### Finance Page Success:
```
Flutter Console:
📊 Fetching finance dashboard...
✅ Finance dashboard fetched successfully

Backend Logs:
📊 Fetching finance dashboard...
📊 Fetching quote for: NIFTY
📥 TwelveData response for NIFTY: {...}
✅ Quote fetched successfully for NIFTY: ₹24,587.30
... (more quotes)
✅ Dashboard data fetched successfully
```

---

**DO THIS NOW**:
1. Stop Flutter app
2. Apply image size fix above
3. Restart Flutter app (`flutter run`)
4. Test both features
5. Share the EXACT error messages if still failing

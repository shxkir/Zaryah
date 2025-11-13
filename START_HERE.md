# 🚀 Zaryah - Start Here

## What is the Anthropic API Key?

**Anthropic API Key** is required to use Claude AI for the chatbot. It's like a password that lets your app talk to Claude.

### How to Get Your Anthropic API Key:

1. Go to: **https://console.anthropic.com/**
2. Sign up or log in
3. Go to "API Keys" section
4. Click "Create Key"
5. Copy the key (it looks like: `sk-ant-api03-xxxxxxxxxxxxx`)

**Cost**: Anthropic has a free tier for testing. For this app, the cost is very minimal (few cents per day).

---

## ⚡ Quick Setup (5 Minutes)

### Step 1: Add Your Anthropic API Key (REQUIRED)

Open the `.env` file and replace this line:
```env
ANTHROPIC_API_KEY="your-anthropic-api-key-here"
```

With your actual key:
```env
ANTHROPIC_API_KEY="sk-ant-api03-YOUR-ACTUAL-KEY-HERE"
```

✅ **Pinecone is already configured!** Your key is: `pcsk_41qBGm...`

---

### Step 2: Fix App Name (Run This First)

The app name got changed to "Zarayah" by mistake. Fix it:

```powershell
.\fix-app-name.ps1
```

---

### Step 3: Update Database Password

In `.env`, change `password` to your actual PostgreSQL password:
```env
DATABASE_URL="postgresql://postgres:YOUR_ACTUAL_PASSWORD@localhost:5432/zaryah?schema=public"
```

---

### Step 4: Create Database

**Choose one method:**

**Method A - Using the Script (Easiest):**
```powershell
.\setup-database.ps1
```

**Method B - Using pgAdmin GUI:**
1. Open pgAdmin
2. Right-click "Databases"
3. Create → Database
4. Name: `zaryah`
5. Save

**Method C - Using psql Command:**
```powershell
# Find your PostgreSQL version (usually 15 or 16)
& "C:\Program Files\PostgreSQL\16\bin\psql.exe" -U postgres -c "CREATE DATABASE zaryah;"
```

---

### Step 5: Initialize the Platform

Run these commands **one at a time**:

```powershell
npm run prisma:generate
```

Wait for it to finish, then:

```powershell
npm run prisma:migrate
```

Wait for it to finish, then:

```powershell
npm run seed
```

You should see:
```
✅ Created user: Sarah Johnson (sarah.johnson@example.com)
✅ Created user: Michael Chen (michael.chen@example.com)
...
✅ Stored 30 users in Pinecone
🎉 Mock user generation complete!
```

---

### Step 6: Test Everything

```powershell
npm test
```

You should see:
```
✅ PASSED: Exactly 30 users found
✅ PASSED: All users have complete profiles
✅ PASSED: All emails are unique
🎉 All tests passed!
```

---

### Step 7: Start the Backend

```powershell
npm start
```

You should see:
```
✅ Pinecone initialized successfully
🚀 Zaryah backend server running on http://localhost:3000
```

**Keep this terminal open!**

---

### Step 8: Run the Flutter App

Open a **NEW** PowerShell window:

```powershell
cd flutter-app
```

```powershell
flutter pub get
```

```powershell
flutter run
```

Choose your device (emulator or physical phone).

---

## 🎉 You're Done!

### Test the App

**Login Credentials:**
- Email: `sarah.johnson@example.com`
- Password: `password123`

**Try These Chatbot Questions:**
- "Tell me about Sarah Johnson"
- "Which users are interested in Machine Learning?"
- "What is Michael Chen's biggest challenge?"
- "Compare Sarah and Michael"
- "Who has the most available hours per week?"
- "Show me all developers"

---

## 🆘 Troubleshooting

### Error: "ANTHROPIC_API_KEY required"
- You forgot to add your Anthropic API key in `.env`
- Get it from: https://console.anthropic.com/

### Error: "Cannot connect to database"
- Make sure PostgreSQL is running
- Check your password in `.env` DATABASE_URL
- Try: `pg_ctl status` to check PostgreSQL status

### Error: "Pinecone error"
- Your Pinecone key is already configured correctly
- The app will automatically fallback to PostgreSQL if needed

### Flutter app shows "Connection refused"
- Make sure backend is running (`npm start`)
- Check that you see: "🚀 Zaryah backend server running on http://localhost:3000"

### For physical devices (not emulator):
Edit `flutter-app/lib/services/api_service.dart` line 6:
```dart
static const String baseUrl = 'http://YOUR_COMPUTER_IP:3000/api';
```
Replace `YOUR_COMPUTER_IP` with your computer's IP address (e.g., `192.168.1.100`)

---

## 📊 What's Included

✅ **30 Diverse Mock Users** - All with password: `password123`
✅ **AI Chatbot** - Powered by Claude Sonnet 4.5
✅ **Vector Database** - Pinecone (already configured!)
✅ **5-Step Signup Flow** - Complete user profiling
✅ **JWT Authentication** - Secure login system
✅ **Beautiful UI** - Material Design 3

---

## 🔑 Summary of Your Keys

| Service | Status | Where to Get |
|---------|--------|--------------|
| **Pinecone** | ✅ Already configured | - |
| **Anthropic** | ⚠️ Need to add | https://console.anthropic.com/ |
| **PostgreSQL** | ⚠️ Update password | Your local installation |

---

## 📚 Additional Help

- **Full Documentation**: [README.md](README.md)
- **API Reference**: [API_DOCUMENTATION.md](API_DOCUMENTATION.md)
- **Environment Check**: `npm run check`

---

## 💰 Cost Information

**Anthropic Claude API:**
- Free tier: $5 credit
- Cost: ~$0.01 - $0.05 per day for testing
- This app uses Claude Sonnet (cheaper model)

**Pinecone:**
- Already configured with your free tier
- No additional setup needed

**PostgreSQL:**
- Free (local installation)

---

## ✅ Quick Checklist

- [ ] Get Anthropic API key from console.anthropic.com
- [ ] Add Anthropic key to `.env` file
- [ ] Update PostgreSQL password in `.env`
- [ ] Run `.\fix-app-name.ps1` to fix naming
- [ ] Create `zaryah` database
- [ ] Run `npm run prisma:generate`
- [ ] Run `npm run prisma:migrate`
- [ ] Run `npm run seed` (creates 30 users)
- [ ] Run `npm test` (verify everything works)
- [ ] Run `npm start` (start backend)
- [ ] Run Flutter app in new terminal
- [ ] Test login with sarah.johnson@example.com / password123
- [ ] Try chatbot questions

---

**Need help?** All your Pinecone configuration is correct. You just need to:
1. Get an Anthropic API key (free: https://console.anthropic.com/)
2. Add it to `.env`
3. Follow the steps above!

The app is ready to run! 🎉

# ⚡ Setup Zaryah NOW (Using Google Gemini)

## ✅ What's Already Done

- ✅ **Google API Key configured**: Your key is already in `.env`
- ✅ **Pinecone API Key configured**: Your key is already in `.env`
- ✅ **Backend updated**: Now uses Google Gemini instead of Anthropic Claude
- ✅ **30 mock users ready**: All configured and ready to seed
- ✅ **Everything configured**: Just need to run setup commands!

---

## 🚀 Complete Setup (5 Minutes)

### Step 1: Install Dependencies (1 minute)

```powershell
npm install
```

This will install:
- `@google/generative-ai` (Google Gemini SDK)
- `@pinecone-database/pinecone` (Vector database)
- All other dependencies

---

### Step 2: Update PostgreSQL Password (30 seconds)

Open `.env` and change `password` to your actual PostgreSQL password:

```env
DATABASE_URL="postgresql://postgres:YOUR_PASSWORD@localhost:5432/zaryah?schema=public"
```

---

### Step 3: Create Database (1 minute)

**Choose ONE method:**

**Method A - Using Script:**
```powershell
.\setup-database.ps1
```

**Method B - Using psql:**
```powershell
& "C:\Program Files\PostgreSQL\16\bin\psql.exe" -U postgres -c "CREATE DATABASE zaryah;"
```

**Method C - Using pgAdmin:**
1. Open pgAdmin
2. Right-click "Databases" → Create → Database
3. Name: `zaryah`

---

### Step 4: Initialize Platform (2 minutes)

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
🌱 Starting to generate mock users...
📌 Initializing Pinecone...
✅ Created user: Sarah Johnson (sarah.johnson@example.com)
✅ Created user: Michael Chen (michael.chen@example.com)
...
✅ Stored 30 users in Pinecone
🎉 Mock user generation complete!
   All users have the password: password123
```

---

### Step 5: Test Everything (30 seconds)

```powershell
npm test
```

Expected output:
```
🧪 Zaryah Platform Test Suite
✅ PASSED: Successfully connected to PostgreSQL
✅ PASSED: Exactly 30 users found
✅ PASSED: All users have complete profiles
✅ PASSED: All emails are unique
✅ PASSED: All profiles have complete data
✅ PASSED: All users have learning subjects
🎉 All tests passed! Zaryah platform is ready to use.
```

---

### Step 6: Start Backend (10 seconds)

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

### Step 7: Run Flutter App (1 minute)

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

---

## 🎉 Test the App!

### Login Credentials
- **Email**: `sarah.johnson@example.com`
- **Password**: `password123`

### Try These Chatbot Questions
- "Tell me about Sarah Johnson"
- "Which users are interested in Machine Learning?"
- "What is Michael Chen's biggest challenge?"
- "Compare Sarah and Michael"
- "Who has the most available hours per week?"
- "Show me all developers"
- "List all users interested in Python"

---

## 🔑 Your API Keys (Already Configured!)

| Service | Status | Key |
|---------|--------|-----|
| **Google Gemini** | ✅ Configured | `AIzaSyBF...` |
| **Pinecone** | ✅ Configured | `pcsk_41qB...` |
| **PostgreSQL** | ⚠️ Update password | In `.env` |

---

## 💰 Cost

**Google Gemini (AI Chatbot):**
- ✅ **FREE**: Up to 60 requests per minute
- ✅ **No credit card required**
- ✅ **Perfect for development**

**Pinecone (Vector Database):**
- ✅ **FREE tier**: Already configured
- ✅ **No additional cost**

**PostgreSQL:**
- ✅ **FREE**: Local installation

---

## 🆘 Quick Troubleshooting

### "Cannot connect to database"
- Make sure PostgreSQL is running
- Update password in `.env` file

### "Module not found: @google/generative-ai"
- Run: `npm install`

### Port 3000 already in use
```powershell
netstat -ano | findstr :3000
taskkill /PID <PID> /F
```

### Flutter app can't connect
- Make sure backend is running (`npm start`)
- Check you see: "🚀 Zaryah backend server running on http://localhost:3000"

---

## 📊 What You Get

✅ **30 diverse mock users** with complete profiles
✅ **Google Gemini AI** chatbot (FREE)
✅ **Pinecone vector database** for semantic search
✅ **5-step signup flow** with beautiful UI
✅ **JWT authentication** with auto-login
✅ **Material Design 3** UI

---

## 📝 Quick Command Reference

```powershell
npm install              # Install all dependencies
npm run prisma:generate  # Generate Prisma client
npm run prisma:migrate   # Run database migrations
npm run seed            # Create 30 mock users
npm test                # Verify everything works
npm start               # Start backend server
```

In new terminal:
```powershell
cd flutter-app
flutter pub get
flutter run
```

---

## ✅ Complete Checklist

- [ ] Run `npm install`
- [ ] Update PostgreSQL password in `.env`
- [ ] Create `zaryah` database
- [ ] Run `npm run prisma:generate`
- [ ] Run `npm run prisma:migrate`
- [ ] Run `npm run seed`
- [ ] Run `npm test` to verify
- [ ] Run `npm start` (keep terminal open)
- [ ] In new terminal: `cd flutter-app && flutter pub get && flutter run`
- [ ] Test login: sarah.johnson@example.com / password123
- [ ] Try chatbot questions

---

## 🎯 Key Difference from Previous Setup

**OLD**: Used Anthropic Claude (required sign-up and API key)
**NEW**: Uses Google Gemini (FREE, already configured!)

**Advantages:**
- ✅ No need to sign up for Anthropic
- ✅ Completely FREE
- ✅ 60 requests per minute (plenty for development)
- ✅ Same great AI quality
- ✅ Your key is already configured!

---

**You're all set!** Just follow the steps above and you'll have Zaryah running in 5 minutes! 🚀

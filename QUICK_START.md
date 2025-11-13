# Zarayah - Quick Start Guide

## ⚡ 3-Minute Setup

### Prerequisites
- ✅ Node.js installed
- ✅ PostgreSQL installed
- ✅ Flutter installed (for mobile app)

### Step 1: Add Your Anthropic API Key (30 seconds)

Edit `.env` file and replace this line:
```env
ANTHROPIC_API_KEY="your-anthropic-api-key-here"
```

With your actual key:
```env
ANTHROPIC_API_KEY="sk-ant-api03-YOUR-ACTUAL-KEY"
```

### Step 2: Update Database URL (30 seconds)

In `.env`, update this line with your PostgreSQL password:
```env
DATABASE_URL="postgresql://postgres:YOUR_PASSWORD@localhost:5432/zaryah?schema=public"
```

### Step 3: Create Database (1 minute)

**Option A - Using PowerShell script:**
```powershell
.\setup-database.ps1
```

**Option B - Manual (if you know your PostgreSQL path):**
```powershell
& "C:\Program Files\PostgreSQL\16\bin\psql.exe" -U postgres -c "CREATE DATABASE zaryah;"
```

**Option C - Using pgAdmin:**
- Open pgAdmin
- Right-click "Databases" → Create → Database
- Name it: `zaryah`

### Step 4: Initialize Platform (1 minute)

Run these commands one by one:

```powershell
npm run prisma:generate
```

```powershell
npm run prisma:migrate
```

```powershell
npm run seed
```

You should see: `✅ Stored 30 users in Pinecone`

### Step 5: Start Backend (10 seconds)

```powershell
npm start
```

You should see:
```
✅ Pinecone initialized successfully
🚀 Zaryah backend server running on http://localhost:3000
```

### Step 6: Run Flutter App (30 seconds)

Open a NEW PowerShell window:

```powershell
cd flutter-app
flutter pub get
flutter run
```

## 🎉 You're Done!

### Test Login
- **Email**: `sarah.johnson@example.com`
- **Password**: `password123`

### Try These Chatbot Queries
- "Tell me about Sarah Johnson"
- "Which users are interested in Machine Learning?"
- "Compare Sarah and Michael"
- "What is Michael Chen's biggest challenge?"
- "Who has the most available hours per week?"

---

## 🆘 Troubleshooting

### "Cannot connect to database"
- Make sure PostgreSQL is running
- Check your DATABASE_URL in `.env`

### "Pinecone error"
- Your Pinecone key is already configured
- If issues persist, the app will automatically fall back to PostgreSQL

### "ANTHROPIC_API_KEY required"
- You forgot to add your Anthropic key in `.env`

### Flutter can't connect
- Make sure backend is running (`npm start`)
- For physical devices, update `baseUrl` in `flutter-app/lib/services/api_service.dart` with your computer's IP

---

## 📚 More Information

- **Full Documentation**: [README.md](README.md)
- **API Reference**: [API_DOCUMENTATION.md](API_DOCUMENTATION.md)
- **Critical Updates**: [CRITICAL_UPDATES.md](CRITICAL_UPDATES.md)
- **Environment Check**: Run `npm run check`

---

## 🎯 What You Get

✅ **30 Diverse Mock Users** - Ready to test
✅ **AI Chatbot** - Powered by Claude Sonnet 4.5
✅ **Vector Database** - Pinecone integration
✅ **Full Authentication** - JWT-based
✅ **Beautiful UI** - Material Design 3
✅ **5-Step Signup** - Comprehensive user profiling

**All users have password**: `password123`

---

**Need Help?** Check [CRITICAL_UPDATES.md](CRITICAL_UPDATES.md) for detailed information.

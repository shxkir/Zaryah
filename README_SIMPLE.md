# Zaryah - Simple Setup Guide

## 🎯 What You Need to Know

Your Zaryah app is **ready to run!** All API keys are configured:
- ✅ Google Gemini API (AI chatbot) - FREE
- ✅ Pinecone API (vector database) - FREE
- ⚠️ PostgreSQL password - Update in `.env`

---

## ⚡ 3 Simple Steps

### 1. Install & Setup (2 minutes)

```powershell
npm install
npm run prisma:generate
```

### 2. Create Database & Users (2 minutes)

Update your PostgreSQL password in `.env` first!

Then run:
```powershell
# Create database (use setup-database.ps1 or pgAdmin)
.\setup-database.ps1

# Or manually:
& "C:\Program Files\PostgreSQL\16\bin\psql.exe" -U postgres -c "CREATE DATABASE zaryah;"

# Initialize
npm run prisma:migrate
npm run seed
npm test
```

### 3. Start Everything (1 minute)

Terminal 1:
```powershell
npm start
```

Terminal 2:
```powershell
cd flutter-app
flutter pub get
flutter run
```

---

## 🎮 Test Login

- Email: `sarah.johnson@example.com`
- Password: `password123`

---

## 💬 Try These Questions

- "Tell me about Sarah"
- "Who is interested in Machine Learning?"
- "Compare Sarah and Michael"

---

## 🆘 Problems?

**Can't connect to database?**
- Update password in `.env`
- Make sure PostgreSQL is running

**Port 3000 in use?**
```powershell
netstat -ano | findstr :3000
taskkill /PID <PID> /F
```

**Need more help?**
- See [SETUP_NOW.md](SETUP_NOW.md) for detailed steps
- See [COMMANDS.md](COMMANDS.md) for all commands

---

## ✨ What Makes This Special?

- Uses **Google Gemini** (FREE, no sign-up needed!)
- **30 realistic users** already configured
- **Vector database** for smart search
- **Beautiful UI** with Material Design 3
- **Complete authentication** system

---

**That's it!** Follow the 3 steps above and you're done! 🚀

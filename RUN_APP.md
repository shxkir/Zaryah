# 🚀 Run Zaryah App - Complete Guide

## The Problem

The app is getting a **500 Internal Server Error** because it can't connect to PostgreSQL. The password in `.env` needs to be updated.

## ⚡ Quick Fix (3 Steps)

### Step 1: Update Password in .env

1. Open `c:\Users\ismai\Downloads\Zaryah\.env` in any text editor
2. Find line 2 that looks like:
   ```
   DATABASE_URL="postgresql://postgres:@localhost:5432/zaryah?schema=public"
   ```
3. Change it to (replace `YOUR_PASSWORD` with your actual PostgreSQL password):
   ```
   DATABASE_URL="postgresql://postgres:YOUR_PASSWORD@localhost:5432/zaryah?schema=public"
   ```
4. Save the file

**Example:**
If your PostgreSQL password is `mypass123`, the line should be:
```
DATABASE_URL="postgresql://postgres:mypass123@localhost:5432/zaryah?schema=public"
```

### Step 2: Run Setup Commands

Open PowerShell in the Zaryah folder and run these commands **one by one**:

```powershell
# Navigate to project folder
cd c:\Users\ismai\Downloads\Zaryah

# 1. Create database (if it doesn't exist)
# If you get password prompt, enter your PostgreSQL password
& "C:\Program Files\PostgreSQL\18\bin\psql.exe" -U postgres -c "CREATE DATABASE zaryah;"
# Note: If you get "database already exists" error, that's OK!

# 2. Run Prisma migrations (creates tables)
npx prisma migrate dev --name init

# 3. Seed database with 30 users
npm run seed

# 4. Start backend server
npm start
```

After running `npm start`, you should see:
```
✓ Pinecone initialized successfully
🚀 Zaryah backend server running on http://localhost:3000
```

### Step 3: Run Flutter App

**Open a NEW PowerShell window** (keep the backend running) and run:

```powershell
cd c:\Users\ismai\Downloads\Zaryah\flutter-app
flutter pub get
flutter run
```

## 🎨 What You'll See

The app now has a **beautiful dark theme with gold accents**:
- Dark navy background (#0A0E27)
- Gold text and buttons (#D4AF37)
- Smooth animations and modern design

## 🧪 Test Login

After the app opens, you can:

**Option 1: Login with test user**
- Email: `sarah.johnson@example.com`
- Password: `password123`

**Option 2: Create new account**
- Go through the 5-step signup process
- Your account will be created instantly

## 💬 Test Chatbot

After login, you'll be immediately on the chatbot screen. Try these questions:

1. "How many users do we have?"
   - Should return: "30 users"

2. "Tell me about Sarah Johnson"
   - Should return complete profile with all details

3. "Which users are interested in Machine Learning?"
   - Should return filtered list of relevant users

4. "Compare Sarah and Michael"
   - Should return side-by-side comparison

## 🐛 Troubleshooting

### Error: "Can't find psql.exe"
**Solution:** Use pgAdmin to create database instead:
1. Open pgAdmin 4
2. Right-click "Databases" → "Create" → "Database"
3. Name: `zaryah`
4. Click "Save"
5. Then continue with `npx prisma migrate dev --name init`

### Error: "Authentication failed"
**Solution:** Your password in `.env` is wrong. Double-check:
1. Open pgAdmin and try to connect - what password works there?
2. Use that same password in `.env` file
3. Save and try again

### Error: "Port 3000 already in use"
**Solution:** Kill the process using port 3000:
```powershell
# Find process
netstat -ano | findstr :3000
# Kill it (replace PID with the number from above)
powershell -Command "Stop-Process -Id PID -Force"
```

### Error: "Prisma Client not generated"
**Solution:**
```powershell
npx prisma generate
npx prisma migrate dev --name init
```

## ✅ Success Checklist

After everything is running, you should have:

- [ ] Backend running on http://localhost:3000
- [ ] Flutter app opened on emulator/device
- [ ] Dark theme with gold visible in app
- [ ] Can login successfully
- [ ] Redirected to chatbot after login
- [ ] Chatbot responds to "How many users?"
- [ ] Response says "30 users"

## 📝 One-Line Summary

**To run the app:**
1. Update password in `.env` (line 2)
2. Run: `npx prisma migrate dev --name init` then `npm run seed` then `npm start`
3. New terminal: `cd flutter-app` then `flutter run`
4. Login and test chatbot!

## 🎉 What's Ready

Everything is already configured and ready:
- ✅ Google Gemini AI (FREE, no credit card needed)
- ✅ Pinecone vector database (FREE tier)
- ✅ 30 diverse mock users with complete profiles
- ✅ Beautiful dark theme with gold design
- ✅ Complete authentication system
- ✅ All API keys configured in `.env`

The only thing you need to do is update your PostgreSQL password!

# Zaryah Setup Steps

## Current Status
✅ All dependencies installed
✅ Prisma client generated
✅ Flutter theme with dark gold design ready
⚠️ Database needs to be created

## Next Steps

### 1. Update PostgreSQL Password in .env

Open `.env` file and update the DATABASE_URL with your actual PostgreSQL password:

```
DATABASE_URL="postgresql://postgres:YOUR_PASSWORD_HERE@localhost:5432/zaryah?schema=public"
```

Replace `YOUR_PASSWORD_HERE` with your actual PostgreSQL password.

### 2. Create Database

You have two options:

**Option A: Using pgAdmin (Easiest)**
1. Open pgAdmin
2. Right-click on "Databases"
3. Click "Create" → "Database"
4. Enter database name: `zaryah`
5. Click "Save"

**Option B: Using PowerShell (if you know your postgres password)**
```powershell
$env:PGPASSWORD="your_password_here"
& "C:\Program Files\PostgreSQL\18\bin\psql.exe" -U postgres -c "CREATE DATABASE zaryah;"
```

### 3. Run Prisma Migrations

After creating the database, run:

```powershell
npx prisma migrate dev --name init
```

This will create all the necessary tables.

### 4. Seed Database with 30 Mock Users

```powershell
npm run seed
```

This will:
- Create 30 diverse users with complete profiles
- Sync all users to Pinecone vector database
- Display confirmation for each user created

### 5. Start Backend Server

```powershell
npm start
```

You should see:
```
✅ Pinecone initialized successfully
🚀 Zaryah backend server running on http://localhost:3000
```

### 6. Start Flutter App (New Terminal)

```powershell
cd flutter-app
flutter pub get
flutter run
```

### 7. Test the App

**Login credentials:**
- Email: `sarah.johnson@example.com`
- Password: `password123`

After login, you'll be immediately redirected to the chatbot screen where you can ask:
- "How many users do we have?"
- "Tell me about Sarah Johnson"
- "Which users are interested in Machine Learning?"

## Troubleshooting

### Error: "Can't connect to database"
- Make sure PostgreSQL is running
- Verify your password in `.env` is correct
- Check that database `zaryah` exists

### Error: "Pinecone initialization failed"
- The app will work fine, it will just use PostgreSQL instead
- All API keys are already configured in `.env`

### Error: "Port 3000 already in use"
```powershell
# Find process using port 3000
netstat -ano | findstr :3000
# Kill it (replace PID with actual process ID)
powershell -Command "Stop-Process -Id PID -Force"
```

## What's Already Configured

✅ **Google Gemini AI** - Free API, already configured
✅ **Pinecone Vector DB** - API key already configured
✅ **Dark Theme with Gold** - Beautiful UI ready
✅ **30 Mock Users** - Complete profiles ready to seed
✅ **JWT Authentication** - Secure login system ready
✅ **Complete Backend** - All endpoints implemented

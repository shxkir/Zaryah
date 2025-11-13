# Zaryah - Command Reference

## 🚀 Initial Setup Commands (Run Once)

```powershell
# 1. Fix the app name (Zarayah → Zaryah)
.\fix-app-name.ps1

# 2. Install dependencies
npm install

# 3. Create database (choose one method)
.\setup-database.ps1                                    # Easiest
# OR
& "C:\Program Files\PostgreSQL\16\bin\psql.exe" -U postgres -c "CREATE DATABASE zaryah;"

# 4. Generate Prisma client
npm run prisma:generate

# 5. Run database migrations
npm run prisma:migrate

# 6. Create 30 mock users
npm run seed

# 7. Test everything
npm test
```

---

## 💻 Daily Development Commands

### Start Backend Server
```powershell
npm start              # Production mode
# OR
npm run dev           # Development mode (auto-restart on changes)
```

### Run Flutter App
```powershell
cd flutter-app
flutter pub get       # Install dependencies (first time only)
flutter run          # Run the app
```

---

## 🔧 Utility Commands

### Database Management
```powershell
npm run prisma:studio     # Open visual database editor (http://localhost:5555)
npm run prisma:generate   # Regenerate Prisma client after schema changes
npm run prisma:migrate    # Apply database migrations
```

### Testing & Verification
```powershell
npm test                  # Test platform (verify 30 users exist)
npm run check            # Check environment configuration
```

### Data Management
```powershell
npm run seed             # Regenerate 30 mock users (if deleted)
```

---

## 📱 Flutter Commands

```powershell
cd flutter-app

# Install dependencies
flutter pub get

# Run app
flutter run

# Run on specific device
flutter devices                    # List available devices
flutter run -d <device-id>         # Run on specific device

# Build app
flutter build apk                  # Build Android APK
flutter build ios                  # Build iOS app (Mac only)

# Clean and rebuild
flutter clean
flutter pub get
flutter run
```

---

## 🗄️ PostgreSQL Commands

### Start/Stop PostgreSQL (Windows)
```powershell
# Start PostgreSQL service
net start postgresql-x64-16        # Replace 16 with your version

# Stop PostgreSQL service
net stop postgresql-x64-16

# Check status
sc query postgresql-x64-16
```

### Access Database
```powershell
# Using psql
& "C:\Program Files\PostgreSQL\16\bin\psql.exe" -U postgres -d zaryah

# Common SQL commands (inside psql):
\dt                                # List all tables
\d users                          # Describe users table
\d user_profiles                  # Describe user_profiles table
SELECT COUNT(*) FROM users;       # Count users
SELECT * FROM users LIMIT 5;     # Show first 5 users
\q                                # Quit psql
```

---

## 🧪 Testing API Endpoints

### Using curl (PowerShell)
```powershell
# Health check
curl http://localhost:3000/health

# Login (get JWT token)
curl -X POST http://localhost:3000/api/auth/login `
  -H "Content-Type: application/json" `
  -d '{\"email\":\"sarah.johnson@example.com\",\"password\":\"password123\"}'

# Get all users (requires JWT token)
curl -X GET http://localhost:3000/api/users `
  -H "Authorization: Bearer YOUR_JWT_TOKEN_HERE"

# Chatbot query (requires JWT token)
curl -X POST http://localhost:3000/api/chatbot `
  -H "Content-Type: application/json" `
  -H "Authorization: Bearer YOUR_JWT_TOKEN_HERE" `
  -d '{\"query\":\"Tell me about Sarah Johnson\"}'
```

---

## 🔑 Environment Configuration

### View Current Configuration
```powershell
# Show .env file contents
Get-Content .env

# Check specific variable
$env:PINECONE_API_KEY              # Should show your key
$env:ANTHROPIC_API_KEY             # Should show your key
```

### Edit Configuration
```powershell
notepad .env                       # Open in Notepad
# OR
code .env                          # Open in VS Code
```

---

## 🔄 Reset & Cleanup

### Reset Database
```powershell
# Drop and recreate database
& "C:\Program Files\PostgreSQL\16\bin\psql.exe" -U postgres -c "DROP DATABASE IF EXISTS zaryah;"
& "C:\Program Files\PostgreSQL\16\bin\psql.exe" -U postgres -c "CREATE DATABASE zaryah;"

# Re-run migrations and seed
npm run prisma:migrate
npm run seed
```

### Clear Node Modules
```powershell
# If having dependency issues
Remove-Item -Recurse -Force node_modules
npm install
npm run prisma:generate
```

### Clear Flutter Build
```powershell
cd flutter-app
flutter clean
flutter pub get
```

---

## 📊 Monitoring & Logs

### View Backend Logs
Backend logs appear in the terminal where you ran `npm start`

### View Database Activity
```powershell
npm run prisma:studio              # Visual database browser
```

### Check Running Processes
```powershell
# Check if backend is running
Get-Process -Name node | Where-Object {$_.Path -like "*zaryah*"}

# Kill backend process (if stuck)
Get-Process -Name node | Where-Object {$_.Path -like "*zaryah*"} | Stop-Process
```

---

## 🆘 Troubleshooting Commands

### Port Already in Use (3000)
```powershell
# Find what's using port 3000
netstat -ano | findstr :3000

# Kill process by PID (replace 1234 with actual PID)
taskkill /PID 1234 /F
```

### PostgreSQL Connection Issues
```powershell
# Test PostgreSQL connection
& "C:\Program Files\PostgreSQL\16\bin\psql.exe" -U postgres -c "SELECT version();"

# Check PostgreSQL status
sc query postgresql-x64-16

# Restart PostgreSQL
net stop postgresql-x64-16
net start postgresql-x64-16
```

### Prisma Issues
```powershell
# Reset Prisma
Remove-Item -Recurse -Force prisma\migrations
npm run prisma:generate
npm run prisma:migrate

# If schema.prisma was modified
npm run prisma:generate
npm run prisma:migrate
npm run seed
```

---

## 📦 Complete Fresh Start

If everything is broken, start fresh:

```powershell
# 1. Stop all processes
# Press Ctrl+C in all terminal windows

# 2. Drop database
& "C:\Program Files\PostgreSQL\16\bin\psql.exe" -U postgres -c "DROP DATABASE IF EXISTS zaryah;"

# 3. Clean everything
Remove-Item -Recurse -Force node_modules
Remove-Item -Recurse -Force prisma\migrations
cd flutter-app
flutter clean
cd ..

# 4. Reinstall everything
npm install
npm run prisma:generate

# 5. Create database
& "C:\Program Files\PostgreSQL\16\bin\psql.exe" -U postgres -c "CREATE DATABASE zaryah;"

# 6. Initialize
npm run prisma:migrate
npm run seed

# 7. Test
npm test

# 8. Start
npm start
```

---

## 🎯 Quick Reference

| Task | Command |
|------|---------|
| Start backend | `npm start` |
| Run Flutter app | `cd flutter-app && flutter run` |
| Create 30 users | `npm run seed` |
| Test platform | `npm test` |
| View database | `npm run prisma:studio` |
| Check environment | `npm run check` |
| Fix app name | `.\fix-app-name.ps1` |
| Reset database | See "Reset Database" section above |

---

## 📚 Need Help?

- **Start Here**: [START_HERE.md](START_HERE.md)
- **What is Anthropic?**: [WHAT_IS_ANTHROPIC_KEY.md](WHAT_IS_ANTHROPIC_KEY.md)
- **Full Docs**: [README.md](README.md)
- **API Docs**: [API_DOCUMENTATION.md](API_DOCUMENTATION.md)

# Zaryah - Quick Setup Guide

This guide will help you get Zaryah up and running in under 10 minutes.

## Prerequisites Checklist

- [ ] Node.js v18+ installed
- [ ] PostgreSQL v14+ installed and running
- [ ] Flutter v3.0+ installed
- [ ] Anthropic API key (get from https://console.anthropic.com/)
- [ ] Pinecone API key (get from https://www.pinecone.io/)

## Step-by-Step Setup

### 1. Environment Setup (2 minutes)

```bash
# Navigate to project
cd Zaryah

# Install backend dependencies
npm install

# Copy environment file
cp .env.example .env
```

Now edit `.env` with your credentials:
```env
DATABASE_URL="postgresql://YOUR_USER:YOUR_PASSWORD@localhost:5432/zaryah?schema=public"
JWT_SECRET="your-random-secret-key-here"
ANTHROPIC_API_KEY="sk-ant-xxxxx"  # Your Anthropic key
PINECONE_API_KEY="pcsk_xxxxx"     # Your Pinecone key
```

### 2. Database Setup (2 minutes)

```bash
# Create PostgreSQL database
createdb zaryah

# Run Prisma migrations
npm run prisma:generate
npm run prisma:migrate

# Generate 30 mock users
npm run seed
```

### 3. Start Backend (1 minute)

```bash
npm start
```

You should see:
```
✅ Pinecone initialized successfully
🚀 Zaryah backend server running on http://localhost:3000
```

### 4. Flutter App Setup (3 minutes)

Open a new terminal:

```bash
cd flutter-app

# Install Flutter dependencies
flutter pub get

# Run the app
flutter run
```

### 5. Test the App (2 minutes)

**Login with a mock user:**
- Email: `sarah.johnson@example.com`
- Password: `password123`

**Try the chatbot:**
- "Tell me about Sarah Johnson"
- "Which users are interested in Machine Learning?"
- "Compare Sarah and Michael"

## Quick Tips

### Backend is on different machine?
Edit `flutter-app/lib/services/api_service.dart`:
```dart
static const String baseUrl = 'http://YOUR_IP:3000/api';
```

### View database with GUI
```bash
npm run prisma:studio
```
Opens at http://localhost:5555

### Check if backend is working
Visit http://localhost:3000/health

### Reset everything
```bash
# Drop database
dropdb zaryah

# Recreate
createdb zaryah

# Re-run migrations and seed
npm run prisma:migrate
npm run seed
```

## Common Issues

### "Cannot connect to database"
- Make sure PostgreSQL is running: `pg_ctl status`
- Check DATABASE_URL in `.env`

### "Pinecone error"
- Verify PINECONE_API_KEY is correct
- App will fallback to PostgreSQL automatically

### Flutter can't connect to backend
- Use your computer's IP address (not localhost) for physical devices
- Make sure backend is running
- Check firewall allows port 3000

## All Set!

You now have:
- ✅ Backend server running with Pinecone + PostgreSQL
- ✅ 30 mock users ready to test
- ✅ Flutter app connected to backend
- ✅ Claude AI chatbot ready to answer questions

## Next Steps

- Create your own user account via signup
- Ask the chatbot about different users
- Explore the Prisma Studio to see the database
- Check the full README.md for detailed documentation

## Need Help?

- Check the full README.md
- Review API endpoints in README.md
- All mock users use password: `password123`

Happy learning with Zaryah!

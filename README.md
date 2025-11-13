# Zaryah - AI-Powered Education Platform

A comprehensive education platform with a Flutter mobile app, Node.js backend, PostgreSQL database, Pinecone vector database, and Claude Sonnet 4.5 AI integration.

## Features

- **Multi-step User Signup** (5 steps): Collect detailed user profiles including learning preferences, goals, and availability
- **JWT Authentication**: Secure login/signup with token-based authentication
- **AI Chatbot**: Claude Sonnet 4.5 powered chatbot with access to all user data stored in Pinecone
- **Vector Database**: Pinecone integration for efficient user data storage and retrieval
- **30 Mock Users**: Pre-generated diverse user profiles for testing
- **Material Design 3**: Modern, beautiful UI with Flutter

## Tech Stack

### Backend
- **Node.js** + **Express**: REST API server
- **PostgreSQL**: Primary relational database
- **Prisma ORM**: Type-safe database queries
- **Pinecone**: Vector database for user data embeddings
- **Claude API**: AI chatbot capabilities
- **bcrypt**: Password hashing
- **JWT**: Authentication tokens

### Frontend
- **Flutter**: Cross-platform mobile app
- **Material Design 3**: Modern UI components
- **SharedPreferences**: Local storage for JWT tokens
- **HTTP**: API communication

## Project Structure

```
Zaryah/
├── backend/
│   ├── server.js                 # Express server with all routes
│   ├── generateMockUsers.js      # Script to generate 30 mock users
│   └── pineconeUtils.js          # Pinecone integration utilities
├── prisma/
│   └── schema.prisma             # Database schema
├── flutter-app/
│   ├── lib/
│   │   ├── main.dart             # App entry point with auto-login
│   │   ├── screens/
│   │   │   ├── login_screen.dart     # Login screen
│   │   │   ├── signup_screen.dart    # 5-step signup flow
│   │   │   └── chatbot_screen.dart   # AI chatbot interface
│   │   └── services/
│   │       └── api_service.dart      # API communication
│   └── pubspec.yaml
├── package.json
├── .env.example
└── README.md
```

## Getting Started

### Prerequisites

- Node.js (v18 or higher)
- PostgreSQL (v14 or higher)
- Flutter (v3.0 or higher)
- Anthropic API key
- Pinecone API key

### Backend Setup

1. **Clone the repository**
   ```bash
   cd Zaryah
   ```

2. **Install dependencies**
   ```bash
   npm install
   ```

3. **Set up environment variables**
   ```bash
   cp .env.example .env
   ```

   Edit `.env` and add your credentials:
   ```env
   DATABASE_URL="postgresql://username:password@localhost:5432/zaryah?schema=public"
   JWT_SECRET="your-super-secret-jwt-key"
   ANTHROPIC_API_KEY="your-anthropic-api-key"
   PINECONE_API_KEY="your-pinecone-api-key"
   ```

4. **Set up PostgreSQL database**
   ```bash
   # Create database
   createdb zaryah

   # Or using psql
   psql -U postgres
   CREATE DATABASE zaryah;
   ```

5. **Run Prisma migrations**
   ```bash
   npm run prisma:generate
   npm run prisma:migrate
   ```

6. **Generate mock users** (30 diverse users)
   ```bash
   npm run seed
   ```
   All mock users have the password: `password123`

7. **Start the backend server**
   ```bash
   npm start
   # Or for development with auto-reload
   npm run dev
   ```

   Server will run on `http://localhost:3000`

### Flutter App Setup

1. **Navigate to Flutter app directory**
   ```bash
   cd flutter-app
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Update API URL** (if needed)
   Edit `lib/services/api_service.dart` and update `baseUrl` if your backend runs on a different host:
   ```dart
   static const String baseUrl = 'http://YOUR_IP:3000/api';
   ```

4. **Run the app**
   ```bash
   flutter run
   ```

## API Endpoints

### Authentication

**POST** `/api/auth/signup`
- Creates user and profile
- Returns JWT token
- Body: All signup fields (name, email, password, age, education, etc.)

**POST** `/api/auth/login`
- Authenticates user
- Returns JWT token
- Body: `{ email, password }`

### Users (Protected)

**GET** `/api/users`
- Returns all users with profiles
- Requires: `Authorization: Bearer <token>`

**GET** `/api/users/:identifier`
- Get user by ID or email
- Requires: `Authorization: Bearer <token>`

### Chatbot (Protected)

**POST** `/api/chatbot`
- Sends query to Claude with user data context from Pinecone
- Returns AI response
- Requires: `Authorization: Bearer <token>`
- Body: `{ query: "your question" }`

### Health Check

**GET** `/health`
- Returns server status

## User Signup Flow (5 Steps)

1. **Basic Info**: Name, email, password, age
2. **Education & Occupation**: Education level, current occupation
3. **Learning Preferences**: Learning goals, subjects of interest (multi-select), learning style
4. **Experience & Challenges**: Previous experience, strengths, weaknesses, specific challenges
5. **Time & Pace**: Available hours per week (1-40 slider), learning pace, motivation level

## Database Schema

### User Table
- `id` (UUID, primary key)
- `email` (unique)
- `password` (hashed with bcrypt)
- `createdAt`

### UserProfile Table (1:1 with User)
- All signup fields
- `subjects` as string array
- Cascading delete on user deletion

## Pinecone Integration

User data is stored in Pinecone vector database for efficient retrieval:
- Automatic embedding generation from user profiles
- Bulk upsert during seeding
- Real-time storage on signup
- Fallback to PostgreSQL if Pinecone is unavailable

## Claude AI Chatbot

The chatbot has access to the complete user database and can:
- Answer questions about specific users
- Find users by interests or criteria
- Compare users
- Generate statistics
- Provide insights about the user base

**Example queries:**
- "Tell me about Sarah Johnson"
- "Which users are interested in Machine Learning?"
- "Compare Sarah Johnson and Michael Chen"
- "Show me statistics about learning styles"
- "Who has the most available hours per week?"

## Mock Users

30 diverse mock users are included:
- Ages: 19-45
- Occupations: Developers, designers, students, managers, teachers, etc.
- Various education levels, learning goals, subjects, and styles
- Password for all: `password123`

Sample users:
- Sarah Johnson (Software Developer, 28)
- Michael Chen (Data Scientist, 32)
- Emily Rodriguez (UX Designer, 24)
- David Kim (Student, 19)
- ...and 26 more!

## Development Commands

```bash
# Backend
npm start              # Start server
npm run dev            # Start with nodemon (auto-reload)
npm run seed           # Generate mock users
npm run prisma:generate # Generate Prisma client
npm run prisma:migrate  # Run migrations
npm run prisma:studio   # Open Prisma Studio (DB GUI)

# Flutter
flutter pub get        # Install dependencies
flutter run            # Run app
flutter build apk      # Build Android APK
flutter build ios      # Build iOS app
```

## Security Features

- **Password Hashing**: bcrypt with salt rounds
- **JWT Authentication**: 7-day expiration
- **Protected Routes**: All user and chatbot endpoints require valid JWT
- **CORS Enabled**: Cross-origin requests supported
- **Input Validation**: Server-side validation for all endpoints

## Environment Variables

| Variable | Description | Required |
|----------|-------------|----------|
| `DATABASE_URL` | PostgreSQL connection string | Yes |
| `JWT_SECRET` | Secret key for JWT signing | Yes |
| `ANTHROPIC_API_KEY` | Claude API key | Yes |
| `PINECONE_API_KEY` | Pinecone API key | Yes |
| `PORT` | Server port (default: 3000) | No |

## Troubleshooting

### Backend won't start
- Check PostgreSQL is running
- Verify DATABASE_URL is correct
- Ensure all environment variables are set
- Run `npm run prisma:generate`

### Prisma migration errors
- Delete `prisma/migrations` folder
- Drop and recreate the database
- Run `npm run prisma:migrate` again

### Flutter app can't connect to backend
- Update `baseUrl` in `api_service.dart`
- Use your computer's IP address (not localhost) for physical devices
- Ensure backend is running
- Check firewall settings

### Pinecone connection issues
- Verify PINECONE_API_KEY is correct
- Check Pinecone index region matches code
- App will fallback to PostgreSQL if Pinecone fails

### Mock users not created
- Ensure database is migrated
- Check for existing users with same emails
- Verify Pinecone is initialized

## Testing Credentials

Use any of the 30 mock users or create your own:
- **Email**: sarah.johnson@example.com
- **Password**: password123

Or login with any other mock user email (see backend console after running seed).

## License

MIT

## Author

Built with Claude Code
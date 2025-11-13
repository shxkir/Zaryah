# 🔄 Zaryah Complete User Flow

## Visual Flow Diagram

```
┌─────────────────────────────────────────────────────────────────────┐
│                         USER OPENS ZARYAH APP                        │
└────────────────────────────┬────────────────────────────────────────┘
                             │
                             ▼
                  ┌──────────────────────┐
                  │   Splash Screen      │
                  │   (Zaryah Logo)      │
                  │   1 second           │
                  └──────────┬───────────┘
                             │
                             ▼
                  ┌──────────────────────┐
                  │   Check JWT Token    │
                  │   in SharedPrefs     │
                  └──────────┬───────────┘
                             │
                ┌────────────┴────────────┐
                │                         │
         No Token                   Has Token
                │                         │
                ▼                         ▼
    ┌───────────────────┐     ┌───────────────────┐
    │  Login Screen     │     │  Chatbot Screen   │
    │                   │     │  (Direct Access)  │
    └─────────┬─────────┘     └───────────────────┘
              │
              │ User enters:
              │ sarah.johnson@example.com
              │ password123
              │
              ▼
    ┌───────────────────┐
    │ POST /api/auth/   │
    │      login        │
    └─────────┬─────────┘
              │
              │ Returns:
              │ - JWT Token
              │ - User Profile
              │
              ▼
    ┌───────────────────┐
    │ Save Token to     │
    │ SharedPrefs       │
    └─────────┬─────────┘
              │
              ▼
    ┌───────────────────────────────────────────┐
    │        CHATBOT SCREEN                     │
    │  ┌─────────────────────────────────────┐  │
    │  │ "Hello! I'm Zaryah AI assistant..." │  │
    │  └─────────────────────────────────────┘  │
    │                                           │
    │  ┌─────────────────────────────────────┐  │
    │  │ [Message Input Field]               │  │
    │  │ [Send Button]                       │  │
    │  └─────────────────────────────────────┘  │
    └───────────────────┬───────────────────────┘
                        │
          User Types: "Tell me about Sarah Johnson"
                        │
                        ▼
          ┌─────────────────────────────┐
          │ POST /api/chatbot           │
          │ Authorization: Bearer TOKEN │
          │ Body: { query: "..." }      │
          └──────────┬──────────────────┘
                     │
                     ▼
          ┌─────────────────────────────┐
          │ Backend: Verify JWT         │
          └──────────┬──────────────────┘
                     │
                     ▼
          ┌─────────────────────────────┐
          │ Query Pinecone Vector DB    │
          │ → Get all 30 users          │
          └──────────┬──────────────────┘
                     │
                     ▼
          ┌─────────────────────────────┐
          │ If Pinecone fails:          │
          │ Fallback to PostgreSQL      │
          │ → Get all 30 users          │
          └──────────┬──────────────────┘
                     │
                     │ usersData = [30 users with
                     │              complete profiles]
                     │
                     ▼
          ┌─────────────────────────────────────────┐
          │ Build Prompt for Google Gemini:         │
          │                                         │
          │ "You are Zaryah AI assistant.          │
          │                                         │
          │ User Database:                          │
          │ [JSON of all 30 users]                 │
          │                                         │
          │ User Question: Tell me about Sarah..." │
          └──────────┬──────────────────────────────┘
                     │
                     ▼
          ┌─────────────────────────────┐
          │ POST to Google Gemini API   │
          │ Model: gemini-pro           │
          │ API Key: AIzaSyBF...        │
          └──────────┬──────────────────┘
                     │
                     │ Gemini analyzes:
                     │ - All 30 users data
                     │ - User's question
                     │ - Returns detailed answer
                     │
                     ▼
          ┌─────────────────────────────┐
          │ Gemini Response:            │
          │                             │
          │ "Sarah Johnson:             │
          │  • Age: 28                  │
          │  • Email: sarah.johnson...  │
          │  • Occupation: Software Dev │
          │  • Learning Goals: Master...│
          │  • Subjects: Web Dev, Cloud │
          │  • Experience: 3 years...   │
          │  • Strengths: Quick learner │
          │  • Challenges: Distributed  │
          │  • Available: 15 hrs/week   │
          │  • Pace: Fast               │
          │  • Motivation: High"        │
          └──────────┬──────────────────┘
                     │
                     ▼
          ┌─────────────────────────────┐
          │ Backend Returns to Flutter: │
          │ {                           │
          │   query: "Tell me...",      │
          │   response: "Sarah...",     │
          │   timestamp: "...",         │
          │   dataSource: "pinecone"    │
          │ }                           │
          └──────────┬──────────────────┘
                     │
                     ▼
          ┌─────────────────────────────┐
          │ Flutter Displays Response   │
          │ in Chat Bubble              │
          │                             │
          │ 🤖: "Sarah Johnson:         │
          │      • Age: 28              │
          │      • Email: sarah..."     │
          │      ... (full details)     │
          └─────────────────────────────┘
                     │
                     ▼
          ┌─────────────────────────────┐
          │ User Asks Another Question  │
          │ (Repeat chatbot flow)       │
          └─────────────────────────────┘
```

---

## Key Components

### 1. Data Storage (30 Users)

```
PostgreSQL                     Pinecone Vector DB
┌──────────────┐              ┌──────────────────┐
│ users table  │              │ zaryah-users     │
│ - id         │──sync to──→  │ index            │
│ - email      │              │                  │
│ - password   │              │ Vectors:         │
│              │              │ - User 1 (Sarah) │
│user_profiles │              │ - User 2 (Michael)│
│- name        │              │ ... 30 total     │
│- age         │              │                  │
│- education   │              │ Metadata:        │
│- occupation  │              │ - All profile    │
│- subjects[]  │              │   fields stored  │
│- goals       │              │   as metadata    │
│- experience  │              │                  │
│- strengths   │              │                  │
│- weaknesses  │              │                  │
│- challenges  │              │                  │
│- hours/week  │              │                  │
│- pace        │              │                  │
│- motivation  │              │                  │
└──────────────┘              └──────────────────┘
```

### 2. Authentication Flow

```
Flutter App          Backend Server        Database
    │                      │                   │
    │  Login Request       │                   │
    ├─────────────────────>│                   │
    │  email + password    │   Find User       │
    │                      ├──────────────────>│
    │                      │   Return User     │
    │                      │<──────────────────┤
    │                      │                   │
    │                      │ Verify Password   │
    │                      │ (bcrypt compare)  │
    │                      │                   │
    │                      │ Generate JWT      │
    │                      │                   │
    │  JWT Token + User    │                   │
    │<─────────────────────┤                   │
    │                      │                   │
    │ Save to SharedPrefs  │                   │
    │                      │                   │
    │ Navigate to Chatbot  │                   │
    │                      │                   │
```

### 3. Chatbot Query Flow

```
User Types Question
       │
       ▼
┌──────────────┐
│ Flutter App  │
│ Sends:       │
│ - JWT Token  │
│ - User Query │
└──────┬───────┘
       │
       ▼
┌──────────────────────────────────────────┐
│         Backend Server                   │
│  1. Verify JWT                           │
│  2. Query Pinecone (get 30 users)        │
│  3. Build context with all user data     │
│  4. Send to Google Gemini                │
│  5. Return Gemini's response             │
└──────┬───────────────────────────────────┘
       │
       ▼
┌──────────────┐
│ Google Gemini│
│ Analyzes:    │
│ - 30 users   │
│ - Question   │
│ Returns:     │
│ - Answer     │
└──────┬───────┘
       │
       ▼
┌──────────────┐
│ Flutter App  │
│ Displays in  │
│ Chat Bubble  │
└──────────────┘
```

---

## Data Flow Example

### Question: "Which users are interested in Machine Learning?"

```
1. USER TYPES in Flutter:
   "Which users are interested in Machine Learning?"

2. FLUTTER SENDS to Backend:
   POST /api/chatbot
   Headers: { Authorization: "Bearer eyJhbG..." }
   Body: { query: "Which users are interested in Machine Learning?" }

3. BACKEND RECEIVES:
   ✓ Verifies JWT token
   ✓ User authenticated

4. BACKEND QUERIES PINECONE:
   ✓ Retrieves all 30 users with metadata
   ✓ Each user has subjects array in metadata

5. BACKEND BUILDS CONTEXT:
   30 users JSON including:
   - Michael Chen: [Machine Learning, Deep Learning, ...]
   - Lisa Wang: [NLP, Machine Learning, Deep Learning, ...]
   - ... (all 30 users)

6. BACKEND SENDS TO GEMINI:
   "You are Zaryah AI assistant.

   User Database: [30 users JSON]

   Question: Which users are interested in Machine Learning?"

7. GEMINI PROCESSES:
   ✓ Searches through all 30 users
   ✓ Filters by "Machine Learning" in subjects
   ✓ Finds: Michael Chen, Lisa Wang, etc.
   ✓ Formats response with details

8. GEMINI RETURNS:
   "Users interested in Machine Learning:

   1. Michael Chen (Data Scientist, 32)
      - Subjects: Machine Learning, Deep Learning...
      - Goals: Advance ML skills and learn MLOps
      - Experience: 5 years in data analytics...

   2. Lisa Wang (AI Researcher, 25)
      - Subjects: NLP, Machine Learning...
      - Goals: Advance in natural language processing
      - Experience: Master's thesis on NLP..."

9. BACKEND RETURNS TO FLUTTER:
   {
     query: "Which users...",
     response: "Users interested in...",
     timestamp: "...",
     dataSource: "pinecone"
   }

10. FLUTTER DISPLAYS:
    Shows response in chat bubble with formatting
```

---

## Success Indicators

✅ **Login Flow**: Login → Immediately see chatbot (no extra screens)
✅ **Data Access**: Chatbot has access to all 30 users from Pinecone
✅ **Accurate Answers**: All queries return correct information
✅ **Complete Details**: Responses include ALL profile fields
✅ **Fast Response**: 2-5 seconds per query
✅ **Seamless UX**: No errors, smooth conversation flow

---

This is the EXACT flow your Zaryah app follows! 🚀

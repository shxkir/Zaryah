# Zaryah API Documentation

Base URL: `http://localhost:3000/api`

## Table of Contents
- [Authentication](#authentication)
- [User Management](#user-management)
- [AI Chatbot](#ai-chatbot)
- [Error Handling](#error-handling)
- [Example Requests](#example-requests)

---

## Authentication

All protected endpoints require a JWT token in the Authorization header:
```
Authorization: Bearer <your-jwt-token>
```

### POST /auth/signup

Create a new user account with complete profile.

**Request Body:**
```json
{
  "email": "user@example.com",
  "password": "securePassword123",
  "name": "John Doe",
  "age": 25,
  "educationLevel": "Bachelor's",
  "occupation": "Software Developer",
  "learningGoals": "Master full-stack development",
  "subjects": ["Web Development", "Cloud Computing"],
  "learningStyle": "Visual",
  "previousExperience": "2 years of frontend development",
  "strengths": "Quick learner, problem solver",
  "weaknesses": "Limited backend experience",
  "specificChallenges": "Understanding microservices",
  "availableHoursPerWeek": 15,
  "learningPace": "Fast",
  "motivationLevel": "High"
}
```

**Response (201):**
```json
{
  "message": "User created successfully",
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "user": {
    "id": "uuid-here",
    "email": "user@example.com",
    "createdAt": "2024-01-01T00:00:00.000Z",
    "profile": {
      "id": "uuid-here",
      "userId": "uuid-here",
      "name": "John Doe",
      "age": 25,
      "educationLevel": "Bachelor's",
      "occupation": "Software Developer",
      "learningGoals": "Master full-stack development",
      "subjects": ["Web Development", "Cloud Computing"],
      "learningStyle": "Visual",
      "previousExperience": "2 years of frontend development",
      "strengths": "Quick learner, problem solver",
      "weaknesses": "Limited backend experience",
      "specificChallenges": "Understanding microservices",
      "availableHoursPerWeek": 15,
      "learningPace": "Fast",
      "motivationLevel": "High",
      "createdAt": "2024-01-01T00:00:00.000Z",
      "updatedAt": "2024-01-01T00:00:00.000Z"
    }
  }
}
```

**Errors:**
- `400`: Missing required fields or user already exists
- `500`: Internal server error

---

### POST /auth/login

Authenticate an existing user.

**Request Body:**
```json
{
  "email": "user@example.com",
  "password": "securePassword123"
}
```

**Response (200):**
```json
{
  "message": "Login successful",
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "user": {
    "id": "uuid-here",
    "email": "user@example.com",
    "createdAt": "2024-01-01T00:00:00.000Z",
    "profile": { /* full profile object */ }
  }
}
```

**Errors:**
- `400`: Email and password required
- `401`: Invalid email or password
- `500`: Internal server error

---

## User Management

### GET /users

Get all users with their profiles.

**Headers:**
```
Authorization: Bearer <jwt-token>
```

**Response (200):**
```json
{
  "users": [
    {
      "id": "uuid-1",
      "email": "user1@example.com",
      "createdAt": "2024-01-01T00:00:00.000Z",
      "profile": { /* profile object */ }
    },
    {
      "id": "uuid-2",
      "email": "user2@example.com",
      "createdAt": "2024-01-01T00:00:00.000Z",
      "profile": { /* profile object */ }
    }
  ]
}
```

**Errors:**
- `401`: Access token required
- `403`: Invalid or expired token
- `500`: Internal server error

---

### GET /users/:identifier

Get a specific user by ID or email.

**Headers:**
```
Authorization: Bearer <jwt-token>
```

**Parameters:**
- `identifier` (path): User ID (UUID) or email address

**Example:**
```
GET /api/users/sarah.johnson@example.com
GET /api/users/123e4567-e89b-12d3-a456-426614174000
```

**Response (200):**
```json
{
  "user": {
    "id": "uuid-here",
    "email": "sarah.johnson@example.com",
    "createdAt": "2024-01-01T00:00:00.000Z",
    "profile": {
      "id": "uuid-here",
      "userId": "uuid-here",
      "name": "Sarah Johnson",
      "age": 28,
      "educationLevel": "Bachelor's",
      "occupation": "Software Developer",
      "learningGoals": "Master full-stack development",
      "subjects": ["Web Development", "Cloud Computing"],
      "learningStyle": "Visual",
      "previousExperience": "3 years of frontend development",
      "strengths": "Quick learner, problem-solving",
      "weaknesses": "Limited backend experience",
      "specificChallenges": "Understanding distributed systems",
      "availableHoursPerWeek": 15,
      "learningPace": "Fast",
      "motivationLevel": "High",
      "createdAt": "2024-01-01T00:00:00.000Z",
      "updatedAt": "2024-01-01T00:00:00.000Z"
    }
  }
}
```

**Errors:**
- `401`: Access token required
- `403`: Invalid or expired token
- `404`: User not found
- `500`: Internal server error

---

## AI Chatbot

### POST /chatbot

Send a query to the Claude AI chatbot. The chatbot has access to all user data stored in Pinecone and can answer questions about users, their profiles, interests, and statistics.

**Headers:**
```
Authorization: Bearer <jwt-token>
```

**Request Body:**
```json
{
  "query": "Which users are interested in Machine Learning?"
}
```

**Response (200):**
```json
{
  "query": "Which users are interested in Machine Learning?",
  "response": "Based on the user database, here are the users interested in Machine Learning:\n\n1. **Michael Chen** (Data Scientist, 32)\n   - Subjects: Machine Learning, Deep Learning, Data Engineering, Python\n   - Learning Goals: Advance machine learning skills and learn MLOps\n   - Motivation: High\n\n2. **Lisa Wang** (AI Researcher, 25)\n   - Subjects: Natural Language Processing, Machine Learning, Deep Learning, Python\n   - Learning Goals: Advance in natural language processing\n   - Motivation: High\n\nBoth users have high motivation levels and are actively seeking to improve their machine learning expertise.",
  "timestamp": "2024-01-01T00:00:00.000Z",
  "dataSource": "pinecone"
}
```

**Example Queries:**
- "Tell me about Sarah Johnson"
- "Which users are interested in Machine Learning?"
- "Compare Sarah Johnson and Michael Chen"
- "Show me statistics about learning styles"
- "Who has the most available hours per week?"
- "Find users who are students"
- "What's the average age of users interested in Web Development?"

**Errors:**
- `400`: Query is required
- `401`: Access token required
- `403`: Invalid or expired token
- `500`: Internal server error

---

## Health Check

### GET /health

Check if the server is running.

**No authentication required**

**Response (200):**
```json
{
  "status": "ok",
  "message": "Zaryah API is running"
}
```

---

## Error Handling

All errors follow this format:

```json
{
  "error": "Error message here",
  "details": "Additional error details (only in development)"
}
```

### HTTP Status Codes

- `200` - Success
- `201` - Created
- `400` - Bad Request (validation error)
- `401` - Unauthorized (no token)
- `403` - Forbidden (invalid token)
- `404` - Not Found
- `500` - Internal Server Error

---

## Example Requests

### cURL Examples

**Signup:**
```bash
curl -X POST http://localhost:3000/api/auth/signup \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "password123",
    "name": "Test User",
    "age": 25,
    "educationLevel": "Bachelor'\''s",
    "occupation": "Developer",
    "learningGoals": "Learn new skills",
    "subjects": ["Web Development"],
    "learningStyle": "Visual",
    "previousExperience": "None",
    "strengths": "Fast learner",
    "weaknesses": "Limited experience",
    "specificChallenges": "Time management",
    "availableHoursPerWeek": 10,
    "learningPace": "Medium",
    "motivationLevel": "High"
  }'
```

**Login:**
```bash
curl -X POST http://localhost:3000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "sarah.johnson@example.com",
    "password": "password123"
  }'
```

**Get All Users:**
```bash
curl -X GET http://localhost:3000/api/users \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

**Chatbot Query:**
```bash
curl -X POST http://localhost:3000/api/chatbot \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -d '{
    "query": "Tell me about Sarah Johnson"
  }'
```

### JavaScript (Fetch API) Examples

**Signup:**
```javascript
const response = await fetch('http://localhost:3000/api/auth/signup', {
  method: 'POST',
  headers: {
    'Content-Type': 'application/json',
  },
  body: JSON.stringify({
    email: 'test@example.com',
    password: 'password123',
    name: 'Test User',
    age: 25,
    educationLevel: "Bachelor's",
    occupation: 'Developer',
    learningGoals: 'Learn new skills',
    subjects: ['Web Development'],
    learningStyle: 'Visual',
    previousExperience: 'None',
    strengths: 'Fast learner',
    weaknesses: 'Limited experience',
    specificChallenges: 'Time management',
    availableHoursPerWeek: 10,
    learningPace: 'Medium',
    motivationLevel: 'High'
  })
});

const data = await response.json();
console.log(data);
```

**Login:**
```javascript
const response = await fetch('http://localhost:3000/api/auth/login', {
  method: 'POST',
  headers: {
    'Content-Type': 'application/json',
  },
  body: JSON.stringify({
    email: 'sarah.johnson@example.com',
    password: 'password123'
  })
});

const data = await response.json();
const token = data.token;
```

**Chatbot Query:**
```javascript
const response = await fetch('http://localhost:3000/api/chatbot', {
  method: 'POST',
  headers: {
    'Content-Type': 'application/json',
    'Authorization': `Bearer ${token}`
  },
  body: JSON.stringify({
    query: 'Which users are interested in Machine Learning?'
  })
});

const data = await response.json();
console.log(data.response);
```

---

## Rate Limiting

Currently, there is no rate limiting implemented. Consider adding rate limiting in production.

## CORS

CORS is enabled for all origins. In production, restrict to specific domains.

## Security Notes

- All passwords are hashed using bcrypt
- JWT tokens expire after 7 days
- Sensitive routes require authentication
- Never expose your `JWT_SECRET` or API keys
- Use HTTPS in production

---

For more information, see the main [README.md](README.md)

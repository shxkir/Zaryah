require('dotenv').config();
const express = require('express');
const cors = require('cors');
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const { PrismaClient } = require('@prisma/client');
const { GoogleGenerativeAI } = require('@google/generative-ai');
const {
  initializePineconeIndex,
  storeUserInPinecone,
  queryUsersFromPinecone,
  getAllUsersFromPinecone,
} = require('./pineconeUtils');

const app = express();
const prisma = new PrismaClient();
const genAI = new GoogleGenerativeAI(process.env.GOOGLE_API_KEY);

const PORT = process.env.PORT || 3000;
const JWT_SECRET = process.env.JWT_SECRET || 'your-secret-key-change-in-production';

// Initialize Pinecone on startup
let pineconeReady = false;
initializePineconeIndex()
  .then(() => {
    pineconeReady = true;
    console.log('✅ Pinecone initialized successfully');
  })
  .catch(err => {
    console.error('❌ Failed to initialize Pinecone:', err);
  });

// Middleware
app.use(cors());
app.use(express.json());

// JWT Authentication Middleware
const authenticateToken = (req, res, next) => {
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1];

  if (!token) {
    return res.status(401).json({ error: 'Access token required' });
  }

  jwt.verify(token, JWT_SECRET, (err, user) => {
    if (err) {
      return res.status(403).json({ error: 'Invalid or expired token' });
    }
    req.user = user;
    next();
  });
};

// Routes

// POST /api/auth/signup - Create user and profile
app.post('/api/auth/signup', async (req, res) => {
  try {
    const {
      email,
      password,
      name,
      age,
      educationLevel,
      occupation,
      learningGoals,
      subjects,
      learningStyle,
      previousExperience,
      strengths,
      weaknesses,
      specificChallenges,
      availableHoursPerWeek,
      learningPace,
      motivationLevel,
    } = req.body;

    // Validate required fields
    if (!email || !password || !name || !age) {
      return res.status(400).json({ error: 'Missing required fields' });
    }

    // Check if user already exists
    const existingUser = await prisma.user.findUnique({
      where: { email },
    });

    if (existingUser) {
      return res.status(400).json({ error: 'User with this email already exists' });
    }

    // Hash password
    const hashedPassword = await bcrypt.hash(password, 10);

    // Create user and profile in a transaction
    const user = await prisma.user.create({
      data: {
        email,
        password: hashedPassword,
        profile: {
          create: {
            name,
            age: parseInt(age),
            educationLevel: educationLevel || '',
            occupation: occupation || '',
            learningGoals: learningGoals || '',
            subjects: subjects || [],
            learningStyle: learningStyle || '',
            previousExperience: previousExperience || '',
            strengths: strengths || '',
            weaknesses: weaknesses || '',
            specificChallenges: specificChallenges || '',
            availableHoursPerWeek: parseInt(availableHoursPerWeek) || 5,
            learningPace: learningPace || 'Medium',
            motivationLevel: motivationLevel || 'Medium',
          },
        },
      },
      include: {
        profile: true,
      },
    });

    // Store user in Pinecone
    if (pineconeReady) {
      try {
        await storeUserInPinecone(user);
      } catch (pineconeError) {
        console.error('Error storing user in Pinecone:', pineconeError);
        // Continue even if Pinecone fails
      }
    }

    // Generate JWT token
    const token = jwt.sign(
      { userId: user.id, email: user.email },
      JWT_SECRET,
      { expiresIn: '7d' }
    );

    // Remove password from response
    const { password: _, ...userWithoutPassword } = user;

    res.status(201).json({
      message: 'User created successfully',
      token,
      user: userWithoutPassword,
    });
  } catch (error) {
    console.error('Signup error:', error);
    res.status(500).json({ error: 'Internal server error', details: error.message });
  }
});

// POST /api/auth/login - Authenticate user
app.post('/api/auth/login', async (req, res) => {
  try {
    const { email, password } = req.body;

    if (!email || !password) {
      return res.status(400).json({ error: 'Email and password are required' });
    }

    // Find user
    const user = await prisma.user.findUnique({
      where: { email },
      include: { profile: true },
    });

    if (!user) {
      return res.status(401).json({ error: 'Invalid email or password' });
    }

    // Verify password
    const validPassword = await bcrypt.compare(password, user.password);

    if (!validPassword) {
      return res.status(401).json({ error: 'Invalid email or password' });
    }

    // Generate JWT token
    const token = jwt.sign(
      { userId: user.id, email: user.email },
      JWT_SECRET,
      { expiresIn: '7d' }
    );

    // Remove password from response
    const { password: _, ...userWithoutPassword } = user;

    res.json({
      message: 'Login successful',
      token,
      user: userWithoutPassword,
    });
  } catch (error) {
    console.error('Login error:', error);
    res.status(500).json({ error: 'Internal server error', details: error.message });
  }
});

// GET /api/users - Get all users with profiles (protected)
app.get('/api/users', authenticateToken, async (req, res) => {
  try {
    const users = await prisma.user.findMany({
      include: { profile: true },
      select: {
        id: true,
        email: true,
        createdAt: true,
        profile: true,
      },
    });

    res.json({ users });
  } catch (error) {
    console.error('Get users error:', error);
    res.status(500).json({ error: 'Internal server error', details: error.message });
  }
});

// GET /api/users/:identifier - Get user by ID or email (protected)
app.get('/api/users/:identifier', authenticateToken, async (req, res) => {
  try {
    const { identifier } = req.params;

    // Try to find by ID first, then by email
    let user = await prisma.user.findUnique({
      where: { id: identifier },
      include: { profile: true },
      select: {
        id: true,
        email: true,
        createdAt: true,
        profile: true,
      },
    });

    if (!user) {
      user = await prisma.user.findUnique({
        where: { email: identifier },
        include: { profile: true },
        select: {
          id: true,
          email: true,
          createdAt: true,
          profile: true,
        },
      });
    }

    if (!user) {
      return res.status(404).json({ error: 'User not found' });
    }

    res.json({ user });
  } catch (error) {
    console.error('Get user error:', error);
    res.status(500).json({ error: 'Internal server error', details: error.message });
  }
});

// POST /api/chatbot - Send query to Claude with user data context from Pinecone (protected)
app.post('/api/chatbot', authenticateToken, async (req, res) => {
  try {
    const { query } = req.body;

    if (!query) {
      return res.status(400).json({ error: 'Query is required' });
    }

    let usersData;

    // Try to get data from Pinecone first, fallback to PostgreSQL
    if (pineconeReady) {
      try {
        // Get all users from Pinecone
        const pineconeUsers = await getAllUsersFromPinecone();

        if (pineconeUsers && pineconeUsers.length > 0) {
          // Use Pinecone data
          usersData = pineconeUsers.map(pu => ({
            id: pu.id,
            email: pu.metadata.email,
            createdAt: pu.metadata.createdAt,
            profile: {
              name: pu.metadata.name,
              age: pu.metadata.age,
              educationLevel: pu.metadata.educationLevel,
              occupation: pu.metadata.occupation,
              learningGoals: pu.metadata.learningGoals,
              subjects: pu.metadata.subjects,
              learningStyle: pu.metadata.learningStyle,
              previousExperience: pu.metadata.previousExperience,
              strengths: pu.metadata.strengths,
              weaknesses: pu.metadata.weaknesses,
              specificChallenges: pu.metadata.specificChallenges,
              availableHoursPerWeek: pu.metadata.availableHoursPerWeek,
              learningPace: pu.metadata.learningPace,
              motivationLevel: pu.metadata.motivationLevel,
            }
          }));
          console.log(`✅ Retrieved ${usersData.length} users from Pinecone`);
        } else {
          throw new Error('No users in Pinecone');
        }
      } catch (pineconeError) {
        console.error('Pinecone retrieval failed, falling back to PostgreSQL:', pineconeError);
        // Fallback to PostgreSQL
        const users = await prisma.user.findMany({
          include: { profile: true },
          select: {
            id: true,
            email: true,
            createdAt: true,
            profile: true,
          },
        });
        usersData = users;
      }
    } else {
      // Pinecone not ready, use PostgreSQL
      const users = await prisma.user.findMany({
        include: { profile: true },
        select: {
          id: true,
          email: true,
          createdAt: true,
          profile: true,
        },
      });
      usersData = users;
    }

    // Create prompt with user data context for Gemini
    const prompt = `You are an AI assistant for Zaryah, an educational platform. You have access to user data and can answer questions about users and their learning profiles.

Here is the complete user database:

${JSON.stringify(usersData, null, 2)}

Answer questions about users, their learning profiles, interests, goals, and statistics. Provide detailed, structured, and helpful responses. When comparing users or showing statistics, format your response clearly with relevant details.

User Question: ${query}`;

    // Call Google Gemini API
    const model = genAI.getGenerativeModel({ model: 'gemini-pro' });
    const result = await model.generateContent(prompt);
    const response = result.response.text();

    res.json({
      query,
      response,
      timestamp: new Date().toISOString(),
      dataSource: pineconeReady ? 'pinecone' : 'postgresql',
    });
  } catch (error) {
    console.error('Chatbot error:', error);
    res.status(500).json({ error: 'Internal server error', details: error.message });
  }
});

// Health check endpoint
app.get('/health', (req, res) => {
  res.json({ status: 'ok', message: 'Zaryah API is running' });
});

// Start server
app.listen(PORT, () => {
  console.log(`🚀 Zaryah backend server running on http://localhost:${PORT}`);
});

// Graceful shutdown
process.on('SIGINT', async () => {
  await prisma.$disconnect();
  process.exit(0);
});

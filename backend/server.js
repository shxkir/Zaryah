require('dotenv').config({ override: true });
const express = require('express');
const cors = require('cors');
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const { PrismaClient } = require('@prisma/client');
const Groq = require('groq-sdk');
const {
  initializePineconeIndex,
  storeUserInPinecone,
  queryUsersFromPinecone,
  getAllUsersFromPinecone,
} = require('./pineconeUtils');

const app = express();
const prisma = new PrismaClient();
const groq = new Groq({ apiKey: process.env.GROQ_API_KEY });

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

    // Create prompt with user data context
    const prompt = `You are Zaryah AI, an intelligent educational assistant for the Zaryah platform. You have access to student data and can help answer questions about users and their learning profiles.

IMPORTANT INSTRUCTIONS:
- If the user greets you or says hello, respond warmly: "Hello! I'm Zaryah AI, your educational assistant. How may I help you today?"
- ONLY provide user information when specifically asked about a user, users, or learning data
- Do NOT volunteer information about users unless explicitly requested
- Keep responses concise and helpful
- When asked about a specific user, provide relevant details from their profile
- When asked for statistics or comparisons, format them clearly

Here is the user database (ONLY use this when the user asks about users):

${JSON.stringify(usersData, null, 2)}

User Question: ${query}`;

    // Call Groq API
    const chatCompletion = await groq.chat.completions.create({
      messages: [{ role: 'user', content: prompt }],
      model: 'llama-3.3-70b-versatile',
      temperature: 0.7,
      max_tokens: 1024,
    });
    const response = chatCompletion.choices[0]?.message?.content || 'No response generated';

    // Extract user names mentioned in the response to send back as cards
    const mentionedUsers = [];
    usersData.forEach(user => {
      if (user.profile && user.profile.name) {
        const nameLower = user.profile.name.toLowerCase();
        const responseLower = response.toLowerCase();
        // Check if user's name is mentioned in the response
        if (responseLower.includes(nameLower)) {
          mentionedUsers.push({
            id: user.id,
            email: user.email,
            profile: user.profile,
          });
        }
      }
    });

    res.json({
      query,
      response,
      mentionedUsers, // Include users mentioned in response
      timestamp: new Date().toISOString(),
      dataSource: pineconeReady ? 'pinecone' : 'postgresql',
    });
  } catch (error) {
    console.error('Chatbot error:', error);
    res.status(500).json({ error: 'Internal server error', details: error.message });
  }
});

// POST /api/messages/send - Send a message (protected)
app.post('/api/messages/send', authenticateToken, async (req, res) => {
  try {
    const { receiverId, text } = req.body;
    const senderId = req.user.userId;

    if (!receiverId || !text) {
      return res.status(400).json({ error: 'receiverId and text are required' });
    }

    // Check if receiver exists
    const receiver = await prisma.user.findUnique({
      where: { id: receiverId },
    });

    if (!receiver) {
      return res.status(404).json({ error: 'Receiver not found' });
    }

    // Create message
    const message = await prisma.message.create({
      data: {
        senderId,
        receiverId,
        text,
      },
      include: {
        sender: {
          select: {
            id: true,
            email: true,
            profile: { select: { name: true } },
          },
        },
        receiver: {
          select: {
            id: true,
            email: true,
            profile: { select: { name: true } },
          },
        },
      },
    });

    res.status(201).json({ message: 'Message sent successfully', data: message });
  } catch (error) {
    console.error('Send message error:', error);
    res.status(500).json({ error: 'Internal server error', details: error.message });
  }
});

// GET /api/messages/conversations - Get all conversations for current user (protected)
app.get('/api/messages/conversations', authenticateToken, async (req, res) => {
  try {
    const userId = req.user.userId;

    // Get all unique conversations
    const messages = await prisma.message.findMany({
      where: {
        OR: [{ senderId: userId }, { receiverId: userId }],
      },
      include: {
        sender: {
          select: {
            id: true,
            email: true,
            profile: { select: { name: true } },
          },
        },
        receiver: {
          select: {
            id: true,
            email: true,
            profile: { select: { name: true } },
          },
        },
      },
      orderBy: { createdAt: 'desc' },
    });

    // Group by conversation partner
    const conversationsMap = new Map();

    messages.forEach(msg => {
      const partnerId = msg.senderId === userId ? msg.receiverId : msg.senderId;
      const partner = msg.senderId === userId ? msg.receiver : msg.sender;

      if (!conversationsMap.has(partnerId)) {
        conversationsMap.set(partnerId, {
          partnerId,
          partnerName: partner.profile?.name || partner.email,
          partnerEmail: partner.email,
          lastMessage: msg.text,
          lastMessageTime: msg.createdAt,
          unreadCount: 0,
        });
      }

      // Count unread messages
      if (msg.receiverId === userId && !msg.read) {
        conversationsMap.get(partnerId).unreadCount++;
      }
    });

    const conversations = Array.from(conversationsMap.values());

    res.json({ conversations });
  } catch (error) {
    console.error('Get conversations error:', error);
    res.status(500).json({ error: 'Internal server error', details: error.message });
  }
});

// GET /api/messages/:partnerId - Get messages with a specific user (protected)
app.get('/api/messages/:partnerId', authenticateToken, async (req, res) => {
  try {
    const userId = req.user.userId;
    const { partnerId } = req.params;

    // Get all messages between these two users
    const messages = await prisma.message.findMany({
      where: {
        OR: [
          { senderId: userId, receiverId: partnerId },
          { senderId: partnerId, receiverId: userId },
        ],
      },
      include: {
        sender: {
          select: {
            id: true,
            email: true,
            profile: { select: { name: true } },
          },
        },
        receiver: {
          select: {
            id: true,
            email: true,
            profile: { select: { name: true } },
          },
        },
      },
      orderBy: { createdAt: 'asc' },
    });

    // Mark messages as read
    await prisma.message.updateMany({
      where: {
        senderId: partnerId,
        receiverId: userId,
        read: false,
      },
      data: { read: true },
    });

    res.json({ messages });
  } catch (error) {
    console.error('Get messages error:', error);
    res.status(500).json({ error: 'Internal server error', details: error.message });
  }
});

// GET /api/profile/me - Get current user's profile (protected)
app.get('/api/profile/me', authenticateToken, async (req, res) => {
  try {
    const userId = req.user.userId;

    const user = await prisma.user.findUnique({
      where: { id: userId },
      include: { profile: true },
      select: {
        id: true,
        email: true,
        createdAt: true,
        profile: true,
      },
    });

    if (!user) {
      return res.status(404).json({ error: 'User not found' });
    }

    res.json({ user });
  } catch (error) {
    console.error('Get current profile error:', error);
    res.status(500).json({ error: 'Internal server error', details: error.message });
  }
});

// PUT /api/profile/me - Update current user's profile (protected)
app.put('/api/profile/me', authenticateToken, async (req, res) => {
  try {
    const userId = req.user.userId;
    const {
      name,
      age,
      bio,
      profilePicture,
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

    // Update profile
    const updatedUser = await prisma.user.update({
      where: { id: userId },
      data: {
        profile: {
          update: {
            ...(name && { name }),
            ...(age && { age: parseInt(age) }),
            ...(bio !== undefined && { bio }),
            ...(profilePicture !== undefined && { profilePicture }),
            ...(educationLevel && { educationLevel }),
            ...(occupation && { occupation }),
            ...(learningGoals && { learningGoals }),
            ...(subjects && { subjects }),
            ...(learningStyle && { learningStyle }),
            ...(previousExperience && { previousExperience }),
            ...(strengths && { strengths }),
            ...(weaknesses && { weaknesses }),
            ...(specificChallenges && { specificChallenges }),
            ...(availableHoursPerWeek && { availableHoursPerWeek: parseInt(availableHoursPerWeek) }),
            ...(learningPace && { learningPace }),
            ...(motivationLevel && { motivationLevel }),
          },
        },
      },
      include: {
        profile: true,
      },
    });

    res.json({ message: 'Profile updated successfully', user: updatedUser });
  } catch (error) {
    console.error('Update profile error:', error);
    res.status(500).json({ error: 'Internal server error', details: error.message });
  }
});

// GET /api/dashboard - Get dashboard data with stats and suggestions (protected)
app.get('/api/dashboard', authenticateToken, async (req, res) => {
  try {
    const userId = req.user.userId;

    // Get total users count
    const totalUsers = await prisma.user.count();

    // Get unread messages count
    const unreadMessages = await prisma.message.count({
      where: {
        receiverId: userId,
        read: false,
      },
    });

    // Get total conversations count
    const conversations = await prisma.message.groupBy({
      by: ['senderId', 'receiverId'],
      where: {
        OR: [
          { senderId: userId },
          { receiverId: userId },
        ],
      },
    });
    const uniqueConversations = new Set();
    conversations.forEach(conv => {
      const partnerId = conv.senderId === userId ? conv.receiverId : conv.senderId;
      uniqueConversations.add(partnerId);
    });
    const totalConversations = uniqueConversations.size;

    // Get suggested users (random 5 users excluding current user)
    const suggestedUsers = await prisma.user.findMany({
      where: {
        NOT: { id: userId },
      },
      include: {
        profile: true,
      },
      take: 5,
      orderBy: {
        createdAt: 'desc',
      },
    });

    // Get recent users (users with recent messages)
    const recentMessages = await prisma.message.findMany({
      where: {
        OR: [
          { senderId: userId },
          { receiverId: userId },
        ],
      },
      include: {
        sender: {
          include: { profile: true },
        },
        receiver: {
          include: { profile: true },
        },
      },
      orderBy: {
        createdAt: 'desc',
      },
      take: 10,
    });

    const recentUserIds = new Set();
    const recentUsers = [];
    recentMessages.forEach(msg => {
      const otherUser = msg.senderId === userId ? msg.receiver : msg.sender;
      if (!recentUserIds.has(otherUser.id) && recentUsers.length < 5) {
        recentUserIds.add(otherUser.id);
        recentUsers.push({
          id: otherUser.id,
          email: otherUser.email,
          profile: otherUser.profile,
        });
      }
    });

    // Trending topics (subjects from user profiles)
    const profiles = await prisma.profile.findMany({
      select: {
        subjects: true,
      },
    });
    const subjectCounts = {};
    profiles.forEach(profile => {
      profile.subjects.forEach(subject => {
        subjectCounts[subject] = (subjectCounts[subject] || 0) + 1;
      });
    });
    const trendingTopics = Object.entries(subjectCounts)
      .sort((a, b) => b[1] - a[1])
      .slice(0, 5)
      .map(([topic, count]) => ({ topic, count }));

    res.json({
      stats: {
        totalUsers,
        unreadMessages,
        totalConversations,
      },
      suggestedUsers: suggestedUsers.map(user => ({
        id: user.id,
        email: user.email,
        profile: user.profile,
      })),
      recentUsers,
      trendingTopics,
    });
  } catch (error) {
    console.error('Dashboard error:', error);
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

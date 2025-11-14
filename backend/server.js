require('dotenv').config({ override: true });
const express = require('express');
const cors = require('cors');
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const { PrismaClient } = require('@prisma/client');
const OpenAI = require('openai');
const emailjs = require('@emailjs/nodejs');
const crypto = require('crypto');
const {
  initializePineconeIndex,
  storeUserInPinecone,
  queryUsersFromPinecone,
  getAllUsersFromPinecone,
} = require('./pineconeUtils');

const app = express();
const prisma = new PrismaClient();
// Initialize OpenAI client
const openai = new OpenAI({
  apiKey: process.env.OPENAI_API_KEY,
});

const PORT = process.env.PORT || 3000;
const JWT_SECRET = process.env.JWT_SECRET || 'your-secret-key-change-in-production';

// EmailJS Configuration
const EMAILJS_SERVICE_ID = 'service_dknkiv9';
const EMAILJS_TEMPLATE_ID = 'template_bf0zmmn';
const EMAILJS_PUBLIC_KEY = 'c5CEubgqvcGAXMmUe';
const EMAILJS_PRIVATE_KEY = 'mg58cX4sZL-BLpKRSfZ8L';

// In-memory storage for password reset tokens (in production, use Redis or database)
const resetTokens = new Map(); // Map<token, {email, expiresAt}>

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

// POST /api/forgot-password - Request password reset
app.post('/api/forgot-password', async (req, res) => {
  try {
    const { email } = req.body;

    if (!email) {
      return res.status(400).json({ error: 'Email is required' });
    }

    // Check if user exists
    const user = await prisma.user.findUnique({
      where: { email },
      include: { profile: true }
    });

    if (!user) {
      // For security, don't reveal if email exists or not
      return res.json({
        message: 'If an account exists with this email, a password reset link has been sent.'
      });
    }

    // Generate secure reset token
    const resetToken = crypto.randomBytes(32).toString('hex');
    const expiresAt = Date.now() + 3600000; // 1 hour from now

    // Store token in memory (in production, use database or Redis)
    resetTokens.set(resetToken, {
      email: user.email,
      expiresAt
    });

    // Send email using EmailJS
    try {
      await emailjs.send(
        EMAILJS_SERVICE_ID,
        EMAILJS_TEMPLATE_ID,
        {
          to_email: user.email,
          user_name: user.profile?.name || user.email,
          reset_token: resetToken,
          reset_link: `http://localhost:3000/reset-password?token=${resetToken}`,
          expires_in: '1 hour'
        },
        {
          publicKey: EMAILJS_PUBLIC_KEY,
          privateKey: EMAILJS_PRIVATE_KEY,
        }
      );

      console.log(`✅ Password reset email sent to ${user.email}`);

      res.json({
        message: 'If an account exists with this email, a password reset link has been sent.',
        token: resetToken, // Send token for testing
        success: true
      });
    } catch (emailError) {
      console.error('❌ EmailJS error:', emailError.message || emailError);

      // Still return success but provide token for testing since email might not work in development
      console.log(`⚠️  Email sending failed, but token generated: ${resetToken}`);

      res.json({
        message: 'Password reset initiated. For testing, use the token below.',
        token: resetToken, // Send token for testing when email fails
        success: true,
        emailSent: false
      });
    }
  } catch (error) {
    console.error('Forgot password error:', error);
    res.status(500).json({ error: 'Internal server error', details: error.message });
  }
});

// POST /api/reset-password - Reset password with token
app.post('/api/reset-password', async (req, res) => {
  try {
    const { token, newPassword } = req.body;

    if (!token || !newPassword) {
      return res.status(400).json({ error: 'Token and new password are required' });
    }

    // Validate password strength
    if (newPassword.length < 6) {
      return res.status(400).json({ error: 'Password must be at least 6 characters long' });
    }

    // Check if token exists and is valid
    const tokenData = resetTokens.get(token);

    if (!tokenData) {
      return res.status(400).json({ error: 'Invalid or expired reset token' });
    }

    // Check if token has expired
    if (Date.now() > tokenData.expiresAt) {
      resetTokens.delete(token);
      return res.status(400).json({ error: 'Reset token has expired' });
    }

    // Hash new password
    const hashedPassword = await bcrypt.hash(newPassword, 10);

    // Update user password
    await prisma.user.update({
      where: { email: tokenData.email },
      data: { password: hashedPassword }
    });

    // Delete used token
    resetTokens.delete(token);

    console.log(`✅ Password reset successful for ${tokenData.email}`);

    res.json({ message: 'Password reset successful. You can now login with your new password.' });
  } catch (error) {
    console.error('Reset password error:', error);
    res.status(500).json({ error: 'Internal server error', details: error.message });
  }
});

// GET /api/users - Get all users with profiles (protected)
app.get('/api/users', authenticateToken, async (req, res) => {
  try {
    const users = await prisma.user.findMany({
      include: { profile: true },
    });

    // Remove password from response
    const usersWithoutPassword = users.map(user => {
      const { password, ...userWithoutPassword } = user;
      return userWithoutPassword;
    });

    res.json({ users: usersWithoutPassword });
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
    });

    if (!user) {
      user = await prisma.user.findUnique({
        where: { email: identifier },
        include: { profile: true },
      });
    }

    if (!user) {
      return res.status(404).json({ error: 'User not found' });
    }

    // Remove password from response
    const { password, ...userWithoutPassword } = user;

    res.json({ user: userWithoutPassword });
  } catch (error) {
    console.error('Get user error:', error);
    res.status(500).json({ error: 'Internal server error', details: error.message });
  }
});

// POST /api/chatbot - Send query to OpenAI with intelligent user filtering (protected)
app.post('/api/chatbot', authenticateToken, async (req, res) => {
  try {
    const { query } = req.body;

    if (!query) {
      return res.status(400).json({ error: 'Query is required' });
    }

    // Get ALL users from database (better than buggy semantic search)
    const allUsers = await prisma.user.findMany({
      include: { profile: true },
    });

    const totalUserCount = allUsers.length;

    // Simple but effective keyword-based filtering
    const queryLower = query.toLowerCase();
    const keywords = queryLower.split(/\s+/);

    // Score each user based on relevance
    const scoredUsers = allUsers.map(user => {
      let score = 0;
      const profile = user.profile;

      if (!profile) return { user, score: 0 };

      const searchText = `
        ${profile.name || ''}
        ${profile.occupation || ''}
        ${profile.educationLevel || ''}
        ${profile.learningGoals || ''}
        ${profile.subjects?.join(' ') || ''}
        ${profile.previousExperience || ''}
      `.toLowerCase();

      // Count keyword matches
      keywords.forEach(keyword => {
        if (searchText.includes(keyword)) {
          score += 10;
        }
      });

      // Boost for exact occupation match
      if (profile.occupation && queryLower.includes(profile.occupation.toLowerCase())) {
        score += 50;
      }

      // Boost for subject matches
      if (profile.subjects) {
        profile.subjects.forEach(subject => {
          if (queryLower.includes(subject.toLowerCase())) {
            score += 30;
          }
        });
      }

      return { user, score };
    });

    // Sort by score and take top 15 relevant users
    const relevantUsers = scoredUsers
      .filter(item => item.score > 0)
      .sort((a, b) => b.score - a.score)
      .slice(0, 15)
      .map(item => ({
        id: item.user.id,
        email: item.user.email || '',
        profile: {
          name: item.user.profile?.name || 'Unknown',
          age: item.user.profile?.age || 0,
          educationLevel: item.user.profile?.educationLevel || '',
          occupation: item.user.profile?.occupation || '',
          learningGoals: item.user.profile?.learningGoals || '',
          subjects: item.user.profile?.subjects || [],
          learningStyle: item.user.profile?.learningStyle || '',
          previousExperience: item.user.profile?.previousExperience || '',
          strengths: item.user.profile?.strengths || '',
          weaknesses: item.user.profile?.weaknesses || '',
          specificChallenges: item.user.profile?.specificChallenges || '',
          availableHoursPerWeek: item.user.profile?.availableHoursPerWeek || 0,
          learningPace: item.user.profile?.learningPace || '',
          motivationLevel: item.user.profile?.motivationLevel || '',
        }
      }));

    console.log(`✅ Found ${relevantUsers.length} relevant users for query: "${query}"`);

    // Define agentic tools for function calling
    const tools = [
      {
        type: "function",
        function: {
          name: "search_users",
          description: "Search for users by specific criteria such as occupation, education level, or subjects of interest",
          parameters: {
            type: "object",
            properties: {
              occupation: {
                type: "string",
                description: "Filter by occupation (e.g., 'Student', 'Teacher', 'Engineer', 'Doctor')"
              },
              educationLevel: {
                type: "string",
                description: "Filter by education level (e.g., 'High School', 'Bachelor', 'Master')"
              },
              subjects: {
                type: "array",
                items: { type: "string" },
                description: "Filter by subjects of interest"
              }
            }
          }
        }
      },
      {
        type: "function",
        function: {
          name: "get_user_profile",
          description: "Get detailed profile information for a specific user by their name or ID",
          parameters: {
            type: "object",
            properties: {
              identifier: {
                type: "string",
                description: "User's name or ID"
              }
            },
            required: ["identifier"]
          }
        }
      },
      {
        type: "function",
        function: {
          name: "send_message",
          description: "Send a message to a specific user on behalf of the current user",
          parameters: {
            type: "object",
            properties: {
              userName: {
                type: "string",
                description: "Name of the user to send message to"
              },
              message: {
                type: "string",
                description: "The message content to send"
              }
            },
            required: ["userName", "message"]
          }
        }
      }
    ];

    // Create system prompt with RELEVANT user data context
    const systemPrompt = `You are Zaryah AI, an intelligent educational assistant for the Zaryah platform. You help users discover and connect with other learners.

PLATFORM STATISTICS:
- Total users on platform: ${totalUserCount}
- Most relevant users for this query: ${relevantUsers.length}

IMPORTANT INSTRUCTIONS:
- When asked "who is a developer" or "who is developing", look for users with occupations like "Software Developer", "Backend Developer", "Frontend Developer", "Game Developer", "Junior Developer", "Blockchain Developer"
- When asked "who is studying", look for users with occupation "Student"
- When asked "who is learning X", look for users with X in their subjects or learning goals
- ALWAYS mention user names explicitly in your response
- Provide specific information about each relevant user
- Include occupation, education level, subjects, and learning goals
- Format responses clearly with bullet points
- Be conversational and helpful

RELEVANT USERS FOR THIS QUERY:
${JSON.stringify(relevantUsers, null, 2)}`;

    // Call OpenAI API with function calling
    let response;
    try {
      console.log('🤖 Calling OpenAI API...');

      // Call OpenAI with function calling support
      const completion = await openai.chat.completions.create({
        model: "gpt-3.5-turbo",
        messages: [
          { role: "system", content: systemPrompt },
          { role: "user", content: query }
        ],
        tools: tools,
        tool_choice: "auto",
        max_tokens: 1024,
        temperature: 0.7,
      });

      const message = completion.choices[0]?.message;

      // Check if the model wants to call a function
      if (message.tool_calls && message.tool_calls.length > 0) {
        const toolCall = message.tool_calls[0];
        const functionName = toolCall.function.name;
        const functionArgs = JSON.parse(toolCall.function.arguments);

        console.log(`🔧 Tool call: ${functionName}`, functionArgs);

        // Execute tool functions
        if (functionName === "search_users") {
          // Search through ALL users, not just relevantUsers
          const filtered = allUsers.filter(u => {
            if (!u.profile) return false;

            // Check occupation (partial match for "developer" matching "Software Developer", etc.)
            if (functionArgs.occupation) {
              const occupationLower = functionArgs.occupation.toLowerCase();
              const userOccupation = (u.profile.occupation || '').toLowerCase();
              if (!userOccupation.includes(occupationLower) && !occupationLower.includes(userOccupation)) {
                return false;
              }
            }

            // Check education level
            if (functionArgs.educationLevel && u.profile.educationLevel !== functionArgs.educationLevel) {
              return false;
            }

            // Check subjects
            if (functionArgs.subjects && !functionArgs.subjects.some(s => u.profile.subjects?.includes(s))) {
              return false;
            }

            return true;
          });

          response = `Found ${filtered.length} users matching your criteria:\n\n` +
                    filtered.slice(0, 15).map(u => `• ${u.profile?.name}: ${u.profile?.occupation}, ${u.profile?.educationLevel}`).join('\n');
        } else if (functionName === "get_user_profile") {
          // First search in relevant users
          let user = relevantUsers.find(u =>
            u.profile?.name?.toLowerCase().includes(functionArgs.identifier.toLowerCase()) ||
            u.id === functionArgs.identifier
          );

          // If not found, search in database
          if (!user) {
            const dbUser = await prisma.user.findFirst({
              where: {
                OR: [
                  { profile: { name: { contains: functionArgs.identifier, mode: 'insensitive' } } },
                  { id: functionArgs.identifier }
                ]
              },
              include: { profile: true }
            });
            user = dbUser;
          }

          if (user) {
            response = `Profile for ${user.profile?.name}:\n\n` +
                      `• Occupation: ${user.profile?.occupation}\n` +
                      `• Education: ${user.profile?.educationLevel}\n` +
                      `• Subjects: ${user.profile?.subjects?.join(', ')}\n` +
                      `• Learning Goals: ${user.profile?.learningGoals}\n` +
                      `• Available Hours: ${user.profile?.availableHoursPerWeek} hours/week\n` +
                      `• Learning Pace: ${user.profile?.learningPace}`;
          } else {
            response = `User not found with identifier: ${functionArgs.identifier}`;
          }
        } else if (functionName === "send_message") {
          // Search in relevant users first, then database
          let targetUser = relevantUsers.find(u =>
            u.profile?.name?.toLowerCase() === functionArgs.userName.toLowerCase()
          );

          if (!targetUser) {
            targetUser = await prisma.user.findFirst({
              where: { profile: { name: { equals: functionArgs.userName, mode: 'insensitive' } } },
              include: { profile: true }
            });
          }

          if (targetUser) {
            // Actually send the message via Prisma
            await prisma.message.create({
              data: {
                senderId: req.user.userId,
                receiverId: targetUser.id,
                text: functionArgs.message
              }
            });
            response = `Message sent successfully to ${targetUser.profile?.name}!`;
          } else {
            response = `Could not find user: ${functionArgs.userName}`;
          }
        }
      } else {
        // Use the direct response from OpenAI
        response = message.content || 'I apologize, but I could not generate a response. Please try rephrasing your question.';
      }

      console.log('✅ OpenAI API response received');

    } catch (openaiError) {
      console.error('❌ OpenAI API error:', openaiError.message || openaiError);

      // Fallback: Provide intelligent response based on query
      const queryLower = query.toLowerCase();

      if (queryLower.includes('user') || queryLower.includes('people') || queryLower.includes('student')) {
        // List relevant users
        response = `I found ${totalUserCount} users in our platform. Here are the most relevant ones:\n\n` +
          relevantUsers.slice(0, 5).map(u => `• ${u.profile?.name || 'Unknown'} - ${u.profile?.occupation || 'N/A'}`).join('\n') +
          `\n\nWould you like to know more about any specific user?`;
      } else if (queryLower.includes('subject') || queryLower.includes('topic')) {
        // Get subjects from relevant users
        const allSubjects = new Set();
        relevantUsers.forEach(u => {
          u.profile?.subjects?.forEach(s => allSubjects.add(s));
        });
        response = `Based on your query, here are relevant subjects from our users:\n\n${Array.from(allSubjects).join(', ')}\n\nWould you like to find users interested in a specific subject?`;
      } else {
        response = `I'm Zaryah AI, your educational assistant. I have information about ${totalUserCount} users. You can ask me about:\n\n• Finding users by occupation or education level\n• Users interested in specific subjects\n• User profiles and learning goals\n• Connecting with other learners\n\nWhat would you like to know?`;
      }
    }

    // Extract user names mentioned in the response to send back as cards
    // Search through ALL users, not just relevantUsers
    const mentionedUsers = [];
    allUsers.forEach(user => {
      if (user.profile && user.profile.name) {
        const nameLower = user.profile.name.toLowerCase();
        const responseLower = response.toLowerCase();
        // Check if user's name is mentioned in the response
        if (responseLower.includes(nameLower)) {
          mentionedUsers.push({
            id: user.id || '',
            email: user.email || '',
            profile: {
              name: user.profile.name || '',
              age: user.profile.age || 0,
              educationLevel: user.profile.educationLevel || '',
              occupation: user.profile.occupation || '',
              learningGoals: user.profile.learningGoals || '',
              subjects: user.profile.subjects || [],
              learningStyle: user.profile.learningStyle || '',
              previousExperience: user.profile.previousExperience || '',
              strengths: user.profile.strengths || '',
              weaknesses: user.profile.weaknesses || '',
              specificChallenges: user.profile.specificChallenges || '',
              availableHoursPerWeek: user.profile.availableHoursPerWeek || 0,
              learningPace: user.profile.learningPace || '',
              motivationLevel: user.profile.motivationLevel || '',
              bio: user.profile.bio || '',
              profilePicture: user.profile.profilePicture || '',
            }
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
        users_messages_senderIdTousers: {
          select: {
            id: true,
            email: true,
            profile: { select: { name: true } },
          },
        },
        users_messages_receiverIdTousers: {
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
        users_messages_senderIdTousers: {
          select: {
            id: true,
            email: true,
            profile: { select: { name: true } },
          },
        },
        users_messages_receiverIdTousers: {
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
      const partner = msg.senderId === userId ? msg.users_messages_receiverIdTousers : msg.users_messages_senderIdTousers;

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
        users_messages_senderIdTousers: {
          select: {
            id: true,
            email: true,
            profile: { select: { name: true } },
          },
        },
        users_messages_receiverIdTousers: {
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
    });

    if (!user) {
      return res.status(404).json({ error: 'User not found' });
    }

    // Remove password from response
    const { password, ...userWithoutPassword } = user;

    res.json({ user: userWithoutPassword });
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
        users_messages_senderIdTousers: {
          include: { profile: true },
        },
        users_messages_receiverIdTousers: {
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
      const otherUser = msg.senderId === userId ? msg.users_messages_receiverIdTousers : msg.users_messages_senderIdTousers;
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

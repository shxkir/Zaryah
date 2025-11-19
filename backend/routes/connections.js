const express = require('express');
const router = express.Router();
const { PrismaClient } = require('@prisma/client');

// Use a single Prisma instance to avoid connection issues
let prisma;
if (global.prisma) {
  prisma = global.prisma;
} else {
  prisma = new PrismaClient();
  global.prisma = prisma;
}

// Middleware to verify JWT token
const authenticateToken = (req, res, next) => {
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1];

  if (!token) {
    return res.status(401).json({ error: 'Access token required' });
  }

  const jwt = require('jsonwebtoken');
  jwt.verify(token, process.env.JWT_SECRET || 'your-secret-key', (err, user) => {
    if (err) {
      return res.status(403).json({ error: 'Invalid or expired token' });
    }
    req.user = user;
    next();
  });
};

/**
 * GET /api/connections
 * Get user's connections (accepted only)
 */
router.get('/', authenticateToken, async (req, res) => {
  try {
    const userId = req.user.userId;

    const profile = await prisma.profile.findUnique({
      where: { userId },
    });

    if (!profile) {
      return res.status(404).json({ error: 'Profile not found' });
    }

    const connections = await prisma.connection.findMany({
      where: {
        OR: [
          { userId: profile.id, status: 'accepted' },
          { connectedId: profile.id, status: 'accepted' },
        ],
      },
      include: {
        user: {
          include: {
            user: {
              select: {
                id: true,
                email: true,
              },
            },
          },
        },
        connected: {
          include: {
            user: {
              select: {
                id: true,
                email: true,
              },
            },
          },
        },
      },
    });

    res.json({ connections });
  } catch (error) {
    console.error('Error fetching connections:', error);
    res.status(500).json({
      error: 'Failed to fetch connections',
      details: error.message,
    });
  }
});

/**
 * POST /api/connections
 * Send connection request
 * Body: { targetUserId }
 */
router.post('/', authenticateToken, async (req, res) => {
  try {
    const userId = req.user.userId;
    const { targetUserId } = req.body;

    console.log(`🤝 Connection request: ${userId} -> ${targetUserId}`);

    if (!targetUserId) {
      console.error('❌ Missing targetUserId');
      return res.status(400).json({ error: 'Target user ID required' });
    }

    if (userId === targetUserId) {
      console.error('❌ User trying to connect to themselves');
      return res.status(400).json({ error: 'Cannot connect to yourself' });
    }

    // Find both user profiles
    console.log('📝 Looking up user profiles...');
    const userProfile = await prisma.profile.findUnique({
      where: { userId },
      include: {
        user: {
          select: {
            id: true,
            email: true,
          },
        },
      },
    });

    const targetProfile = await prisma.profile.findUnique({
      where: { userId: targetUserId },
      include: {
        user: {
          select: {
            id: true,
            email: true,
          },
        },
      },
    });

    if (!userProfile) {
      console.error(`❌ Requesting user profile not found: ${userId}`);
      return res.status(404).json({ error: 'Your profile not found. Please complete your profile first.' });
    }

    if (!targetProfile) {
      console.error(`❌ Target user profile not found: ${targetUserId}`);
      return res.status(404).json({ error: 'Target user profile not found' });
    }

    console.log(`✅ Found profiles: ${userProfile.name} -> ${targetProfile.name}`);

    // Check if connection already exists
    const existing = await prisma.connection.findFirst({
      where: {
        OR: [
          { userId: userProfile.id, connectedId: targetProfile.id },
          { userId: targetProfile.id, connectedId: userProfile.id },
        ],
      },
    });

    if (existing) {
      console.log(`⚠️ Connection already exists with status: ${existing.status}`);
      return res.status(400).json({
        error: 'Connection already exists',
        status: existing.status,
        message: existing.status === 'pending' ? 'Connection request is pending' : 'You are already connected',
      });
    }

    // Create new connection request
    console.log('📝 Creating connection request...');
    const connection = await prisma.connection.create({
      data: {
        userId: userProfile.id,
        connectedId: targetProfile.id,
        status: 'pending',
      },
      include: {
        user: {
          include: {
            user: {
              select: {
                id: true,
                email: true,
              },
            },
          },
        },
        connected: {
          include: {
            user: {
              select: {
                id: true,
                email: true,
              },
            },
          },
        },
      },
    });

    console.log(`✅ Connection request created successfully: ${connection.id}`);

    res.status(201).json({
      message: 'Connection request sent successfully',
      connection,
    });
  } catch (error) {
    console.error('❌ Error creating connection:', error);
    console.error('Error stack:', error.stack);

    res.status(500).json({
      error: 'Failed to create connection',
      details: error.message,
      hint: 'Check server logs for more details',
    });
  }
});

/**
 * PUT /api/connections/:id
 * Accept or reject connection request
 * Body: { status: 'accepted' | 'rejected' }
 */
router.put('/:id', authenticateToken, async (req, res) => {
  try {
    const { id } = req.params;
    const { status } = req.body;

    if (!['accepted', 'rejected'].includes(status)) {
      return res.status(400).json({
        error: 'Invalid status',
        validStatuses: ['accepted', 'rejected'],
      });
    }

    // Verify this connection exists and user is the receiver
    const connection = await prisma.connection.findUnique({
      where: { id },
      include: {
        connected: {
          select: {
            userId: true,
          },
        },
      },
    });

    if (!connection) {
      return res.status(404).json({ error: 'Connection not found' });
    }

    if (connection.connected.userId !== req.user.userId) {
      return res.status(403).json({
        error: 'Only the receiver can accept/reject connection requests',
      });
    }

    const updated = await prisma.connection.update({
      where: { id },
      data: { status },
      include: {
        user: {
          include: {
            user: {
              select: {
                id: true,
                email: true,
              },
            },
          },
        },
        connected: {
          include: {
            user: {
              select: {
                id: true,
                email: true,
              },
            },
          },
        },
      },
    });

    res.json({
      message: `Connection ${status}`,
      connection: updated,
    });
  } catch (error) {
    console.error('Error updating connection:', error);
    res.status(500).json({
      error: 'Failed to update connection',
      details: error.message,
    });
  }
});

/**
 * DELETE /api/connections/:id
 * Remove a connection
 */
router.delete('/:id', authenticateToken, async (req, res) => {
  try {
    const { id } = req.params;
    const userId = req.user.userId;

    const userProfile = await prisma.profile.findUnique({
      where: { userId },
    });

    if (!userProfile) {
      return res.status(404).json({ error: 'Profile not found' });
    }

    // Verify user owns this connection
    const connection = await prisma.connection.findUnique({
      where: { id },
    });

    if (!connection) {
      return res.status(404).json({ error: 'Connection not found' });
    }

    if (connection.userId !== userProfile.id && connection.connectedId !== userProfile.id) {
      return res.status(403).json({ error: 'Unauthorized' });
    }

    await prisma.connection.delete({
      where: { id },
    });

    res.json({ message: 'Connection removed successfully' });
  } catch (error) {
    console.error('Error deleting connection:', error);
    res.status(500).json({
      error: 'Failed to delete connection',
      details: error.message,
    });
  }
});

/**
 * GET /api/connections/suggested
 * Get suggested connections based on location, occupation, education
 */
router.get('/suggested', authenticateToken, async (req, res) => {
  try {
    const userId = req.user.userId;

    const userProfile = await prisma.profile.findUnique({
      where: { userId },
    });

    if (!userProfile) {
      return res.status(404).json({ error: 'Profile not found' });
    }

    // Get existing connections
    const existingConnections = await prisma.connection.findMany({
      where: {
        OR: [
          { userId: userProfile.id },
          { connectedId: userProfile.id },
        ],
      },
      select: {
        userId: true,
        connectedId: true,
      },
    });

    const connectedIds = new Set();
    existingConnections.forEach(conn => {
      connectedIds.add(conn.userId);
      connectedIds.add(conn.connectedId);
    });

    // Get suggested users (same country, similar occupation/education)
    const suggested = await prisma.profile.findMany({
      where: {
        userId: { not: userId },
        id: { notIn: Array.from(connectedIds) },
        OR: [
          { country: userProfile.country },
          { city: userProfile.city },
          { occupation: userProfile.occupation },
          { educationLevel: userProfile.educationLevel },
        ],
      },
      include: {
        user: {
          select: {
            id: true,
            email: true,
          },
        },
      },
      take: 20,
      orderBy: {
        createdAt: 'desc',
      },
    });

    res.json({
      suggested,
      count: suggested.length,
    });
  } catch (error) {
    console.error('Error fetching suggested connections:', error);
    res.status(500).json({
      error: 'Failed to fetch suggested connections',
      details: error.message,
    });
  }
});

/**
 * GET /api/connections/pending
 * Get pending connection requests (both sent and received)
 */
router.get('/pending', authenticateToken, async (req, res) => {
  try {
    const userId = req.user.userId;

    const profile = await prisma.profile.findUnique({
      where: { userId },
    });

    if (!profile) {
      return res.status(404).json({ error: 'Profile not found' });
    }

    const pending = await prisma.connection.findMany({
      where: {
        OR: [
          { userId: profile.id, status: 'pending' },
          { connectedId: profile.id, status: 'pending' },
        ],
      },
      include: {
        user: {
          include: {
            user: {
              select: {
                id: true,
                email: true,
              },
            },
          },
        },
        connected: {
          include: {
            user: {
              select: {
                id: true,
                email: true,
              },
            },
          },
        },
      },
      orderBy: {
        createdAt: 'desc',
      },
    });

    // Separate sent vs received
    const sent = pending.filter(c => c.userId === profile.id);
    const received = pending.filter(c => c.connectedId === profile.id);

    res.json({
      sent,
      received,
      total: pending.length,
    });
  } catch (error) {
    console.error('Error fetching pending connections:', error);
    res.status(500).json({
      error: 'Failed to fetch pending connections',
      details: error.message,
    });
  }
});

module.exports = router;

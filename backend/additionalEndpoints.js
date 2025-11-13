/**
 * Additional API Endpoints for Zarayah
 * Add these to your backend/server.js file
 */

// Import at the top of server.js (if not already imported):
// const { bulkStoreUsersInPinecone, queryUsersFromPinecone } = require('./pineconeUtils');

// Add these endpoints before app.listen():

// POST /api/sync-to-pinecone - Manually sync all users to Pinecone
app.post('/api/sync-to-pinecone', authenticateToken, async (req, res) => {
  try {
    console.log('🔄 Starting manual sync to Pinecone...');

    const users = await prisma.user.findMany({
      include: { profile: true },
    });

    if (users.length === 0) {
      return res.status(404).json({ error: 'No users found to sync' });
    }

    await bulkStoreUsersInPinecone(users);

    res.json({
      message: 'Users synced to Pinecone successfully',
      count: users.length,
      timestamp: new Date().toISOString()
    });
  } catch (error) {
    console.error('Sync error:', error);
    res.status(500).json({ error: error.message });
  }
});

// GET /api/search-users?query=python - Semantic search via Pinecone
app.get('/api/search-users', authenticateToken, async (req, res) => {
  try {
    const { query, limit } = req.query;

    if (!query) {
      return res.status(400).json({ error: 'Query parameter required' });
    }

    const topK = limit ? parseInt(limit) : 10;
    const results = await queryUsersFromPinecone(query, topK);

    // Fetch full user details from PostgreSQL
    const userIds = results.map(r => r.id);
    const users = await prisma.user.findMany({
      where: {
        id: { in: userIds }
      },
      include: { profile: true },
      select: {
        id: true,
        email: true,
        createdAt: true,
        profile: true,
      },
    });

    // Combine Pinecone scores with user data
    const enrichedResults = results.map(result => {
      const user = users.find(u => u.id === result.id);
      return {
        ...user,
        relevanceScore: result.score,
      };
    });

    res.json({
      query,
      results: enrichedResults,
      count: enrichedResults.length
    });
  } catch (error) {
    console.error('Search error:', error);
    res.status(500).json({ error: error.message });
  }
});

// GET /api/user-stats - Statistics about all users
app.get('/api/user-stats', authenticateToken, async (req, res) => {
  try {
    const users = await prisma.user.findMany({
      include: { profile: true },
    });

    if (users.length === 0) {
      return res.json({
        totalUsers: 0,
        message: 'No users found'
      });
    }

    // Calculate learning style distribution
    const learningStyles = users.reduce((acc, u) => {
      const style = u.profile.learningStyle;
      acc[style] = (acc[style] || 0) + 1;
      return acc;
    }, {});

    // Calculate subject popularity
    const allSubjects = users.flatMap(u => u.profile.subjects);
    const subjectCounts = allSubjects.reduce((acc, subject) => {
      acc[subject] = (acc[subject] || 0) + 1;
      return acc;
    }, {});

    // Sort subjects by popularity
    const topSubjects = Object.entries(subjectCounts)
      .sort(([,a], [,b]) => b - a)
      .slice(0, 10)
      .reduce((acc, [subject, count]) => {
        acc[subject] = count;
        return acc;
      }, {});

    // Calculate learning pace distribution
    const learningPace = users.reduce((acc, u) => {
      const pace = u.profile.learningPace;
      acc[pace] = (acc[pace] || 0) + 1;
      return acc;
    }, {});

    // Calculate motivation level distribution
    const motivationLevel = users.reduce((acc, u) => {
      const level = u.profile.motivationLevel;
      acc[level] = (acc[level] || 0) + 1;
      return acc;
    }, {});

    // Calculate education level distribution
    const educationLevel = users.reduce((acc, u) => {
      const level = u.profile.educationLevel;
      acc[level] = (acc[level] || 0) + 1;
      return acc;
    }, {});

    // Calculate age statistics
    const ages = users.map(u => u.profile.age);
    const avgAge = ages.reduce((sum, age) => sum + age, 0) / ages.length;
    const minAge = Math.min(...ages);
    const maxAge = Math.max(...ages);

    // Calculate hours statistics
    const hours = users.map(u => u.profile.availableHoursPerWeek);
    const avgHours = hours.reduce((sum, h) => sum + h, 0) / hours.length;
    const maxHours = Math.max(...hours);
    const minHours = Math.min(...hours);

    const stats = {
      totalUsers: users.length,
      demographics: {
        avgAge: Math.round(avgAge * 10) / 10,
        minAge,
        maxAge,
        educationLevel
      },
      learning: {
        learningStyles,
        learningPace,
        motivationLevel,
        avgHoursPerWeek: Math.round(avgHours * 10) / 10,
        maxHoursPerWeek: maxHours,
        minHoursPerWeek: minHours
      },
      subjects: {
        topSubjects,
        totalUniqueSubjects: Object.keys(subjectCounts).length
      },
      generatedAt: new Date().toISOString()
    };

    res.json(stats);
  } catch (error) {
    console.error('Stats error:', error);
    res.status(500).json({ error: error.message });
  }
});

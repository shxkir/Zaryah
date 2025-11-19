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

// Authentication middleware (copied from server.js)
const jwt = require('jsonwebtoken');
const JWT_SECRET = process.env.JWT_SECRET || 'your-secret-key-change-in-production';

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

// GET /api/housing - Get all active housing listings
router.get('/', async (req, res) => {
  try {
    const { locality, minPrice, maxPrice, propertyType, bedrooms } = req.query;

    const where = { isActive: true };

    if (locality) {
      where.locality = { contains: locality, mode: 'insensitive' };
    }
    if (minPrice) {
      where.monthlyPrice = { ...where.monthlyPrice, gte: parseFloat(minPrice) };
    }
    if (maxPrice) {
      where.monthlyPrice = { ...where.monthlyPrice, lte: parseFloat(maxPrice) };
    }
    if (propertyType) {
      where.propertyType = propertyType;
    }
    if (bedrooms) {
      where.bedrooms = parseInt(bedrooms);
    }

    const listings = await prisma.housingListing.findMany({
      where,
      include: {
        user: {
          include: {
            profile: {
              select: {
                name: true,
                profilePicture: true
              }
            }
          }
        }
      },
      orderBy: {
        createdAt: 'desc'
      }
    });

    res.json({ listings });
  } catch (error) {
    console.error('Error fetching housing listings:', error);
    res.status(500).json({ error: 'Failed to fetch housing listings' });
  }
});

// GET /api/housing/search - Search housing by location/query
router.get('/search', async (req, res) => {
  try {
    const { query } = req.query;

    if (!query) {
      return res.status(400).json({ error: 'Query parameter required' });
    }

    const listings = await prisma.housingListing.findMany({
      where: {
        isActive: true,
        OR: [
          { locality: { contains: query, mode: 'insensitive' } },
          { fullAddress: { contains: query, mode: 'insensitive' } },
          { title: { contains: query, mode: 'insensitive' } },
          { description: { contains: query, mode: 'insensitive' } }
        ]
      },
      include: {
        user: {
          include: {
            profile: {
              select: {
                name: true,
                profilePicture: true
              }
            }
          }
        }
      },
      orderBy: {
        createdAt: 'desc'
      }
    });

    res.json({ listings, count: listings.length });
  } catch (error) {
    console.error('Error searching housing:', error);
    res.status(500).json({ error: 'Failed to search housing' });
  }
});

// GET /api/housing/stats - Get housing statistics
router.get('/stats', async (req, res) => {
  try {
    const totalListings = await prisma.housingListing.count({
      where: { isActive: true }
    });

    const listingsByLocality = await prisma.housingListing.groupBy({
      by: ['locality'],
      where: { isActive: true },
      _count: true
    });

    const avgPrice = await prisma.housingListing.aggregate({
      where: { isActive: true },
      _avg: {
        monthlyPrice: true
      }
    });

    res.json({
      totalListings,
      listingsByLocality,
      averagePrice: avgPrice._avg.monthlyPrice
    });
  } catch (error) {
    console.error('Error fetching housing stats:', error);
    res.status(500).json({ error: 'Failed to fetch housing stats' });
  }
});

// GET /api/housing/:id - Get single housing listing
router.get('/:id', async (req, res) => {
  try {
    const { id } = req.params;

    const listing = await prisma.housingListing.findUnique({
      where: { id },
      include: {
        user: {
          include: {
            profile: {
              select: {
                name: true,
                profilePicture: true,
                bio: true
              }
            }
          }
        }
      }
    });

    if (!listing) {
      return res.status(404).json({ error: 'Housing listing not found' });
    }

    res.json({ listing });
  } catch (error) {
    console.error('Error fetching housing listing:', error);
    res.status(500).json({ error: 'Failed to fetch housing listing' });
  }
});

// POST /api/housing - Create new housing listing (authenticated)
router.post('/', authenticateToken, async (req, res) => {
  try {
    const {
      title,
      monthlyPrice,
      locality,
      fullAddress,
      latitude,
      longitude,
      images,
      contactInfo,
      bedrooms,
      bathrooms,
      squareFeet,
      propertyType,
      amenities,
      description
    } = req.body;

    // Validation
    if (!title || !monthlyPrice || !locality || !fullAddress || !latitude || !longitude || !contactInfo) {
      return res.status(400).json({ error: 'Missing required fields' });
    }

    const listing = await prisma.housingListing.create({
      data: {
        userId: req.user.id,
        title,
        monthlyPrice: parseFloat(monthlyPrice),
        locality,
        fullAddress,
        latitude: parseFloat(latitude),
        longitude: parseFloat(longitude),
        images: images || [],
        contactInfo,
        bedrooms: bedrooms ? parseInt(bedrooms) : null,
        bathrooms: bathrooms ? parseInt(bathrooms) : null,
        squareFeet: squareFeet ? parseInt(squareFeet) : null,
        propertyType: propertyType || 'apartment',
        amenities: amenities || [],
        description
      },
      include: {
        user: {
          include: {
            profile: {
              select: {
                name: true,
                profilePicture: true
              }
            }
          }
        }
      }
    });

    res.status(201).json({ listing, message: 'Housing listing created successfully' });
  } catch (error) {
    console.error('Error creating housing listing:', error);
    res.status(500).json({ error: 'Failed to create housing listing' });
  }
});

// PUT /api/housing/:id - Update housing listing (authenticated, owner only)
router.put('/:id', authenticateToken, async (req, res) => {
  try {
    const { id } = req.params;

    // Check if listing exists and belongs to user
    const existingListing = await prisma.housingListing.findUnique({
      where: { id }
    });

    if (!existingListing) {
      return res.status(404).json({ error: 'Housing listing not found' });
    }

    if (existingListing.userId !== req.user.id) {
      return res.status(403).json({ error: 'Not authorized to update this listing' });
    }

    const {
      title,
      monthlyPrice,
      locality,
      fullAddress,
      latitude,
      longitude,
      images,
      contactInfo,
      bedrooms,
      bathrooms,
      squareFeet,
      propertyType,
      amenities,
      description,
      isActive
    } = req.body;

    const updateData = {};
    if (title !== undefined) updateData.title = title;
    if (monthlyPrice !== undefined) updateData.monthlyPrice = parseFloat(monthlyPrice);
    if (locality !== undefined) updateData.locality = locality;
    if (fullAddress !== undefined) updateData.fullAddress = fullAddress;
    if (latitude !== undefined) updateData.latitude = parseFloat(latitude);
    if (longitude !== undefined) updateData.longitude = parseFloat(longitude);
    if (images !== undefined) updateData.images = images;
    if (contactInfo !== undefined) updateData.contactInfo = contactInfo;
    if (bedrooms !== undefined) updateData.bedrooms = parseInt(bedrooms);
    if (bathrooms !== undefined) updateData.bathrooms = parseInt(bathrooms);
    if (squareFeet !== undefined) updateData.squareFeet = parseInt(squareFeet);
    if (propertyType !== undefined) updateData.propertyType = propertyType;
    if (amenities !== undefined) updateData.amenities = amenities;
    if (description !== undefined) updateData.description = description;
    if (isActive !== undefined) updateData.isActive = isActive;

    const listing = await prisma.housingListing.update({
      where: { id },
      data: updateData,
      include: {
        user: {
          include: {
            profile: {
              select: {
                name: true,
                profilePicture: true
              }
            }
          }
        }
      }
    });

    res.json({ listing, message: 'Housing listing updated successfully' });
  } catch (error) {
    console.error('Error updating housing listing:', error);
    res.status(500).json({ error: 'Failed to update housing listing' });
  }
});

// DELETE /api/housing/:id - Delete housing listing (authenticated, owner only)
router.delete('/:id', authenticateToken, async (req, res) => {
  try {
    const { id } = req.params;

    // Check if listing exists and belongs to user
    const existingListing = await prisma.housingListing.findUnique({
      where: { id }
    });

    if (!existingListing) {
      return res.status(404).json({ error: 'Housing listing not found' });
    }

    if (existingListing.userId !== req.user.id) {
      return res.status(403).json({ error: 'Not authorized to delete this listing' });
    }

    await prisma.housingListing.delete({
      where: { id }
    });

    res.json({ message: 'Housing listing deleted successfully' });
  } catch (error) {
    console.error('Error deleting housing listing:', error);
    res.status(500).json({ error: 'Failed to delete housing listing' });
  }
});

// GET /api/housing/user/:userId - Get user's housing listings
router.get('/user/:userId', async (req, res) => {
  try {
    const { userId } = req.params;

    const listings = await prisma.housingListing.findMany({
      where: { userId },
      include: {
        user: {
          include: {
            profile: {
              select: {
                name: true,
                profilePicture: true,
                profilePictureUrl: true
              }
            }
          }
        }
      },
      orderBy: {
        createdAt: 'desc'
      }
    });

    res.json({ listings });
  } catch (error) {
    console.error('Error fetching user housing listings:', error);
    res.status(500).json({ error: 'Failed to fetch user housing listings' });
  }
});

// GET /api/housing/feed - Get recent housing feed
router.get('/feed', async (req, res) => {
  try {
    const { city, limit = 20, offset = 0 } = req.query;

    const where = { isActive: true };

    // Filter by city if provided
    if (city) {
      where.locality = { contains: city, mode: 'insensitive' };
    }

    const listings = await prisma.housingListing.findMany({
      where,
      include: {
        user: {
          include: {
            profile: {
              select: {
                name: true,
                profilePicture: true,
                profilePictureUrl: true,
                city: true,
                country: true
              }
            }
          }
        }
      },
      orderBy: {
        createdAt: 'desc'
      },
      take: parseInt(limit),
      skip: parseInt(offset)
    });

    // Calculate "time ago" for each listing
    const listingsWithTimeAgo = listings.map(listing => {
      const now = new Date();
      const created = new Date(listing.createdAt);
      const diffMs = now - created;
      const diffMins = Math.floor(diffMs / 60000);
      const diffHours = Math.floor(diffMins / 60);
      const diffDays = Math.floor(diffHours / 24);

      let timeAgo;
      if (diffMins < 60) {
        timeAgo = `${diffMins} minute${diffMins !== 1 ? 's' : ''} ago`;
      } else if (diffHours < 24) {
        timeAgo = `${diffHours} hour${diffHours !== 1 ? 's' : ''} ago`;
      } else {
        timeAgo = `${diffDays} day${diffDays !== 1 ? 's' : ''} ago`;
      }

      return {
        ...listing,
        timeAgo
      };
    });

    res.json({
      listings: listingsWithTimeAgo,
      count: listingsWithTimeAgo.length,
      hasMore: listingsWithTimeAgo.length === parseInt(limit)
    });
  } catch (error) {
    console.error('Error fetching housing feed:', error);
    res.status(500).json({ error: 'Failed to fetch housing feed' });
  }
});

module.exports = router;

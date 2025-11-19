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
 * POST /api/upload/image
 * Upload a profile picture or other image
 * Body: { userId, folder, image (data URI) }
 */
router.post('/image', authenticateToken, async (req, res) => {
  try {
    const { userId, folder = 'profile-pictures', image } = req.body;

    console.log(`📸 Image upload request for user ${userId}`);

    // Verify user owns this profile
    if (req.user.userId !== userId) {
      console.error(`❌ Unauthorized upload attempt by ${req.user.userId} for ${userId}`);
      return res.status(403).json({ error: 'Unauthorized' });
    }

    if (!image || !image.startsWith('data:image/')) {
      console.error('❌ Invalid image data format');
      return res.status(400).json({ error: 'Invalid image data. Must be a data URI (data:image/...)' });
    }

    // Validate image size (max 5MB for base64)
    const base64Length = image.length - (image.indexOf(',') + 1);
    const sizeInBytes = (base64Length * 3) / 4;
    const sizeInMB = sizeInBytes / (1024 * 1024);

    console.log(`📊 Image size: ${sizeInMB.toFixed(2)}MB`);

    if (sizeInMB > 5) {
      console.error(`❌ Image too large: ${sizeInMB.toFixed(2)}MB`);
      return res.status(400).json({
        error: 'Image too large. Maximum size is 5MB.',
        size: `${sizeInMB.toFixed(2)}MB`
      });
    }

    // Check if profile exists first
    const existingProfile = await prisma.profile.findUnique({
      where: { userId },
    });

    if (!existingProfile) {
      console.error(`❌ Profile not found for user ${userId}`);
      return res.status(404).json({
        error: 'Profile not found. Please create a profile first.',
      });
    }

    // Update profile with the new image (stored as base64 data URI)
    console.log('📝 Updating profile picture...');
    const profile = await prisma.profile.update({
      where: { userId },
      data: {
        profilePictureUrl: image,
        profilePicture: image, // Keep both in sync for backward compatibility
      },
    });

    console.log(`✅ Profile picture updated successfully for user ${userId}`);

    res.status(200).json({
      message: 'Image uploaded successfully',
      url: image,
      profile: {
        id: profile.id,
        userId: profile.userId,
        profilePictureUrl: profile.profilePictureUrl,
        profilePicture: profile.profilePicture,
      },
    });
  } catch (error) {
    console.error('❌ Error uploading image:', error);
    console.error('Error stack:', error.stack);

    res.status(500).json({
      error: 'Failed to upload image',
      details: error.message,
      hint: 'Check server logs for more details',
    });
  }
});

/**
 * DELETE /api/upload/image
 * Delete an uploaded image
 * Body: { imageUrl }
 */
router.delete('/image', authenticateToken, async (req, res) => {
  try {
    const { imageUrl } = req.body;

    if (!imageUrl) {
      return res.status(400).json({ error: 'Image URL required' });
    }

    // Find profile with this image and verify ownership
    const profile = await prisma.profile.findFirst({
      where: {
        userId: req.user.userId,
        profilePictureUrl: imageUrl,
      },
    });

    if (!profile) {
      return res.status(404).json({ error: 'Image not found or unauthorized' });
    }

    // Remove the image URL from profile
    await prisma.profile.update({
      where: { id: profile.id },
      data: {
        profilePictureUrl: null,
      },
    });

    res.status(200).json({
      message: 'Image deleted successfully',
    });
  } catch (error) {
    console.error('Error deleting image:', error);
    res.status(500).json({
      error: 'Failed to delete image',
      details: error.message,
    });
  }
});

/**
 * POST /api/upload/bulk
 * Upload multiple images (for housing listings, posts, etc.)
 * Body: { userId, images: Array<data URI> }
 */
router.post('/bulk', authenticateToken, async (req, res) => {
  try {
    const { userId, images } = req.body;

    // Verify user
    if (req.user.userId !== userId) {
      return res.status(403).json({ error: 'Unauthorized' });
    }

    if (!images || !Array.isArray(images)) {
      return res.status(400).json({ error: 'Images array required' });
    }

    // Validate all images
    const validImages = images.filter(img => img.startsWith('data:image/'));

    if (validImages.length === 0) {
      return res.status(400).json({ error: 'No valid images provided' });
    }

    res.status(200).json({
      message: 'Images uploaded successfully',
      urls: validImages,
      count: validImages.length,
    });
  } catch (error) {
    console.error('Error uploading images:', error);
    res.status(500).json({
      error: 'Failed to upload images',
      details: error.message,
    });
  }
});

module.exports = router;

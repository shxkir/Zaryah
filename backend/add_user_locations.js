require('dotenv').config();
const { PrismaClient } = require('@prisma/client');

const prisma = new PrismaClient();

// Location data for major Indian cities
const userLocations = [
  {
    email: 'ismaielshakir900@gmail.com',
    city: 'Mumbai',
    state: 'Maharashtra',
    country: 'India',
    latitude: 19.0760,
    longitude: 72.8777
  },
  {
    email: 'alice.smith@example.com',
    city: 'Delhi',
    state: 'Delhi',
    country: 'India',
    latitude: 28.6139,
    longitude: 77.2090
  },
  {
    email: 'bob.johnson@example.com',
    city: 'Bangalore',
    state: 'Karnataka',
    country: 'India',
    latitude: 12.9716,
    longitude: 77.5946
  },
  {
    email: 'carol.davis@example.com',
    city: 'Hyderabad',
    state: 'Telangana',
    country: 'India',
    latitude: 17.3850,
    longitude: 78.4867
  },
  {
    email: 'david.wilson@example.com',
    city: 'Chennai',
    state: 'Tamil Nadu',
    country: 'India',
    latitude: 13.0827,
    longitude: 80.2707
  },
  {
    email: 'eva.martinez@example.com',
    city: 'Pune',
    state: 'Maharashtra',
    country: 'India',
    latitude: 18.5204,
    longitude: 73.8567
  },
  {
    email: 'zainab.ali@example.com',
    city: 'Kolkata',
    state: 'West Bengal',
    country: 'India',
    latitude: 22.5726,
    longitude: 88.3639
  },
  {
    email: 'ibrahim.malik@example.com',
    city: 'Ahmedabad',
    state: 'Gujarat',
    country: 'India',
    latitude: 23.0225,
    longitude: 72.5714
  },
  {
    email: 'mariam.khan@example.com',
    city: 'Jaipur',
    state: 'Rajasthan',
    country: 'India',
    latitude: 26.9124,
    longitude: 75.7873
  }
];

async function addLocationsToUsers() {
  try {
    console.log('🌍 Adding location data to test users...\n');

    let updatedCount = 0;
    let notFoundCount = 0;

    for (const location of userLocations) {
      const { email, ...locationData } = location;

      // Find user by email
      const user = await prisma.user.findUnique({
        where: { email },
        include: { profile: true }
      });

      if (!user) {
        console.log(`⚠️  User not found: ${email}`);
        notFoundCount++;
        continue;
      }

      if (!user.profile) {
        console.log(`⚠️  No profile for user: ${email}`);
        notFoundCount++;
        continue;
      }

      // Update profile with location data
      await prisma.profile.update({
        where: { id: user.profile.id },
        data: locationData
      });

      console.log(`✅ Updated ${user.profile.name} (${email})`);
      console.log(`   📍 ${locationData.city}, ${locationData.state}, ${locationData.country}`);
      console.log(`   🗺️  Coordinates: ${locationData.latitude}, ${locationData.longitude}\n`);
      updatedCount++;
    }

    console.log('\n' + '='.repeat(60));
    console.log(`✅ Successfully updated ${updatedCount} users with location data`);
    if (notFoundCount > 0) {
      console.log(`⚠️  ${notFoundCount} users not found or missing profiles`);
    }
    console.log('='.repeat(60));

  } catch (error) {
    console.error('❌ Error adding locations:', error);
  } finally {
    await prisma.$disconnect();
  }
}

addLocationsToUsers();

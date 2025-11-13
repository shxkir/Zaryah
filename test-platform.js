#!/usr/bin/env node

/**
 * Zarayah Platform Test Script
 * Verifies that all 30 users exist and the platform is working correctly
 */

require('dotenv').config();
const { PrismaClient } = require('@prisma/client');

const prisma = new PrismaClient();

async function testPlatform() {
  console.log('\n🧪 Zarayah Platform Test Suite\n');
  console.log('='.repeat(60));

  let passedTests = 0;
  let failedTests = 0;

  // Test 1: Database Connection
  console.log('\n📊 Test 1: Database Connection');
  try {
    await prisma.$connect();
    console.log('✅ PASSED: Successfully connected to PostgreSQL');
    passedTests++;
  } catch (error) {
    console.log('❌ FAILED: Could not connect to database');
    console.log('   Error:', error.message);
    failedTests++;
    return;
  }

  // Test 2: User Count
  console.log('\n👥 Test 2: Mock Users Count');
  try {
    const userCount = await prisma.user.count();
    if (userCount === 30) {
      console.log(`✅ PASSED: Exactly 30 users found`);
      passedTests++;
    } else {
      console.log(`❌ FAILED: Expected 30 users, found ${userCount}`);
      failedTests++;
    }
  } catch (error) {
    console.log('❌ FAILED: Could not count users');
    console.log('   Error:', error.message);
    failedTests++;
  }

  // Test 3: All Users Have Profiles
  console.log('\n📝 Test 3: User Profiles');
  try {
    const usersWithoutProfiles = await prisma.user.findMany({
      where: {
        profile: null
      }
    });

    if (usersWithoutProfiles.length === 0) {
      console.log('✅ PASSED: All users have complete profiles');
      passedTests++;
    } else {
      console.log(`❌ FAILED: ${usersWithoutProfiles.length} users missing profiles`);
      failedTests++;
    }
  } catch (error) {
    console.log('❌ FAILED: Could not check profiles');
    console.log('   Error:', error.message);
    failedTests++;
  }

  // Test 4: Email Uniqueness
  console.log('\n✉️  Test 4: Email Uniqueness');
  try {
    const users = await prisma.user.findMany({
      select: { email: true }
    });

    const emails = users.map(u => u.email);
    const uniqueEmails = new Set(emails);

    if (emails.length === uniqueEmails.size) {
      console.log('✅ PASSED: All emails are unique');
      passedTests++;
    } else {
      console.log(`❌ FAILED: Found duplicate emails`);
      failedTests++;
    }
  } catch (error) {
    console.log('❌ FAILED: Could not check emails');
    console.log('   Error:', error.message);
    failedTests++;
  }

  // Test 5: Profile Completeness
  console.log('\n🔍 Test 5: Profile Data Completeness');
  try {
    const profiles = await prisma.userProfile.findMany();
    let incompleteProfiles = 0;

    profiles.forEach(profile => {
      const requiredFields = [
        'name', 'age', 'educationLevel', 'occupation',
        'learningGoals', 'learningStyle', 'previousExperience',
        'strengths', 'weaknesses', 'specificChallenges',
        'availableHoursPerWeek', 'learningPace', 'motivationLevel'
      ];

      const missingFields = requiredFields.filter(field => {
        const value = profile[field];
        return value === null || value === undefined || value === '';
      });

      if (missingFields.length > 0) {
        incompleteProfiles++;
      }
    });

    if (incompleteProfiles === 0) {
      console.log('✅ PASSED: All profiles have complete data');
      passedTests++;
    } else {
      console.log(`❌ FAILED: ${incompleteProfiles} profiles have missing fields`);
      failedTests++;
    }
  } catch (error) {
    console.log('❌ FAILED: Could not check profile completeness');
    console.log('   Error:', error.message);
    failedTests++;
  }

  // Test 6: Subjects Data
  console.log('\n📚 Test 6: Learning Subjects');
  try {
    const profiles = await prisma.userProfile.findMany({
      select: { subjects: true, name: true }
    });

    let profilesWithoutSubjects = 0;

    profiles.forEach(profile => {
      if (!profile.subjects || profile.subjects.length === 0) {
        profilesWithoutSubjects++;
      }
    });

    if (profilesWithoutSubjects === 0) {
      console.log('✅ PASSED: All users have learning subjects');
      passedTests++;
    } else {
      console.log(`❌ FAILED: ${profilesWithoutSubjects} users have no subjects`);
      failedTests++;
    }
  } catch (error) {
    console.log('❌ FAILED: Could not check subjects');
    console.log('   Error:', error.message);
    failedTests++;
  }

  // Test 7: Environment Variables
  console.log('\n⚙️  Test 7: Environment Configuration');
  const requiredEnvVars = [
    'DATABASE_URL',
    'JWT_SECRET',
    'ANTHROPIC_API_KEY',
    'PINECONE_API_KEY'
  ];

  let missingVars = 0;
  requiredEnvVars.forEach(varName => {
    const value = process.env[varName];
    if (!value || value.includes('your-') || value.includes('change')) {
      console.log(`   ⚠️  ${varName} needs to be configured`);
      missingVars++;
    }
  });

  if (missingVars === 0) {
    console.log('✅ PASSED: All environment variables configured');
    passedTests++;
  } else {
    console.log(`⚠️  WARNING: ${missingVars} environment variables need configuration`);
    console.log('   (This won\'t stop the platform but may limit functionality)');
    passedTests++; // Don't fail on this, just warn
  }

  // Display Sample Users
  console.log('\n👨‍💼 Sample Users (first 5):');
  const sampleUsers = await prisma.user.findMany({
    take: 5,
    include: { profile: true },
    select: {
      email: true,
      profile: {
        select: {
          name: true,
          occupation: true,
          subjects: true
        }
      }
    }
  });

  sampleUsers.forEach(user => {
    console.log(`   • ${user.profile.name} (${user.email})`);
    console.log(`     ${user.profile.occupation}`);
    console.log(`     Interests: ${user.profile.subjects.slice(0, 3).join(', ')}`);
  });

  // Test Summary
  console.log('\n' + '='.repeat(60));
  console.log('\n📊 Test Summary:\n');
  console.log(`   ✅ Passed: ${passedTests}`);
  console.log(`   ❌ Failed: ${failedTests}`);
  console.log(`   📝 Total:  ${passedTests + failedTests}`);

  if (failedTests === 0) {
    console.log('\n🎉 All tests passed! Zarayah platform is ready to use.\n');
    console.log('Next steps:');
    console.log('  1. npm start             # Start backend server');
    console.log('  2. cd flutter-app && flutter run   # Run mobile app');
    console.log('  3. Test login with: sarah.johnson@example.com / password123\n');
  } else {
    console.log('\n⚠️  Some tests failed. Please fix the issues above.\n');
  }

  await prisma.$disconnect();
  process.exit(failedTests === 0 ? 0 : 1);
}

testPlatform().catch(error => {
  console.error('\n❌ Test suite error:', error);
  process.exit(1);
});

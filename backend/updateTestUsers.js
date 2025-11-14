require('dotenv').config();
const { PrismaClient } = require('@prisma/client');
const { exec } = require('child_process');

const prisma = new PrismaClient();

async function updateTestUsers() {
  console.log('🔄 Starting test user update (preserving personal accounts)...\n');

  try {
    // Step 1: Delete ONLY test users (NOT ismaielshakir900@gmail.com)
    console.log('🗑️  Deleting existing test users...');
    const deleteResult = await prisma.user.deleteMany({
      where: {
        email: {
          not: 'ismaielshakir900@gmail.com', // Preserve personal account
        },
      },
    });
    console.log(`✅ Deleted ${deleteResult.count} test users\n`);

    // Step 2: Check remaining users
    const remainingUsers = await prisma.user.findMany({
      include: {
        profile: true,
      },
    });
    console.log(`📊 Remaining users: ${remainingUsers.length}`);
    remainingUsers.forEach(user => {
      console.log(`   - ${user.profile?.name} (${user.email})`);
    });
    console.log('');

    // Step 3: Generate new users with Muslim names
    console.log('🌱 Generating new test users with Muslim names...\n');

    // Run the generateMockUsers.js script
    await new Promise((resolve, reject) => {
      exec('node generateMockUsers.js', { cwd: __dirname }, (error, stdout, stderr) => {
        if (error) {
          console.error(`Error: ${error.message}`);
          reject(error);
          return;
        }
        if (stderr) {
          console.error(`stderr: ${stderr}`);
        }
        console.log(stdout);
        resolve();
      });
    });

    // Step 4: Verify final count
    const finalUsers = await prisma.user.count();
    console.log(`\n📊 Final user count: ${finalUsers}`);
    console.log('✅ Test user update complete!');
    console.log('   Your personal account (ismaielshakir900@gmail.com) has been preserved.');

  } catch (error) {
    console.error('❌ Error updating test users:', error);
  } finally {
    await prisma.$disconnect();
  }
}

updateTestUsers();

require('dotenv').config();
const { PrismaClient } = require('@prisma/client');
const bcrypt = require('bcrypt');

const prisma = new PrismaClient();

async function createMainUser() {
  try {
    console.log('🔧 Creating main user account...');

    // Delete existing test@example.com if it exists
    await prisma.user.deleteMany({
      where: {
        email: 'test@example.com'
      }
    });

    // Check if ismaielshakir900@gmail.com already exists
    const existingUser = await prisma.user.findUnique({
      where: { email: 'ismaielshakir900@gmail.com' }
    });

    if (existingUser) {
      console.log('✅ User ismaielshakir900@gmail.com already exists');
      console.log('   Email: ismaielshakir900@gmail.com');
      console.log('   Password: password123');
      return;
    }

    // Hash the password
    const hashedPassword = await bcrypt.hash('password123', 10);

    // Create user
    const user = await prisma.user.create({
      data: {
        email: 'ismaielshakir900@gmail.com',
        password: hashedPassword,
        profile: {
          create: {
            name: 'Ismaiel Shakir',
            age: 25,
            educationLevel: 'University',
            occupation: 'Developer',
            learningGoals: 'Master full-stack development and AI integration',
            subjects: ['Computer Science', 'Artificial Intelligence', 'Web Development'],
            learningStyle: 'Hands-on, project-based learning',
            previousExperience: 'Experienced developer with knowledge of Flutter, Node.js, and databases',
            strengths: 'Problem-solving, quick learner, passionate about technology',
            weaknesses: 'Time management, sometimes over-engineering solutions',
            specificChallenges: 'Balancing multiple projects and staying up-to-date with new technologies',
            availableHoursPerWeek: 20,
            learningPace: 'Fast',
            motivationLevel: 'High'
          }
        }
      },
      include: {
        profile: true
      }
    });

    console.log('✅ Main user created successfully!');
    console.log('   Email: ismaielshakir900@gmail.com');
    console.log('   Password: password123');
    console.log(`   User ID: ${user.id}`);
    console.log(`   Profile: ${user.profile.name}`);

  } catch (error) {
    console.error('❌ Error creating user:', error);
  } finally {
    await prisma.$disconnect();
  }
}

createMainUser();

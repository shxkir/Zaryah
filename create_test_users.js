require('dotenv').config();
const { PrismaClient } = require('@prisma/client');
const bcrypt = require('bcrypt');

const prisma = new PrismaClient();

const testUsers = [
  {
    email: 'alice.smith@example.com',
    password: 'password123',
    profile: {
      name: 'Alice Smith',
      age: 28,
      bio: 'Software engineer passionate about AI and machine learning',
      educationLevel: 'Master\'s Degree',
      occupation: 'Software Engineer',
      learningGoals: 'Advanced AI and deep learning',
      subjects: ['AI', 'Machine Learning', 'Python'],
      learningStyle: 'Project-based',
      previousExperience: '5 years in software development',
      strengths: 'Problem-solving, algorithms',
      weaknesses: 'Public speaking',
      specificChallenges: 'Staying current with AI trends',
      availableHoursPerWeek: 10,
      learningPace: 'Fast',
      motivationLevel: 'High',
      city: 'San Francisco',
      country: 'United States',
    }
  },
  {
    email: 'bob.johnson@example.com',
    password: 'password123',
    profile: {
      name: 'Bob Johnson',
      age: 35,
      bio: 'Product manager with tech background',
      educationLevel: 'Bachelor\'s Degree',
      occupation: 'Product Manager',
      learningGoals: 'Technical skills for product management',
      subjects: ['Product Management', 'Data Analysis', 'UX Design'],
      learningStyle: 'Visual learner',
      previousExperience: '10 years in tech industry',
      strengths: 'Communication, strategy',
      weaknesses: 'Deep technical implementation',
      specificChallenges: 'Balancing business and technical needs',
      availableHoursPerWeek: 5,
      learningPace: 'Medium',
      motivationLevel: 'High',
      city: 'New York',
      country: 'United States',
    }
  },
  {
    email: 'carol.davis@example.com',
    password: 'password123',
    profile: {
      name: 'Carol Davis',
      age: 24,
      bio: 'Recent graduate exploring web development',
      educationLevel: 'Bachelor\'s Degree',
      occupation: 'Junior Developer',
      learningGoals: 'Full-stack web development',
      subjects: ['JavaScript', 'React', 'Node.js'],
      learningStyle: 'Hands-on practice',
      previousExperience: 'Fresh graduate with internship experience',
      strengths: 'Quick learner, enthusiastic',
      weaknesses: 'Limited real-world experience',
      specificChallenges: 'Building complex applications',
      availableHoursPerWeek: 15,
      learningPace: 'Fast',
      motivationLevel: 'Very High',
      city: 'Austin',
      country: 'United States',
    }
  },
  {
    email: 'david.wilson@example.com',
    password: 'password123',
    profile: {
      name: 'David Wilson',
      age: 42,
      bio: 'Career changer from finance to tech',
      educationLevel: 'MBA',
      occupation: 'Consultant',
      learningGoals: 'Learn programming for career transition',
      subjects: ['Python', 'Data Science', 'Business Analytics'],
      learningStyle: 'Structured courses',
      previousExperience: '15 years in finance',
      strengths: 'Business acumen, analytical thinking',
      weaknesses: 'No programming background',
      specificChallenges: 'Learning to code from scratch',
      availableHoursPerWeek: 20,
      learningPace: 'Slow',
      motivationLevel: 'High',
      city: 'Chicago',
      country: 'United States',
    }
  },
  {
    email: 'eva.martinez@example.com',
    password: 'password123',
    profile: {
      name: 'Eva Martinez',
      age: 30,
      bio: 'UX designer learning to code',
      educationLevel: 'Bachelor\'s Degree',
      occupation: 'UX Designer',
      learningGoals: 'Frontend development to implement own designs',
      subjects: ['HTML/CSS', 'JavaScript', 'Design Systems'],
      learningStyle: 'Visual and interactive',
      previousExperience: '6 years in design',
      strengths: 'Design thinking, user empathy',
      weaknesses: 'Backend development',
      specificChallenges: 'Understanding complex JavaScript',
      availableHoursPerWeek: 8,
      learningPace: 'Medium',
      motivationLevel: 'High',
      city: 'Los Angeles',
      country: 'United States',
    }
  }
];

async function createTestUsers() {
  try {
    console.log('🔧 Creating test users...\n');

    for (const userData of testUsers) {
      // Check if user already exists
      const existing = await prisma.user.findUnique({
        where: { email: userData.email }
      });

      if (existing) {
        console.log(`⏭️  Skipping ${userData.email} (already exists)`);
        continue;
      }

      // Hash password
      const hashedPassword = await bcrypt.hash(userData.password, 10);

      // Create user with profile
      const user = await prisma.user.create({
        data: {
          email: userData.email,
          password: hashedPassword,
          profile: {
            create: userData.profile
          }
        },
        include: {
          profile: true
        }
      });

      console.log(`✅ Created user: ${user.profile.name} (${user.email})`);
    }

    console.log('\n🎉 All test users created successfully!');
    console.log('\n📝 Login credentials for all users:');
    console.log('   Password: password123');
    console.log('\n📧 Email addresses:');
    testUsers.forEach(u => console.log(`   - ${u.email}`));

  } catch (error) {
    console.error('❌ Error creating test users:', error.message);
    process.exit(1);
  } finally {
    await prisma.$disconnect();
  }
}

createTestUsers();

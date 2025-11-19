const axios = require('axios');

const BASE_URL = 'http://localhost:3000/api';

const mockUsers = [
  {
    name: "Fatima Ahmed",
    email: "fatima.ahmed@example.com",
    age: 28,
    educationLevel: "Bachelor's",
    occupation: "Software Developer",
    learningGoals: "Master full-stack development and cloud architecture",
    subjects: ["Web Development", "Cloud Computing", "DevOps", "System Design"],
    learningStyle: "Visual",
    previousExperience: "3 years of frontend development with React",
    strengths: "Quick learner, good at problem-solving",
    weaknesses: "Limited backend experience",
    specificChallenges: "Understanding distributed systems and microservices",
    availableHoursPerWeek: 15,
    learningPace: "Fast",
    motivationLevel: "High"
  },
  {
    name: "Mohammed Hassan",
    email: "mohammed.hassan@example.com",
    age: 32,
    educationLevel: "Master's",
    occupation: "Data Scientist",
    learningGoals: "Advance machine learning skills and learn MLOps",
    subjects: ["Machine Learning", "Deep Learning", "Data Engineering", "Python"],
    learningStyle: "Reading-Writing",
    previousExperience: "5 years in data analytics and basic ML models",
    strengths: "Strong mathematical background, detail-oriented",
    weaknesses: "Deployment and production challenges",
    specificChallenges: "Scaling ML models and optimizing performance",
    availableHoursPerWeek: 20,
    learningPace: "Medium",
    motivationLevel: "High"
  },
  {
    name: "Aisha Rahman",
    email: "aisha.rahman@example.com",
    age: 24,
    educationLevel: "Bachelor's",
    occupation: "UX Designer",
    learningGoals: "Learn UI development and design systems",
    subjects: ["UI/UX Design", "Frontend Development", "Design Systems", "User Research"],
    learningStyle: "Visual",
    previousExperience: "2 years of UX design with Figma",
    strengths: "Creative thinking, user empathy",
    weaknesses: "Limited coding knowledge",
    specificChallenges: "Bridging design and development",
    availableHoursPerWeek: 12,
    learningPace: "Medium",
    motivationLevel: "High"
  },
  {
    name: "Omar Abdullah",
    email: "omar.abdullah@example.com",
    age: 19,
    educationLevel: "High School",
    occupation: "Student",
    learningGoals: "Prepare for computer science degree",
    subjects: ["Programming Fundamentals", "Mathematics", "Computer Science", "Web Development"],
    learningStyle: "Kinesthetic",
    previousExperience: "Basic HTML and Python from online courses",
    strengths: "Enthusiastic, willing to practice",
    weaknesses: "No formal programming training",
    specificChallenges: "Understanding algorithms and data structures",
    availableHoursPerWeek: 25,
    learningPace: "Medium",
    motivationLevel: "High"
  },
  {
    name: "Layla Nasser",
    email: "layla.nasser@example.com",
    age: 30,
    educationLevel: "Master's",
    occupation: "Product Manager",
    learningGoals: "Understand technical aspects of product development",
    subjects: ["Product Management", "Agile", "Technical Skills", "Data Analysis"],
    learningStyle: "Reading-Writing",
    previousExperience: "6 years in product management",
    strengths: "Communication, stakeholder management",
    weaknesses: "Technical implementation details",
    specificChallenges: "Making informed technical decisions",
    availableHoursPerWeek: 8,
    learningPace: "Medium",
    motivationLevel: "Medium"
  }
];

async function createMockUsers() {
  console.log('🌱 Starting to create mock users via API...\n');

  let successCount = 0;
  let errorCount = 0;
  let skipCount = 0;

  for (const userData of mockUsers) {
    try {
      const response = await axios.post(`${BASE_URL}/auth/signup`, {
        ...userData,
        password: 'password123'
      });

      console.log(`✅ Created user: ${userData.name} (${userData.email})`);
      successCount++;
    } catch (error) {
      if (error.response?.data?.error?.includes('already exists') ||
          error.response?.data?.error?.includes('unique constraint')) {
        console.log(`⚠️  User ${userData.email} already exists, skipping...`);
        skipCount++;
      } else {
        console.error(`❌ Error creating user ${userData.email}:`, error.response?.data?.error || error.message);
        errorCount++;
      }
    }
  }

  console.log('\n📊 Summary:');
  console.log(`   ✅ Successfully created: ${successCount} users`);
  console.log(`   ⚠️  Skipped (already exists): ${skipCount} users`);
  console.log(`   ❌ Errors: ${errorCount}`);
  console.log(`   📝 Total processed: ${mockUsers.length}`);
  console.log('\n🎉 Mock user creation complete!');
  console.log('   All users have the password: password123');
}

createMockUsers();

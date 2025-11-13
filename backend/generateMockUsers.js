require('dotenv').config();
const { PrismaClient } = require('@prisma/client');
const bcrypt = require('bcrypt');
const {
  initializePineconeIndex,
  bulkStoreUsersInPinecone,
} = require('./pineconeUtils');

const prisma = new PrismaClient();

const mockUsers = [
  {
    name: "Sarah Johnson",
    email: "sarah.johnson@example.com",
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
    name: "Michael Chen",
    email: "michael.chen@example.com",
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
    name: "Emily Rodriguez",
    email: "emily.rodriguez@example.com",
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
    name: "David Kim",
    email: "david.kim@example.com",
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
    name: "Jennifer Thompson",
    email: "jennifer.thompson@example.com",
    age: 35,
    educationLevel: "Bachelor's",
    occupation: "Project Manager",
    learningGoals: "Transition to product management in tech",
    subjects: ["Product Management", "Agile Methodologies", "Data Analysis", "Business Strategy"],
    learningStyle: "Reading-Writing",
    previousExperience: "10 years in project management, various industries",
    strengths: "Leadership, communication, organization",
    weaknesses: "Limited technical background",
    specificChallenges: "Understanding technical concepts and engineering workflows",
    availableHoursPerWeek: 10,
    learningPace: "Slow",
    motivationLevel: "Medium"
  },
  {
    name: "Alex Martinez",
    email: "alex.martinez@example.com",
    age: 27,
    educationLevel: "Master's",
    occupation: "Backend Developer",
    learningGoals: "Learn system design and scalability patterns",
    subjects: ["System Design", "Database Design", "Microservices", "Cloud Computing"],
    learningStyle: "Visual",
    previousExperience: "4 years building REST APIs with Node.js and Python",
    strengths: "Strong backend fundamentals, good at optimization",
    weaknesses: "Limited frontend skills",
    specificChallenges: "Designing highly scalable distributed systems",
    availableHoursPerWeek: 18,
    learningPace: "Fast",
    motivationLevel: "High"
  },
  {
    name: "Jessica Lee",
    email: "jessica.lee@example.com",
    age: 29,
    educationLevel: "Bachelor's",
    occupation: "Marketing Specialist",
    learningGoals: "Learn digital marketing analytics and automation",
    subjects: ["Digital Marketing", "Data Analytics", "Marketing Automation", "SEO"],
    learningStyle: "Auditory",
    previousExperience: "5 years in traditional marketing",
    strengths: "Creative campaigns, content creation",
    weaknesses: "Data analysis and technical tools",
    specificChallenges: "Understanding analytics platforms and automation tools",
    availableHoursPerWeek: 8,
    learningPace: "Slow",
    motivationLevel: "Medium"
  },
  {
    name: "Robert Wilson",
    email: "robert.wilson@example.com",
    age: 42,
    educationLevel: "Master's",
    occupation: "Senior Manager",
    learningGoals: "Understand AI and machine learning for business decisions",
    subjects: ["Artificial Intelligence", "Business Analytics", "Leadership", "Digital Transformation"],
    learningStyle: "Reading-Writing",
    previousExperience: "20 years in management, minimal tech background",
    strengths: "Strategic thinking, business acumen",
    weaknesses: "Technical knowledge",
    specificChallenges: "Understanding AI capabilities and limitations for business",
    availableHoursPerWeek: 5,
    learningPace: "Slow",
    motivationLevel: "Medium"
  },
  {
    name: "Amanda Brown",
    email: "amanda.brown@example.com",
    age: 26,
    educationLevel: "Bachelor's",
    occupation: "Graphic Designer",
    learningGoals: "Master 3D design and animation",
    subjects: ["3D Design", "Animation", "Motion Graphics", "Game Design"],
    learningStyle: "Visual",
    previousExperience: "3 years of 2D graphic design",
    strengths: "Artistic skills, color theory",
    weaknesses: "3D software knowledge",
    specificChallenges: "Learning Blender and 3D modeling workflows",
    availableHoursPerWeek: 14,
    learningPace: "Medium",
    motivationLevel: "High"
  },
  {
    name: "Chris Anderson",
    email: "chris.anderson@example.com",
    age: 31,
    educationLevel: "PhD",
    occupation: "Research Scientist",
    learningGoals: "Apply deep learning to research problems",
    subjects: ["Deep Learning", "Neural Networks", "Research Methods", "Python"],
    learningStyle: "Reading-Writing",
    previousExperience: "PhD in computational biology, basic ML knowledge",
    strengths: "Research methodology, analytical thinking",
    weaknesses: "Practical implementation skills",
    specificChallenges: "Implementing complex neural network architectures",
    availableHoursPerWeek: 15,
    learningPace: "Fast",
    motivationLevel: "High"
  },
  {
    name: "Maria Garcia",
    email: "maria.garcia@example.com",
    age: 23,
    educationLevel: "Bachelor's",
    occupation: "Junior Developer",
    learningGoals: "Become proficient in mobile app development",
    subjects: ["Mobile Development", "Flutter", "React Native", "UI Design"],
    learningStyle: "Kinesthetic",
    previousExperience: "1 year of web development",
    strengths: "Quick to adapt, good debugging skills",
    weaknesses: "Mobile-specific patterns",
    specificChallenges: "Understanding mobile architecture and state management",
    availableHoursPerWeek: 20,
    learningPace: "Fast",
    motivationLevel: "High"
  },
  {
    name: "James Taylor",
    email: "james.taylor@example.com",
    age: 38,
    educationLevel: "Bachelor's",
    occupation: "IT Administrator",
    learningGoals: "Learn cloud infrastructure and DevOps",
    subjects: ["Cloud Computing", "DevOps", "Kubernetes", "Linux"],
    learningStyle: "Kinesthetic",
    previousExperience: "10 years managing on-premise infrastructure",
    strengths: "System administration, troubleshooting",
    weaknesses: "Cloud-native technologies",
    specificChallenges: "Migrating to cloud infrastructure and automation",
    availableHoursPerWeek: 12,
    learningPace: "Medium",
    motivationLevel: "Medium"
  },
  {
    name: "Lisa Wang",
    email: "lisa.wang@example.com",
    age: 25,
    educationLevel: "Master's",
    occupation: "AI Researcher",
    learningGoals: "Advance in natural language processing",
    subjects: ["Natural Language Processing", "Machine Learning", "Deep Learning", "Python"],
    learningStyle: "Reading-Writing",
    previousExperience: "Master's thesis on NLP, 2 years research experience",
    strengths: "Strong theoretical foundation, research skills",
    weaknesses: "Production deployment",
    specificChallenges: "Building scalable NLP applications",
    availableHoursPerWeek: 22,
    learningPace: "Fast",
    motivationLevel: "High"
  },
  {
    name: "Daniel Miller",
    email: "daniel.miller@example.com",
    age: 45,
    educationLevel: "Bachelor's",
    occupation: "Teacher",
    learningGoals: "Integrate technology into classroom teaching",
    subjects: ["Educational Technology", "Programming for Kids", "Digital Literacy", "Curriculum Design"],
    learningStyle: "Auditory",
    previousExperience: "15 years teaching, basic computer skills",
    strengths: "Pedagogy, patience, communication",
    weaknesses: "Technical skills",
    specificChallenges: "Finding appropriate tools and learning to use them",
    availableHoursPerWeek: 7,
    learningPace: "Slow",
    motivationLevel: "Medium"
  },
  {
    name: "Rachel Green",
    email: "rachel.green@example.com",
    age: 22,
    educationLevel: "Bachelor's",
    occupation: "Student",
    learningGoals: "Build portfolio projects for job applications",
    subjects: ["Web Development", "JavaScript", "Portfolio Building", "Git"],
    learningStyle: "Visual",
    previousExperience: "Computer science degree, academic projects only",
    strengths: "Fresh knowledge, eager to learn",
    weaknesses: "Real-world project experience",
    specificChallenges: "Building production-ready applications",
    availableHoursPerWeek: 30,
    learningPace: "Fast",
    motivationLevel: "High"
  },
  {
    name: "Kevin Patel",
    email: "kevin.patel@example.com",
    age: 33,
    educationLevel: "Master's",
    occupation: "Security Engineer",
    learningGoals: "Master penetration testing and ethical hacking",
    subjects: ["Cybersecurity", "Penetration Testing", "Network Security", "Cryptography"],
    learningStyle: "Kinesthetic",
    previousExperience: "5 years in network security",
    strengths: "Network fundamentals, security mindset",
    weaknesses: "Offensive security techniques",
    specificChallenges: "Advanced exploitation and post-exploitation",
    availableHoursPerWeek: 16,
    learningPace: "Medium",
    motivationLevel: "High"
  },
  {
    name: "Sophia Nguyen",
    email: "sophia.nguyen@example.com",
    age: 27,
    educationLevel: "Bachelor's",
    occupation: "Content Creator",
    learningGoals: "Learn video editing and motion graphics",
    subjects: ["Video Editing", "Motion Graphics", "Content Strategy", "Adobe Creative Suite"],
    learningStyle: "Visual",
    previousExperience: "3 years creating content for social media",
    strengths: "Creativity, audience understanding",
    weaknesses: "Advanced editing techniques",
    specificChallenges: "Professional-level video production",
    availableHoursPerWeek: 18,
    learningPace: "Medium",
    motivationLevel: "High"
  },
  {
    name: "Thomas Wright",
    email: "thomas.wright@example.com",
    age: 36,
    educationLevel: "Bachelor's",
    occupation: "Business Analyst",
    learningGoals: "Learn data science and predictive analytics",
    subjects: ["Data Science", "Python", "Statistics", "Business Intelligence"],
    learningStyle: "Reading-Writing",
    previousExperience: "8 years in business analysis with Excel",
    strengths: "Business domain knowledge, analytical thinking",
    weaknesses: "Programming and statistics",
    specificChallenges: "Learning Python and statistical modeling",
    availableHoursPerWeek: 10,
    learningPace: "Slow",
    motivationLevel: "Medium"
  },
  {
    name: "Olivia Davis",
    email: "olivia.davis@example.com",
    age: 24,
    educationLevel: "Bachelor's",
    occupation: "QA Engineer",
    learningGoals: "Transition to automation testing and DevOps",
    subjects: ["Test Automation", "DevOps", "CI/CD", "Python"],
    learningStyle: "Kinesthetic",
    previousExperience: "2 years of manual testing",
    strengths: "Attention to detail, testing mindset",
    weaknesses: "Coding and automation",
    specificChallenges: "Building automated testing frameworks",
    availableHoursPerWeek: 15,
    learningPace: "Medium",
    motivationLevel: "High"
  },
  {
    name: "Nathan Scott",
    email: "nathan.scott@example.com",
    age: 29,
    educationLevel: "Master's",
    occupation: "Game Developer",
    learningGoals: "Master Unity and game physics",
    subjects: ["Game Development", "Unity", "C#", "Game Physics"],
    learningStyle: "Kinesthetic",
    previousExperience: "4 years developing indie games",
    strengths: "Game design, creativity",
    weaknesses: "Advanced physics and optimization",
    specificChallenges: "Optimizing games for different platforms",
    availableHoursPerWeek: 20,
    learningPace: "Fast",
    motivationLevel: "High"
  },
  {
    name: "Isabella Martin",
    email: "isabella.martin@example.com",
    age: 31,
    educationLevel: "Bachelor's",
    occupation: "HR Manager",
    learningGoals: "Learn HR analytics and people analytics",
    subjects: ["HR Analytics", "Data Analysis", "People Management", "Excel"],
    learningStyle: "Auditory",
    previousExperience: "7 years in HR, traditional methods",
    strengths: "People skills, organization",
    weaknesses: "Data analysis",
    specificChallenges: "Using data to drive HR decisions",
    availableHoursPerWeek: 6,
    learningPace: "Slow",
    motivationLevel: "Low"
  },
  {
    name: "Ethan Clark",
    email: "ethan.clark@example.com",
    age: 26,
    educationLevel: "Bachelor's",
    occupation: "Frontend Developer",
    learningGoals: "Master React and modern frontend architecture",
    subjects: ["React", "JavaScript", "TypeScript", "Frontend Architecture"],
    learningStyle: "Visual",
    previousExperience: "3 years with Vue.js",
    strengths: "Component design, CSS skills",
    weaknesses: "React ecosystem",
    specificChallenges: "State management and performance optimization in React",
    availableHoursPerWeek: 17,
    learningPace: "Fast",
    motivationLevel: "High"
  },
  {
    name: "Mia Robinson",
    email: "mia.robinson@example.com",
    age: 21,
    educationLevel: "Bachelor's",
    occupation: "Student",
    learningGoals: "Prepare for data science career",
    subjects: ["Data Science", "Statistics", "Machine Learning", "Python"],
    learningStyle: "Reading-Writing",
    previousExperience: "Statistics courses, basic Python",
    strengths: "Mathematics, academic research",
    weaknesses: "Real-world data experience",
    specificChallenges: "Working with messy real-world datasets",
    availableHoursPerWeek: 28,
    learningPace: "Medium",
    motivationLevel: "High"
  },
  {
    name: "William Turner",
    email: "william.turner@example.com",
    age: 40,
    educationLevel: "Master's",
    occupation: "Solutions Architect",
    learningGoals: "Learn serverless architecture and edge computing",
    subjects: ["Serverless Architecture", "Cloud Computing", "Edge Computing", "Microservices"],
    learningStyle: "Reading-Writing",
    previousExperience: "12 years in software architecture",
    strengths: "System design, architectural patterns",
    weaknesses: "Emerging cloud technologies",
    specificChallenges: "Designing cost-effective serverless solutions",
    availableHoursPerWeek: 12,
    learningPace: "Medium",
    motivationLevel: "High"
  },
  {
    name: "Ava Lewis",
    email: "ava.lewis@example.com",
    age: 25,
    educationLevel: "Bachelor's",
    occupation: "Digital Marketer",
    learningGoals: "Master social media advertising and analytics",
    subjects: ["Social Media Marketing", "Digital Advertising", "Analytics", "Content Marketing"],
    learningStyle: "Visual",
    previousExperience: "2 years in digital marketing",
    strengths: "Content creation, social media savvy",
    weaknesses: "Data-driven decision making",
    specificChallenges: "Measuring ROI and optimizing ad campaigns",
    availableHoursPerWeek: 11,
    learningPace: "Medium",
    motivationLevel: "Medium"
  },
  {
    name: "Ryan Hall",
    email: "ryan.hall@example.com",
    age: 34,
    educationLevel: "Bachelor's",
    occupation: "DevOps Engineer",
    learningGoals: "Master Kubernetes and container orchestration",
    subjects: ["Kubernetes", "Docker", "DevOps", "Infrastructure as Code"],
    learningStyle: "Kinesthetic",
    previousExperience: "6 years in DevOps, basic Kubernetes",
    strengths: "CI/CD, automation",
    weaknesses: "Complex Kubernetes deployments",
    specificChallenges: "Managing large-scale container orchestration",
    availableHoursPerWeek: 14,
    learningPace: "Fast",
    motivationLevel: "High"
  },
  {
    name: "Emma White",
    email: "emma.white@example.com",
    age: 28,
    educationLevel: "Master's",
    occupation: "Product Designer",
    learningGoals: "Learn user research and design thinking",
    subjects: ["User Research", "Design Thinking", "Prototyping", "UX Design"],
    learningStyle: "Visual",
    previousExperience: "4 years in product design",
    strengths: "Visual design, empathy",
    weaknesses: "Research methodologies",
    specificChallenges: "Conducting effective user research and testing",
    availableHoursPerWeek: 13,
    learningPace: "Medium",
    motivationLevel: "High"
  },
  {
    name: "Benjamin Harris",
    email: "benjamin.harris@example.com",
    age: 37,
    educationLevel: "Bachelor's",
    occupation: "Database Administrator",
    learningGoals: "Learn NoSQL databases and data modeling",
    subjects: ["Database Design", "NoSQL", "MongoDB", "Data Modeling"],
    learningStyle: "Reading-Writing",
    previousExperience: "10 years with SQL databases",
    strengths: "SQL expertise, optimization",
    weaknesses: "NoSQL paradigms",
    specificChallenges: "Transitioning from relational to document databases",
    availableHoursPerWeek: 9,
    learningPace: "Slow",
    motivationLevel: "Medium"
  },
  {
    name: "Charlotte Young",
    email: "charlotte.young@example.com",
    age: 23,
    educationLevel: "Bachelor's",
    occupation: "Junior Data Analyst",
    learningGoals: "Advance to senior data analyst role",
    subjects: ["Data Analysis", "SQL", "Python", "Data Visualization"],
    learningStyle: "Visual",
    previousExperience: "1 year of data analysis with Excel and SQL",
    strengths: "Attention to detail, visualization",
    weaknesses: "Advanced analytics and Python",
    specificChallenges: "Statistical analysis and predictive modeling",
    availableHoursPerWeek: 19,
    learningPace: "Fast",
    motivationLevel: "High"
  },
  {
    name: "Jacob King",
    email: "jacob.king@example.com",
    age: 30,
    educationLevel: "Master's",
    occupation: "Blockchain Developer",
    learningGoals: "Master smart contract development and Web3",
    subjects: ["Blockchain", "Smart Contracts", "Solidity", "Web3"],
    learningStyle: "Kinesthetic",
    previousExperience: "5 years in web development, 1 year in blockchain",
    strengths: "Programming fundamentals, web3 basics",
    weaknesses: "Smart contract security",
    specificChallenges: "Building secure and gas-efficient smart contracts",
    availableHoursPerWeek: 24,
    learningPace: "Fast",
    motivationLevel: "High"
  }
];

async function generateMockUsers() {
  console.log('🌱 Starting to generate mock users...');

  try {
    // Initialize Pinecone
    console.log('📌 Initializing Pinecone...');
    await initializePineconeIndex();

    // Hash password once (all users have the same password)
    const hashedPassword = await bcrypt.hash('password123', 10);

    let successCount = 0;
    let errorCount = 0;
    const createdUsers = [];

    for (const userData of mockUsers) {
      try {
        // Check if user already exists
        const existingUser = await prisma.user.findUnique({
          where: { email: userData.email },
        });

        if (existingUser) {
          console.log(`⚠️  User ${userData.email} already exists, skipping...`);
          continue;
        }

        // Create user with profile
        const user = await prisma.user.create({
          data: {
            email: userData.email,
            password: hashedPassword,
            profile: {
              create: {
                name: userData.name,
                age: userData.age,
                educationLevel: userData.educationLevel,
                occupation: userData.occupation,
                learningGoals: userData.learningGoals,
                subjects: userData.subjects,
                learningStyle: userData.learningStyle,
                previousExperience: userData.previousExperience,
                strengths: userData.strengths,
                weaknesses: userData.weaknesses,
                specificChallenges: userData.specificChallenges,
                availableHoursPerWeek: userData.availableHoursPerWeek,
                learningPace: userData.learningPace,
                motivationLevel: userData.motivationLevel,
              },
            },
          },
          include: {
            profile: true,
          },
        });

        createdUsers.push(user);
        console.log(`✅ Created user: ${userData.name} (${userData.email})`);
        successCount++;
      } catch (error) {
        console.error(`❌ Error creating user ${userData.email}:`, error.message);
        errorCount++;
      }
    }

    // Store all created users in Pinecone
    if (createdUsers.length > 0) {
      console.log('\n📌 Storing users in Pinecone...');
      try {
        await bulkStoreUsersInPinecone(createdUsers);
        console.log(`✅ Stored ${createdUsers.length} users in Pinecone`);
      } catch (pineconeError) {
        console.error('❌ Error storing users in Pinecone:', pineconeError);
      }
    }

    console.log('\n📊 Summary:');
    console.log(`   ✅ Successfully created: ${successCount} users`);
    console.log(`   ❌ Errors: ${errorCount}`);
    console.log(`   📝 Total processed: ${mockUsers.length}`);
    console.log('\n🎉 Mock user generation complete!');
    console.log('   All users have the password: password123');

  } catch (error) {
    console.error('❌ Fatal error during mock user generation:', error);
  } finally {
    await prisma.$disconnect();
  }
}

generateMockUsers();

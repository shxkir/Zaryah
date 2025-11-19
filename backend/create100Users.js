require('dotenv').config();
const { PrismaClient } = require('@prisma/client');
const bcrypt = require('bcryptjs');
const {
  initializePineconeIndex,
  bulkStoreUsersInPinecone,
} = require('./pineconeUtils');

const prisma = new PrismaClient();

// 100 major cities worldwide with coordinates
const worldCities = [
  { city: 'Dubai', country: 'United Arab Emirates', lat: 25.2048, lng: 55.2708 },
  { city: 'Istanbul', country: 'Turkey', lat: 41.0082, lng: 28.9784 },
  { city: 'Cairo', country: 'Egypt', lat: 30.0444, lng: 31.2357 },
  { city: 'Riyadh', country: 'Saudi Arabia', lat: 24.7136, lng: 46.6753 },
  { city: 'Kuala Lumpur', country: 'Malaysia', lat: 3.1390, lng: 101.6869 },
  { city: 'Jakarta', country: 'Indonesia', lat: -6.2088, lng: 106.8456 },
  { city: 'London', country: 'United Kingdom', lat: 51.5074, lng: -0.1278 },
  { city: 'New York', country: 'United States', lat: 40.7128, lng: -74.0060 },
  { city: 'Toronto', country: 'Canada', lat: 43.6532, lng: -79.3832 },
  { city: 'Sydney', country: 'Australia', lat: -33.8688, lng: 151.2093 },
  { city: 'Singapore', country: 'Singapore', lat: 1.3521, lng: 103.8198 },
  { city: 'Tokyo', country: 'Japan', lat: 35.6762, lng: 139.6503 },
  { city: 'Paris', country: 'France', lat: 48.8566, lng: 2.3522 },
  { city: 'Berlin', country: 'Germany', lat: 52.5200, lng: 13.4050 },
  { city: 'Amsterdam', country: 'Netherlands', lat: 52.3676, lng: 4.9041 },
  { city: 'Barcelona', country: 'Spain', lat: 41.3851, lng: 2.1734 },
  { city: 'Rome', country: 'Italy', lat: 41.9028, lng: 12.4964 },
  { city: 'Stockholm', country: 'Sweden', lat: 59.3293, lng: 18.0686 },
  { city: 'Oslo', country: 'Norway', lat: 59.9139, lng: 10.7522 },
  { city: 'Copenhagen', country: 'Denmark', lat: 55.6761, lng: 12.5683 },
  { city: 'Brussels', country: 'Belgium', lat: 50.8503, lng: 4.3517 },
  { city: 'Vienna', country: 'Austria', lat: 48.2082, lng: 16.3738 },
  { city: 'Zurich', country: 'Switzerland', lat: 47.3769, lng: 8.5417 },
  { city: 'Moscow', country: 'Russia', lat: 55.7558, lng: 37.6173 },
  { city: 'Mumbai', country: 'India', lat: 19.0760, lng: 72.8777 },
  { city: 'Delhi', country: 'India', lat: 28.7041, lng: 77.1025 },
  { city: 'Bangalore', country: 'India', lat: 12.9716, lng: 77.5946 },
  { city: 'Karachi', country: 'Pakistan', lat: 24.8607, lng: 67.0011 },
  { city: 'Lahore', country: 'Pakistan', lat: 31.5497, lng: 74.3436 },
  { city: 'Islamabad', country: 'Pakistan', lat: 33.6844, lng: 73.0479 },
  { city: 'Dhaka', country: 'Bangladesh', lat: 23.8103, lng: 90.4125 },
  { city: 'Tehran', country: 'Iran', lat: 35.6892, lng: 51.3890 },
  { city: 'Baghdad', country: 'Iraq', lat: 33.3152, lng: 44.3661 },
  { city: 'Amman', country: 'Jordan', lat: 31.9454, lng: 35.9284 },
  { city: 'Beirut', country: 'Lebanon', lat: 33.8886, lng: 35.4955 },
  { city: 'Damascus', country: 'Syria', lat: 33.5138, lng: 36.2765 },
  { city: 'Doha', country: 'Qatar', lat: 25.2854, lng: 51.5310 },
  { city: 'Abu Dhabi', country: 'United Arab Emirates', lat: 24.4539, lng: 54.3773 },
  { city: 'Kuwait City', country: 'Kuwait', lat: 29.3759, lng: 47.9774 },
  { city: 'Muscat', country: 'Oman', lat: 23.5880, lng: 58.3829 },
  { city: 'Manama', country: 'Bahrain', lat: 26.2285, lng: 50.5860 },
  { city: 'Jeddah', country: 'Saudi Arabia', lat: 21.4858, lng: 39.1925 },
  { city: 'Mecca', country: 'Saudi Arabia', lat: 21.3891, lng: 39.8579 },
  { city: 'Medina', country: 'Saudi Arabia', lat: 24.5247, lng: 39.5692 },
  { city: 'Casablanca', country: 'Morocco', lat: 33.5731, lng: -7.5898 },
  { city: 'Rabat', country: 'Morocco', lat: 34.0209, lng: -6.8416 },
  { city: 'Tunis', country: 'Tunisia', lat: 36.8065, lng: 10.1815 },
  { city: 'Algiers', country: 'Algeria', lat: 36.7372, lng: 3.0865 },
  { city: 'Tripoli', country: 'Libya', lat: 32.8872, lng: 13.1913 },
  { city: 'Khartoum', country: 'Sudan', lat: 15.5007, lng: 32.5599 },
  { city: 'Nairobi', country: 'Kenya', lat: -1.2921, lng: 36.8219 },
  { city: 'Dar es Salaam', country: 'Tanzania', lat: -6.7924, lng: 39.2083 },
  { city: 'Cape Town', country: 'South Africa', lat: -33.9249, lng: 18.4241 },
  { city: 'Johannesburg', country: 'South Africa', lat: -26.2041, lng: 28.0473 },
  { city: 'Lagos', country: 'Nigeria', lat: 6.5244, lng: 3.3792 },
  { city: 'Abuja', country: 'Nigeria', lat: 9.0579, lng: 7.4951 },
  { city: 'Accra', country: 'Ghana', lat: 5.6037, lng: -0.1870 },
  { city: 'Dakar', country: 'Senegal', lat: 14.7167, lng: -17.4677 },
  { city: 'Addis Ababa', country: 'Ethiopia', lat: 9.0320, lng: 38.7469 },
  { city: 'Kampala', country: 'Uganda', lat: 0.3476, lng: 32.5825 },
  { city: 'Los Angeles', country: 'United States', lat: 34.0522, lng: -118.2437 },
  { city: 'Chicago', country: 'United States', lat: 41.8781, lng: -87.6298 },
  { city: 'Houston', country: 'United States', lat: 29.7604, lng: -95.3698 },
  { city: 'Philadelphia', country: 'United States', lat: 39.9526, lng: -75.1652 },
  { city: 'Washington DC', country: 'United States', lat: 38.9072, lng: -77.0369 },
  { city: 'Boston', country: 'United States', lat: 42.3601, lng: -71.0589 },
  { city: 'San Francisco', country: 'United States', lat: 37.7749, lng: -122.4194 },
  { city: 'Seattle', country: 'United States', lat: 47.6062, lng: -122.3321 },
  { city: 'Miami', country: 'United States', lat: 25.7617, lng: -80.1918 },
  { city: 'Atlanta', country: 'United States', lat: 33.7490, lng: -84.3880 },
  { city: 'Vancouver', country: 'Canada', lat: 49.2827, lng: -123.1207 },
  { city: 'Montreal', country: 'Canada', lat: 45.5017, lng: -73.5673 },
  { city: 'Ottawa', country: 'Canada', lat: 45.4215, lng: -75.6972 },
  { city: 'Calgary', country: 'Canada', lat: 51.0447, lng: -114.0719 },
  { city: 'Mexico City', country: 'Mexico', lat: 19.4326, lng: -99.1332 },
  { city: 'São Paulo', country: 'Brazil', lat: -23.5505, lng: -46.6333 },
  { city: 'Rio de Janeiro', country: 'Brazil', lat: -22.9068, lng: -43.1729 },
  { city: 'Buenos Aires', country: 'Argentina', lat: -34.6037, lng: -58.3816 },
  { city: 'Lima', country: 'Peru', lat: -12.0464, lng: -77.0428 },
  { city: 'Bogotá', country: 'Colombia', lat: 4.7110, lng: -74.0721 },
  { city: 'Santiago', country: 'Chile', lat: -33.4489, lng: -70.6693 },
  { city: 'Caracas', country: 'Venezuela', lat: 10.4806, lng: -66.9036 },
  { city: 'Melbourne', country: 'Australia', lat: -37.8136, lng: 144.9631 },
  { city: 'Brisbane', country: 'Australia', lat: -27.4698, lng: 153.0251 },
  { city: 'Perth', country: 'Australia', lat: -31.9505, lng: 115.8605 },
  { city: 'Auckland', country: 'New Zealand', lat: -36.8485, lng: 174.7633 },
  { city: 'Wellington', country: 'New Zealand', lat: -41.2865, lng: 174.7762 },
  { city: 'Seoul', country: 'South Korea', lat: 37.5665, lng: 126.9780 },
  { city: 'Beijing', country: 'China', lat: 39.9042, lng: 116.4074 },
  { city: 'Shanghai', country: 'China', lat: 31.2304, lng: 121.4737 },
  { city: 'Hong Kong', country: 'Hong Kong', lat: 22.3193, lng: 114.1694 },
  { city: 'Bangkok', country: 'Thailand', lat: 13.7563, lng: 100.5018 },
  { city: 'Manila', country: 'Philippines', lat: 14.5995, lng: 120.9842 },
  { city: 'Ho Chi Minh City', country: 'Vietnam', lat: 10.8231, lng: 106.6297 },
  { city: 'Hanoi', country: 'Vietnam', lat: 21.0285, lng: 105.8542 },
  { city: 'Colombo', country: 'Sri Lanka', lat: 6.9271, lng: 79.8612 },
  { city: 'Kabul', country: 'Afghanistan', lat: 34.5553, lng: 69.2075 },
];

// Generate 100 unique Muslim users
const mockUsers = [
  // 1-10
  { name: 'Aisha Mohammed', email: 'aisha.mohammed@example.com', age: 28, occupation: 'Software Engineer', subjects: ['Web Development', 'AI', 'Cloud Computing'], educationLevel: "Bachelor's", learningGoals: 'Master full-stack development', learningStyle: 'Visual', previousExperience: '3 years coding', strengths: 'Problem solving', weaknesses: 'Time management', specificChallenges: 'Learning system design', availableHoursPerWeek: 15, learningPace: 'Fast', motivationLevel: 'High' },
  { name: 'Omar Abdullah', email: 'omar.abdullah@example.com', age: 32, occupation: 'Data Scientist', subjects: ['Machine Learning', 'Python', 'Statistics'], educationLevel: "Master's", learningGoals: 'Advance in ML and AI', learningStyle: 'Reading-Writing', previousExperience: '5 years in data', strengths: 'Math skills', weaknesses: 'Deployment', specificChallenges: 'MLOps', availableHoursPerWeek: 20, learningPace: 'Medium', motivationLevel: 'High' },
  { name: 'Fatima Hassan', email: 'fatima.hassan@example.com', age: 24, occupation: 'UX Designer', subjects: ['UI/UX', 'Design Systems', 'User Research'], educationLevel: "Bachelor's", learningGoals: 'Become senior designer', learningStyle: 'Visual', previousExperience: '2 years design', strengths: 'Creativity', weaknesses: 'Coding', specificChallenges: 'Frontend development', availableHoursPerWeek: 12, learningPace: 'Medium', motivationLevel: 'High' },
  { name: 'Yusuf Ali', email: 'yusuf.ali@example.com', age: 19, occupation: 'Student', subjects: ['Computer Science', 'Programming', 'Algorithms'], educationLevel: 'High School', learningGoals: 'Get into top university', learningStyle: 'Kinesthetic', previousExperience: 'Basic Python', strengths: 'Quick learner', weaknesses: 'Limited experience', specificChallenges: 'Data structures', availableHoursPerWeek: 25, learningPace: 'Fast', motivationLevel: 'High' },
  { name: 'Zainab Ahmed', email: 'zainab.ahmed@example.com', age: 35, occupation: 'Product Manager', subjects: ['Product Management', 'Agile', 'Business Strategy'], educationLevel: "Bachelor's", learningGoals: 'Lead product teams', learningStyle: 'Reading-Writing', previousExperience: '10 years PM', strengths: 'Leadership', weaknesses: 'Technical depth', specificChallenges: 'Tech stack decisions', availableHoursPerWeek: 10, learningPace: 'Slow', motivationLevel: 'Medium' },
  { name: 'Ibrahim Malik', email: 'ibrahim.malik@example.com', age: 27, occupation: 'Backend Developer', subjects: ['System Design', 'Microservices', 'Databases'], educationLevel: "Master's", learningGoals: 'Architect scalable systems', learningStyle: 'Visual', previousExperience: '4 years backend', strengths: 'API design', weaknesses: 'Frontend', specificChallenges: 'Distributed systems', availableHoursPerWeek: 18, learningPace: 'Fast', motivationLevel: 'High' },
  { name: 'Mariam Khan', email: 'mariam.khan@example.com', age: 29, occupation: 'Digital Marketer', subjects: ['Digital Marketing', 'SEO', 'Analytics'], educationLevel: "Bachelor's", learningGoals: 'Master growth hacking', learningStyle: 'Auditory', previousExperience: '5 years marketing', strengths: 'Content creation', weaknesses: 'Data analysis', specificChallenges: 'Marketing automation', availableHoursPerWeek: 8, learningPace: 'Slow', motivationLevel: 'Medium' },
  { name: 'Hassan Noor', email: 'hassan.noor@example.com', age: 42, occupation: 'Engineering Manager', subjects: ['Leadership', 'Software Architecture', 'Team Building'], educationLevel: "Master's", learningGoals: 'Lead large engineering teams', learningStyle: 'Reading-Writing', previousExperience: '15 years engineering', strengths: 'Mentorship', weaknesses: 'Latest tech trends', specificChallenges: 'Scaling teams', availableHoursPerWeek: 5, learningPace: 'Slow', motivationLevel: 'Medium' },
  { name: 'Khadija Rahman', email: 'khadija.rahman@example.com', age: 26, occupation: 'Graphic Designer', subjects: ['3D Design', 'Animation', 'Motion Graphics'], educationLevel: "Bachelor's", learningGoals: 'Master 3D animation', learningStyle: 'Visual', previousExperience: '3 years design', strengths: 'Artistic talent', weaknesses: '3D software', specificChallenges: 'Blender mastery', availableHoursPerWeek: 14, learningPace: 'Medium', motivationLevel: 'High' },
  { name: 'Hamza Sheikh', email: 'hamza.sheikh@example.com', age: 31, occupation: 'AI Researcher', subjects: ['Deep Learning', 'NLP', 'Computer Vision'], educationLevel: 'PhD', learningGoals: 'Publish research papers', learningStyle: 'Reading-Writing', previousExperience: 'PhD research', strengths: 'Theory', weaknesses: 'Production code', specificChallenges: 'Research to production', availableHoursPerWeek: 15, learningPace: 'Fast', motivationLevel: 'High' },

  // 11-20
  { name: 'Layla Abbas', email: 'layla.abbas@example.com', age: 23, occupation: 'Mobile Developer', subjects: ['Flutter', 'React Native', 'iOS'], educationLevel: "Bachelor's", learningGoals: 'Build popular apps', learningStyle: 'Kinesthetic', previousExperience: '1 year mobile dev', strengths: 'UI implementation', weaknesses: 'State management', specificChallenges: 'App architecture', availableHoursPerWeek: 20, learningPace: 'Fast', motivationLevel: 'High' },
  { name: 'Tariq Mansour', email: 'tariq.mansour@example.com', age: 38, occupation: 'DevOps Engineer', subjects: ['Kubernetes', 'Docker', 'CI/CD'], educationLevel: "Bachelor's", learningGoals: 'Cloud native expert', learningStyle: 'Kinesthetic', previousExperience: '10 years IT', strengths: 'Infrastructure', weaknesses: 'Cloud patterns', specificChallenges: 'K8s at scale', availableHoursPerWeek: 12, learningPace: 'Medium', motivationLevel: 'Medium' },
  { name: 'Safiya Iqbal', email: 'safiya.iqbal@example.com', age: 25, occupation: 'NLP Engineer', subjects: ['Natural Language Processing', 'Transformers', 'Python'], educationLevel: "Master's", learningGoals: 'Build LLM applications', learningStyle: 'Reading-Writing', previousExperience: '2 years NLP', strengths: 'Research', weaknesses: 'Scalability', specificChallenges: 'Production NLP', availableHoursPerWeek: 22, learningPace: 'Fast', motivationLevel: 'High' },
  { name: 'Bilal Hussain', email: 'bilal.hussain@example.com', age: 33, occupation: 'Security Engineer', subjects: ['Cybersecurity', 'Penetration Testing', 'Network Security'], educationLevel: "Master's", learningGoals: 'Become security architect', learningStyle: 'Kinesthetic', previousExperience: '5 years security', strengths: 'Network knowledge', weaknesses: 'Offensive security', specificChallenges: 'Advanced exploits', availableHoursPerWeek: 16, learningPace: 'Medium', motivationLevel: 'High' },
  { name: 'Nadia Qureshi', email: 'nadia.qureshi@example.com', age: 27, occupation: 'Content Creator', subjects: ['Video Editing', 'Social Media', 'Adobe Suite'], educationLevel: "Bachelor's", learningGoals: 'Professional video production', learningStyle: 'Visual', previousExperience: '3 years content', strengths: 'Creativity', weaknesses: 'Advanced editing', specificChallenges: 'Motion graphics', availableHoursPerWeek: 18, learningPace: 'Medium', motivationLevel: 'High' },
  { name: 'Rashid Farooq', email: 'rashid.farooq@example.com', age: 36, occupation: 'Business Analyst', subjects: ['Data Science', 'Python', 'Business Intelligence'], educationLevel: "Bachelor's", learningGoals: 'Transition to data science', learningStyle: 'Reading-Writing', previousExperience: '8 years BA', strengths: 'Domain knowledge', weaknesses: 'Programming', specificChallenges: 'Python & statistics', availableHoursPerWeek: 10, learningPace: 'Slow', motivationLevel: 'Medium' },
  { name: 'Hiba Khalil', email: 'hiba.khalil@example.com', age: 24, occupation: 'QA Engineer', subjects: ['Test Automation', 'Selenium', 'Python'], educationLevel: "Bachelor's", learningGoals: 'Automation expert', learningStyle: 'Kinesthetic', previousExperience: '2 years testing', strengths: 'Detail oriented', weaknesses: 'Coding', specificChallenges: 'Test frameworks', availableHoursPerWeek: 15, learningPace: 'Medium', motivationLevel: 'High' },
  { name: 'Imran Siddiqui', email: 'imran.siddiqui@example.com', age: 29, occupation: 'Game Developer', subjects: ['Unity', 'C#', 'Game Design'], educationLevel: "Master's", learningGoals: 'Launch successful game', learningStyle: 'Kinesthetic', previousExperience: '4 years gamedev', strengths: 'Game design', weaknesses: 'Optimization', specificChallenges: 'Cross-platform', availableHoursPerWeek: 20, learningPace: 'Fast', motivationLevel: 'High' },
  { name: 'Sumaya Rashid', email: 'sumaya.rashid@example.com', age: 31, occupation: 'HR Manager', subjects: ['HR Analytics', 'People Management', 'Excel'], educationLevel: "Bachelor's", learningGoals: 'Data-driven HR', learningStyle: 'Auditory', previousExperience: '7 years HR', strengths: 'People skills', weaknesses: 'Analytics', specificChallenges: 'HR tech tools', availableHoursPerWeek: 6, learningPace: 'Slow', motivationLevel: 'Low' },
  { name: 'Karim Mahmoud', email: 'karim.mahmoud@example.com', age: 26, occupation: 'Frontend Developer', subjects: ['React', 'TypeScript', 'CSS'], educationLevel: "Bachelor's", learningGoals: 'Senior frontend role', learningStyle: 'Visual', previousExperience: '3 years frontend', strengths: 'CSS skills', weaknesses: 'State management', specificChallenges: 'Performance optimization', availableHoursPerWeek: 17, learningPace: 'Fast', motivationLevel: 'High' },

  // 21-30
  { name: 'Yasmin Saeed', email: 'yasmin.saeed@example.com', age: 21, occupation: 'Data Analyst', subjects: ['Data Science', 'SQL', 'Tableau'], educationLevel: "Bachelor's", learningGoals: 'Senior analyst role', learningStyle: 'Reading-Writing', previousExperience: '1 year analytics', strengths: 'Math', weaknesses: 'Machine learning', specificChallenges: 'Advanced analytics', availableHoursPerWeek: 28, learningPace: 'Medium', motivationLevel: 'High' },
  { name: 'Fahad Amin', email: 'fahad.amin@example.com', age: 40, occupation: 'Solutions Architect', subjects: ['Cloud Architecture', 'AWS', 'Serverless'], educationLevel: "Master's", learningGoals: 'Cloud architect certification', learningStyle: 'Reading-Writing', previousExperience: '12 years architecture', strengths: 'System design', weaknesses: 'Serverless', specificChallenges: 'Cost optimization', availableHoursPerWeek: 12, learningPace: 'Medium', motivationLevel: 'High' },
  { name: 'Salma Youssef', email: 'salma.youssef@example.com', age: 25, occupation: 'Social Media Manager', subjects: ['Social Media Marketing', 'Analytics', 'Content Strategy'], educationLevel: "Bachelor's", learningGoals: 'Marketing director', learningStyle: 'Visual', previousExperience: '2 years SM', strengths: 'Engagement', weaknesses: 'ROI measurement', specificChallenges: 'Ad optimization', availableHoursPerWeek: 11, learningPace: 'Medium', motivationLevel: 'Medium' },
  { name: 'Adil Zahir', email: 'adil.zahir@example.com', age: 34, occupation: 'Cloud Engineer', subjects: ['Kubernetes', 'Terraform', 'GCP'], educationLevel: "Bachelor's", learningGoals: 'Multi-cloud expert', learningStyle: 'Kinesthetic', previousExperience: '6 years cloud', strengths: 'Automation', weaknesses: 'Complex deployments', specificChallenges: 'K8s orchestration', availableHoursPerWeek: 14, learningPace: 'Fast', motivationLevel: 'High' },
  { name: 'Rania Hakim', email: 'rania.hakim@example.com', age: 28, occupation: 'Product Designer', subjects: ['UX Research', 'Prototyping', 'Figma'], educationLevel: "Master's", learningGoals: 'Design leadership', learningStyle: 'Visual', previousExperience: '4 years design', strengths: 'User research', weaknesses: 'Dev handoff', specificChallenges: 'Design systems', availableHoursPerWeek: 13, learningPace: 'Medium', motivationLevel: 'High' },
  { name: 'Samir Wazir', email: 'samir.wazir@example.com', age: 37, occupation: 'Database Administrator', subjects: ['PostgreSQL', 'MongoDB', 'Database Design'], educationLevel: "Bachelor's", learningGoals: 'NoSQL mastery', learningStyle: 'Reading-Writing', previousExperience: '10 years DBA', strengths: 'SQL optimization', weaknesses: 'NoSQL', specificChallenges: 'Document databases', availableHoursPerWeek: 9, learningPace: 'Slow', motivationLevel: 'Medium' },
  { name: 'Nour Abdallah', email: 'nour.abdallah@example.com', age: 23, occupation: 'Junior Data Scientist', subjects: ['Machine Learning', 'Python', 'Statistics'], educationLevel: "Bachelor's", learningGoals: 'Senior DS role', learningStyle: 'Visual', previousExperience: '1 year DS', strengths: 'Visualization', weaknesses: 'ML theory', specificChallenges: 'Model deployment', availableHoursPerWeek: 19, learningPace: 'Fast', motivationLevel: 'High' },
  { name: 'Zayn Ibrahim', email: 'zayn.ibrahim@example.com', age: 30, occupation: 'Blockchain Developer', subjects: ['Solidity', 'Smart Contracts', 'Web3'], educationLevel: "Master's", learningGoals: 'Web3 architect', learningStyle: 'Kinesthetic', previousExperience: '5 years dev', strengths: 'Web development', weaknesses: 'Security', specificChallenges: 'Smart contract security', availableHoursPerWeek: 24, learningPace: 'Fast', motivationLevel: 'High' },
  { name: 'Amina Farouk', email: 'amina.farouk@example.com', age: 22, occupation: 'CS Student', subjects: ['Algorithms', 'Web Dev', 'Git'], educationLevel: "Bachelor's", learningGoals: 'First job in tech', learningStyle: 'Visual', previousExperience: 'Academic projects', strengths: 'Fresh knowledge', weaknesses: 'Real projects', specificChallenges: 'Production code', availableHoursPerWeek: 30, learningPace: 'Fast', motivationLevel: 'High' },
  { name: 'Mustafa Aziz', email: 'mustafa.aziz@example.com', age: 45, occupation: 'IT Director', subjects: ['IT Strategy', 'Digital Transformation', 'Leadership'], educationLevel: "Master's", learningGoals: 'CTO role', learningStyle: 'Reading-Writing', previousExperience: '20 years IT', strengths: 'Strategy', weaknesses: 'Modern tech', specificChallenges: 'Cloud migration', availableHoursPerWeek: 8, learningPace: 'Slow', motivationLevel: 'Medium' },

  // 31-40
  { name: 'Samira Osman', email: 'samira.osman@example.com', age: 27, occupation: 'iOS Developer', subjects: ['Swift', 'SwiftUI', 'iOS'], educationLevel: "Bachelor's", learningGoals: 'Lead iOS developer', learningStyle: 'Kinesthetic', previousExperience: '4 years iOS', strengths: 'UI design', weaknesses: 'Backend', specificChallenges: 'Complex architectures', availableHoursPerWeek: 16, learningPace: 'Fast', motivationLevel: 'High' },
  { name: 'Khalid Jamal', email: 'khalid.jamal@example.com', age: 33, occupation: 'ML Engineer', subjects: ['TensorFlow', 'PyTorch', 'MLOps'], educationLevel: "Master's", learningGoals: 'ML architect', learningStyle: 'Reading-Writing', previousExperience: '6 years ML', strengths: 'Model building', weaknesses: 'Deployment', specificChallenges: 'Production ML', availableHoursPerWeek: 18, learningPace: 'Fast', motivationLevel: 'High' },
  { name: 'Leila Hashim', email: 'leila.hashim@example.com', age: 24, occupation: 'Technical Writer', subjects: ['Documentation', 'API Docs', 'Content'], educationLevel: "Bachelor's", learningGoals: 'Developer advocate', learningStyle: 'Reading-Writing', previousExperience: '2 years writing', strengths: 'Communication', weaknesses: 'Technical depth', specificChallenges: 'Complex topics', availableHoursPerWeek: 12, learningPace: 'Medium', motivationLevel: 'High' },
  { name: 'Rashad Karim', email: 'rashad.karim@example.com', age: 29, occupation: 'Full Stack Developer', subjects: ['Node.js', 'React', 'PostgreSQL'], educationLevel: "Bachelor's", learningGoals: 'Tech lead', learningStyle: 'Visual', previousExperience: '5 years fullstack', strengths: 'Both frontend & backend', weaknesses: 'System design', specificChallenges: 'Scalability', availableHoursPerWeek: 15, learningPace: 'Fast', motivationLevel: 'High' },
  { name: 'Naima Saleh', email: 'naima.saleh@example.com', age: 26, occupation: 'Scrum Master', subjects: ['Agile', 'Project Management', 'Facilitation'], educationLevel: "Bachelor's", learningGoals: 'Agile coach', learningStyle: 'Auditory', previousExperience: '3 years scrum', strengths: 'Team dynamics', weaknesses: 'Technical skills', specificChallenges: 'Complex projects', availableHoursPerWeek: 10, learningPace: 'Medium', motivationLevel: 'Medium' },
  { name: 'Jawad Sabri', email: 'jawad.sabri@example.com', age: 35, occupation: 'Systems Engineer', subjects: ['Linux', 'Networking', 'Automation'], educationLevel: "Bachelor's", learningGoals: 'Cloud infrastructure', learningStyle: 'Kinesthetic', previousExperience: '9 years sysadmin', strengths: 'Troubleshooting', weaknesses: 'Cloud native', specificChallenges: 'IaC', availableHoursPerWeek: 14, learningPace: 'Medium', motivationLevel: 'High' },
  { name: 'Dina Salah', email: 'dina.salah@example.com', age: 23, occupation: 'UI Developer', subjects: ['HTML', 'CSS', 'JavaScript'], educationLevel: "Bachelor's", learningGoals: 'Frontend architect', learningStyle: 'Visual', previousExperience: '2 years UI', strengths: 'CSS animations', weaknesses: 'Complex JS', specificChallenges: 'React patterns', availableHoursPerWeek: 20, learningPace: 'Fast', motivationLevel: 'High' },
  { name: 'Faisal Nadeem', email: 'faisal.nadeem@example.com', age: 41, occupation: 'Enterprise Architect', subjects: ['Architecture', 'Microservices', 'Domain Design'], educationLevel: "Master's", learningGoals: 'Chief architect', learningStyle: 'Reading-Writing', previousExperience: '15 years architecture', strengths: 'Big picture', weaknesses: 'Implementation', specificChallenges: 'Modern patterns', availableHoursPerWeek: 10, learningPace: 'Slow', motivationLevel: 'Medium' },
  { name: 'Maha Fawzi', email: 'maha.fawzi@example.com', age: 28, occupation: 'Data Engineer', subjects: ['Spark', 'Airflow', 'Data Pipelines'], educationLevel: "Master's", learningGoals: 'Lead data engineer', learningStyle: 'Kinesthetic', previousExperience: '4 years data', strengths: 'ETL', weaknesses: 'Streaming', specificChallenges: 'Real-time pipelines', availableHoursPerWeek: 16, learningPace: 'Fast', motivationLevel: 'High' },
  { name: 'Tariq Fares', email: 'tariq.fares@example.com', age: 32, occupation: 'Security Analyst', subjects: ['SIEM', 'Threat Detection', 'Incident Response'], educationLevel: "Bachelor's", learningGoals: 'Security operations lead', learningStyle: 'Reading-Writing', previousExperience: '6 years security', strengths: 'Threat analysis', weaknesses: 'Cloud security', specificChallenges: 'Modern threats', availableHoursPerWeek: 12, learningPace: 'Medium', motivationLevel: 'High' },

  // 41-50
  { name: 'Rana Mahmood', email: 'rana.mahmood@example.com', age: 25, occupation: 'Android Developer', subjects: ['Kotlin', 'Android', 'Jetpack'], educationLevel: "Bachelor's", learningGoals: 'Senior Android dev', learningStyle: 'Visual', previousExperience: '3 years Android', strengths: 'Material design', weaknesses: 'Architecture', specificChallenges: 'Clean architecture', availableHoursPerWeek: 18, learningPace: 'Fast', motivationLevel: 'High' },
  { name: 'Saif Hussain', email: 'saif.hussain@example.com', age: 30, occupation: 'Platform Engineer', subjects: ['Kubernetes', 'Platform Engineering', 'DevOps'], educationLevel: "Master's", learningGoals: 'Staff platform engineer', learningStyle: 'Kinesthetic', previousExperience: '5 years platform', strengths: 'Infrastructure', weaknesses: 'Developer experience', specificChallenges: 'Internal platforms', availableHoursPerWeek: 15, learningPace: 'Fast', motivationLevel: 'High' },
  { name: 'Lina Taha', email: 'lina.taha@example.com', age: 27, occupation: 'Growth Hacker', subjects: ['Growth Marketing', 'A/B Testing', 'Analytics'], educationLevel: "Bachelor's", learningGoals: 'Head of growth', learningStyle: 'Visual', previousExperience: '4 years growth', strengths: 'Experimentation', weaknesses: 'Technical SEO', specificChallenges: 'Scale experiments', availableHoursPerWeek: 14, learningPace: 'Medium', motivationLevel: 'High' },
  { name: 'Walid Nasser', email: 'walid.nasser@example.com', age: 38, occupation: 'Engineering Lead', subjects: ['Leadership', 'Hiring', 'Team Building'], educationLevel: "Master's", learningGoals: 'VP Engineering', learningStyle: 'Reading-Writing', previousExperience: '12 years leadership', strengths: 'People management', weaknesses: 'Latest frameworks', specificChallenges: 'Remote teams', availableHoursPerWeek: 8, learningPace: 'Slow', motivationLevel: 'Medium' },
  { name: 'Amani Said', email: 'amani.said@example.com', age: 24, occupation: 'Research Engineer', subjects: ['Computer Vision', 'Deep Learning', 'Research'], educationLevel: "Master's", learningGoals: 'PhD in AI', learningStyle: 'Reading-Writing', previousExperience: '2 years research', strengths: 'Mathematics', weaknesses: 'Engineering', specificChallenges: 'Research to product', availableHoursPerWeek: 25, learningPace: 'Fast', motivationLevel: 'High' },
  { name: 'Majid Rahman', email: 'majid.rahman@example.com', age: 31, occupation: 'Site Reliability Engineer', subjects: ['SRE', 'Monitoring', 'Incident Management'], educationLevel: "Bachelor's", learningGoals: 'Principal SRE', learningStyle: 'Kinesthetic', previousExperience: '6 years SRE', strengths: 'Reliability', weaknesses: 'Chaos engineering', specificChallenges: 'Complex systems', availableHoursPerWeek: 16, learningPace: 'Fast', motivationLevel: 'High' },
  { name: 'Huda Khalifa', email: 'huda.khalifa@example.com', age: 26, occupation: 'Product Analyst', subjects: ['Product Analytics', 'SQL', 'Mixpanel'], educationLevel: "Bachelor's", learningGoals: 'Senior product analyst', learningStyle: 'Visual', previousExperience: '3 years analytics', strengths: 'Data interpretation', weaknesses: 'Statistics', specificChallenges: 'Causal inference', availableHoursPerWeek: 15, learningPace: 'Medium', motivationLevel: 'High' },
  { name: 'Anwar Bakri', email: 'anwar.bakri@example.com', age: 34, occupation: 'Solutions Engineer', subjects: ['Pre-sales', 'Technical Demos', 'Cloud'], educationLevel: "Bachelor's", learningGoals: 'Sales engineer', learningStyle: 'Auditory', previousExperience: '7 years SE', strengths: 'Communication', weaknesses: 'Deep technical', specificChallenges: 'Complex solutions', availableHoursPerWeek: 10, learningPace: 'Medium', motivationLevel: 'Medium' },
  { name: 'Salwa Amin', email: 'salwa.amin@example.com', age: 22, occupation: 'Junior Frontend Developer', subjects: ['React', 'JavaScript', 'CSS'], educationLevel: "Bachelor's", learningGoals: 'Mid-level developer', learningStyle: 'Visual', previousExperience: '1 year frontend', strengths: 'Fast learner', weaknesses: 'Experience', specificChallenges: 'Best practices', availableHoursPerWeek: 22, learningPace: 'Fast', motivationLevel: 'High' },
  { name: 'Rami Azmi', email: 'rami.azmi@example.com', age: 29, occupation: 'Backend Engineer', subjects: ['Go', 'Microservices', 'APIs'], educationLevel: "Bachelor's", learningGoals: 'Staff engineer', learningStyle: 'Kinesthetic', previousExperience: '5 years backend', strengths: 'Performance', weaknesses: 'Frontend', specificChallenges: 'Distributed systems', availableHoursPerWeek: 18, learningPace: 'Fast', motivationLevel: 'High' },

  // 51-60
  { name: 'Dalal Hamza', email: 'dalal.hamza@example.com', age: 28, occupation: 'Customer Success Manager', subjects: ['Customer Success', 'SaaS', 'Account Management'], educationLevel: "Bachelor's", learningGoals: 'Director of CS', learningStyle: 'Auditory', previousExperience: '4 years CS', strengths: 'Relationships', weaknesses: 'Technical product', specificChallenges: 'Retention strategies', availableHoursPerWeek: 12, learningPace: 'Medium', motivationLevel: 'High' },
  { name: 'Jamal Bakr', email: 'jamal.bakr@example.com', age: 36, occupation: 'Principal Engineer', subjects: ['System Design', 'Architecture', 'Mentoring'], educationLevel: "Master's", learningGoals: 'Distinguished engineer', learningStyle: 'Reading-Writing', previousExperience: '14 years engineering', strengths: 'Technical depth', weaknesses: 'Keeping up with trends', specificChallenges: 'Influence at scale', availableHoursPerWeek: 10, learningPace: 'Slow', motivationLevel: 'Medium' },
  { name: 'Nora Fahmy', email: 'nora.fahmy@example.com', age: 25, occupation: 'DevRel Engineer', subjects: ['Developer Relations', 'Technical Content', 'APIs'], educationLevel: "Bachelor's", learningGoals: 'Lead DevRel', learningStyle: 'Visual', previousExperience: '2 years DevRel', strengths: 'Communication', weaknesses: 'Deep tech', specificChallenges: 'Developer engagement', availableHoursPerWeek: 16, learningPace: 'Fast', motivationLevel: 'High' },
  { name: 'Sami Zaid', email: 'sami.zaid@example.com', age: 32, occupation: 'Staff Software Engineer', subjects: ['Distributed Systems', 'Scalability', 'Performance'], educationLevel: "Master's", learningGoals: 'Principal engineer', learningStyle: 'Kinesthetic', previousExperience: '8 years engineering', strengths: 'Problem solving', weaknesses: 'Communication', specificChallenges: 'Technical leadership', availableHoursPerWeek: 14, learningPace: 'Fast', motivationLevel: 'High' },
  { name: 'Aya Sharif', email: 'aya.sharif@example.com', age: 23, occupation: 'ML Intern', subjects: ['Machine Learning', 'Python', 'Statistics'], educationLevel: "Bachelor's", learningGoals: 'ML engineer role', learningStyle: 'Reading-Writing', previousExperience: 'Academic ML', strengths: 'Theory', weaknesses: 'Production ML', specificChallenges: 'Real-world projects', availableHoursPerWeek: 30, learningPace: 'Fast', motivationLevel: 'High' },
  { name: 'Hasan Younis', email: 'hasan.younis@example.com', age: 39, occupation: 'CTO', subjects: ['Technology Strategy', 'Leadership', 'Innovation'], educationLevel: "Master's", learningGoals: 'Scale tech organization', learningStyle: 'Reading-Writing', previousExperience: '16 years tech leadership', strengths: 'Vision', weaknesses: 'Hands-on coding', specificChallenges: 'Organizational scale', availableHoursPerWeek: 6, learningPace: 'Slow', motivationLevel: 'Medium' },
  { name: 'Sana Rashed', email: 'sana.rashed@example.com', age: 27, occupation: 'UX Researcher', subjects: ['User Research', 'Qualitative Methods', 'Design Thinking'], educationLevel: "Master's", learningGoals: 'Research director', learningStyle: 'Visual', previousExperience: '4 years research', strengths: 'User empathy', weaknesses: 'Quantitative methods', specificChallenges: 'Research at scale', availableHoursPerWeek: 13, learningPace: 'Medium', motivationLevel: 'High' },
  { name: 'Tamer Gamal', email: 'tamer.gamal@example.com', age: 30, occupation: 'Cloud Solutions Architect', subjects: ['Azure', 'Cloud Architecture', 'Migration'], educationLevel: "Bachelor's", learningGoals: 'Principal architect', learningStyle: 'Kinesthetic', previousExperience: '6 years cloud', strengths: 'Architecture', weaknesses: 'Cost optimization', specificChallenges: 'Multi-cloud', availableHoursPerWeek: 15, learningPace: 'Fast', motivationLevel: 'High' },
  { name: 'Mona Jalal', email: 'mona.jalal@example.com', age: 24, occupation: 'Data Analyst', subjects: ['SQL', 'Python', 'Tableau'], educationLevel: "Bachelor's", learningGoals: 'Data scientist', learningStyle: 'Visual', previousExperience: '2 years analytics', strengths: 'Visualization', weaknesses: 'ML', specificChallenges: 'Predictive models', availableHoursPerWeek: 18, learningPace: 'Medium', motivationLevel: 'High' },
  { name: 'Adnan Wahab', email: 'adnan.wahab@example.com', age: 33, occupation: 'Technical Architect', subjects: ['Software Architecture', 'Cloud Native', 'Microservices'], educationLevel: "Master's", learningGoals: 'Enterprise architect', learningStyle: 'Reading-Writing', previousExperience: '9 years architecture', strengths: 'Design patterns', weaknesses: 'Emerging tech', specificChallenges: 'Legacy modernization', availableHoursPerWeek: 12, learningPace: 'Medium', motivationLevel: 'High' },

  // 61-70
  { name: 'Ghada Othman', email: 'ghada.othman@example.com', age: 26, occupation: 'Frontend Engineer', subjects: ['Vue.js', 'TypeScript', 'Testing'], educationLevel: "Bachelor's", learningGoals: 'Frontend architect', learningStyle: 'Visual', previousExperience: '3 years frontend', strengths: 'Component design', weaknesses: 'Backend', specificChallenges: 'State complexity', availableHoursPerWeek: 17, learningPace: 'Fast', motivationLevel: 'High' },
  { name: 'Bassam Lutfi', email: 'bassam.lutfi@example.com', age: 35, occupation: 'Engineering Manager', subjects: ['Engineering Management', 'Agile', 'Career Development'], educationLevel: "Bachelor's", learningGoals: 'Director of engineering', learningStyle: 'Auditory', previousExperience: '10 years engineering', strengths: 'Team building', weaknesses: 'Modern frameworks', specificChallenges: 'Scaling teams', availableHoursPerWeek: 10, learningPace: 'Slow', motivationLevel: 'Medium' },
  { name: 'Raghad Nabil', email: 'raghad.nabil@example.com', age: 22, occupation: 'Software Engineering Intern', subjects: ['Java', 'Spring Boot', 'REST APIs'], educationLevel: "Bachelor's", learningGoals: 'Junior developer job', learningStyle: 'Kinesthetic', previousExperience: 'University projects', strengths: 'Eager to learn', weaknesses: 'Production experience', specificChallenges: 'Best practices', availableHoursPerWeek: 35, learningPace: 'Fast', motivationLevel: 'High' },
  { name: 'Ismail Qasim', email: 'ismail.qasim@example.com', age: 29, occupation: 'DevOps Lead', subjects: ['CI/CD', 'Infrastructure', 'GitOps'], educationLevel: "Bachelor's", learningGoals: 'Platform engineering', learningStyle: 'Kinesthetic', previousExperience: '5 years DevOps', strengths: 'Automation', weaknesses: 'Development', specificChallenges: 'Platform abstractions', availableHoursPerWeek: 16, learningPace: 'Fast', motivationLevel: 'High' },
  { name: 'Lamia Zahran', email: 'lamia.zahran@example.com', age: 31, occupation: 'Product Marketing Manager', subjects: ['Product Marketing', 'Positioning', 'Launch Strategy'], educationLevel: "Master's", learningGoals: 'Director PMM', learningStyle: 'Visual', previousExperience: '6 years PMM', strengths: 'Messaging', weaknesses: 'Technical depth', specificChallenges: 'Developer products', availableHoursPerWeek: 11, learningPace: 'Medium', motivationLevel: 'Medium' },
  { name: 'Ziad Mansour', email: 'ziad.mansour@example.com', age: 28, occupation: 'Backend Developer', subjects: ['Python', 'Django', 'PostgreSQL'], educationLevel: "Bachelor's", learningGoals: 'Senior backend engineer', learningStyle: 'Reading-Writing', previousExperience: '4 years backend', strengths: 'API design', weaknesses: 'Frontend', specificChallenges: 'Scalability', availableHoursPerWeek: 15, learningPace: 'Fast', motivationLevel: 'High' },
  { name: 'Nadia Fouad', email: 'nadia.fouad@example.com', age: 25, occupation: 'Interaction Designer', subjects: ['Interaction Design', 'Prototyping', 'Animation'], educationLevel: "Bachelor's", learningGoals: 'Lead designer', learningStyle: 'Visual', previousExperience: '2 years design', strengths: 'Motion design', weaknesses: 'User research', specificChallenges: 'Complex interactions', availableHoursPerWeek: 14, learningPace: 'Medium', motivationLevel: 'High' },
  { name: 'Reda Mousa', email: 'reda.mousa@example.com', age: 37, occupation: 'Software Architect', subjects: ['Event-Driven Architecture', 'DDD', 'CQRS'], educationLevel: "Master's", learningGoals: 'Chief architect', learningStyle: 'Reading-Writing', previousExperience: '13 years architecture', strengths: 'System design', weaknesses: 'Implementation speed', specificChallenges: 'Modern patterns', availableHoursPerWeek: 9, learningPace: 'Slow', motivationLevel: 'Medium' },
  { name: 'Shadia Kamal', email: 'shadia.kamal@example.com', age: 23, occupation: 'QA Automation Engineer', subjects: ['Test Automation', 'Cypress', 'API Testing'], educationLevel: "Bachelor's", learningGoals: 'Test architect', learningStyle: 'Kinesthetic', previousExperience: '1 year automation', strengths: 'Attention to detail', weaknesses: 'Complex frameworks', specificChallenges: 'E2E testing', availableHoursPerWeek: 20, learningPace: 'Fast', motivationLevel: 'High' },
  { name: 'Yahya Darwish', email: 'yahya.darwish@example.com', age: 32, occupation: 'Data Platform Engineer', subjects: ['Data Infrastructure', 'Kafka', 'Spark'], educationLevel: "Master's", learningGoals: 'Staff data engineer', learningStyle: 'Kinesthetic', previousExperience: '7 years data', strengths: 'Pipeline design', weaknesses: 'ML deployment', specificChallenges: 'Real-time data', availableHoursPerWeek: 17, learningPace: 'Fast', motivationLevel: 'High' },

  // 71-80
  { name: 'Sawsan Majid', email: 'sawsan.majid@example.com', age: 27, occupation: 'Privacy Engineer', subjects: ['Data Privacy', 'GDPR', 'Security'], educationLevel: "Bachelor's", learningGoals: 'Privacy architect', learningStyle: 'Reading-Writing', previousExperience: '3 years privacy', strengths: 'Compliance', weaknesses: 'Implementation', specificChallenges: 'Privacy-by-design', availableHoursPerWeek: 13, learningPace: 'Medium', motivationLevel: 'High' },
  { name: 'Fadi Yousef', email: 'fadi.yousef@example.com', age: 34, occupation: 'Machine Learning Lead', subjects: ['MLOps', 'Model Deployment', 'Team Leadership'], educationLevel: "PhD", learningGoals: 'ML director', learningStyle: 'Reading-Writing', previousExperience: '8 years ML', strengths: 'Research', weaknesses: 'People management', specificChallenges: 'Team scaling', availableHoursPerWeek: 12, learningPace: 'Medium', motivationLevel: 'High' },
  { name: 'Dalia Waheed', email: 'dalia.waheed@example.com', age: 24, occupation: 'Developer Advocate', subjects: ['Developer Relations', 'Content Creation', 'Community'], educationLevel: "Bachelor's", learningGoals: 'Head of DevRel', learningStyle: 'Visual', previousExperience: '2 years advocacy', strengths: 'Public speaking', weaknesses: 'Deep technical', specificChallenges: 'Developer engagement', availableHoursPerWeek: 15, learningPace: 'Fast', motivationLevel: 'High' },
  { name: 'Ashraf Selim', email: 'ashraf.selim@example.com', age: 40, occupation: 'VP of Engineering', subjects: ['Engineering Leadership', 'Org Design', 'Strategy'], educationLevel: "Master's", learningGoals: 'CTO', learningStyle: 'Reading-Writing', previousExperience: '17 years leadership', strengths: 'Organizational design', weaknesses: 'Hands-on tech', specificChallenges: 'Hypergrowth', availableHoursPerWeek: 7, learningPace: 'Slow', motivationLevel: 'Medium' },
  { name: 'Hala Samir', email: 'hala.samir@example.com', age: 26, occupation: 'Solutions Developer', subjects: ['Full Stack', 'Cloud', 'APIs'], educationLevel: "Bachelor's", learningGoals: 'Solutions architect', learningStyle: 'Kinesthetic', previousExperience: '3 years development', strengths: 'Quick prototyping', weaknesses: 'Architecture', specificChallenges: 'System design', availableHoursPerWeek: 16, learningPace: 'Fast', motivationLevel: 'High' },
  { name: 'Munir Haddad', email: 'munir.haddad@example.com', age: 31, occupation: 'Infrastructure Engineer', subjects: ['Infrastructure as Code', 'Terraform', 'Ansible'], educationLevel: "Bachelor's", learningGoals: 'Principal infrastructure', learningStyle: 'Kinesthetic', previousExperience: '6 years infra', strengths: 'Automation', weaknesses: 'Cloud native', specificChallenges: 'Multi-region', availableHoursPerWeek: 14, learningPace: 'Fast', motivationLevel: 'High' },
  { name: 'Reem Badawi', email: 'reem.badawi@example.com', age: 25, occupation: 'Product Designer', subjects: ['Product Design', 'User Flows', 'Design Systems'], educationLevel: "Bachelor's", learningGoals: 'Senior product designer', learningStyle: 'Visual', previousExperience: '2 years design', strengths: 'User thinking', weaknesses: 'Technical constraints', specificChallenges: 'Complex products', availableHoursPerWeek: 18, learningPace: 'Medium', motivationLevel: 'High' },
  { name: 'Taher Abbas', email: 'taher.abbas@example.com', age: 33, occupation: 'API Developer', subjects: ['REST APIs', 'GraphQL', 'API Design'], educationLevel: "Bachelor's", learningGoals: 'API architect', learningStyle: 'Reading-Writing', previousExperience: '7 years API dev', strengths: 'API design', weaknesses: 'Frontend', specificChallenges: 'GraphQL at scale', availableHoursPerWeek: 15, learningPace: 'Fast', motivationLevel: 'High' },
  { name: 'Asma Ramadan', email: 'asma.ramadan@example.com', age: 22, occupation: 'Junior ML Engineer', subjects: ['Machine Learning', 'TensorFlow', 'Data Science'], educationLevel: "Bachelor's", learningGoals: 'ML engineer', learningStyle: 'Reading-Writing', previousExperience: '1 year ML', strengths: 'Math background', weaknesses: 'Engineering', specificChallenges: 'Production ML', availableHoursPerWeek: 24, learningPace: 'Fast', motivationLevel: 'High' },
  { name: 'Hamdi Nassar', email: 'hamdi.nassar@example.com', age: 36, occupation: 'Security Architect', subjects: ['Security Architecture', 'Zero Trust', 'Compliance'], educationLevel: "Master's", learningGoals: 'CISO', learningStyle: 'Reading-Writing', previousExperience: '11 years security', strengths: 'Security design', weaknesses: 'Cloud security', specificChallenges: 'Modern threats', availableHoursPerWeek: 11, learningPace: 'Medium', motivationLevel: 'High' },

  // 81-90
  { name: 'Janna Harb', email: 'janna.harb@example.com', age: 28, occupation: 'Technical Product Manager', subjects: ['Product Management', 'APIs', 'Developer Tools'], educationLevel: "Master's", learningGoals: 'Senior TPM', learningStyle: 'Visual', previousExperience: '4 years PM', strengths: 'Technical depth', weaknesses: 'Business metrics', specificChallenges: 'Developer products', availableHoursPerWeek: 14, learningPace: 'Fast', motivationLevel: 'High' },
  { name: 'Kareem Badran', email: 'kareem.badran@example.com', age: 30, occupation: 'Observability Engineer', subjects: ['Monitoring', 'Observability', 'Distributed Tracing'], educationLevel: "Bachelor's", learningGoals: 'Staff SRE', learningStyle: 'Kinesthetic', previousExperience: '5 years ops', strengths: 'Debugging', weaknesses: 'Development', specificChallenges: 'Observability at scale', availableHoursPerWeek: 16, learningPace: 'Fast', motivationLevel: 'High' },
  { name: 'Lubna Ismail', email: 'lubna.ismail@example.com', age: 24, occupation: 'Growth Engineer', subjects: ['Growth Hacking', 'A/B Testing', 'Analytics'], educationLevel: "Bachelor's", learningGoals: 'Lead growth engineer', learningStyle: 'Visual', previousExperience: '2 years growth', strengths: 'Data analysis', weaknesses: 'Infrastructure', specificChallenges: 'Experimentation platform', availableHoursPerWeek: 19, learningPace: 'Fast', motivationLevel: 'High' },
  { name: 'Nabeel Sharif', email: 'nabeel.sharif@example.com', age: 35, occupation: 'AI Product Manager', subjects: ['AI Products', 'Product Strategy', 'ML'], educationLevel: "Master's", learningGoals: 'Director of AI products', learningStyle: 'Reading-Writing', previousExperience: '8 years PM', strengths: 'Product vision', weaknesses: 'Technical ML', specificChallenges: 'AI product market fit', availableHoursPerWeek: 12, learningPace: 'Medium', motivationLevel: 'High' },
  { name: 'Suha Alwan', email: 'suha.alwan@example.com', age: 27, occupation: 'Design Engineer', subjects: ['Design Engineering', 'React', 'Animation'], educationLevel: "Bachelor's", learningGoals: 'Senior design engineer', learningStyle: 'Visual', previousExperience: '3 years design eng', strengths: 'Design + code', weaknesses: 'Backend', specificChallenges: 'Complex animations', availableHoursPerWeek: 17, learningPace: 'Fast', motivationLevel: 'High' },
  { name: 'Wael Khaled', email: 'wael.khaled@example.com', age: 32, occupation: 'Performance Engineer', subjects: ['Performance', 'Profiling', 'Optimization'], educationLevel: "Bachelor's", learningGoals: 'Staff performance engineer', learningStyle: 'Kinesthetic', previousExperience: '6 years perf', strengths: 'Optimization', weaknesses: 'Frontend perf', specificChallenges: 'Web performance', availableHoursPerWeek: 15, learningPace: 'Fast', motivationLevel: 'High' },
  { name: 'Iman Zaidan', email: 'iman.zaidan@example.com', age: 23, occupation: 'Cloud Developer', subjects: ['AWS', 'Serverless', 'Lambda'], educationLevel: "Bachelor's", learningGoals: 'Cloud architect', learningStyle: 'Kinesthetic', previousExperience: '1 year cloud', strengths: 'Cloud services', weaknesses: 'Architecture', specificChallenges: 'Serverless patterns', availableHoursPerWeek: 21, learningPace: 'Fast', motivationLevel: 'High' },
  { name: 'Raed Saad', email: 'raed.saad@example.com', age: 29, occupation: 'Integration Engineer', subjects: ['System Integration', 'APIs', 'ETL'], educationLevel: "Bachelor's", learningGoals: 'Integration architect', learningStyle: 'Reading-Writing', previousExperience: '4 years integration', strengths: 'Connectors', weaknesses: 'Event-driven', specificChallenges: 'Real-time integration', availableHoursPerWeek: 14, learningPace: 'Medium', motivationLevel: 'High' },
  { name: 'Hanan Masri', email: 'hanan.masri@example.com', age: 26, occupation: 'Accessibility Engineer', subjects: ['Web Accessibility', 'WCAG', 'A11y'], educationLevel: "Bachelor's", learningGoals: 'A11y lead', learningStyle: 'Visual', previousExperience: '2 years a11y', strengths: 'Standards', weaknesses: 'Complex components', specificChallenges: 'Rich interactions', availableHoursPerWeek: 16, learningPace: 'Medium', motivationLevel: 'High' },
  { name: 'Shadi Issa', email: 'shadi.issa@example.com', age: 31, occupation: 'Reliability Engineer', subjects: ['SRE', 'Incident Response', 'Chaos Engineering'], educationLevel: "Bachelor's", learningGoals: 'Principal SRE', learningStyle: 'Kinesthetic', previousExperience: '5 years reliability', strengths: 'Troubleshooting', weaknesses: 'Software dev', specificChallenges: 'Complex failures', availableHoursPerWeek: 15, learningPace: 'Fast', motivationLevel: 'High' },

  // 91-100
  { name: 'Dima Sabbagh', email: 'dima.sabbagh@example.com', age: 25, occupation: 'Revenue Operations Analyst', subjects: ['RevOps', 'Salesforce', 'Analytics'], educationLevel: "Bachelor's", learningGoals: 'RevOps manager', learningStyle: 'Visual', previousExperience: '2 years revops', strengths: 'Process optimization', weaknesses: 'Technical integrations', specificChallenges: 'Data pipeline', availableHoursPerWeek: 13, learningPace: 'Medium', motivationLevel: 'High' },
  { name: 'Ghassan Tawfik', email: 'ghassan.tawfik@example.com', age: 38, occupation: 'Distinguished Engineer', subjects: ['Technical Leadership', 'Innovation', 'Research'], educationLevel: 'PhD', learningGoals: 'Technical Fellow', learningStyle: 'Reading-Writing', previousExperience: '15 years engineering', strengths: 'Deep expertise', weaknesses: 'Delegation', specificChallenges: 'Org-wide impact', availableHoursPerWeek: 8, learningPace: 'Slow', motivationLevel: 'Medium' },
  { name: 'Nida Hamid', email: 'nida.hamid@example.com', age: 24, occupation: 'Search Engineer', subjects: ['Elasticsearch', 'Search Relevance', 'NLP'], educationLevel: "Bachelor's", learningGoals: 'Senior search engineer', learningStyle: 'Reading-Writing', previousExperience: '2 years search', strengths: 'Ranking algorithms', weaknesses: 'ML', specificChallenges: 'Semantic search', availableHoursPerWeek: 18, learningPace: 'Fast', motivationLevel: 'High' },
  { name: 'Qasim Wehbe', email: 'qasim.wehbe@example.com', age: 30, occupation: 'Streaming Engineer', subjects: ['Kafka', 'Stream Processing', 'Real-time'], educationLevel: "Master's", learningGoals: 'Staff streaming engineer', learningStyle: 'Kinesthetic', previousExperience: '5 years streaming', strengths: 'Event processing', weaknesses: 'Batch processing', specificChallenges: 'Exactly-once semantics', availableHoursPerWeek: 16, learningPace: 'Fast', motivationLevel: 'High' },
  { name: 'Rula Abboud', email: 'rula.abboud@example.com', age: 27, occupation: 'Customer Engineer', subjects: ['Customer Engineering', 'Technical Support', 'Cloud'], educationLevel: "Bachelor's", learningGoals: 'Principal CE', learningStyle: 'Auditory', previousExperience: '3 years CE', strengths: 'Customer empathy', weaknesses: 'Deep technical', specificChallenges: 'Complex issues', availableHoursPerWeek: 12, learningPace: 'Medium', motivationLevel: 'High' },
  { name: 'Usama Ghanem', email: 'usama.ghanem@example.com', age: 33, occupation: 'Compliance Engineer', subjects: ['Compliance', 'SOC2', 'Automation'], educationLevel: "Bachelor's", learningGoals: 'Compliance architect', learningStyle: 'Reading-Writing', previousExperience: '6 years compliance', strengths: 'Frameworks', weaknesses: 'Automation', specificChallenges: 'Compliance as code', availableHoursPerWeek: 11, learningPace: 'Medium', motivationLevel: 'Medium' },
  { name: 'Wisam Jaber', email: 'wisam.jaber@example.com', age: 28, occupation: 'Edge Computing Engineer', subjects: ['Edge Computing', 'IoT', 'Distributed Systems'], educationLevel: "Master's", learningGoals: 'Edge architect', learningStyle: 'Kinesthetic', previousExperience: '4 years edge', strengths: 'Distributed systems', weaknesses: 'Hardware', specificChallenges: 'Edge orchestration', availableHoursPerWeek: 15, learningPace: 'Fast', motivationLevel: 'High' },
  { name: 'Abeer Shaaban', email: 'abeer.shaaban@example.com', age: 26, occupation: 'Voice Engineer', subjects: ['Voice AI', 'Speech Recognition', 'NLP'], educationLevel: "Master's", learningGoals: 'Voice AI lead', learningStyle: 'Reading-Writing', previousExperience: '2 years voice', strengths: 'Speech tech', weaknesses: 'Production', specificChallenges: 'Conversational AI', availableHoursPerWeek: 17, learningPace: 'Fast', motivationLevel: 'High' },
  { name: 'Zaki Habeeb', email: 'zaki.habeeb@example.com', age: 34, occupation: 'AR/VR Engineer', subjects: ['Augmented Reality', 'Unity', '3D Graphics'], educationLevel: "Bachelor's", learningGoals: 'XR architect', learningStyle: 'Visual', previousExperience: '7 years AR/VR', strengths: '3D programming', weaknesses: 'Performance', specificChallenges: 'Mobile AR', availableHoursPerWeek: 14, learningPace: 'Medium', motivationLevel: 'High' },
  { name: 'Bushra Nader', email: 'bushra.nader@example.com', age: 25, occupation: 'FinTech Engineer', subjects: ['FinTech', 'Payments', 'Compliance'], educationLevel: "Bachelor's", learningGoals: 'Senior fintech engineer', learningStyle: 'Reading-Writing', previousExperience: '2 years fintech', strengths: 'Financial systems', weaknesses: 'Regulations', specificChallenges: 'Payment infrastructure', availableHoursPerWeek: 19, learningPace: 'Fast', motivationLevel: 'High' },
];

// Function to get random city
function getRandomCity() {
  return worldCities[Math.floor(Math.random() * worldCities.length)];
}

// Function to generate avatar URL using UI Avatars
function generateAvatarUrl(name) {
  const initials = name.split(' ').map(n => n[0]).join('');
  const colors = ['00D9FF', '8B5CF6', '10B981', '3B82F6', 'F59E0B', 'EF4444', 'EC4899'];
  const randomColor = colors[Math.floor(Math.random() * colors.length)];
  return `https://ui-avatars.com/api/?name=${encodeURIComponent(name)}&background=${randomColor}&color=fff&size=200&bold=true`;
}

async function create100Users() {
  console.log('🌱 Starting to generate 100 Muslim users with worldwide locations...');

  try {
    // Initialize Pinecone
    console.log('📌 Initializing Pinecone...');
    await initializePineconeIndex();

    // Clear existing users (except your personal account)
    console.log('🗑️  Clearing existing users (keeping ismaielashruff@gmail.com)...');
    await prisma.user.deleteMany({
      where: {
        email: {
          not: 'ismaielashruff@gmail.com'
        }
      }
    });
    console.log('✅ Existing users cleared');

    // Hash password once (all users have the same password)
    const hashedPassword = await bcrypt.hash('password123', 10);

    let successCount = 0;
    let errorCount = 0;
    const createdUsers = [];

    for (const userData of mockUsers) {
      try {
        // Get random city for this user
        const location = getRandomCity();
        const avatarUrl = generateAvatarUrl(userData.name);

        // Create user with profile and location
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
                // Location data
                latitude: location.lat,
                longitude: location.lng,
                city: location.city,
                country: location.country,
                locationPrivacy: 'everyone', // Make all visible on map
                profilePicture: avatarUrl,
              },
            },
          },
          include: {
            profile: true,
          },
        });

        createdUsers.push(user);
        console.log(`✅ Created: ${userData.name} in ${location.city}, ${location.country}`);
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
    console.log(`   🌍 Users distributed across ${worldCities.length} cities worldwide`);
    console.log('\n🎉 100 Muslim users with worldwide locations created!');
    console.log('   All users have the password: password123');
    console.log('   All users are visible on the map (locationPrivacy: everyone)');
    console.log('   Avatar URLs generated using UI Avatars service');

  } catch (error) {
    console.error('❌ Fatal error during user generation:', error);
  } finally {
    await prisma.$disconnect();
  }
}

create100Users();

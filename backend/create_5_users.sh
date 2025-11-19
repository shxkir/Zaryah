#!/bin/bash

echo "🌱 Creating 5 mock users..."
echo ""

# User 1: Fatima Ahmed
echo "Creating Fatima Ahmed..."
curl -s -X POST http://localhost:3000/api/auth/signup \
  -H "Content-Type: application/json" \
  -d '{
    "email": "fatima.ahmed@example.com",
    "password": "password123",
    "name": "Fatima Ahmed",
    "age": 28,
    "educationLevel": "Bachelors",
    "occupation": "Software Developer",
    "learningGoals": "Master full-stack development and cloud architecture",
    "subjects": ["Web Development", "Cloud Computing", "DevOps"],
    "learningStyle": "Visual",
    "previousExperience": "3 years of frontend development with React",
    "strengths": "Quick learner, good at problem-solving",
    "weaknesses": "Limited backend experience",
    "specificChallenges": "Understanding distributed systems",
    "availableHoursPerWeek": 15,
    "learningPace": "Fast",
    "motivationLevel": "High"
  }' > /dev/null && echo "✅ Fatima Ahmed created" || echo "⚠️  Fatima Ahmed failed (might already exist)"

# User 2: Mohammed Hassan
echo "Creating Mohammed Hassan..."
curl -s -X POST http://localhost:3000/api/auth/signup \
  -H "Content-Type: application/json" \
  -d '{
    "email": "mohammed.hassan@example.com",
    "password": "password123",
    "name": "Mohammed Hassan",
    "age": 32,
    "educationLevel": "Masters",
    "occupation": "Data Scientist",
    "learningGoals": "Advance machine learning skills and learn MLOps",
    "subjects": ["Machine Learning", "Deep Learning", "Data Engineering", "Python"],
    "learningStyle": "Reading-Writing",
    "previousExperience": "5 years in data analytics and basic ML models",
    "strengths": "Strong mathematical background",
    "weaknesses": "Deployment challenges",
    "specificChallenges": "Scaling ML models",
    "availableHoursPerWeek": 20,
    "learningPace": "Medium",
    "motivationLevel": "High"
  }' > /dev/null && echo "✅ Mohammed Hassan created" || echo "⚠️  Mohammed Hassan failed"

# User 3: Aisha Rahman
echo "Creating Aisha Rahman..."
curl -s -X POST http://localhost:3000/api/auth/signup \
  -H "Content-Type: application/json" \
  -d '{
    "email": "aisha.rahman@example.com",
    "password": "password123",
    "name": "Aisha Rahman",
    "age": 24,
    "educationLevel": "Bachelors",
    "occupation": "UX Designer",
    "learningGoals": "Learn UI development and design systems",
    "subjects": ["UI/UX Design", "Frontend Development", "Design Systems"],
    "learningStyle": "Visual",
    "previousExperience": "2 years of UX design with Figma",
    "strengths": "Creative thinking, user empathy",
    "weaknesses": "Limited coding knowledge",
    "specificChallenges": "Bridging design and development",
    "availableHoursPerWeek": 12,
    "learningPace": "Medium",
    "motivationLevel": "High"
  }' > /dev/null && echo "✅ Aisha Rahman created" || echo "⚠️  Aisha Rahman failed"

# User 4: Omar Abdullah
echo "Creating Omar Abdullah..."
curl -s -X POST http://localhost:3000/api/auth/signup \
  -H "Content-Type: application/json" \
  -d '{
    "email": "omar.abdullah@example.com",
    "password": "password123",
    "name": "Omar Abdullah",
    "age": 19,
    "educationLevel": "High School",
    "occupation": "Student",
    "learningGoals": "Prepare for computer science degree",
    "subjects": ["Programming Fundamentals", "Mathematics", "Computer Science"],
    "learningStyle": "Kinesthetic",
    "previousExperience": "Basic HTML and Python from online courses",
    "strengths": "Enthusiastic, willing to practice",
    "weaknesses": "No formal programming training",
    "specificChallenges": "Understanding algorithms and data structures",
    "availableHoursPerWeek": 25,
    "learningPace": "Medium",
    "motivationLevel": "High"
  }' > /dev/null && echo "✅ Omar Abdullah created" || echo "⚠️  Omar Abdullah failed"

# User 5: Layla Nasser
echo "Creating Layla Nasser..."
curl -s -X POST http://localhost:3000/api/auth/signup \
  -H "Content-Type: application/json" \
  -d '{
    "email": "layla.nasser@example.com",
    "password": "password123",
    "name": "Layla Nasser",
    "age": 30,
    "educationLevel": "Masters",
    "occupation": "Product Manager",
    "learningGoals": "Understand technical aspects of product development",
    "subjects": ["Product Management", "Agile", "Technical Skills"],
    "learningStyle": "Reading-Writing",
    "previousExperience": "6 years in product management",
    "strengths": "Communication, stakeholder management",
    "weaknesses": "Technical implementation details",
    "specificChallenges": "Making informed technical decisions",
    "availableHoursPerWeek": 8,
    "learningPace": "Medium",
    "motivationLevel": "Medium"
  }' > /dev/null && echo "✅ Layla Nasser created" || echo "⚠️  Layla Nasser failed"

echo ""
echo "🎉 User creation complete!"
echo "   All users have password: password123"

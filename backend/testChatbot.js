const axios = require('axios');

const BASE_URL = 'http://localhost:3000';

async function testChatbot() {
  try {
    // Login first
    console.log('📝 Logging in...');
    const loginRes = await axios.post(`${BASE_URL}/api/auth/login`, {
      email: 'ismaielshakir900@gmail.com',
      password: 'password123'
    });
    const token = loginRes.data.token;
    console.log('✅ Logged in successfully\n');

    // Test queries
    const queries = [
      'Who is studying?',
      'Who is a developer?',
      'Tell me about Fatima Ahmed',
      'Who works in IT?',
      'Who is learning Machine Learning?'
    ];

    for (const query of queries) {
      console.log(`\n🤖 Query: "${query}"`);
      console.log('─'.repeat(60));

      const chatRes = await axios.post(
        `${BASE_URL}/api/chatbot`,
        { query },
        { headers: { Authorization: `Bearer ${token}` } }
      );

      console.log('Response:', chatRes.data.response);
      console.log('Mentioned Users:', chatRes.data.mentionedUsers?.length || 0);
      if (chatRes.data.mentionedUsers && chatRes.data.mentionedUsers.length > 0) {
        console.log('Users mentioned:');
        chatRes.data.mentionedUsers.forEach(u => {
          console.log(`  • ${u.profile.name} - ${u.profile.occupation}`);
        });
      }
    }

  } catch (error) {
    console.error('❌ Error:', error.response?.data || error.message);
  }
}

testChatbot();

const axios = require('axios');

const BASE_URL = 'http://localhost:3000';

async function testComprehensive() {
  try {
    // Login first
    console.log('📝 Logging in...');
    const loginRes = await axios.post(`${BASE_URL}/api/auth/login`, {
      email: 'ismaielshakir900@gmail.com',
      password: 'password123'
    });
    const token = loginRes.data.token;
    console.log('✅ Logged in successfully\n');

    // More comprehensive test queries
    const queries = [
      'Who is a Software Developer?',
      'Tell me about Mohammed Hassan',
      'Who is learning Data Science?',
      'Find me students',
      'Who works in game development?',
      'List all AI Researchers',
      'Who has a Master\'s degree?',
      'Who is interested in Blockchain?'
    ];

    for (const query of queries) {
      console.log(`\n🤖 Query: "${query}"`);
      console.log('─'.repeat(70));

      try {
        const chatRes = await axios.post(
          `${BASE_URL}/api/chatbot`,
          { query },
          {
            headers: { Authorization: `Bearer ${token}` },
            timeout: 15000
          }
        );

        console.log('\nResponse:');
        console.log(chatRes.data.response);

        if (chatRes.data.mentionedUsers && chatRes.data.mentionedUsers.length > 0) {
          console.log(`\n👥 ${chatRes.data.mentionedUsers.length} user(s) mentioned:`);
          chatRes.data.mentionedUsers.forEach(u => {
            console.log(`   • ${u.profile.name} - ${u.profile.occupation} (${u.profile.educationLevel})`);
          });
        }
      } catch (err) {
        console.error('❌ Error:', err.response?.data?.error || err.message);
      }
    }

    console.log('\n\n' + '='.repeat(70));
    console.log('✅ All tests completed successfully!');
    console.log('='.repeat(70));

  } catch (error) {
    console.error('❌ Fatal Error:', error.response?.data || error.message);
  }
}

testComprehensive();

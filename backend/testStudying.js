const axios = require('axios');

const BASE_URL = 'http://localhost:3000';

async function testStudying() {
  try {
    // Login first
    console.log('📝 Logging in...');
    const loginRes = await axios.post(`${BASE_URL}/api/auth/login`, {
      email: 'ismaielshakir900@gmail.com',
      password: 'password123'
    });
    const token = loginRes.data.token;
    console.log('✅ Logged in successfully\n');

    // Test studying-related queries
    const queries = [
      'Who is studying?',
      'Find me students who are studying',
      'Show me people who are learning',
    ];

    for (const query of queries) {
      console.log(`\n${'='.repeat(70)}`);
      console.log(`🤖 Query: "${query}"`);
      console.log('='.repeat(70));

      try {
        const chatRes = await axios.post(
          `${BASE_URL}/api/chatbot`,
          { query },
          {
            headers: { Authorization: `Bearer ${token}` },
            timeout: 15000
          }
        );

        console.log('\n✅ Response:');
        console.log(chatRes.data.response);

        if (chatRes.data.mentionedUsers && chatRes.data.mentionedUsers.length > 0) {
          console.log(`\n👥 ${chatRes.data.mentionedUsers.length} user(s) found with contact info:`);
          chatRes.data.mentionedUsers.forEach(u => {
            console.log(`   • ${u.profile.name} - ${u.profile.occupation} (${u.profile.educationLevel})`);
            console.log(`     Email: ${u.email}`);
            console.log(`     Learning Goals: ${u.profile.learningGoals}`);
          });
        } else {
          console.log('\n⚠️  No users mentioned in response');
        }
      } catch (err) {
        console.error('❌ Error:', err.response?.data?.error || err.message);
      }
    }

    console.log('\n\n' + '='.repeat(70));
    console.log('✅ All studying tests completed!');
    console.log('='.repeat(70));

  } catch (error) {
    console.error('❌ Fatal Error:', error.response?.data || error.message);
  }
}

testStudying();

const axios = require('axios');

const BASE_URL = 'http://localhost:3000';

async function testVariations() {
  try {
    // Login first
    console.log('📝 Logging in...');
    const loginRes = await axios.post(`${BASE_URL}/api/auth/login`, {
      email: 'ismaielshakir900@gmail.com',
      password: 'password123'
    });
    const token = loginRes.data.token;
    console.log('✅ Logged in successfully\n');

    // Test various short forms and different ways of asking
    const queries = [
      // Developer variations
      'dev',
      'devs',
      'developers',
      'who dev',
      'show devs',
      'find dev',

      // Student variations
      'students',
      'student',
      'who student',
      'studying',
      'whos studying',

      // Learning variations
      'learning ML',
      'learning machine learning',
      'who learning',
      'ppl learning',

      // Education variations
      'masters',
      'master degree',
      'phd',
      'bachelor',

      // Occupation variations
      'designer',
      'managers',
      'engineer',
      'data scientist',

      // Subject variations
      'python',
      'javascript',
      'blockchain',
      'AI',
      'ML',
      'web dev',

      // Specific person
      'fatima',
      'mohammed',
      'omar',
    ];

    for (const query of queries) {
      console.log(`\n${'─'.repeat(70)}`);
      console.log(`🤖 Query: "${query}"`);

      try {
        const chatRes = await axios.post(
          `${BASE_URL}/api/chatbot`,
          { query },
          {
            headers: { Authorization: `Bearer ${token}` },
            timeout: 15000
          }
        );

        // Show condensed response
        const responsePreview = chatRes.data.response.substring(0, 150);
        console.log(`📝 Response: ${responsePreview}${chatRes.data.response.length > 150 ? '...' : ''}`);

        if (chatRes.data.mentionedUsers && chatRes.data.mentionedUsers.length > 0) {
          console.log(`✅ ${chatRes.data.mentionedUsers.length} users found with contact info`);
        } else {
          console.log(`⚠️  0 users found`);
        }
      } catch (err) {
        console.error('❌ Error:', err.response?.data?.error || err.message);
      }
    }

    console.log('\n\n' + '='.repeat(70));
    console.log('✅ All variation tests completed!');
    console.log('='.repeat(70));

  } catch (error) {
    console.error('❌ Fatal Error:', error.response?.data || error.message);
  }
}

testVariations();

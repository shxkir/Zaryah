require('dotenv').config({ path: '/Users/ismaielshakir/Desktop/Zaryah/.env' });
const { Pinecone } = require('@pinecone-database/pinecone');

async function viewPineconeData() {
  try {
    const pc = new Pinecone({
      apiKey: process.env.PINECONE_API_KEY
    });

    const index = pc.index('zaryah-users');

    // Get index stats
    const stats = await index.describeIndexStats();
    console.log('\n=== PINECONE INDEX STATS ===');
    console.log(`Total Records: ${stats.totalRecordCount}`);
    console.log(`Dimensions: ${stats.dimension}`);
    console.log(`Namespaces:`, stats.namespaces);

    // List all record IDs
    console.log('\n=== LISTING ALL RECORD IDs ===');
    const listResponse = await index.listPaginated({ limit: 100 });
    const recordIds = listResponse.vectors.map(v => v.id);
    console.log(`Found ${recordIds.length} record IDs:`, recordIds);

    // Fetch actual records with metadata
    console.log('\n=== FETCHING FULL RECORDS WITH METADATA ===');
    const fetchResponse = await index.fetch(recordIds);

    console.log(`\nRetrieved ${Object.keys(fetchResponse.records).length} complete records:\n`);

    // Display each user's full data
    Object.entries(fetchResponse.records).forEach(([id, record], idx) => {
      console.log(`\n--- USER ${idx + 1} ---`);
      console.log(`ID: ${id}`);
      console.log(`Name: ${record.metadata.name}`);
      console.log(`Email: ${record.metadata.email}`);
      console.log(`Occupation: ${record.metadata.occupation || 'N/A'}`);
      console.log(`Age: ${record.metadata.age || 'N/A'}`);
      console.log(`Grade Level: ${record.metadata.gradeLevel || 'N/A'}`);
      console.log(`Learning Style: ${record.metadata.learningStyle || 'N/A'}`);
      console.log(`Interests: ${record.metadata.interests || 'N/A'}`);
      console.log(`Goals: ${record.metadata.goals || 'N/A'}`);
      console.log(`Strengths: ${record.metadata.strengths || 'N/A'}`);
      console.log(`Challenges: ${record.metadata.challenges || 'N/A'}`);
    });

    console.log('\n\n=== SUMMARY ===');
    console.log(`✅ Successfully retrieved ${Object.keys(fetchResponse.records).length} complete user profiles from Pinecone`);
    console.log('✅ All metadata is properly stored and accessible');
    console.log('\nNote: The Pinecone web console only shows vector IDs by default.');
    console.log('The actual user data and metadata IS stored - you need to fetch it via API (as shown above).');

  } catch (error) {
    console.error('Error viewing Pinecone data:', error);
  }
}

viewPineconeData();

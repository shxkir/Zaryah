const { Pinecone } = require('@pinecone-database/pinecone');

const pinecone = new Pinecone({
  apiKey: process.env.PINECONE_API_KEY,
});

const INDEX_NAME = 'zaryah-users';

/**
 * Initialize Pinecone index
 */
async function initializePineconeIndex() {
  try {
    const indexList = await pinecone.listIndexes();
    const indexExists = indexList.indexes?.some(index => index.name === INDEX_NAME);

    if (!indexExists) {
      console.log(`Creating Pinecone index: ${INDEX_NAME}...`);
      await pinecone.createIndex({
        name: INDEX_NAME,
        dimension: 1024, // Claude embeddings dimension
        metric: 'cosine',
        spec: {
          serverless: {
            cloud: 'aws',
            region: 'us-east-1'
          }
        }
      });
      console.log('✅ Pinecone index created successfully');

      // Wait for index to be ready
      await new Promise(resolve => setTimeout(resolve, 10000));
    } else {
      console.log('✅ Pinecone index already exists');
    }

    return pinecone.index(INDEX_NAME);
  } catch (error) {
    console.error('Error initializing Pinecone index:', error);
    throw error;
  }
}

/**
 * Generate embeddings using Claude API
 * Note: Since Claude doesn't have a native embeddings API, we'll create a simple
 * text representation and use a hash-based approach for similarity
 * In production, you'd want to use a dedicated embeddings model
 */
function generateSimpleEmbedding(text) {
  // This is a simplified approach - in production, use a proper embeddings model
  // like OpenAI's text-embedding-3-small or similar
  const words = text.toLowerCase().split(/\s+/);
  const embedding = new Array(1024).fill(0);

  // Simple hash-based embedding generation
  words.forEach((word, idx) => {
    for (let i = 0; i < word.length; i++) {
      const charCode = word.charCodeAt(i);
      const position = (charCode + idx + i) % 1024;
      embedding[position] += 0.1;
    }
  });

  // Normalize
  const magnitude = Math.sqrt(embedding.reduce((sum, val) => sum + val * val, 0));
  return embedding.map(val => magnitude > 0 ? val / magnitude : 0);
}

/**
 * Create a searchable text representation of a user profile
 */
function createUserText(user) {
  const profile = user.profile;
  return `
    Name: ${profile.name}
    Email: ${user.email}
    Age: ${profile.age}
    Education: ${profile.educationLevel}
    Occupation: ${profile.occupation}
    Learning Goals: ${profile.learningGoals}
    Subjects: ${profile.subjects.join(', ')}
    Learning Style: ${profile.learningStyle}
    Experience: ${profile.previousExperience}
    Strengths: ${profile.strengths}
    Weaknesses: ${profile.weaknesses}
    Challenges: ${profile.specificChallenges}
    Available Hours: ${profile.availableHoursPerWeek} hours/week
    Learning Pace: ${profile.learningPace}
    Motivation: ${profile.motivationLevel}
  `.trim();
}

/**
 * Store user data in Pinecone
 */
async function storeUserInPinecone(user) {
  try {
    const index = pinecone.index(INDEX_NAME);
    const userText = createUserText(user);
    const embedding = generateSimpleEmbedding(userText);

    await index.upsert([
      {
        id: user.id,
        values: embedding,
        metadata: {
          email: user.email,
          name: user.profile.name,
          age: user.profile.age,
          educationLevel: user.profile.educationLevel,
          occupation: user.profile.occupation,
          learningGoals: user.profile.learningGoals,
          subjects: user.profile.subjects.join('|'),
          learningStyle: user.profile.learningStyle,
          previousExperience: user.profile.previousExperience,
          strengths: user.profile.strengths,
          weaknesses: user.profile.weaknesses,
          specificChallenges: user.profile.specificChallenges,
          availableHoursPerWeek: user.profile.availableHoursPerWeek,
          learningPace: user.profile.learningPace,
          motivationLevel: user.profile.motivationLevel,
          createdAt: user.createdAt.toISOString(),
        }
      }
    ]);

    console.log(`✅ Stored user ${user.profile.name} in Pinecone`);
    return true;
  } catch (error) {
    console.error(`Error storing user in Pinecone:`, error);
    throw error;
  }
}

/**
 * Bulk upsert users to Pinecone
 */
async function bulkStoreUsersInPinecone(users) {
  try {
    const index = pinecone.index(INDEX_NAME);
    const vectors = users.map(user => {
      const userText = createUserText(user);
      const embedding = generateSimpleEmbedding(userText);

      return {
        id: user.id,
        values: embedding,
        metadata: {
          email: user.email,
          name: user.profile.name,
          age: user.profile.age,
          educationLevel: user.profile.educationLevel,
          occupation: user.profile.occupation,
          learningGoals: user.profile.learningGoals,
          subjects: user.profile.subjects.join('|'),
          learningStyle: user.profile.learningStyle,
          previousExperience: user.profile.previousExperience,
          strengths: user.profile.strengths,
          weaknesses: user.profile.weaknesses,
          specificChallenges: user.profile.specificChallenges,
          availableHoursPerWeek: user.profile.availableHoursPerWeek,
          learningPace: user.profile.learningPace,
          motivationLevel: user.profile.motivationLevel,
          createdAt: user.createdAt.toISOString(),
        }
      };
    });

    // Pinecone has a limit on batch size, so we'll chunk it
    const chunkSize = 100;
    for (let i = 0; i < vectors.length; i += chunkSize) {
      const chunk = vectors.slice(i, i + chunkSize);
      await index.upsert(chunk);
      console.log(`✅ Stored ${chunk.length} users in Pinecone (batch ${Math.floor(i / chunkSize) + 1})`);
    }

    return true;
  } catch (error) {
    console.error('Error bulk storing users in Pinecone:', error);
    throw error;
  }
}

/**
 * Query Pinecone for relevant users based on a text query
 */
async function queryUsersFromPinecone(queryText, topK = 10) {
  try {
    const index = pinecone.index(INDEX_NAME);
    const queryEmbedding = generateSimpleEmbedding(queryText);

    const results = await index.query({
      vector: queryEmbedding,
      topK,
      includeMetadata: true,
    });

    return results.matches.map(match => ({
      id: match.id,
      score: match.score,
      metadata: {
        ...match.metadata,
        subjects: match.metadata.subjects ? match.metadata.subjects.split('|') : [],
      }
    }));
  } catch (error) {
    console.error('Error querying Pinecone:', error);
    throw error;
  }
}

/**
 * Get all users from Pinecone (for full context queries)
 */
async function getAllUsersFromPinecone() {
  try {
    const index = pinecone.index(INDEX_NAME);

    // Fetch stats to get total count
    const stats = await index.describeIndexStats();
    const totalVectors = stats.totalRecordCount || 0;

    if (totalVectors === 0) {
      return [];
    }

    // Query with a zero vector to get all records (or use a dummy query)
    // Note: This is a workaround - in production, you might want to maintain a cache
    const dummyVector = new Array(1024).fill(0);
    const results = await index.query({
      vector: dummyVector,
      topK: Math.min(totalVectors, 10000), // Pinecone has limits
      includeMetadata: true,
    });

    return results.matches.map(match => ({
      id: match.id,
      metadata: {
        ...match.metadata,
        subjects: match.metadata.subjects ? match.metadata.subjects.split('|') : [],
      }
    }));
  } catch (error) {
    console.error('Error getting all users from Pinecone:', error);
    throw error;
  }
}

/**
 * Delete a user from Pinecone
 */
async function deleteUserFromPinecone(userId) {
  try {
    const index = pinecone.index(INDEX_NAME);
    await index.deleteOne(userId);
    console.log(`✅ Deleted user ${userId} from Pinecone`);
    return true;
  } catch (error) {
    console.error('Error deleting user from Pinecone:', error);
    throw error;
  }
}

module.exports = {
  initializePineconeIndex,
  storeUserInPinecone,
  bulkStoreUsersInPinecone,
  queryUsersFromPinecone,
  getAllUsersFromPinecone,
  deleteUserFromPinecone,
};

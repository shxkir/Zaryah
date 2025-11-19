const express = require('express');
const router = express.Router();
const { PrismaClient } = require('@prisma/client');
const OpenAI = require('openai');
const axios = require('axios');

const prisma = new PrismaClient();
const openai = new OpenAI({
  apiKey: process.env.OPENAI_API_KEY,
});

// Authentication middleware
const jwt = require('jsonwebtoken');
const JWT_SECRET = process.env.JWT_SECRET || 'your-secret-key-change-in-production';

const authenticateToken = (req, res, next) => {
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1];

  if (!token) {
    return res.status(401).json({ error: 'Access token required' });
  }

  jwt.verify(token, JWT_SECRET, (err, user) => {
    if (err) {
      return res.status(403).json({ error: 'Invalid or expired token' });
    }
    req.user = user;
    next();
  });
};

// Helper functions for chatbot to query database

async function getUserByName(name) {
  const profiles = await prisma.profile.findMany({
    where: {
      name: {
        contains: name,
        mode: 'insensitive'
      }
    },
    include: {
      user: {
        select: {
          id: true,
          email: true
        }
      }
    }
  });
  return profiles;
}

async function getUsersByLocation(location) {
  const profiles = await prisma.profile.findMany({
    where: {
      AND: [
        {
          OR: [
            { city: { contains: location, mode: 'insensitive' } },
            { country: { contains: location, mode: 'insensitive' } }
          ]
        },
        // Exclude Israel from results
        {
          country: { not: { contains: 'israel', mode: 'insensitive' } }
        },
        {
          city: { not: { contains: 'israel', mode: 'insensitive' } }
        }
      ]
    },
    include: {
      user: {
        select: {
          id: true,
          email: true
        }
      }
    }
  });
  return profiles;
}

async function getHousingInLocation(location) {
  const listings = await prisma.housingListing.findMany({
    where: {
      isActive: true,
      OR: [
        { locality: { contains: location, mode: 'insensitive' } },
        { fullAddress: { contains: location, mode: 'insensitive' } }
      ]
    },
    include: {
      user: {
        include: {
          profile: {
            select: {
              name: true,
              profilePicture: true
            }
          }
        }
      }
    },
    take: 10
  });
  return listings;
}

async function getHousingStats() {
  const total = await prisma.housingListing.count({
    where: { isActive: true }
  });

  const byLocality = await prisma.housingListing.groupBy({
    by: ['locality'],
    where: { isActive: true },
    _count: true
  });

  return { total, byLocality };
}

async function getStockPrice(symbol) {
  try {
    // Try Indian stock first
    const nsSymbol = symbol.includes('.') ? symbol : `${symbol}.NS`;
    const url = `https://query1.finance.yahoo.com/v8/finance/chart/${nsSymbol}`;
    const response = await axios.get(url, { timeout: 5000 });

    if (response.data?.chart?.result?.[0]) {
      const meta = response.data.chart.result[0].meta;
      return {
        symbol: meta.symbol,
        price: meta.regularMarketPrice,
        change: meta.regularMarketPrice - meta.previousClose,
        changePercent: ((meta.regularMarketPrice - meta.previousClose) / meta.previousClose * 100).toFixed(2)
      };
    }
  } catch (error) {
    console.error('Error fetching stock:', error.message);
  }
  return null;
}

async function getCurrencyRate(from, to) {
  try {
    const url = `https://api.exchangerate-api.com/v4/latest/${from}`;
    const response = await axios.get(url, { timeout: 5000 });

    if (response.data?.rates?.[to]) {
      return {
        from,
        to,
        rate: response.data.rates[to]
      };
    }
  } catch (error) {
    console.error('Error fetching currency:', error.message);
  }
  return null;
}

async function getCommodityPrice(commodity) {
  // Mock data for demonstration
  const prices = {
    'GOLD': { price: 62500, currency: 'INR', unit: 'per 10 grams', change: 150 },
    'SILVER': { price: 72500, currency: 'INR', unit: 'per kg', change: -200 },
    'CRUDE_OIL': { price: 6800, currency: 'INR', unit: 'per barrel', change: 50 },
    'OIL': { price: 6800, currency: 'INR', unit: 'per barrel', change: 50 }
  };
  return prices[commodity.toUpperCase()] || null;
}

// Function calling tools for GPT-4
const tools = [
  {
    type: 'function',
    function: {
      name: 'get_user_by_name',
      description: 'Search for users by name',
      parameters: {
        type: 'object',
        properties: {
          name: {
            type: 'string',
            description: 'The name to search for'
          }
        },
        required: ['name']
      }
    }
  },
  {
    type: 'function',
    function: {
      name: 'get_users_by_location',
      description: 'Find users in a specific location (city or country)',
      parameters: {
        type: 'object',
        properties: {
          location: {
            type: 'string',
            description: 'The city or country to search in'
          }
        },
        required: ['location']
      }
    }
  },
  {
    type: 'function',
    function: {
      name: 'get_housing_in_location',
      description: 'Find housing listings in a specific location',
      parameters: {
        type: 'object',
        properties: {
          location: {
            type: 'string',
            description: 'The locality or area to search for housing'
          }
        },
        required: ['location']
      }
    }
  },
  {
    type: 'function',
    function: {
      name: 'get_housing_stats',
      description: 'Get statistics about housing listings (total count, distribution by locality)',
      parameters: {
        type: 'object',
        properties: {}
      }
    }
  },
  {
    type: 'function',
    function: {
      name: 'get_stock_price',
      description: 'Get current stock price and details',
      parameters: {
        type: 'object',
        properties: {
          symbol: {
            type: 'string',
            description: 'Stock symbol (e.g., RELIANCE, TCS, INFY)'
          }
        },
        required: ['symbol']
      }
    }
  },
  {
    type: 'function',
    function: {
      name: 'get_currency_rate',
      description: 'Get exchange rate between two currencies',
      parameters: {
        type: 'object',
        properties: {
          from: {
            type: 'string',
            description: 'From currency code (e.g., USD, EUR)'
          },
          to: {
            type: 'string',
            description: 'To currency code (e.g., INR, USD)'
          }
        },
        required: ['from', 'to']
      }
    }
  },
  {
    type: 'function',
    function: {
      name: 'get_commodity_price',
      description: 'Get price of commodities like gold, silver, oil',
      parameters: {
        type: 'object',
        properties: {
          commodity: {
            type: 'string',
            description: 'Commodity name (GOLD, SILVER, CRUDE_OIL, OIL)',
            enum: ['GOLD', 'SILVER', 'CRUDE_OIL', 'OIL']
          }
        },
        required: ['commodity']
      }
    }
  }
];

// Execute function calls
async function executeFunctionCall(functionName, args) {
  switch (functionName) {
    case 'get_user_by_name':
      return await getUserByName(args.name);
    case 'get_users_by_location':
      return await getUsersByLocation(args.location);
    case 'get_housing_in_location':
      return await getHousingInLocation(args.location);
    case 'get_housing_stats':
      return await getHousingStats();
    case 'get_stock_price':
      return await getStockPrice(args.symbol);
    case 'get_currency_rate':
      return await getCurrencyRate(args.from, args.to);
    case 'get_commodity_price':
      return await getCommodityPrice(args.commodity);
    default:
      return { error: 'Unknown function' };
  }
}

// POST /api/chatbot/chat - Chat with AI assistant (authenticated)
router.post('/chat', authenticateToken, async (req, res) => {
  try {
    const { message, conversationHistory } = req.body;

    if (!message) {
      return res.status(400).json({ error: 'Message required' });
    }

    // Get current user profile for context
    const userProfile = await prisma.profile.findUnique({
      where: { userId: req.user.id }
    });

    // Build messages array
    const messages = [
      {
        role: 'system',
        content: `You are Zaryah AI, a helpful assistant for the Zaryah platform - a social and services platform.

You have access to:
- User profiles (name, location, bio)
- Housing listings (locations, prices, details)
- Real-time finance data (stocks, currencies, commodities)

Current user context:
- Name: ${userProfile?.name || 'User'}
- Location: ${userProfile?.city || 'Not set'}, ${userProfile?.country || 'Not set'}

Be helpful, conversational, and use the available functions to answer questions about:
- Users and their locations ("Who lives in India?", "Where is John located?")
- Housing ("Show me houses in Chennai", "How many listings are there?")
- Finance ("What's the USD to INR rate?", "Price of Reliance stock?", "Gold prices?")

Always provide specific data when available and format responses clearly.`
      }
    ];

    // Add conversation history if provided
    if (conversationHistory && Array.isArray(conversationHistory)) {
      messages.push(...conversationHistory);
    }

    // Add current message
    messages.push({
      role: 'user',
      content: message
    });

    // First API call to GPT-4
    let response = await openai.chat.completions.create({
      model: 'gpt-4-turbo-preview',
      messages: messages,
      tools: tools,
      tool_choice: 'auto',
      temperature: 0.7,
      max_tokens: 1000
    });

    let responseMessage = response.choices[0].message;

    // Handle function calls
    let functionCallResults = [];
    while (responseMessage.tool_calls) {
      messages.push(responseMessage);

      // Execute all function calls
      for (const toolCall of responseMessage.tool_calls) {
        const functionName = toolCall.function.name;
        const functionArgs = JSON.parse(toolCall.function.arguments);

        console.log(`Executing function: ${functionName} with args:`, functionArgs);

        const functionResult = await executeFunctionCall(functionName, functionArgs);

        functionCallResults.push({
          name: functionName,
          result: functionResult
        });

        messages.push({
          role: 'tool',
          tool_call_id: toolCall.id,
          content: JSON.stringify(functionResult)
        });
      }

      // Get next response with function results
      response = await openai.chat.completions.create({
        model: 'gpt-4-turbo-preview',
        messages: messages,
        tools: tools,
        tool_choice: 'auto',
        temperature: 0.7,
        max_tokens: 1000
      });

      responseMessage = response.choices[0].message;
    }

    res.json({
      message: responseMessage.content,
      functionCalls: functionCallResults,
      conversationHistory: messages
    });

  } catch (error) {
    console.error('Error in chatbot:', error);
    res.status(500).json({
      error: 'Failed to process chat',
      details: error.message
    });
  }
});

// POST /api/chatbot/quick-query - Quick query without conversation history
router.post('/quick-query', authenticateToken, async (req, res) => {
  try {
    const { query } = req.body;

    if (!query) {
      return res.status(400).json({ error: 'Query required' });
    }

    // Determine query type and execute directly
    const lowerQuery = query.toLowerCase();

    let result = null;

    // Housing queries
    if (lowerQuery.includes('house') || lowerQuery.includes('housing') || lowerQuery.includes('listing')) {
      if (lowerQuery.includes('how many') || lowerQuery.includes('count') || lowerQuery.includes('stats')) {
        result = await getHousingStats();
      } else {
        // Extract location from query
        const locationMatch = lowerQuery.match(/in ([a-z\s]+)/i);
        if (locationMatch) {
          result = await getHousingInLocation(locationMatch[1]);
        }
      }
    }

    // User location queries
    if (lowerQuery.includes('who lives') || lowerQuery.includes('users in')) {
      const locationMatch = lowerQuery.match(/in ([a-z\s]+)/i);
      if (locationMatch) {
        result = await getUsersByLocation(locationMatch[1]);
      }
    }

    // Finance queries
    if (lowerQuery.includes('price') || lowerQuery.includes('stock') || lowerQuery.includes('rate')) {
      if (lowerQuery.includes('gold')) {
        result = await getCommodityPrice('GOLD');
      } else if (lowerQuery.includes('silver')) {
        result = await getCommodityPrice('SILVER');
      } else if (lowerQuery.includes('oil')) {
        result = await getCommodityPrice('OIL');
      } else if (lowerQuery.includes('usd') && lowerQuery.includes('inr')) {
        result = await getCurrencyRate('USD', 'INR');
      }
    }

    res.json({ result });

  } catch (error) {
    console.error('Error in quick query:', error);
    res.status(500).json({ error: 'Failed to process query' });
  }
});

module.exports = router;

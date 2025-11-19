const express = require('express');
const router = express.Router();
const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

// Yahoo Finance Helper for FREE Indian stock data
const {
  getIndianStockQuote,
  getCurrencyRate,
  getCommodityPrice
} = require('../yahooFinanceHelper');

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

// Note: Stock quote, currency, and commodity functions are imported from yahooFinanceHelper.js
// No local function definitions needed - using Yahoo Finance API (free, accurate Indian stocks)

// ============================================================
// API ROUTES
// ============================================================

/**
 * GET /api/finance/quote/:symbol
 * Get stock quote for a symbol (NSE, BSE, US markets)
 * Example: /api/finance/quote/RELIANCE, /api/finance/quote/AAPL
 */
router.get('/quote/:symbol', authenticateToken, async (req, res) => {
  try {
    const { symbol } = req.params;

    if (!symbol) {
      return res.status(400).json({ error: 'Symbol required' });
    }

    const quote = await getIndianStockQuote(symbol);

    if (!quote) {
      return res.status(404).json({
        error: 'Stock data not found',
        symbol,
        message: 'Unable to fetch stock data. Please verify the symbol is correct.',
      });
    }

    res.json({ quote });
  } catch (error) {
    console.error('Error in /quote/:symbol:', error);
    res.status(500).json({
      error: 'Failed to fetch stock quote',
      details: error.message,
    });
  }
});

/**
 * GET /api/finance/index/:symbol
 * Get index data (NIFTY, SENSEX, etc.)
 * Example: /api/finance/index/NIFTY50, /api/finance/index/BSE500
 */
router.get('/index/:symbol', authenticateToken, async (req, res) => {
  try {
    const { symbol } = req.params;

    const quote = await getIndianStockQuote(symbol);

    if (!quote) {
      return res.status(404).json({
        error: 'Index data not found',
        symbol,
      });
    }

    res.json({ index: quote });
  } catch (error) {
    console.error('Error in /index/:symbol:', error);
    res.status(500).json({
      error: 'Failed to fetch index data',
      details: error.message,
    });
  }
});

/**
 * GET /api/finance/currency/:pair
 * Get currency exchange rate
 * Example: /api/finance/currency/USD-INR
 */
router.get('/currency/:pair', authenticateToken, async (req, res) => {
  try {
    const { pair } = req.params;
    const [from, to] = pair.split('-');

    if (!from || !to) {
      return res.status(400).json({
        error: 'Invalid currency pair format',
        format: 'Use format: USD-INR',
      });
    }

    const rate = await getCurrencyRate(from, to);

    if (!rate) {
      return res.status(404).json({
        error: 'Currency rate not found',
        pair,
      });
    }

    res.json({ currency: rate });
  } catch (error) {
    console.error('Error in /currency/:pair:', error);
    res.status(500).json({
      error: 'Failed to fetch currency rate',
      details: error.message,
    });
  }
});

/**
 * GET /api/finance/commodity/:item
 * Get commodity price (GOLD, SILVER, CRUDE_OIL)
 * Example: /api/finance/commodity/GOLD
 */
router.get('/commodity/:item', authenticateToken, async (req, res) => {
  try {
    const { item } = req.params;

    const price = await getCommodityPrice(item);

    if (!price) {
      return res.status(404).json({
        error: 'Commodity data not found',
        item,
      });
    }

    res.json({ commodity: price });
  } catch (error) {
    console.error('Error in /commodity/:item:', error);
    res.status(500).json({
      error: 'Failed to fetch commodity price',
      details: error.message,
    });
  }
});

/**
 * GET /api/finance/timeseries/:symbol
 * Get time series data for a symbol
 * NOTE: Temporarily disabled - Yahoo Finance helper doesn't implement time series yet
 * Query params: interval (1min, 5min, 15min, 30min, 1h, 1day, 1week, 1month)
 */
// router.get('/timeseries/:symbol', authenticateToken, async (req, res) => {
//   try {
//     const { symbol } = req.params;
//     const { interval = '1day' } = req.query;

//     const series = await getTimeSeries(symbol, interval);

//     if (!series) {
//       return res.status(404).json({
//         error: 'Time series data not found',
//         symbol,
//       });
//     }

//     res.json({ timeSeries: series });
//   } catch (error) {
//     console.error('Error in /timeseries/:symbol:', error);
//     res.status(500).json({
//       error: 'Failed to fetch time series',
//       details: error.message,
//     });
//   }
// });

/**
 * GET /api/finance/news
 * Get latest financial news (placeholder - requires separate API)
 */
router.get('/news', authenticateToken, async (req, res) => {
  try {
    // This would require a news API like NewsAPI, Alpha Vantage News, or similar
    // For now, return a placeholder
    const news = [
      {
        title: 'Market Update: NSE Nifty 50',
        description: 'Latest updates from Indian stock markets',
        source: 'Market Watch',
        timestamp: new Date().toISOString(),
      },
    ];

    res.json({ news });
  } catch (error) {
    console.error('Error in /news:', error);
    res.status(500).json({
      error: 'Failed to fetch news',
      details: error.message,
    });
  }
});

/**
 * POST /api/finance/watchlist
 * Add stock to user's watchlist
 */
router.post('/watchlist', authenticateToken, async (req, res) => {
  try {
    const userId = req.user.userId;
    const { symbol } = req.body;

    if (!symbol) {
      return res.status(400).json({ error: 'Symbol required' });
    }

    // Verify symbol exists
    const quote = await getIndianStockQuote(symbol);
    if (!quote) {
      return res.status(404).json({ error: 'Invalid symbol' });
    }

    // This would require a Watchlist model in Prisma schema
    // For now, return success message
    res.json({
      message: 'Stock added to watchlist',
      symbol,
    });
  } catch (error) {
    console.error('Error adding to watchlist:', error);
    res.status(500).json({
      error: 'Failed to add to watchlist',
      details: error.message,
    });
  }
});

/**
 * GET /api/finance/dashboard
 * Get user's finance dashboard with key indices and watchlist
 * Uses proper TwelveData symbol formatting (e.g., RELIANCE.NSE, TCS.NSE)
 */
router.get('/dashboard', authenticateToken, async (req, res) => {
  try {
    console.log('📊 Fetching Indian stock market dashboard...');

    // Fetch Indian market indices (Yahoo Finance free)
    const indices = await Promise.all([
      getIndianStockQuote('^NSEI'),   // NIFTY 50
      getIndianStockQuote('^BSESN'),  // SENSEX
    ]);

    // Fetch popular Indian stocks (Yahoo Finance free - like Zerodha)
    const popularStocks = await Promise.all([
      getIndianStockQuote('RELIANCE.NS'),  // Reliance Industries
      getIndianStockQuote('TCS.NS'),       // Tata Consultancy Services
      getIndianStockQuote('INFY.NS'),      // Infosys
      getIndianStockQuote('HDFCBANK.NS'),  // HDFC Bank
      getIndianStockQuote('ITC.NS'),       // ITC Limited
    ]);

    // Fetch currency rates (Yahoo Finance free)
    const currencies = await Promise.all([
      getCurrencyRate('USD', 'INR'),  // US Dollar to INR
      getCurrencyRate('EUR', 'INR'),  // Euro to INR
      getCurrencyRate('GBP', 'INR'),  // British Pound to INR
    ]);

    // Fetch commodity prices (Yahoo Finance free)
    const commodities = await Promise.all([
      getCommodityPrice('GOLD'),       // Gold
      getCommodityPrice('SILVER'),     // Silver
      getCommodityPrice('CRUDE_OIL'),  // Crude Oil
    ]);

    console.log('✅ Dashboard data fetched successfully');

    res.json({
      indices: indices.filter(Boolean),
      popularStocks: popularStocks.filter(Boolean),
      currencies: currencies.filter(Boolean),
      commodities: commodities.filter(Boolean),
      timestamp: new Date().toISOString(),
      message: 'Dashboard data fetched successfully',
    });
  } catch (error) {
    console.error('❌ Error fetching dashboard:', error);
    res.status(500).json({
      error: 'Failed to fetch finance dashboard',
      details: error.message,
    });
  }
});

module.exports = router;

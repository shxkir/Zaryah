// Yahoo Finance Helper for Indian Stocks (Free API)
const YahooFinanceClass = require('yahoo-finance2').default;
const yahooFinance = new YahooFinanceClass({
  suppressNotices: ['yahooSurvey']
});

/**
 * Get Indian stock quote from Yahoo Finance
 * Symbols: RELIANCE.NS, TCS.NS, INFY.NS, etc.
 * Indices: ^NSEI (NIFTY), ^BSESN (SENSEX)
 */
async function getIndianStockQuote(symbol) {
  try {
    console.log(`📊 Fetching quote for: ${symbol}`);

    const quote = await yahooFinance.quote(symbol);

    if (!quote) {
      console.warn(`⚠️ No data returned for ${symbol}`);
      return null;
    }

    const result = {
      symbol: quote.symbol,
      name: quote.longName || quote.shortName || symbol,
      price: quote.regularMarketPrice || 0,
      open: quote.regularMarketOpen || 0,
      high: quote.regularMarketDayHigh || 0,
      low: quote.regularMarketDayLow || 0,
      previousClose: quote.regularMarketPreviousClose || 0,
      change: quote.regularMarketChange || 0,
      changePercent: quote.regularMarketChangePercent || 0,
      volume: quote.regularMarketVolume || 0,
      fiftyTwoWeekHigh: quote.fiftyTwoWeekHigh || 0,
      fiftyTwoWeekLow: quote.fiftyTwoWeekLow || 0,
      timestamp: quote.regularMarketTime ? new Date(quote.regularMarketTime * 1000).toISOString() : new Date().toISOString(),
      exchange: quote.exchange || 'NSE',
      currency: quote.currency || 'INR',
    };

    console.log(`✅ Quote fetched successfully for ${symbol}: ₹${result.price}`);
    return result;
  } catch (error) {
    console.error(`❌ Error fetching stock quote for ${symbol}:`, error.message);
    return null;
  }
}

/**
 * Get currency exchange rate
 */
async function getCurrencyRate(from, to) {
  try {
    const pair = `${from}${to}=X`;  // Yahoo Finance format: USDINR=X
    console.log(`💱 Fetching currency rate for: ${from}/${to}`);

    const quote = await yahooFinance.quote(pair);

    if (!quote) {
      return null;
    }

    const result = {
      from,
      to,
      rate: quote.regularMarketPrice || 0,
      change: quote.regularMarketChange || 0,
      changePercent: quote.regularMarketChangePercent || 0,
      timestamp: quote.regularMarketTime ? new Date(quote.regularMarketTime * 1000).toISOString() : new Date().toISOString(),
    };

    console.log(`✅ Currency rate fetched: ${from}/${to} = ${result.rate}`);
    return result;
  } catch (error) {
    console.error(`❌ Error fetching currency rate ${from}/${to}:`, error.message);
    return null;
  }
}

/**
 * Get commodity price (Gold, Silver, Crude Oil)
 */
async function getCommodityPrice(commodity) {
  try {
    // Yahoo Finance symbols for commodities
    const commoditySymbols = {
      'GOLD': 'GC=F',        // Gold Futures
      'SILVER': 'SI=F',      // Silver Futures
      'CRUDE_OIL': 'CL=F',   // Crude Oil Futures
    };

    const symbol = commoditySymbols[commodity.toUpperCase()] || commodity;
    console.log(`🥇 Fetching commodity price for: ${commodity} (${symbol})`);

    const quote = await yahooFinance.quote(symbol);

    if (!quote) {
      return null;
    }

    const result = {
      commodity: commodity.toUpperCase(),
      symbol: quote.symbol,
      price: quote.regularMarketPrice || 0,
      currency: quote.currency || 'USD',
      change: quote.regularMarketChange || 0,
      changePercent: quote.regularMarketChangePercent || 0,
      timestamp: quote.regularMarketTime ? new Date(quote.regularMarketTime * 1000).toISOString() : new Date().toISOString(),
    };

    console.log(`✅ Commodity price fetched for ${commodity}: $${result.price}`);
    return result;
  } catch (error) {
    console.error(`❌ Error fetching commodity price for ${commodity}:`, error.message);
    return null;
  }
}

module.exports = {
  getIndianStockQuote,
  getCurrencyRate,
  getCommodityPrice,
};

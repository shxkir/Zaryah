import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;
import '../models/finance_models.dart';
import 'api_service.dart';

class FinanceService {
  // Platform-aware base URL
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:3000/api/finance';
    } else if (Platform.isAndroid) {
      return 'http://10.0.2.2:3000/api/finance';
    } else {
      return 'http://127.0.0.1:3000/api/finance';
    }
  }

  // Get auth token from ApiService
  static Future<String?> _getAuthToken() async {
    final apiService = ApiService();
    return await apiService.getToken();
  }

  static Future<Map<String, String>> _getHeaders({bool requiresAuth = false}) async {
    final headers = {
      'Content-Type': 'application/json',
    };

    if (requiresAuth) {
      final token = await _getAuthToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    return headers;
  }

  // GET /api/finance/quote/:symbol - Get stock quote
  // IMPORTANT: For Indian stocks, append .NSE or .BSE (e.g., RELIANCE.NSE, TCS.NSE)
  static Future<StockQuote> getStockQuote(String symbol) async {
    try {
      // Ensure authentication
      final headers = await _getHeaders(requiresAuth: true);

      print('📊 Fetching quote for: $symbol');

      final response = await http.get(
        Uri.parse('$baseUrl/quote/$symbol'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('✅ Quote fetched successfully for $symbol');
        return StockQuote.fromJson(data['quote']);
      } else {
        final errorData = json.decode(response.body);
        final errorMsg = errorData['error'] ?? 'Stock not found';
        print('❌ Stock quote error: $errorMsg');
        throw Exception(errorMsg);
      }
    } catch (e) {
      print('❌ Error fetching stock quote: $e');
      throw Exception('Failed to fetch stock: $e');
    }
  }

  // GET /api/finance/currency/:pair - Get currency rate
  // Format: USD-INR (with hyphen separator)
  static Future<CurrencyRate> getCurrencyRate(String from, String to) async {
    try {
      final pair = '$from-$to';  // Use hyphen separator as per backend
      final headers = await _getHeaders(requiresAuth: true);

      print('💱 Fetching currency rate for: $pair');

      final response = await http.get(
        Uri.parse('$baseUrl/currency/$pair'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('✅ Currency rate fetched successfully for $pair');
        return CurrencyRate.fromJson(data['currency']);
      } else {
        final errorData = json.decode(response.body);
        final errorMsg = errorData['error'] ?? 'Currency pair not found';
        print('❌ Currency error: $errorMsg');
        throw Exception(errorMsg);
      }
    } catch (e) {
      print('❌ Error fetching currency rate: $e');
      throw Exception('Failed to fetch currency: $e');
    }
  }

  // GET /api/finance/commodity/:name - Get commodity price
  static Future<CommodityPrice> getCommodityPrice(String commodity) async {
    try {
      final headers = await _getHeaders(requiresAuth: true);

      print('🥇 Fetching commodity price for: $commodity');

      final response = await http.get(
        Uri.parse('$baseUrl/commodity/$commodity'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final priceData = data['commodity'];
        // Add commodity name to the response if not present
        priceData['commodity'] = commodity;
        print('✅ Commodity price fetched successfully for $commodity');
        return CommodityPrice.fromJson(priceData);
      } else {
        final errorData = json.decode(response.body);
        final errorMsg = errorData['error'] ?? 'Commodity not found';
        print('❌ Commodity error: $errorMsg');
        throw Exception(errorMsg);
      }
    } catch (e) {
      print('❌ Error fetching commodity price: $e');
      throw Exception('Failed to fetch commodity: $e');
    }
  }

  // GET /api/finance/search/:query - Search stocks
  static Future<List<SearchResult>> searchSymbols(String query) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/search/$query'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> resultsJson = data['results'] ?? [];
        return resultsJson.map((json) => SearchResult.fromJson(json)).toList();
      } else {
        throw Exception('Search failed: ${response.statusCode}');
      }
    } catch (e) {
      print('Error searching symbols: $e');
      return [];
    }
  }

  // GET /api/finance/watchlist - Get user's watchlist
  static Future<List<WatchlistItem>> getWatchlist() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/watchlist'),
        headers: await _getHeaders(requiresAuth: true),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> watchlistJson = data['watchlist'] ?? [];
        return watchlistJson.map((json) => WatchlistItem.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load watchlist: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching watchlist: $e');
      return [];
    }
  }

  // POST /api/finance/watchlist - Add to watchlist
  static Future<WatchlistItem> addToWatchlist({
    required String symbol,
    required String assetType,
    String? exchange,
  }) async {
    try {
      final body = {
        'symbol': symbol,
        'assetType': assetType,
        if (exchange != null) 'exchange': exchange,
      };

      final response = await http.post(
        Uri.parse('$baseUrl/watchlist'),
        headers: await _getHeaders(requiresAuth: true),
        body: json.encode(body),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        return WatchlistItem.fromJson(data['item']);
      } else {
        throw Exception('Failed to add to watchlist: ${response.body}');
      }
    } catch (e) {
      print('Error adding to watchlist: $e');
      throw Exception('Failed to add to watchlist: $e');
    }
  }

  // DELETE /api/finance/watchlist/:id - Remove from watchlist
  static Future<void> removeFromWatchlist(String id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/watchlist/$id'),
        headers: await _getHeaders(requiresAuth: true),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to remove from watchlist: ${response.body}');
      }
    } catch (e) {
      print('Error removing from watchlist: $e');
      throw Exception('Failed to remove from watchlist: $e');
    }
  }

  // GET /api/finance/trending - Get trending stocks
  static Future<List<StockQuote>> getTrendingStocks() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/trending'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> trendingJson = data['trending'] ?? [];
        return trendingJson.map((json) => StockQuote.fromJson(json)).toList();
      } else {
        return [];
      }
    } catch (e) {
      print('Error fetching trending stocks: $e');
      return [];
    }
  }

  // GET /api/finance/dashboard - Get finance dashboard with indices, stocks, currencies, commodities
  static Future<Map<String, dynamic>?> getFinanceDashboard() async {
    try {
      final headers = await _getHeaders(requiresAuth: true);

      print('📊 Fetching finance dashboard...');

      final response = await http.get(
        Uri.parse('$baseUrl/dashboard'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('✅ Finance dashboard fetched successfully');
        return data;
      } else {
        print('❌ Dashboard failed with status: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('❌ Error fetching dashboard: $e');
      return null;
    }
  }

  // GET /api/finance/market-overview - Get complete market overview
  static Future<MarketOverview?> getMarketOverview() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/market-overview'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return MarketOverview.fromJson(data);
      } else {
        print('Market overview failed with status: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error fetching market overview: $e');
      return null;
    }
  }

  // GET /api/finance/indices - Get major Indian market indices
  static Future<List<MarketIndex>> getIndices() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/indices'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> indicesJson = data['indices'] ?? [];
        return indicesJson.map((json) => MarketIndex.fromJson(json)).toList();
      } else {
        return [];
      }
    } catch (e) {
      print('Error fetching indices: $e');
      return [];
    }
  }

  // Popular currency pairs
  static List<Map<String, String>> getPopularCurrencyPairs() {
    return [
      {'from': 'USD', 'to': 'INR', 'name': 'US Dollar to Indian Rupee'},
      {'from': 'EUR', 'to': 'INR', 'name': 'Euro to Indian Rupee'},
      {'from': 'GBP', 'to': 'INR', 'name': 'British Pound to Indian Rupee'},
      {'from': 'AED', 'to': 'INR', 'name': 'UAE Dirham to Indian Rupee'},
      {'from': 'SGD', 'to': 'INR', 'name': 'Singapore Dollar to Indian Rupee'},
    ];
  }

  // Popular commodities
  static List<String> getPopularCommodities() {
    return ['GOLD', 'SILVER', 'CRUDE_OIL'];
  }

  // Popular US stocks (TwelveData free tier)
  // Note: Indian stocks require paid tier
  static List<Map<String, String>> getPopularStocks() {
    return [
      {'symbol': 'AAPL', 'name': 'Apple Inc.'},
      {'symbol': 'MSFT', 'name': 'Microsoft Corporation'},
      {'symbol': 'GOOGL', 'name': 'Alphabet Inc. (Google)'},
      {'symbol': 'AMZN', 'name': 'Amazon.com Inc.'},
      {'symbol': 'TSLA', 'name': 'Tesla Inc.'},
      {'symbol': 'META', 'name': 'Meta Platforms Inc.'},
      {'symbol': 'NVDA', 'name': 'NVIDIA Corporation'},
      {'symbol': 'JPM', 'name': 'JPMorgan Chase & Co.'},
      {'symbol': 'V', 'name': 'Visa Inc.'},
      {'symbol': 'WMT', 'name': 'Walmart Inc.'},
    ];
  }
}

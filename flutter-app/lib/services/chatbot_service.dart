import 'dart:convert';
import 'package:http/http.dart' as http;

class ChatbotService {
  static const String baseUrl = 'http://localhost:3000/api/chatbot';

  // Get auth token from storage
  static Future<String?> _getAuthToken() async {
    // TODO: Get token from shared preferences or secure storage
    return null;
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

  // POST /api/chatbot/chat - Main chat endpoint with function calling
  static Future<ChatResponse> chat({
    required String message,
    List<Map<String, dynamic>>? conversationHistory,
  }) async {
    try {
      final body = {
        'message': message,
        if (conversationHistory != null) 'conversationHistory': conversationHistory,
      };

      final response = await http.post(
        Uri.parse('$baseUrl/chat'),
        headers: await _getHeaders(requiresAuth: true),
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return ChatResponse.fromJson(data);
      } else {
        throw Exception('Chat failed: ${response.body}');
      }
    } catch (e) {
      print('Error in chat: $e');
      throw Exception('Failed to get response: $e');
    }
  }

  // POST /api/chatbot/quick-query - Quick queries without conversation context
  static Future<dynamic> quickQuery(String query) async {
    try {
      final body = {'query': query};

      final response = await http.post(
        Uri.parse('$baseUrl/quick-query'),
        headers: await _getHeaders(requiresAuth: true),
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['result'];
      } else {
        throw Exception('Query failed: ${response.body}');
      }
    } catch (e) {
      print('Error in quick query: $e');
      return null;
    }
  }
}

class ChatResponse {
  final String message;
  final List<FunctionCallResult>? functionCalls;
  final List<Map<String, dynamic>>? conversationHistory;

  ChatResponse({
    required this.message,
    this.functionCalls,
    this.conversationHistory,
  });

  factory ChatResponse.fromJson(Map<String, dynamic> json) {
    List<FunctionCallResult>? calls;
    if (json['functionCalls'] != null) {
      calls = (json['functionCalls'] as List)
          .map((call) => FunctionCallResult.fromJson(call))
          .toList();
    }

    List<Map<String, dynamic>>? history;
    if (json['conversationHistory'] != null) {
      history = (json['conversationHistory'] as List)
          .map((msg) => msg as Map<String, dynamic>)
          .toList();
    }

    return ChatResponse(
      message: json['message'] as String,
      functionCalls: calls,
      conversationHistory: history,
    );
  }

  bool get hasFunctionCalls =>
      functionCalls != null && functionCalls!.isNotEmpty;

  String getFunctionCallsSummary() {
    if (!hasFunctionCalls) return '';

    final names = functionCalls!.map((call) => call.name).toSet();
    return 'Searched: ${names.join(', ')}';
  }
}

class FunctionCallResult {
  final String name;
  final dynamic result;

  FunctionCallResult({
    required this.name,
    required this.result,
  });

  factory FunctionCallResult.fromJson(Map<String, dynamic> json) {
    return FunctionCallResult(
      name: json['name'] as String,
      result: json['result'],
    );
  }

  String get displayName {
    switch (name) {
      case 'get_user_by_name':
        return 'User Search';
      case 'get_users_by_location':
        return 'Location Search';
      case 'get_housing_in_location':
        return 'Housing Search';
      case 'get_housing_stats':
        return 'Housing Stats';
      case 'get_stock_price':
        return 'Stock Quote';
      case 'get_currency_rate':
        return 'Currency Rate';
      case 'get_commodity_price':
        return 'Commodity Price';
      default:
        return name;
    }
  }

  int get resultCount {
    if (result is List) return (result as List).length;
    if (result is Map) return 1;
    return 0;
  }
}

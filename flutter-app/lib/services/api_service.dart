import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String _envBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: '',
  );

  static final String baseUrl = _normalizeBaseUrl(
    _envBaseUrl.isNotEmpty ? _envBaseUrl : _resolveBaseUrl(),
  );

  static const Duration _requestTimeout = Duration(seconds: 15);

  static String _resolveBaseUrl() {
    if (kIsWeb) {
      return 'http://localhost:3000/api';
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 'http://192.168.1.15:3000/api';
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        return 'http://192.168.1.15:3000/api';
      case TargetPlatform.windows:
      case TargetPlatform.linux:
      case TargetPlatform.fuchsia:
        return 'http://192.168.1.15:3000/api';
    }

    return 'http://localhost:3000/api';
  }

  static String _normalizeBaseUrl(String url) {
    if (url.isEmpty) return url;

    String normalized = url.trim().replaceAll(RegExp(r'/+$'), '');

    final uri = Uri.tryParse(normalized);
    final pathSegments = uri?.pathSegments ?? const [];

    if (!pathSegments.contains('api')) {
      normalized = '$normalized/api';
    }

    return normalized;
  }

  Map<String, String> _jsonHeaders({String? token}) {
    final headers = <String, String>{'Content-Type': 'application/json'};
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  Future<http.Response> _safeHttpCall(
    Future<http.Response> Function() request,
    Uri uri,
  ) async {
    try {
      return await request().timeout(_requestTimeout);
    } on TimeoutException {
      throw Exception(
        'Request to ${uri.origin} timed out. Ensure the backend server is running and reachable.',
      );
    } on http.ClientException {
      throw Exception(
        'Unable to reach ${uri.origin}. Ensure the backend server is running or update API_BASE_URL.',
      );
    } catch (error) {
      final message = error.toString();
      if (message.contains('SocketException') ||
          message.contains('Failed host lookup') ||
          message.contains('Connection refused')) {
        throw Exception(
          'Unable to reach ${uri.origin}. Ensure the backend server is running or update API_BASE_URL.',
        );
      }
      rethrow;
    }
  }

  // Get stored JWT token
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }

  // Save JWT token
  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('jwt_token', token);
  }

  // Remove JWT token
  Future<void> removeToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token');
  }

  // Signup
  Future<Map<String, dynamic>> signup({
    required String email,
    required String password,
    required String name,
    required int age,
    required String educationLevel,
    required String occupation,
    required String learningGoals,
    required List<String> subjects,
    required String learningStyle,
    required String previousExperience,
    required String strengths,
    required String weaknesses,
    required String specificChallenges,
    required int availableHoursPerWeek,
    required String learningPace,
    required String motivationLevel,
  }) async {
    final uri = Uri.parse('$baseUrl/auth/signup');
    final response = await _safeHttpCall(
      () => http.post(
        uri,
        headers: _jsonHeaders(),
        body: jsonEncode({
        'email': email,
        'password': password,
        'name': name,
        'age': age,
        'educationLevel': educationLevel,
        'occupation': occupation,
        'learningGoals': learningGoals,
        'subjects': subjects,
        'learningStyle': learningStyle,
        'previousExperience': previousExperience,
        'strengths': strengths,
        'weaknesses': weaknesses,
        'specificChallenges': specificChallenges,
        'availableHoursPerWeek': availableHoursPerWeek,
        'learningPace': learningPace,
        'motivationLevel': motivationLevel,
      }),
      ),
      uri,
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      await saveToken(data['token']);
      return data;
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['error'] ?? 'Signup failed');
    }
  }

  // Login
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final uri = Uri.parse('$baseUrl/auth/login');
    final response = await _safeHttpCall(
      () => http.post(
        uri,
        headers: _jsonHeaders(),
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      ),
      uri,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      await saveToken(data['token']);
      return data;
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['error'] ?? 'Login failed');
    }
  }

  // Send chatbot query
  Future<Map<String, dynamic>> sendChatMessage(String query) async {
    final token = await getToken();
    if (token == null) throw Exception('Not authenticated');

    final uri = Uri.parse('$baseUrl/chatbot');
    final response = await _safeHttpCall(
      () => http.post(
        uri,
        headers: _jsonHeaders(token: token),
        body: jsonEncode({'query': query}),
      ),
      uri,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['error'] ?? 'Chat request failed');
    }
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null;
  }

  // Logout
  Future<void> logout() async {
    await removeToken();
  }

  // Get all users with optional country filter
  Future<List<Map<String, dynamic>>> getAllUsers({String? country}) async {
    final token = await getToken();
    if (token == null) throw Exception('Not authenticated');

    // Build URI with optional country query parameter
    final queryParams = <String, String>{};
    if (country != null && country.isNotEmpty && country != 'All Countries') {
      queryParams['country'] = country;
    }

    final uri = Uri.parse('$baseUrl/users').replace(queryParameters: queryParams.isEmpty ? null : queryParams);
    final response = await _safeHttpCall(
      () => http.get(
        uri,
        headers: _jsonHeaders(token: token),
      ),
      uri,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(data['users']);
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['error'] ?? 'Failed to fetch users');
    }
  }

  // Get users by country (convenience method)
  Future<List<Map<String, dynamic>>> getUsersByCountry(String country) async {
    return getAllUsers(country: country);
  }

  // Get user by ID
  Future<Map<String, dynamic>> getUserById(String userId) async {
    final token = await getToken();
    if (token == null) throw Exception('Not authenticated');

    final uri = Uri.parse('$baseUrl/users/$userId');
    final response = await _safeHttpCall(
      () => http.get(
        uri,
        headers: _jsonHeaders(token: token),
      ),
      uri,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['user'];
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['error'] ?? 'Failed to fetch user');
    }
  }

  // Send message
  Future<Map<String, dynamic>> sendMessage({
    required String receiverId,
    required String text,
  }) async {
    final token = await getToken();
    if (token == null) throw Exception('Not authenticated');

    final uri = Uri.parse('$baseUrl/messages/send');
    final response = await _safeHttpCall(
      () => http.post(
        uri,
        headers: _jsonHeaders(token: token),
        body: jsonEncode({
          'receiverId': receiverId,
          'text': text,
        }),
      ),
      uri,
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['error'] ?? 'Failed to send message');
    }
  }

  // Get conversations
  Future<List<Map<String, dynamic>>> getConversations() async {
    final token = await getToken();
    if (token == null) throw Exception('Not authenticated');

    final uri = Uri.parse('$baseUrl/messages/conversations');
    final response = await _safeHttpCall(
      () => http.get(
        uri,
        headers: _jsonHeaders(token: token),
      ),
      uri,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(data['conversations']);
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['error'] ?? 'Failed to fetch conversations');
    }
  }

  // Get messages with a user
  Future<List<Map<String, dynamic>>> getMessages(String partnerId) async {
    final token = await getToken();
    if (token == null) throw Exception('Not authenticated');

    final uri = Uri.parse('$baseUrl/messages/$partnerId');
    final response = await _safeHttpCall(
      () => http.get(
        uri,
        headers: _jsonHeaders(token: token),
      ),
      uri,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(data['messages']);
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['error'] ?? 'Failed to fetch messages');
    }
  }

  // Get current user's profile
  Future<Map<String, dynamic>> getCurrentProfile() async {
    final token = await getToken();
    if (token == null) throw Exception('Not authenticated');

    final uri = Uri.parse('$baseUrl/profile/me');
    final response = await _safeHttpCall(
      () => http.get(
        uri,
        headers: _jsonHeaders(token: token),
      ),
      uri,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['user'];
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['error'] ?? 'Failed to fetch profile');
    }
  }

  // Update current user's profile
  Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> profileData) async {
    final token = await getToken();
    if (token == null) throw Exception('Not authenticated');

    final uri = Uri.parse('$baseUrl/profile/me');
    final response = await _safeHttpCall(
      () => http.put(
        uri,
        headers: _jsonHeaders(token: token),
        body: jsonEncode(profileData),
      ),
      uri,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['user'];
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['error'] ?? 'Failed to update profile');
    }
  }

  // Get dashboard data
  Future<Map<String, dynamic>> getDashboardData() async {
    final token = await getToken();
    if (token == null) throw Exception('Not authenticated');

    final uri = Uri.parse('$baseUrl/dashboard');
    final response = await _safeHttpCall(
      () => http.get(
        uri,
        headers: _jsonHeaders(token: token),
      ),
      uri,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['error'] ?? 'Failed to fetch dashboard data');
    }
  }

  // Send connection request
  Future<void> sendConnectionRequest(String userId) async {
    final token = await getToken();
    if (token == null) throw Exception('Not authenticated');

    // Backend expects POST /api/connections with targetUserId
    final uri = Uri.parse('$baseUrl/connections');
    final response = await _safeHttpCall(
      () => http.post(
        uri,
        headers: _jsonHeaders(token: token),
        body: jsonEncode({
          'targetUserId': userId,
        }),
      ),
      uri,
    );

    if (response.statusCode != 201 && response.statusCode != 200) {
      final error = jsonDecode(response.body);
      throw Exception(error['error'] ?? 'Failed to send connection request');
    }
  }

  // Refresh current user data
  Future<Map<String, dynamic>> refreshCurrentUser() async {
    final token = await getToken();
    if (token == null) throw Exception('Not authenticated');

    final uri = Uri.parse('$baseUrl/users/profile');
    final response = await _safeHttpCall(
      () => http.get(
        uri,
        headers: _jsonHeaders(token: token),
      ),
      uri,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['user'] ?? data;
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['error'] ?? 'Failed to fetch user data');
    }
  }

  // Update user location
  Future<Map<String, dynamic>> updateLocation({
    required double latitude,
    required double longitude,
    String? city,
    String? country,
    String? locationPrivacy,
  }) async {
    final token = await getToken();
    if (token == null) throw Exception('Not authenticated');

    final uri = Uri.parse('$baseUrl/profile/location');
    final response = await _safeHttpCall(
      () => http.put(
        uri,
        headers: _jsonHeaders(token: token),
        body: jsonEncode({
          'latitude': latitude,
          'longitude': longitude,
          if (city != null) 'city': city,
          if (country != null) 'country': country,
          if (locationPrivacy != null) 'locationPrivacy': locationPrivacy,
        }),
      ),
      uri,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['user'];
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['error'] ?? 'Failed to update location');
    }
  }

  // Get users with locations for map
  Future<List<Map<String, dynamic>>> getMapUsers() async {
    final token = await getToken();
    if (token == null) throw Exception('Not authenticated');

    final uri = Uri.parse('$baseUrl/users/map');
    final response = await _safeHttpCall(
      () => http.get(
        uri,
        headers: _jsonHeaders(token: token),
      ),
      uri,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(data['users']);
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['error'] ?? 'Failed to fetch map users');
    }
  }

  // Create a new post
  Future<Map<String, dynamic>> createPost({
    required String imageUrl,
    String? caption,
    double? latitude,
    double? longitude,
    String? city,
    String? country,
    String? privacy,
  }) async {
    final token = await getToken();
    if (token == null) throw Exception('Not authenticated');

    final uri = Uri.parse('$baseUrl/posts');
    final response = await _safeHttpCall(
      () => http.post(
        uri,
        headers: _jsonHeaders(token: token),
        body: jsonEncode({
          'imageUrl': imageUrl,
          if (caption != null) 'caption': caption,
          if (latitude != null) 'latitude': latitude,
          if (longitude != null) 'longitude': longitude,
          if (city != null) 'city': city,
          if (country != null) 'country': country,
          if (privacy != null) 'privacy': privacy,
        }),
      ),
      uri,
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['error'] ?? 'Failed to create post');
    }
  }

  // Get all posts
  Future<List<Map<String, dynamic>>> getPosts({String? country}) async {
    final token = await getToken();
    if (token == null) throw Exception('Not authenticated');

    var url = '$baseUrl/posts';
    if (country != null) {
      url += '?country=$country';
    }

    final uri = Uri.parse(url);
    final response = await _safeHttpCall(
      () => http.get(
        uri,
        headers: _jsonHeaders(token: token),
      ),
      uri,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(data['posts']);
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['error'] ?? 'Failed to fetch posts');
    }
  }

  // Get posts with location for map
  Future<List<Map<String, dynamic>>> getMapPosts() async {
    final token = await getToken();
    if (token == null) throw Exception('Not authenticated');

    final uri = Uri.parse('$baseUrl/posts/map');
    final response = await _safeHttpCall(
      () => http.get(
        uri,
        headers: _jsonHeaders(token: token),
      ),
      uri,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(data['posts']);
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['error'] ?? 'Failed to fetch map posts');
    }
  }

  // Get single post
  Future<Map<String, dynamic>> getPost(String postId) async {
    final token = await getToken();
    if (token == null) throw Exception('Not authenticated');

    final uri = Uri.parse('$baseUrl/posts/$postId');
    final response = await _safeHttpCall(
      () => http.get(
        uri,
        headers: _jsonHeaders(token: token),
      ),
      uri,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['post'];
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['error'] ?? 'Failed to fetch post');
    }
  }

  // Delete a post
  Future<void> deletePost(String postId) async {
    final token = await getToken();
    if (token == null) throw Exception('Not authenticated');

    final uri = Uri.parse('$baseUrl/posts/$postId');
    final response = await _safeHttpCall(
      () => http.delete(
        uri,
        headers: _jsonHeaders(token: token),
      ),
      uri,
    );

    if (response.statusCode != 200) {
      final error = jsonDecode(response.body);
      throw Exception(error['error'] ?? 'Failed to delete post');
    }
  }
}

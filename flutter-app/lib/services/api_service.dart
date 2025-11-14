import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:3000/api';

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
    final response = await http.post(
      Uri.parse('$baseUrl/auth/signup'),
      headers: {'Content-Type': 'application/json'},
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
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
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

    final response = await http.post(
      Uri.parse('$baseUrl/chatbot'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'query': query}),
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

  // Get all users
  Future<List<Map<String, dynamic>>> getAllUsers() async {
    final token = await getToken();
    if (token == null) throw Exception('Not authenticated');

    final response = await http.get(
      Uri.parse('$baseUrl/users'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(data['users']);
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['error'] ?? 'Failed to fetch users');
    }
  }

  // Get user by ID
  Future<Map<String, dynamic>> getUserById(String userId) async {
    final token = await getToken();
    if (token == null) throw Exception('Not authenticated');

    final response = await http.get(
      Uri.parse('$baseUrl/users/$userId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
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

    final response = await http.post(
      Uri.parse('$baseUrl/messages/send'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'receiverId': receiverId,
        'text': text,
      }),
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

    final response = await http.get(
      Uri.parse('$baseUrl/messages/conversations'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
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

    final response = await http.get(
      Uri.parse('$baseUrl/messages/$partnerId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
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

    final response = await http.get(
      Uri.parse('$baseUrl/profile/me'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
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

    final response = await http.put(
      Uri.parse('$baseUrl/profile/me'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(profileData),
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

    final response = await http.get(
      Uri.parse('$baseUrl/dashboard'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['error'] ?? 'Failed to fetch dashboard data');
    }
  }
}

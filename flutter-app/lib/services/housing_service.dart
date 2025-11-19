import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;
import '../models/housing_model.dart';
import 'api_service.dart';

class HousingService {
  // Platform-aware base URL
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:3000/api/housing';
    } else if (Platform.isAndroid) {
      return 'http://10.0.2.2:3000/api/housing';
    } else {
      return 'http://127.0.0.1:3000/api/housing';
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

  // GET /api/housing - Get all active listings
  static Future<List<HousingListing>> getAllListings({
    String? locality,
    double? minPrice,
    double? maxPrice,
    String? propertyType,
    int? bedrooms,
  }) async {
    try {
      final queryParams = <String, String>{};
      if (locality != null) queryParams['locality'] = locality;
      if (minPrice != null) queryParams['minPrice'] = minPrice.toString();
      if (maxPrice != null) queryParams['maxPrice'] = maxPrice.toString();
      if (propertyType != null) queryParams['propertyType'] = propertyType;
      if (bedrooms != null) queryParams['bedrooms'] = bedrooms.toString();

      final uri = Uri.parse(baseUrl).replace(queryParameters: queryParams);
      final response = await http.get(uri, headers: await _getHeaders());

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> listingsJson = data['listings'] ?? [];
        return listingsJson.map((json) => HousingListing.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load housing listings: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching housing listings: $e');
      throw Exception('Failed to load housing listings: $e');
    }
  }

  // GET /api/housing/search - Search listings
  static Future<List<HousingListing>> searchListings(String query) async {
    try {
      final uri = Uri.parse('$baseUrl/search').replace(
        queryParameters: {'query': query},
      );
      final response = await http.get(uri, headers: await _getHeaders());

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> listingsJson = data['listings'] ?? [];
        return listingsJson.map((json) => HousingListing.fromJson(json)).toList();
      } else {
        throw Exception('Search failed: ${response.statusCode}');
      }
    } catch (e) {
      print('Error searching housing: $e');
      throw Exception('Search failed: $e');
    }
  }

  // GET /api/housing/feed - Get housing feed with time ago
  static Future<Map<String, dynamic>> getHousingFeed({
    String? city,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final queryParams = <String, String>{
        'limit': limit.toString(),
        'offset': offset.toString(),
      };
      if (city != null) queryParams['city'] = city;

      final uri = Uri.parse('$baseUrl/feed').replace(queryParameters: queryParams);
      final response = await http.get(uri, headers: await _getHeaders());

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'listings': (data['listings'] as List<dynamic>)
              .map((json) => HousingListing.fromJson(json))
              .toList(),
          'count': data['count'] as int,
          'hasMore': data['hasMore'] as bool,
        };
      } else {
        throw Exception('Failed to load housing feed: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching housing feed: $e');
      throw Exception('Failed to load housing feed: $e');
    }
  }

  // GET /api/housing/stats - Get statistics
  static Future<HousingStats> getStats() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/stats'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return HousingStats.fromJson(data);
      } else {
        throw Exception('Failed to load stats: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching stats: $e');
      throw Exception('Failed to load stats: $e');
    }
  }

  // GET /api/housing/:id - Get single listing
  static Future<HousingListing> getListingById(String id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/$id'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return HousingListing.fromJson(data['listing']);
      } else {
        throw Exception('Listing not found: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching listing: $e');
      throw Exception('Failed to load listing: $e');
    }
  }

  // POST /api/housing - Create new listing (requires auth)
  static Future<HousingListing> createListing({
    required String title,
    required double monthlyPrice,
    required String locality,
    required String fullAddress,
    required double latitude,
    required double longitude,
    required String contactInfo,
    List<String>? images,
    int? bedrooms,
    int? bathrooms,
    int? squareFeet,
    String? propertyType,
    List<String>? amenities,
    String? description,
  }) async {
    try {
      final body = {
        'title': title,
        'monthlyPrice': monthlyPrice,
        'locality': locality,
        'fullAddress': fullAddress,
        'latitude': latitude,
        'longitude': longitude,
        'contactInfo': contactInfo,
        if (images != null) 'images': images,
        if (bedrooms != null) 'bedrooms': bedrooms,
        if (bathrooms != null) 'bathrooms': bathrooms,
        if (squareFeet != null) 'squareFeet': squareFeet,
        if (propertyType != null) 'propertyType': propertyType,
        if (amenities != null) 'amenities': amenities,
        if (description != null) 'description': description,
      };

      final response = await http.post(
        Uri.parse(baseUrl),
        headers: await _getHeaders(requiresAuth: true),
        body: json.encode(body),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        return HousingListing.fromJson(data['listing']);
      } else {
        throw Exception('Failed to create listing: ${response.body}');
      }
    } catch (e) {
      print('Error creating listing: $e');
      throw Exception('Failed to create listing: $e');
    }
  }

  // PUT /api/housing/:id - Update listing (requires auth)
  static Future<HousingListing> updateListing(
    String id,
    Map<String, dynamic> updates,
  ) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/$id'),
        headers: await _getHeaders(requiresAuth: true),
        body: json.encode(updates),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return HousingListing.fromJson(data['listing']);
      } else {
        throw Exception('Failed to update listing: ${response.body}');
      }
    } catch (e) {
      print('Error updating listing: $e');
      throw Exception('Failed to update listing: $e');
    }
  }

  // DELETE /api/housing/:id - Delete listing (requires auth)
  static Future<void> deleteListing(String id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/$id'),
        headers: await _getHeaders(requiresAuth: true),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to delete listing: ${response.body}');
      }
    } catch (e) {
      print('Error deleting listing: $e');
      throw Exception('Failed to delete listing: $e');
    }
  }

  // GET /api/housing/user/:userId - Get user's listings
  static Future<List<HousingListing>> getUserListings(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/user/$userId'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> listingsJson = data['listings'] ?? [];
        return listingsJson.map((json) => HousingListing.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load user listings: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching user listings: $e');
      throw Exception('Failed to load user listings: $e');
    }
  }
}

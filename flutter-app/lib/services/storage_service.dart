import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

/// Service for handling image uploads and storage operations
/// Supports both base64 encoding (for backend storage) and external storage (Firebase/Supabase)
class StorageService {
  final String baseUrl;
  final String? firebaseStorageBucket;
  final String? supabaseUrl;
  final String? supabaseAnonKey;

  StorageService({
    required this.baseUrl,
    this.firebaseStorageBucket,
    this.supabaseUrl,
    this.supabaseAnonKey,
  });

  /// Pick an image from gallery
  Future<XFile?> pickImageFromGallery() async {
    final ImagePicker picker = ImagePicker();
    try {
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      return image;
    } catch (e) {
      print('Error picking image: $e');
      return null;
    }
  }

  /// Pick an image from camera
  Future<XFile?> pickImageFromCamera() async {
    final ImagePicker picker = ImagePicker();
    try {
      final XFile? image = await picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      return image;
    } catch (e) {
      print('Error taking photo: $e');
      return null;
    }
  }

  /// Convert image file to base64 string
  Future<String> imageToBase64(XFile image) async {
    final bytes = await image.readAsBytes();
    return base64Encode(bytes);
  }

  /// Convert image file to base64 with data URI prefix
  Future<String> imageToDataUri(XFile image) async {
    final bytes = await image.readAsBytes();
    final base64String = base64Encode(bytes);

    // Determine MIME type from extension
    String mimeType = 'image/jpeg';
    final extension = image.path.split('.').last.toLowerCase();
    if (extension == 'png') {
      mimeType = 'image/png';
    } else if (extension == 'gif') {
      mimeType = 'image/gif';
    } else if (extension == 'webp') {
      mimeType = 'image/webp';
    }

    return 'data:$mimeType;base64,$base64String';
  }

  /// Upload image to backend (saves as base64 in database)
  Future<String?> uploadToBackend({
    required XFile image,
    required String userId,
    required String token,
    String folder = 'profile-pictures',
  }) async {
    try {
      final dataUri = await imageToDataUri(image);

      final response = await http.post(
        Uri.parse('$baseUrl/api/upload/image'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'userId': userId,
          'folder': folder,
          'image': dataUri,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return data['url'] as String?;
      } else {
        print('Upload failed: ${response.statusCode} ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error uploading to backend: $e');
      return null;
    }
  }

  /// Upload image to Supabase Storage
  Future<String?> uploadToSupabase({
    required XFile image,
    required String userId,
    String bucket = 'profile-pictures',
  }) async {
    if (supabaseUrl == null || supabaseAnonKey == null) {
      print('Supabase credentials not configured');
      return null;
    }

    try {
      final bytes = await image.readAsBytes();
      final fileName = '$userId-${DateTime.now().millisecondsSinceEpoch}.${image.path.split('.').last}';

      final response = await http.post(
        Uri.parse('$supabaseUrl/storage/v1/object/$bucket/$fileName'),
        headers: {
          'Authorization': 'Bearer $supabaseAnonKey',
          'Content-Type': 'application/octet-stream',
        },
        body: bytes,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return '$supabaseUrl/storage/v1/object/public/$bucket/$fileName';
      } else {
        print('Supabase upload failed: ${response.statusCode} ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error uploading to Supabase: $e');
      return null;
    }
  }

  /// Upload image to Firebase Storage (requires Firebase SDK)
  /// Note: This is a placeholder - actual implementation requires firebase_storage package
  Future<String?> uploadToFirebase({
    required XFile image,
    required String userId,
    String folder = 'profile-pictures',
  }) async {
    // TODO: Implement Firebase Storage upload
    // Requires: firebase_storage package
    print('Firebase upload not implemented yet. Use uploadToBackend() instead.');
    return null;
  }

  /// Upload profile picture and return the URL
  /// Automatically chooses the best storage option based on configuration
  Future<String?> uploadProfilePicture({
    required XFile image,
    required String userId,
    String? token,
  }) async {
    // Try Supabase first if configured
    if (supabaseUrl != null && supabaseAnonKey != null) {
      final url = await uploadToSupabase(
        image: image,
        userId: userId,
        bucket: 'profile-pictures',
      );
      if (url != null) return url;
    }

    // Fall back to backend base64 storage
    if (token != null) {
      return await uploadToBackend(
        image: image,
        userId: userId,
        token: token,
        folder: 'profile-pictures',
      );
    }

    // Last resort: return base64 data URI
    return await imageToDataUri(image);
  }

  /// Delete image from storage
  Future<bool> deleteImage({
    required String imageUrl,
    required String token,
  }) async {
    try {
      if (imageUrl.startsWith('http')) {
        // Delete from external storage
        if (imageUrl.contains(supabaseUrl ?? '')) {
          // Supabase deletion
          final parts = imageUrl.split('/');
          final bucket = parts[parts.length - 2];
          final fileName = parts[parts.length - 1];

          final response = await http.delete(
            Uri.parse('$supabaseUrl/storage/v1/object/$bucket/$fileName'),
            headers: {
              'Authorization': 'Bearer $supabaseAnonKey',
            },
          );

          return response.statusCode == 200;
        }
      } else {
        // Delete from backend
        final response = await http.delete(
          Uri.parse('$baseUrl/api/upload/image'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode({
            'imageUrl': imageUrl,
          }),
        );

        return response.statusCode == 200;
      }
    } catch (e) {
      print('Error deleting image: $e');
    }
    return false;
  }

  /// Compress image before upload
  Future<Uint8List> compressImage(Uint8List bytes, {int quality = 85}) async {
    // Basic compression - for production, consider using image package
    return bytes;
  }

  /// Get image dimensions
  Future<Map<String, int>> getImageDimensions(XFile image) async {
    // Placeholder - implement with image package if needed
    return {'width': 0, 'height': 0};
  }
}

import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:typed_data';
import '../services/api_service.dart';
import '../theme/neon_palette.dart';
import 'location_picker_screen.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final ApiService _apiService = ApiService();
  final TextEditingController _captionController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();

  File? _imageFile;
  Uint8List? _imageBytes;  // For web compatibility
  double? _latitude;
  double? _longitude;
  String? _city;
  String? _country;
  String _privacy = 'everyone';
  bool _isSubmitting = false;

  @override
  void dispose() {
    _captionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      // Request permissions only on mobile
      if (!kIsWeb) {
        PermissionStatus permission;
        if (source == ImageSource.camera) {
          permission = await Permission.camera.request();
        } else {
          permission = await Permission.photos.request();
        }

        if (!permission.isGranted) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Permission denied for ${source == ImageSource.camera ? 'camera' : 'gallery'}'),
              ),
            );
          }
          return;
        }
      }

      final XFile? image = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (image != null) {
        final bytes = await image.readAsBytes();
        setState(() {
          _imageBytes = bytes;
          if (!kIsWeb) {
            _imageFile = File(image.path);
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking image: $e')),
        );
      }
    }
  }

  Future<void> _selectLocation() async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (context) => const LocationPickerScreen(),
      ),
    );

    if (result != null) {
      setState(() {
        _latitude = result['latitude'];
        _longitude = result['longitude'];
        _city = result['city'];
        _country = result['country'];
      });
    }
  }

  Future<void> _createPost() async {
    if (_imageBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an image')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      // Convert image bytes to base64 string
      final base64Image = base64Encode(_imageBytes!);
      final imageUrl = 'data:image/jpeg;base64,$base64Image';

      await _apiService.createPost(
        imageUrl: imageUrl,
        caption: _captionController.text.trim().isEmpty ? null : _captionController.text.trim(),
        latitude: _latitude,
        longitude: _longitude,
        city: _city,
        country: _country,
        privacy: _privacy,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Post created successfully!')),
        );
        Navigator.pop(context, true); // Return true to indicate success
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating post: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NeonColors.background,
      appBar: AppBar(
        title: const Text('Create Post'),
        backgroundColor: NeonColors.surface,
        actions: [
          TextButton(
            onPressed: _isSubmitting ? null : _createPost,
            child: _isSubmitting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: NeonColors.cyan,
                    ),
                  )
                : const Text(
                    'POST',
                    style: TextStyle(
                      color: NeonColors.cyan,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image selection
            if (_imageBytes != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.memory(
                  _imageBytes!,
                  height: 300,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              )
            else
              Container(
                height: 300,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: NeonColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: NeonColors.cyan.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.add_photo_alternate,
                      size: 64,
                      color: NeonColors.mutedText,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No image selected',
                      style: TextStyle(
                        color: NeonColors.mutedText,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 16),

            // Image source buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _pickImage(ImageSource.camera),
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Camera'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: NeonColors.cyan,
                      foregroundColor: NeonColors.background,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _pickImage(ImageSource.gallery),
                    icon: const Icon(Icons.photo_library),
                    label: const Text('Gallery'),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: NeonColors.cyan),
                      foregroundColor: NeonColors.cyan,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Caption input
            TextField(
              controller: _captionController,
              maxLines: 3,
              style: const TextStyle(color: NeonColors.text),
              decoration: InputDecoration(
                hintText: 'Write a caption...',
                hintStyle: TextStyle(color: NeonColors.mutedText),
                filled: true,
                fillColor: NeonColors.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Location section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: NeonColors.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.location_on, color: NeonColors.cyan),
                      const SizedBox(width: 8),
                      const Text(
                        'Location',
                        style: TextStyle(
                          color: NeonColors.text,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: _selectLocation,
                        child: Text(
                          _latitude != null ? 'Change' : 'Add',
                          style: const TextStyle(color: NeonColors.cyan),
                        ),
                      ),
                    ],
                  ),
                  if (_city != null || _country != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      '${_city ?? ''}${_city != null && _country != null ? ', ' : ''}${_country ?? ''}',
                      style: const TextStyle(
                        color: NeonColors.text,
                        fontSize: 14,
                      ),
                    ),
                  ] else
                    const Padding(
                      padding: EdgeInsets.only(top: 8),
                      child: Text(
                        'No location selected',
                        style: TextStyle(
                          color: NeonColors.mutedText,
                          fontSize: 14,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Privacy settings
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: NeonColors.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.lock, color: NeonColors.cyan),
                      SizedBox(width: 8),
                      Text(
                        'Privacy',
                        style: TextStyle(
                          color: NeonColors.text,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  RadioListTile<String>(
                    title: const Text('Everyone', style: TextStyle(color: NeonColors.text)),
                    subtitle: const Text(
                      'Anyone can see this post',
                      style: TextStyle(color: NeonColors.mutedText, fontSize: 12),
                    ),
                    value: 'everyone',
                    groupValue: _privacy,
                    onChanged: (value) => setState(() => _privacy = value!),
                    activeColor: NeonColors.cyan,
                  ),
                  RadioListTile<String>(
                    title: const Text('Connections', style: TextStyle(color: NeonColors.text)),
                    subtitle: const Text(
                      'Only your connections can see',
                      style: TextStyle(color: NeonColors.mutedText, fontSize: 12),
                    ),
                    value: 'connections',
                    groupValue: _privacy,
                    onChanged: (value) => setState(() => _privacy = value!),
                    activeColor: NeonColors.cyan,
                  ),
                  RadioListTile<String>(
                    title: const Text('Private', style: TextStyle(color: NeonColors.text)),
                    subtitle: const Text(
                      'Only you can see this post',
                      style: TextStyle(color: NeonColors.mutedText, fontSize: 12),
                    ),
                    value: 'private',
                    groupValue: _privacy,
                    onChanged: (value) => setState(() => _privacy = value!),
                    activeColor: NeonColors.cyan,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

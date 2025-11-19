import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:convert';
import 'dart:typed_data';
import '../models/user_model.dart';
import '../services/api_service.dart';
import '../utils/initials_helper.dart';
import '../theme/luxury_theme.dart';
import '../widgets/luxury_components.dart';
import 'location_picker_screen.dart';

class EditProfileScreen extends StatefulWidget {
  final UserModel user;

  const EditProfileScreen({super.key, required this.user});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _apiService = ApiService();

  late TextEditingController _nameController;
  late TextEditingController _ageController;
  late TextEditingController _bioController;
  late TextEditingController _occupationController;
  late TextEditingController _educationController;
  late TextEditingController _learningGoalsController;
  late TextEditingController _strengthsController;
  late TextEditingController _weaknessesController;
  late TextEditingController _profilePictureController;
  late TextEditingController _cityController;
  late TextEditingController _countryController;
  late FocusNode _photoFocusNode;
  bool _profileImageLoadFailed = false;
  String? _selectedLocationPrivacy;
  final ImagePicker _picker = ImagePicker();
  Uint8List? _selectedImageBytes;
  double? _latitude;
  double? _longitude;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.profile?.name ?? '');
    _ageController = TextEditingController(text: widget.user.profile?.age.toString() ?? '');
    _bioController = TextEditingController(text: widget.user.profile?.bio ?? '');
    _occupationController = TextEditingController(text: widget.user.profile?.occupation ?? '');
    _educationController = TextEditingController(text: widget.user.profile?.educationLevel ?? '');
    _learningGoalsController = TextEditingController(text: widget.user.profile?.learningGoals ?? '');
    _strengthsController = TextEditingController(text: widget.user.profile?.strengths ?? '');
    _weaknessesController = TextEditingController(text: widget.user.profile?.weaknesses ?? '');
    _profilePictureController = TextEditingController(text: widget.user.profile?.profilePicture ?? '');
    _cityController = TextEditingController(text: widget.user.profile?.city ?? '');
    _countryController = TextEditingController(text: widget.user.profile?.country ?? '');
    _latitude = widget.user.profile?.latitude;
    _longitude = widget.user.profile?.longitude;
    _profilePictureController.addListener(_handlePhotoChanged);
    _photoFocusNode = FocusNode();
    _selectedLocationPrivacy = widget.user.profile?.locationPrivacy ?? 'everyone';
  }

  Future<void> _pickImageFromGallery() async {
    try {
      // On web, skip permission request (not supported)
      // On mobile, request permission
      if (!kIsWeb) {
        final status = await Permission.photos.request();

        if (status.isDenied) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Photo access denied. Please enable it in settings.'),
                duration: Duration(seconds: 3),
              ),
            );
          }
          return;
        }

        if (status.isPermanentlyDenied) {
          if (mounted) {
            // Show dialog to open settings
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Photo Access Required'),
                content: const Text('Please allow photo access in settings to select images from your gallery.'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () {
                      openAppSettings();
                      Navigator.pop(context);
                    },
                    child: const Text('Open Settings'),
                  ),
                ],
              ),
            );
          }
          return;
        }
      }

      // Pick image (works on both web and mobile)
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,      // Reduced from 1080 for smaller file size
        maxHeight: 800,     // Reduced from 1080 for smaller file size
        imageQuality: 70,   // Reduced from 85 for better compression
      );

      if (image != null) {
        final bytes = await image.readAsBytes();
        final sizeInMB = bytes.length / (1024 * 1024);

        print('📊 Image size: ${sizeInMB.toStringAsFixed(2)}MB');

        // Check if image is too large
        if (sizeInMB > 5) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Image too large (${sizeInMB.toStringAsFixed(2)}MB). Please select a smaller image.'),
                backgroundColor: Colors.red,
              ),
            );
          }
          return;
        }

        final base64Image = 'data:image/${image.path.split('.').last};base64,${base64Encode(bytes)}';

        print('📊 Base64 length: ${base64Image.length} characters');

        setState(() {
          _selectedImageBytes = bytes;
          _profilePictureController.text = base64Image;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Image selected (${sizeInMB.toStringAsFixed(2)}MB)'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking image: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _bioController.dispose();
    _occupationController.dispose();
    _educationController.dispose();
    _learningGoalsController.dispose();
    _strengthsController.dispose();
    _weaknessesController.dispose();
    _profilePictureController
      ..removeListener(_handlePhotoChanged)
      ..dispose();
    _cityController.dispose();
    _countryController.dispose();
    _photoFocusNode.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final profileImageUrl = _profilePictureController.text.trim().isEmpty
          ? null
          : _profilePictureController.text.trim();

      final profileData = {
        'name': _nameController.text,
        'age': int.parse(_ageController.text),
        'bio': _bioController.text,
        'occupation': _occupationController.text,
        'educationLevel': _educationController.text,
        'learningGoals': _learningGoalsController.text,
        'strengths': _strengthsController.text,
        'weaknesses': _weaknessesController.text,
        'profilePictureUrl': profileImageUrl,  // Use profilePictureUrl for uploaded images
        'profilePicture': profileImageUrl,     // Keep backward compatibility
        'city': _cityController.text.trim().isEmpty ? null : _cityController.text.trim(),
        'country': _countryController.text.trim().isEmpty ? null : _countryController.text.trim(),
        'latitude': _latitude,
        'longitude': _longitude,
        'locationPrivacy': _selectedLocationPrivacy ?? 'everyone',
      };

      await _apiService.updateProfile(profileData);

      // Refresh current user data globally
      await _apiService.getCurrentProfile();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!')),
        );
        Navigator.pop(context, true); // Return true to indicate update
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _handlePhotoChanged() {
    if (!mounted) return;
    setState(() {
      _profileImageLoadFailed = false;
    });
  }

  void _markProfileImageFailed() {
    if (_profileImageLoadFailed) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() => _profileImageLoadFailed = true);
    });
  }

  Widget _buildInitialsWidget(String initials) {
    return Text(
      initials,
      style: TextStyle(
        fontSize: 48,
        fontWeight: FontWeight.bold,
        color: LuxuryColors.mainBackground,
      ),
    );
  }

  Widget _buildAvatarPreview({
    required String initials,
    required bool showPhoto,
    required String photoUrl,
  }) {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: LuxuryColors.primaryGold,
        shape: BoxShape.circle,
        border: Border.all(color: LuxuryColors.mainBackground.withOpacity(0.3), width: 2),
      ),
      clipBehavior: Clip.antiAlias,
      child: showPhoto
          ? _buildImageWidget(photoUrl, initials)
          : Center(child: _buildInitialsWidget(initials)),
    );
  }

  Widget _buildImageWidget(String photoUrl, String initials) {
    // Check if it's a base64 image (from gallery)
    if (photoUrl.startsWith('data:image/')) {
      // For base64 images, use Image.memory with the selected bytes
      if (_selectedImageBytes != null) {
        return Image.memory(
          _selectedImageBytes!,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) {
            _markProfileImageFailed();
            return Center(child: _buildInitialsWidget(initials));
          },
        );
      }
    }

    // For network URLs, use Image.network
    return Image.network(
      photoUrl,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) {
        _markProfileImageFailed();
        return Center(child: _buildInitialsWidget(initials));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final String initials = initialsFromName(_nameController.text, fallback: 'U');
    final String selectedPhoto = _profilePictureController.text.trim();
    final bool hasPreviewPhoto = selectedPhoto.isNotEmpty && !_profileImageLoadFailed;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: GoldAppBar(
        title: 'Edit Profile',
        actions: [
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: LuxuryColors.primaryGold,
                  ),
                ),
              ),
            )
          else
            GoldIconButton(
              icon: Icons.check,
              onPressed: _saveProfile,
            ),
        ],
      ),
      body: GoldGradientBackground(
        child: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Center(
              child: Stack(
                children: [
                  _buildAvatarPreview(
                    initials: initials,
                    showPhoto: hasPreviewPhoto,
                    photoUrl: selectedPhoto,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      decoration: BoxDecoration(
                        color: LuxuryColors.primaryGold,
                        shape: BoxShape.circle,
                        border: Border.all(color: LuxuryColors.mainBackground, width: 2),
                      ),
                      child: IconButton(
                        icon: Icon(Icons.camera_alt, color: LuxuryColors.mainBackground),
                        onPressed: () async {
                          await showModalBottomSheet(
                            context: context,
                            builder: (context) => SafeArea(
                              child: Wrap(
                                children: [
                                  ListTile(
                                    leading: const Icon(Icons.photo_library),
                                    title: const Text('Choose from Gallery'),
                                    onTap: () {
                                      Navigator.pop(context);
                                      _pickImageFromGallery();
                                    },
                                  ),
                                  ListTile(
                                    leading: const Icon(Icons.link),
                                    title: const Text('Enter Image URL'),
                                    onTap: () {
                                      Navigator.pop(context);
                                      _photoFocusNode.requestFocus();
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            GoldTextField(
              controller: _profilePictureController,
              onTap: () => _photoFocusNode.requestFocus(),
              labelText: 'Profile photo URL',
              hintText: 'Use a direct HTTPS link to a PNG, JPG, or WebP image',
              prefixIcon: Icons.link,
              suffixIcon: _profilePictureController.text.isNotEmpty
                  ? Icons.clear
                  : null,
              onSuffixIconTap: _profilePictureController.clear,
              keyboardType: TextInputType.url,
            ),
            if (_profileImageLoadFailed)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'We couldn\'t preview that image. Double-check the URL or try another link.',
                  style: LuxuryTextStyles.bodySmall.copyWith(
                    color: LuxuryColors.errorGold,
                  ),
                ),
              ),
            const SizedBox(height: 32),
            GoldTextField(
              controller: _nameController,
              labelText: 'Name',
              prefixIcon: Icons.person,
              validator: (value) => value?.isEmpty ?? true ? 'Name is required' : null,
            ),
            const SizedBox(height: 16),
            GoldTextField(
              controller: _ageController,
              labelText: 'Age',
              prefixIcon: Icons.cake,
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value?.isEmpty ?? true) return 'Age is required';
                if (int.tryParse(value!) == null) return 'Enter a valid number';
                return null;
              },
            ),
            const SizedBox(height: 16),
            GoldTextField(
              controller: _bioController,
              labelText: 'Bio',
              prefixIcon: Icons.info,
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            GoldTextField(
              controller: _occupationController,
              labelText: 'Occupation',
              prefixIcon: Icons.work,
            ),
            const SizedBox(height: 16),
            GoldTextField(
              controller: _educationController,
              labelText: 'Education Level',
              prefixIcon: Icons.school,
            ),
            const SizedBox(height: 16),
            GoldTextField(
              controller: _learningGoalsController,
              labelText: 'Learning Goals',
              prefixIcon: Icons.flag,
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            GoldTextField(
              controller: _strengthsController,
              labelText: 'Strengths',
              prefixIcon: Icons.star,
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            GoldTextField(
              controller: _weaknessesController,
              labelText: 'Areas to Improve',
              prefixIcon: Icons.trending_up,
              maxLines: 2,
            ),
            const SizedBox(height: 24),
            GoldSectionHeader(
              text: 'Location',
              icon: Icons.location_on,
              padding: const EdgeInsets.only(bottom: 8),
            ),
            GoldTextField(
              controller: _cityController,
              labelText: 'City',
              hintText: 'Enter your city to appear on the map',
              prefixIcon: Icons.location_city,
            ),
            const SizedBox(height: 16),
            GoldTextField(
              controller: _countryController,
              labelText: 'Country',
              hintText: 'Enter your country to appear on the map',
              prefixIcon: Icons.public,
            ),
            const SizedBox(height: 16),
            GoldButton(
              text: _latitude != null && _longitude != null
                  ? 'Location Set ✓'
                  : 'Pick Location on Map',
              icon: Icons.map,
              width: double.infinity,
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LocationPickerScreen(),
                  ),
                );

                if (result != null) {
                  setState(() {
                    _latitude = result['latitude'];
                    _longitude = result['longitude'];
                    _cityController.text = result['city'] ?? '';
                    _countryController.text = result['country'] ?? '';
                  });
                }
              },
            ),
            if (_latitude != null && _longitude != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Coordinates: ${_latitude!.toStringAsFixed(4)}, ${_longitude!.toStringAsFixed(4)}',
                  style: LuxuryTextStyles.bodySmall.copyWith(
                    color: LuxuryColors.primaryGold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            const SizedBox(height: 24),
            GoldSectionHeader(
              text: 'Location Privacy',
              icon: Icons.privacy_tip,
              padding: const EdgeInsets.only(bottom: 8),
            ),
            DropdownButtonFormField<String>(
              value: _selectedLocationPrivacy,
              decoration: const InputDecoration(
                labelText: 'Who can see my location on the map?',
                prefixIcon: Icon(Icons.location_on),
                helperText: 'Control who can view your location on the world map',
              ),
              items: const [
                DropdownMenuItem(
                  value: 'everyone',
                  child: Row(
                    children: [
                      Icon(Icons.public, size: 20),
                      SizedBox(width: 8),
                      Text('Everyone'),
                    ],
                  ),
                ),
                DropdownMenuItem(
                  value: 'connections',
                  child: Row(
                    children: [
                      Icon(Icons.group, size: 20),
                      SizedBox(width: 8),
                      Text('My Connections Only'),
                    ],
                  ),
                ),
                DropdownMenuItem(
                  value: 'private',
                  child: Row(
                    children: [
                      Icon(Icons.lock, size: 20),
                      SizedBox(width: 8),
                      Text('Private (Hidden)'),
                    ],
                  ),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedLocationPrivacy = value;
                });
              },
            ),
            const SizedBox(height: 32),
            GoldButton(
              text: 'Save Changes',
              icon: Icons.save,
              width: double.infinity,
              isLoading: _isLoading,
              onPressed: _saveProfile,
            ),
          ],
          ),
        ),
      ),
    );
  }
}

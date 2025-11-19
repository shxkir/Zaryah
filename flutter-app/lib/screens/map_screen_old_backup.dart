import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:convert';
import 'dart:typed_data';
import '../models/user_model.dart';
import '../models/post_model.dart';
import '../services/api_service.dart';
import '../theme/neon_palette.dart';
import 'user_profile_detail_screen.dart';
import 'create_post_screen.dart';
import 'chat_screen.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final ApiService _apiService = ApiService();
  final MapController _mapController = MapController();

  List<UserModel> _mapUsers = [];
  List<PostModel> _mapPosts = [];
  bool _isLoading = true;
  bool _showUsers = true;
  bool _showPosts = true;
  String? _selectedCountry;
  LatLng? _currentUserLocation;
  bool _isLocating = false;

  @override
  void initState() {
    super.initState();
    _loadMapData();
  }

  Future<void> _loadMapData() async {
    setState(() => _isLoading = true);

    try {
      final usersData = await _apiService.getMapUsers();
      final postsData = await _apiService.getMapPosts();

      setState(() {
        _mapUsers = usersData.map((u) => UserModel.fromJson(u)).toList();
        _mapPosts = postsData.map((p) => PostModel.fromJson(p)).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading map data: $e')),
        );
      }
    }
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _isLocating = true);

    try {
      // Request location permission
      final permission = await Permission.location.request();

      if (!permission.isGranted) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permission denied. Please enable location access in settings.')),
          );
        }
        setState(() => _isLocating = false);
        return;
      }

      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please enable location services on your device')),
          );
        }
        setState(() => _isLocating = false);
        return;
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _currentUserLocation = LatLng(position.latitude, position.longitude);
        _isLocating = false;
      });

      // Animate to current location
      _mapController.move(_currentUserLocation!, 13.0);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Location found! Tap the marker to see options.'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error getting location: $e')),
        );
      }
      setState(() => _isLocating = false);
    }
  }

  List<Marker> _buildMarkers() {
    List<Marker> markers = [];

    // Current user location marker (green pin with pulsing effect)
    if (_currentUserLocation != null) {
      markers.add(
        Marker(
          point: _currentUserLocation!,
          width: 50,
          height: 50,
          child: GestureDetector(
            onTap: () => _showCurrentLocationOptions(),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Pulsing circle
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                ),
                // Main marker
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.green.withOpacity(0.6),
                        blurRadius: 15,
                        spreadRadius: 3,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.person_pin,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // User markers (cyan pins)
    if (_showUsers) {
      for (var user in _mapUsers) {
        if (user.profile?.latitude != null && user.profile?.longitude != null) {
          // Filter by country if selected
          if (_selectedCountry != null && user.profile?.country != _selectedCountry) {
            continue;
          }

          markers.add(
            Marker(
              point: LatLng(user.profile!.latitude!, user.profile!.longitude!),
              width: 40,
              height: 40,
              child: GestureDetector(
                onTap: () => _showUserDetails(user),
                child: Container(
                  decoration: BoxDecoration(
                    color: NeonColors.cyan,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: NeonColors.cyan.withOpacity(0.5),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.person,
                    color: NeonColors.background,
                    size: 24,
                  ),
                ),
              ),
            ),
          );
        }
      }
    }

    // Post markers (purple pins)
    if (_showPosts) {
      for (var post in _mapPosts) {
        if (post.latitude != null && post.longitude != null) {
          // Filter by country if selected
          if (_selectedCountry != null && post.country != _selectedCountry) {
            continue;
          }

          markers.add(
            Marker(
              point: LatLng(post.latitude!, post.longitude!),
              width: 40,
              height: 40,
              child: GestureDetector(
                onTap: () => _showPostDetails(post),
                child: Container(
                  decoration: BoxDecoration(
                    color: NeonColors.purple,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: NeonColors.purple.withOpacity(0.5),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.photo,
                    color: NeonColors.background,
                    size: 24,
                  ),
                ),
              ),
            ),
          );
        }
      }
    }

    return markers;
  }

  List<Polyline> _buildConnectionLines() {
    List<Polyline> polylines = [];

    // Only show connection lines between users in the same country
    if (_showUsers && _mapUsers.length > 1) {
      // Group users by country
      Map<String, List<LatLng>> usersByCountry = {};

      for (var user in _mapUsers) {
        if (user.profile?.latitude != null &&
            user.profile?.longitude != null &&
            user.profile?.country != null) {

          // Filter by selected country if applicable
          if (_selectedCountry != null && user.profile?.country != _selectedCountry) {
            continue;
          }

          String country = user.profile!.country!;
          if (!usersByCountry.containsKey(country)) {
            usersByCountry[country] = [];
          }
          usersByCountry[country]!.add(
            LatLng(user.profile!.latitude!, user.profile!.longitude!)
          );
        }
      }

      // Create glowing lines connecting users in the same country
      for (var countryPoints in usersByCountry.values) {
        if (countryPoints.length > 1) {
          // Connect each user to the next one in a chain
          for (int i = 0; i < countryPoints.length - 1; i++) {
            // Outer glow line
            polylines.add(
              Polyline(
                points: [countryPoints[i], countryPoints[i + 1]],
                color: NeonColors.cyan.withOpacity(0.3),
                strokeWidth: 8.0,
              ),
            );
            // Inner bright line
            polylines.add(
              Polyline(
                points: [countryPoints[i], countryPoints[i + 1]],
                color: NeonColors.cyan,
                strokeWidth: 2.0,
              ),
            );
          }
        }
      }
    }

    return polylines;
  }

  void _showUserDetails(UserModel user) {
    showModalBottomSheet(
      context: context,
      backgroundColor: NeonColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: NeonColors.cyan,
                  child: Text(
                    user.profile?.name[0].toUpperCase() ?? 'U',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: NeonColors.background,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.profile?.name ?? 'Unknown',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: NeonColors.text,
                        ),
                      ),
                      Text(
                        user.profile?.occupation ?? '',
                        style: const TextStyle(
                          fontSize: 14,
                          color: NeonColors.mutedText,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (user.profile?.city != null || user.profile?.country != null)
              Row(
                children: [
                  const Icon(Icons.location_on, color: NeonColors.cyan, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    '${user.profile?.city ?? ''}${user.profile?.city != null && user.profile?.country != null ? ', ' : ''}${user.profile?.country ?? ''}',
                    style: const TextStyle(color: NeonColors.text),
                  ),
                ],
              ),
            const SizedBox(height: 8),
            if (user.profile?.educationLevel != null)
              Row(
                children: [
                  const Icon(Icons.school, color: NeonColors.cyan, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    user.profile!.educationLevel,
                    style: const TextStyle(color: NeonColors.text),
                  ),
                ],
              ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => UserProfileDetailScreen(user: user),
                        ),
                      );
                    },
                    icon: const Icon(Icons.person),
                    label: const Text('View Profile'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: NeonColors.cyan,
                      foregroundColor: NeonColors.background,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatScreen(
                            partnerId: user.id,
                            partnerName: user.profile?.name ?? 'Unknown',
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.message),
                    label: const Text('Message'),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: NeonColors.cyan),
                      foregroundColor: NeonColors.cyan,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showCurrentLocationOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: NeonColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.person_pin_circle,
              color: Colors.green,
              size: 48,
            ),
            const SizedBox(height: 16),
            const Text(
              'Your Current Location',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: NeonColors.text,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Lat: ${_currentUserLocation!.latitude.toStringAsFixed(6)}\nLng: ${_currentUserLocation!.longitude.toStringAsFixed(6)}',
              style: const TextStyle(
                color: NeonColors.mutedText,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                // Re-center on current location
                _mapController.move(_currentUserLocation!, 15.0);
              },
              icon: const Icon(Icons.center_focus_strong),
              label: const Text('Re-center Map'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 48),
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () {
                setState(() {
                  _currentUserLocation = null;
                });
                Navigator.pop(context);
              },
              icon: const Icon(Icons.clear),
              label: const Text('Clear Location'),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: NeonColors.mutedText),
                foregroundColor: NeonColors.mutedText,
                minimumSize: const Size(double.infinity, 48),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPostImage(String imageUrl) {
    // Check if it's a base64 image
    if (imageUrl.startsWith('data:image/')) {
      try {
        final base64String = imageUrl.split(',')[1];
        final Uint8List bytes = base64Decode(base64String);
        return Image.memory(
          bytes,
          height: 300,
          width: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Container(
            height: 300,
            color: NeonColors.background,
            child: const Icon(Icons.broken_image, size: 50, color: NeonColors.mutedText),
          ),
        );
      } catch (e) {
        return Container(
          height: 300,
          color: NeonColors.background,
          child: const Icon(Icons.broken_image, size: 50, color: NeonColors.mutedText),
        );
      }
    }

    // Regular network image
    return Image.network(
      imageUrl,
      height: 300,
      width: double.infinity,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          height: 300,
          color: NeonColors.background,
          child: Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                  : null,
              color: NeonColors.purple,
            ),
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) => Container(
        height: 300,
        color: NeonColors.background,
        child: const Icon(Icons.broken_image, size: 50, color: NeonColors.mutedText),
      ),
    );
  }

  Future<void> _deletePost(String postId) async {
    try {
      await _apiService.deletePost(postId);
      await _loadMapData(); // Reload map data
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Post deleted successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting post: $e')),
        );
      }
    }
  }

  void _showPostDetails(PostModel post) {
    showModalBottomSheet(
      context: context,
      backgroundColor: NeonColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(20),
          child: ListView(
            controller: scrollController,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: _buildPostImage(post.imageUrl),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: NeonColors.purple,
                    child: Text(
                      post.user?.profile?.name[0].toUpperCase() ?? 'U',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: NeonColors.background,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          post.user?.profile?.name ?? 'Unknown',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: NeonColors.text,
                          ),
                        ),
                        if (post.city != null || post.country != null)
                          Text(
                            '${post.city ?? ''}${post.city != null && post.country != null ? ', ' : ''}${post.country ?? ''}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: NeonColors.mutedText,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              if (post.caption != null) ...[
                const SizedBox(height: 16),
                Text(
                  post.caption!,
                  style: const TextStyle(
                    fontSize: 14,
                    color: NeonColors.text,
                  ),
                ),
              ],
              const SizedBox(height: 16),
              Text(
                _formatDate(post.createdAt),
                style: const TextStyle(
                  fontSize: 12,
                  color: NeonColors.mutedText,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  if (post.user != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => UserProfileDetailScreen(user: post.user!),
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.person),
                label: const Text('View User Profile'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: NeonColors.purple,
                  foregroundColor: NeonColors.background,
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () {
                  // Show confirmation dialog
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      backgroundColor: NeonColors.surface,
                      title: const Text(
                        'Delete Post?',
                        style: TextStyle(color: NeonColors.text),
                      ),
                      content: const Text(
                        'Are you sure you want to delete this post? This action cannot be undone.',
                        style: TextStyle(color: NeonColors.mutedText),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () async {
                            Navigator.pop(context); // Close dialog
                            Navigator.pop(context); // Close bottom sheet
                            await _deletePost(post.id);
                          },
                          child: const Text(
                            'Delete',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  );
                },
                icon: const Icon(Icons.delete_outline),
                label: const Text('Delete Post'),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.red),
                  foregroundColor: Colors.red,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()} year${(difference.inDays / 365).floor() > 1 ? 's' : ''} ago';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()} month${(difference.inDays / 30).floor() > 1 ? 's' : ''} ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }

  Set<String> _getCountries() {
    final countries = <String>{};
    for (var user in _mapUsers) {
      if (user.profile?.country != null) {
        countries.add(user.profile!.country!);
      }
    }
    for (var post in _mapPosts) {
      if (post.country != null) {
        countries.add(post.country!);
      }
    }
    return countries;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NeonColors.background,
      appBar: AppBar(
        title: const Text('World Map'),
        backgroundColor: NeonColors.surface,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterMenu(),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadMapData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: NeonColors.cyan),
            )
          : Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: const LatLng(20, 0), // Center of world
                    initialZoom: 2,
                    minZoom: 2,
                    maxZoom: 18,
                  ),
                  children: [
                    // Dark theme map tiles
                    TileLayer(
                      urlTemplate: 'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}.png',
                      subdomains: const ['a', 'b', 'c'],
                      userAgentPackageName: 'com.zaryah.app',
                    ),
                    // Glowing connection lines between users
                    PolylineLayer(
                      polylines: _buildConnectionLines(),
                    ),
                    MarkerLayer(markers: _buildMarkers()),
                  ],
                ),
                Positioned(
                  top: 16,
                  left: 16,
                  right: 16,
                  child: Card(
                    color: NeonColors.surface.withOpacity(0.95),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildLegendItem(
                            Icons.person,
                            'Users',
                            NeonColors.cyan,
                            _showUsers,
                            (value) => setState(() => _showUsers = value!),
                          ),
                          const SizedBox(width: 20),
                          _buildLegendItem(
                            Icons.photo,
                            'Posts',
                            NeonColors.purple,
                            _showPosts,
                            (value) => setState(() => _showPosts = value!),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'locate_btn',
        onPressed: _isLocating ? null : _getCurrentLocation,
        backgroundColor: _currentUserLocation != null ? Colors.green : NeonColors.cyan,
        child: _isLocating
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Icon(
                _currentUserLocation != null ? Icons.my_location : Icons.location_searching,
                color: Colors.white,
              ),
      ),
    );
  }

  Widget _buildLegendItem(
    IconData icon,
    String label,
    Color color,
    bool value,
    Function(bool?) onChanged,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Checkbox(
          value: value,
          onChanged: onChanged,
          activeColor: color,
        ),
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            color: NeonColors.text,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  void _showFilterMenu() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: NeonColors.surface,
        title: const Text('Filter by Country', style: TextStyle(color: NeonColors.text)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('All Countries', style: TextStyle(color: NeonColors.text)),
              leading: Radio<String?>(
                value: null,
                groupValue: _selectedCountry,
                onChanged: (value) {
                  setState(() => _selectedCountry = value);
                  Navigator.pop(context);
                },
                activeColor: NeonColors.cyan,
              ),
            ),
            ..._getCountries().map((country) => ListTile(
                  title: Text(country, style: const TextStyle(color: NeonColors.text)),
                  leading: Radio<String?>(
                    value: country,
                    groupValue: _selectedCountry,
                    onChanged: (value) {
                      setState(() => _selectedCountry = value);
                      Navigator.pop(context);
                    },
                    activeColor: NeonColors.cyan,
                  ),
                )),
          ],
        ),
      ),
    );
  }
}

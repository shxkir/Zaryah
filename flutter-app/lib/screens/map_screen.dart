import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:convert';
import 'dart:typed_data';
import '../models/user_model.dart';
import '../services/api_service.dart';
import '../theme/luxury_theme.dart';
import '../widgets/luxury_components.dart';
import 'user_profile_detail_screen.dart';
import 'chat_screen.dart';

enum MapStyle { dark, light, satellite }

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final ApiService _apiService = ApiService();
  final MapController _mapController = MapController();

  List<UserModel> _mapUsers = [];
  bool _isLoading = true;
  bool _showUsers = true;
  String? _selectedCountry;
  LatLng? _currentUserLocation;
  bool _isLocating = false;

  // Map style
  MapStyle _currentStyle = MapStyle.dark;

  @override
  void initState() {
    super.initState();
    _loadMapData();
  }

  Future<void> _loadMapData() async {
    setState(() => _isLoading = true);

    try {
      final usersData = await _apiService.getMapUsers();

      setState(() {
        _mapUsers = usersData.map((u) => UserModel.fromJson(u)).toList();
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
      final permission = await Permission.location.request();

      if (!permission.isGranted) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Location permission denied. Please enable in settings.'),
            ),
          );
        }
        setState(() => _isLocating = false);
        return;
      }

      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please enable location services')),
          );
        }
        setState(() => _isLocating = false);
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _currentUserLocation = LatLng(position.latitude, position.longitude);
        _isLocating = false;
      });

      _mapController.move(_currentUserLocation!, 13.0);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error getting location: $e')),
        );
      }
      setState(() => _isLocating = false);
    }
  }

  String _getTileUrl() {
    switch (_currentStyle) {
      case MapStyle.dark:
        return 'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}.png';
      case MapStyle.light:
        return 'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}.png';
      case MapStyle.satellite:
        return 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}';
    }
  }

  List<Marker> _buildMarkers() {
    List<Marker> markers = [];

    // Current user location marker
    if (_currentUserLocation != null) {
      markers.add(
        Marker(
          point: _currentUserLocation!,
          width: 50,
          height: 50,
          child: GestureDetector(
            onTap: _showCurrentLocationOptions,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                ),
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

    // User markers with profile pictures
    if (_showUsers) {
      for (var user in _mapUsers) {
        if (user.profile?.latitude != null && user.profile?.longitude != null) {
          if (_selectedCountry != null && user.profile?.country != _selectedCountry) {
            continue;
          }

          markers.add(
            Marker(
              point: LatLng(user.profile!.latitude!, user.profile!.longitude!),
              width: 50,
              height: 50,
              child: GestureDetector(
                onTap: () => _showUserDetails(user),
                child: _buildUserMarker(user),
              ),
            ),
          );
        }
      }
    }

    return markers;
  }

  Widget _buildUserMarker(UserModel user) {
    final profilePic = user.profile?.displayPicture;

    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: LuxuryColors.primaryGold.withOpacity(0.5),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: ClipOval(
        child: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: LuxuryColors.primaryGold,
            border: Border.all(color: Colors.white, width: 2),
          ),
          child: _buildMarkerContent(profilePic, user),
        ),
      ),
    );
  }

  Widget _buildMarkerContent(String? profilePic, UserModel user) {
    if (profilePic != null && profilePic.isNotEmpty) {
      if (profilePic.startsWith('data:image/')) {
        try {
          final base64String = profilePic.split(',')[1];
          final Uint8List bytes = base64Decode(base64String);
          return Image.memory(
            bytes,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _buildInitialsAvatar(user),
          );
        } catch (e) {
          return _buildInitialsAvatar(user);
        }
      } else if (profilePic.startsWith('http')) {
        return Image.network(
          profilePic,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return const Center(
              child: CircularProgressIndicator(strokeWidth: 2),
            );
          },
          errorBuilder: (_, __, ___) => _buildInitialsAvatar(user),
        );
      }
    }
    return _buildInitialsAvatar(user);
  }

  Widget _buildInitialsAvatar(UserModel user) {
    return Center(
      child: Text(
        user.profile?.name[0].toUpperCase() ?? 'U',
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: LuxuryColors.mainBackground,
        ),
      ),
    );
  }

  void _showUserDetails(UserModel user) {
    showModalBottomSheet(
      context: context,
      backgroundColor: LuxuryColors.cardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Profile Picture
            CircleAvatar(
              radius: 40,
              backgroundColor: LuxuryColors.primaryGold,
              backgroundImage: user.profile?.displayPicture != null
                  ? (user.profile!.displayPicture!.startsWith('data:image/')
                      ? MemoryImage(
                          base64Decode(user.profile!.displayPicture!.split(',')[1]))
                      : NetworkImage(user.profile!.displayPicture!) as ImageProvider)
                  : null,
              child: user.profile?.displayPicture == null
                  ? Text(
                      user.profile?.name[0].toUpperCase() ?? 'U',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: LuxuryColors.mainBackground,
                      ),
                    )
                  : null,
            ),
            const SizedBox(height: 16),
            // Name
            Text(
              user.profile?.name ?? 'Unknown',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: LuxuryColors.bodyText,
              ),
            ),
            const SizedBox(height: 8),
            // Location
            if (user.profile?.formattedLocation.isNotEmpty == true)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.location_on, color: LuxuryColors.primaryGold, size: 18),
                  const SizedBox(width: 4),
                  Text(
                    user.profile!.formattedLocation,
                    style: const TextStyle(
                      fontSize: 14,
                      color: LuxuryColors.mutedText,
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 24),
            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      // TODO: Implement add connection
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Connection request sent!')),
                      );
                    },
                    icon: const Icon(Icons.person_add),
                    label: const Text('Add'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: LuxuryColors.primaryGold,
                      foregroundColor: LuxuryColors.mainBackground,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
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
                    style: ElevatedButton.styleFrom(
                      backgroundColor: LuxuryColors.softGold,
                      foregroundColor: LuxuryColors.mainBackground,
                      padding: const EdgeInsets.symmetric(vertical: 12),
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
      backgroundColor: LuxuryColors.cardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.person_pin_circle, color: Colors.green, size: 48),
            const SizedBox(height: 16),
            const Text(
              'Your Current Location',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: LuxuryColors.bodyText,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                _mapController.move(_currentUserLocation!, 15.0);
              },
              icon: const Icon(Icons.center_focus_strong),
              label: const Text('Re-center Map'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                minimumSize: const Size(double.infinity, 48),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showMapStylePicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: LuxuryColors.cardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Map Style',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: LuxuryColors.bodyText,
              ),
            ),
            const SizedBox(height: 16),
            ...MapStyle.values.map((style) {
              final isSelected = _currentStyle == style;
              return ListTile(
                title: Text(
                  style.name.toUpperCase(),
                  style: TextStyle(
                    color: isSelected ? LuxuryColors.primaryGold : LuxuryColors.bodyText,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                leading: Radio<MapStyle>(
                  value: style,
                  groupValue: _currentStyle,
                  onChanged: (value) {
                    setState(() => _currentStyle = value!);
                    Navigator.pop(context);
                  },
                  activeColor: LuxuryColors.primaryGold,
                ),
              );
            }),
          ],
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LuxuryColors.mainBackground,
      appBar: AppBar(
        title: const Text('World Map'),
        backgroundColor: LuxuryColors.cardBackground,
        actions: [
          // Toggle Users display
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: FilterChip(
              label: const Text('Users'),
              selected: _showUsers,
              onSelected: (value) {
                setState(() => _showUsers = value);
              },
              selectedColor: LuxuryColors.primaryGold,
              checkmarkColor: LuxuryColors.mainBackground,
              backgroundColor: LuxuryColors.cardBackground,
              labelStyle: TextStyle(
                color: _showUsers ? LuxuryColors.mainBackground : LuxuryColors.bodyText,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.layers),
            tooltip: 'Map Style',
            onPressed: _showMapStylePicker,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: _loadMapData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: LuxuryColors.primaryGold),
            )
          : FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: const LatLng(20, 0),
                initialZoom: 2,
                minZoom: 2,
                maxZoom: 18,
              ),
              children: [
                TileLayer(
                  urlTemplate: _getTileUrl(),
                  subdomains: _currentStyle == MapStyle.satellite ? const [] : const ['a', 'b', 'c'],
                  userAgentPackageName: 'com.zaryah.app',
                ),
                MarkerLayer(markers: _buildMarkers()),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'locate_btn',
        onPressed: _isLocating ? null : _getCurrentLocation,
        backgroundColor:
            _currentUserLocation != null ? Colors.green : LuxuryColors.primaryGold,
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
                _currentUserLocation != null
                    ? Icons.my_location
                    : Icons.location_searching,
                color: Colors.white,
              ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:permission_handler/permission_handler.dart';
import '../theme/neon_palette.dart';

class LocationPickerScreen extends StatefulWidget {
  const LocationPickerScreen({super.key});

  @override
  State<LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  final TextEditingController _searchController = TextEditingController();

  bool _isLoadingGPS = false;
  double? _latitude;
  double? _longitude;
  String? _city;
  String? _country;

  // Popular cities for manual selection
  final List<Map<String, dynamic>> _popularCities = [
    {'city': 'New York', 'country': 'United States', 'lat': 40.7128, 'lng': -74.0060},
    {'city': 'London', 'country': 'United Kingdom', 'lat': 51.5074, 'lng': -0.1278},
    {'city': 'Tokyo', 'country': 'Japan', 'lat': 35.6762, 'lng': 139.6503},
    {'city': 'Paris', 'country': 'France', 'lat': 48.8566, 'lng': 2.3522},
    {'city': 'Dubai', 'country': 'United Arab Emirates', 'lat': 25.2048, 'lng': 55.2708},
    {'city': 'Singapore', 'country': 'Singapore', 'lat': 1.3521, 'lng': 103.8198},
    {'city': 'Hong Kong', 'country': 'China', 'lat': 22.3193, 'lng': 114.1694},
    {'city': 'Sydney', 'country': 'Australia', 'lat': -33.8688, 'lng': 151.2093},
    {'city': 'Mumbai', 'country': 'India', 'lat': 19.0760, 'lng': 72.8777},
    {'city': 'São Paulo', 'country': 'Brazil', 'lat': -23.5505, 'lng': -46.6333},
    {'city': 'Cairo', 'country': 'Egypt', 'lat': 30.0444, 'lng': 31.2357},
    {'city': 'Mexico City', 'country': 'Mexico', 'lat': 19.4326, 'lng': -99.1332},
    {'city': 'Moscow', 'country': 'Russia', 'lat': 55.7558, 'lng': 37.6173},
    {'city': 'Toronto', 'country': 'Canada', 'lat': 43.6532, 'lng': -79.3832},
    {'city': 'Berlin', 'country': 'Germany', 'lat': 52.5200, 'lng': 13.4050},
    {'city': 'Los Angeles', 'country': 'United States', 'lat': 34.0522, 'lng': -118.2437},
    {'city': 'Seoul', 'country': 'South Korea', 'lat': 37.5665, 'lng': 126.9780},
    {'city': 'Bangkok', 'country': 'Thailand', 'lat': 13.7563, 'lng': 100.5018},
    {'city': 'Istanbul', 'country': 'Turkey', 'lat': 41.0082, 'lng': 28.9784},
    {'city': 'Rome', 'country': 'Italy', 'lat': 41.9028, 'lng': 12.4964},
  ];

  List<Map<String, dynamic>> _filteredCities = [];

  @override
  void initState() {
    super.initState();
    _filteredCities = _popularCities;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _isLoadingGPS = true);

    try {
      // Request location permission
      final permission = await Permission.location.request();

      if (!permission.isGranted) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permission denied')),
          );
        }
        return;
      }

      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please enable location services')),
          );
        }
        return;
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Get place name from coordinates
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        setState(() {
          _latitude = position.latitude;
          _longitude = position.longitude;
          _city = place.locality ?? place.subAdministrativeArea ?? 'Unknown';
          _country = place.country ?? 'Unknown';
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Location detected: $_city, $_country')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error getting location: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoadingGPS = false);
      }
    }
  }

  void _selectCity(Map<String, dynamic> cityData) {
    setState(() {
      _latitude = cityData['lat'];
      _longitude = cityData['lng'];
      _city = cityData['city'];
      _country = cityData['country'];
    });
  }

  void _confirmLocation() {
    if (_latitude == null || _longitude == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a location')),
      );
      return;
    }

    Navigator.pop(context, {
      'latitude': _latitude,
      'longitude': _longitude,
      'city': _city,
      'country': _country,
    });
  }

  void _filterCities(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredCities = _popularCities;
      } else {
        _filteredCities = _popularCities
            .where((city) =>
                city['city'].toLowerCase().contains(query.toLowerCase()) ||
                city['country'].toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NeonColors.background,
      appBar: AppBar(
        title: const Text('Select Location'),
        backgroundColor: NeonColors.surface,
        actions: [
          TextButton(
            onPressed: _confirmLocation,
            child: const Text(
              'DONE',
              style: TextStyle(
                color: NeonColors.cyan,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // GPS Section
          Container(
            padding: const EdgeInsets.all(20),
            color: NeonColors.surface,
            child: Column(
              children: [
                ElevatedButton.icon(
                  onPressed: _isLoadingGPS ? null : _getCurrentLocation,
                  icon: _isLoadingGPS
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: NeonColors.background,
                          ),
                        )
                      : const Icon(Icons.my_location),
                  label: Text(_isLoadingGPS ? 'Detecting...' : 'Use Current Location'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: NeonColors.cyan,
                    foregroundColor: NeonColors.background,
                    minimumSize: const Size(double.infinity, 50),
                  ),
                ),
                if (_latitude != null && _longitude != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: NeonColors.background,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: NeonColors.cyan.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.location_on, color: NeonColors.cyan),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '$_city',
                                style: const TextStyle(
                                  color: NeonColors.text,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '$_country',
                                style: const TextStyle(
                                  color: NeonColors.mutedText,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            setState(() {
                              _latitude = null;
                              _longitude = null;
                              _city = null;
                              _country = null;
                            });
                          },
                          icon: const Icon(Icons.close, color: NeonColors.mutedText),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          const Divider(height: 1, color: NeonColors.mutedText),

          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              onChanged: _filterCities,
              style: const TextStyle(color: NeonColors.text),
              decoration: InputDecoration(
                hintText: 'Search cities...',
                hintStyle: TextStyle(color: NeonColors.mutedText),
                prefixIcon: const Icon(Icons.search, color: NeonColors.cyan),
                filled: true,
                fillColor: NeonColors.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // Cities list
          Expanded(
            child: ListView.builder(
              itemCount: _filteredCities.length,
              itemBuilder: (context, index) {
                final city = _filteredCities[index];
                final isSelected = _latitude == city['lat'] && _longitude == city['lng'];

                return ListTile(
                  leading: Icon(
                    Icons.location_city,
                    color: isSelected ? NeonColors.cyan : NeonColors.mutedText,
                  ),
                  title: Text(
                    city['city'],
                    style: TextStyle(
                      color: isSelected ? NeonColors.cyan : NeonColors.text,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  subtitle: Text(
                    city['country'],
                    style: const TextStyle(color: NeonColors.mutedText),
                  ),
                  trailing: isSelected
                      ? const Icon(Icons.check_circle, color: NeonColors.cyan)
                      : null,
                  onTap: () => _selectCity(city),
                  tileColor: isSelected
                      ? NeonColors.cyan.withOpacity(0.1)
                      : Colors.transparent,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

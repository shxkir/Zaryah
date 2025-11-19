// ==========================================
// SATELLITE MAP IMPLEMENTATION
// Add to: flutter-app/lib/screens/map_screen.dart
// ==========================================

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../theme/luxury_theme.dart';
import '../widgets/luxury_components.dart';

class MapScreenWithSatellite extends StatefulWidget {
  const MapScreenWithSatellite({super.key});

  @override
  State<MapScreenWithSatellite> createState() => _MapScreenWithSatelliteState();
}

class _MapScreenWithSatelliteState extends State<MapScreenWithSatellite> {
  String _mapType = 'dark'; // 'dark', 'light', 'satellite'
  bool _showUsers = true;
  bool _showListings = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GoldAppBar(
        title: 'Map',
        actions: [
          // Map Type Selector
          PopupMenuButton<String>(
            icon: const Icon(Icons.layers, color: LuxuryColors.primaryGold),
            onSelected: (value) {
              setState(() {
                _mapType = value;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'dark',
                child: Row(
                  children: [
                    Icon(Icons.dark_mode, size: 20),
                    SizedBox(width: 8),
                    Text('Dark Map'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'light',
                child: Row(
                  children: [
                    Icon(Icons.light_mode, size: 20),
                    SizedBox(width: 8),
                    Text('Light Map'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'satellite',
                child: Row(
                  children: [
                    Icon(Icons.satellite, size: 20),
                    SizedBox(width: 8),
                    Text('Satellite'),
                  ],
                ),
              ),
            ],
          ),
          // User Toggle
          IconButton(
            icon: Icon(
              _showUsers ? Icons.people : Icons.people_outline,
              color: LuxuryColors.primaryGold,
            ),
            onPressed: () {
              setState(() {
                _showUsers = !_showUsers;
              });
            },
            tooltip: _showUsers ? 'Hide Users' : 'Show Users',
          ),
          // Listings Toggle
          IconButton(
            icon: Icon(
              _showListings ? Icons.home : Icons.home_outlined,
              color: LuxuryColors.primaryGold,
            ),
            onPressed: () {
              setState(() {
                _showListings = !_showListings;
              });
            },
            tooltip: _showListings ? 'Hide Listings' : 'Show Listings',
          ),
        ],
      ),
      body: FlutterMap(
        options: MapOptions(
          center: LatLng(20.5937, 78.9629), // Center of India
          zoom: 5.0,
        ),
        children: [
          // Base Tile Layer (changes based on map type)
          _buildTileLayer(),

          // User Markers (if enabled)
          if (_showUsers)
            MarkerLayer(
              markers: _buildUserMarkers(),
            ),

          // Housing Listing Markers (if enabled)
          if (_showListings)
            MarkerLayer(
              markers: _buildListingMarkers(),
            ),

          // Attribution Layer
          RichAttributionWidget(
            attributions: [
              TextSourceAttribution(
                _getAttribution(),
                onTap: () {},
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: _buildLegend(),
    );
  }

  TileLayer _buildTileLayer() {
    switch (_mapType) {
      case 'satellite':
        return TileLayer(
          urlTemplate: 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}',
          userAgentPackageName: 'com.zaryah.app',
          tileProvider: NetworkTileProvider(),
        );

      case 'light':
        return TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.zaryah.app',
          tileProvider: NetworkTileProvider(),
        );

      case 'dark':
      default:
        return TileLayer(
          urlTemplate: 'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}.png',
          subdomains: const ['a', 'b', 'c'],
          userAgentPackageName: 'com.zaryah.app',
          tileProvider: NetworkTileProvider(),
        );
    }
  }

  String _getAttribution() {
    switch (_mapType) {
      case 'satellite':
        return 'Esri, DigitalGlobe, GeoEye, Earthstar Geographics, CNES/Airbus DS, USDA, USGS, AeroGRID, IGN, and the GIS User Community';
      case 'light':
        return 'OpenStreetMap contributors';
      case 'dark':
      default:
        return 'CartoDB, OpenStreetMap contributors';
    }
  }

  List<Marker> _buildUserMarkers() {
    // TODO: Replace with actual user data from your service
    return [];
  }

  List<Marker> _buildListingMarkers() {
    // TODO: Replace with actual listing data from your service
    return [];
  }

  Widget _buildLegend() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LuxuryColors.cardGradient,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: LuxuryColors.borderGold),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Legend',
            style: LuxuryTextStyles.h3.copyWith(fontSize: 14),
          ),
          const SizedBox(height: 8),
          if (_showUsers)
            _buildLegendItem(
              Icons.person_pin_circle,
              'Users',
              LuxuryColors.primaryGold,
            ),
          if (_showListings)
            _buildLegendItem(
              Icons.home,
              'Housing',
              LuxuryColors.softGold,
            ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(IconData icon, String label, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 8),
          Text(
            label,
            style: LuxuryTextStyles.caption.copyWith(
              color: LuxuryColors.bodyText,
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// ALTERNATIVE SATELLITE PROVIDERS (FREE)
// ==========================================

class SatelliteProviders {
  // 1. ArcGIS World Imagery (High Quality, Free)
  static const arcgis = 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}';

  // 2. USGS Imagery (Good for US, Free)
  static const usgs = 'https://basemap.nationalmap.gov/arcgis/rest/services/USGSImageryOnly/MapServer/tile/{z}/{y}/{x}';

  // 3. Mapbox Satellite (Requires free API key)
  static String mapbox(String apiKey) =>
      'https://api.mapbox.com/v4/mapbox.satellite/{z}/{x}/{y}.png?access_token=$apiKey';

  // 4. Google Maps Satellite (Requires API key)
  static String google(String apiKey) =>
      'https://mt1.google.com/vt/lyrs=s&x={x}&y={y}&z={z}&key=$apiKey';
}

// ==========================================
// USAGE NOTES
// ==========================================

/*
1. Add to pubspec.yaml:
   dependencies:
     flutter_map: ^6.1.0
     latlong2: ^0.9.0

2. Run: flutter pub get

3. Replace existing map_screen.dart with this implementation

4. The satellite tiles work WITHOUT any API keys

5. For better satellite quality, you can:
   - Sign up for free Mapbox account (50k requests/month)
   - Use Google Maps API (requires billing, but $200 free credit)

6. Current implementation uses:
   - ArcGIS for satellite (FREE)
   - CartoDB for dark theme (FREE)
   - OpenStreetMap for light theme (FREE)

7. No CORS issues - all providers work from browser

8. Map automatically matches luxury black-gold theme
*/

import 'package:flutter/material.dart';
import '../models/housing_model.dart';
import '../services/housing_service.dart';
import '../theme/luxury_theme.dart';
import '../widgets/luxury_components.dart';
import 'housing_detail_screen.dart';
import 'create_housing_screen.dart';

class HousingListScreen extends StatefulWidget {
  const HousingListScreen({super.key});

  @override
  State<HousingListScreen> createState() => _HousingListScreenState();
}

class _HousingListScreenState extends State<HousingListScreen> {
  List<HousingListing> _listings = [];
  bool _isLoading = false;
  String _searchQuery = '';
  String? _selectedLocality;
  String? _selectedPropertyType;

  @override
  void initState() {
    super.initState();
    _loadListings();
  }

  Future<void> _loadListings() async {
    setState(() => _isLoading = true);
    try {
      final listings = await HousingService.getAllListings(
        locality: _selectedLocality,
        propertyType: _selectedPropertyType,
      );
      setState(() {
        _listings = listings;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading listings: $e')),
        );
      }
    }
  }

  Future<void> _searchListings(String query) async {
    if (query.isEmpty) {
      _loadListings();
      return;
    }

    setState(() => _isLoading = true);
    try {
      final listings = await HousingService.searchListings(query);
      setState(() {
        _listings = listings;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _showFilters() {
    showModalBottomSheet(
      context: context,
      backgroundColor: LuxuryColors.cardBackground,
      builder: (context) => _buildFilterSheet(),
    );
  }

  Widget _buildFilterSheet() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Filters',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: LuxuryColors.bodyText,
            ),
          ),
          const SizedBox(height: 20),
          DropdownButtonFormField<String>(
            value: _selectedPropertyType,
            decoration: const InputDecoration(labelText: 'Property Type'),
            dropdownColor: LuxuryColors.cardBackground,
            items: const [
              DropdownMenuItem(value: null, child: Text('All Types')),
              DropdownMenuItem(value: 'apartment', child: Text('Apartment')),
              DropdownMenuItem(value: 'house', child: Text('House')),
              DropdownMenuItem(value: 'villa', child: Text('Villa')),
              DropdownMenuItem(value: 'studio', child: Text('Studio')),
            ],
            onChanged: (value) {
              setState(() => _selectedPropertyType = value);
            },
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    setState(() {
                      _selectedPropertyType = null;
                      _selectedLocality = null;
                    });
                    Navigator.pop(context);
                    _loadListings();
                  },
                  child: const Text('Clear'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _loadListings();
                  },
                  child: const Text('Apply'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search by location...',
                      prefixIcon: const Icon(Icons.search, color: LuxuryColors.primaryGold),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                setState(() => _searchQuery = '');
                                _loadListings();
                              },
                            )
                          : null,
                    ),
                    onChanged: (value) {
                      setState(() => _searchQuery = value);
                      if (value.length > 2) {
                        _searchListings(value);
                      }
                    },
                  ),
                ),
                const SizedBox(width: 10),
                IconButton(
                  onPressed: _showFilters,
                  icon: const Icon(Icons.filter_list, color: LuxuryColors.primaryGold),
                  style: IconButton.styleFrom(
                    backgroundColor: LuxuryColors.cardBackground,
                  ),
                ),
              ],
            ),
          ),

          // Listings
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: LuxuryColors.primaryGold),
                  )
                : _listings.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        onRefresh: _loadListings,
                        color: LuxuryColors.primaryGold,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _listings.length,
                          itemBuilder: (context, index) {
                            return _buildListingCard(_listings[index]);
                          },
                        ),
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CreateHousingScreen()),
          ).then((_) => _loadListings());
        },
        backgroundColor: LuxuryColors.primaryGold,
        foregroundColor: Colors.black,
        icon: const Icon(Icons.add),
        label: const Text('Add Listing'),
      ),
    );
  }

  Widget _buildListingCard(HousingListing listing) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => HousingDetailScreen(listing: listing),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: LuxuryColors.cardBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: LuxuryColors.primaryGold.withOpacity(0.2)),
          boxShadow: [
            BoxShadow(
              color: LuxuryColors.primaryGold.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            if (listing.images.isNotEmpty)
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: Image.network(
                  listing.images.first,
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 180,
                    color: LuxuryColors.secondaryBackground,
                    child: const Icon(Icons.image, size: 64, color: LuxuryColors.mutedText),
                  ),
                ),
              ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title & Price
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          listing.title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: LuxuryColors.bodyText,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        listing.priceFormatted,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: LuxuryColors.primaryGold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Location
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 16, color: LuxuryColors.mutedText),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          listing.locality,
                          style: const TextStyle(color: LuxuryColors.mutedText),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Property Details
                  if (listing.propertyDetails.isNotEmpty)
                    Text(
                      listing.propertyDetails,
                      style: const TextStyle(
                        color: LuxuryColors.bodyText,
                        fontSize: 14,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.home_work, size: 80, color: LuxuryColors.mutedText.withOpacity(0.5)),
          const SizedBox(height: 16),
          const Text(
            'No housing listings found',
            style: TextStyle(
              fontSize: 18,
              color: LuxuryColors.mutedText,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Be the first to add a listing!',
            style: TextStyle(color: LuxuryColors.mutedText),
          ),
        ],
      ),
    );
  }
}

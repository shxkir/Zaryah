import 'package:flutter/material.dart';
import '../models/housing_model.dart';
import '../services/housing_service.dart';
import '../theme/luxury_theme.dart';
import '../widgets/luxury_components.dart';
import 'housing_detail_screen.dart';

class HousingFeedScreen extends StatefulWidget {
  const HousingFeedScreen({super.key});

  @override
  State<HousingFeedScreen> createState() => _HousingFeedScreenState();
}

class _HousingFeedScreenState extends State<HousingFeedScreen> {
  List<HousingListing> _listings = [];
  bool _isLoading = false;
  String? _errorMessage;
  final HousingService _housingService = HousingService();

  @override
  void initState() {
    super.initState();
    _loadFeed();
  }

  Future<void> _loadFeed() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final listings = await _housingService.getHousingFeed();
      setState(() {
        _listings = listings;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  Future<void> _onRefresh() async {
    await _loadFeed();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: GoldAppBar(
        title: 'Housing Feed',
        subtitle: 'New listings in your area',
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LuxuryColors.primaryGradient,
        ),
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading && _listings.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(
          color: LuxuryColors.primaryGold,
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: LuxuryColors.errorGold,
            ),
            const SizedBox(height: 16),
            Text(
              'Error loading feed',
              style: LuxuryTextStyles.h3,
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                _errorMessage!,
                style: LuxuryTextStyles.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 24),
            GoldButton(
              onPressed: _loadFeed,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_listings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.home_work_outlined,
              size: 64,
              color: LuxuryColors.mutedGold,
            ),
            const SizedBox(height: 16),
            Text(
              'No listings found',
              style: LuxuryTextStyles.h3,
            ),
            const SizedBox(height: 8),
            Text(
              'Check back later for new housing listings',
              style: LuxuryTextStyles.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _onRefresh,
      color: LuxuryColors.primaryGold,
      backgroundColor: LuxuryColors.cardBackground,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _listings.length,
        itemBuilder: (context, index) {
          return _buildListingCard(_listings[index]);
        },
      ),
    );
  }

  Widget _buildListingCard(HousingListing listing) {
    return GoldCard(
      margin: const EdgeInsets.only(bottom: 16),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => HousingDetailScreen(listing: listing),
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          if (listing.images.isNotEmpty)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: Image.network(
                listing.images.first,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 200,
                    color: LuxuryColors.cardBackground,
                    child: const Center(
                      child: Icon(
                        Icons.home_work,
                        size: 64,
                        color: LuxuryColors.mutedGold,
                      ),
                    ),
                  );
                },
              ),
            ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Price and Property Type
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      listing.priceFormatted,
                      style: LuxuryTextStyles.h3.copyWith(
                        color: LuxuryColors.primaryGold,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: LuxuryColors.secondaryBackground,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: LuxuryColors.borderGold,
                        ),
                      ),
                      child: Text(
                        listing.propertyType.toUpperCase(),
                        style: LuxuryTextStyles.label.copyWith(
                          color: LuxuryColors.softGold,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Title
                Text(
                  listing.title,
                  style: LuxuryTextStyles.h3,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 8),

                // Location
                Row(
                  children: [
                    const Icon(
                      Icons.location_on,
                      size: 16,
                      color: LuxuryColors.softGold,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        listing.locality,
                        style: LuxuryTextStyles.bodyMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Features (bedrooms, bathrooms, sqft)
                Row(
                  children: [
                    if (listing.bedrooms != null) ...[
                      _buildFeatureChip(
                        Icons.bed,
                        '${listing.bedrooms} BR',
                      ),
                      const SizedBox(width: 8),
                    ],
                    if (listing.bathrooms != null) ...[
                      _buildFeatureChip(
                        Icons.bathroom,
                        '${listing.bathrooms} BA',
                      ),
                      const SizedBox(width: 8),
                    ],
                    if (listing.squareFeet != null)
                      _buildFeatureChip(
                        Icons.square_foot,
                        '${listing.squareFeet} sqft',
                      ),
                  ],
                ),

                const SizedBox(height: 12),

                // Time posted and poster info
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.access_time,
                          size: 14,
                          color: LuxuryColors.mutedText,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          listing.timeAgo ?? 'Recently posted',
                          style: LuxuryTextStyles.caption.copyWith(
                            color: LuxuryColors.mutedText,
                          ),
                        ),
                      ],
                    ),
                    if (listing.user?.profile?.name != null)
                      Row(
                        children: [
                          Text(
                            'Posted by ',
                            style: LuxuryTextStyles.caption.copyWith(
                              color: LuxuryColors.mutedText,
                            ),
                          ),
                          Text(
                            listing.user!.profile!.name,
                            style: LuxuryTextStyles.caption.copyWith(
                              color: LuxuryColors.softGold,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: LuxuryColors.secondaryBackground,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: LuxuryColors.borderGold,
          width: 0.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: LuxuryColors.mutedGold,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: LuxuryTextStyles.caption.copyWith(
              color: LuxuryColors.bodyText,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

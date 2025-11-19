import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/housing_model.dart';
import '../theme/luxury_theme.dart';
import '../widgets/luxury_components.dart';

class HousingDetailScreen extends StatelessWidget {
  final HousingListing listing;

  const HousingDetailScreen({super.key, required this.listing});

  Future<void> _contactOwner() async {
    final Uri telUri = Uri(scheme: 'tel', path: listing.contactInfo);
    if (await canLaunchUrl(telUri)) {
      await launchUrl(telUri);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Property Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              // Share functionality
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Carousel
            _buildImageCarousel(),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title & Price
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          listing.title,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: LuxuryColors.bodyText,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: LuxuryColors.primaryGold.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: LuxuryColors.primaryGold),
                        ),
                        child: Text(
                          listing.priceFormatted,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: LuxuryColors.primaryGold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Location
                  Row(
                    children: [
                      const Icon(Icons.location_on, color: LuxuryColors.primaryGold),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          listing.fullAddress,
                          style: const TextStyle(
                            fontSize: 16,
                            color: LuxuryColors.mutedText,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Property Stats
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      if (listing.bedrooms != null)
                        _buildStatCard(
                          icon: Icons.bed,
                          label: '${listing.bedrooms} BHK',
                        ),
                      if (listing.bathrooms != null)
                        _buildStatCard(
                          icon: Icons.bathtub,
                          label: '${listing.bathrooms} Bath',
                        ),
                      if (listing.squareFeet != null)
                        _buildStatCard(
                          icon: Icons.square_foot,
                          label: '${listing.squareFeet} sqft',
                        ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Description
                  if (listing.description != null) ...[
                    const Text(
                      'Description',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: LuxuryColors.bodyText,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      listing.description!,
                      style: const TextStyle(
                        fontSize: 16,
                        color: LuxuryColors.bodyText,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Amenities
                  if (listing.amenities.isNotEmpty) ...[
                    const Text(
                      'Amenities',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: LuxuryColors.bodyText,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: listing.amenities.map((amenity) {
                        return Chip(
                          label: Text(amenity),
                          backgroundColor: LuxuryColors.cardBackground,
                          side: BorderSide(color: LuxuryColors.primaryGold.withOpacity(0.3)),
                          labelStyle: const TextStyle(color: LuxuryColors.bodyText),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Owner Info
                  if (listing.ownerName != null) ...[
                    const Text(
                      'Posted By',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: LuxuryColors.bodyText,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: LuxuryColors.cardBackground,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: LuxuryColors.primaryGold.withOpacity(0.2)),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 30,
                            backgroundColor: LuxuryColors.primaryGold.withOpacity(0.2),
                            child: listing.ownerProfilePicture != null
                                ? ClipOval(
                                    child: Image.network(
                                      listing.ownerProfilePicture!,
                                      width: 60,
                                      height: 60,
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                : const Icon(Icons.person, size: 30, color: LuxuryColors.primaryGold),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              listing.ownerName!,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: LuxuryColors.bodyText,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Contact Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _contactOwner,
                      icon: const Icon(Icons.phone),
                      label: const Text(
                        'Contact Owner',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
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

  Widget _buildImageCarousel() {
    if (listing.images.isEmpty) {
      return Container(
        height: 300,
        color: LuxuryColors.cardBackground,
        child: const Center(
          child: Icon(Icons.image, size: 80, color: LuxuryColors.mutedText),
        ),
      );
    }

    return SizedBox(
      height: 300,
      child: PageView.builder(
        itemCount: listing.images.length,
        itemBuilder: (context, index) {
          return Image.network(
            listing.images[index],
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              color: LuxuryColors.cardBackground,
              child: const Icon(Icons.broken_image, size: 80, color: LuxuryColors.mutedText),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatCard({required IconData icon, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: LuxuryColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: LuxuryColors.primaryGold.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: LuxuryColors.primaryGold, size: 28),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              color: LuxuryColors.bodyText,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

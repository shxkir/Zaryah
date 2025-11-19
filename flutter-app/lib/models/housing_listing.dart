class HousingListing {
  final String id;
  final String userId;
  final String title;
  final double monthlyPrice;
  final String locality;
  final String fullAddress;
  final double latitude;
  final double longitude;
  final List<String> images;
  final String contactInfo;
  final int? bedrooms;
  final int? bathrooms;
  final int? squareFeet;
  final String propertyType;
  final List<String> amenities;
  final String? description;
  final bool isActive;
  final DateTime createdAt;
  final String? ownerName;
  final String? ownerPicture;

  HousingListing({
    required this.id,
    required this.userId,
    required this.title,
    required this.monthlyPrice,
    required this.locality,
    required this.fullAddress,
    required this.latitude,
    required this.longitude,
    required this.images,
    required this.contactInfo,
    this.bedrooms,
    this.bathrooms,
    this.squareFeet,
    required this.propertyType,
    required this.amenities,
    this.description,
    required this.isActive,
    required this.createdAt,
    this.ownerName,
    this.ownerPicture,
  });

  factory HousingListing.fromJson(Map<String, dynamic> json) {
    return HousingListing(
      id: json['id'] as String,
      userId: json['userId'] as String,
      title: json['title'] as String,
      monthlyPrice: (json['monthlyPrice'] as num).toDouble(),
      locality: json['locality'] as String,
      fullAddress: json['fullAddress'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      images: (json['images'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      contactInfo: json['contactInfo'] as String,
      bedrooms: json['bedrooms'] as int?,
      bathrooms: json['bathrooms'] as int?,
      squareFeet: json['squareFeet'] as int?,
      propertyType: json['propertyType'] as String? ?? 'apartment',
      amenities: (json['amenities'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      description: json['description'] as String?,
      isActive: json['isActive'] as bool? ?? true,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      ownerName: json['user']?['profile']?['name'] as String?,
      ownerPicture: json['user']?['profile']?['displayPicture'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'monthlyPrice': monthlyPrice,
      'locality': locality,
      'fullAddress': fullAddress,
      'latitude': latitude,
      'longitude': longitude,
      'images': images,
      'contactInfo': contactInfo,
      'bedrooms': bedrooms,
      'bathrooms': bathrooms,
      'squareFeet': squareFeet,
      'propertyType': propertyType,
      'amenities': amenities,
      'description': description,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  String get priceFormatted => '₹${monthlyPrice.toStringAsFixed(0)}/month';

  String get propertyDetails {
    final parts = <String>[];
    if (bedrooms != null) parts.add('$bedrooms BHK');
    if (bathrooms != null) parts.add('$bathrooms Bath');
    if (squareFeet != null) parts.add('$squareFeet sq ft');
    return parts.join(' • ');
  }
}

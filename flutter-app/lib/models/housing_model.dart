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
  final DateTime updatedAt;

  // Owner info (populated from join)
  final String? ownerName;
  final String? ownerProfilePicture;

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
    required this.updatedAt,
    this.ownerName,
    this.ownerProfilePicture,
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
      images: (json['images'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
      contactInfo: json['contactInfo'] as String,
      bedrooms: json['bedrooms'] as int?,
      bathrooms: json['bathrooms'] as int?,
      squareFeet: json['squareFeet'] as int?,
      propertyType: json['propertyType'] as String? ?? 'apartment',
      amenities: (json['amenities'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
      description: json['description'] as String?,
      isActive: json['isActive'] as bool? ?? true,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      ownerName: json['user']?['profile']?['name'] as String?,
      ownerProfilePicture: json['user']?['profile']?['profilePicture'] as String?,
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
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  String get priceFormatted => '₹${monthlyPrice.toStringAsFixed(0)}/month';

  String get propertyDetails {
    final parts = <String>[];
    if (bedrooms != null) parts.add('$bedrooms BHK');
    if (bathrooms != null) parts.add('$bathrooms Bath');
    if (squareFeet != null) parts.add('$squareFeet sqft');
    return parts.join(' • ');
  }
}

class HousingStats {
  final int totalListings;
  final Map<String, int> listingsByLocality;
  final double? averagePrice;

  HousingStats({
    required this.totalListings,
    required this.listingsByLocality,
    this.averagePrice,
  });

  factory HousingStats.fromJson(Map<String, dynamic> json) {
    final byLocality = <String, int>{};
    if (json['listingsByLocality'] != null) {
      for (var item in json['listingsByLocality']) {
        byLocality[item['locality']] = item['_count'] as int;
      }
    }

    return HousingStats(
      totalListings: json['totalListings'] as int,
      listingsByLocality: byLocality,
      averagePrice: json['averagePrice'] != null
          ? (json['averagePrice'] as num).toDouble()
          : null,
    );
  }
}

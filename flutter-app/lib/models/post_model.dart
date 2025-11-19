import 'user_model.dart';

class PostModel {
  final String id;
  final String userId;
  final String? caption;
  final String imageUrl;
  final double? latitude;
  final double? longitude;
  final String? city;
  final String? country;
  final String privacy;
  final DateTime createdAt;
  final UserModel? user;

  PostModel({
    required this.id,
    required this.userId,
    this.caption,
    required this.imageUrl,
    this.latitude,
    this.longitude,
    this.city,
    this.country,
    this.privacy = 'everyone',
    required this.createdAt,
    this.user,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      id: json['id'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      caption: json['caption'] as String?,
      imageUrl: json['imageUrl'] as String? ?? '',
      latitude: json['latitude'] != null ? (json['latitude'] as num).toDouble() : null,
      longitude: json['longitude'] != null ? (json['longitude'] as num).toDouble() : null,
      city: json['city'] as String?,
      country: json['country'] as String?,
      privacy: json['privacy'] as String? ?? 'everyone',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      user: json['user'] != null
          ? UserModel.fromJson(json['user'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'caption': caption,
      'imageUrl': imageUrl,
      'latitude': latitude,
      'longitude': longitude,
      'city': city,
      'country': country,
      'privacy': privacy,
      'createdAt': createdAt.toIso8601String(),
      'user': user?.toJson(),
    };
  }
}

class UserModel {
  final String id;
  final String email;
  final ProfileModel? profile;
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.email,
    this.profile,
    required this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String? ?? '',
      email: json['email'] as String? ?? '',
      profile: json['profile'] != null
          ? ProfileModel.fromJson(json['profile'])
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'profile': profile?.toJson(),
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

class ProfileModel {
  final String id;
  final String name;
  final int age;
  final String? bio;
  final String? profilePicture;
  final String educationLevel;
  final String occupation;
  final String learningGoals;
  final List<String> subjects;
  final String learningStyle;
  final String previousExperience;
  final String strengths;
  final String weaknesses;
  final String specificChallenges;
  final int availableHoursPerWeek;
  final String learningPace;
  final String motivationLevel;
  final double? latitude;
  final double? longitude;
  final String? city;
  final String? state;
  final String? country;
  final String locationPrivacy;
  final String? profilePictureUrl; // Separate field for uploaded images

  ProfileModel({
    required this.id,
    required this.name,
    required this.age,
    this.bio,
    this.profilePicture,
    required this.educationLevel,
    required this.occupation,
    required this.learningGoals,
    required this.subjects,
    required this.learningStyle,
    required this.previousExperience,
    required this.strengths,
    required this.weaknesses,
    required this.specificChallenges,
    required this.availableHoursPerWeek,
    required this.learningPace,
    required this.motivationLevel,
    this.latitude,
    this.longitude,
    this.city,
    this.state,
    this.country,
    this.locationPrivacy = 'everyone',
    this.profilePictureUrl,
  });

  // Helper to get the best available profile picture
  String? get displayPicture => profilePictureUrl ?? profilePicture;

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? 'Unknown',
      age: json['age'] as int? ?? 0,
      bio: json['bio'] as String?,
      profilePicture: json['profilePicture'] as String?,
      educationLevel: json['educationLevel'] as String? ?? '',
      occupation: json['occupation'] as String? ?? '',
      learningGoals: json['learningGoals'] as String? ?? '',
      subjects: (json['subjects'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      learningStyle: json['learningStyle'] as String? ?? '',
      previousExperience: json['previousExperience'] as String? ?? '',
      strengths: json['strengths'] as String? ?? '',
      weaknesses: json['weaknesses'] as String? ?? '',
      specificChallenges: json['specificChallenges'] as String? ?? '',
      availableHoursPerWeek: json['availableHoursPerWeek'] as int? ?? 5,
      learningPace: json['learningPace'] as String? ?? 'Medium',
      motivationLevel: json['motivationLevel'] as String? ?? 'Medium',
      latitude: json['latitude'] != null ? (json['latitude'] as num).toDouble() : null,
      longitude: json['longitude'] != null ? (json['longitude'] as num).toDouble() : null,
      city: json['city'] as String?,
      state: json['state'] as String?,
      country: json['country'] as String?,
      locationPrivacy: json['locationPrivacy'] as String? ?? 'everyone',
      profilePictureUrl: json['profilePictureUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'age': age,
      'bio': bio,
      'profilePicture': profilePicture,
      'educationLevel': educationLevel,
      'occupation': occupation,
      'learningGoals': learningGoals,
      'subjects': subjects,
      'learningStyle': learningStyle,
      'previousExperience': previousExperience,
      'strengths': strengths,
      'weaknesses': weaknesses,
      'specificChallenges': specificChallenges,
      'availableHoursPerWeek': availableHoursPerWeek,
      'learningPace': learningPace,
      'motivationLevel': motivationLevel,
      'latitude': latitude,
      'longitude': longitude,
      'city': city,
      'state': state,
      'country': country,
      'locationPrivacy': locationPrivacy,
      'profilePictureUrl': profilePictureUrl,
    };
  }

  // Helper to get formatted location string
  String get formattedLocation {
    final parts = <String>[];
    if (city != null && city!.isNotEmpty) parts.add(city!);
    if (state != null && state!.isNotEmpty) parts.add(state!);
    if (country != null && country!.isNotEmpty) parts.add(country!);
    return parts.join(', ');
  }
}

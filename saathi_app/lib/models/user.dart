class SaathiUser {
  const SaathiUser({
    required this.id,
    required this.name,
    required this.phoneNumber,
    required this.isVerified,
    required this.rating,
    required this.helpedCount,
    required this.fcmToken,
    required this.latitude,
    required this.longitude,
  });

  final String id;
  final String name;
  final String phoneNumber;
  final bool isVerified;
  final double rating;
  final int helpedCount;
  final String fcmToken;
  final double latitude;
  final double longitude;

  SaathiUser copyWith({
    String? id,
    String? name,
    String? phoneNumber,
    bool? isVerified,
    double? rating,
    int? helpedCount,
    String? fcmToken,
    double? latitude,
    double? longitude,
  }) {
    return SaathiUser(
      id: id ?? this.id,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      isVerified: isVerified ?? this.isVerified,
      rating: rating ?? this.rating,
      helpedCount: helpedCount ?? this.helpedCount,
      fcmToken: fcmToken ?? this.fcmToken,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }

  factory SaathiUser.demo() {
    return const SaathiUser(
      id: 'victim_demo',
      name: 'Aarav Shrestha',
      phoneNumber: '+977 9800000000',
      isVerified: true,
      rating: 4.8,
      helpedCount: 23,
      fcmToken: 'demo-token',
      latitude: 27.7172,
      longitude: 85.3240,
    );
  }
}

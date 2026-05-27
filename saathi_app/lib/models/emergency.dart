enum EmergencyStatus { active, cancelled, resolved }

class EmergencyLocation {
  const EmergencyLocation({
    required this.latitude,
    required this.longitude,
    required this.accuracy,
  });

  final double latitude;
  final double longitude;
  final double accuracy;

  Map<String, dynamic> toJson() => {
        'lat': latitude,
        'lng': longitude,
        'accuracy': accuracy,
      };
}

class EmergencyEvent {
  const EmergencyEvent({
    required this.id,
    required this.userId,
    required this.location,
    required this.dangerLevel,
    required this.status,
    required this.createdAt,
    required this.nearbyResponderIds,
  });

  final String id;
  final String userId;
  final EmergencyLocation location;
  final int dangerLevel;
  final EmergencyStatus status;
  final DateTime createdAt;
  final List<String> nearbyResponderIds;

  EmergencyEvent copyWith({
    String? id,
    String? userId,
    EmergencyLocation? location,
    int? dangerLevel,
    EmergencyStatus? status,
    DateTime? createdAt,
    List<String>? nearbyResponderIds,
  }) {
    return EmergencyEvent(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      location: location ?? this.location,
      dangerLevel: dangerLevel ?? this.dangerLevel,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      nearbyResponderIds: nearbyResponderIds ?? this.nearbyResponderIds,
    );
  }

  Map<String, dynamic> toJson() => {
        'user_id': userId,
        'location': location.toJson(),
        'danger_level': dangerLevel,
        'status': status.name,
        'created_at': createdAt.toIso8601String(),
        'nearby_responder_ids': nearbyResponderIds,
      };
}

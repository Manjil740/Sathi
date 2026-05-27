enum ResponderRole { approach, callPolice, document }

class ResponderAssignment {
  const ResponderAssignment({
    required this.userId,
    required this.name,
    required this.distanceMeters,
    required this.role,
    required this.isComing,
  });

  final String userId;
  final String name;
  final double distanceMeters;
  final ResponderRole role;
  final bool isComing;

  ResponderAssignment copyWith({
    String? userId,
    String? name,
    double? distanceMeters,
    ResponderRole? role,
    bool? isComing,
  }) {
    return ResponderAssignment(
      userId: userId ?? this.userId,
      name: name ?? this.name,
      distanceMeters: distanceMeters ?? this.distanceMeters,
      role: role ?? this.role,
      isComing: isComing ?? this.isComing,
    );
  }
}

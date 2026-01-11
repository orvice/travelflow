class LocationMarker {
  final String id;
  final String name;
  final String? notes;
  final double latitude;
  final double longitude;
  final bool isFavorite;
  final DateTime createdAt;
  final DateTime updatedAt;

  LocationMarker({
    required this.id,
    required this.name,
    this.notes,
    required this.latitude,
    required this.longitude,
    this.isFavorite = false,
    required this.createdAt,
    required this.updatedAt,
  });

  factory LocationMarker.fromJson(Map<String, dynamic> json) {
    return LocationMarker(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      notes: json['notes'],
      latitude: (json['latitude'] ?? 0.0).toDouble(),
      longitude: (json['longitude'] ?? 0.0).toDouble(),
      isFavorite: json['isFavorite'] ?? false,
      createdAt:
          json['createdAt'] != null
              ? DateTime.parse(json['createdAt'])
              : DateTime.now(),
      updatedAt:
          json['updatedAt'] != null
              ? DateTime.parse(json['updatedAt'])
              : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'notes': notes,
      'latitude': latitude,
      'longitude': longitude,
      'isFavorite': isFavorite,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  LocationMarker copyWith({
    String? id,
    String? name,
    String? notes,
    double? latitude,
    double? longitude,
    bool? isFavorite,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return LocationMarker(
      id: id ?? this.id,
      name: name ?? this.name,
      notes: notes ?? this.notes,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      isFavorite: isFavorite ?? this.isFavorite,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LocationMarker &&
        other.id == id &&
        other.name == name &&
        other.notes == notes &&
        other.latitude == latitude &&
        other.longitude == longitude &&
        other.isFavorite == isFavorite &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      name,
      notes,
      latitude,
      longitude,
      isFavorite,
      createdAt,
      updatedAt,
    );
  }

  @override
  String toString() {
    return 'LocationMarker(id: $id, name: $name, notes: $notes, '
        'latitude: $latitude, longitude: $longitude, isFavorite: $isFavorite, '
        'createdAt: $createdAt, updatedAt: $updatedAt)';
  }
}

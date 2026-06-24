/// Represents the location coverage check response.
class LocationCoverageModel {
  final bool covered;
  final int? zoneId;
  final String? zoneName;
  final String? zoneType;

  const LocationCoverageModel({
    required this.covered,
    this.zoneId,
    this.zoneName,
    this.zoneType,
  });

  factory LocationCoverageModel.fromJson(Map<String, dynamic> json) {
    final zone = json['zone'] as Map<String, dynamic>?;
    return LocationCoverageModel(
      covered: json['covered'] as bool? ?? false,
      zoneId: zone?['id'] as int?,
      zoneName: zone?['name'] as String?,
      zoneType: zone?['type'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'covered': covered,
      if (zoneId != null || zoneName != null || zoneType != null)
        'zone': {
          if (zoneId != null) 'id': zoneId,
          if (zoneName != null) 'name': zoneName,
          if (zoneType != null) 'type': zoneType,
        },
    };
  }
}

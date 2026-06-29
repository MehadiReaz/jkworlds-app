class LocationPrediction {
  final String id;
  final String description;
  final String name;
  final String typeLabel;
  final String address;
  final double? latitude;
  final double? longitude;

  LocationPrediction({
    required this.id,
    required this.description,
    this.name = '',
    this.typeLabel = '',
    this.address = '',
    this.latitude,
    this.longitude,
  });

  factory LocationPrediction.fromJson(Map<String, dynamic> json) {
    // Handles Google Places, Mapbox, or custom database search returns
    final String idValue = (json['place_id'] ?? json['id'] ?? json['key'] ?? '').toString();
    
    final String descValue = (json['description'] ?? 
                              json['address'] ??
                              json['place_name'] ?? 
                              json['formatted_address'] ?? 
                              json['name'] ?? 
                              '').toString();

    final String nameValue = (json['name'] ?? '').toString();
    final String typeLabelValue = (json['type_label'] ?? json['type'] ?? '').toString();
    final String addressValue = (json['address'] ?? '').toString();

    final double? latValue = json['latitude'] is num
        ? (json['latitude'] as num).toDouble()
        : double.tryParse(json['latitude']?.toString() ?? '');
    final double? lngValue = json['longitude'] is num
        ? (json['longitude'] as num).toDouble()
        : json['lng'] is num
            ? (json['lng'] as num).toDouble()
            : double.tryParse((json['longitude'] ?? json['lng'])?.toString() ?? '');

    return LocationPrediction(
      id: idValue,
      description: descValue,
      name: nameValue.isNotEmpty ? nameValue : descValue,
      typeLabel: typeLabelValue,
      address: addressValue,
      latitude: latValue,
      longitude: lngValue,
    );
  }
}

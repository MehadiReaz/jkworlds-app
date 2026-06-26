class LocationPrediction {
  final String id;
  final String description;
  final String name;
  final String typeLabel;
  final String address;

  LocationPrediction({
    required this.id,
    required this.description,
    this.name = '',
    this.typeLabel = '',
    this.address = '',
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

    return LocationPrediction(
      id: idValue,
      description: descValue,
      name: nameValue.isNotEmpty ? nameValue : descValue,
      typeLabel: typeLabelValue,
      address: addressValue,
    );
  }
}

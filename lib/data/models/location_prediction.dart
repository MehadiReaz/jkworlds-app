class LocationPrediction {
  final String id;
  final String description;

  LocationPrediction({
    required this.id,
    required this.description,
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

    return LocationPrediction(
      id: idValue,
      description: descValue,
    );
  }
}

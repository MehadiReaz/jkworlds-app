/// Represents the detailed location schema returned by geocoding details API.
class LocationModel {
  final String id;
  final String name;
  final String type;
  final String typeLabel;
  final String address;
  final String city;
  final String country;
  final String countryCode;
  final double? latitude;
  final double? longitude;

  const LocationModel({
    required this.id,
    required this.name,
    this.type = '',
    this.typeLabel = '',
    this.address = '',
    this.city = '',
    this.country = '',
    this.countryCode = '',
    this.latitude,
    this.longitude,
  });

  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      type: (json['type'] ?? '').toString(),
      typeLabel: (json['type_label'] ?? '').toString(),
      address: (json['address'] ?? '').toString(),
      city: (json['city'] ?? '').toString(),
      country: (json['country'] ?? '').toString(),
      countryCode: (json['country_code'] ?? '').toString(),
      latitude: json['latitude'] is num
          ? (json['latitude'] as num).toDouble()
          : double.tryParse(json['latitude']?.toString() ?? ''),
      longitude: json['longitude'] is num
          ? (json['longitude'] as num).toDouble()
          : double.tryParse(json['longitude']?.toString() ?? ''),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'type_label': typeLabel,
      'address': address,
      'city': city,
      'country': country,
      'country_code': countryCode,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
    };
  }
}

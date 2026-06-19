/// Vehicle data model for car rental listings.
class VehicleModel {
  final String id;
  final String name;
  final String brand;
  final String type; // Sedan, SUV, Luxury, Van
  final int year;
  final String transmission; // Automatic, Manual
  final int seats;
  final String fuelType; // Petrol, Diesel, Hybrid, Electric
  final double pricePerDay; // in NGN
  final double pricePerWeek;
  final double pricePerMonth;
  final List<String> images;
  final List<String> features;
  final double rating;
  final int reviewCount;
  final bool isAvailable;
  final bool isFeatured;
  final bool hasChauffeur;
  final String location;
  final String description;

  // API extras
  final int? categoryId;
  final String? serviceType; // self-drive, chauffeur

  const VehicleModel({
    required this.id,
    required this.name,
    required this.brand,
    required this.type,
    required this.year,
    required this.transmission,
    required this.seats,
    required this.fuelType,
    required this.pricePerDay,
    required this.pricePerWeek,
    required this.pricePerMonth,
    required this.images,
    required this.features,
    required this.rating,
    required this.reviewCount,
    this.isAvailable = true,
    this.isFeatured = false,
    this.hasChauffeur = false,
    required this.location,
    required this.description,
    this.categoryId,
    this.serviceType,
  });

  factory VehicleModel.fromJson(Map<String, dynamic> json) {
    double _parseDouble(dynamic v) {
      if (v == null) return 0.0;
      if (v is double) return v;
      if (v is int) return v.toDouble();
      return double.tryParse(v.toString()) ?? 0.0;
    }

    int _parseInt(dynamic v) {
      if (v == null) return 0;
      if (v is int) return v;
      return int.tryParse(v.toString()) ?? 0;
    }

    // ── Nested objects from the real API ──────────────────────────
    // category: {id, name, slug}
    final categoryMap = json['category'] is Map<String, dynamic>
        ? json['category'] as Map<String, dynamic>
        : null;

    // specs: {seats, doors, transmission, transmission_label, fuel_type, fuel_type_label, mileage}
    final specsMap = json['specs'] is Map<String, dynamic>
        ? json['specs'] as Map<String, dynamic>
        : null;

    // rating: {average, count}
    final ratingMap = json['rating'] is Map<String, dynamic>
        ? json['rating'] as Map<String, dynamic>
        : null;

    // pricing: {daily_rate, daily_rate_formatted, total_price, currency, ...}
    final pricingMap = json['pricing'] is Map<String, dynamic>
        ? json['pricing'] as Map<String, dynamic>
        : null;

    // ── Images ────────────────────────────────────────────────────
    // Real API: single top-level 'image' URL string
    // Fallback: 'images' array (mock data)
    List<String> parseImages(dynamic v) {
      if (v == null) return [];
      if (v is List) return v.map((e) => e.toString()).toList();
      if (v is String && v.isNotEmpty) return [v];
      return [];
    }

    final images = parseImages(json['images'] ?? json['image']);

    // ── Features ──────────────────────────────────────────────────
    // Real API: [{id, name, icon}, ...]  →  extract 'name'
    // Fallback: ['string', ...]  (mock data)
    List<String> parseFeatures(dynamic v) {
      if (v == null) return [];
      if (v is List) {
        return v
            .map((e) => e is Map<String, dynamic>
                ? (e['name'] ?? e['label'] ?? '').toString()
                : e.toString())
            .where((s) => s.isNotEmpty)
            .toList();
      }
      if (v is String && v.isNotEmpty) return [v];
      return [];
    }

    // ── Derived fields ────────────────────────────────────────────
    // Vehicle type/category name: prefer nested category.name, then flat 'type'
    final vehicleType = categoryMap?['name'] as String?
        ?? json['type'] as String?
        ?? 'Sedan';

    // Transmission: prefer specs.transmission_label (human-readable)
    final transmission = specsMap?['transmission_label'] as String?
        ?? specsMap?['transmission'] as String?
        ?? json['transmission'] as String?
        ?? 'Automatic';

    // Seats: prefer specs.seats
    final seats = _parseInt(specsMap?['seats'] ?? json['seats'] ?? json['capacity']);

    // Fuel type: prefer specs.fuel_type_label
    final fuelType = specsMap?['fuel_type_label'] as String?
        ?? specsMap?['fuel_type'] as String?
        ?? json['fuel_type'] as String?
        ?? 'Petrol';

    // Pricing: prefer pricing.daily_rate, then flat daily_rate
    final pricePerDay = _parseDouble(
        pricingMap?['daily_rate'] ?? json['daily_rate'] ?? json['price_per_day']);
    final pricePerWeek = _parseDouble(
        pricingMap?['weekly_rate'] ?? json['weekly_rate'] ?? json['price_per_week']);
    final pricePerMonth = _parseDouble(
        pricingMap?['monthly_rate'] ?? json['monthly_rate'] ?? json['price_per_month']);

    // Rating: prefer rating.average
    final rating = _parseDouble(
        ratingMap?['average'] ?? json['rating'] ?? json['average_rating']);
    final reviewCount = _parseInt(
        ratingMap?['count'] ?? json['review_count'] ?? json['reviews_count']);

    // Category ID: prefer nested category.id, then flat category_id
    final categoryId = categoryMap?['id'] is int
        ? categoryMap!['id'] as int
        : int.tryParse(
            (categoryMap?['id'] ?? json['category_id'])?.toString() ?? '');

    // Service type (self_drive / chauffeur)
    final serviceType = json['service_type'] as String?;
    final hasChauffeur = serviceType == 'chauffeur' || _parseBool(json['has_chauffeur']);

    // Location: 'title' is the display name on this API; use as location fallback
    final location = json['location'] as String?
        ?? json['pickup_location'] as String?
        ?? '';

    return VehicleModel(
      id: (json['id'] ?? '').toString(),
      name: json['title'] as String?           // Real API uses 'title'
          ?? json['name'] as String?
          ?? '',
      brand: json['brand'] as String?
          ?? json['make'] as String?
          ?? '',
      type: vehicleType,
      year: _parseInt(json['year']),
      transmission: transmission,
      seats: seats,
      fuelType: fuelType,
      pricePerDay: pricePerDay,
      pricePerWeek: pricePerWeek,
      pricePerMonth: pricePerMonth,
      images: images,
      features: parseFeatures(json['features']),
      rating: rating,
      reviewCount: reviewCount,
      isAvailable: _parseBool(json['is_available'] ?? json['available'] ?? true),
      isFeatured: _parseBool(json['is_featured'] ?? json['featured']),
      hasChauffeur: hasChauffeur,
      location: location,
      description: json['description'] as String? ?? '',
      categoryId: categoryId,
      serviceType: serviceType,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'brand': brand,
        'type': type,
        'year': year,
        'transmission': transmission,
        'seats': seats,
        'fuel_type': fuelType,
        'daily_rate': pricePerDay,
        'weekly_rate': pricePerWeek,
        'monthly_rate': pricePerMonth,
        'images': images,
        'features': features,
        'rating': rating,
        'review_count': reviewCount,
        'is_available': isAvailable,
        'is_featured': isFeatured,
        'has_chauffeur': hasChauffeur,
        'location': location,
        'description': description,
        'category_id': categoryId,
        'service_type': serviceType,
      };
}

bool _parseBool(dynamic val) {
  if (val == null) return false;
  if (val is bool) return val;
  if (val is int) return val != 0;
  if (val is String) {
    final lower = val.toLowerCase();
    return lower == 'true' || lower == '1';
  }
  return false;
}

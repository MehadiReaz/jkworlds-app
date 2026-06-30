import 'package:get/get.dart';
import 'package:jkworlds/app/currency/currency_service.dart';
import 'protection_plan_model.dart';
import 'rental_addon_model.dart';
import 'unavailable_date_model.dart';
import 'service_pricing_model.dart';

export 'protection_plan_model.dart';
export 'service_pricing_model.dart';
export 'rental_addon_model.dart';
export 'unavailable_date_model.dart';

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
  final String currency;
  final String dailyRateFormatted;
  final double totalPrice;
  final String totalPriceFormatted;
  final double? taxesFees;
  final String? taxesFeesFormatted;

  // Dynamic details fields from new API
  final String? plateNumber;
  final int? mileage;
  final String? color;
  final List<String> gallery;
  final double? dailyRate;
  final double? weeklyRate;
  final double? monthlyRate;
  final double? chauffeurRatePerDay;
  final double? extraKmCharge;
  final double? overtimeChargePerHour;
  final double? securityDepositAmount;
  final String? securityDepositDescription;
  final String? cancellationTitle;
  final String? cancellationDescription;
  final List<String> mileagePolicies;
  final List<String> rentalRequirements;
  final List<String> includedItems;
  final List<ProtectionPlanModel> protectionPlans;
  final List<RentalAddonModel> rentalAddons;
  final List<UnavailableDateModel> unavailableDates;
  final ServicePricingModel? servicePricing;

  // Additional fields from response data
  final String slug;
  final String model;
  final String categoryName;
  final String categorySlug;
  final String serviceTypeLabel;
  final int doors;
  final String transmissionLabel;
  final String fuelTypeLabel;
  final bool additionalDriverEnabled;
  final String additionalDriverPriceType;
  final double additionalDriverPriceValue;
  final String additionalDriverPriceFormatted;
  final String weeklyRateFormatted;
  final String monthlyRateFormatted;
  final String chauffeurRatePerDayFormatted;
  final String extraKmChargeFormatted;
  final String overtimeChargePerHourFormatted;
  final String securityDepositAmountFormatted;

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
    this.currency = '',
    this.dailyRateFormatted = '',
    this.totalPrice = 0.0,
    this.totalPriceFormatted = '',
    this.taxesFees,
    this.taxesFeesFormatted,
    this.plateNumber,
    this.mileage,
    this.color,
    this.gallery = const [],
    this.dailyRate,
    this.weeklyRate,
    this.monthlyRate,
    this.chauffeurRatePerDay,
    this.extraKmCharge,
    this.overtimeChargePerHour,
    this.securityDepositAmount,
    this.securityDepositDescription,
    this.cancellationTitle,
    this.cancellationDescription,
    this.mileagePolicies = const [],
    this.rentalRequirements = const [],
    this.includedItems = const [],
    this.protectionPlans = const [],
    this.rentalAddons = const [],
    this.unavailableDates = const [],
    this.servicePricing,
    this.slug = '',
    this.model = '',
    this.categoryName = '',
    this.categorySlug = '',
    this.serviceTypeLabel = '',
    this.doors = 4,
    this.transmissionLabel = '',
    this.fuelTypeLabel = '',
    this.additionalDriverEnabled = false,
    this.additionalDriverPriceType = '',
    this.additionalDriverPriceValue = 0.0,
    this.additionalDriverPriceFormatted = '',
    this.weeklyRateFormatted = '',
    this.monthlyRateFormatted = '',
    this.chauffeurRatePerDayFormatted = '',
    this.extraKmChargeFormatted = '',
    this.overtimeChargePerHourFormatted = '',
    this.securityDepositAmountFormatted = '',
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

    // pricing_details: {daily_rate, weekly_rate, monthly_rate, ...}
    final pricingDetailsMap = json['pricing_details'] is Map<String, dynamic>
        ? json['pricing_details'] as Map<String, dynamic>
        : null;

    // ── Images ────────────────────────────────────────────────────
    // Real API: single top-level 'image' URL string or list in gallery
    // Fallback: 'images' array (mock data)
    List<String> parseImages(dynamic v) {
      if (v == null) return [];
      if (v is List) return v.map((e) => e.toString()).toList();
      if (v is String && v.isNotEmpty) return [v];
      return [];
    }

    var images = parseImages(json['gallery'] ?? json['images'] ?? json['image']);
    if (images.isEmpty && json['image'] != null) {
      final imgStr = json['image'].toString();
      if (imgStr.isNotEmpty) {
        images = [imgStr];
      }
    }

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

    // Pricing: prefer pricing_details.daily_rate, pricing.daily_rate, then flat daily_rate
    final currency = pricingMap?['currency'] as String? ?? pricingDetailsMap?['currency'] as String? ?? json['currency'] as String? ?? '';
    final dailyRateFormatted = pricingMap?['daily_rate_formatted'] as String? ?? pricingDetailsMap?['daily_rate_formatted'] as String? ?? json['daily_rate_formatted'] as String? ?? '';
    double scale = 1.0;
    if (currency.isNotEmpty) {
      if (Get.isRegistered<CurrencyService>()) {
        final curService = Get.find<CurrencyService>();
        final match = curService.currencies.firstWhereOrNull((c) => c.code.toUpperCase() == currency.toUpperCase());
        if (match != null && match.exchangeRate > 0) {
          scale = 1.0 / match.exchangeRate;
        } else if (currency.toUpperCase() == 'USD') {
          scale = 1600.0;
        }
      } else {
        if (currency.toUpperCase() == 'USD') {
          scale = 1600.0;
        }
      }
    }

    final pricePerDay = _parseDouble(
        pricingDetailsMap?['daily_rate'] ?? pricingMap?['daily_rate'] ?? json['daily_rate'] ?? json['price_per_day']) * scale;
    final totalPrice = _parseDouble(
        pricingMap?['total_price'] ?? json['total_price'] ?? pricingDetailsMap?['total_price'] ?? json['price_per_day']) * scale;
    final totalPriceFormatted = pricingMap?['total_price_formatted'] as String?
        ?? pricingDetailsMap?['total_price_formatted'] as String?
        ?? json['total_price_formatted'] as String?
        ?? '';
    final taxesFees = pricingMap != null && pricingMap['taxes_fees'] != null
        ? _parseDouble(pricingMap['taxes_fees']) * scale
        : null;
    final taxesFeesFormatted = pricingMap?['taxes_fees_formatted'] as String?;
    final pricePerWeek = _parseDouble(
        pricingDetailsMap?['weekly_rate'] ?? pricingMap?['weekly_rate'] ?? json['weekly_rate'] ?? json['price_per_week']) * scale;
    final pricePerMonth = _parseDouble(
        pricingDetailsMap?['monthly_rate'] ?? pricingMap?['monthly_rate'] ?? json['monthly_rate'] ?? json['price_per_month']) * scale;

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

    // Plate & mileage & color
    final plateNumber = json['plate_number'] as String?;
    final mileage = specsMap != null
        ? _parseInt(specsMap['mileage'] ?? json['mileage'])
        : _parseInt(json['mileage']);
    final color = json['color'] as String?;

    // Gallery
    final List<String> galleryList = [];
    if (json['gallery'] is List) {
      galleryList.addAll((json['gallery'] as List).map((e) => e.toString()));
    }

    // Pricing details mapping
    final chauffeurRatePerDay = pricingDetailsMap != null && pricingDetailsMap['chauffeur_rate_per_day'] != null
        ? _parseDouble(pricingDetailsMap['chauffeur_rate_per_day']) * scale
        : null;
    final extraKmCharge = pricingDetailsMap != null && pricingDetailsMap['extra_km_charge'] != null
        ? _parseDouble(pricingDetailsMap['extra_km_charge']) * scale
        : null;
    final overtimeChargePerHour = pricingDetailsMap != null && pricingDetailsMap['overtime_charge_per_hour'] != null
        ? _parseDouble(pricingDetailsMap['overtime_charge_per_hour']) * scale
        : null;

    // Security deposit details
    final secDepMap = json['security_deposit'] is Map<String, dynamic>
        ? json['security_deposit'] as Map<String, dynamic>
        : null;
    final securityDepositAmount = secDepMap != null && secDepMap['amount'] != null
        ? _parseDouble(secDepMap['amount']) * scale
        : (pricingDetailsMap != null && pricingDetailsMap['security_deposit'] != null
            ? _parseDouble(pricingDetailsMap['security_deposit']) * scale
            : null);
    final securityDepositDescription = secDepMap?['description'] as String?;

    // Cancellation details
    final cancellationMap = json['cancellation'] is Map<String, dynamic>
        ? json['cancellation'] as Map<String, dynamic>
        : null;
    final cancellationTitle = cancellationMap?['title'] as String?;
    final cancellationDescription = cancellationMap?['description'] as String?;

    // New properties
    final slug = json['slug'] as String? ?? '';
    final model = json['model'] as String?
        ?? (json['vehicle_model'] is Map<String, dynamic> ? json['vehicle_model']['name'] as String? : null)
        ?? '';
    final categoryName = categoryMap?['name'] as String? ?? json['category_name'] as String? ?? '';
    final categorySlug = categoryMap?['slug'] as String? ?? json['category_slug'] as String? ?? '';
    final serviceTypeLabel = json['service_type_label'] as String? ?? '';
    final doors = _parseInt(specsMap?['doors'] ?? json['doors']);
    final transmissionLabel = specsMap?['transmission_label'] as String? ?? json['transmission_label'] as String? ?? '';
    final fuelTypeLabel = specsMap?['fuel_type_label'] as String? ?? json['fuel_type_label'] as String? ?? '';

    final additionalDriverMap = json['additional_driver'] is Map<String, dynamic>
        ? json['additional_driver'] as Map<String, dynamic>
        : null;
    final additionalDriverEnabled = _parseBool(additionalDriverMap?['enabled'] ?? json['additional_driver_enabled']);
    final additionalDriverPriceType = additionalDriverMap?['price_type'] as String? ?? '';
    final additionalDriverPriceValue = _parseDouble(additionalDriverMap?['price_value'] ?? json['additional_driver_price']) * scale;
    final additionalDriverPriceFormatted = additionalDriverMap?['price_value_formatted'] as String? ?? '';

    final weeklyRateFormatted = pricingDetailsMap?['weekly_rate_formatted'] as String? ?? '';
    final monthlyRateFormatted = pricingDetailsMap?['monthly_rate_formatted'] as String? ?? '';
    final chauffeurRatePerDayFormatted = pricingDetailsMap?['chauffeur_rate_per_day_formatted'] as String? ?? '';
    final extraKmChargeFormatted = pricingDetailsMap?['extra_km_charge_formatted'] as String? ?? '';
    final overtimeChargePerHourFormatted = pricingDetailsMap?['overtime_charge_per_hour_formatted'] as String? ?? '';
    final securityDepositAmountFormatted = secDepMap?['amount_formatted'] as String? ?? pricingDetailsMap?['security_deposit_formatted'] as String? ?? '';

    // Lists of strings/objects
    List<String> parseStringList(dynamic v) {
      if (v is List) {
        return v
            .map((e) => e is Map<String, dynamic>
                ? (e['title'] ?? e['name'] ?? '').toString()
                : e.toString())
            .where((s) => s.isNotEmpty)
            .toList();
      }
      return [];
    }

    final mileagePolicies = parseStringList(json['mileage_policies']);
    final rentalRequirements = parseStringList(json['rental_requirements']);
    final includedItems = parseStringList(json['included_items']);

    // Protection plans
    final List<ProtectionPlanModel> protectionPlans = [];
    if (json['protection_plans'] is List) {
      for (final item in json['protection_plans'] as List) {
        if (item is Map<String, dynamic>) {
          protectionPlans.add(ProtectionPlanModel.fromJson(item, scale: scale));
        }
      }
    }

    // Rental Addons
    final List<RentalAddonModel> rentalAddons = [];
    if (json['rental_addons'] is List) {
      for (final item in json['rental_addons'] as List) {
        if (item is Map<String, dynamic>) {
          rentalAddons.add(RentalAddonModel.fromJson(item, scale: scale));
        }
      }
    }

    // Unavailable dates
    final List<UnavailableDateModel> unavailableDates = [];
    if (json['unavailable_dates'] is List) {
      for (final item in json['unavailable_dates'] as List) {
        if (item is Map<String, dynamic>) {
          unavailableDates.add(UnavailableDateModel.fromJson(item));
        }
      }
    }

    final servicePricingMap = json['service_pricing'] is Map<String, dynamic>
        ? json['service_pricing'] as Map<String, dynamic>
        : null;
    final servicePricing = servicePricingMap != null
        ? ServicePricingModel.fromJson(servicePricingMap)
        : null;

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
      plateNumber: plateNumber,
      mileage: mileage,
      color: color,
      gallery: galleryList,
      dailyRate: pricePerDay,
      weeklyRate: pricePerWeek,
      monthlyRate: pricePerMonth,
      chauffeurRatePerDay: chauffeurRatePerDay,
      extraKmCharge: extraKmCharge,
      overtimeChargePerHour: overtimeChargePerHour,
      securityDepositAmount: securityDepositAmount,
      securityDepositDescription: securityDepositDescription,
      cancellationTitle: cancellationTitle,
      cancellationDescription: cancellationDescription,
      mileagePolicies: mileagePolicies,
      rentalRequirements: rentalRequirements,
      includedItems: includedItems,
      protectionPlans: protectionPlans,
      rentalAddons: rentalAddons,
      unavailableDates: unavailableDates,
      servicePricing: servicePricing,
      currency: currency,
      dailyRateFormatted: dailyRateFormatted,
      totalPrice: totalPrice,
      totalPriceFormatted: totalPriceFormatted,
      taxesFees: taxesFees,
      taxesFeesFormatted: taxesFeesFormatted,
      slug: slug,
      model: model,
      categoryName: categoryName,
      categorySlug: categorySlug,
      serviceTypeLabel: serviceTypeLabel,
      doors: doors,
      transmissionLabel: transmissionLabel,
      fuelTypeLabel: fuelTypeLabel,
      additionalDriverEnabled: additionalDriverEnabled,
      additionalDriverPriceType: additionalDriverPriceType,
      additionalDriverPriceValue: additionalDriverPriceValue,
      additionalDriverPriceFormatted: additionalDriverPriceFormatted,
      weeklyRateFormatted: weeklyRateFormatted,
      monthlyRateFormatted: monthlyRateFormatted,
      chauffeurRatePerDayFormatted: chauffeurRatePerDayFormatted,
      extraKmChargeFormatted: extraKmChargeFormatted,
      overtimeChargePerHourFormatted: overtimeChargePerHourFormatted,
      securityDepositAmountFormatted: securityDepositAmountFormatted,
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
        'currency': currency,
        'daily_rate_formatted': dailyRateFormatted,
        'total_price': totalPrice,
        'total_price_formatted': totalPriceFormatted,
        'taxes_fees': taxesFees,
        'taxes_fees_formatted': taxesFeesFormatted,
        'plate_number': plateNumber,
        'mileage': mileage,
        'color': color,
        'gallery': gallery,
        'chauffeur_rate_per_day': chauffeurRatePerDay,
        'extra_km_charge': extraKmCharge,
        'overtime_charge_per_hour': overtimeChargePerHour,
        'security_deposit_amount': securityDepositAmount,
        'security_deposit_description': securityDepositDescription,
        'cancellation_title': cancellationTitle,
        'cancellation_description': cancellationDescription,
        'mileage_policies': mileagePolicies,
        'rental_requirements': rentalRequirements,
        'included_items': includedItems,
        'protection_plans': protectionPlans.map((e) => e.toJson()).toList(),
        'rental_addons': rentalAddons.map((e) => e.toJson()).toList(),
        'unavailable_dates': unavailableDates.map((e) => e.toJson()).toList(),
        'slug': slug,
        'model': model,
        'category_name': categoryName,
        'category_slug': categorySlug,
        'service_type_label': serviceTypeLabel,
        'doors': doors,
        'transmission_label': transmissionLabel,
        'fuel_type_label': fuelTypeLabel,
        'additional_driver_enabled': additionalDriverEnabled,
        'additional_driver_price_type': additionalDriverPriceType,
        'additional_driver_price_value': additionalDriverPriceValue,
        'additional_driver_price_formatted': additionalDriverPriceFormatted,
        'weekly_rate_formatted': weeklyRateFormatted,
        'monthly_rate_formatted': monthlyRateFormatted,
        'chauffeur_rate_per_day_formatted': chauffeurRatePerDayFormatted,
        'extra_km_charge_formatted': extraKmChargeFormatted,
        'overtime_charge_per_hour_formatted': overtimeChargePerHourFormatted,
        'security_deposit_amount_formatted': securityDepositAmountFormatted,
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

import 'package:jkworlds/data/services/category_service.dart';
import 'package:jkworlds/data/services/booking_service.dart';
import 'package:jkworlds/data/services/location_service.dart';
import 'package:jkworlds/data/models/category_model.dart';
import 'package:jkworlds/data/models/vehicle_model.dart';
import 'package:jkworlds/data/models/booking_model.dart';
import 'package:jkworlds/data/models/location_prediction.dart';
import 'package:jkworlds/data/models/location_coverage_model.dart';
import 'package:jkworlds/data/mock/mock_vehicles.dart';
import 'package:jkworlds/data/mock/mock_bookings.dart';
import 'package:jkworlds/data/models/airport_transfer_distance_model.dart';
import 'package:jkworlds/data/models/checkout_pricing_model.dart';

class MockCategoryService extends CategoryService {
  MockCategoryService() {
    categories.value = [
      const CategoryModel(id: 1, name: 'Sedan', slug: 'sedan', type: 'sedan', status: true),
      const CategoryModel(id: 2, name: 'SUV', slug: 'suv', type: 'suv', status: true),
      const CategoryModel(id: 3, name: 'Luxury', slug: 'luxury', type: 'luxury', status: true),
      const CategoryModel(id: 4, name: 'Van', slug: 'van', type: 'van', status: true),
    ];
  }

  @override
  Future<List<CategoryModel>> fetchCategories({bool forceRefresh = false}) async {
    return categories;
  }

  @override
  Future<List<VehicleModel>> fetchAllVehicles({
    String? search,
    String? serviceType,
    String? transmission,
    String? fuelType,
    String? featured,
    String? sort,
    int? page,
    int? perPage,
    double? pickupLatitude,
    double? pickupLongitude,
    double? dropoffLatitude,
    double? dropoffLongitude,
    bool forceRefresh = false,
  }) async {
    var results = List<VehicleModel>.from(mockVehicles);
    
    if (search != null && search.trim().isNotEmpty) {
      final loc = search.toLowerCase();
      results = results.where((v) =>
          v.location.toLowerCase().contains(loc) ||
          v.brand.toLowerCase().contains(loc) ||
          v.name.toLowerCase().contains(loc)).toList();
    }
    
    if (serviceType != null && serviceType.isNotEmpty) {
      if (serviceType == 'chauffeur') {
        results = results.where((v) => v.hasChauffeur).toList();
      }
    }
    
    if (transmission != null && transmission.isNotEmpty) {
      results = results.where((v) => v.transmission.toLowerCase() == transmission.toLowerCase()).toList();
    }
    
    if (fuelType != null && fuelType.isNotEmpty) {
      results = results.where((v) => v.fuelType.toLowerCase() == fuelType.toLowerCase()).toList();
    }
    
    if (sort != null) {
      if (sort == 'rating') {
        results.sort((a, b) => b.rating.compareTo(a.rating));
      } else if (sort == 'price_asc') {
        results.sort((a, b) => a.pricePerDay.compareTo(b.pricePerDay));
      } else if (sort == 'price_desc') {
        results.sort((a, b) => b.pricePerDay.compareTo(a.pricePerDay));
      }
    }

    if (page != null && perPage != null) {
      final startIndex = (page - 1) * perPage;
      if (startIndex >= results.length) {
        return [];
      }
      final endIndex = (startIndex + perPage).clamp(0, results.length);
      return results.sublist(startIndex, endIndex);
    }
    
    return results;
  }

  @override
  Future<List<VehicleModel>> fetchVehiclesByCategory(
    int categoryId, {
    String? search,
    String? category,
    String? serviceType,
    String? transmission,
    String? fuelType,
    String? featured,
    String? sort,
    int? page,
    int? perPage,
    double? pickupLatitude,
    double? pickupLongitude,
    double? dropoffLatitude,
    double? dropoffLongitude,
  }) async {
    final catName = categoryId == 1
        ? 'Sedan'
        : categoryId == 2
            ? 'SUV'
            : categoryId == 3
                ? 'Luxury'
                : 'Van';
    var results = mockVehicles.where((v) => v.type.toLowerCase() == catName.toLowerCase()).toList();
    
    if (search != null && search.trim().isNotEmpty) {
      final loc = search.toLowerCase();
      results = results.where((v) =>
          v.location.toLowerCase().contains(loc) ||
          v.brand.toLowerCase().contains(loc) ||
          v.name.toLowerCase().contains(loc)).toList();
    }
    
    if (serviceType != null && serviceType.isNotEmpty) {
      if (serviceType == 'chauffeur') {
        results = results.where((v) => v.hasChauffeur).toList();
      }
    }
    
    if (transmission != null && transmission.isNotEmpty) {
      results = results.where((v) => v.transmission.toLowerCase() == transmission.toLowerCase()).toList();
    }
    
    if (fuelType != null && fuelType.isNotEmpty) {
      results = results.where((v) => v.fuelType.toLowerCase() == fuelType.toLowerCase()).toList();
    }
    
    if (sort != null) {
      if (sort == 'rating') {
        results.sort((a, b) => b.rating.compareTo(a.rating));
      } else if (sort == 'price_asc') {
        results.sort((a, b) => a.pricePerDay.compareTo(b.pricePerDay));
      } else if (sort == 'price_desc') {
        results.sort((a, b) => b.pricePerDay.compareTo(a.pricePerDay));
      }
    }

    if (page != null && perPage != null) {
      final startIndex = (page - 1) * perPage;
      if (startIndex >= results.length) {
        return [];
      }
      final endIndex = (startIndex + perPage).clamp(0, results.length);
      return results.sublist(startIndex, endIndex);
    }
    
    return results;
  }

  @override
  Future<VehicleDetailResult> fetchVehicleDetail(
    dynamic vehicleId, {
    String? serviceType,
    double? pickupLatitude,
    double? pickupLongitude,
    double? dropoffLatitude,
    double? dropoffLongitude,
  }) async {
    final vehicle = mockVehicles.firstWhere(
      (v) => v.id.toString() == vehicleId.toString(),
      orElse: () => mockVehicles.first,
    );
    final detailedVehicle = VehicleModel(
      id: vehicle.id,
      name: vehicle.name,
      brand: vehicle.brand,
      type: vehicle.type,
      year: vehicle.year,
      transmission: vehicle.transmission,
      seats: vehicle.seats,
      fuelType: vehicle.fuelType,
      pricePerDay: vehicle.pricePerDay,
      pricePerWeek: vehicle.pricePerWeek,
      pricePerMonth: vehicle.pricePerMonth,
      images: vehicle.images,
      features: vehicle.features,
      rating: vehicle.rating,
      reviewCount: vehicle.reviewCount,
      isAvailable: vehicle.isAvailable,
      isFeatured: vehicle.isFeatured,
      hasChauffeur: vehicle.hasChauffeur,
      location: vehicle.location,
      description: vehicle.description,
      categoryId: vehicle.categoryId,
      serviceType: vehicle.serviceType,
      currency: vehicle.currency,
      dailyRateFormatted: vehicle.dailyRateFormatted,
      totalPrice: vehicle.totalPrice,
      totalPriceFormatted: vehicle.totalPriceFormatted,
      plateNumber: vehicle.plateNumber ?? 'LG-890-IKJ',
      mileage: vehicle.mileage ?? 9500,
      color: vehicle.color ?? 'Black',
      gallery: vehicle.gallery,
      dailyRate: vehicle.dailyRate,
      weeklyRate: vehicle.weeklyRate,
      monthlyRate: vehicle.monthlyRate,
      chauffeurRatePerDay: vehicle.chauffeurRatePerDay,
      extraKmCharge: vehicle.extraKmCharge,
      overtimeChargePerHour: vehicle.overtimeChargePerHour,
      securityDepositAmount: vehicle.securityDepositAmount,
      securityDepositDescription: vehicle.securityDepositDescription,
      cancellationTitle: vehicle.cancellationTitle,
      cancellationDescription: vehicle.cancellationDescription,
      mileagePolicies: vehicle.mileagePolicies,
      rentalRequirements: vehicle.rentalRequirements,
      includedItems: vehicle.includedItems,
      protectionPlans: vehicle.protectionPlans,
      rentalAddons: vehicle.rentalAddons,
      unavailableDates: vehicle.unavailableDates,
      slug: vehicle.slug,
      model: vehicle.model,
      categoryName: vehicle.categoryName,
      categorySlug: vehicle.categorySlug,
      serviceTypeLabel: vehicle.serviceTypeLabel,
      doors: vehicle.doors,
      transmissionLabel: vehicle.transmissionLabel,
      fuelTypeLabel: vehicle.fuelTypeLabel,
      additionalDriverEnabled: vehicle.additionalDriverEnabled,
      additionalDriverPriceType: vehicle.additionalDriverPriceType,
      additionalDriverPriceValue: vehicle.additionalDriverPriceValue,
      additionalDriverPriceFormatted: vehicle.additionalDriverPriceFormatted,
      weeklyRateFormatted: vehicle.weeklyRateFormatted,
      monthlyRateFormatted: vehicle.monthlyRateFormatted,
      chauffeurRatePerDayFormatted: vehicle.chauffeurRatePerDayFormatted,
      extraKmChargeFormatted: vehicle.extraKmChargeFormatted,
      overtimeChargePerHourFormatted: vehicle.overtimeChargePerHourFormatted,
      securityDepositAmountFormatted: vehicle.securityDepositAmountFormatted,
    );
    return VehicleDetailResult(
      vehicle: detailedVehicle,
      similarVehicles: mockVehicles.where((v) => v.type == vehicle.type && v.id != vehicle.id).toList(),
      reviews: [],
    );
  }
}

class MockBookingService extends BookingService {
  @override
  Future<List<BookingModel>> fetchBookings() async {
    return mockBookings;
  }

  @override
  Future<BookingModel> fetchBookingDetail(int id) async {
    return mockBookings.firstWhere(
      (b) => b.id.contains(id.toString()) || int.tryParse(b.id) == id,
      orElse: () => mockBookings.first,
    );
  }

  @override
  Future<AirportTransferDistanceModel> fetchAirportTransferDistance({
    required double pickupLatitude,
    required double pickupLongitude,
    required double dropoffLatitude,
    required double dropoffLongitude,
    int? vehicleId,
  }) async {
    return const AirportTransferDistanceModel(
      currency: 'USD',
      distance: DistanceDetails(
        method: 'haversine',
        rawKm: 10.8,
        billableKm: 10.8,
        minBillableKm: 1,
      ),
    );
  }

  @override
  Future<CheckoutPricingModel> calculateCheckoutPricing(Map<String, dynamic> data) async {
    final int? protectionId = data['protection_plan_id'] as int?;
    final List<dynamic>? addonIdsRaw = data['addon_ids'] as List<dynamic>?;
    final List<int> addonIds = addonIdsRaw?.map((e) => int.tryParse(e.toString()) ?? 0).toList() ?? [];

    double subtotal = 110000.0;
    double protectionCost = 0.0;
    String protectionTitle = 'Basic Protection';

    if (protectionId == 2) {
      protectionCost = subtotal * 0.15;
      protectionTitle = 'Premium Protection';
    } else if (protectionId == 3) {
      protectionCost = subtotal * 0.25;
      protectionTitle = 'Full Protection';
    }

    double addonsCost = 0.0;
    if (addonIds.contains(1)) {
      addonsCost += 5000.0 * 2; // GPS Navigation
    }
    if (addonIds.contains(2)) {
      addonsCost += 8000.0 * 2; // Additional Driver
    }

    double fees = 5500.0;
    double deposit = 100000.0;
    double total = subtotal + protectionCost + addonsCost + fees + deposit;

    String formatPrice(double amount) {
      if (amount == 0.0) return '₦0';
      final str = amount.round().toString();
      if (str.length > 3) {
        final left = str.substring(0, str.length - 3);
        final right = str.substring(str.length - 3);
        return '₦$left,$right';
      }
      return '₦$str';
    }

    return CheckoutPricingModel(
      currency: 'NGN',
      serviceType: 'self_drive',
      rentalDays: 2,
      base: CheckoutPricingItem(amount: subtotal, amountFormatted: formatPrice(subtotal)),
      addonsTotal: CheckoutPricingItem(amount: addonsCost, amountFormatted: formatPrice(addonsCost)),
      protection: CheckoutPricingItem(
        amount: protectionCost,
        amountFormatted: protectionCost > 0 ? formatPrice(protectionCost) : '₦0',
        title: protectionCost > 0 ? protectionTitle : null,
      ),
      feesTotal: CheckoutPricingItem(amount: fees, amountFormatted: formatPrice(fees)),
      discount: const CheckoutPricingItem(amount: 0.0, amountFormatted: '₦0'),
      total: CheckoutPricingItem(amount: total, amountFormatted: formatPrice(total)),
      payableTotal: CheckoutPricingItem(amount: total, amountFormatted: formatPrice(total)),
      deposit: CheckoutPricingItem(amount: deposit, amountFormatted: formatPrice(deposit)),
      addons: const [],
      fees: const [],
      paymentMethods: const [],
    );
  }
}

class MockLocationService extends LocationService {
  @override
  Future<List<LocationPrediction>> searchLocations(String query, {int? limit}) async {
    final suggestions = <LocationPrediction>[
      LocationPrediction(description: 'Lekki Phase 1, Lagos', id: 'lekki_1'),
      LocationPrediction(description: 'Lekki Toll Gate, Lagos', id: 'lekki_2'),
      LocationPrediction(description: 'Victoria Island, Lagos', id: 'vi_1'),
      LocationPrediction(description: 'Maitama, Abuja', id: 'maitama_1'),
    ];
    return suggestions
        .where((p) => p.description.toLowerCase().contains(query.toLowerCase()))
        .take(limit ?? 5)
        .toList();
  }

  @override
  Future<LocationCoverageModel> checkCoverage({
    required double lat,
    required double lng,
    required String serviceType,
  }) async {
    return const LocationCoverageModel(covered: true);
  }
}

import 'package:get/get.dart';
import 'package:jkworlds/data/models/vehicle_model.dart';
import 'package:jkworlds/data/mock/mock_vehicles.dart';

class ExploreController extends GetxController {
  // ── Search Form States ──────────────────────────────────────────
  final pickupLocation = ''.obs;
  final isDifferentDropoff = false.obs;
  final dropoffLocation = ''.obs;
  final pickupDateTime = Rxn<DateTime>();
  final dropoffDateTime = Rxn<DateTime>();
  final isChauffeurRequired = false.obs;

  // ── Filter & Sort States ────────────────────────────────────────
  final selectedServiceType = 'All'.obs;      // All, Self-Drive, Chauffeur
  final selectedCategory = 'All'.obs;         // All, Sedan, SUV, Luxury, Van
  final selectedTransmission = 'All'.obs;     // All, Automatic, Manual
  final selectedFuelType = 'All'.obs;         // All, Petrol, Diesel, Hybrid, Electric
  final selectedSortType = 'Top Rated'.obs;   // Top Rated, Price: Low to High, Price: High to Low

  // ── Results State ───────────────────────────────────────────────
  final filteredVehicles = <VehicleModel>[].obs;

  // ── Filter Lists ────────────────────────────────────────────────
  final serviceTypes = const ['All', 'Self-Drive', 'Chauffeur'];
  final categories = const ['All', 'Sedan', 'SUV', 'Luxury', 'Van'];
  final transmissions = const ['All', 'Automatic', 'Manual'];
  final fuelTypes = const ['All', 'Petrol', 'Diesel', 'Hybrid', 'Electric'];
  final sortTypes = const ['Top Rated', 'Price: Low to High', 'Price: High to Low'];

  @override
  void onInit() {
    super.onInit();
    applyFilters();
  }

  /// Reset all search inputs, date-times, filters, and sorting choices.
  void clearFilters() {
    pickupLocation.value = '';
    isDifferentDropoff.value = false;
    dropoffLocation.value = '';
    pickupDateTime.value = null;
    dropoffDateTime.value = null;
    isChauffeurRequired.value = false;

    selectedServiceType.value = 'All';
    selectedCategory.value = 'All';
    selectedTransmission.value = 'All';
    selectedFuelType.value = 'All';
    selectedSortType.value = 'Top Rated';

    applyFilters();
  }

  /// Trigger the filtering rules based on active user configurations.
  void applyFilters() {
    var results = List<VehicleModel>.from(mockVehicles);

    // 1. Pick-up Location Filter (fuzzy matches location or brand/name)
    if (pickupLocation.value.isNotEmpty) {
      final loc = pickupLocation.value.toLowerCase();
      results = results.where((v) =>
          v.location.toLowerCase().contains(loc) ||
          v.brand.toLowerCase().contains(loc) ||
          v.name.toLowerCase().contains(loc)).toList();
    }

    // 2. Chauffeur Availability Check
    if (isChauffeurRequired.value) {
      results = results.where((v) => v.hasChauffeur).toList();
    }

    // 3. Service Type Filter
    if (selectedServiceType.value == 'Chauffeur') {
      results = results.where((v) => v.hasChauffeur).toList();
    }

    // 4. Category (Type) Filter
    if (selectedCategory.value != 'All') {
      results = results.where((v) => v.type == selectedCategory.value).toList();
    }

    // 5. Transmission Filter
    if (selectedTransmission.value != 'All') {
      results = results.where((v) => v.transmission == selectedTransmission.value).toList();
    }

    // 6. Fuel Type Filter
    if (selectedFuelType.value != 'All') {
      results = results.where((v) => v.fuelType == selectedFuelType.value).toList();
    }

    // 7. Sort Order
    switch (selectedSortType.value) {
      case 'Price: Low to High':
        results.sort((a, b) => a.pricePerDay.compareTo(b.pricePerDay));
        break;
      case 'Price: High to Low':
        results.sort((a, b) => b.pricePerDay.compareTo(a.pricePerDay));
        break;
      case 'Top Rated':
      default:
        results.sort((a, b) => b.rating.compareTo(a.rating));
        break;
    }

    filteredVehicles.value = results;
  }
}

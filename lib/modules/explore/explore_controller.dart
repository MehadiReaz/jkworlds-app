import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jkworlds/data/models/vehicle_model.dart';
import 'package:jkworlds/data/services/category_service.dart';
import 'package:jkworlds/data/services/location_service.dart';
import 'package:jkworlds/data/models/location_prediction.dart';

class ExploreController extends GetxController {
  // ── Search Form States ──────────────────────────────────────────
  final pickupLocation = ''.obs;
  final isDifferentDropoff = false.obs;
  final dropoffLocation = ''.obs;
  final pickupDateTime = Rxn<DateTime>();
  final dropoffDateTime = Rxn<DateTime>();
  final isChauffeurRequired = false.obs;

  // Controllers for text inputs
  final pickupLocationCtrl = TextEditingController();
  final dropoffLocationCtrl = TextEditingController();

  // ── Location Autocomplete States ──────────────────────────────
  final pickupSuggestions = <LocationPrediction>[].obs;
  final dropoffSuggestions = <LocationPrediction>[].obs;
  final isLoadingPickup = false.obs;
  final isLoadingDropoff = false.obs;

  LocationService get _locationService => Get.find<LocationService>();

  // ── Filter & Sort States ────────────────────────────────────────
  final selectedServiceType = 'All'.obs;      // All, Self-Drive, Chauffeur
  final selectedCategory = 'All'.obs;         // All, Sedan, SUV, Luxury, Van
  final selectedTransmission = 'All'.obs;     // All, Automatic, Manual
  final selectedFuelType = 'All'.obs;         // All, Petrol, Diesel, Hybrid, Electric
  final selectedSortType = 'Top Rated'.obs;   // Top Rated, Price: Low to High, Price: High to Low

  // ── Results State ───────────────────────────────────────────────
  final filteredVehicles = <VehicleModel>[].obs;
  final isLoading = false.obs;
  final errorMessage = ''.obs;

  // ── Filter Lists ────────────────────────────────────────────────
  final serviceTypes = const ['All', 'Self-Drive', 'Chauffeur'];
  final categories = const ['All', 'Sedan', 'SUV', 'Luxury', 'Van'];
  final transmissions = const ['All', 'Automatic', 'Manual'];
  final fuelTypes = const ['All', 'Petrol', 'Diesel', 'Hybrid', 'Electric'];
  final sortTypes = const ['Top Rated', 'Price: Low to High', 'Price: High to Low'];

  CategoryService get _categoryService => Get.find<CategoryService>();

  @override
  void onInit() {
    super.onInit();

    // Debounce location search queries to avoid hitting API too frequently
    debounce(pickupLocation, (val) => _fetchPickupSuggestions(val), time: const Duration(milliseconds: 500));
    debounce(dropoffLocation, (val) => _fetchDropoffSuggestions(val), time: const Duration(milliseconds: 500));

    applyFilters();
  }

  @override
  void onClose() {
    pickupLocationCtrl.dispose();
    dropoffLocationCtrl.dispose();
    super.onClose();
  }

  /// Reset all search inputs, date-times, filters, and sorting choices.
  void clearFilters() {
    pickupLocationCtrl.clear();
    dropoffLocationCtrl.clear();
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
    pickupSuggestions.clear();
    dropoffSuggestions.clear();

    applyFilters();
  }

  /// Trigger the filtering rules — fetches from API with server-side filter
  /// params, then applies any remaining client-side filters.
  Future<void> applyFilters() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final cats = _categoryService.categories;

      if (cats.isNotEmpty) {
        // Build query params for the API
        final serviceType = selectedServiceType.value == 'All'
            ? null
            : selectedServiceType.value.toLowerCase().replaceAll('-', '_');
        final transmission = selectedTransmission.value == 'All'
            ? null
            : selectedTransmission.value;
        final fuelType = selectedFuelType.value == 'All'
            ? null
            : selectedFuelType.value;
        final sort = _buildSortParam(selectedSortType.value);
        final search = pickupLocation.value.isNotEmpty ? pickupLocation.value : null;

        // Determine target category and fetch appropriately
        List<VehicleModel> results;
        if (selectedCategory.value != 'All') {
          final targetCat = cats.firstWhereOrNull(
            (c) => c.name.toLowerCase() == selectedCategory.value.toLowerCase(),
          );
          if (targetCat != null) {
            results = await _categoryService.fetchVehiclesByCategory(
              targetCat.id,
              search: search,
              serviceType: serviceType,
              transmission: transmission,
              fuelType: fuelType,
              sort: sort,
            );
          } else {
            // Fallback to fetch all and filter by type client-side
            results = await _categoryService.fetchAllVehicles(
              search: search,
              serviceType: serviceType,
              transmission: transmission,
              fuelType: fuelType,
              sort: sort,
            );
            results = results
                .where((v) => v.type.toLowerCase() == selectedCategory.value.toLowerCase())
                .toList();
          }
        } else {
          results = await _categoryService.fetchAllVehicles(
            search: search,
            serviceType: serviceType,
            transmission: transmission,
            fuelType: fuelType,
            sort: sort,
          );
        }

        // Client-side chauffeur filter
        if (isChauffeurRequired.value || selectedServiceType.value == 'Chauffeur') {
          results = results.where((v) => v.hasChauffeur).toList();
        }

        filteredVehicles.value = results;
      }} catch (_) {
        
      } finally {
        isLoading.value = false;
      }
    }
  

  String? _buildSortParam(String sortType) {
    switch (sortType) {
      case 'Price: Low to High':
        return 'price_asc';
      case 'Price: High to Low':
        return 'price_desc';
      case 'Top Rated':
        return 'rating';
      default:
        return null;
    }
  }

  /// Pure client-side fallback filtering on mock data.
  // void _applyClientSideFilters() {
  //   var results = List<VehicleModel>.from(mockVehicles);

  //   // 1. Pick-up Location Filter (fuzzy matches location or brand/name)
  //   if (pickupLocation.value.isNotEmpty) {
  //     final loc = pickupLocation.value.toLowerCase();
  //     results = results.where((v) =>
  //         v.location.toLowerCase().contains(loc) ||
  //         v.brand.toLowerCase().contains(loc) ||
  //         v.name.toLowerCase().contains(loc)).toList();
  //   }

  //   // 2. Chauffeur Availability Check
  //   if (isChauffeurRequired.value) {
  //     results = results.where((v) => v.hasChauffeur).toList();
  //   }

  //   // 3. Service Type Filter
  //   if (selectedServiceType.value == 'Chauffeur') {
  //     results = results.where((v) => v.hasChauffeur).toList();
  //   }

  //   // 4. Category (Type) Filter
  //   if (selectedCategory.value != 'All') {
  //     results = results.where((v) => v.type == selectedCategory.value).toList();
  //   }

  //   // 5. Transmission Filter
  //   if (selectedTransmission.value != 'All') {
  //     results = results.where((v) => v.transmission == selectedTransmission.value).toList();
  //   }

  //   // 6. Fuel Type Filter
  //   if (selectedFuelType.value != 'All') {
  //     results = results.where((v) => v.fuelType == selectedFuelType.value).toList();
  //   }

  //   // 7. Sort Order
  //   switch (selectedSortType.value) {
  //     case 'Price: Low to High':
  //       results.sort((a, b) => a.pricePerDay.compareTo(b.pricePerDay));
  //       break;
  //     case 'Price: High to Low':
  //       results.sort((a, b) => b.pricePerDay.compareTo(a.pricePerDay));
  //       break;
  //     case 'Top Rated':
  //     default:
  //       results.sort((a, b) => b.rating.compareTo(a.rating));
  //       break;
  //   }

  //   filteredVehicles.value = results;
  // }

  Future<void> _fetchPickupSuggestions(String query) async {
    if (query.trim().isEmpty) {
      pickupSuggestions.clear();
      return;
    }
    isLoadingPickup.value = true;
    try {
      final results = await _locationService.searchLocations(query, limit: 5);
      pickupSuggestions.assignAll(results);
    } catch (_) {
      pickupSuggestions.clear();
    } finally {
      isLoadingPickup.value = false;
    }
  }

  Future<void> _fetchDropoffSuggestions(String query) async {
    if (query.trim().isEmpty) {
      dropoffSuggestions.clear();
      return;
    }
    isLoadingDropoff.value = true;
    try {
      final results = await _locationService.searchLocations(query, limit: 5);
      dropoffSuggestions.assignAll(results);
    } catch (_) {
      dropoffSuggestions.clear();
    } finally {
      isLoadingDropoff.value = false;
    }
  }

  void selectPickupSuggestion(LocationPrediction suggestion) {
    pickupLocationCtrl.text = suggestion.description;
    pickupLocation.value = suggestion.description;
    pickupSuggestions.clear();
    applyFilters();
  }

  void selectDropoffSuggestion(LocationPrediction suggestion) {
    dropoffLocationCtrl.text = suggestion.description;
    dropoffLocation.value = suggestion.description;
    dropoffSuggestions.clear();
    applyFilters();
  }
}

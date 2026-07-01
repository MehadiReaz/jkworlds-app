import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jkworlds/data/models/vehicle_model.dart';
import 'package:jkworlds/data/services/category_service.dart';
import 'package:jkworlds/data/services/location_service.dart';
import 'package:jkworlds/data/models/location_prediction.dart';
import 'package:jkworlds/app/currency/currency_service.dart';
import 'package:jkworlds/core/utils/logger.dart';

class ExploreController extends GetxController {
  // ── Search Form States ──────────────────────────────────────────
  final pickupLocation = ''.obs;
  final isDifferentDropoff = false.obs;
  final dropoffLocation = ''.obs;
  final pickupDateTime = Rxn<DateTime>();
  final dropoffDateTime = Rxn<DateTime>();
  final isChauffeurRequired = false.obs;

  final selectedPickupPrediction = Rxn<LocationPrediction>();
  final selectedDropoffPrediction = Rxn<LocationPrediction>();

  // Controllers for text inputs
  final pickupLocationCtrl = TextEditingController();
  final dropoffLocationCtrl = TextEditingController();

  // Timers for search debouncing
  Timer? _pickupDebounceTimer;
  Timer? _dropoffDebounceTimer;

  // ── Location Autocomplete States ──────────────────────────────
  final pickupSuggestions = <LocationPrediction>[].obs;
  final dropoffSuggestions = <LocationPrediction>[].obs;
  final isLoadingPickup = false.obs;
  final isLoadingDropoff = false.obs;

  LocationService get _locationService => Get.find<LocationService>();

  // ── Filter & Sort States ────────────────────────────────────────
  final selectedBookingTab = 'Cars'.obs; // Cars, Airport Transfer
  final selectedServiceType = 'All'.obs; // All, Self-Drive, Chauffeur
  final selectedCategory = 'All'.obs; // All, Sedan, SUV, Luxury, Van
  final selectedTransmission = 'All'.obs; // All, Automatic, Manual
  final selectedFuelType = 'All'.obs; // All, Petrol, Diesel, Hybrid, Electric
  final selectedSortType =
      'Top Rated'.obs; // Top Rated, Price: Low to High, Price: High to Low

  // ── Results State ───────────────────────────────────────────────
  final filteredVehicles = <VehicleModel>[].obs;
  final isLoading = false.obs;
  final errorMessage = ''.obs;

  // ── Pagination States ───────────────────────────────────────────
  final currentPage = 1.obs;
  final hasNextPage = true.obs;
  final isLoadMoreLoading = false.obs;
  static const int _perPage = 10;
  final scrollController = ScrollController();

  // ── Filter Lists ────────────────────────────────────────────────
  final serviceTypes = const ['All', 'Self-Drive', 'Chauffeur', 'Airport Transfer'];
  final categories = <String>[].obs;
  final transmissions = const ['All', 'Automatic', 'Manual'];
  final fuelTypes = const ['All', 'Petrol', 'Diesel', 'Hybrid', 'Electric'];
  final sortTypes = const [
    'Top Rated',
    'Price: Low to High',
    'Price: High to Low',
  ];

  CategoryService get _categoryService => Get.find<CategoryService>();

  @override
  void onInit() {
    super.onInit();

    // Populate categories dynamically from CategoryService
    categories.assignAll([
      'All',
      ..._categoryService.categories.map((c) => c.name),
    ]);
    ever(_categoryService.categories, (catsList) {
      categories.assignAll(['All', ...catsList.map((c) => c.name)]);
    });

    if (_categoryService.categories.isEmpty) {
      _categoryService.fetchCategories();
    }

    // Scroll listener for pagination
    scrollController.addListener(() {
      if (scrollController.position.pixels >=
          scrollController.position.maxScrollExtent - 200) {
        applyFilters(isLoadMore: true);
      }
    });

    if (Get.isRegistered<CurrencyService>()) {
      ever(Get.find<CurrencyService>().selectedCurrency, (_) {
        applyFilters();
      });
    }

    applyFilters();
    if (selectedPickupPrediction.value != null) {
      _checkCoverage(selectedPickupPrediction.value, isPickup: true);
    }
    if (selectedDropoffPrediction.value != null) {
      _checkCoverage(selectedDropoffPrediction.value, isPickup: false);
    }
  }

  @override
  void onClose() {
    _pickupDebounceTimer?.cancel();
    _dropoffDebounceTimer?.cancel();
    pickupLocationCtrl.dispose();
    dropoffLocationCtrl.dispose();
    scrollController.dispose();
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
    selectedPickupPrediction.value = null;
    selectedDropoffPrediction.value = null;

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
  /// params, then applies any remaining client-side filters. Support pagination.
  Future<void> applyFilters({bool isLoadMore = false}) async {
    if (isLoadMore) {
      if (isLoadMoreLoading.value || !hasNextPage.value) return;
      isLoadMoreLoading.value = true;
    } else {
      isLoading.value = true;
      currentPage.value = 1;
      hasNextPage.value = true;
    }
    errorMessage.value = '';

    if (selectedServiceType.value != 'Chauffeur') {
      isDifferentDropoff.value = false;
      dropoffLocation.value = '';
      dropoffLocationCtrl.clear();
    }

    try {
      final cats = _categoryService.categories;

      double? pickupLat;
      double? pickupLng;
      double? dropoffLat;
      double? dropoffLng;

      if (selectedPickupPrediction.value != null) {
        try {
          final details = await _locationService.fetchLocationDetails(
            selectedPickupPrediction.value!.id,
          );
          pickupLat =
              details?.latitude ?? selectedPickupPrediction.value?.latitude;
          pickupLng =
              details?.longitude ?? selectedPickupPrediction.value?.longitude;
        } catch (e) {
          logger.e(
            '[ExploreController] Error resolving pickup coordinates: $e',
          );
        }
      }

      if (isDifferentDropoff.value && selectedDropoffPrediction.value != null) {
        try {
          final details = await _locationService.fetchLocationDetails(
            selectedDropoffPrediction.value!.id,
          );
          dropoffLat =
              details?.latitude ?? selectedDropoffPrediction.value?.latitude;
          dropoffLng =
              details?.longitude ?? selectedDropoffPrediction.value?.longitude;
        } catch (e) {
          logger.e(
            '[ExploreController] Error resolving dropoff coordinates: $e',
          );
        }
      } else {
        dropoffLat = pickupLat;
        dropoffLng = pickupLng;
      }

      // Build query params for the API
      final serviceType = selectedServiceType.value == 'All'
          ? null
          : selectedServiceType.value.toLowerCase().replaceAll('-', '_').replaceAll(' ', '_');
      final transmission = selectedTransmission.value == 'All'
          ? null
          : selectedTransmission.value;
      final fuelType = selectedFuelType.value == 'All'
          ? null
          : selectedFuelType.value;
      final sort = _buildSortParam(selectedSortType.value);
      final search = pickupLocation.value.isNotEmpty
          ? pickupLocation.value
          : null;

      // Determine target category and fetch appropriately
      List<VehicleModel> results;
      if (selectedCategory.value != 'All' && cats.isNotEmpty) {
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
            page: currentPage.value,
            perPage: _perPage,
            pickupLatitude: pickupLat,
            pickupLongitude: pickupLng,
            dropoffLatitude: dropoffLat,
            dropoffLongitude: dropoffLng,
          );
        } else {
          // Fallback to fetch all and filter by type client-side
          results = await _categoryService.fetchAllVehicles(
            search: search,
            serviceType: serviceType,
            transmission: transmission,
            fuelType: fuelType,
            sort: sort,
            page: currentPage.value,
            perPage: _perPage,
            pickupLatitude: pickupLat,
            pickupLongitude: pickupLng,
            dropoffLatitude: dropoffLat,
            dropoffLongitude: dropoffLng,
          );
          results = results
              .where(
                (v) =>
                    v.type.toLowerCase() ==
                    selectedCategory.value.toLowerCase(),
              )
              .toList();
        }
      } else {
        results = await _categoryService.fetchAllVehicles(
          search: search,
          serviceType: serviceType,
          transmission: transmission,
          fuelType: fuelType,
          sort: sort,
          page: currentPage.value,
          perPage: _perPage,
          pickupLatitude: pickupLat,
          pickupLongitude: pickupLng,
          dropoffLatitude: dropoffLat,
          dropoffLongitude: dropoffLng,
        );
      }

      // Client-side chauffeur filter
      if (isChauffeurRequired.value ||
          selectedServiceType.value == 'Chauffeur') {
        results = results.where((v) => v.hasChauffeur).toList();
      }

      if (isLoadMore) {
        if (results.isEmpty) {
          hasNextPage.value = false;
        } else {
          filteredVehicles.addAll(results);
          currentPage.value++;
          if (results.length < _perPage) {
            hasNextPage.value = false;
          }
        }
      } else {
        filteredVehicles.assignAll(results);
        if (results.length < _perPage) {
          hasNextPage.value = false;
        } else {
          currentPage.value++;
        }
      }
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      if (isLoadMore) {
        isLoadMoreLoading.value = false;
      } else {
        isLoading.value = false;
      }
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

  void updatePickupLocation(String val) {
    pickupLocation.value = val;
    _pickupDebounceTimer?.cancel();
    _pickupDebounceTimer = Timer(const Duration(milliseconds: 500), () {
      _fetchPickupSuggestions(val);
    });
  }

  void updateDropoffLocation(String val) {
    dropoffLocation.value = val;
    _dropoffDebounceTimer?.cancel();
    _dropoffDebounceTimer = Timer(const Duration(milliseconds: 500), () {
      _fetchDropoffSuggestions(val);
    });
  }

  void _showLocationNotAvailableDialog() {
    if (Get.context == null ||
        Platform.environment.containsKey('FLUTTER_TEST')) {
      debugPrint('[CoverageCheck] Showed Location Not Available Dialog');
      return;
    }

    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        icon: Icon(
          Icons.location_off_rounded,
          color: Get.theme.colorScheme.error,
          size: 28,
        ),
        title: const Text('Location Not Covered'),
        titleTextStyle: Get.theme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w600,
        ),
        content: const Text(
          'Sorry, our services are not available in the selected location at this time. Please choose another location.',
        ),
        contentTextStyle: Get.theme.textTheme.bodyMedium?.copyWith(
          color: Get.theme.colorScheme.onSurfaceVariant,
          height: 1.4,
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            style: TextButton.styleFrom(
              foregroundColor: Get.theme.colorScheme.primary,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text(
              'OK',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _checkCoverage(
    LocationPrediction? prediction, {
    required bool isPickup,
  }) async {
    if (prediction == null) return;

    final controller = isPickup ? pickupLocationCtrl : dropoffLocationCtrl;
    final locationVal = isPickup ? pickupLocation : dropoffLocation;
    final predictionVal = isPickup
        ? selectedPickupPrediction
        : selectedDropoffPrediction;
    final loadingVal = isPickup ? isLoadingPickup : isLoadingDropoff;

    loadingVal.value = true;
    try {
      final details = await _locationService.fetchLocationDetails(
        prediction.id,
      );
      final double? lat = details?.latitude ?? prediction.latitude;
      final double? lng = details?.longitude ?? prediction.longitude;
      if (lat != null && lng != null) {
        final bool isAirportTab = selectedBookingTab.value == 'Airport Transfer';
        final sType = isAirportTab || selectedServiceType.value == 'Airport Transfer'
            ? 'airport_transfer'
            : (selectedServiceType.value == 'Self-Drive'
                ? 'self_drive'
                : (selectedServiceType.value == 'Chauffeur' ? 'chauffeur' : 'self_drive'));
        final coverage = await _locationService.checkCoverage(
          lat: lat,
          lng: lng,
          serviceType: sType,
        );
        if (!coverage.covered) {
          _showLocationNotAvailableDialog();
          controller.clear();
          locationVal.value = '';
          predictionVal.value = null;
        }
      }
    } catch (e) {
      logger.e('Coverage check failed: $e');
    } finally {
      loadingVal.value = false;
      applyFilters();
    }
  }

  void selectPickupSuggestion(LocationPrediction suggestion) async {
    pickupSuggestions.clear();
    pickupLocationCtrl.text = suggestion.name;
    pickupLocation.value = suggestion.name;
    selectedPickupPrediction.value = suggestion;
    await _checkCoverage(suggestion, isPickup: true);
  }

  void selectDropoffSuggestion(LocationPrediction suggestion) async {
    dropoffSuggestions.clear();
    dropoffLocationCtrl.text = suggestion.name;
    dropoffLocation.value = suggestion.name;
    selectedDropoffPrediction.value = suggestion;
    await _checkCoverage(suggestion, isPickup: false);
  }
}

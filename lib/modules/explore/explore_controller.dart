import 'package:get/get.dart';

import 'package:jkworlds/data/models/vehicle_model.dart';
import 'package:jkworlds/data/mock/mock_vehicles.dart';

class ExploreController extends GetxController {
  final searchQuery = ''.obs;
  final selectedType = 'All'.obs;
  final selectedTransmission = 'All'.obs;
  final sortOption = 'sort_rating'.obs;
  final hasChauffeurFilter = false.obs;
  final filteredVehicles = <VehicleModel>[].obs;

  final types = const ['All', 'Sedan', 'SUV', 'Luxury', 'Van'];
  final transmissions = const ['All', 'Automatic', 'Manual'];

  @override
  void onInit() {
    super.onInit();
    applyFilters();
  }

  void updateSearch(String query) {
    searchQuery.value = query;
    applyFilters();
  }

  void selectType(String type) {
    selectedType.value = type;
    applyFilters();
  }

  void selectTransmission(String transmission) {
    selectedTransmission.value = transmission;
    applyFilters();
  }

  void toggleChauffeurFilter() {
    hasChauffeurFilter.value = !hasChauffeurFilter.value;
    applyFilters();
  }

  void changeSortOption(String option) {
    sortOption.value = option;
    applyFilters();
  }

  void clearFilters() {
    searchQuery.value = '';
    selectedType.value = 'All';
    selectedTransmission.value = 'All';
    hasChauffeurFilter.value = false;
    sortOption.value = 'sort_rating';
    applyFilters();
  }

  void applyFilters() {
    var results = List<VehicleModel>.from(mockVehicles);

    // Search
    if (searchQuery.value.isNotEmpty) {
      final q = searchQuery.value.toLowerCase();
      results = results.where((v) =>
          v.name.toLowerCase().contains(q) ||
          v.brand.toLowerCase().contains(q) ||
          v.type.toLowerCase().contains(q) ||
          v.location.toLowerCase().contains(q)).toList();
    }

    // Type filter
    if (selectedType.value != 'All') {
      results = results.where((v) => v.type == selectedType.value).toList();
    }

    // Transmission filter
    if (selectedTransmission.value != 'All') {
      results = results.where((v) => v.transmission == selectedTransmission.value).toList();
    }

    // Chauffeur filter
    if (hasChauffeurFilter.value) {
      results = results.where((v) => v.hasChauffeur).toList();
    }

    // Sort
    switch (sortOption.value) {
      case 'sort_rating':
        results.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case 'sort_newest':
        results.sort((a, b) => b.year.compareTo(a.year));
        break;
      case 'sort_price_low':
        results.sort((a, b) => a.pricePerDay.compareTo(b.pricePerDay));
        break;
      case 'sort_price_high':
        results.sort((a, b) => b.pricePerDay.compareTo(a.pricePerDay));
        break;
    }

    filteredVehicles.value = results;
  }
}

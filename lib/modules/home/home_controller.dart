import 'package:get/get.dart';

import 'package:jkworlds/data/models/vehicle_model.dart';
import 'package:jkworlds/data/mock/mock_vehicles.dart';

class HomeController extends GetxController {
  final featuredVehicles = <VehicleModel>[].obs;
  final popularVehicles = <VehicleModel>[].obs;
  final selectedCategory = 'All'.obs;

  final categories = const ['All', 'Sedan', 'SUV', 'Luxury', 'Van'];

  @override
  void onInit() {
    super.onInit();
    _loadData();
  }

  void _loadData() {
    featuredVehicles.value =
        mockVehicles.where((v) => v.isFeatured).toList();
    _filterPopular();
  }

  void selectCategory(String category) {
    selectedCategory.value = category;
    _filterPopular();
  }

  void _filterPopular() {
    if (selectedCategory.value == 'All') {
      popularVehicles.value = mockVehicles;
    } else {
      popularVehicles.value = mockVehicles
          .where((v) => v.type == selectedCategory.value)
          .toList();
    }
  }

  /// Greeting based on time of day.
  String get greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'good_morning'.tr;
    if (hour < 17) return 'good_afternoon'.tr;
    return 'good_evening'.tr;
  }
}

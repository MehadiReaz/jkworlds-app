import 'package:get/get.dart';

import 'package:jkworlds/data/models/vehicle_model.dart';
import 'package:jkworlds/data/models/review_model.dart';
import 'package:jkworlds/data/mock/mock_reviews.dart';

class VehicleDetailController extends GetxController {
  late final VehicleModel vehicle;
  final reviews = <ReviewModel>[].obs;
  final selectedPriceTab = 0.obs; // 0=daily, 1=weekly, 2=monthly
  final isSelfDrive = true.obs;
  final isWishlisted = false.obs;

  @override
  void onInit() {
    super.onInit();
    // Vehicle is passed via Get.arguments
    vehicle = Get.arguments as VehicleModel;
    _loadReviews();
  }

  void _loadReviews() {
    reviews.value = mockReviews.where((r) => r.vehicleId == vehicle.id).toList();
  }

  void selectPriceTab(int tab) {
    selectedPriceTab.value = tab;
  }

  void toggleDriveMode() {
    isSelfDrive.value = !isSelfDrive.value;
  }

  void toggleWishlist() {
    isWishlisted.value = !isWishlisted.value;
    Get.snackbar(
      isWishlisted.value ? 'wishlisted'.tr : 'removed_wishlist'.tr,
      vehicle.name,
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }

  double get displayPrice {
    switch (selectedPriceTab.value) {
      case 1:
        return vehicle.pricePerWeek;
      case 2:
        return vehicle.pricePerMonth;
      default:
        return vehicle.pricePerDay;
    }
  }

  String get priceSuffix {
    switch (selectedPriceTab.value) {
      case 1:
        return 'per_week'.tr;
      case 2:
        return 'per_month'.tr;
      default:
        return 'per_day'.tr;
    }
  }
}

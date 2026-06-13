import 'dart:async';
import 'package:get/get.dart';

import 'package:jkworlds/data/models/vehicle_model.dart';
import 'package:jkworlds/data/models/booking_model.dart';
import 'package:jkworlds/data/mock/mock_vehicles.dart';
import 'package:jkworlds/data/mock/mock_bookings.dart';
import 'package:jkworlds/data/services/auth_service.dart';
import 'package:jkworlds/modules/main_nav/main_nav_controller.dart';
import 'package:jkworlds/app/routes/app_routes.dart';

class HomeController extends GetxController {
  final featuredVehicles = <VehicleModel>[].obs;
  final popularVehicles = <VehicleModel>[].obs;
  final selectedCategory = 'All'.obs;

  final categories = const ['All', 'Sedan', 'SUV', 'Luxury', 'Van'];

  // ── Promo banner ───────────────────────────────────────────────
  final currentPromoIndex = 0.obs;
  Timer? _promoTimer;

  // ── Active booking ─────────────────────────────────────────────
  final activeBooking = Rxn<BookingModel>();

  @override
  void onInit() {
    super.onInit();
    _loadData();
    _startPromoAutoScroll();
  }

  @override
  void onClose() {
    _promoTimer?.cancel();
    super.onClose();
  }

  void _loadData() {
    featuredVehicles.value =
        mockVehicles.where((v) => v.isFeatured).toList();
    _filterPopular();
    _loadActiveBooking();
  }

  void _loadActiveBooking() {
    // Find the first active or upcoming booking
    final active = mockBookings.where(
      (b) => b.status == BookingStatus.active || b.status == BookingStatus.upcoming,
    );
    if (active.isNotEmpty) {
      activeBooking.value = active.first;
    }
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

  /// User display name from AuthService.
  String get userName {
    try {
      final auth = Get.find<AuthService>();
      final name = auth.userName.value;
      return name.isNotEmpty ? name : 'guest'.tr;
    } catch (_) {
      return 'guest'.tr;
    }
  }

  /// User photo URL from AuthService.
  String get userPhotoUrl {
    try {
      final auth = Get.find<AuthService>();
      return auth.userPhotoUrl.value;
    } catch (_) {
      return '';
    }
  }

  // ── Promo Carousel ─────────────────────────────────────────────

  void _startPromoAutoScroll() {
    _promoTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      currentPromoIndex.value = (currentPromoIndex.value + 1) % 3;
    });
  }

  void setPromoIndex(int index) {
    currentPromoIndex.value = index;
    // Reset the timer when user manually swipes
    _promoTimer?.cancel();
    _startPromoAutoScroll();
  }

  // ── Navigation Helpers ─────────────────────────────────────────

  void navigateToExplore() {
    try {
      final navCtrl = Get.find<MainNavController>();
      navCtrl.changePage(1); // Explore tab
    } catch (_) {
      // Fallback: direct route navigation
      Get.toNamed(AppRoutes.explore);
    }
  }

  void navigateToBookings() {
    try {
      final navCtrl = Get.find<MainNavController>();
      navCtrl.changePage(2); // Orders/Bookings tab
    } catch (_) {
      Get.toNamed(AppRoutes.orders);
    }
  }

  void navigateToVehicleDetail(VehicleModel vehicle) {
    Get.toNamed(AppRoutes.vehicleDetail, arguments: vehicle);
  }
}

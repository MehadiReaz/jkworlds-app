import 'dart:async';
import 'package:get/get.dart';
import 'package:jkworlds/core/utils/logger.dart';

import 'package:jkworlds/data/models/vehicle_model.dart';
import 'package:jkworlds/data/models/booking_model.dart';
import 'package:jkworlds/data/models/category_model.dart';
import 'package:jkworlds/data/services/auth_service.dart';
import 'package:jkworlds/data/services/category_service.dart';
import 'package:jkworlds/data/services/booking_service.dart';
import 'package:jkworlds/modules/main_nav/main_nav_controller.dart';
import 'package:jkworlds/app/routes/app_routes.dart';

class HomeController extends GetxController {
  final featuredVehicles = <VehicleModel>[].obs;
  final popularVehicles  = <VehicleModel>[].obs;
  final apiCategories    = <CategoryModel>[].obs;
  final selectedCategory = 'All'.obs;
  final isLoading        = false.obs;
  final errorMessage     = ''.obs;

  final categories = <String>['All', 'Sedan', 'SUV', 'Luxury', 'Van'].obs;

  // ── Promo banner ───────────────────────────────────────────────
  final currentPromoIndex = 0.obs;
  Timer? _promoTimer;

  // ── Active booking ─────────────────────────────────────────────
  final activeBooking = Rxn<BookingModel>();

  CategoryService get _categoryService => Get.find<CategoryService>();
  BookingService  get _bookingService  => Get.find<BookingService>();

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

  Future<void> _loadData() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      // Load categories list
      final cats = await _categoryService.fetchCategories();
      apiCategories.value = cats;

      if (cats.isNotEmpty) {
        categories.value = ['All', ...cats.map((c) => c.name)];
        
        // Load featured vehicles across all categories (with featured: '1')
        final allFeatured = await _categoryService.fetchAllVehicles(featured: '1');
        featuredVehicles.value = allFeatured.where((v) => v.isFeatured).toList();
        
        // Load popular vehicles based on the selected category ('All' on startup)
        await _loadVehiclesForSelectedCategory();
      }
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }

    // Load active booking (non-critical)
    _loadActiveBooking();
  }

  Future<void> _loadActiveBooking() async {
    try {
      final bookings = await _bookingService.fetchBookings();
      final active = bookings.where(
        (b) => b.status == BookingStatus.active || b.status == BookingStatus.upcoming,
      );
      if (active.isNotEmpty) activeBooking.value = active.first;
    } catch (e) {
      logger.e('Error loading active booking: $e');
    }
  }

  @override
  Future<void> refresh() => _loadData();

  void selectCategory(String category) {
    selectedCategory.value = category;
    if (apiCategories.isNotEmpty) {
      _loadVehiclesForSelectedCategory();
    }
  }

  Future<void> _loadVehiclesForSelectedCategory() async {
    isLoading.value = true;
    try {
      if (selectedCategory.value == 'All') {
        final vehicles = await _categoryService.fetchAllVehicles();
        popularVehicles.value = vehicles;
      } else {
        final targetCat = apiCategories.firstWhereOrNull(
          (c) => c.name.toLowerCase() == selectedCategory.value.toLowerCase(),
        );
        if (targetCat != null) {
          final vehicles = await _categoryService.fetchVehiclesByCategory(targetCat.id);
          popularVehicles.value = vehicles;
        }
      }
    } catch (e) {
      logger.e('Error loading vehicles: $e');
    } finally {
      isLoading.value = false;
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

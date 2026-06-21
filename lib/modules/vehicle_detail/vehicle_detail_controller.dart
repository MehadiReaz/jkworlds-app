import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jkworlds/core/utils/snackbar_helper.dart';
import 'package:jkworlds/core/utils/logger.dart';

import 'package:jkworlds/data/models/vehicle_model.dart';
import 'package:jkworlds/data/models/review_model.dart';
import 'package:jkworlds/data/services/category_service.dart';
import 'package:jkworlds/app/routes/app_routes.dart';

class VehicleDetailController extends GetxController {
  // The vehicle starts as the list-page preview; replaced with full detail after fetch.
  late VehicleModel vehicle;
  final vehicleRx = Rxn<VehicleModel>();

  final reviews = <ReviewModel>[].obs;
  final similarVehicles = <VehicleModel>[].obs;
  final selectedPriceTab = 0.obs; // 0=daily, 1=weekly, 2=monthly
  final isSelfDrive = true.obs;
  final isWishlisted = false.obs;

  // ── Loading / Error States ──────────────────────────────────────
  final isLoadingDetail = true.obs;
  final detailError = ''.obs;

  // ── Reservation Form States ──────────────────────────────────────
  final pickupDate = Rxn<DateTime>();
  final returnDate = Rxn<DateTime>();
  final pickupTime = ''.obs;
  final returnTime = ''.obs;
  final selectedProtection = 'Basic'.obs; // Basic, Premium, Full
  final gpsAddon = false.obs;
  final additionalDriverAddon = false.obs;
  final childSeatAddon = false.obs;
  final isLoading = false.obs;

  CategoryService get _categoryService => Get.find<CategoryService>();

  @override
  void onInit() {
    super.onInit();
    // Vehicle is passed via Get.arguments (from list page)
    vehicle = Get.arguments as VehicleModel;
    vehicleRx.value = vehicle;

    // Fetch full details from the API
    _fetchVehicleDetail();
  }

  /// Fetches the full vehicle detail from the API endpoint
  /// GET /api/vehicles/{id}
  Future<void> _fetchVehicleDetail() async {
    isLoadingDetail.value = true;
    detailError.value = '';

    try {
      final result = await _categoryService.fetchVehicleDetail(vehicle.id);

      // Update vehicle with full details from API
      vehicle = result.vehicle;
      vehicleRx.value = result.vehicle;

      // Populate reviews
      reviews.assignAll(result.reviews);

      // Populate similar vehicles
      similarVehicles.assignAll(result.similarVehicles);
    } catch (e) {
      logger.e('[VehicleDetailController] Error fetching vehicle detail: $e');
      detailError.value = e.toString();
      // The page still works with the list-page preview data
    } finally {
      isLoadingDetail.value = false;
    }
  }

  /// Retry fetching vehicle details (e.g. after a network error)
  Future<void> retryFetchDetail() => _fetchVehicleDetail();

  void selectPriceTab(int tab) {
    selectedPriceTab.value = tab;
  }

  void toggleDriveMode() {
    isSelfDrive.value = !isSelfDrive.value;
  }

  void toggleWishlist() {
    isWishlisted.value = !isWishlisted.value;
    SnackbarHelper.showSuccess(
      '${isWishlisted.value ? 'wishlisted'.tr : 'removed_wishlist'.tr}: ${vehicle.name}',
    );
  }

  double get displayPrice {
    final v = vehicleRx.value ?? vehicle;
    switch (selectedPriceTab.value) {
      case 1:
        return v.pricePerWeek;
      case 2:
        return v.pricePerMonth;
      default:
        return v.pricePerDay;
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

  // ── Pricing Getters & Logic ──────────────────────────────────────
  int get totalDays {
    if (pickupDate.value == null || returnDate.value == null) return 0;
    final diff = returnDate.value!.difference(pickupDate.value!).inDays;
    return diff > 0 ? diff : 0;
  }

  double get subtotal {
    final v = vehicleRx.value ?? vehicle;
    return totalDays * v.pricePerDay;
  }

  double get protectionCost {
    final v = vehicleRx.value ?? vehicle;
    if (v.protectionPlans.isNotEmpty) {
      final plans = v.protectionPlans.where((p) => p.title.toLowerCase().contains(selectedProtection.value.toLowerCase()));
      if (plans.isNotEmpty) {
        final plan = plans.first;
        if (plan.priceType == 'percentage' && plan.priceValue != null) {
          return subtotal * (plan.priceValue! / 100.0);
        } else if (plan.priceType == 'fixed' && plan.priceValue != null) {
          return plan.priceValue! * totalDays;
        }
      }
      return 0.0;
    }
    // Fallback:
    if (selectedProtection.value == 'Premium') {
      return subtotal * 0.15;
    } else if (selectedProtection.value == 'Full') {
      return subtotal * 0.25;
    }
    return 0.0;
  }

  double get gpsAddonPrice {
    final v = vehicleRx.value ?? vehicle;
    final addons = v.rentalAddons.where((a) => a.title.toLowerCase().contains('gps'));
    if (addons.isNotEmpty && addons.first.priceValue != null) {
      return addons.first.priceValue!;
    }
    return 5000.0;
  }

  double get additionalDriverAddonPrice {
    final v = vehicleRx.value ?? vehicle;
    final addons = v.rentalAddons.where((a) => a.title.toLowerCase().contains('driver'));
    if (addons.isNotEmpty && addons.first.priceValue != null) {
      final addon = addons.first;
      if (addon.priceType == 'percentage') {
        return (subtotal * (addon.priceValue! / 100.0)) / (totalDays > 0 ? totalDays : 1);
      }
      return addon.priceValue!;
    }
    return 8000.0;
  }

  double get childSeatAddonPrice {
    final v = vehicleRx.value ?? vehicle;
    final addons = v.rentalAddons.where((a) => a.title.toLowerCase().contains('seat') || a.title.toLowerCase().contains('child'));
    if (addons.isNotEmpty && addons.first.priceValue != null) {
      final addon = addons.first;
      if (addon.priceType == 'percentage') {
        return (subtotal * (addon.priceValue! / 100.0)) / (totalDays > 0 ? totalDays : 1);
      }
      return addon.priceValue!;
    }
    return 4000.0;
  }

  double get addonsCost {
    double cost = 0.0;
    if (gpsAddon.value) cost += gpsAddonPrice * totalDays;
    if (additionalDriverAddon.value) cost += additionalDriverAddonPrice * totalDays;
    if (childSeatAddon.value) cost += childSeatAddonPrice * totalDays;
    return cost;
  }

  double get serviceFee => subtotal * 0.05;

  double get securityDeposit {
    final v = vehicleRx.value ?? vehicle;
    if (v.securityDepositAmount != null) {
      return v.securityDepositAmount!;
    }
    if (v.type == 'Luxury') return 150000.0;
    if (v.type == 'SUV') return 100000.0;
    return 50000.0;
  }

  double get total {
    if (totalDays == 0) return 0.0;
    return subtotal + protectionCost + addonsCost + serviceFee + securityDeposit;
  }

  bool get canBook {
    return pickupDate.value != null &&
        returnDate.value != null &&
        pickupTime.value.isNotEmpty &&
        returnTime.value.isNotEmpty &&
        totalDays > 0;
  }

  Future<void> selectPickupDate(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      initialDate: pickupDate.value ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null) {
      pickupDate.value = date;
      // Reset return date if before or same as pickup
      if (returnDate.value != null && !returnDate.value!.isAfter(date)) {
        returnDate.value = null;
      }
    }
  }

  Future<void> selectReturnDate(BuildContext context) async {
    if (pickupDate.value == null) {
      SnackbarHelper.showWarning('Please select a pick-up date first.');
      return;
    }
    final date = await showDatePicker(
      context: context,
      initialDate: returnDate.value ?? pickupDate.value!.add(const Duration(days: 1)),
      firstDate: pickupDate.value!.add(const Duration(days: 1)),
      lastDate: pickupDate.value!.add(const Duration(days: 365)),
    );
    if (date != null) {
      returnDate.value = date;
    }
  }

  Future<void> confirmBooking() async {
    if (!canBook) return;

    final currentVehicle = vehicleRx.value ?? vehicle;

    // Serialize the details of the booking configurator to pass to Checkout Screen
    final arguments = {
      'vehicle': currentVehicle,
      'pickupDate': pickupDate.value!,
      'returnDate': returnDate.value!,
      'pickupTime': pickupTime.value,
      'returnTime': returnTime.value,
      'isSelfDrive': isSelfDrive.value,
      'selectedProtection': selectedProtection.value,
      'gpsAddon': gpsAddon.value,
      'additionalDriverAddon': additionalDriverAddon.value,
      'childSeatAddon': childSeatAddon.value,
      'subtotal': subtotal,
      'protectionCost': protectionCost,
      'addonsCost': addonsCost,
      'serviceFee': serviceFee,
      'securityDeposit': securityDeposit,
      'total': total,
    };

    // Navigate to Checkout Screen
    Get.toNamed('/checkout', arguments: arguments);
  }

  /// Navigate to a similar vehicle's detail page
  void navigateToSimilarVehicle(VehicleModel similarVehicle) {
    Get.offNamed(AppRoutes.vehicleDetail, arguments: similarVehicle);
  }
}

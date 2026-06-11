import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:jkworlds/data/models/vehicle_model.dart';
import 'package:jkworlds/data/models/review_model.dart';
import 'package:jkworlds/data/mock/mock_reviews.dart';
import 'package:jkworlds/data/models/booking_model.dart';
import 'package:jkworlds/data/mock/mock_bookings.dart';
import 'package:jkworlds/modules/orders/orders_controller.dart';

class VehicleDetailController extends GetxController {
  late final VehicleModel vehicle;
  final reviews = <ReviewModel>[].obs;
  final selectedPriceTab = 0.obs; // 0=daily, 1=weekly, 2=monthly
  final isSelfDrive = true.obs;
  final isWishlisted = false.obs;

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

  // ── Pricing Getters & Logic ──────────────────────────────────────
  int get totalDays {
    if (pickupDate.value == null || returnDate.value == null) return 0;
    final diff = returnDate.value!.difference(pickupDate.value!).inDays;
    return diff > 0 ? diff : 0;
  }

  double get subtotal => totalDays * vehicle.pricePerDay;

  double get protectionCost {
    if (selectedProtection.value == 'Premium') {
      return subtotal * 0.15;
    } else if (selectedProtection.value == 'Full') {
      return subtotal * 0.25;
    }
    return 0.0;
  }

  double get addonsCost {
    double cost = 0.0;
    // Addons are cost per day
    if (gpsAddon.value) cost += 5000.0 * totalDays;
    if (additionalDriverAddon.value) cost += 8000.0 * totalDays;
    if (childSeatAddon.value) cost += 4000.0 * totalDays;
    return cost;
  }

  double get serviceFee => subtotal * 0.05;

  double get securityDeposit {
    if (vehicle.type == 'Luxury') return 150000.0;
    if (vehicle.type == 'SUV') return 100000.0;
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
      Get.snackbar('Alert', 'Please select a pick-up date first.',
          snackPosition: SnackPosition.BOTTOM);
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

    // Serialize the details of the booking configurator to pass to Checkout Screen
    final arguments = {
      'vehicle': vehicle,
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

  DateTime _combineDateAndTime(DateTime date, String timeStr) {
    if (timeStr.isEmpty) return date;
    final parts = timeStr.split(':');
    if (parts.length < 2) return date;
    final hour = int.tryParse(parts[0]) ?? 0;
    final minute = int.tryParse(parts[1]) ?? 0;
    return DateTime(date.year, date.month, date.day, hour, minute);
  }
}


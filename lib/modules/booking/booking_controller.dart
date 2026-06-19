import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jkworlds/core/utils/snackbar_helper.dart';
import 'package:jkworlds/data/models/vehicle_model.dart';
import 'package:jkworlds/data/models/booking_model.dart';
import 'package:jkworlds/data/mock/mock_bookings.dart';

class BookingController extends GetxController {
  late final VehicleModel vehicle;

  final pickupDate = Rxn<DateTime>();
  final returnDate = Rxn<DateTime>();
  final isSelfDrive = true.obs;
  final isLoading = false.obs;
  final pickupLocation = ''.obs;

  @override
  void onInit() {
    super.onInit();
    vehicle = Get.arguments as VehicleModel;
    pickupLocation.value = vehicle.location;
  }

  int get totalDays {
    if (pickupDate.value == null || returnDate.value == null) return 0;
    return returnDate.value!.difference(pickupDate.value!).inDays;
  }

  double get subtotal => totalDays * vehicle.pricePerDay;
  double get serviceFee => subtotal * 0.05;
  double get securityDeposit => vehicle.type == 'Luxury' ? 150000 : (vehicle.type == 'SUV' ? 100000 : 50000);
  double get total => subtotal + serviceFee + securityDeposit;

  bool get canBook =>
      pickupDate.value != null &&
      returnDate.value != null &&
      totalDays > 0;

  Future<void> selectPickupDate(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null) {
      pickupDate.value = date;
      // Reset return date if before pickup
      if (returnDate.value != null && returnDate.value!.isBefore(date)) {
        returnDate.value = null;
      }
    }
  }

  Future<void> selectReturnDate(BuildContext context) async {
    if (pickupDate.value == null) {
      SnackbarHelper.showWarning('select_pickup_date'.tr);
      return;
    }
    final date = await showDatePicker(
      context: context,
      initialDate: pickupDate.value!.add(const Duration(days: 1)),
      firstDate: pickupDate.value!.add(const Duration(days: 1)),
      lastDate: pickupDate.value!.add(const Duration(days: 365)),
    );
    if (date != null) {
      returnDate.value = date;
    }
  }

  Future<void> confirmBooking() async {
    if (!canBook) return;

    isLoading.value = true;
    await Future.delayed(const Duration(milliseconds: 800));

    // Add to mock bookings
    // mockBookings.insert(
    //   0,
    //   BookingModel(
    //     id: 'BK-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
    //     vehicle: vehicle,
    //     pickupDate: pickupDate.value!,
    //     returnDate: returnDate.value!,
    //     pickupLocation: pickupLocation.value,
    //     status: BookingStatus.upcoming,
    //     rentalType: isSelfDrive.value ? RentalType.selfDrive : RentalType.chauffeur,
    //     subtotal: subtotal,
    //     serviceFee: serviceFee,
    //     securityDeposit: securityDeposit,
    //     totalPrice: total,
    //     createdAt: DateTime.now(),
    //   ),
    // );

    isLoading.value = false;

    Get.back(); // Return to vehicle detail
    SnackbarHelper.showSuccess('booking_success_msg'.tr);
  }
}

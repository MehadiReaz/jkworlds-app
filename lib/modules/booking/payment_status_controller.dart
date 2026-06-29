import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jkworlds/data/models/booking_model.dart';
import 'package:jkworlds/data/models/vehicle_model.dart';
import 'package:jkworlds/data/services/booking_service.dart';
import 'package:jkworlds/data/mock/mock_bookings.dart';
import 'package:jkworlds/modules/orders/orders_controller.dart';
import 'package:jkworlds/modules/main_nav/main_nav_controller.dart';
import 'package:jkworlds/core/utils/logger.dart';
import 'package:jkworlds/app/routes/app_routes.dart';

enum PaymentVerificationStatus { verifying, success, failed }

class PaymentStatusController extends GetxController {
  final status = PaymentVerificationStatus.verifying.obs;
  final errorMessage = ''.obs;

  BookingModel? confirmedBooking;
  late final String gateway;
  late final String reference;
  late final String? transactionId;
  late final VehicleModel? vehicle;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>? ?? {};
    gateway = args['gateway'] as String? ?? 'flutterwave';
    reference = args['reference'] as String? ?? '';
    transactionId = args['transactionId'] as String?;
    vehicle = args['vehicle'] as VehicleModel?;
    verifyPayment();
  }

  Future<void> verifyPayment() async {
    status.value = PaymentVerificationStatus.verifying;
    errorMessage.value = '';

    try {
      logger.i('[PaymentStatusController] starting payment verification for $gateway, ref: $reference, txId: $transactionId');

      // Call booking service to confirm payment
      final booking = await Get.find<BookingService>().confirmPayment(
        gateway,
        reference: reference,
        transactionId: transactionId,
      );

      confirmedBooking = booking;

      // Update local database & refresh active Orders lists
      mockBookings.insert(0, booking);
      if (Get.isRegistered<OrdersController>()) {
        Get.find<OrdersController>().allBookings.insert(0, booking);
      }

      status.value = PaymentVerificationStatus.success;
      logger.i('[PaymentStatusController] verification success, bookingId: ${booking.id}');
    } catch (e, st) {
      logger.e('[PaymentStatusController] verification failed', error: e, stackTrace: st);
      errorMessage.value = e.toString();
      status.value = PaymentVerificationStatus.failed;
    }
  }

  void goToHome() {
    Get.offAllNamed(AppRoutes.main);
  }

  void goToBookings() {
    Get.offAllNamed(AppRoutes.main);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Get.isRegistered<MainNavController>()) {
        Get.find<MainNavController>().changePage(2); // Index 2 is OrdersView tab
      }
    });
  }
}

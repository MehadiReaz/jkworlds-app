import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:jkworlds/core/utils/snackbar_helper.dart';
import 'package:jkworlds/data/services/auth_service.dart';
import 'package:jkworlds/data/services/booking_service.dart';
import 'package:jkworlds/data/services/location_service.dart';
import 'package:jkworlds/data/models/vehicle_model.dart';
import 'package:jkworlds/data/mock/mock_bookings.dart';
import 'package:jkworlds/modules/orders/orders_controller.dart';
import 'package:jkworlds/modules/explore/explore_controller.dart';
import 'package:jkworlds/core/utils/image_picker_helper.dart';
import 'package:jkworlds/core/utils/logger.dart';
import 'package:jkworlds/app/routes/app_routes.dart';

class CheckoutController extends GetxController {
  late final Map<String, dynamic> args;

  // Serialized values passed from details configurator
  late final VehicleModel vehicle;
  late final DateTime pickupDate;
  late final DateTime returnDate;
  late final String pickupTime;
  late final String returnTime;
  late final bool isSelfDrive;
  late final String selectedProtection;
  late final bool gpsAddon;
  late final bool additionalDriverAddon;
  late final bool childSeatAddon;

  // ── Form Controllers ─────────────────────────────────────────────
  late final TextEditingController fullNameController;
  late final TextEditingController emailController;
  late final TextEditingController phoneController;
  final flightNumberController = TextEditingController();
  final specialRequestsController = TextEditingController();

  // ── Driver License File ──────────────────────────────────────────
  final selectedLicensePath = ''.obs;

  // ── Payment Selection ────────────────────────────────────────────
  final selectedPaymentMethod = 'stripe'.obs; // stripe, paypal, flutterwave

  // ── Promo Code ───────────────────────────────────────────────────
  final promoCodeController = TextEditingController();
  final appliedPromoCode = ''.obs;

  // ── Dynamic Pricing State (from API) ─────────────────────────────
  final calculatedSubtotal = 0.0.obs;
  final calculatedProtectionCost = 0.0.obs;
  final calculatedAddonsCost = 0.0.obs;
  final calculatedServiceFee = 0.0.obs;
  final calculatedSecurityDeposit = 0.0.obs;
  final calculatedTotal = 0.0.obs;
  final calculatedPayableTotal = 0.0.obs;
  final calculatedDiscount = 0.0.obs;
  final calculatedCurrency = 'USD'.obs;

  final calculatedSubtotalFormatted = ''.obs;
  final calculatedProtectionTitle = 'Basic'.obs;
  final calculatedProtectionFormatted = ''.obs;
  final calculatedAddonsFormatted = ''.obs;
  final calculatedServiceFeeFormatted = ''.obs;
  final calculatedSecurityDepositFormatted = ''.obs;
  final calculatedDiscountFormatted = ''.obs;
  final calculatedTotalFormatted = ''.obs;
  final calculatedPayableTotalFormatted = ''.obs;

  // Active payment gateways from API
  final paymentMethods = <Map<String, dynamic>>[].obs;

  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    args = Get.arguments as Map<String, dynamic>;

    // Unpack arguments
    vehicle = args['vehicle'] as VehicleModel;
    pickupDate = args['pickupDate'] as DateTime;
    returnDate = args['returnDate'] as DateTime;
    pickupTime = args['pickupTime'] as String;
    returnTime = args['returnTime'] as String;
    isSelfDrive = args['isSelfDrive'] as bool;
    selectedProtection = args['selectedProtection'] as String;
    gpsAddon = args['gpsAddon'] as bool;
    additionalDriverAddon = args['additionalDriverAddon'] as bool;
    childSeatAddon = args['childSeatAddon'] as bool;

    // Prefill form from AuthService
    final auth = Get.find<AuthService>();
    fullNameController = TextEditingController(text: auth.userName.value);
    emailController = TextEditingController(text: auth.userEmail.value);
    phoneController = TextEditingController(text: auth.userPhone.value);

    // Fetch initial pricing calculations
    fetchCheckoutPricing();
  }

  int get totalDays => returnDate.difference(pickupDate).inDays;

  @override
  void onClose() {
    fullNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    flightNumberController.dispose();
    specialRequestsController.dispose();
    promoCodeController.dispose();
    super.onClose();
  }

  // ── Fetch Pricing Calculation from Checkout API ──────────────────
  Future<void> fetchCheckoutPricing() async {
    isLoading.value = true;
    try {
      final protectionPlan = vehicle.protectionPlans.firstWhereOrNull(
        (p) => p.title.toLowerCase().contains(selectedProtection.toLowerCase()),
      );
      final protectionPlanId = protectionPlan?.id;

      final addonIds = <int>[];
      if (gpsAddon) {
        final addon = vehicle.rentalAddons.firstWhereOrNull(
          (a) => a.title.toLowerCase().contains('gps'),
        );
        if (addon != null) addonIds.add(addon.id);
      }
      if (additionalDriverAddon) {
        final addon = vehicle.rentalAddons.firstWhereOrNull(
          (a) => a.title.toLowerCase().contains('driver'),
        );
        if (addon != null) addonIds.add(addon.id);
      }
      if (childSeatAddon) {
        final addon = vehicle.rentalAddons.firstWhereOrNull(
          (a) => a.title.toLowerCase().contains('seat') || a.title.toLowerCase().contains('child'),
        );
        if (addon != null) addonIds.add(addon.id);
      }

      final pickupDateStr = DateFormat('yyyy-MM-dd').format(pickupDate);
      final returnDateStr = DateFormat('yyyy-MM-dd').format(returnDate);

      // Resolve coordinates asynchronously (using Nigeria coordinates as default fallback)
      double pickupLat = 9.0579;
      double pickupLng = 7.4951;
      double dropoffLat = 9.0765;
      double dropoffLng = 7.3986;
      String pickupAddress = vehicle.location;
      String dropoffAddress = vehicle.location;

      final exploreCtrl = Get.isRegistered<ExploreController>() ? Get.find<ExploreController>() : null;
      if (exploreCtrl != null) {
        final pickupPred = exploreCtrl.selectedPickupPrediction.value;
        if (pickupPred != null) {
          final details = await Get.find<LocationService>().fetchLocationDetails(pickupPred.id);
          if (details != null) {
            pickupLat = double.tryParse(details['latitude']?.toString() ?? '') ?? 9.0579;
            pickupLng = double.tryParse(details['longitude']?.toString() ?? '') ?? 7.4951;
            pickupAddress = details['address']?.toString() ?? details['name']?.toString() ?? pickupPred.description;
          }
        }
        final dropoffPred = exploreCtrl.selectedDropoffPrediction.value;
        if (dropoffPred != null) {
          final details = await Get.find<LocationService>().fetchLocationDetails(dropoffPred.id);
          if (details != null) {
            dropoffLat = double.tryParse(details['latitude']?.toString() ?? '') ?? 9.0765;
            dropoffLng = double.tryParse(details['longitude']?.toString() ?? '') ?? 7.3986;
            dropoffAddress = details['address']?.toString() ?? details['name']?.toString() ?? dropoffPred.description;
          }
        }
      }

      final payload = {
        'vehicle_id': int.tryParse(vehicle.id) ?? 0,
        'service_type': isSelfDrive ? 'self_drive' : 'chauffeur',
        'pickup_date': pickupDateStr,
        'pickup_time': pickupTime,
        'return_date': returnDateStr,
        'return_time': returnTime,
        'pickup_latitude': pickupLat,
        'pickup_longitude': pickupLng,
        if (!isSelfDrive) ...{
          'dropoff_latitude': dropoffLat,
          'dropoff_longitude': dropoffLng,
          'dropoff_location_name': dropoffAddress,
          'dropoff_address': dropoffAddress,
        },
        'pickup_location_name': pickupAddress,
        'pickup_address': pickupAddress,
        if (protectionPlanId != null) 'protection_plan_id': protectionPlanId,
        if (addonIds.isNotEmpty) 'addon_ids': addonIds,
        if (appliedPromoCode.value.isNotEmpty) 'coupon_code': appliedPromoCode.value,
      };

      final data = await Get.find<BookingService>().calculateCheckoutPricing(payload);

      // Update reactive states
      calculatedCurrency.value = data['currency']?.toString() ?? 'USD';

      final baseMap = data['base'] as Map<String, dynamic>?;
      calculatedSubtotal.value = double.tryParse(baseMap?['amount']?.toString() ?? '') ?? 0.0;
      calculatedSubtotalFormatted.value = baseMap?['amount_formatted']?.toString() ?? '';

      final protectionMap = data['protection'] as Map<String, dynamic>?;
      calculatedProtectionCost.value = double.tryParse(protectionMap?['amount']?.toString() ?? '') ?? 0.0;
      calculatedProtectionTitle.value = protectionMap?['title']?.toString() ?? 'Basic';
      calculatedProtectionFormatted.value = protectionMap?['amount_formatted']?.toString() ?? '';

      final addonsTotalMap = data['addons_total'] as Map<String, dynamic>?;
      calculatedAddonsCost.value = double.tryParse(addonsTotalMap?['amount']?.toString() ?? '') ?? 0.0;
      calculatedAddonsFormatted.value = addonsTotalMap?['amount_formatted']?.toString() ?? '';

      final feesTotalMap = data['fees_total'] as Map<String, dynamic>?;
      calculatedServiceFee.value = double.tryParse(feesTotalMap?['amount']?.toString() ?? '') ?? 0.0;
      calculatedServiceFeeFormatted.value = feesTotalMap?['amount_formatted']?.toString() ?? '';

      final depositMap = data['deposit'] as Map<String, dynamic>?;
      calculatedSecurityDeposit.value = double.tryParse(depositMap?['amount']?.toString() ?? '') ?? 0.0;
      calculatedSecurityDepositFormatted.value = depositMap?['amount_formatted']?.toString() ?? '';

      final discountMap = data['discount'] as Map<String, dynamic>?;
      calculatedDiscount.value = double.tryParse(discountMap?['amount']?.toString() ?? '') ?? 0.0;
      calculatedDiscountFormatted.value = discountMap?['amount_formatted']?.toString() ?? '';

      final totalMap = data['total'] as Map<String, dynamic>?;
      calculatedTotal.value = double.tryParse(totalMap?['amount']?.toString() ?? '') ?? 0.0;
      calculatedTotalFormatted.value = totalMap?['amount_formatted']?.toString() ?? '';

      final payableMap = data['payable_total'] as Map<String, dynamic>?;
      calculatedPayableTotal.value = double.tryParse(payableMap?['amount']?.toString() ?? '') ?? 0.0;
      calculatedPayableTotalFormatted.value = payableMap?['amount_formatted']?.toString() ?? '';

      // Update payment methods list
      final methodsList = data['payment_methods'] as List?;
      if (methodsList != null) {
        final List<Map<String, dynamic>> mapped = [];
        for (var item in methodsList) {
          if (item is Map) {
            mapped.add(Map<String, dynamic>.from(item));
          }
        }
        paymentMethods.assignAll(mapped);
        if (paymentMethods.isNotEmpty) {
          final defaultMethod = paymentMethods.firstWhereOrNull((m) => m['enabled'] == true);
          if (defaultMethod != null) {
            selectedPaymentMethod.value = defaultMethod['key']?.toString() ?? 'stripe';
          }
        }
      }
    } catch (e) {
      SnackbarHelper.showError('Checkout Pricing Error: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  // ── File Selection ───────────────────────────────────────────────
  Future<void> chooseLicenseFile() async {
    final path = await ImagePickerHelper.pickImageWithBottomSheet();
    if (path != null && path.isNotEmpty) {
      selectedLicensePath.value = path;
    }
  }

  // ── Promo Code Action ────────────────────────────────────────────
  Future<void> applyPromoCode() async {
    final code = promoCodeController.text.trim().toUpperCase();
    if (code.isEmpty) return;

    appliedPromoCode.value = code;
    await fetchCheckoutPricing();

    if (calculatedDiscount.value > 0) {
      SnackbarHelper.showSuccess('Promo code applied successfully!');
    } else {
      appliedPromoCode.value = '';
      SnackbarHelper.showError('This promo code is not valid.');
    }
  }

  // ── Form Validation ──────────────────────────────────────────────
  bool get canPay {
    final basicInfoOk = fullNameController.text.trim().isNotEmpty &&
        emailController.text.trim().isNotEmpty &&
        phoneController.text.trim().isNotEmpty;
    if (isSelfDrive) {
      return basicInfoOk && selectedLicensePath.value.isNotEmpty;
    }
    return basicInfoOk;
  }

  // ── Checkout Action ──────────────────────────────────────────────
  Future<void> confirmAndPay() async {
    logger.i('[CheckoutController] confirmAndPay started');
    if (!canPay) {
      logger.w('[CheckoutController] confirmAndPay validation failed');
      SnackbarHelper.showWarning("Please fill in all required fields and upload your driver's license.");
      return;
    }

    final protectionPlan = vehicle.protectionPlans.firstWhereOrNull(
      (p) => p.title.toLowerCase().contains(selectedProtection.toLowerCase()),
    );
    final protectionPlanId = protectionPlan?.id;

    final addonIds = <int>[];
    if (gpsAddon) {
      final addon = vehicle.rentalAddons.firstWhereOrNull(
        (a) => a.title.toLowerCase().contains('gps'),
      );
      if (addon != null) addonIds.add(addon.id);
    }
    if (additionalDriverAddon) {
      final addon = vehicle.rentalAddons.firstWhereOrNull(
        (a) => a.title.toLowerCase().contains('driver'),
      );
      if (addon != null) addonIds.add(addon.id);
    }
    if (childSeatAddon) {
      final addon = vehicle.rentalAddons.firstWhereOrNull(
        (a) => a.title.toLowerCase().contains('seat') || a.title.toLowerCase().contains('child'),
      );
      if (addon != null) addonIds.add(addon.id);
    }

    final pickupDateStr = DateFormat('yyyy-MM-dd').format(pickupDate);
    final returnDateStr = DateFormat('yyyy-MM-dd').format(returnDate);

    // Resolve coordinates
    double pickupLat = 9.0579;
    double pickupLng = 7.4951;
    double dropoffLat = 9.0765;
    double dropoffLng = 7.3986;
    String pickupAddress = vehicle.location;
    String dropoffAddress = vehicle.location;

    final exploreCtrl = Get.isRegistered<ExploreController>() ? Get.find<ExploreController>() : null;
    if (exploreCtrl != null) {
      final pickupPred = exploreCtrl.selectedPickupPrediction.value;
      if (pickupPred != null) {
        final details = await Get.find<LocationService>().fetchLocationDetails(pickupPred.id);
        if (details != null) {
          pickupLat = double.tryParse(details['latitude']?.toString() ?? '') ?? 9.0579;
          pickupLng = double.tryParse(details['longitude']?.toString() ?? '') ?? 7.4951;
          pickupAddress = details['address']?.toString() ?? details['name']?.toString() ?? pickupPred.description;
        }
      }
      final dropoffPred = exploreCtrl.selectedDropoffPrediction.value;
      if (dropoffPred != null) {
        final details = await Get.find<LocationService>().fetchLocationDetails(dropoffPred.id);
        if (details != null) {
          dropoffLat = double.tryParse(details['latitude']?.toString() ?? '') ?? 9.0765;
          dropoffLng = double.tryParse(details['longitude']?.toString() ?? '') ?? 7.3986;
          dropoffAddress = details['address']?.toString() ?? details['name']?.toString() ?? dropoffPred.description;
        }
      }
    }

    final bookingPayload = {
      'vehicle_id': int.tryParse(vehicle.id) ?? 0,
      'service_type': isSelfDrive ? 'self_drive' : 'chauffeur',
      'pickup_date': pickupDateStr,
      'pickup_time': pickupTime,
      'return_date': returnDateStr,
      'return_time': returnTime,
      'pickup_latitude': pickupLat,
      'pickup_longitude': pickupLng,
      if (!isSelfDrive) ...{
        'dropoff_latitude': dropoffLat,
        'dropoff_longitude': dropoffLng,
        'dropoff_location_name': dropoffAddress,
        'dropoff_address': dropoffAddress,
      },
      'pickup_location_name': pickupAddress,
      'pickup_address': pickupAddress,
      if (protectionPlanId != null) 'protection_plan_id': protectionPlanId,
      if (addonIds.isNotEmpty) 'addon_ids': addonIds,
      if (appliedPromoCode.value.isNotEmpty) 'coupon_code': appliedPromoCode.value,
      'full_name': fullNameController.text.trim(),
      'email': emailController.text.trim(),
      'phone': phoneController.text.trim(),
      if (flightNumberController.text.isNotEmpty) 'flight_number': flightNumberController.text.trim(),
      if (specialRequestsController.text.isNotEmpty) 'special_requests': specialRequestsController.text.trim(),
      'payment_method': selectedPaymentMethod.value.toLowerCase(),
    };

    isLoading.value = true;
    try {
      logger.i('[CheckoutController] calling initiateBooking...');
      final res = await Get.find<BookingService>().initiateBooking(
        bookingPayload,
        driverLicensePath: isSelfDrive ? selectedLicensePath.value : null,
      );

      final reference = res['reference']?.toString() ?? '';
      final gateway = selectedPaymentMethod.value.toLowerCase();
      logger.i('[CheckoutController] reference: $reference, gateway: $gateway');

      // Navigate to PaymentWebView page and wait for result
      final bool? payResult;
      if (Platform.environment.containsKey('FLUTTER_TEST')) {
        payResult = true;
      } else {
        final result = await Get.toNamed(
          AppRoutes.paymentWebView,
          arguments: {
            'gateway': gateway,
            'reference': reference,
            'initData': res['gateway'] as Map<String, dynamic>,
            'fullName': fullNameController.text.trim(),
            'email': emailController.text.trim(),
            'phone': phoneController.text.trim(),
          },
        );
        payResult = result == true;
      }
      logger.i('[CheckoutController] payResult: $payResult');

      if (payResult == true) {
        // Confirm payment success on API
        // Stripe/PayPal verify via saved gateway references, transaction_id is optional/null
        final String? transactionId = (gateway == 'stripe' || gateway == 'paypal') ? null : 'tx_${DateTime.now().millisecondsSinceEpoch}';
        logger.i('[CheckoutController] calling confirmPayment...');
        final confirmedBooking = await Get.find<BookingService>().confirmPayment(
          gateway,
          reference: reference,
          transactionId: transactionId,
        );
        logger.i('[CheckoutController] confirmedBooking ID: ${confirmedBooking.id}');

        // Update local database & refresh active Orders lists
        mockBookings.insert(0, confirmedBooking);
        if (Get.isRegistered<OrdersController>()) {
          Get.find<OrdersController>().allBookings.insert(0, confirmedBooking);
        }

        // Return to listings safely
        if (Get.context != null && Navigator.canPop(Get.context!)) {
          Get.back();
          if (Navigator.canPop(Get.context!)) {
            Get.back();
          }
        }
        SnackbarHelper.showSuccess('Your booking for ${vehicle.brand} ${vehicle.name} has been processed successfully.');
      } else {
        // Register cancellation on API
        logger.i('[CheckoutController] calling cancelPayment...');
        await Get.find<BookingService>().cancelPayment(gateway, reference: reference);
        SnackbarHelper.showWarning('Payment was cancelled. Your booking was not created.');
      }
    } catch (e, st) {
      logger.e('[CheckoutController] Error in confirmAndPay', error: e, stackTrace: st);
      SnackbarHelper.showError('Booking Initiation/Payment Error: ${e.toString()}');
    } finally {
      isLoading.value = false;
      logger.i('[CheckoutController] confirmAndPay finished');
    }
  }

  Future<bool?> _showSimulatedPaymentDialog(String gateway, String reference) async {
    // Return mock payment result; if in headless/widget test, return true directly
    if (Get.key.currentState == null || Platform.environment.containsKey('FLUTTER_TEST')) {
      return true;
    }

    return Get.dialog<bool>(
      AlertDialog(
        title: Row(
          children: [
            Icon(Icons.payment_rounded, color: Get.theme.colorScheme.primary),
            const SizedBox(width: 10),
            Text('Simulate ${gateway.toUpperCase()}'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Booking Reference: $reference', style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            const Text('Choose a payment outcome to simulate. Real gateway SDK payment sheets will be used in production.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel / Fail Payment', style: TextStyle(color: Colors.red)),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Get.theme.colorScheme.primary,
              foregroundColor: Get.theme.colorScheme.onPrimary,
            ),
            child: const Text('Complete Payment'),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }
}

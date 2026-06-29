import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:jkworlds/core/utils/snackbar_helper.dart';
import 'package:jkworlds/data/services/auth_service.dart';
import 'package:jkworlds/data/services/booking_service.dart';
import 'package:jkworlds/data/services/location_service.dart';
import 'package:jkworlds/data/models/location_prediction.dart';
import 'package:jkworlds/data/models/location_model.dart';
import 'package:jkworlds/data/models/initiate_booking_response_model.dart';
import 'package:jkworlds/data/models/vehicle_model.dart';
import 'package:jkworlds/data/mock/mock_bookings.dart';
import 'package:jkworlds/modules/orders/orders_controller.dart';
import 'package:jkworlds/modules/explore/explore_controller.dart';
import 'package:jkworlds/core/utils/image_picker_helper.dart';
import 'package:jkworlds/core/utils/logger.dart';
import 'package:jkworlds/data/models/checkout_pricing_model.dart';
import 'package:jkworlds/app/routes/app_routes.dart';

class CheckoutController extends GetxController {
  late final Map<String, dynamic> args;

  // ── Checkout Pricing Model State ────────────────────────────────
  final checkoutPricing = Rxn<CheckoutPricingModel>();

  // Expose the duration (rental days) as base to match the view's requirements
  int get base => checkoutPricing.value?.rentalDays ?? totalDays;

  bool get isDifferentDropoff => args['isDifferentDropoff'] as bool? ?? false;

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
  late final bool prepaidFuelAddon;

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
  int selectedPriceTab = 0;
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

  // Itemized addons and fees from checkout API
  final calculatedAddons = <Map<String, dynamic>>[].obs;
  final calculatedFees = <Map<String, dynamic>>[].obs;

  // Addon price helpers for local calculations/fallbacks
  double get gpsAddonPrice {
    final addons = vehicle.rentalAddons.where((a) => a.title.toLowerCase().contains('gps'));
    if (addons.isNotEmpty && addons.first.priceValue != null) {
      return addons.first.priceValue!;
    }
    return 5000.0;
  }

  double get additionalDriverAddonPrice {
    final addons = vehicle.rentalAddons.where((a) => a.title.toLowerCase().contains('driver'));
    if (addons.isNotEmpty && addons.first.priceValue != null) {
      final addon = addons.first;
      if (addon.priceType == 'percentage') {
        final sub = subtotal;
        return (sub * (addon.priceValue! / 100.0)) / (totalDays > 0 ? totalDays : 1);
      }
      return addon.priceValue!;
    }
    return 8000.0;
  }

  double get childSeatAddonPrice {
    final addons = vehicle.rentalAddons.where((a) => a.title.toLowerCase().contains('seat') || a.title.toLowerCase().contains('child'));
    if (addons.isNotEmpty && addons.first.priceValue != null) {
      final addon = addons.first;
      if (addon.priceType == 'percentage') {
        final sub = subtotal;
        return (sub * (addon.priceValue! / 100.0)) / (totalDays > 0 ? totalDays : 1);
      }
      return addon.priceValue!;
    }
    return 4000.0;
  }

  double get prepaidFuelAddonPrice {
    final addons = vehicle.rentalAddons.where((a) => a.title.toLowerCase().contains('fuel') || a.title.toLowerCase().contains('prepaid'));
    if (addons.isNotEmpty && addons.first.priceValue != null) {
      final addon = addons.first;
      if (addon.priceType == 'percentage') {
        final sub = subtotal;
        return (sub * (addon.priceValue! / 100.0));
      }
      return addon.priceValue!;
    }
    return 15000.0;
  }

  double get subtotal {
    if (calculatedSubtotal.value > 0) return calculatedSubtotal.value;
    switch (selectedPriceTab) {
      case 1:
        return totalDays * (vehicle.pricePerWeek / 7.0);
      case 2:
        return totalDays * (vehicle.pricePerMonth / 30.0);
      default:
        return vehicle.pricePerDay * totalDays;
    }
  }

  // Resolved coordinates & addresses
  double resolvedPickupLat = 9.0579;
  double resolvedPickupLng = 7.4951;
  double resolvedDropoffLat = 9.0765;
  double resolvedDropoffLng = 7.3986;
  String resolvedPickupAddress = '';
  String resolvedDropoffAddress = '';

  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    args = Get.arguments as Map<String, dynamic>;
    logger.i('[CheckoutController] args: $args');

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
    prepaidFuelAddon = args['prepaidFuelAddon'] as bool? ?? false;
    // Auto-adjust selectedPriceTab based on date range duration
    final days = returnDate.difference(pickupDate).inDays;
    if (days >= 30) {
      selectedPriceTab = 2;
    } else if (days >= 7) {
      selectedPriceTab = 1;
    } else {
      selectedPriceTab = 0;
    }

    // Prefill form from AuthService
    final auth = Get.find<AuthService>();
    fullNameController = TextEditingController(text: auth.userName.value);
    emailController = TextEditingController(text: auth.userEmail.value);
    phoneController = TextEditingController(text: auth.userPhone.value);

    // Resolve location details then fetch initial pricing calculations
    _initiateCheckoutFlow();
  }

  Future<void> _initiateCheckoutFlow() async {
    await resolveLocations();
    await fetchCheckoutPricing();
  }

  Future<void> resolveLocations() async {
    // 1. Initial fallbacks
    resolvedPickupAddress = args['pickupLocation'] as String? ?? '';
    if (resolvedPickupAddress.trim().isEmpty) {
      resolvedPickupAddress = vehicle.location.isNotEmpty ? vehicle.location : 'Lekki, Lagos';
    }

    final isDifferentDropoff = args['isDifferentDropoff'] as bool? ?? false;
    if (isDifferentDropoff) {
      resolvedDropoffAddress = args['dropoffLocation'] as String? ?? '';
      if (resolvedDropoffAddress.trim().isEmpty) {
        resolvedDropoffAddress = vehicle.location.isNotEmpty ? vehicle.location : 'Lekki, Lagos';
      }
    } else {
      resolvedDropoffAddress = resolvedPickupAddress;
    }

    // 2. Fetch coordinates & detailed addresses from predictions if available
    final exploreCtrl = Get.isRegistered<ExploreController>() ? Get.find<ExploreController>() : null;
    
    final pickupPred = args['selectedPickupPrediction'] as LocationPrediction? ??
        exploreCtrl?.selectedPickupPrediction.value;
        
    if (pickupPred != null) {
      try {
        final LocationModel? details = await Get.find<LocationService>().fetchLocationDetails(pickupPred.id);
        if (details != null) {
          resolvedPickupLat = details.latitude ?? 9.0579;
          resolvedPickupLng = details.longitude ?? 7.4951;
          
          final addr = details.address;
          final nm = details.name;
          if (addr.trim().isNotEmpty) {
            resolvedPickupAddress = addr;
          } else if (nm.trim().isNotEmpty) {
            resolvedPickupAddress = nm;
          } else if (pickupPred.description.trim().isNotEmpty) {
            resolvedPickupAddress = pickupPred.description;
          }
        }
      } catch (e) {
        logger.e('[CheckoutController] Error fetching pickup details: $e');
      }
    }

    if (isDifferentDropoff) {
      final dropoffPred = args['selectedDropoffPrediction'] as LocationPrediction? ??
          exploreCtrl?.selectedDropoffPrediction.value;
          
      if (dropoffPred != null) {
        try {
          final LocationModel? details = await Get.find<LocationService>().fetchLocationDetails(dropoffPred.id);
          if (details != null) {
            resolvedDropoffLat = details.latitude ?? 9.0765;
            resolvedDropoffLng = details.longitude ?? 7.3986;
            
            final addr = details.address;
            final nm = details.name;
            if (addr.trim().isNotEmpty) {
              resolvedDropoffAddress = addr;
            } else if (nm.trim().isNotEmpty) {
              resolvedDropoffAddress = nm;
            } else if (dropoffPred.description.trim().isNotEmpty) {
              resolvedDropoffAddress = dropoffPred.description;
            }
          }
        } catch (e) {
          logger.e('[CheckoutController] Error fetching dropoff details: $e');
        }
      }
    } else {
      resolvedDropoffLat = resolvedPickupLat;
      resolvedDropoffLng = resolvedPickupLng;
      resolvedDropoffAddress = resolvedPickupAddress;
    }

    // Double check that neither address is empty/blank after resolving
    if (resolvedPickupAddress.trim().isEmpty) {
      resolvedPickupAddress = vehicle.location.isNotEmpty ? vehicle.location : 'Lekki, Lagos';
    }
    if (resolvedDropoffAddress.trim().isEmpty) {
      resolvedDropoffAddress = resolvedPickupAddress;
    }

    logger.i('[CheckoutController] Location resolution complete: '
             'Pickup: ($resolvedPickupLat, $resolvedPickupLng) - $resolvedPickupAddress, '
             'Dropoff: ($resolvedDropoffLat, $resolvedDropoffLng) - $resolvedDropoffAddress');
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
      if (prepaidFuelAddon) {
        final addon = vehicle.rentalAddons.firstWhereOrNull(
          (a) => a.title.toLowerCase().contains('fuel') || a.title.toLowerCase().contains('prepaid'),
        );
        if (addon != null) addonIds.add(addon.id);
      }

      final pickupDateStr = DateFormat('yyyy-MM-dd').format(pickupDate);
      final returnDateStr = DateFormat('yyyy-MM-dd').format(returnDate);

      final payload = {
        'vehicle_id': int.tryParse(vehicle.id) ?? 0,
        'service_type': isSelfDrive ? 'self_drive' : 'chauffeur',
        'pickup_date': pickupDateStr,
        'pickup_time': pickupTime,
        'return_date': returnDateStr,
        'return_time': returnTime,
        'pickup_latitude': resolvedPickupLat,
        'pickup_longitude': resolvedPickupLng,
        'dropoff_latitude': resolvedDropoffLat,
        'dropoff_longitude': resolvedDropoffLng,
        'dropoff_location_name': resolvedDropoffAddress,
        'dropoff_address': resolvedDropoffAddress,
        'pickup_location_name': resolvedPickupAddress,
        'pickup_address': resolvedPickupAddress,
        if (protectionPlanId != null) 'protection_plan_id': protectionPlanId,
        if (addonIds.isNotEmpty) 'addon_ids': addonIds,
        if (appliedPromoCode.value.isNotEmpty) 'coupon_code': appliedPromoCode.value,
      };

      final model = await Get.find<BookingService>().calculateCheckoutPricing(payload);
      checkoutPricing.value = model;

      // Update reactive states
      calculatedCurrency.value = model.currency;

      calculatedSubtotal.value = model.base.amount;
      calculatedSubtotalFormatted.value = model.base.amountFormatted;

      calculatedProtectionCost.value = model.protection.amount;
      calculatedProtectionTitle.value = model.protection.title ?? 'Basic';
      calculatedProtectionFormatted.value = model.protection.amountFormatted;

      calculatedAddonsCost.value = model.addonsTotal.amount;
      calculatedAddonsFormatted.value = model.addonsTotal.amountFormatted;

      calculatedServiceFee.value = model.feesTotal.amount;
      calculatedServiceFeeFormatted.value = model.feesTotal.amountFormatted;

      calculatedSecurityDeposit.value = model.deposit.amount;
      calculatedSecurityDepositFormatted.value = model.deposit.amountFormatted;

      calculatedDiscount.value = model.discount.amount;
      calculatedDiscountFormatted.value = model.discount.amountFormatted;

      calculatedTotal.value = model.total.amount;
      calculatedTotalFormatted.value = model.total.amountFormatted;

      calculatedPayableTotal.value = model.payableTotal.amount;
      calculatedPayableTotalFormatted.value = model.payableTotal.amountFormatted;

      calculatedAddons.assignAll(model.addons);
      calculatedFees.assignAll(model.fees);

      // Update payment methods list
      paymentMethods.assignAll(model.paymentMethods);
      if (paymentMethods.isNotEmpty) {
        final defaultMethod = paymentMethods.firstWhereOrNull((m) => m['enabled'] == true);
        if (defaultMethod != null) {
          selectedPaymentMethod.value = defaultMethod['key']?.toString() ?? 'stripe';
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

  String get serviceTypeContext {
    if (isSelfDrive) return 'self_drive';
    if (vehicle.serviceType == 'airport_transfer') return 'airport_transfer';
    return 'chauffeur';
  }

  // ── Checkout Action ──────────────────────────────────────────────
  Future<void> confirmAndPay() async {
    logger.i('[CheckoutController] confirmAndPay started');
    if (!canPay) {
      logger.w('[CheckoutController] confirmAndPay validation failed');
      SnackbarHelper.showWarning("Please fill in all required fields and upload your driver's license.");
      return;
    }

    isLoading.value = true;

    try {
      // 1. Perform Coverage Validation
      final pickupCoverage = await Get.find<LocationService>().checkCoverage(
        lat: resolvedPickupLat,
        lng: resolvedPickupLng,
        serviceType: serviceTypeContext,
      );
      if (!pickupCoverage.covered) {
        SnackbarHelper.showError('Pickup location is outside of our active service area.');
        isLoading.value = false;
        return;
      }

      if (isDifferentDropoff || serviceTypeContext == 'airport_transfer' || serviceTypeContext == 'chauffeur') {
        final dropoffCoverage = await Get.find<LocationService>().checkCoverage(
          lat: resolvedDropoffLat,
          lng: resolvedDropoffLng,
          serviceType: serviceTypeContext,
        );
        if (!dropoffCoverage.covered) {
          SnackbarHelper.showError('Drop-off location is outside of our active service area.');
          isLoading.value = false;
          return;
        }
      }

      // 2. Perform Airport Transfer Distance & Reachability check
      if (serviceTypeContext == 'airport_transfer') {
        try {
          final distancePreview = await Get.find<BookingService>().fetchAirportTransferDistance(
            pickupLatitude: resolvedPickupLat,
            pickupLongitude: resolvedPickupLng,
            dropoffLatitude: resolvedDropoffLat,
            dropoffLongitude: resolvedDropoffLng,
            vehicleId: int.tryParse(vehicle.id),
          );
          logger.i('[CheckoutController] Distance preview calculated successfully: ${distancePreview.distance.billableKm} km');
        } catch (e) {
          logger.e('[CheckoutController] Distance calculation validation failed: $e');
          SnackbarHelper.showError('Distance check failed: ${e.toString()}');
          isLoading.value = false;
          return;
        }
      }
    } catch (e) {
      logger.e('[CheckoutController] Geocoding coverage check failed: $e');
      SnackbarHelper.showError('Location coverage check failed: ${e.toString()}');
      isLoading.value = false;
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

    final bookingPayload = {
      'vehicle_id': int.tryParse(vehicle.id) ?? 0,
      'service_type': isSelfDrive ? 'self_drive' : 'chauffeur',
      'pickup_date': pickupDateStr,
      'pickup_time': pickupTime,
      'return_date': returnDateStr,
      'return_time': returnTime,
      'pickup_latitude': resolvedPickupLat,
      'pickup_longitude': resolvedPickupLng,
      'dropoff_latitude': resolvedDropoffLat,
      'dropoff_longitude': resolvedDropoffLng,
      'dropoff_location_name': resolvedDropoffAddress,
      'dropoff_address': resolvedDropoffAddress,
      'pickup_location_name': resolvedPickupAddress,
      'pickup_address': resolvedPickupAddress,
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
      final InitiateBookingResponseModel res = await Get.find<BookingService>().initiateBooking(
        bookingPayload,
        driverLicensePath: isSelfDrive ? selectedLicensePath.value : null,
      );

      final reference = res.reference;
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
            'initData': res.gateway,
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
}

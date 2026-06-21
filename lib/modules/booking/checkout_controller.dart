import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jkworlds/core/utils/snackbar_helper.dart';
import 'package:jkworlds/data/services/auth_service.dart';
import 'package:jkworlds/data/models/vehicle_model.dart';
import 'package:jkworlds/data/models/booking_model.dart';
import 'package:jkworlds/data/mock/mock_bookings.dart';
import 'package:jkworlds/modules/orders/orders_controller.dart';
import 'package:jkworlds/core/utils/image_picker_helper.dart';

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

  late final double initialSubtotal;
  late final double initialProtectionCost;
  late final double initialAddonsCost;
  late final double initialServiceFee;
  late final double initialSecurityDeposit;
  late final double initialTotal;

  // ── Form Controllers ─────────────────────────────────────────────
  late final TextEditingController fullNameController;
  late final TextEditingController emailController;
  late final TextEditingController phoneController;
  final flightNumberController = TextEditingController();
  final specialRequestsController = TextEditingController();

  // ── Driver License File ──────────────────────────────────────────
  final selectedLicensePath = ''.obs;

  // ── Payment Selection ────────────────────────────────────────────
  final selectedPaymentMethod = 'Stripe'.obs; // Stripe, PayPal, Flutterwave

  // ── Promo Code ───────────────────────────────────────────────────
  final promoCodeController = TextEditingController();
  final appliedPromoCode = ''.obs;
  final discountAmount = 0.0.obs;

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

    initialSubtotal = args['subtotal'] as double;
    initialProtectionCost = args['protectionCost'] as double;
    initialAddonsCost = args['addonsCost'] as double;
    initialServiceFee = args['serviceFee'] as double;
    initialSecurityDeposit = args['securityDeposit'] as double;
    initialTotal = args['total'] as double;

    // Prefill form from AuthService
    final auth = Get.find<AuthService>();
    fullNameController = TextEditingController(text: auth.userName.value);
    emailController = TextEditingController(text: auth.userEmail.value);
    phoneController = TextEditingController(text: auth.userPhone.value);
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

  // ── File Selection ───────────────────────────────────────────────
  Future<void> chooseLicenseFile() async {
    final path = await ImagePickerHelper.pickImageWithBottomSheet();
    if (path != null && path.isNotEmpty) {
      selectedLicensePath.value = path;
    }
  }

  // ── Promo Code Action ────────────────────────────────────────────
  void applyPromoCode() {
    final code = promoCodeController.text.trim().toUpperCase();
    if (code.isEmpty) return;

    if (code == 'WELCOME10') {
      // 10% discount on initial rental subtotal
      discountAmount.value = initialSubtotal * 0.10;
      appliedPromoCode.value = code;
      SnackbarHelper.showSuccess('10% discount applied to your rental base rate!');
    } else {
      SnackbarHelper.showError('This promo code is not valid.');
    }
  }

  double get totalAmount {
    final result = initialTotal - discountAmount.value;
    return result > 0 ? result : 0.0;
  }

  // ── Form Validation ──────────────────────────────────────────────
  bool get canPay {
    return fullNameController.text.trim().isNotEmpty &&
        emailController.text.trim().isNotEmpty &&
        phoneController.text.trim().isNotEmpty &&
        selectedLicensePath.value.isNotEmpty;
  }

  // ── Checkout Action ──────────────────────────────────────────────
  Future<void> confirmAndPay() async {
    if (!canPay) {
      SnackbarHelper.showWarning("Please fill in all required fields and upload your driver's license.");
      return;
    }

    isLoading.value = true;
    await Future.delayed(const Duration(milliseconds: 1200));

    // Combine Date and Times
    final pickupDateTime = _combineDateAndTime(pickupDate, pickupTime);
    final returnDateTime = _combineDateAndTime(returnDate, returnTime);

    // Create a new BookingModel
    final newBooking = BookingModel(
      id: 'BK-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
      vehicle: vehicle,
      pickupDate: pickupDateTime,
      returnDate: returnDateTime,
      pickupLocation: vehicle.location,
      status: BookingStatus.upcoming,
      rentalType: isSelfDrive ? RentalType.selfDrive : RentalType.chauffeur,
      subtotal: initialSubtotal,
      serviceFee: initialServiceFee,
      securityDeposit: initialSecurityDeposit,
      totalPrice: totalAmount,
      createdAt: DateTime.now(),
    );

    // Insert to global mockBookings
    mockBookings.insert(0, newBooking);

    // Trigger OrdersController reactive refresh
    if (Get.isRegistered<OrdersController>()) {
      Get.find<OrdersController>().allBookings.value = List.from(mockBookings);
    }

    isLoading.value = false;

    // Pop Checkout Screen and Details Screen back to Explore List
    Get.back();
    Get.back();

    SnackbarHelper.showSuccess('Your booking for ${vehicle.brand} ${vehicle.name} has been processed successfully.');
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

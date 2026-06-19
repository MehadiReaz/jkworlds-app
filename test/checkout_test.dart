import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';
import 'package:jkworlds/app/currency/currency_service.dart';
import 'package:jkworlds/data/services/auth_service.dart';
import 'package:jkworlds/data/mock/mock_vehicles.dart';
import 'package:jkworlds/data/mock/mock_bookings.dart';
import 'package:jkworlds/data/models/booking_model.dart';
import 'package:jkworlds/modules/booking/checkout_view.dart';
import 'package:jkworlds/modules/booking/checkout_controller.dart';
import 'package:jkworlds/modules/booking/checkout_binding.dart';

void main() {
  testWidgets('CheckoutView renders prefilled user details, summary, applies promo, and confirms payment', (WidgetTester tester) async {
    // Set a large screen size to ensure all layout elements build without overflow
    tester.view.physicalSize = const Size(1080, 2600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    // 1. Mock SharedPreferences with user info
    SharedPreferences.setMockInitialValues({
      'auth_token': 'mock_token_123',
      'auth_user_name': 'Chinedu Obi',
      'auth_user_email': 'chinedu@example.com',
      'auth_user_phone': '08031234567',
    });
    final prefs = await SharedPreferences.getInstance();
    Get.put<SharedPreferences>(prefs, permanent: true);

    // 2. Initialize global AuthService and CurrencyService
    Get.put(AuthService(), permanent: true);
    Get.put(CurrencyService(), permanent: true);

    // 3. Pump the GetMaterialApp with an empty scaffold
    await tester.pumpWidget(
      GetMaterialApp(
        home: const Scaffold(body: SizedBox()),
      ),
    );
    await tester.pumpAndSettle();

    // 4. Create mock booking arguments from configurator (RAV4, 2 days, GPS addon)
    final testVehicle = mockVehicles[10]; // Toyota RAV4, 55,000 NGN
    final arguments = {
      'vehicle': testVehicle,
      'pickupDate': DateTime(2026, 6, 12),
      'returnDate': DateTime(2026, 6, 14), // 2 days
      'pickupTime': '10:00',
      'returnTime': '12:00',
      'isSelfDrive': true,
      'selectedProtection': 'Basic',
      'gpsAddon': true, // +5,000/day = 10,000
      'additionalDriverAddon': false,
      'childSeatAddon': false,
      'subtotal': 110000.0,
      'protectionCost': 0.0,
      'addonsCost': 10000.0,
      'serviceFee': 5500.0,
      'securityDeposit': 100000.0,
      'total': 225500.0,
    };

    // 5. Navigate to CheckoutView with arguments
    Get.to(
      () => const CheckoutView(),
      arguments: arguments,
      binding: CheckoutBinding(),
    );
    await tester.pumpAndSettle();

    final controller = Get.find<CheckoutController>();

    // 6. Verify prefilled user details in Form inputs
    expect(find.text('Chinedu Obi'), findsOneWidget);
    expect(find.text('chinedu@example.com'), findsOneWidget);
    expect(find.text('08031234567'), findsOneWidget);

    // Verify summary breakdown calculations render correctly
    expect(find.text('BOOKING SUMMARY'), findsOneWidget);
    expect(find.text('Base (2d x ₦55,000)'), findsOneWidget);
    expect(find.text('₦110,000'), findsOneWidget);
    expect(find.text('₦225,500'), findsOneWidget); // Initial total amount


    // Verify add-on cost
    expect(find.text('+₦10,000'), findsOneWidget);

    // Verify Stripe payment option is visible
    expect(find.text('Stripe'), findsOneWidget);
    expect(find.text('Credit / Debit Card'), findsOneWidget);

    // 7. Test Promo Code application ('WELCOME10' gives 10% off subtotal: -₦11,000)
    // New total expected: 225,500 - 11,000 = 214,500 NGN
    final promoInput = find.widgetWithText(TextField, 'Enter promo code');
    expect(promoInput, findsOneWidget);
    await tester.enterText(promoInput, 'WELCOME10');
    await tester.pumpAndSettle();

    final applyButton = find.widgetWithText(ElevatedButton, 'Apply');
    expect(applyButton, findsOneWidget);
    await tester.tap(applyButton);
    await tester.pumpAndSettle();

    // Verify new total price
    expect(find.text('₦214,500'), findsOneWidget);

    // 8. Test Driver License upload simulation
    // Initially checkout button is disabled because no license file is chosen
    final payButton = find.widgetWithText(FilledButton, 'Confirm & Pay');
    expect(payButton, findsOneWidget);
    await tester.tap(payButton);
    await tester.pumpAndSettle();

    // Check that booking is not created yet
    expect(controller.canPay, isFalse);

    // Mock license upload path on controller
    controller.selectedLicensePath.value = 'assets/license.png';
    await tester.pumpAndSettle();

    // Verify file name display updates
    expect(find.text('license.png'), findsOneWidget);
    expect(controller.canPay, isTrue);

    // 9. Confirm & Complete Checkout
    final initialBookingCount = mockBookings.length;
    await tester.tap(payButton);

    // Wait for simulated checkout payment process delay
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();

    // Verify a new booking is registered in the list database
    expect(mockBookings.length, initialBookingCount + 1);
    expect(mockBookings[0].vehicle?.id ?? mockBookings[0].vehicleId?.toString(), 'v11');
    expect(mockBookings[0].totalPrice, 214500.0);

    // Pump to let getx success snackbar timer dismiss safely
    await tester.pumpAndSettle(const Duration(seconds: 5));

    // Clean up
    Get.reset();
  });
}

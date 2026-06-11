import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';
import 'package:jkworlds/app/routes/app_pages.dart';
import 'package:jkworlds/app/currency/currency_service.dart';
import 'package:jkworlds/data/mock/mock_vehicles.dart';
import 'package:jkworlds/data/mock/mock_bookings.dart';
import 'package:jkworlds/data/models/booking_model.dart';
import 'package:jkworlds/modules/vehicle_detail/vehicle_detail_view.dart';
import 'package:jkworlds/modules/vehicle_detail/vehicle_detail_controller.dart';
import 'package:jkworlds/modules/vehicle_detail/vehicle_detail_binding.dart';
import 'package:jkworlds/modules/booking/checkout_view.dart';
import 'package:jkworlds/data/services/auth_service.dart';


void main() {
  testWidgets('VehicleDetailView renders specifications, policies, reviews, and interactive booking configurator', (WidgetTester tester) async {
    // Set a large screen size to ensure all scrollable content renders without clipping issues
    tester.view.physicalSize = const Size(1080, 3600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    // 1. Mock SharedPreferences
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    Get.put<SharedPreferences>(prefs, permanent: true);

    // 2. Initialize CurrencyService and AuthService
    Get.put(CurrencyService(), permanent: true);
    Get.put(AuthService(), permanent: true);


    // 3. Pump the GetMaterialApp registering AppPages.pages
    await tester.pumpWidget(
      GetMaterialApp(
        getPages: AppPages.pages,
        home: const Scaffold(body: SizedBox()),
      ),
    );
    await tester.pumpAndSettle();

    // 4. Navigate to details view with arguments
    // Use RAV4 (index 10) as test vehicle
    final testVehicle = mockVehicles[10];
    Get.to(
      () => const VehicleDetailView(),
      arguments: testVehicle,
      binding: VehicleDetailBinding(),
    );
    await tester.pumpAndSettle();

    final controller = Get.find<VehicleDetailController>();

    // 5. Verify specifications rendering
    expect(find.text('Toyota RAV4'), findsWidgets);
    expect(find.text('SEATS'), findsOneWidget);
    expect(find.text('5'), findsWidgets); // 5 seats spec & reviews rating references
    expect(find.text('TRANSMISSION'), findsOneWidget);
    expect(find.text('Auto'), findsWidgets);
    expect(find.text('FUEL'), findsOneWidget);
    expect(find.text('Hybrid'), findsWidgets);
    expect(find.text('LOCATION'), findsOneWidget);
    expect(find.text('Lekki'), findsWidgets);

    // Verify plate and odometer details
    expect(find.text('LG-890-IKJ'), findsOneWidget);
    expect(find.text('9,500 km'), findsOneWidget);

    // Verify About this vehicle section and content
    expect(find.text('About this vehicle'), findsOneWidget);
    expect(find.text(testVehicle.description), findsOneWidget);

    // Verify Policy cards and titles
    expect(find.text('Mileage Policy'), findsOneWidget);
    expect(find.text('Rental Requirements'), findsOneWidget);
    expect(find.text("What's Included"), findsOneWidget);

    // Verify alert cards (both texts appear in the bullet points list and inside the warning/info alert card titles)
    expect(find.text('Refundable Security Deposit'), findsNWidgets(2));
    expect(find.text('Free Cancellation'), findsNWidgets(2));

    // Verify customer reviews header
    expect(find.text('Customer Reviews'), findsOneWidget);

    // 6. Test Interactive booking form calculations
    // Initially, dates are null, so price breakdown should show placeholder prompt
    expect(find.text('Select pickup & return dates to see price breakdown.'), findsOneWidget);

    // Configure dates and times on the controller directly
    final now = DateTime.now();
    controller.pickupDate.value = DateTime(now.year, now.month, now.day + 1);
    controller.returnDate.value = DateTime(now.year, now.month, now.day + 3); // 2 days duration
    controller.pickupTime.value = '10:00';
    controller.returnTime.value = '12:00';
    await tester.pumpAndSettle();

    // Confirm that the breakdown is shown and the placeholder prompt is hidden
    expect(find.text('Select pickup & return dates to see price breakdown.'), findsNothing);
    expect(find.text('Rental Rate'), findsOneWidget);
    expect(find.text('Service Fee'), findsOneWidget);
    expect(find.text('Total Price'), findsOneWidget);

    // Initial breakdown calculations for RAV4 (₦55,000 per day for 2 days):
    // Subtotal: 110,000 NGN
    // Protection: Basic (0 NGN)
    // Add-ons: 0 NGN
    // Service fee: 5,500 NGN
    // Security deposit: 100,000 NGN (SUV)
    // Total expected: 215,500 NGN
    expect(find.text('₦110,000'), findsOneWidget); // Subtotal
    expect(find.text('₦5,500'), findsOneWidget); // Service fee
    expect(find.text('₦100,000'), findsWidgets); // Security deposit alert + breakdown row
    expect(find.text('₦215,500'), findsOneWidget); // Initial total price

    // 7. Select Premium Protection Plan (+15% of subtotal)
    // 110,000 * 0.15 = 16,500 NGN
    // New total expected: 215,500 + 16,500 = 232,000 NGN
    final premiumPlan = find.text('Premium Protection');
    expect(premiumPlan, findsOneWidget);
    await tester.ensureVisible(premiumPlan);
    await tester.tap(premiumPlan);
    await tester.pumpAndSettle();

    expect(find.text('Premium Protection'), findsWidgets);
    expect(find.text('₦16,500'), findsOneWidget); // Protection cost
    expect(find.text('₦232,000'), findsOneWidget); // New total price

    // 8. Select GPS Navigation Add-on (+₦5,000/day = 10,000 NGN for 2 days)
    // New total expected: 232,000 + 10,000 = 242,000 NGN
    final gpsCheckbox = find.text('GPS Navigation');
    expect(gpsCheckbox, findsOneWidget);
    await tester.ensureVisible(gpsCheckbox);
    await tester.tap(gpsCheckbox);
    await tester.pumpAndSettle();

    expect(find.text('₦10,000'), findsOneWidget); // Addon cost
    expect(find.text('₦242,000'), findsOneWidget); // New total price

    // 9. Verify Checkout navigation when clicking Reserve Now
    final reserveButton = find.widgetWithText(FilledButton, 'Reserve Now');
    expect(reserveButton, findsOneWidget);
    await tester.ensureVisible(reserveButton);
    await tester.tap(reserveButton);
    await tester.pumpAndSettle();

    // Verify it navigated to the Checkout page
    expect(Get.currentRoute, '/checkout');
    expect(find.byType(CheckoutView), findsOneWidget);

    // Clean up
    Get.reset();
  });
}

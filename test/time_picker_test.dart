import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:jkworlds/app/currency/currency_service.dart';
import 'package:jkworlds/data/services/auth_service.dart';
import 'package:jkworlds/data/services/category_service.dart';
import 'package:jkworlds/data/services/booking_service.dart';
import 'package:jkworlds/data/services/location_service.dart';
import 'package:jkworlds/modules/explore/explore_controller.dart';
import 'package:jkworlds/modules/home/home_controller.dart';
import 'package:jkworlds/modules/main_nav/main_nav_controller.dart';
import 'package:jkworlds/modules/home/home_view.dart';
import 'package:jkworlds/modules/explore/explore_view.dart';
import 'package:jkworlds/data/services/app_data_service.dart';
import 'mocks.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({
      'auth_token': 'mock_token',
      'auth_user_name': 'Mehadi',
      'auth_user_email': 'mehadi@test.com',
    });
    final prefs = await SharedPreferences.getInstance();
    Get.put<SharedPreferences>(prefs, permanent: true);
    Get.put(CurrencyService(), permanent: true);
    Get.put(AuthService(), permanent: true);
    Get.put<CategoryService>(MockCategoryService(), permanent: true);
    Get.put<BookingService>(MockBookingService(), permanent: true);
    Get.put<LocationService>(MockLocationService(), permanent: true);
    Get.put(MainNavController(), permanent: true);
    Get.put(AppDataService(), permanent: true);
  });

  tearDown(() {
    Get.reset();
  });

  testWidgets('HomeView custom time bottom sheet interactions', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    Get.put(ExploreController());
    Get.put(HomeController());
    addTearDown(() {
      Get.delete<HomeController>(force: true);
      Get.delete<ExploreController>(force: true);
    });

    await tester.pumpWidget(
      GetMaterialApp(
        home: const HomeView(),
      ),
    );
    await tester.pumpAndSettle();

    // 1. Open the pickup location bottom sheet
    final enterPickupBtn = find.text('Enter pick-up location');
    expect(enterPickupBtn, findsOneWidget);
    await tester.tap(enterPickupBtn);
    await tester.pumpAndSettle();

    // Drag to bring 'Select Time' buttons into view
    await tester.drag(find.byType(SingleChildScrollView).last, const Offset(0, -400));
    await tester.pumpAndSettle();

    // Verify 'Select Time' button is visible
    final selectTimeFinder = find.text('Select Time');
    expect(selectTimeFinder, findsNWidgets(2)); // pickup and drop-off

    // 2. Tap the first 'Select Time' button to open time picker bottom sheet
    await tester.tap(selectTimeFinder.first);
    await tester.pumpAndSettle();

    // Verify custom time list bottom sheet is opened
    expect(find.text('Opening Times: 6:00 AM - 12:00 AM'), findsOneWidget);
    expect(find.text('Early Morning'), findsOneWidget);
    expect(find.text('Morning - afternoon'), findsOneWidget);
    expect(find.text('Evening - Night'), findsOneWidget);

    // Verify specific slot exists, ensure visible, and tap it
    final slot1200 = find.text('12:00 PM');
    await tester.ensureVisible(slot1200);
    await tester.pumpAndSettle();
    await tester.tap(slot1200);
    await tester.pumpAndSettle();

    // Bottom sheet should be dismissed, check that '12:00 PM' is now shown in UI
    expect(find.text('12:00 PM'), findsOneWidget);
    expect(find.text('Select Time'), findsOneWidget); // drop-off is still unselected

    // 3. Tap the remaining 'Select Time' button for drop-off
    await tester.tap(find.text('Select Time'));
    await tester.pumpAndSettle();

    // Tap '5:30 PM'
    final slot530 = find.text('5:30 PM');
    await tester.ensureVisible(slot530);
    await tester.pumpAndSettle();
    await tester.tap(slot530);
    await tester.pumpAndSettle();

    // Check updated values
    expect(find.text('12:00 PM'), findsOneWidget);
    expect(find.text('5:30 PM'), findsOneWidget);

    Get.delete<HomeController>(force: true);
  });

  testWidgets('ExploreView custom time bottom sheet interactions', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final ctrl = Get.put(ExploreController());

    await tester.pumpWidget(
      GetMaterialApp(
        home: const ExploreView(),
      ),
    );
    await tester.pumpAndSettle();

    // Set initial pickup/dropoff date so that they don't trigger warning snackbars
    ctrl.pickupDateTime.value = DateTime.now().add(const Duration(days: 1));
    ctrl.dropoffDateTime.value = DateTime.now().add(const Duration(days: 3));
    await tester.pumpAndSettle();

    // Tap the Trip Summary Card to open the Trip Details bottom sheet
    await tester.tap(find.text('Enter pick-up location'));
    await tester.pumpAndSettle();

    // 1. Tap PICK-UP DATE box containing the formatted date
    final pickupDateStr = DateFormat('MMM d, yyyy').format(ctrl.pickupDateTime.value!);
    final pickupBtn = find.text(pickupDateStr);
    expect(pickupBtn, findsOneWidget);
    await tester.tap(pickupBtn);
    await tester.pumpAndSettle();

    // Tap SAVE on the default date range picker dialog
    final saveBtn = find.byWidgetPredicate((widget) => widget is Text && widget.data?.toUpperCase() == 'SAVE');
    expect(saveBtn, findsOneWidget);
    await tester.tap(saveBtn);
    await tester.pumpAndSettle();

    // Time picker bottom sheet should open
    expect(find.text('Opening Times: 6:00 AM - 12:00 AM'), findsOneWidget);

    // Tap '9:30 AM'
    final slot930 = find.text('9:30 AM');
    await tester.ensureVisible(slot930);
    await tester.pumpAndSettle();
    await tester.tap(slot930);
    await tester.pumpAndSettle();

    // Verify time matches
    expect(ctrl.pickupDateTime.value, isNotNull);
    expect(ctrl.pickupDateTime.value!.hour, 9);
    expect(ctrl.pickupDateTime.value!.minute, 30);
  });
}

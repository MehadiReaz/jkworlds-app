import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';
import 'package:jkworlds/app/currency/currency_service.dart';
import 'package:jkworlds/data/services/category_service.dart';
import 'package:jkworlds/data/services/location_service.dart';
import 'package:jkworlds/modules/explore/explore_view.dart';
import 'package:jkworlds/modules/explore/explore_controller.dart';
import 'mocks.dart';

void main() {
  testWidgets('ExploreView renders search fields, interactive filters, and car cards', (WidgetTester tester) async {
    // Set a large screen size to ensure widgets are built and visible without scrolling issues
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    // 1. Mock SharedPreferences
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    Get.put<SharedPreferences>(prefs, permanent: true);

    Get.put<CategoryService>(MockCategoryService(), permanent: true);
    Get.put<LocationService>(MockLocationService(), permanent: true);

    // 2. Initialize CurrencyService and ExploreController
    Get.put(CurrencyService(), permanent: true);
    final ctrl = Get.put(ExploreController());

    // 3. Pump the widget
    await tester.pumpWidget(
      GetMaterialApp(
        home: const ExploreView(),
      ),
    );
    await tester.pumpAndSettle();

    print('DEBUG: categories length = ${Get.find<CategoryService>().categories.length}');
    print('DEBUG: filteredVehicles length = ${ctrl.filteredVehicles.length}');

    // 4. Verify search section headers and initial state
    expect(find.text('Search Options'), findsOneWidget);
    expect(find.text('Pick-up Location'), findsOneWidget);
    expect(find.text('Different Drop-off Location?'), findsOneWidget);
    expect(find.text('PICK-UP DATE & TIME'), findsOneWidget);
    expect(find.text('DROP-OFF DATE & TIME'), findsOneWidget);
    expect(find.text('Require Chauffeur Service?'), findsOneWidget);

    // 5. Verify initial car cards are rendered
    // Under "Top Rated" sorting, Mercedes-Benz S-Class has 5.0 rating and should be first/visible.
    expect(find.text('Mercedes-Benz S-Class'), findsOneWidget);
    expect(find.text('Toyota Land Cruiser V8'), findsOneWidget);

    // Verify category headers and pricing labels
    expect(find.text('PREMIUM LUXURY'), findsWidgets);
    expect(find.text('RESERVE NOW'), findsWidgets);

    // 6. Test Pick-up Location filtering
    final pickupField = find.widgetWithText(TextField, 'Pick-up Location');
    expect(pickupField, findsOneWidget);

    // Type 'Lekki' to match Lekki vehicles (e.g. Toyota Camry XLE, Toyota RAV4)
    await tester.enterText(pickupField, 'Lekki');
    await tester.pumpAndSettle();

    // Verify that the list has updated (e.g. Land Cruiser from Victoria Island is filtered out)
    expect(find.text('Toyota Land Cruiser V8'), findsNothing);
    expect(find.text('Toyota Camry XLE'), findsOneWidget);
    expect(find.text('Toyota RAV4'), findsOneWidget);

    // Reset location filter
    await tester.enterText(pickupField, '');
    await tester.pumpAndSettle();
    expect(find.text('Toyota Land Cruiser V8'), findsOneWidget);

    // 7. Test interactive filters section
    // Tap 'Filters & Sorting' button to expand the drawer
    final filterToggleBtn = find.text('Filters & Sorting');
    expect(filterToggleBtn, findsOneWidget);
    await tester.tap(filterToggleBtn);
    await tester.pumpAndSettle();

    // Verify filter headers are shown
    expect(find.text('CATEGORY'), findsOneWidget);
    expect(find.text('SERVICE TYPE'), findsOneWidget);
    expect(find.text('TRANSMISSION'), findsOneWidget);
    expect(find.text('FUEL TYPE'), findsOneWidget);
    expect(find.text('SORT BY'), findsOneWidget);

    // Tap 'SUV' category chip
    final suvChip = find.text('SUV');
    expect(suvChip, findsOneWidget);
    await tester.tap(suvChip);
    await tester.pumpAndSettle();

    // Verify only SUVs are shown
    expect(find.text('Toyota Land Cruiser V8'), findsOneWidget);
    expect(find.text('Mercedes-Benz S-Class'), findsNothing);

    // Tap 'All' to clear category filter
    final allCategoryChip = find.descendant(
      of: find.ancestor(of: suvChip, matching: find.byType(Row)),
      matching: find.text('All'),
    ).first;
    await tester.tap(allCategoryChip);
    await tester.pumpAndSettle();

    // 8. Test Sorting Options
    // Tap 'Price: Low to High' chip under SORT BY section
    final lowToHighChip = find.text('Price: Low to High');
    expect(lowToHighChip, findsOneWidget);
    await tester.ensureVisible(lowToHighChip);
    await tester.tap(lowToHighChip);
    await tester.pumpAndSettle();

    // The cheapest car (Honda Accord, 40,000 NGN) should be visible
    expect(find.text('Honda Accord'), findsOneWidget);


    // Clean up
    Get.reset();
  });
}

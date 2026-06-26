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

    // 4. Verify trip summary card initial state
    expect(find.text('Select Location'), findsOneWidget);
    expect(find.text('Select Dates'), findsOneWidget);

    // Tap trip summary card to open details bottom sheet
    await tester.tap(find.text('Select Location'));
    await tester.pumpAndSettle();

    // Verify search options are present in details sheet
    expect(find.text('Trip Details'), findsOneWidget);
    expect(find.text('Pick-up Location'), findsOneWidget);
    expect(find.text('Different Drop-off Location'), findsNothing);
    expect(find.text('PICK-UP DATE & TIME'), findsOneWidget);
    expect(find.text('DROP-OFF DATE & TIME'), findsOneWidget);
    expect(find.text('Require Chauffeur Service'), findsOneWidget);

    // Toggle Chauffeur Service to show Different Drop-off Location
    await tester.tap(find.text('Require Chauffeur Service'));
    await tester.pumpAndSettle();
    expect(find.text('Different Drop-off Location'), findsOneWidget);

    // Toggle Chauffeur Service back to false to restore original state
    await tester.tap(find.text('Require Chauffeur Service'));
    await tester.pumpAndSettle();
    expect(find.text('Different Drop-off Location'), findsNothing);

    // 5. Test Pick-up Location filtering
    final pickupField = find.widgetWithText(TextField, 'Pick-up Location');
    expect(pickupField, findsOneWidget);

    // Type 'Lekki' to match Lekki vehicles
    await tester.enterText(pickupField, 'Lekki');
    await tester.pumpAndSettle();

    // Tap Apply Details to close the bottom sheet and apply
    await tester.tap(find.text('Apply Details'));
    await tester.pumpAndSettle();

    // Verify that the list has updated (Toyota Land Cruiser from Victoria Island is filtered out)
    expect(find.text('Toyota Land Cruiser V8'), findsNothing);
    expect(find.text('Toyota Camry XLE'), findsOneWidget);
    expect(find.text('Toyota RAV4'), findsOneWidget);

    // Tap Lekki summary card to open details bottom sheet again
    await tester.tap(find.text('Lekki'));
    await tester.pumpAndSettle();

    // Reset location filter
    final pickupFieldAgain = find.widgetWithText(TextField, 'Pick-up Location');
    await tester.enterText(pickupFieldAgain, '');
    await tester.pumpAndSettle();

    // Tap Apply Details
    await tester.tap(find.text('Apply Details'));
    await tester.pumpAndSettle();

    // Land Cruiser should be back
    expect(find.text('Toyota Land Cruiser V8'), findsOneWidget);

    // 6. Verify initial car cards are rendered
    expect(find.text('Mercedes-Benz S-Class'), findsOneWidget);
    expect(find.text('RESERVE NOW'), findsWidgets);

    // 7. Test Quick Category selector (All, Sedan, SUV, Luxury, Van horizontal chips)
    // Tap 'SUV' category card in the quick category bar
    final suvQuickCard = find.text('SUV');
    expect(suvQuickCard, findsOneWidget);
    await tester.tap(suvQuickCard);
    await tester.pumpAndSettle();

    // Verify only SUVs are shown
    expect(find.text('Toyota Land Cruiser V8'), findsOneWidget);
    expect(find.text('Mercedes-Benz S-Class'), findsNothing);

    // Tap 'All' in the quick category bar to reset category filter
    final allQuickCard = find.text('All');
    expect(allQuickCard, findsOneWidget);
    await tester.tap(allQuickCard);
    await tester.pumpAndSettle();

    // Both should be visible again
    expect(find.text('Mercedes-Benz S-Class'), findsOneWidget);
    expect(find.text('Toyota Land Cruiser V8'), findsOneWidget);

    // 8. Test Filters & Sorting Bottom Sheet
    // Tap the tune/filter button on the summary card
    final tuneBtn = find.byIcon(Icons.tune_rounded);
    expect(tuneBtn, findsOneWidget);
    await tester.tap(tuneBtn);
    await tester.pumpAndSettle();

    // Verify filter sheet contents
    expect(find.text('Filters & Sorting'), findsOneWidget);
    expect(find.text('CATEGORY'), findsOneWidget);
    expect(find.text('SERVICE TYPE'), findsOneWidget);
    expect(find.text('TRANSMISSION'), findsOneWidget);
    expect(find.text('FUEL TYPE'), findsOneWidget);
    expect(find.text('SORT BY'), findsOneWidget);

    // Tap 'Price: Low to High' chip under SORT BY section
    final lowToHighChip = find.text('Price: Low to High');
    expect(lowToHighChip, findsOneWidget);
    await tester.ensureVisible(lowToHighChip);
    await tester.tap(lowToHighChip);
    await tester.pumpAndSettle();

    // Apply filters
    await tester.tap(find.text('Apply Filters'));
    await tester.pumpAndSettle();

    // The cheapest car (Honda Accord, 40,000 NGN) should be visible
    expect(find.text('Honda Accord'), findsOneWidget);

    // Clean up
    Get.reset();
  });
}

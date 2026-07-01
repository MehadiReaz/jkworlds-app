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
    expect(find.text('Enter pick-up location'), findsOneWidget);

    // Tap trip summary card to open details bottom sheet
    await tester.tap(find.text('Enter pick-up location'));
    await tester.pumpAndSettle();

    // Verify search options are present in details sheet
    final bottomSheet = find.byType(SingleChildScrollView);
    expect(find.text('Book Your Ride'), findsOneWidget);
    expect(find.descendant(of: bottomSheet, matching: find.text('PICK-UP LOCATION')), findsOneWidget);
    expect(find.descendant(of: bottomSheet, matching: find.text('PICK-UP DATE & TIME')), findsOneWidget);
    expect(find.descendant(of: bottomSheet, matching: find.text('DROP-OFF DATE & TIME')), findsOneWidget);

    // Tap 'Airport Transfer' tab inside the bottom sheet
    final airportTabInSheet = find.descendant(
      of: find.byType(SingleChildScrollView),
      matching: find.text('Airport Transfer'),
    );
    expect(airportTabInSheet, findsOneWidget);
    await tester.tap(airportTabInSheet);
    await tester.pumpAndSettle();

    // Verify Airport Transfer fields are shown
    expect(find.text('DESTINATION'), findsOneWidget);
    expect(find.text('PICKUP DATE'), findsOneWidget);

    // Switch back to 'Cars' tab inside the bottom sheet
    final carsTabInSheet = find.descendant(
      of: find.byType(SingleChildScrollView),
      matching: find.text('Cars'),
    );
    expect(carsTabInSheet, findsOneWidget);
    await tester.tap(carsTabInSheet);
    await tester.pumpAndSettle();

    // 5. Test Pick-up Location filtering
    final pickupField = find.widgetWithText(TextField, 'Enter pick-up location');
    expect(pickupField, findsOneWidget);

    // Type 'Lekki' to match Lekki vehicles
    await tester.enterText(pickupField, 'Lekki');
    await tester.pumpAndSettle();

    // Tap Show Vehicles to close the bottom sheet and apply
    await tester.tap(find.text('Show Vehicles'));
    await tester.pumpAndSettle();

    // Verify that the list has updated (Toyota Land Cruiser from Victoria Island is filtered out)
    expect(find.text('Toyota Land Cruiser V8'), findsNothing);
    expect(find.text('Toyota Camry XLE'), findsOneWidget);
    expect(find.text('Toyota RAV4'), findsOneWidget);

    // Tap Lekki summary card to open details bottom sheet again
    await tester.tap(find.text('Lekki'));
    await tester.pumpAndSettle();

    // Reset location filter
    final pickupFieldAgain = find.widgetWithText(TextField, 'Enter pick-up location');
    await tester.enterText(pickupFieldAgain, '');
    await tester.pumpAndSettle();

    // Tap Show Vehicles
    await tester.tap(find.text('Show Vehicles'));
    await tester.pumpAndSettle();

    // Land Cruiser should be back
    expect(find.text('Toyota Land Cruiser V8'), findsOneWidget);

    // 6. Verify initial car cards are rendered
    expect(find.text('Mercedes-Benz S-Class'), findsOneWidget);
    expect(find.text('RESERVE NOW'), findsWidgets);

    // 7. Test Quick Service Tab selector (Cars and Airport Transfer tabs)
    // Tap 'Airport Transfer' tab button in the quick service tab selector
    final airportTransferTab = find.text('Airport Transfer');
    expect(airportTransferTab, findsOneWidget);
    await tester.tap(airportTransferTab);
    await tester.pumpAndSettle();

    // Verify only vehicles with chauffeur are shown (Toyota Camry XLE has hasChauffeur: false, so it shouldn't show)
    expect(find.text('Mercedes-Benz S-Class'), findsOneWidget);
    expect(find.text('Toyota Camry XLE'), findsNothing);

    // Tap 'Cars' tab to reset service tab filter
    final carsTab = find.text('Cars');
    expect(carsTab, findsOneWidget);
    await tester.tap(carsTab);
    await tester.pumpAndSettle();

    // Both should be visible again
    expect(find.text('Mercedes-Benz S-Class'), findsOneWidget);

    // Scroll down to bring Toyota Camry XLE into view
    await tester.drag(find.byType(CustomScrollView), const Offset(0, -600));
    await tester.pumpAndSettle();

    expect(find.text('Toyota Camry XLE'), findsOneWidget);

    // Scroll back up to the top to bring the summary card and tune button back into view
    await tester.drag(find.byType(CustomScrollView), const Offset(0, 600));
    await tester.pumpAndSettle();

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

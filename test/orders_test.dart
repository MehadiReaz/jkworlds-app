import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';
import 'package:jkworlds/app/currency/currency_service.dart';
import 'package:jkworlds/app/translations/app_translations.dart';
import 'package:jkworlds/modules/orders/orders_view.dart';
import 'package:jkworlds/modules/orders/orders_controller.dart';

void main() {
  testWidgets('OrdersView renders filter chips and bookings table correctly', (WidgetTester tester) async {
    // Mock SharedPreferences
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    Get.put<SharedPreferences>(prefs, permanent: true);

    // Initialize CurrencyService
    Get.put(CurrencyService(), permanent: true);

    // Initialize OrdersController
    Get.put(OrdersController());

    // Pump widget
    await tester.pumpWidget(
      GetMaterialApp(
        translations: AppTranslations(),
        locale: const Locale('en', 'US'),
        home: const OrdersView(),
      ),
    );
    await tester.pumpAndSettle();

    // Verify AppBar Title and headers are rendered
    expect(find.text('My Bookings'), findsOneWidget);
    expect(find.text('Car'), findsOneWidget);
    expect(find.text('Date'), findsOneWidget);
    expect(find.text('Status'), findsOneWidget);
    expect(find.text('Amount'), findsOneWidget);

    // Verify bookings list elements are rendered
    expect(find.text('Toyota Land Cruiser V8'), findsOneWidget);
    expect(find.text('Mercedes-Benz E-Class'), findsOneWidget);
    expect(find.text('BMW 5 Series'), findsOneWidget);

    // Verify status states
    expect(find.text('ACTIVE'), findsOneWidget);
    expect(find.text('CONFIRMED'), findsOneWidget);
    expect(find.text('COMPLETED'), findsOneWidget);

    // Verify filtering works by tapping the 'Confirmed' chip
    await tester.tap(find.text('Confirmed'));
    await tester.pumpAndSettle();

    // Now only Confirmed booking should be visible
    expect(find.text('Mercedes-Benz E-Class'), findsOneWidget);
    expect(find.text('Toyota Land Cruiser V8'), findsNothing);
    expect(find.text('BMW 5 Series'), findsNothing);

    // Clean up
    Get.reset();
  });
}

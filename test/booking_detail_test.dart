import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';
import 'package:jkworlds/app/routes/app_pages.dart';
import 'package:jkworlds/app/currency/currency_service.dart';
import 'package:jkworlds/data/services/booking_service.dart';
import 'package:jkworlds/data/services/auth_service.dart';
import 'package:jkworlds/modules/booking_detail/booking_detail_view.dart';
import 'package:jkworlds/modules/booking_detail/booking_detail_binding.dart';
import 'mocks.dart';

void main() {
  testWidgets('BookingDetailsView renders states and dynamic booking details correctly', (WidgetTester tester) async {
    // Mock SharedPreferences
    SharedPreferences.setMockInitialValues({
      'auth_token': 'mock_token',
      'auth_user_name': 'Mehadi',
      'auth_user_email': 'mehadi@test.com',
    });
    final prefs = await SharedPreferences.getInstance();
    Get.put<SharedPreferences>(prefs, permanent: true);

    Get.put(CurrencyService(), permanent: true);
    Get.put(AuthService(), permanent: true);
    Get.put<BookingService>(MockBookingService(), permanent: true);

    // Pump widget app
    await tester.pumpWidget(
      GetMaterialApp(
        getPages: AppPages.pages,
        home: const Scaffold(body: SizedBox()),
      ),
    );
    await tester.pumpAndSettle();

    // Navigate to BookingDetailsView with mock ID 1001
    Get.to(
      () => const BookingDetailsView(),
      arguments: 1001,
      binding: BookingDetailsBinding(),
    );

    // Let it build and layout
    await tester.pumpAndSettle();

    // Verify AppBar Title and elements are rendered
    expect(find.text('Booking Details'), findsOneWidget);
    
    // Check that booking ID string and vehicle name is rendered
    expect(find.text('Booking #BK-1001'), findsOneWidget);
    expect(find.text('Land Cruiser V8'), findsOneWidget);
    expect(find.text('ACTIVE'), findsOneWidget);

    // Clean up
    Get.reset();
  });
}

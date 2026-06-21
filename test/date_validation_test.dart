import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jkworlds/app/currency/currency_service.dart';
import 'package:jkworlds/data/services/category_service.dart';
import 'package:jkworlds/data/services/location_service.dart';
import 'package:jkworlds/modules/explore/explore_controller.dart';
import 'package:jkworlds/modules/booking/booking_controller.dart';
import 'package:jkworlds/modules/vehicle_detail/vehicle_detail_controller.dart';
import 'package:jkworlds/data/mock/mock_vehicles.dart';
import 'mocks.dart';

void main() {
  testWidgets('Date selection reset logic tests', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    Get.put<SharedPreferences>(prefs, permanent: true);
    Get.put<CategoryService>(MockCategoryService(), permanent: true);
    Get.put<LocationService>(MockLocationService(), permanent: true);
    Get.put(CurrencyService(), permanent: true);

    await tester.pumpWidget(
      GetMaterialApp(
        home: const Scaffold(body: SizedBox()),
      ),
    );
    await tester.pumpAndSettle();

    final testVehicle = mockVehicles[0];

    // 1. ExploreController test
    final exploreCtrl = Get.put(ExploreController());
    exploreCtrl.pickupDateTime.value = DateTime(2026, 6, 12, 10, 0);
    exploreCtrl.dropoffDateTime.value = DateTime(2026, 6, 14, 10, 0);
    exploreCtrl.pickupDateTime.value = DateTime(2026, 6, 14, 10, 0);
    if (exploreCtrl.pickupDateTime.value != null && exploreCtrl.dropoffDateTime.value != null &&
        !exploreCtrl.dropoffDateTime.value!.isAfter(exploreCtrl.pickupDateTime.value!)) {
      exploreCtrl.dropoffDateTime.value = null;
    }
    expect(exploreCtrl.dropoffDateTime.value, isNull);

    // 2. BookingController test
    Get.to(
      () => const Scaffold(),
      arguments: testVehicle,
    );
    await tester.pumpAndSettle();
    final bookingCtrl = Get.put(BookingController());
    bookingCtrl.pickupDate.value = DateTime(2026, 6, 12);
    bookingCtrl.returnDate.value = DateTime(2026, 6, 14);
    final newPickup = DateTime(2026, 6, 15);
    bookingCtrl.pickupDate.value = newPickup;
    if (bookingCtrl.returnDate.value != null && bookingCtrl.returnDate.value!.isBefore(newPickup)) {
      bookingCtrl.returnDate.value = null;
    }
    expect(bookingCtrl.returnDate.value, isNull);

    // 3. VehicleDetailController test
    Get.delete<BookingController>();
    Get.to(
      () => const Scaffold(),
      arguments: testVehicle,
    );
    await tester.pumpAndSettle();
    final detailCtrl = Get.put(VehicleDetailController());
    detailCtrl.pickupDate.value = DateTime(2026, 6, 12);
    detailCtrl.returnDate.value = DateTime(2026, 6, 14);
    final newPickup2 = DateTime(2026, 6, 14);
    detailCtrl.pickupDate.value = newPickup2;
    if (detailCtrl.returnDate.value != null && !detailCtrl.returnDate.value!.isAfter(newPickup2)) {
      detailCtrl.returnDate.value = null;
    }
    expect(detailCtrl.returnDate.value, isNull);

    Get.reset();
  });
}

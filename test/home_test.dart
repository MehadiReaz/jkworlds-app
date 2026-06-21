import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';
import 'package:jkworlds/app/routes/app_pages.dart';
import 'package:jkworlds/app/currency/currency_service.dart';
import 'package:jkworlds/data/services/auth_service.dart';
import 'package:jkworlds/data/services/category_service.dart';
import 'package:jkworlds/data/services/booking_service.dart';
import 'package:jkworlds/data/mock/mock_vehicles.dart';
import 'package:jkworlds/modules/home/home_view.dart';
import 'package:jkworlds/modules/home/home_controller.dart';
import 'package:jkworlds/modules/main_nav/main_nav_controller.dart';
import 'package:jkworlds/app/translations/app_translations.dart';
import 'mocks.dart';

void main() {
  testWidgets(
    'HomeView renders greeting, search, promos, categories, featured vehicles, popular vehicles, and trust badges',
    (WidgetTester tester) async {
      // Set a large screen size to render all scrollable sections
      tester.view.physicalSize = const Size(1080, 4200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      // 1. Setup dependencies
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
      Get.put(MainNavController(), permanent: true);

      // 2. Pump app — use pump() instead of pumpAndSettle() since the promo
      //    carousel has a periodic auto-scroll timer that never "settles".
      await tester.pumpWidget(
        GetMaterialApp(
          translations: AppTranslations(),
          locale: const Locale('en', 'US'),
          getPages: AppPages.pages,
          home: const HomeView(),
        ),
      );
      // Pump a few frames to build the UI fully
      await tester.pump(const Duration(milliseconds: 500));

      // 3. Verify greeting header
      expect(find.textContaining('Mehadi'), findsOneWidget);
      expect(find.text('Find your perfect ride today'), findsOneWidget);

      // 4. Verify search bar
      expect(find.text('Search by brand, model, or location...'), findsOneWidget);
      expect(find.byIcon(Icons.search_rounded), findsOneWidget);
      expect(find.byIcon(Icons.tune_rounded), findsOneWidget);

      // 5. Verify promo carousel — first promo should be visible
      expect(find.text('20% Off First Ride'), findsOneWidget);
      expect(find.text('Book Now'), findsWidgets);

      // 6. Verify active booking card
      expect(find.text('Your Active Ride'), findsOneWidget);
      expect(find.textContaining('Toyota'), findsWidgets);

      // 7. Verify category section
      expect(find.text('Categories'), findsOneWidget);
      expect(find.text('All'), findsOneWidget);
      expect(find.text('Sedan'), findsOneWidget);
      expect(find.text('SUV'), findsOneWidget);
      expect(find.text('Luxury'), findsOneWidget);
      expect(find.text('Van'), findsOneWidget);

      // 8. Verify featured vehicles section header
      expect(find.text('Featured Vehicles'), findsOneWidget);
      final featuredCount = mockVehicles.where((v) => v.isFeatured).length;
      expect(featuredCount, greaterThan(0));

      // 9. Verify top rated vehicles section
      expect(find.text('View All'), findsOneWidget);

      // 10. Verify trust badges and section header
      expect(find.text('Why Choose JKWorlds'), findsOneWidget);
      expect(find.text('Fully Insured'), findsOneWidget);
      expect(find.text('Top Rated'), findsNWidgets(2));
      expect(find.text('Premium Fleet'), findsOneWidget);

      // 11. Test category filtering — tap "SUV"
      final suvChip = find.text('SUV');
      await tester.tap(suvChip);
      await tester.pump(const Duration(milliseconds: 300));

      final navCtrl = Get.find<MainNavController>();
      expect(navCtrl.currentIndex.value, 1);

      // Reset index back to 0 to test search bar navigation next
      navCtrl.changePage(0);
      await tester.pump(const Duration(milliseconds: 300));

      // 12. Test search bar navigation
      final searchBar = find.text('Search by brand, model, or location...');
      await tester.tap(searchBar);
      await tester.pump(const Duration(milliseconds: 300));

      Get.find<MainNavController>();
      expect(navCtrl.currentIndex.value, 1);

      // Clean up: delete the controller to cancel its timer, then reset GetX
      Get.delete<HomeController>(force: true);
      Get.reset();
    },
  );
}

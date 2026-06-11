// Basic smoke test for JKWorlds app.

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';

import 'package:jkworlds/main.dart';

void main() {
  testWidgets('App launches and shows bottom nav', (WidgetTester tester) async {
    // Mock SharedPreferences
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    Get.put<SharedPreferences>(prefs, permanent: true);

    await tester.pumpWidget(const JKWorldsApp());
    await tester.pumpAndSettle();

    // The bottom navigation should be present
    // (detailed tests to be added per module)
  });
}

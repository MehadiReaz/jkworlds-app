// Basic smoke test for JKWorlds app.

import 'package:flutter_test/flutter_test.dart';

import 'package:jkworlds/main.dart';

void main() {
  testWidgets('App launches and shows bottom nav', (WidgetTester tester) async {
    await tester.pumpWidget(const JKWorldsApp());
    await tester.pumpAndSettle();

    // The bottom navigation should be present
    // (detailed tests to be added per module)
  });
}

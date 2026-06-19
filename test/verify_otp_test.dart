import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';
import 'package:jkworlds/data/services/auth_service.dart';
import 'package:jkworlds/modules/auth/verify_otp_view.dart';
import 'package:jkworlds/modules/auth/auth_controller.dart';

class MockAuthService extends GetxService implements AuthService {
  @override
  final isLoggedIn = false.obs;
  @override
  final userName = ''.obs;
  @override
  final userEmail = ''.obs;
  @override
  final userPhone = ''.obs;
  @override
  final userAddress = ''.obs;
  @override
  final userPhotoUrl = ''.obs;
  @override
  final isSocialLoading = false.obs;

  bool forgotPasswordCalled = false;
  String? forgotPasswordEmail;

  @override
  Future<String> forgotPassword(String email) async {
    forgotPasswordCalled = true;
    forgotPasswordEmail = email;
    return 'OTP sent successfully';
  }

  bool verifyOtpCalled = false;
  @override
  Future<String> verifyOtp({required String otp, required String email}) async {
    verifyOtpCalled = true;
    return 'OTP verified';
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  testWidgets('VerifyOtpView renders and timer ticks down, enabling resend', (WidgetTester tester) async {
    // Mock SharedPreferences
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    Get.put<SharedPreferences>(prefs, permanent: true);

    // Register MockAuthService
    final mockAuth = MockAuthService();
    Get.put<AuthService>(mockAuth);

    // Put AuthController
    final controller = Get.put(AuthController());
    controller.emailCtrl.text = 'test@example.com';

    // Pump the view
    await tester.pumpWidget(const GetMaterialApp(home: VerifyOtpView()));
    await tester.pumpAndSettle();

    // Check timer is initially 0 (shows "Resend OTP" button) since we haven't started it yet
    expect(find.text('Resend OTP'), findsOneWidget);

    // Start timer manually
    controller.startOtpTimer();
    await tester.pump(); // trigger rebuild

    // Now it should show "Didn't receive code? Resend in 120s"
    final richTextFinder = find.byWidgetPredicate(
      (widget) => widget is RichText && widget.text.toPlainText().contains("Didn't receive code?"),
    );
    expect(richTextFinder, findsOneWidget);
    RichText richText = tester.element(richTextFinder).widget as RichText;
    expect(richText.text.toPlainText(), contains("Didn't receive code? Resend in 120s"));

    // Pump to verify it ticks down
    await tester.pump(const Duration(seconds: 1));
    expect(richTextFinder, findsOneWidget);
    richText = tester.element(richTextFinder).widget as RichText;
    expect(richText.text.toPlainText(), contains("Didn't receive code? Resend in 119s"));

    // Clean up
    await Get.delete<AuthController>();
    await Get.delete<AuthService>();
    Get.reset();
  });
}

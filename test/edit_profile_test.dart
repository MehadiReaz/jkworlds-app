import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';
import 'package:jkworlds/data/services/auth_service.dart';
import 'package:jkworlds/modules/profile/edit_profile_view.dart';
import 'package:jkworlds/modules/profile/profile_binding.dart';
import 'package:jkworlds/modules/profile/edit_profile_controller.dart';
import 'package:jkworlds/core/utils/image_picker_helper.dart';

void main() {
  testWidgets(
    'EditProfileView renders form fields and updates profile picture',
    (WidgetTester tester) async {
      // Mock SharedPreferences
      SharedPreferences.setMockInitialValues({
        'auth_token': 'mock_token_123',
        'auth_user_name': 'Test User',
        'auth_user_email': 'test@example.com',
        'auth_user_phone': '1234567890',
        'auth_user_address': '123 Test St',
        'auth_user_photo': 'assets/pictures/avatar_male.png',
      });
      final prefs = await SharedPreferences.getInstance();
      Get.put<SharedPreferences>(prefs, permanent: true);

      // Initialize global AuthService
      Get.put(AuthService(), permanent: true);

      // Setup EditProfile bindings
      final binding = ProfileBinding();
      binding.dependencies();

      // Configure ImagePicker Mock
      ImagePickerHelper.mockPickImage = ({required source}) async {
        return 'assets/pictures/avatar_female.png';
      };

      // Pump the view
      await tester.pumpWidget(GetMaterialApp(home: const EditProfileView()));
      await tester.pumpAndSettle();

      // Verify initial values are populated in the TextFormField inputs
      expect(find.text('Test User'), findsOneWidget);
      expect(find.text('test@example.com'), findsOneWidget);
      expect(find.text('1234567890'), findsOneWidget);
      expect(find.text('123 Test St'), findsOneWidget);

      // Verify sections and buttons are present
      expect(find.text('Personal Information'), findsOneWidget);
      expect(find.text('Change Password'), findsNWidgets(2));
      expect(find.text('Update'), findsOneWidget);
      expect(find.byIcon(Icons.camera_alt_rounded), findsOneWidget);

      // Tap camera icon button to pick new image
      await tester.tap(find.byIcon(Icons.camera_alt_rounded));
      await tester.pumpAndSettle();

      // Verify the controller's selected image path is updated reactively
      final controller = Get.find<EditProfileController>();
      expect(controller.selectedImagePath.value, 'assets/pictures/avatar_female.png');

      // Clean up
      ImagePickerHelper.mockPickImage = null;
      Get.reset();
    },
  );
}

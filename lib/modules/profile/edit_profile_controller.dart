import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jkworlds/data/services/auth_service.dart';
import 'package:jkworlds/core/utils/image_picker_helper.dart';

class EditProfileController extends GetxController {
  final AuthService _auth = Get.find<AuthService>();

  // ── Form Keys ─────────────────────────────────────────────────
  final profileFormKey = GlobalKey<FormState>();
  final passwordFormKey = GlobalKey<FormState>();

  // ── Form Controllers ──────────────────────────────────────────
  final nameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final addressCtrl = TextEditingController();

  final newPasswordCtrl = TextEditingController();
  final confirmNewPasswordCtrl = TextEditingController();

  // ── State ─────────────────────────────────────────────────────
  final isLoading = false.obs;
  final isPasswordLoading = false.obs;
  final selectedImageName = 'No file chosen'.obs;
  final selectedImagePath = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _loadCurrentProfile();
  }

  void _loadCurrentProfile() {
    nameCtrl.text = _auth.userName.value;
    emailCtrl.text = _auth.userEmail.value;
    phoneCtrl.text = _auth.userPhone.value;
    addressCtrl.text = _auth.userAddress.value;

    if (_auth.userPhotoUrl.value.isNotEmpty) {
      selectedImagePath.value = _auth.userPhotoUrl.value;
      selectedImageName.value = _auth.userPhotoUrl.value.split('/').last;
    }
  }

  // ── Validators ────────────────────────────────────────────────
  String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) return 'field_required'.tr;
    return null;
  }

  String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) return 'field_required'.tr;
    if (!GetUtils.isEmail(value.trim())) return 'invalid_email'.tr;
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'field_required'.tr;
    if (value.length < 6) return 'password_too_short'.tr;
    return null;
  }

  String? validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) return 'field_required'.tr;
    if (value != newPasswordCtrl.text) return 'passwords_dont_match'.tr;
    return null;
  }

  // ── Actions ───────────────────────────────────────────────────

  /// Choose an image using the unified ImagePickerHelper
  Future<void> chooseFile() async {
    final pickedPath = await ImagePickerHelper.pickImageWithBottomSheet();
    if (pickedPath != null && pickedPath.isNotEmpty) {
      selectedImagePath.value = pickedPath;
      selectedImageName.value = pickedPath.split('/').last;
    }
  }

  /// Updates personal profile info
  Future<void> updateProfile() async {
    if (!profileFormKey.currentState!.validate()) return;

    isLoading.value = true;
    final success = await _auth.updateProfile(
      name: nameCtrl.text.trim(),
      email: emailCtrl.text.trim(),
      phone: phoneCtrl.text.trim(),
      address: addressCtrl.text.trim(),
      imagePath: selectedImagePath.value,
    );
    isLoading.value = false;

    if (success) {
      Get.snackbar(
        'success'.tr,
        'Profile updated successfully!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.primaryContainer,
        colorText: Get.theme.colorScheme.onPrimaryContainer,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
    }
  }

  /// Updates profile password
  Future<void> changePassword() async {
    if (!passwordFormKey.currentState!.validate()) return;

    isPasswordLoading.value = true;
    final success = await _auth.updatePassword(newPasswordCtrl.text);
    isPasswordLoading.value = false;

    if (success) {
      newPasswordCtrl.clear();
      confirmNewPasswordCtrl.clear();
      Get.snackbar(
        'success'.tr,
        'Password changed successfully!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.primaryContainer,
        colorText: Get.theme.colorScheme.onPrimaryContainer,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
    }
  }

}

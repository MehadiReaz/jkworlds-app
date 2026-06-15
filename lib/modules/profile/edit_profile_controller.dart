import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jkworlds/core/errors/app_exception.dart';
import 'package:jkworlds/data/services/auth_service.dart';
import 'package:jkworlds/core/utils/image_picker_helper.dart';

class EditProfileController extends GetxController {
  final AuthService _auth = Get.find<AuthService>();

  // ── Form Keys ─────────────────────────────────────────────────
  final profileFormKey  = GlobalKey<FormState>();
  final passwordFormKey = GlobalKey<FormState>();

  // ── Form Controllers ──────────────────────────────────────────
  final nameCtrl    = TextEditingController();
  final emailCtrl   = TextEditingController();
  final phoneCtrl   = TextEditingController();
  final addressCtrl = TextEditingController();

  final currentPasswordCtrl      = TextEditingController();
  final newPasswordCtrl          = TextEditingController();
  final confirmNewPasswordCtrl   = TextEditingController();

  // ── State ─────────────────────────────────────────────────────
  final isLoading         = false.obs;
  final isPasswordLoading = false.obs;
  final selectedImageName = 'No file chosen'.obs;
  final selectedImagePath = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _loadCurrentProfile();
  }

  @override
  void onClose() {
    nameCtrl.dispose();
    emailCtrl.dispose();
    phoneCtrl.dispose();
    addressCtrl.dispose();
    currentPasswordCtrl.dispose();
    newPasswordCtrl.dispose();
    confirmNewPasswordCtrl.dispose();
    super.onClose();
  }

  void _loadCurrentProfile() {
    nameCtrl.text    = _auth.userName.value;
    emailCtrl.text   = _auth.userEmail.value;
    phoneCtrl.text   = _auth.userPhone.value;
    addressCtrl.text = _auth.userAddress.value;

    if (_auth.userPhotoUrl.value.isNotEmpty) {
      selectedImagePath.value = _auth.userPhotoUrl.value;
      selectedImageName.value = _auth.userPhotoUrl.value.split('/').last;
    }
  }

  // ── Validators ────────────────────────────────────────────────

  String? validateName(String? v) {
    if (v == null || v.trim().isEmpty) return 'field_required'.tr;
    return null;
  }

  String? validateEmail(String? v) {
    if (v == null || v.trim().isEmpty) return 'field_required'.tr;
    if (!GetUtils.isEmail(v.trim())) return 'invalid_email'.tr;
    return null;
  }

  String? validateCurrentPassword(String? v) {
    if (v == null || v.isEmpty) return 'field_required'.tr;
    return null;
  }

  String? validateNewPassword(String? v) {
    if (v == null || v.isEmpty) return 'field_required'.tr;
    if (v.length < 6) return 'password_too_short'.tr;
    return null;
  }

  String? validateConfirmPassword(String? v) {
    if (v == null || v.isEmpty) return 'field_required'.tr;
    if (v != newPasswordCtrl.text) return 'passwords_dont_match'.tr;
    return null;
  }

  // ── Actions ───────────────────────────────────────────────────

  Future<void> chooseFile() async {
    final pickedPath = await ImagePickerHelper.pickImageWithBottomSheet();
    if (pickedPath != null && pickedPath.isNotEmpty) {
      selectedImagePath.value = pickedPath;
      selectedImageName.value = pickedPath.split('/').last;
    }
  }

  Future<void> updateProfile() async {
    if (!profileFormKey.currentState!.validate()) return;

    isLoading.value = true;
    try {
      await _auth.updateProfile(
        name:      nameCtrl.text.trim(),
        email:     emailCtrl.text.trim(),
        phone:     phoneCtrl.text.trim(),
        address:   addressCtrl.text.trim(),
        imagePath: selectedImagePath.value.isNotEmpty
            ? selectedImagePath.value
            : null,
      );
      _showSuccess('Profile updated successfully!');
    } on ServerException catch (e) {
      _showError(e.message);
    } on NetworkException catch (e) {
      _showError(e.message);
    } on AppException catch (e) {
      _showError(e.message);
    } catch (e) {
      _showError('An unexpected error occurred.');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> changePassword() async {
    if (!passwordFormKey.currentState!.validate()) return;

    isPasswordLoading.value = true;
    try {
      await _auth.updatePassword(
        currentPassword:         currentPasswordCtrl.text,
        newPassword:             newPasswordCtrl.text,
        newPasswordConfirmation: confirmNewPasswordCtrl.text,
      );
      currentPasswordCtrl.clear();
      newPasswordCtrl.clear();
      confirmNewPasswordCtrl.clear();
      _showSuccess('Password changed successfully!');
    } on ServerException catch (e) {
      _showError(e.message);
    } on NetworkException catch (e) {
      _showError(e.message);
    } on AppException catch (e) {
      _showError(e.message);
    } catch (e) {
      _showError('An unexpected error occurred.');
    } finally {
      isPasswordLoading.value = false;
    }
  }

  // ── Snackbar Helpers ──────────────────────────────────────────

  void _showSuccess(String message) => Get.snackbar(
        'success'.tr,
        message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.primaryContainer,
        colorText: Get.theme.colorScheme.onPrimaryContainer,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );

  void _showError(String message) => Get.snackbar(
        'error'.tr,
        message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.errorContainer,
        colorText: Get.theme.colorScheme.onErrorContainer,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
}
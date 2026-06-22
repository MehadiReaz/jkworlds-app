import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:jkworlds/core/utils/snackbar_helper.dart';

/// Reusable utility helper for picking images using [image_picker].
///
/// Features a premium, localized bottom sheet for picking from Camera/Gallery,
/// respects active themes, and includes a testing hook to bypass platform channel calls.
class ImagePickerHelper {
  ImagePickerHelper._();

  static final ImagePicker _picker = ImagePicker();

  /// Hook to override image selection behavior during tests.
  @visibleForTesting
  static Future<String?> Function({required ImageSource source})? mockPickImage;

  /// Prompts the user with a bottom sheet to pick an image from camera or gallery.
  ///
  /// Returns the picked file path, or `null` if the action was cancelled.
  static Future<String?> pickImageWithBottomSheet({
    String? title,
    double? maxWidth,
    double? maxHeight,
    int? imageQuality,
    CameraDevice preferredCameraDevice = CameraDevice.rear,
  }) async {
    // During tests, bypass the UI and return the mocked path directly
    if (mockPickImage != null) {
      return pickImage(
        source: ImageSource.gallery,
        maxWidth: maxWidth,
        maxHeight: maxHeight,
        imageQuality: imageQuality,
        preferredCameraDevice: preferredCameraDevice,
      );
    }

    final source = await showSelectionBottomSheet(title: title);
    if (source == null) return null;

    return pickImage(
      source: source,
      maxWidth: maxWidth,
      maxHeight: maxHeight,
      imageQuality: imageQuality,
      preferredCameraDevice: preferredCameraDevice,
    );
  }

  /// Picks an image directly from the specified [ImageSource].
  ///
  /// Returns the picked file path, or `null` if none was selected.
  static Future<String?> pickImage({
    required ImageSource source,
    double? maxWidth,
    double? maxHeight,
    int? imageQuality,
    CameraDevice preferredCameraDevice = CameraDevice.rear,
  }) async {
    if (mockPickImage != null) {
      return mockPickImage!(source: source);
    }

    final bool hasPermission = await _requestImageSourcePermission(source);
    if (!hasPermission) {
      return null;
    }

    try {
      final XFile? file = await _picker.pickImage(
        source: source,
        maxWidth: maxWidth,
        maxHeight: maxHeight,
        imageQuality: imageQuality,
        preferredCameraDevice: preferredCameraDevice,
      );
      return file?.path;
    } catch (e) {
      SnackbarHelper.showError('failed_to_pick_image'.tr);
      return null;
    }
  }

  static Future<bool> _requestImageSourcePermission(ImageSource source) async {
    if (source == ImageSource.camera) {
      final status = await Permission.camera.request();
      if (status.isGranted) return true;
      if (status.isPermanentlyDenied) {
        _showPermissionDeniedDialog(
          title: 'camera_permission_title'.tr,
          message: 'camera_permission_message'.tr,
        );
      } else {
        SnackbarHelper.showError('camera_permission_denied'.tr);
      }
      return false;
    } else {
      final status = await Permission.photos.request();
      if (status.isGranted || status.isLimited) return true;
      if (status.isPermanentlyDenied) {
        _showPermissionDeniedDialog(
          title: 'photos_permission_title'.tr,
          message: 'photos_permission_message'.tr,
        );
      } else {
        SnackbarHelper.showError('photos_permission_denied'.tr);
      }
      return false;
    }
  }

  static void _showPermissionDeniedDialog({
    required String title,
    required String message,
  }) {
    Get.dialog(
      AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('cancel'.tr),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              openAppSettings();
            },
            child: Text('settings'.tr),
          ),
        ],
      ),
    );
  }

  /// Displays the interactive bottom sheet dialog for picking the image source.
  static Future<ImageSource?> showSelectionBottomSheet({String? title}) async {
    final theme = Get.theme;
    final cs = theme.colorScheme;
    final isLight = theme.brightness == Brightness.light;

    return Get.bottomSheet<ImageSource>(
      Container(
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          border: Border.all(
            color: cs.outlineVariant.withValues(alpha: 0.5),
            width: 1,
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Swipe-down indicator
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: cs.onSurfaceVariant.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                title ?? 'select_image_source'.tr,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: cs.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => Get.back(result: ImageSource.camera),
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        decoration: BoxDecoration(
                          color: isLight ? Colors.grey.shade50 : const Color(0xFF161A22),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: cs.outlineVariant.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Column(
                          children: [
                            Icon(Icons.photo_camera_rounded, size: 36, color: cs.primary),
                            const SizedBox(height: 12),
                            Text(
                              'camera'.tr,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: cs.onSurface,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: InkWell(
                      onTap: () => Get.back(result: ImageSource.gallery),
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        decoration: BoxDecoration(
                          color: isLight ? Colors.grey.shade50 : const Color(0xFF161A22),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: cs.outlineVariant.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Column(
                          children: [
                            Icon(Icons.photo_library_rounded, size: 36, color: cs.primary),
                            const SizedBox(height: 12),
                            Text(
                              'gallery'.tr,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: cs.onSurface,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      isDismissible: true,
    );
  }
}

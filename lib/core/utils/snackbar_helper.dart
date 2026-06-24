import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SnackbarHelper {
  SnackbarHelper._();

  static void showSuccess(String message) => _show(
        title: 'success'.tr,
        message: message,
        color: const Color(0xFF22C55E),
        icon: Icons.check_circle_rounded,
      );

  static void showError(String message) => _show(
        title: 'error'.tr,
        message: message,
        color: const Color(0xFFEF4444),
        icon: Icons.error_rounded,
      );

  static void showWarning(String message) => _show(
        title: 'warning'.tr,
        message: message,
        color: const Color(0xFFF59E0B),
        icon: Icons.warning_amber_rounded,
      );

  static void showInfo(String message) => _show(
        title: 'info'.tr,
        message: message,
        color: const Color(0xFF3B82F6),
        icon: Icons.info_rounded,
      );

  static void _show({
    required String title,
    required String message,
    required Color color,
    required IconData icon,
  }) {
    if (Get.key.currentState == null) {
      debugPrint('[SnackbarHelper] $title: $message');
      return;
    }
    Get.snackbar(
      '',
      '',
      titleText: const SizedBox.shrink(),
      messageText: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 24,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),

                const SizedBox(height: 2),

                Text(
                  message,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.95),
                    fontSize: 13,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),

          IconButton(
            onPressed: Get.back,
            splashRadius: 18,
            icon: const Icon(
              Icons.close_rounded,
              color: Colors.white70,
              size: 20,
            ),
          ),
        ],
      ),

      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: color,
      borderRadius: 16,
      margin: const EdgeInsets.all(16),

      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 12,
      ),

      boxShadows: [
        BoxShadow(
          color: color.withValues(alpha: 0.35),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
      ],

      duration: const Duration(seconds: 3),
      isDismissible: true,
      shouldIconPulse: false,
      snackStyle: SnackStyle.FLOATING,
    );
  }
}
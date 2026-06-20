import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DialogHelper {
  static void showConfirmation({
    required String title,
    required String message,
    required VoidCallback onConfirm,
    bool isDestructive = false,
  }) {
    final theme = Get.theme;
    final cs = theme.colorScheme;

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 6,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Icon Header
              Center(
                child: CircleAvatar(
                  radius: 28,
                  backgroundColor: isDestructive
                      ? cs.errorContainer.withValues(alpha: 0.8)
                      : cs.primaryContainer.withValues(alpha: 0.8),
                  child: Icon(
                    isDestructive ? Icons.warning_amber_rounded : Icons.info_outline_rounded,
                    size: 28,
                    color: isDestructive ? cs.onErrorContainer : cs.onPrimaryContainer,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Title
              Text(
                title,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: cs.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              // Message
              Text(
                message,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: cs.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 28),
              // Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: BorderSide(color: cs.outlineVariant),
                      ),
                      child: Text(
                        'cancel'.tr,
                        style: TextStyle(
                          color: cs.onSurfaceVariant,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: () {
                        Get.back(); // Close the dialog
                        onConfirm(); // Perform the confirmed action
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: isDestructive ? cs.error : cs.primary,
                        foregroundColor: isDestructive ? cs.onError : cs.onPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: Text(
                        'yes'.tr,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
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
      barrierDismissible: true,
      transitionCurve: Curves.easeInOutBack,
    );
  }
}

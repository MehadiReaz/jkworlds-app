import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:jkworlds/core/constants/image_assets.dart';

/// Reusable card layout for auth screens.
class AuthCard extends StatelessWidget {
  final Widget child;

  const AuthCard({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isLight = theme.brightness == Brightness.light;

    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: cs.outlineVariant.withValues(alpha: 0.5),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: isLight ? 0.03 : 0.2,
            ),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 28,
        vertical: 36,
      ),
      child: child,
    );
  }
}

/// Reusable social media authentication button (Google, Apple).
class SocialSignInButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget icon;
  final String label;

  const SocialSignInButton({
    super.key,
    required this.onPressed,
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        backgroundColor: theme.cardColor,
        minimumSize: const Size.fromHeight(54),
        side: BorderSide(
          color: cs.outlineVariant.withValues(alpha: 0.5),
          width: 1.5,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          icon,
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: cs.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

/// Combined reusable Google and Apple sign-in section.
class SocialSignInSection extends StatelessWidget {
  final VoidCallback? onGooglePressed;
  final VoidCallback? onApplePressed;
  final bool isLoading;

  const SocialSignInSection({
    super.key,
    required this.onGooglePressed,
    required this.onApplePressed,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SocialSignInButton(
          onPressed: isLoading ? null : onGooglePressed,
          icon: Image.asset(
            ImageAssets.google,
            width: 20,
            height: 20,
          ),
          label: 'continue_with_google'.tr,
        ),
        const SizedBox(height: 16),
        SocialSignInButton(
          onPressed: isLoading ? null : onApplePressed,
          icon: Icon(
            Icons.apple,
            size: 24,
            color: cs.onSurface,
          ),
          label: 'continue_with_apple'.tr,
        ),
      ],
    );
  }
}

/// Helper function to build custom input decorations for auth fields.
InputDecoration buildAuthInputDecoration({
  required String hintText,
  required ColorScheme cs,
  required ThemeData theme,
  Widget? prefixIcon,
  Widget? suffixIcon,
}) {
  return InputDecoration(
    hintText: hintText,
    hintStyle: TextStyle(
      color: cs.onSurfaceVariant.withValues(alpha: 0.5),
      fontSize: 15,
    ),
    prefixIcon: prefixIcon,
    suffixIcon: suffixIcon,
    filled: true,
    fillColor: theme.brightness == Brightness.light
        ? Colors.white
        : const Color(0xFF111318),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(
        color: cs.outlineVariant.withValues(alpha: 0.5),
        width: 1.5,
      ),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(
        color: cs.outlineVariant.withValues(alpha: 0.5),
        width: 1.5,
      ),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: cs.primary, width: 1.5),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: cs.error, width: 1.5),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: cs.error, width: 1.5),
    ),
  );
}

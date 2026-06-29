import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'onboarding_wizard_controller.dart';

class OnboardingWizardView extends GetView<OnboardingWizardController> {
  const OnboardingWizardView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              cs.primary.withValues(alpha: 0.05),
              theme.scaffoldBackgroundColor,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // ── Header Progress ──────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Preferences Wizard',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: cs.primary,
                      ),
                    ),
                    Obx(() => Text(
                          'Step ${controller.currentStep.value + 1} of 3',
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: cs.onSurfaceVariant.withValues(alpha: 0.7),
                          ),
                        )),
                  ],
                ),
              ),
              Obx(() => _buildProgressBar(controller.currentStep.value, cs)),

              // ── Wizard Body ─────────────────────────────────────
              Expanded(
                child: Obx(() {
                  switch (controller.currentStep.value) {
                    case 0:
                      return _buildStep1(theme, cs);
                    case 1:
                      return _buildStep2(context, theme, cs);
                    case 2:
                      return _buildStep3(theme, cs);
                    default:
                      return const SizedBox.shrink();
                  }
                }),
              ),

              // ── Bottom Action Buttons ───────────────────────────
              Obx(() => _buildBottomNavigation(context, theme, cs)),
            ],
          ),
        ),
      ),
    );
  }

  // ── Progress Bar Builder ──────────────────────────────────────────
  Widget _buildProgressBar(int currentStep, ColorScheme cs) {
    return Container(
      height: 4,
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(2),
      ),
      child: Row(
        children: [
          Expanded(
            flex: currentStep + 1,
            child: Container(
              decoration: BoxDecoration(
                color: cs.primary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Expanded(
            flex: 3 - (currentStep + 1),
            child: const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  // ── Step 1: Select Persona ────────────────────────────────────────
  Widget _buildStep1(ThemeData theme, ColorScheme cs) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      children: [
        Text(
          'Select your booking persona',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w900,
            color: cs.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Help us customize your JKWorlds experience by choosing the role that matches your typical usage.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: cs.onSurfaceVariant.withValues(alpha: 0.8),
          ),
        ),
        const SizedBox(height: 24),
        _buildPersonaCard(
          role: 'traveler',
          title: 'Traveler & Renter',
          desc: 'Renting premium cars for personal trips, weekend getaways, or dynamic self-drive services.',
          icon: Icons.directions_car_rounded,
          theme: theme,
          cs: cs,
        ),
        const SizedBox(height: 16),
        _buildPersonaCard(
          role: 'business',
          title: 'Business Client',
          desc: 'Corporate bookings, corporate transfers, luxury executive shuttles, and chauffeur services.',
          icon: Icons.business_center_rounded,
          theme: theme,
          cs: cs,
        ),
        const SizedBox(height: 16),
        _buildPersonaCard(
          role: 'chauffeur',
          title: 'Partner Chauffeur',
          desc: 'Applying to act as a professional driver or managing corporate fleet transfers on the platform.',
          icon: Icons.person_pin_rounded,
          theme: theme,
          cs: cs,
        ),
      ],
    );
  }

  Widget _buildPersonaCard({
    required String role,
    required String title,
    required String desc,
    required IconData icon,
    required ThemeData theme,
    required ColorScheme cs,
  }) {
    return Obx(() {
      final isSelected = controller.preferredService.value == role;
      return InkWell(
        onTap: () => controller.setService(role),
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isSelected ? cs.primary.withValues(alpha: 0.05) : theme.cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? cs.primary : cs.outlineVariant.withValues(alpha: 0.6),
              width: isSelected ? 2.0 : 1.0,
            ),
            boxShadow: [
              if (isSelected)
                BoxShadow(
                  color: cs.primary.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                )
              else
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isSelected ? cs.primary : cs.surfaceContainerHighest,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: isSelected ? cs.onPrimary : cs.onSurfaceVariant,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: isSelected ? cs.primary : cs.onSurface,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      desc,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: cs.onSurfaceVariant.withValues(alpha: 0.8),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  // ── Step 2: Details & Location ────────────────────────────────────
  Widget _buildStep2(BuildContext context, ThemeData theme, ColorScheme cs) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      children: [
        Text(
          'Contact & Location details',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w900,
            color: cs.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'These details help us customize calculations, local taxes, and support profiles for your account.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: cs.onSurfaceVariant.withValues(alpha: 0.8),
          ),
        ),
        const SizedBox(height: 24),

        // City & Country Row
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                controller: controller.cityCtrl,
                label: 'City',
                hint: 'e.g. Lagos',
                icon: Icons.location_city_rounded,
                theme: theme,
                cs: cs,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildTextField(
                controller: controller.countryCtrl,
                label: 'Country',
                hint: 'e.g. Nigeria',
                icon: Icons.public_rounded,
                theme: theme,
                cs: cs,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Phone number
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 90,
              child: _buildTextField(
                controller: controller.countryCodeCtrl,
                label: 'Code',
                hint: '+234',
                icon: Icons.add,
                theme: theme,
                cs: cs,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildTextField(
                controller: controller.phoneCtrl,
                label: 'Phone Number',
                hint: 'e.g. 8031234567',
                icon: Icons.phone_rounded,
                keyboardType: TextInputType.phone,
                theme: theme,
                cs: cs,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Date of Birth Date-picker row
        Text(
          'Date of Birth',
          style: theme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: cs.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        Obx(() {
          final dob = controller.dobRx.value;
          final displayText = dob != null
              ? DateFormat('MMMM d, yyyy').format(dob)
              : 'Select date of birth (min 18 yrs)';

          return OutlinedButton(
            onPressed: () => controller.pickDateOfBirth(context),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 54),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              side: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.8)),
              foregroundColor: cs.onSurface,
              alignment: Alignment.centerLeft,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.calendar_month_rounded, color: cs.primary),
                    const SizedBox(width: 12),
                    Text(
                      displayText,
                      style: TextStyle(
                        fontSize: 14,
                        color: dob != null ? cs.onSurface : cs.onSurfaceVariant.withValues(alpha: 0.7),
                        fontWeight: dob != null ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
                Icon(Icons.arrow_drop_down_rounded, color: cs.onSurfaceVariant),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    required ThemeData theme,
    required ColorScheme cs,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: cs.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: cs.onSurfaceVariant.withValues(alpha: 0.5), fontWeight: FontWeight.normal),
            prefixIcon: Icon(icon, size: 20),
            prefixIconColor: cs.onSurfaceVariant.withValues(alpha: 0.7),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.8)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.8)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: cs.primary, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  // ── Step 3: Select Currency ────────────────────────────────────────
  Widget _buildStep3(ThemeData theme, ColorScheme cs) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      children: [
        Text(
          'Preferred billing currency',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w900,
            color: cs.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Select the pricing and billing currency to display by default across the JKWorlds catalog.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: cs.onSurfaceVariant.withValues(alpha: 0.8),
          ),
        ),
        const SizedBox(height: 32),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _buildCurrencyOption('USD', 'United States Dollar (USD)', '\$', theme, cs),
            _buildCurrencyOption('NGN', 'Nigerian Naira (₦)', '₦', theme, cs),
            _buildCurrencyOption('EUR', 'Euro Member Countries (EUR)', '€', theme, cs),
            _buildCurrencyOption('GBP', 'British Pound Sterling (GBP)', '£', theme, cs),
          ],
        ),
      ],
    );
  }

  Widget _buildCurrencyOption(
    String code,
    String label,
    String symbol,
    ThemeData theme,
    ColorScheme cs,
  ) {
    return Obx(() {
      final isSelected = controller.preferredCurrency.value == code;
      return InkWell(
        onTap: () => controller.setCurrency(code),
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: isSelected ? cs.primary.withValues(alpha: 0.05) : theme.cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? cs.primary : cs.outlineVariant.withValues(alpha: 0.6),
              width: isSelected ? 1.8 : 1.0,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isSelected ? cs.primary : cs.surfaceContainerHighest,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  symbol,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? cs.onPrimary : cs.onSurface,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  label,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                    color: isSelected ? cs.primary : cs.onSurface,
                  ),
                ),
              ),
              if (isSelected)
                Icon(
                  Icons.check_circle_rounded,
                  color: cs.primary,
                ),
            ],
          ),
        ),
      );
    });
  }

  // ── Bottom Action Navigation ──────────────────────────────────────
  Widget _buildBottomNavigation(
    BuildContext context,
    ThemeData theme,
    ColorScheme cs,
  ) {
    final showBack = controller.currentStep.value > 0;
    final isLastStep = controller.currentStep.value == 2;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.cardColor,
        border: Border(top: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.3))),
      ),
      child: Row(
        children: [
          if (showBack) ...[
            Expanded(
              child: OutlinedButton(
                onPressed: controller.isLoading.value ? null : controller.previousStep,
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 54),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  side: BorderSide(color: cs.primary),
                  foregroundColor: cs.primary,
                ),
                child: const Text(
                  'Back',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ),
            const SizedBox(width: 16),
          ],
          Expanded(
            flex: showBack ? 1 : 2,
            child: FilledButton(
              onPressed: controller.isLoading.value ? null : controller.nextStep,
              style: FilledButton.styleFrom(
                minimumSize: const Size(double.infinity, 54),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                backgroundColor: cs.primary,
                foregroundColor: cs.onPrimary,
              ),
              child: controller.isLoading.value
                  ? SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: cs.onPrimary,
                      ),
                    )
                  : Text(
                      isLastStep ? 'Submit' : 'Continue',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

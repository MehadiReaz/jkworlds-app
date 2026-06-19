import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:jkworlds/core/utils/snackbar_helper.dart';
import 'package:jkworlds/data/services/contact_service.dart';

class ContactUsView extends StatefulWidget {
  const ContactUsView({super.key});

  @override
  State<ContactUsView> createState() => _ContactUsViewState();
}

class _ContactUsViewState extends State<ContactUsView> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _subjectCtrl = TextEditingController();
  final _messageCtrl = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _subjectCtrl.dispose();
    _messageCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final contactService = Get.find<ContactService>();
    final success = await contactService.submitMessage(
      name: _nameCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      subject: _subjectCtrl.text.trim(),
      message: _messageCtrl.text.trim(),
    );

    if (success) {
      _nameCtrl.clear();
      _phoneCtrl.clear();
      _emailCtrl.clear();
      _subjectCtrl.clear();
      _messageCtrl.clear();

      SnackbarHelper.showSuccess('contact_success_msg'.tr);
    } else {
      SnackbarHelper.showError('contact_error_msg'.tr);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final contactService = Get.find<ContactService>();

    return Scaffold(
      appBar: AppBar(title: Text('contact_us'.tr)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──────────────────────────────────────────
            _buildHeader(theme, cs),
            const SizedBox(height: 24),

            // ── Contact Info Card ───────────────────────────────
            _buildContactInfoCard(theme, cs),
            const SizedBox(height: 24),

            // ── Send Message Form ───────────────────────────────
            _buildFormSection(theme, cs, contactService),
          ],
        ),
      ),
    );
  }

  // ── Header ──────────────────────────────────────────────────────
  Widget _buildHeader(ThemeData theme, ColorScheme cs) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            cs.primaryContainer,
            cs.primaryContainer.withValues(alpha: 0.4),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: cs.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              Icons.support_agent_rounded,
              size: 32,
              color: cs.primary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'contact_header'.tr,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: cs.onPrimaryContainer,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'contact_subtitle'.tr,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: cs.onPrimaryContainer.withValues(alpha: 0.7),
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ── Contact Info Card ───────────────────────────────────────────
  Widget _buildContactInfoCard(ThemeData theme, ColorScheme cs) {
    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: cs.outlineVariant.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Text(
              'contact_info'.tr,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          _buildInfoTile(
            context: context,
            icon: Icons.phone_rounded,
            iconBg: cs.primaryContainer,
            iconColor: cs.onPrimaryContainer,
            label: 'contact_phone'.tr,
            value: '+44 (0) 0000 000000',
          ),
          Divider(
            height: 1,
            indent: 56,
            endIndent: 16,
            color: cs.outlineVariant.withValues(alpha: 0.2),
          ),
          _buildInfoTile(
            context: context,
            icon: Icons.email_rounded,
            iconBg: cs.tertiaryContainer,
            iconColor: cs.onTertiaryContainer,
            label: 'email'.tr,
            value: 'info@jkworldsserviceslimited.com',
          ),
          Divider(
            height: 1,
            indent: 56,
            endIndent: 16,
            color: cs.outlineVariant.withValues(alpha: 0.2),
          ),
          _buildInfoTile(
            context: context,
            icon: Icons.access_time_rounded,
            iconBg: cs.secondaryContainer,
            iconColor: cs.onSecondaryContainer,
            label: 'contact_hours'.tr,
            value: 'contact_hours_value'.tr,
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildInfoTile({
    required BuildContext context,
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String label,
    required String value,
  }) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: iconColor),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: cs.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Form Section ────────────────────────────────────────────────
  Widget _buildFormSection(
    ThemeData theme,
    ColorScheme cs,
    ContactService contactService,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: cs.outlineVariant.withValues(alpha: 0.2),
        ),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'send_message'.tr,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),

            // ── Name & Phone Row ──────────────────────────────
            Row(
              children: [
                Expanded(
                  child: _buildField(
                    controller: _nameCtrl,
                    label: 'name'.tr,
                    icon: Icons.person_outline,
                    cs: cs,
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? 'field_required'.tr : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildField(
                    controller: _phoneCtrl,
                    label: 'contact_phone_number'.tr,
                    icon: Icons.phone_outlined,
                    cs: cs,
                    keyboardType: TextInputType.phone,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // ── Email ─────────────────────────────────────────
            _buildField(
              controller: _emailCtrl,
              label: 'email'.tr,
              icon: Icons.email_outlined,
              cs: cs,
              keyboardType: TextInputType.emailAddress,
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'field_required'.tr;
                if (!GetUtils.isEmail(v.trim())) return 'invalid_email'.tr;
                return null;
              },
            ),
            const SizedBox(height: 14),

            // ── Subject ───────────────────────────────────────
            _buildField(
              controller: _subjectCtrl,
              label: 'contact_subject'.tr,
              icon: Icons.subject_rounded,
              cs: cs,
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'field_required'.tr : null,
            ),
            const SizedBox(height: 14),

            // ── Message ───────────────────────────────────────
            _buildField(
              controller: _messageCtrl,
              label: 'contact_message'.tr,
              icon: Icons.chat_bubble_outline_rounded,
              cs: cs,
              maxLines: 5,
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'field_required'.tr : null,
            ),
            const SizedBox(height: 24),

            // ── Submit Button ─────────────────────────────────
            SizedBox(
              width: double.infinity,
              child: Obx(
                () => FilledButton.icon(
                  onPressed: contactService.isSubmitting.value ? null : _submit,
                  icon: contactService.isSubmitting.value
                      ? SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: cs.onPrimary,
                          ),
                        )
                      : const Icon(Icons.send_rounded, size: 18),
                  label: Text(
                    'send_message'.tr,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Reusable Field Builder ──────────────────────────────────────
  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required ColorScheme cs,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      textInputAction:
          maxLines > 1 ? TextInputAction.newline : TextInputAction.next,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: maxLines > 1
            ? Padding(
                padding: const EdgeInsets.only(bottom: 64),
                child: Icon(icon, color: cs.onSurfaceVariant),
              )
            : Icon(icon, color: cs.onSurfaceVariant),
        filled: true,
        fillColor: cs.surfaceContainerHighest.withValues(alpha: 0.4),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
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
        alignLabelWithHint: maxLines > 1,
      ),
    );
  }
}

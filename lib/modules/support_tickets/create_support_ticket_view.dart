import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'support_tickets_controller.dart';

class CreateSupportTicketView extends StatelessWidget {
  const CreateSupportTicketView({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<SupportTicketsController>();
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isLight = theme.brightness == Brightness.light;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create New Ticket'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Submit a Support Request',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: cs.onSurface,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Describe your issue and select priority level. Our support team will resolve it as soon as possible.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: cs.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 28),

            // ── Subject field ───────────────────────────────────────────
            _buildFieldLabel('SUBJECT', cs),
            const SizedBox(height: 6),
            TextField(
              controller: ctrl.subjectCtrl,
              decoration: InputDecoration(
                hintText: 'E.g., Unable to verify driving license',
                filled: true,
                fillColor: isLight ? Colors.grey.shade50 : const Color(0xFF161A22),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.5)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.3)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: cs.primary, width: 1.5),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // ── Priority Selector ───────────────────────────────────────
            _buildFieldLabel('PRIORITY LEVEL', cs),
            const SizedBox(height: 8),
            Row(
              children: ['Low', 'Medium', 'High'].map((priority) {
                return Expanded(
                  child: Obx(() {
                    final isSelected = ctrl.createPriority.value == priority;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => ctrl.createPriority.value = priority,
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? _getPriorityColor(priority, cs).withValues(alpha: 0.1)
                                  : (isLight ? Colors.grey.shade50 : const Color(0xFF161A22)),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected
                                    ? _getPriorityColor(priority, cs)
                                    : cs.outlineVariant.withValues(alpha: 0.3),
                                width: isSelected ? 1.5 : 1.0,
                              ),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _getPriorityIcon(priority),
                                  color: isSelected
                                      ? _getPriorityColor(priority, cs)
                                      : cs.onSurfaceVariant.withValues(alpha: 0.7),
                                  size: 20,
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  priority,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                    color: isSelected
                                        ? _getPriorityColor(priority, cs)
                                        : cs.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }));
                }).toList(),
              ),
              const SizedBox(height: 20),

            // ── Initial Message ─────────────────────────────────────────
            _buildFieldLabel('MESSAGE DETAILS', cs),
            const SizedBox(height: 6),
            TextField(
              controller: ctrl.initialMessageCtrl,
              maxLines: 6,
              decoration: InputDecoration(
                hintText: 'Provide detailed information about the issue...',
                filled: true,
                fillColor: isLight ? Colors.grey.shade50 : const Color(0xFF161A22),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.5)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.3)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: cs.primary, width: 1.5),
                ),
              ),
            ),
            const SizedBox(height: 32),

            // ── Submit Button ───────────────────────────────────────────
            Obx(() => ctrl.isCreatingTicket.value
                ? const Center(child: CircularProgressIndicator())
                : FilledButton(
                    onPressed: ctrl.createTicket,
                    style: FilledButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: cs.primary,
                      foregroundColor: cs.onPrimary,
                    ),
                    child: const Text(
                      'Submit Ticket',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )),
          ],
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String label, ColorScheme cs) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.1,
        color: cs.onSurfaceVariant.withValues(alpha: 0.7),
      ),
    );
  }

  Color _getPriorityColor(String priority, ColorScheme cs) {
    switch (priority.toLowerCase()) {
      case 'high':
        return Colors.blue.shade600;
      case 'medium':
        return Colors.orange.shade700;
      case 'low':
      default:
        return Colors.grey.shade600;
    }
  }

  IconData _getPriorityIcon(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return Icons.error_outline_rounded;
      case 'medium':
        return Icons.warning_amber_rounded;
      case 'low':
      default:
        return Icons.info_outline_rounded;
    }
  }
}

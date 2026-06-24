import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'support_tickets_controller.dart';
import 'package:jkworlds/data/models/support_ticket_model.dart';
import 'package:jkworlds/app/routes/app_routes.dart';

class SupportTicketsListView extends StatelessWidget {
  const SupportTicketsListView({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<SupportTicketsController>();
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isLight = theme.brightness == Brightness.light;

    // Start inbox polling when view is initialized/displayed
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ctrl.startInboxPolling();
      ctrl.refreshTickets(showLoading: false);
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Support Messages'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => ctrl.refreshTickets(showLoading: true),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ctrl.refreshTickets(showLoading: true),
        child: Column(
          children: [
            // ── Top Action & Search Bar ─────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Support Tickets',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: cs.onSurface,
                      ),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => Get.toNamed(AppRoutes.createSupportTicket),
                    icon: const Icon(Icons.add_rounded, size: 18),
                    label: const Text('Create New'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: cs.primary,
                      foregroundColor: cs.onPrimary,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    ),
                  ),
                ],
              ),
            ),

            // Search Field
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: TextField(
                controller: ctrl.searchCtrl,
                decoration: InputDecoration(
                  hintText: 'Search tickets by subject...',
                  prefixIcon: Icon(Icons.search_rounded, color: cs.primary),
                  suffixIcon: Obx(() => ctrl.searchQuery.value.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded),
                          onPressed: () => ctrl.searchCtrl.clear(),
                        )
                      : const SizedBox.shrink()),
                  filled: true,
                  fillColor: isLight ? Colors.grey.shade100 : const Color(0xFF161A22),
                  contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
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
            ),

            // Filter Chips
            SizedBox(
              height: 50,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                children: ['All', 'Low', 'Medium', 'High'].map((priority) {
                  return Obx(() {
                    final isSelected = ctrl.selectedPriorityFilter.value == priority;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        selected: isSelected,
                        label: Text(priority),
                        labelStyle: TextStyle(
                          color: isSelected ? cs.onPrimary : cs.onSurfaceVariant,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          fontSize: 13,
                        ),
                        selectedColor: cs.primary,
                        checkmarkColor: cs.onPrimary,
                        backgroundColor: isLight ? Colors.grey.shade50 : const Color(0xFF161A22),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: BorderSide(
                            color: isSelected ? cs.primary : cs.outlineVariant.withValues(alpha: 0.4),
                          ),
                        ),
                        onSelected: (_) {
                          ctrl.selectedPriorityFilter.value = priority;
                        },
                      ),
                    );
                  });
                }).toList(),
              ),
            ),

            const SizedBox(height: 8),

            // ── Ticket Listing ──────────────────────────────────────────
            Expanded(
              child: Obx(() {
                if (ctrl.isLoadingTickets.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                final list = ctrl.filteredTickets;
                if (list.isEmpty) {
                  return ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      SizedBox(height: MediaQuery.of(context).size.height * 0.15),
                      Center(
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: cs.primaryContainer.withValues(alpha: 0.2),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.chat_bubble_outline_rounded, size: 48, color: cs.primary),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No tickets found',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: cs.onSurface,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              ctrl.searchQuery.value.isNotEmpty
                                  ? 'Try refining your search query.'
                                  : 'Tap "+ Create New" to log a support request.',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: cs.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: list.length,
                  itemBuilder: (context, index) {
                    final ticket = list[index];
                    return _buildTicketCard(context, ticket, index + 1, theme, cs);
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTicketCard(
    BuildContext context,
    SupportTicketModel ticket,
    int index,
    ThemeData theme,
    ColorScheme cs,
  ) {
    final isLight = theme.brightness == Brightness.light;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isLight ? 0.03 : 0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Colored Priority Left border accent
              Container(
                width: 5,
                color: _getPriorityColor(ticket.priority, cs),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'SL: $index',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: cs.onSurfaceVariant.withValues(alpha: 0.6),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            ticket.date,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: cs.onSurfaceVariant.withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        ticket.subject,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: cs.onSurface,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          // Priority Badge
                          _buildBadge(
                            label: ticket.priority,
                            bgColor: _getPriorityColor(ticket.priority, cs).withValues(alpha: 0.1),
                            textColor: _getPriorityColor(ticket.priority, cs),
                          ),
                          const SizedBox(width: 8),
                          // Status Badge
                          _buildBadge(
                            label: ticket.statusLabel.toUpperCase(),
                            bgColor: _getStatusColor(ticket.status, cs).withValues(alpha: 0.1),
                            textColor: _getStatusColor(ticket.status, cs),
                          ),
                          const Spacer(),
                          // Action button
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () => Get.find<SupportTicketsController>().openTicket(ticket),
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  border: Border.all(color: cs.primary.withValues(alpha: 0.4)),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.remove_red_eye_outlined, size: 14, color: cs.primary),
                                    const SizedBox(width: 4),
                                    Text(
                                      'View',
                                      style: TextStyle(
                                        color: cs.primary,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    if (ticket.unreadCount > 0) ...[
                                      const SizedBox(width: 6),
                                      Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: BoxDecoration(
                                          color: cs.error,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Text(
                                          '${ticket.unreadCount}',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 9,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                          )
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBadge({
    required String label,
    required Color bgColor,
    required Color textColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Color _getPriorityColor(String priority, ColorScheme cs) {
    switch (priority.toLowerCase()) {
      case 'high':
        return Colors.blue.shade600; // Blue (based on screenshot: "High" in blue badge)
      case 'medium':
        return Colors.orange.shade700;
      case 'low':
      default:
        return Colors.grey.shade600;
    }
  }

  Color _getStatusColor(int status, ColorScheme cs) {
    switch (status) {
      case 0: // pending
        return Colors.amber.shade700;
      case 1: // open
        return Colors.green.shade600; // Green (based on screenshot: "Open" in green badge)
      case 2: // rejected
        return Colors.red.shade600;
      case 3: // closed
      default:
        return Colors.grey.shade500;
    }
  }
}

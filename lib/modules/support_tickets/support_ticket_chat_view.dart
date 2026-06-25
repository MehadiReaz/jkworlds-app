import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'support_tickets_controller.dart';
import 'package:jkworlds/data/models/support_message_model.dart';

class SupportTicketChatView extends StatelessWidget {
  const SupportTicketChatView({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<SupportTicketsController>();
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isLight = theme.brightness == Brightness.light;

    return WillPopScope(
      onWillPop: () async {
        // When leaving chat, restart the inbox polling
        ctrl.startInboxPolling();
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Obx(() => Text(ctrl.activeTicket.value?.subject ?? 'Chat Room')),
          centerTitle: false,
          actions: [
            Obx(() {
              final ticket = ctrl.activeTicket.value;
              if (ticket == null) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusColor(ticket.status, cs).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      ticket.statusLabel.toUpperCase(),
                      style: TextStyle(
                        color: _getStatusColor(ticket.status, cs),
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
        body: Obx(() {
          if (ctrl.activeTicket.value == null) {
            return const Center(child: CircularProgressIndicator());
          }

          final ticket = ctrl.activeTicket.value!;
          final canSend = ticket.canSendMessage && ticket.status != 3;

          return Column(
            children: [
              // ── Message Log Timeline ────────────────────────────────────
              Expanded(
                child: ctrl.isLoadingMessages.value
                    ? const Center(child: CircularProgressIndicator())
                    : Column(
                        children: [
                          // Load Older Messages Button (Optional pagination indicator)
                          if (ctrl.hasMoreOlder.value)
                            Obx(() => ctrl.isLoadingOlder.value
                                ? const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 8.0),
                                    child: SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    ),
                                  )
                                : TextButton.icon(
                                    onPressed: ctrl.loadOlderMessages,
                                    icon: const Icon(Icons.history_rounded, size: 16),
                                    label: const Text('Load Older Messages'),
                                    style: TextButton.styleFrom(
                                      textStyle: const TextStyle(fontSize: 12),
                                    ),
                                  )),
                          
                          Expanded(
                            child: ctrl.messages.isEmpty
                                ? _buildEmptyTimelineState(theme, cs)
                                : ListView.builder(
                                    controller: ctrl.chatScrollController,
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                    itemCount: ctrl.messages.length,
                                    itemBuilder: (context, index) {
                                      final msg = ctrl.messages[index];
                                      return _buildMessageItem(context, msg, theme, cs);
                                    },
                                  ),
                          ),
                        ],
                      ),
              ),

              // ── Selected Attachment Preview (Floating above input) ──────
              Obx(() {
                final path = ctrl.selectedAttachmentPath.value;
                if (path == null) return const SizedBox.shrink();
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    border: Border(
                      top: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.3)),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: cs.outlineVariant),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            File(path),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          path.split('/').last,
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: cs.onSurface,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.cancel_rounded, color: cs.error),
                        onPressed: ctrl.clearAttachment,
                      ),
                    ],
                  ),
                );
              }),

              // ── Chat Input Container ────────────────────────────────────
              SafeArea(
                child: Container(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    border: Border(
                      top: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.3)),
                    ),
                  ),
                  child: !canSend
                      ? _buildClosedTicketBanner(theme, cs)
                      : Row(
                          children: [
                            // Attachment Trigger Button
                            IconButton(
                              icon: Icon(Icons.attachment_rounded, color: cs.primary),
                              style: IconButton.styleFrom(
                                backgroundColor: cs.primaryContainer.withValues(alpha: 0.3),
                                padding: const EdgeInsets.all(12),
                              ),
                              onPressed: ctrl.pickAttachment,
                            ),
                            const SizedBox(width: 10),
                            
                            // Message TextField Input
                            Expanded(
                              child: TextField(
                                controller: ctrl.messageSendCtrl,
                                minLines: 1,
                                maxLines: 4,
                                textCapitalization: TextCapitalization.sentences,
                                decoration: InputDecoration(
                                  hintText: 'Type your message...',
                                  filled: true,
                                  fillColor: isLight ? Colors.grey.shade50 : const Color(0xFF161A22),
                                  contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(24),
                                    borderSide: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.5)),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(24),
                                    borderSide: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.3)),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(24),
                                    borderSide: BorderSide(color: cs.primary, width: 1.5),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),

                            // Submit Message Button
                            Obx(() => ctrl.isSendingMessage.value
                                ? const SizedBox(
                                    width: 48,
                                    height: 48,
                                    child: Padding(
                                      padding: EdgeInsets.all(12.0),
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    ),
                                  )
                                : IconButton(
                                    icon: const Icon(Icons.send_rounded, color: Colors.white),
                                    style: IconButton.styleFrom(
                                      backgroundColor: cs.primary,
                                      padding: const EdgeInsets.all(12),
                                    ),
                                    onPressed: ctrl.sendMessage,
                                  )),
                          ],
                        ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildEmptyTimelineState(ThemeData theme, ColorScheme cs) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.forum_outlined, size: 48, color: cs.primary.withValues(alpha: 0.5)),
          const SizedBox(height: 12),
          Text(
            'No messages here yet.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: cs.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageItem(
    BuildContext context,
    SupportMessageModel msg,
    ThemeData theme,
    ColorScheme cs,
  ) {
    final isMe = msg.isMine;
    final isLight = theme.brightness == Brightness.light;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Show sender avatar on the left if message is from admin/staff
          if (!isMe) ...[
            CircleAvatar(
              radius: 18,
              backgroundColor: cs.secondaryContainer,
              backgroundImage: msg.senderAvatar != null && msg.senderAvatar!.isNotEmpty
                  ? NetworkImage(msg.senderAvatar!)
                  : null,
              child: msg.senderAvatar == null || msg.senderAvatar!.isEmpty
                  ? Icon(Icons.support_agent_rounded, size: 18, color: cs.onSecondaryContainer)
                  : null,
            ),
            const SizedBox(width: 8),
          ],

          // Bubble detail Column
          Expanded(
            child: Column(
              crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                // Sender label & time
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      isMe ? 'You' : msg.senderName,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      msg.createdAt,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: cs.onSurfaceVariant.withValues(alpha: 0.5),
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),

                // Text Bubble Container
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isMe
                        ? cs.primary
                        : (isLight ? Colors.grey.shade100 : const Color(0xFF1C222E)),
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: isMe ? const Radius.circular(16) : Radius.zero,
                      bottomRight: isMe ? Radius.zero : const Radius.circular(16),
                    ),
                    border: isMe
                        ? null
                        : Border.all(color: cs.outlineVariant.withValues(alpha: 0.2)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Render message text if not empty and not the image placeholder
                      if (msg.message.isNotEmpty && msg.message != '[Image]')
                        Text(
                          msg.message,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: isMe ? cs.onPrimary : cs.onSurface,
                          ),
                        ),

                      // Render attachment image if present
                      if (msg.file != null && msg.file!.isNotEmpty) ...[
                        if (msg.message.isNotEmpty && msg.message != '[Image]') const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: InkWell(
                            onTap: () => _showImageDialog(context, msg.file!),
                            child: Hero(
                              tag: msg.file!,
                              child: Image.network(
                                msg.file!,
                                width: 240,
                                height: 160,
                                fit: BoxFit.cover,
                                loadingBuilder: (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Container(
                                    width: 240,
                                    height: 160,
                                    color: Colors.black.withValues(alpha: 0.05),
                                    child: const Center(
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    ),
                                  );
                                },
                                errorBuilder: (_, __, ___) => Container(
                                  width: 240,
                                  height: 160,
                                  color: cs.errorContainer,
                                  child: Center(
                                    child: Icon(Icons.broken_image_rounded, color: cs.onErrorContainer),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClosedTicketBanner(ThemeData theme, ColorScheme cs) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cs.errorContainer.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.error.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.lock_rounded, color: cs.error, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'This ticket is closed. You cannot send further replies.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: cs.error,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showImageDialog(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(8),
        child: Stack(
          alignment: Alignment.topRight,
          children: [
            InteractiveViewer(
              maxScale: 4.0,
              child: Hero(
                tag: imageUrl,
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close_rounded, color: Colors.white, size: 30),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(int status, ColorScheme cs) {
    switch (status) {
      case 0:
        return Colors.amber.shade700;
      case 1:
        return Colors.green.shade600;
      case 2:
        return Colors.red.shade600;
      case 3:
      default:
        return Colors.grey.shade500;
    }
  }
}

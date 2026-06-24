import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jkworlds/core/utils/logger.dart';
import 'package:jkworlds/core/utils/snackbar_helper.dart';
import 'package:jkworlds/core/utils/image_picker_helper.dart';
import 'package:jkworlds/data/services/support_ticket_service.dart';
import 'package:jkworlds/data/models/support_ticket_model.dart';
import 'package:jkworlds/data/models/support_message_model.dart';
import 'package:jkworlds/app/routes/app_routes.dart';

class SupportTicketsController extends GetxController {
  SupportTicketService get _service => Get.find<SupportTicketService>();

  // ── Tickets List State ──────────────────────────────────────────
  final tickets = <SupportTicketModel>[].obs;
  final isLoadingTickets = false.obs;
  final totalUnread = 0.obs;

  // Search & Filter Settings
  final searchCtrl = TextEditingController();
  final searchQuery = ''.obs;
  final selectedPriorityFilter = 'All'.obs; // All, Low, Medium, High

  // ── Ticket Creation State ───────────────────────────────────────
  final subjectCtrl = TextEditingController();
  final initialMessageCtrl = TextEditingController();
  final createPriority = 'Medium'.obs; // Low, Medium, High
  final isCreatingTicket = false.obs;

  // ── Chat Detail State ───────────────────────────────────────────
  final activeTicket = Rxn<SupportTicketModel>();
  final messages = <SupportMessageModel>[].obs;
  final isLoadingMessages = false.obs;
  final isSendingMessage = false.obs;
  
  // Chat Input / Attachment
  final messageSendCtrl = TextEditingController();
  final selectedAttachmentPath = RxnString();
  final chatScrollController = ScrollController();

  // Pagination for Older Messages
  final hasMoreOlder = false.obs;
  final isLoadingOlder = false.obs;
  final firstId = 0.obs;
  final lastId = 0.obs;

  // Polling Configuration
  Timer? _inboxTimer;
  Timer? _chatTimer;
  int _inboxInterval = 12;
  int _chatLightInterval = 3;

  @override
  void onInit() {
    super.onInit();
    searchCtrl.addListener(() {
      searchQuery.value = searchCtrl.text;
    });
    refreshTickets();
  }

  @override
  void onClose() {
    _inboxTimer?.cancel();
    _chatTimer?.cancel();
    searchCtrl.dispose();
    subjectCtrl.dispose();
    initialMessageCtrl.dispose();
    messageSendCtrl.dispose();
    chatScrollController.dispose();
    super.onClose();
  }

  // ── List & Filter Methods ───────────────────────────────────────
  
  /// Fetches support tickets list.
  Future<void> refreshTickets({bool showLoading = true}) async {
    if (showLoading) isLoadingTickets.value = true;
    try {
      final res = await _service.fetchTickets();
      final list = res['tickets'] as List<SupportTicketModel>? ?? [];
      tickets.assignAll(list);
      totalUnread.value = res['total_unread'] as int? ?? 0;

      // Extract dynamic polling interval from API metadata if available
      final pollingMeta = res['polling'] as Map<String, dynamic>? ?? {};
      if (pollingMeta['inbox_interval_seconds'] != null) {
        _inboxInterval = pollingMeta['inbox_interval_seconds'] as int;
      }
      if (pollingMeta['chat_light_interval_seconds'] != null) {
        _chatLightInterval = pollingMeta['chat_light_interval_seconds'] as int;
      }
    } catch (e) {
      logger.e('[SupportTicketsController] refreshTickets error', error: e);
    } finally {
      if (showLoading) isLoadingTickets.value = false;
    }
  }

  /// List filter selector.
  List<SupportTicketModel> get filteredTickets {
    return tickets.where((t) {
      final matchesSearch = searchQuery.value.isEmpty ||
          t.subject.toLowerCase().contains(searchQuery.value.toLowerCase());
      final matchesPriority = selectedPriorityFilter.value == 'All' ||
          t.priority.toLowerCase() == selectedPriorityFilter.value.toLowerCase();
      return matchesSearch && matchesPriority;
    }).toList();
  }

  // ── Polling Management ──────────────────────────────────────────

  /// Starts polling the inbox/tickets list status.
  void startInboxPolling() {
    _chatTimer?.cancel();
    _inboxTimer?.cancel();
    _inboxTimer = Timer.periodic(Duration(seconds: _inboxInterval), (_) async {
      await refreshTickets(showLoading: false);
    });
  }

  /// Starts light polling for active chat room details.
  void _startChatPolling(int ticketId) {
    _inboxTimer?.cancel();
    _chatTimer?.cancel();
    _chatTimer = Timer.periodic(Duration(seconds: _chatLightInterval), (_) async {
      try {
        final lastMsgId = messages.isNotEmpty ? messages.last.id : 0;
        final res = await _service.fetchMessages(ticketId, light: true, afterId: lastMsgId);
        final hasNew = res['has_new'] as bool? ?? false;
        
        if (hasNew) {
          final newMsgsRes = await _service.fetchMessages(ticketId, afterId: lastMsgId, limit: 50);
          final newMsgsList = newMsgsRes['messages'] as List<SupportMessageModel>? ?? [];
          if (newMsgsList.isNotEmpty) {
            messages.addAll(newMsgsList);
            lastId.value = newMsgsRes['last_id'] as int? ?? 0;
            _markAsReadLocal(ticketId, lastId.value);
            _scrollToBottom();
          }
        }
      } catch (e) {
        logger.e('[SupportTicketsController] Chat polling error', error: e);
      }
    });
  }

  // ── Chat Actions ────────────────────────────────────────────────

  /// Opens chat detail screen for ticket.
  Future<void> openTicket(SupportTicketModel ticket) async {
    activeTicket.value = ticket;
    messages.clear();
    selectedAttachmentPath.value = null;
    messageSendCtrl.clear();
    
    Get.toNamed(AppRoutes.supportTicketChat);
    
    isLoadingMessages.value = true;
    try {
      final res = await _service.fetchMessages(ticket.id, limit: 20);
      final list = res['messages'] as List<SupportMessageModel>? ?? [];
      messages.assignAll(list);
      
      hasMoreOlder.value = res['has_more_older'] as bool? ?? false;
      firstId.value = res['first_id'] as int? ?? 0;
      lastId.value = res['last_id'] as int? ?? 0;
      
      if (ticket.unreadCount > 0) {
        _markAsReadLocal(ticket.id, lastId.value);
      }
      
      _startChatPolling(ticket.id);
    } catch (e) {
      SnackbarHelper.showError(e.toString());
    } finally {
      isLoadingMessages.value = false;
      _scrollToBottom(animate: false);
    }
  }

  /// Paginates older messages.
  Future<void> loadOlderMessages() async {
    if (activeTicket.value == null || isLoadingOlder.value || !hasMoreOlder.value) return;

    isLoadingOlder.value = true;
    try {
      final ticketId = activeTicket.value!.id;
      final res = await _service.fetchMessages(ticketId, beforeId: firstId.value, limit: 20);
      final olderList = res['messages'] as List<SupportMessageModel>? ?? [];
      
      if (olderList.isNotEmpty) {
        messages.insertAll(0, olderList);
        firstId.value = res['first_id'] as int? ?? 0;
        hasMoreOlder.value = res['has_more_older'] as bool? ?? false;
      } else {
        hasMoreOlder.value = false;
      }
    } catch (e) {
      SnackbarHelper.showError(e.toString());
    } finally {
      isLoadingOlder.value = false;
    }
  }

  /// Submits a reply message to the ticket.
  Future<void> sendMessage() async {
    final ticket = activeTicket.value;
    if (ticket == null) return;

    final text = messageSendCtrl.text.trim();
    final file = selectedAttachmentPath.value;

    if (file != null && text.isEmpty) {
      SnackbarHelper.showError('Please enter a message to send with your attachment.');
      return;
    }

    if (text.isEmpty) return;

    isSendingMessage.value = true;
    try {
      final newMessage = await _service.sendMessage(ticket.id, message: text, filePath: file);
      messages.add(newMessage);
      messageSendCtrl.clear();
      selectedAttachmentPath.value = null;
      
      // Update local ticket status fields
      final updatedTicket = SupportTicketModel(
        id: ticket.id,
        subject: ticket.subject,
        priority: ticket.priority,
        status: ticket.status,
        statusLabel: ticket.statusLabel,
        canSendMessage: ticket.canSendMessage,
        unreadCount: 0,
        lastMessageId: newMessage.id,
        date: ticket.date,
        createdAt: ticket.createdAt,
        updatedAt: DateTime.now(),
      );
      activeTicket.value = updatedTicket;

      final index = tickets.indexWhere((t) => t.id == ticket.id);
      if (index != -1) {
        tickets[index] = updatedTicket;
      }

      _scrollToBottom();
    } catch (e) {
      SnackbarHelper.showError(e.toString());
    } finally {
      isSendingMessage.value = false;
    }
  }

  /// Picks an attachment from gallery/camera.
  Future<void> pickAttachment() async {
    final path = await ImagePickerHelper.pickImageWithBottomSheet(
      title: 'Select Message Attachment',
    );
    if (path != null) {
      selectedAttachmentPath.value = path;
    }
  }

  /// Clears chosen image attachment.
  void clearAttachment() {
    selectedAttachmentPath.value = null;
  }

  void _markAsReadLocal(int ticketId, int lastMsgId) async {
    try {
      final updatedTicket = await _service.markAsRead(ticketId, lastId: lastMsgId);
      if (activeTicket.value?.id == ticketId) {
        activeTicket.value = updatedTicket;
      }
      
      final idx = tickets.indexWhere((t) => t.id == ticketId);
      if (idx != -1) {
        tickets[idx] = updatedTicket;
      }
      
      totalUnread.value = tickets.fold(0, (sum, t) => sum + t.unreadCount);
    } catch (e) {
      logger.e('[SupportTicketsController] markAsRead error', error: e);
    }
  }

  void _scrollToBottom({bool animate = true}) {
    int retries = 0;
    void scroll() {
      if (chatScrollController.hasClients) {
        try {
          final position = chatScrollController.position;
          if (animate) {
            position.animateTo(
              position.maxScrollExtent,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          } else {
            position.jumpTo(position.maxScrollExtent);
          }
        } catch (e) {
          logger.e('[SupportTicketsController] scrollToBottom error', error: e);
        }
      } else if (retries < 15) {
        retries++;
        WidgetsBinding.instance.addPostFrameCallback((_) => scroll());
      }
    }
    WidgetsBinding.instance.addPostFrameCallback((_) => scroll());
  }

  // ── Ticket Creation ─────────────────────────────────────────────

  /// Submits the new support ticket form.
  Future<void> createTicket() async {
    final subject = subjectCtrl.text.trim();
    final message = initialMessageCtrl.text.trim();
    if (subject.isEmpty || message.isEmpty) {
      SnackbarHelper.showError('Please fill in both Subject and Message');
      return;
    }

    isCreatingTicket.value = true;
    try {
      final ticket = await _service.createTicket(
        subject: subject,
        message: message,
        priority: createPriority.value,
      );
      tickets.insert(0, ticket);
      
      subjectCtrl.clear();
      initialMessageCtrl.clear();
      createPriority.value = 'Medium';
      
      Get.back();
      SnackbarHelper.showSuccess('Support ticket created successfully');
    } catch (e) {
      SnackbarHelper.showError(e.toString());
    } finally {
      isCreatingTicket.value = false;
    }
  }
}

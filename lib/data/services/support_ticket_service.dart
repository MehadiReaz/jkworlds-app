import 'package:get/get.dart' hide Response, FormData, MultipartFile;
import 'package:dio/dio.dart' show FormData, MultipartFile;
import 'package:jkworlds/core/constants/api_constants.dart';
import 'package:jkworlds/core/errors/app_exception.dart';
import 'package:jkworlds/core/utils/logger.dart';
import 'package:jkworlds/data/providers/api_provider.dart';
import 'package:jkworlds/data/models/support_ticket_model.dart';
import 'package:jkworlds/data/models/support_message_model.dart';
import 'package:jkworlds/data/models/support_ticket_summary_model.dart';

class SupportTicketService extends GetxService {
  ApiProvider get _api => Get.find<ApiProvider>();

  /// Retrieves all tickets belonging to the authenticated user.
  /// GET /api/support-tickets
  Future<Map<String, dynamic>> fetchTickets() async {
    try {
      final response = await _api.get(ApiConstants.supportTickets);
      final body = response.data;
      if (body == null || body is! Map<String, dynamic>) {
        throw const ServerException('Empty or invalid support tickets response');
      }

      final success = body['success'] as bool? ?? body['status'] as bool? ?? false;
      if (!success) {
        final msg = body['message'] as String? ?? 'Failed to fetch tickets';
        throw ServerException(msg);
      }

      final data = body['data'] as Map<String, dynamic>? ?? {};
      final ticketsList = data['tickets'] as List? ?? [];
      final tickets = ticketsList
          .whereType<Map<String, dynamic>>()
          .map(SupportTicketModel.fromJson)
          .toList();

      return {
        'tickets': tickets,
        'total_unread': data['total_unread'] as int? ?? 0,
        'polling': data['polling'] as Map<String, dynamic>? ?? {},
      };
    } on AppException {
      rethrow;
    } catch (e, st) {
      logger.e('[SupportTicketService] fetchTickets error', error: e, stackTrace: st);
      throw UnknownException(e.toString());
    }
  }

  /// Creates a new support ticket with an initial message.
  /// POST /api/support-tickets
  Future<SupportTicketModel> createTicket({
    required String subject,
    required String message,
    required String priority,
  }) async {
    try {
      final response = await _api.post(
        ApiConstants.supportTickets,
        data: {
          'subject': subject,
          'message': message,
          'priority': priority,
        },
      );

      final body = response.data;
      if (body == null || body is! Map<String, dynamic>) {
        throw const ServerException('Empty or invalid create ticket response');
      }

      final success = body['success'] as bool? ?? body['status'] as bool? ?? false;
      if (!success) {
        final msg = body['message'] as String? ?? 'Failed to create support ticket';
        throw ServerException(msg);
      }

      final data = body['data'];
      if (data == null || data is! Map<String, dynamic>) {
        throw const ServerException('Create ticket missing "data" node');
      }

      return SupportTicketModel.fromJson(data);
    } on AppException {
      rethrow;
    } catch (e, st) {
      logger.e('[SupportTicketService] createTicket error', error: e, stackTrace: st);
      throw UnknownException(e.toString());
    }
  }

  /// Retrieves messages for a ticket (supports light checking, cursors, and limits).
  /// GET /api/support-tickets/{ticket}
  Future<Map<String, dynamic>> fetchMessages(
    int ticketId, {
    bool light = false,
    int? afterId,
    int? beforeId,
    int? limit,
  }) async {
    try {
      final queryParams = {
        'light': light ? 1 : 0,
        if (afterId != null && afterId > 0) 'after_id': afterId,
        if (beforeId != null && beforeId > 0) 'before_id': beforeId,
        if (limit != null && limit > 0) 'limit': limit,
      };

      final response = await _api.get(
        ApiConstants.supportTicketDetails(ticketId),
        queryParameters: queryParams,
      );

      final body = response.data;
      if (body == null || body is! Map<String, dynamic>) {
        throw const ServerException('Empty or invalid fetch messages response');
      }

      final success = body['success'] as bool? ?? body['status'] as bool? ?? false;
      if (!success) {
        final msg = body['message'] as String? ?? 'Failed to fetch messages';
        throw ServerException(msg);
      }

      final data = body['data'] as Map<String, dynamic>? ?? {};

      // Parse ticket status/sending details from data['ticket'] if nested, else fallback to root data keys
      final ticketMap = data['ticket'] as Map<String, dynamic>?;
      final ticketStatus = ticketMap?['status'] as int? ?? data['ticket_status'] as int? ?? 1;
      final statusLabel = ticketMap?['status_label'] as String? ?? data['status_label'] as String? ?? 'open';
      final canSendMessage = ticketMap?['can_send_message'] as bool? ?? data['can_send_message'] as bool? ?? true;

      if (light) {
        return {
          'has_new': data['has_new'] as bool? ?? false,
          'ticket_status': ticketStatus,
          'can_send_message': canSendMessage,
        };
      }

      final messagesList = data['messages'] as List? ?? [];
      final messages = messagesList
          .whereType<Map<String, dynamic>>()
          .map(SupportMessageModel.fromJson)
          .toList();

      return {
        'messages': messages,
        'first_id': data['first_id'] as int? ?? 0,
        'last_id': data['last_id'] as int? ?? 0,
        'has_more_older': data['has_more_older'] as bool? ?? false,
        'ticket_status': ticketStatus,
        'status_label': statusLabel,
        'can_send_message': canSendMessage,
      };
    } on AppException {
      rethrow;
    } catch (e, st) {
      logger.e('[SupportTicketService] fetchMessages error', error: e, stackTrace: st);
      throw UnknownException(e.toString());
    }
  }

  /// Appends a new user message to the ticket, optionally uploading a file attachment.
  /// POST /api/support-tickets/{ticket}/messages
  Future<SupportMessageModel> sendMessage(
    int ticketId, {
    required String message,
    String? filePath,
  }) async {
    try {
      final formData = FormData.fromMap({
        'message': message,
        if (filePath != null && filePath.isNotEmpty)
          'file': await MultipartFile.fromFile(
            filePath,
            filename: filePath.split('/').last,
          ),
      });

      final response = await _api.postFormData(
        ApiConstants.supportTicketSendMessage(ticketId),
        formData,
      );

      final body = response.data;
      if (body == null || body is! Map<String, dynamic>) {
        throw const ServerException('Empty or invalid send message response');
      }

      final success = body['success'] as bool? ?? body['status'] as bool? ?? false;
      if (!success) {
        final msg = body['message'] as String? ?? 'Failed to send message';
        throw ServerException(msg);
      }

      final data = body['data'];
      if (data == null || data is! Map<String, dynamic>) {
        throw const ServerException('Send message response missing "data" node');
      }

      return SupportMessageModel.fromJson(data);
    } on AppException {
      rethrow;
    } catch (e, st) {
      logger.e('[SupportTicketService] sendMessage error', error: e, stackTrace: st);
      throw UnknownException(e.toString());
    }
  }

  /// Marks a ticket as read for the user up to a specified message ID.
  /// GET /api/support-tickets/{ticket} with mark_read=1
  Future<SupportTicketModel> markAsRead(int ticketId, {int? lastId}) async {
    try {
      final response = await _api.get(
        ApiConstants.supportTicketDetails(ticketId),
        queryParameters: {
          'mark_read': 1,
          if (lastId != null && lastId > 0) 'last_id': lastId,
        },
      );

      final body = response.data;
      if (body == null || body is! Map<String, dynamic>) {
        throw const ServerException('Empty or invalid mark read response');
      }

      final success = body['success'] as bool? ?? body['status'] as bool? ?? false;
      if (!success) {
        final msg = body['message'] as String? ?? 'Failed to mark ticket as read';
        throw ServerException(msg);
      }

      final data = body['data'] as Map<String, dynamic>? ?? {};
      final ticketData = data['ticket'] as Map<String, dynamic>?;
      if (ticketData == null) {
        throw const ServerException('Mark read response missing "ticket" node');
      }

      return SupportTicketModel.fromJson(ticketData);
    } on AppException {
      rethrow;
    } catch (e, st) {
      logger.e('[SupportTicketService] markAsRead error', error: e, stackTrace: st);
      throw UnknownException(e.toString());
    }
  }

  /// Retrieves a summary mapping of unread message counts for all active tickets.
  /// GET /api/support-tickets/unread-summary
  Future<SupportTicketSummaryModel> fetchUnreadSummary() async {
    try {
      final response = await _api.get(ApiConstants.supportTicketsUnreadSummary);
      final body = response.data;
      if (body == null || body is! Map<String, dynamic>) {
        throw const ServerException('Empty or invalid unread summary response');
      }

      final success = body['success'] as bool? ?? body['status'] as bool? ?? false;
      if (!success) {
        final msg = body['message'] as String? ?? 'Failed to fetch unread summary';
        throw ServerException(msg);
      }

      final data = body['data'] as Map<String, dynamic>? ?? {};
      return SupportTicketSummaryModel.fromJson(data);
    } on AppException {
      rethrow;
    } catch (e, st) {
      logger.e('[SupportTicketService] fetchUnreadSummary error', error: e, stackTrace: st);
      throw UnknownException(e.toString());
    }
  }

  /// Batch checks multiple tickets to see if new messages have arrived.
  /// POST /api/support-tickets/sync
  Future<SupportTicketSummaryModel> syncTickets(Map<String, int> ticketCursors) async {
    try {
      // API expects format: {"tickets": {"12": 143, "15": 150}}
      // Ensure key is String inside body
      final stringCursors = ticketCursors.map((key, value) => MapEntry(key.toString(), value));
      final response = await _api.post(
        ApiConstants.supportTicketsSync,
        data: {
          'tickets': stringCursors,
        },
      );

      final body = response.data;
      if (body == null || body is! Map<String, dynamic>) {
        throw const ServerException('Empty or invalid sync tickets response');
      }

      final success = body['success'] as bool? ?? body['status'] as bool? ?? false;
      if (!success) {
        final msg = body['message'] as String? ?? 'Failed to sync tickets';
        throw ServerException(msg);
      }

      final data = body['data'] as Map<String, dynamic>? ?? {};
      return SupportTicketSummaryModel.fromJson(data);
    } on AppException {
      rethrow;
    } catch (e, st) {
      logger.e('[SupportTicketService] syncTickets error', error: e, stackTrace: st);
      throw UnknownException(e.toString());
    }
  }
}

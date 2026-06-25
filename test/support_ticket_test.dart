import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart' hide Response, FormData;
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:jkworlds/data/models/support_ticket_model.dart';
import 'package:jkworlds/data/models/support_message_model.dart';
import 'package:jkworlds/data/services/support_ticket_service.dart';
import 'package:jkworlds/data/providers/api_provider.dart';
import 'package:jkworlds/modules/support_tickets/support_tickets_controller.dart';

class MockApiProvider extends ApiProvider {
  final Map<String, dynamic> mockResponses;

  MockApiProvider({required this.mockResponses});

  @override
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    if (mockResponses.containsKey(path)) {
      return Response(
        requestOptions: RequestOptions(path: path),
        data: mockResponses[path],
        statusCode: 200,
      );
    }
    // If path is parameterized like /api/support-tickets/12
    final regExp = RegExp(r'/api/support-tickets/\d+$');
    if (regExp.hasMatch(path)) {
      final isLight = queryParameters?['light'] == 1 || queryParameters?['light'] == true;
      final isMarkRead = queryParameters?['mark_read'] == 1 || queryParameters?['mark_read'] == true;

      if (isMarkRead) {
        return Response(
          requestOptions: RequestOptions(path: path),
          data: {
            'success': true,
            'message': 'Ticket marked as read.',
            'data': {
              'ticket': {
                'id': 12,
                'subject': 'Unable to verify driving license',
                'priority': 'High',
                'status': 1,
                'status_label': 'open',
                'can_send_message': true,
                'unread_count': 0,
                'last_message_id': 145,
                'date': '2026-06-24',
                'created_at': '2026-06-24T05:30:17.000000Z',
                'updated_at': '2026-06-24T06:12:45.000000Z',
              }
            }
          },
          statusCode: 200,
        );
      }

      if (isLight) {
        return Response(
          requestOptions: RequestOptions(path: path),
          data: {
            'success': true,
            'message': 'Check success',
            'data': {
              'ticket': {
                'id': 12,
                'subject': 'Unable to verify driving license',
                'priority': 'High',
                'status': 1,
                'status_label': 'open',
                'can_send_message': true,
                'unread_count': 2,
                'last_message_id': 147,
                'date': '2026-06-24',
                'created_at': '2026-06-24T05:30:17.000000Z',
                'updated_at': '2026-06-24T06:12:45.000000Z',
              },
              'has_new': true,
              'poll_seconds': 3,
            }
          },
          statusCode: 200,
        );
      }

      return Response(
        requestOptions: RequestOptions(path: path),
        data: {
          'success': true,
          'message': 'Success',
          'data': {
            'ticket': {
              'id': 12,
              'subject': 'Unable to verify driving license',
              'priority': 'High',
              'status': 1,
              'status_label': 'open',
              'can_send_message': true,
              'unread_count': 2,
              'last_message_id': 145,
              'date': '2026-06-24',
              'created_at': '2026-06-24T05:30:17.000000Z',
              'updated_at': '2026-06-24T06:12:45.000000Z',
            },
            'messages': [
              {
                'id': 145,
                'message': 'Here is the photo.',
                'file': 'https://api.jkworlds.com/uploads/60a2b3c4d5e6.png',
                'from_admin': false,
                'sender_name': 'Jane Smith',
                'sender_avatar': 'https://api.jkworlds.com/storage/profiles/user-4.jpg',
                'created_at': '24 Jun, 2026 06:12 AM',
                'created_at_iso': '2026-06-24T06:12:45.000000Z',
                'is_mine': true,
              }
            ],
            'first_id': 145,
            'last_id': 145,
            'has_more_older': false,
          }
        },
        statusCode: 200,
      );
    }

    return Response(
      requestOptions: RequestOptions(path: path),
      statusCode: 404,
    );
  }

  @override
  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    if (mockResponses.containsKey(path)) {
      return Response(
        requestOptions: RequestOptions(path: path),
        data: mockResponses[path],
        statusCode: 200,
      );
    }

    // Match read endpoint /api/support-tickets/12/read
    final readReg = RegExp(r'/api/support-tickets/\d+/read');
    if (readReg.hasMatch(path)) {
      return Response(
        requestOptions: RequestOptions(path: path),
        data: {
          'success': true,
          'message': 'Ticket marked as read.',
          'data': {
            'ticket': {
              'id': 12,
              'subject': 'Unable to verify driving license',
              'priority': 'High',
              'status': 1,
              'status_label': 'open',
              'can_send_message': true,
              'unread_count': 0,
              'last_message_id': 145,
              'date': '2026-06-24',
              'created_at': '2026-06-24T05:30:17.000000Z',
              'updated_at': '2026-06-24T06:12:45.000000Z',
            }
          }
        },
        statusCode: 200,
      );
    }

    return Response(
      requestOptions: RequestOptions(path: path),
      statusCode: 404,
    );
  }

  @override
  Future<Response> postFormData(
    String path,
    FormData formData, {
    Map<String, dynamic>? queryParameters,
  }) async {
    final regExp = RegExp(r'/api/support-tickets/\d+/messages');
    if (regExp.hasMatch(path)) {
      return Response(
        requestOptions: RequestOptions(path: path),
        data: {
          'success': true,
          'message': 'Message sent successfully.',
          'data': {
            'id': 146,
            'message': 'Test reply',
            'file': null,
            'from_admin': false,
            'sender_name': 'Jane Smith',
            'sender_avatar': null,
            'created_at': '24 Jun, 2026 06:15 AM',
            'created_at_iso': '2026-06-24T06:15:00.000000Z',
            'is_mine': true,
          }
        },
        statusCode: 200,
      );
    }

    return Response(
      requestOptions: RequestOptions(path: path),
      statusCode: 404,
    );
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('[SupportTicketModel & SupportMessageModel]', () {
    test('fromJson and toJson map correctly for SupportTicketModel', () {
      final json = {
        'id': 12,
        'subject': 'Unable to verify driving license',
        'priority': 'High',
        'status': 1,
        'status_label': 'open',
        'can_send_message': true,
        'unread_count': 2,
        'last_message_id': 145,
        'date': '2026-06-24',
        'created_at': '2026-06-24T05:30:17.000000Z',
        'updated_at': '2026-06-24T06:12:45.000000Z'
      };

      final model = SupportTicketModel.fromJson(json);
      expect(model.id, 12);
      expect(model.subject, 'Unable to verify driving license');
      expect(model.priority, 'High');
      expect(model.status, 1);
      expect(model.statusLabel, 'open');
      expect(model.canSendMessage, true);
      expect(model.unreadCount, 2);
      expect(model.lastMessageId, 145);
      expect(model.date, '2026-06-24');

      final mapped = model.toJson();
      expect(mapped['id'], 12);
      expect(mapped['priority'], 'High');
      expect(mapped['unread_count'], 2);
      expect(mapped['last_message_id'], 145);
    });

    test('fromJson and toJson map correctly for SupportMessageModel', () {
      final json = {
        'id': 145,
        'message': 'Here is the photo.',
        'file': 'https://api.jkworlds.com/uploads/60a2b3c4d5e6.png',
        'from_admin': false,
        'sender_name': 'Jane Smith',
        'sender_avatar': 'https://api.jkworlds.com/storage/profiles/user-4.jpg',
        'created_at': '24 Jun, 2026 06:12 AM',
        'created_at_iso': '2026-06-24T06:12:45.000000Z',
        'is_mine': true
      };

      final model = SupportMessageModel.fromJson(json);
      expect(model.id, 145);
      expect(model.message, 'Here is the photo.');
      expect(model.file, 'https://api.jkworlds.com/uploads/60a2b3c4d5e6.png');
      expect(model.fromAdmin, false);
      expect(model.senderName, 'Jane Smith');
      expect(model.senderAvatar, 'https://api.jkworlds.com/storage/profiles/user-4.jpg');
      expect(model.createdAt, '24 Jun, 2026 06:12 AM');
      expect(model.isMine, true);

      final mapped = model.toJson();
      expect(mapped['id'], 145);
      expect(mapped['is_mine'], true);
      expect(mapped['file'], 'https://api.jkworlds.com/uploads/60a2b3c4d5e6.png');
    });
  });

  group('[SupportTicketService & SupportTicketsController]', () {
    late MockApiProvider mockApi;
    late SupportTicketService service;
    late SupportTicketsController controller;

    final mockTicketsJson = {
      'success': true,
      'message': 'Success',
      'data': {
        'tickets': [
          {
            'id': 12,
            'subject': 'Unable to verify driving license',
            'priority': 'High',
            'status': 1,
            'status_label': 'open',
            'can_send_message': true,
            'unread_count': 2,
            'last_message_id': 145,
            'date': '2026-06-24',
            'created_at': '2026-06-24T05:30:17.000000Z',
            'updated_at': '2026-06-24T06:12:45.000000Z',
          }
        ],
        'total_unread': 2,
        'polling': {
          'inbox_interval_seconds': 12,
          'chat_light_interval_seconds': 3,
          'chat_idle_interval_seconds': 20,
          'messages_page_size': 20,
        }
      }
    };

    final mockCreateTicketJson = {
      'success': true,
      'message': 'Success',
      'data': {
        'id': 13,
        'subject': 'Test Ticket',
        'priority': 'High',
        'status': 0,
        'status_label': 'pending',
        'can_send_message': true,
        'unread_count': 0,
        'last_message_id': null,
        'date': '2026-06-24',
        'created_at': '2026-06-24T06:29:25.000000Z',
        'updated_at': '2026-06-24T06:29:25.000000Z',
      }
    };

    setUp(() async {
      Get.reset();
      Get.testMode = true;
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      Get.put<SharedPreferences>(prefs, permanent: true);

      mockApi = MockApiProvider(mockResponses: {
        '/api/support-tickets': mockTicketsJson,
        '/api/support-tickets/unread-summary': {
          'success': true,
          'message': 'Success',
          'data': {'total_unread': 2, 'tickets': {}, 'polling': {}}
        },
      });

      Get.put<ApiProvider>(mockApi);
      service = Get.put(SupportTicketService());
      controller = Get.put(SupportTicketsController());

      // Create dummy file for file attachment tests
      final file = File('mock_image.png');
      if (!await file.exists()) {
        await file.create();
      }
    });

    tearDown(() async {
      Get.reset();
      final file = File('mock_image.png');
      if (await file.exists()) {
        await file.delete();
      }
    });

    test('service fetchTickets works correctly', () async {
      final res = await service.fetchTickets();
      final list = res['tickets'] as List<SupportTicketModel>;
      expect(list.length, 1);
      expect(list[0].subject, 'Unable to verify driving license');
      expect(res['total_unread'], 2);
    });

    test('service createTicket works correctly', () async {
      mockApi.mockResponses['/api/support-tickets'] = mockCreateTicketJson;
      final ticket = await service.createTicket(
        subject: 'Test Ticket',
        message: 'Hello Support',
        priority: 'High',
      );
      expect(ticket.id, 13);
      expect(ticket.subject, 'Test Ticket');
      expect(ticket.statusLabel, 'pending');
    });

    test('controller loads list state and filters correctly', () async {
      await controller.refreshTickets();
      expect(controller.tickets.length, 1);
      expect(controller.totalUnread.value, 2);

      // Search query filtering
      controller.searchQuery.value = 'verify';
      expect(controller.filteredTickets.length, 1);

      controller.searchQuery.value = 'nonexistent';
      expect(controller.filteredTickets.length, 0);

      // Priority filtering
      controller.searchQuery.value = '';
      controller.selectedPriorityFilter.value = 'High';
      expect(controller.filteredTickets.length, 1);

      controller.selectedPriorityFilter.value = 'Low';
      expect(controller.filteredTickets.length, 0);
    });

    test('controller opens ticket and loads messages correctly', () async {
      await controller.refreshTickets();
      final ticket = controller.tickets[0];

      await controller.openTicket(ticket);
      expect(controller.activeTicket.value, isNotNull);
      expect(controller.activeTicket.value!.id, 12);
      expect(controller.messages.length, 1);
      expect(controller.messages[0].message, 'Here is the photo.');
      expect(controller.firstId.value, 145);
      expect(controller.lastId.value, 145);
    });

    test('controller sends replies correctly', () async {
      await controller.refreshTickets();
      final ticket = controller.tickets[0];

      await controller.openTicket(ticket);
      controller.messageSendCtrl.text = 'Test reply';
      
      await controller.sendMessage();
      expect(controller.messages.length, 2);
      expect(controller.messages[1].message, 'Test reply');
      expect(controller.messages[1].id, 146);
    });

    test('controller fails validation when trying to send only image attachment', () async {
      await controller.refreshTickets();
      final ticket = controller.tickets[0];

      await controller.openTicket(ticket);
      controller.messageSendCtrl.text = '';
      controller.selectedAttachmentPath.value = 'mock_image.png';

      await controller.sendMessage();
      // Length should remain 1 because it failed validation and returned early
      expect(controller.messages.length, 1);
      expect(controller.selectedAttachmentPath.value, 'mock_image.png');
    });
  });
}

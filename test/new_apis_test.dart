import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart' hide Response, FormData;
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:jkworlds/data/providers/api_provider.dart';
import 'package:jkworlds/data/services/auth_service.dart';
import 'package:jkworlds/data/services/contact_service.dart';
import 'package:jkworlds/data/services/review_service.dart';
import 'package:jkworlds/data/services/damage_report_service.dart';

class LocalMockApiProvider extends ApiProvider {
  final Map<String, dynamic> mockResponses;

  LocalMockApiProvider({required this.mockResponses});

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
    throw Exception('Unhandled mock GET path: $path');
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
    throw Exception('Unhandled mock POST path: $path');
  }

  @override
  Future<Response> postFormData(
    String path,
    dynamic formData, {
    Map<String, dynamic>? queryParameters,
  }) async {
    if (mockResponses.containsKey(path)) {
      return Response(
        requestOptions: RequestOptions(path: path),
        data: mockResponses[path],
        statusCode: 200,
      );
    }
    throw Exception('Unhandled mock POST FormData path: $path');
  }
}

void main() {
  late LocalMockApiProvider mockApi;

  setUp(() async {
    Get.testMode = true;
    SharedPreferences.setMockInitialValues({
      'auth_token': 'mock_token',
      'auth_user_name': 'Test User',
      'auth_user_email': 'test@test.com',
    });
    final prefs = await SharedPreferences.getInstance();
    Get.put<SharedPreferences>(prefs, permanent: true);

    mockApi = LocalMockApiProvider(mockResponses: {
      '/api/contact': {
        'success': true,
        'message': 'Message sent successfully'
      },
      '/api/account': {
        'success': true,
        'message': 'Account deleted successfully'
      },
      '/api/logout': {
        'success': true,
        'message': 'Logged out successfully'
      },
      '/api/refresh-token': {
        'success': true,
        'data': {
          'token': 'new_refreshed_token'
        }
      },
      '/api/ratings': {
        'success': true,
        'data': [
          {
            'id': 1,
            'vehicle_id': 4,
            'user': {
              'name': 'Rabin'
            },
            'rating': 4,
            'comment': 'Good vehicle',
            'created_at': '2026-06-27T10:16:47Z'
          }
        ]
      },
      '/api/damage-reports': {
        'success': true,
        'data': [
          {
            'id': 1,
            'booking_id': 100,
            'description': 'Scratched side panel',
            'images': ['http://image.url'],
            'status': 'pending',
            'created_at': '2026-06-27T10:16:47Z'
          }
        ]
      },
      '/api/damage-reports/1': {
        'success': true,
        'data': {
          'id': 1,
          'booking_id': 100,
          'description': 'Scratched side panel',
          'images': ['http://image.url'],
          'status': 'pending',
          'created_at': '2026-06-27T10:16:47Z'
        }
      }
    });

    Get.put<ApiProvider>(mockApi, permanent: true);
  });

  tearDown(() {
    Get.reset();
  });

  test('ContactService submitMessage makes real post call and parses success', () async {
    final service = Get.put(ContactService());
    final success = await service.submitMessage(
      name: 'John',
      phone: '123',
      email: 'john@test.com',
      subject: 'Hello',
      message: 'Body message'
    );
    expect(success, isTrue);
  });

  test('AuthService deleteAccount and refreshToken perform correct HTTP calls', () async {
    final service = Get.put(AuthService());
    service.isLoggedIn.value = true;
    
    await service.refreshToken();
    final prefs = Get.find<SharedPreferences>();
    expect(prefs.getString('auth_token'), equals('new_refreshed_token'));

    await service.deleteAccount();
    expect(service.isLoggedIn.value, isFalse);
    expect(prefs.getString('auth_token'), isNull);
  });

  test('ReviewService fetchRatings and createRating work correctly', () async {
    final service = Get.put(ReviewService());
    final ratings = await service.fetchRatings();
    
    expect(ratings, isNotEmpty);
    expect(ratings.first.userName, equals('Rabin'));
    expect(ratings.first.rating, equals(4.0));
    
    // Add mock response for createRating
    mockApi.mockResponses['/api/ratings'] = {
      'success': true,
      'data': {
        'id': 2,
        'vehicle_id': 4,
        'user': {
          'name': 'Test User'
        },
        'rating': 5,
        'comment': 'Awesome car!',
        'created_at': '2026-06-27T10:16:47Z'
      }
    };

    final newReview = await service.createRating(
      bookingId: '100',
      rating: 5.0,
      comment: 'Awesome car!'
    );
    expect(newReview.rating, equals(5.0));
    expect(newReview.comment, equals('Awesome car!'));
  });

  test('DamageReportService fetch and create workflows work correctly', () async {
    final service = Get.put(DamageReportService());
    
    final reports = await service.fetchDamageReports();
    expect(reports, isNotEmpty);
    expect(reports.first.description, equals('Scratched side panel'));

    final detail = await service.fetchDamageReportDetail(1);
    expect(detail.bookingId, equals('100'));

    // Mock create response
    mockApi.mockResponses['/api/damage-reports'] = {
      'success': true,
      'data': {
        'id': 2,
        'booking_id': 100,
        'description': 'Flat tire',
        'images': [],
        'status': 'reviewed',
        'created_at': '2026-06-27T10:16:47Z'
      }
    };

    final newReport = await service.createDamageReport(
      bookingId: '100',
      description: 'Flat tire'
    );
    expect(newReport.description, equals('Flat tire'));
    expect(newReport.status, equals('reviewed'));
  });
}

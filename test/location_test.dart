import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart' hide Response;
import 'package:dio/dio.dart';

import 'package:jkworlds/data/models/location_coverage_model.dart';
import 'package:jkworlds/data/services/location_service.dart';
import 'package:jkworlds/data/providers/api_provider.dart';

class MockApiProvider extends ApiProvider {
  final Map<String, dynamic>? mockResponseData;
  final bool failRequest;

  MockApiProvider({this.mockResponseData, this.failRequest = false});

  @override
  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    if (path == '/api/location/check-coverage') {
      if (failRequest) {
        return Response(
          requestOptions: RequestOptions(path: path),
          data: {
            'success': false,
            'message': 'Validation failed',
            'data': {'lat': ['The lat field must be between -90 and 90.']}
          },
          statusCode: 422,
        );
      }
      return Response(
        requestOptions: RequestOptions(path: path),
        data: mockResponseData,
        statusCode: 200,
      );
    }
    return super.post(path, data: data, queryParameters: queryParameters);
  }
}

void main() {
  group('[LocationCoverageModel]', () {
    test('fromJson and toJson maps correctly', () {
      final json = {
        'covered': true,
        'zone': {
          'id': 5,
          'name': 'Dubai Downtown Area',
          'type': 'city',
        }
      };

      final coverage = LocationCoverageModel.fromJson(json);
      expect(coverage.covered, true);
      expect(coverage.zoneId, 5);
      expect(coverage.zoneName, 'Dubai Downtown Area');
      expect(coverage.zoneType, 'city');

      final mapped = coverage.toJson();
      expect(mapped['covered'], true);
      expect(mapped['zone']['id'], 5);
      expect(mapped['zone']['name'], 'Dubai Downtown Area');
      expect(mapped['zone']['type'], 'city');
    });

    test('fromJson handles null zone correctly', () {
      final json = {
        'covered': true,
        'zone': null,
      };

      final coverage = LocationCoverageModel.fromJson(json);
      expect(coverage.covered, true);
      expect(coverage.zoneId, null);
      expect(coverage.zoneName, null);
      expect(coverage.zoneType, null);

      final mapped = coverage.toJson();
      expect(mapped['covered'], true);
      expect(mapped['zone'], null);
    });
  });

  group('[LocationService - checkCoverage]', () {
    setUp(() {
      Get.reset();
    });

    test('returns LocationCoverageModel on covered zone', () async {
      final mockData = {
        'status': true,
        'message': 'Location is covered.',
        'data': {
          'covered': true,
          'zone': {
            'id': 5,
            'name': 'Dubai Downtown Area',
            'type': 'city',
          }
        }
      };

      final mockApi = MockApiProvider(mockResponseData: mockData);
      Get.put<ApiProvider>(mockApi);
      final service = Get.put(LocationService());

      final result = await service.checkCoverage(
        lat: 25.1973406,
        lng: 55.2796101,
        serviceType: 'self_drive',
      );

      expect(result.covered, true);
      expect(result.zoneId, 5);
      expect(result.zoneName, 'Dubai Downtown Area');
      expect(result.zoneType, 'city');
    });

    test('returns LocationCoverageModel on outside coverage zone', () async {
      final mockData = {
        'status': true,
        'message': 'Location is outside our service area.',
        'data': {
          'covered': false,
        }
      };

      final mockApi = MockApiProvider(mockResponseData: mockData);
      Get.put<ApiProvider>(mockApi);
      final service = Get.put(LocationService());

      final result = await service.checkCoverage(
        lat: 25.1973406,
        lng: 55.2796101,
        serviceType: 'self_drive',
      );

      expect(result.covered, false);
      expect(result.zoneId, null);
    });
  });
}

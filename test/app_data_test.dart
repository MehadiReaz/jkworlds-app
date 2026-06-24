import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart' hide Response;
import 'package:dio/dio.dart';

import 'package:jkworlds/app/currency/currency_model.dart';
import 'package:jkworlds/app/currency/currency_service.dart';
import 'package:jkworlds/data/models/faq_model.dart';
import 'package:jkworlds/data/models/static_page_model.dart';
import 'package:jkworlds/data/services/app_data_service.dart';
import 'package:jkworlds/data/providers/api_provider.dart';

class MockApiProvider extends ApiProvider {
  final Map<String, dynamic> mockResponseData;

  MockApiProvider({required this.mockResponseData});

  @override
  Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) async {
    if (path == '/api/app-data') {
      return Response(
        requestOptions: RequestOptions(path: path),
        data: mockResponseData,
        statusCode: 200,
      );
    }
    return super.get(path, queryParameters: queryParameters);
  }
}

void main() {
  group('[FaqModel]', () {
    test('fromJson and toJson maps correctly', () {
      final json = {
        'id': 10,
        'question': 'How does this work?',
        'answer': 'Like magic.',
        'order': 3,
      };

      final faq = FaqModel.fromJson(json);
      expect(faq.id, 10);
      expect(faq.question, 'How does this work?');
      expect(faq.answer, 'Like magic.');
      expect(faq.order, 3);

      final mapped = faq.toJson();
      expect(mapped['id'], 10);
      expect(mapped['question'], 'How does this work?');
      expect(mapped['answer'], 'Like magic.');
      expect(mapped['order'], 3);
    });
  });

  group('[StaticPageModel]', () {
    test('fromJson and toJson maps correctly', () {
      final json = {
        'id': 5,
        'key': 'about',
        'title': 'About Us',
        'slug': 'about-us',
        'content': 'We are JKWorlds.',
        'order': 1,
      };

      final page = StaticPageModel.fromJson(json);
      expect(page.id, 5);
      expect(page.key, 'about');
      expect(page.title, 'About Us');
      expect(page.slug, 'about-us');
      expect(page.content, 'We are JKWorlds.');
      expect(page.order, 1);

      final mapped = page.toJson();
      expect(mapped['id'], 5);
      expect(mapped['key'], 'about');
      expect(mapped['title'], 'About Us');
      expect(mapped['slug'], 'about-us');
      expect(mapped['content'], 'We are JKWorlds.');
      expect(mapped['order'], 1);
    });
  });

  group('[CurrencyModel]', () {
    test('fromJson and toJson maps correctly', () {
      final json = {
        'id': 3,
        'name': 'UAE Dirham',
        'code': 'AED',
        'symbol': 'د.إ',
        'symbol_position': 'left',
        'exchange_rate': 3.67,
        'is_default': true,
      };

      final currency = CurrencyModel.fromJson(json);
      expect(currency.id, 3);
      expect(currency.name, 'UAE Dirham');
      expect(currency.code, 'AED');
      expect(currency.symbol, 'د.إ');
      expect(currency.symbolPosition, 'left');
      expect(currency.exchangeRate, 3.67);
      expect(currency.isDefault, true);

      final mapped = currency.toJson();
      expect(mapped['id'], 3);
      expect(mapped['name'], 'UAE Dirham');
      expect(mapped['code'], 'AED');
      expect(mapped['symbol'], 'د.إ');
      expect(mapped['symbol_position'], 'left');
      expect(mapped['exchange_rate'], 3.67);
      expect(mapped['is_default'], true);
    });
  });

  group('[AppDataService]', () {
    late SharedPreferences prefs;

    final mockResponse = {
      'status': true,
      'message': 'App data fetched successfully.',
      'data': {
        'currencies': [
          {
            'id': 1,
            'name': 'UAE Dirham',
            'code': 'AED',
            'symbol': 'د.إ',
            'symbol_position': 'left',
            'exchange_rate': 3.67,
            'is_default': true
          },
          {
            'id': 2,
            'name': 'US Dollar',
            'code': 'USD',
            'symbol': '\$',
            'symbol_position': 'left',
            'exchange_rate': 1.0,
            'is_default': false
          }
        ],
        'faqs': [
          {
            'id': 1,
            'question': 'What is the age requirement?',
            'answer': '21 years.',
            'order': 1
          }
        ],
        'pages': [
          {
            'id': 1,
            'key': 'about',
            'title': 'About Us',
            'slug': 'about-us',
            'content': 'We are premium mobility.',
            'order': 1
          }
        ]
      }
    };

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
      Get.put<SharedPreferences>(prefs, permanent: true);
      Get.put(CurrencyService(), permanent: true);
    });

    tearDown(() {
      Get.reset();
    });

    test('Loads empty or default values when cache is empty', () {
      final appDataService = Get.put(AppDataService());
      expect(appDataService.faqs, isEmpty);
      expect(appDataService.pages, isEmpty);
    });

    test('Loads cached data on initialization', () {
      final cachedFaqs = [
        {'id': 1, 'question': 'Q1', 'answer': 'A1', 'order': 1}
      ];
      final cachedPages = [
        {'id': 1, 'key': 'k1', 'title': 'T1', 'slug': 's1', 'content': 'C1', 'order': 1}
      ];
      prefs.setString('cached_app_data_faqs', jsonEncode(cachedFaqs));
      prefs.setString('cached_app_data_pages', jsonEncode(cachedPages));

      final appDataService = Get.put(AppDataService());
      expect(appDataService.faqs, hasLength(1));
      expect(appDataService.faqs.first.question, 'Q1');
      expect(appDataService.pages, hasLength(1));
      expect(appDataService.pages.first.key, 'k1');
    });

    test('fetchAppData fetches, updates currency service, and updates cache', () async {
      final mockApi = MockApiProvider(mockResponseData: mockResponse);
      Get.put<ApiProvider>(mockApi);

      final appDataService = Get.put(AppDataService());
      final currencyService = Get.find<CurrencyService>();

      await appDataService.fetchAppData();

      // Verify FAQs and Pages parsed
      expect(appDataService.faqs, hasLength(1));
      expect(appDataService.faqs.first.question, 'What is the age requirement?');
      expect(appDataService.pages, hasLength(1));
      expect(appDataService.pages.first.key, 'about');

      // Verify CurrencyService updated
      expect(currencyService.currencies, hasLength(2));
      expect(currencyService.currencies.first.code, 'AED');
      expect(currencyService.selectedCurrency.value.code, 'AED');

      // Verify Cache updated in SharedPreferences
      expect(prefs.getString('cached_app_data_faqs'), isNotNull);
      expect(prefs.getString('cached_app_data_pages'), isNotNull);
      expect(prefs.getString('cached_supported_currencies'), isNotNull);
    });
  });
}

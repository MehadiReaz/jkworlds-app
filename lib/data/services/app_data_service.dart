import 'dart:convert';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jkworlds/core/constants/api_constants.dart';
import 'package:jkworlds/core/errors/app_exception.dart';
import 'package:jkworlds/core/utils/logger.dart';
import 'package:jkworlds/data/providers/api_provider.dart';
import 'package:jkworlds/app/currency/currency_service.dart';
import 'package:jkworlds/app/currency/currency_model.dart';
import 'package:jkworlds/data/models/faq_model.dart';
import 'package:jkworlds/data/models/static_page_model.dart';
import 'package:jkworlds/data/models/slider_model.dart';
import 'package:jkworlds/data/models/contact_us_model.dart';

class AppDataService extends GetxService {
  ApiProvider get _api => Get.find<ApiProvider>();
  CurrencyService get _currencyService => Get.find<CurrencyService>();

  static const _faqsCacheKey = 'cached_app_data_faqs';
  static const _pagesCacheKey = 'cached_app_data_pages';
  static const _slidersCacheKey = 'cached_app_data_sliders';
  static const _contactUsCacheKey = 'cached_app_data_contact_us';

  final faqs = <FaqModel>[].obs;
  final pages = <StaticPageModel>[].obs;
  final sliders = <SliderModel>[].obs;
  final contactUs = Rxn<ContactUsModel>();
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadCachedData();
  }

  void _loadCachedData() {
    final prefs = Get.find<SharedPreferences>();
    
    // Load FAQs
    final cachedFaqs = prefs.getString(_faqsCacheKey);
    if (cachedFaqs != null) {
      try {
        final List<dynamic> decoded = jsonDecode(cachedFaqs) as List<dynamic>;
        faqs.assignAll(decoded.map((e) => FaqModel.fromJson(e as Map<String, dynamic>)).toList());
      } catch (e) {
        logger.e('[AppDataService] Error loading cached FAQs: $e');
      }
    }

    // Load Pages
    final cachedPages = prefs.getString(_pagesCacheKey);
    if (cachedPages != null) {
      try {
        final List<dynamic> decoded = jsonDecode(cachedPages) as List<dynamic>;
        pages.assignAll(decoded.map((e) => StaticPageModel.fromJson(e as Map<String, dynamic>)).toList());
      } catch (e) {
        logger.e('[AppDataService] Error loading cached Pages: $e');
      }
    }

    // Load Sliders
    final cachedSliders = prefs.getString(_slidersCacheKey);
    if (cachedSliders != null) {
      try {
        final List<dynamic> decoded = jsonDecode(cachedSliders) as List<dynamic>;
        sliders.assignAll(decoded.map((e) => SliderModel.fromJson(e as Map<String, dynamic>)).toList());
      } catch (e) {
        logger.e('[AppDataService] Error loading cached Sliders: $e');
      }
    }

    // Load Contact Us
    final cachedContactUs = prefs.getString(_contactUsCacheKey);
    if (cachedContactUs != null) {
      try {
        final Map<String, dynamic> decoded = jsonDecode(cachedContactUs) as Map<String, dynamic>;
        contactUs.value = ContactUsModel.fromJson(decoded);
      } catch (e) {
        logger.e('[AppDataService] Error loading cached Contact Us: $e');
      }
    }
  }

  /// Fetches application configuration data (currencies, FAQs, static pages) from `/api/app-data`.
  Future<void> fetchAppData() async {
    isLoading.value = true;
    try {
      final response = await _api.get(ApiConstants.appData);
      final body = response.data;
      if (body == null || body is! Map<String, dynamic>) {
        throw const ServerException('Empty or invalid app data response');
      }

      final data = body['data'] as Map<String, dynamic>?;
      if (data == null) {
        throw const ServerException('App data response missing "data" key');
      }

      final prefs = Get.find<SharedPreferences>();

      // Parse Currencies
      final currenciesRaw = data['currencies'];
      if (currenciesRaw is List) {
        final currenciesList = currenciesRaw
            .whereType<Map<String, dynamic>>()
            .map(CurrencyModel.fromJson)
            .toList();
        _currencyService.updateCurrencies(currenciesList);
      }

      // Parse FAQs
      final faqsRaw = data['faqs'];
      if (faqsRaw is List) {
        final faqsList = faqsRaw
            .whereType<Map<String, dynamic>>()
            .map(FaqModel.fromJson)
            .toList();
        faqs.assignAll(faqsList);
        prefs.setString(_faqsCacheKey, jsonEncode(faqsList.map((e) => e.toJson()).toList()));
      }

      // Parse Pages
      final pagesRaw = data['pages'];
      if (pagesRaw is List) {
        final pagesList = pagesRaw
            .whereType<Map<String, dynamic>>()
            .map(StaticPageModel.fromJson)
            .toList();
        pages.assignAll(pagesList);
        prefs.setString(_pagesCacheKey, jsonEncode(pagesList.map((e) => e.toJson()).toList()));
      }

      // Parse Sliders
      final slidersRaw = data['sliders'];
      if (slidersRaw is List) {
        final slidersList = slidersRaw
            .whereType<Map<String, dynamic>>()
            .map(SliderModel.fromJson)
            .toList();
        sliders.assignAll(slidersList);
        prefs.setString(_slidersCacheKey, jsonEncode(slidersList.map((e) => e.toJson()).toList()));
      }

      // Parse Contact Us
      final contactUsRaw = data['contact_us'];
      if (contactUsRaw is Map<String, dynamic>) {
        final contactModel = ContactUsModel.fromJson(contactUsRaw);
        contactUs.value = contactModel;
        prefs.setString(_contactUsCacheKey, jsonEncode(contactModel.toJson()));
      }

      logger.i('[AppDataService] App data successfully loaded and cached');
    } on AppException {
      rethrow;
    } catch (e, st) {
      logger.e('[AppDataService] fetchAppData unexpected error', error: e, stackTrace: st);
      throw UnknownException(e.toString());
    } finally {
      isLoading.value = false;
    }
  }
}

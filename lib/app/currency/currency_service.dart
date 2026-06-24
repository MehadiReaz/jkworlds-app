import 'dart:convert';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jkworlds/core/utils/logger.dart';

import 'currency_model.dart';

/// Global currency service — persists selection and formats prices.
/// Base currency is NGN (Nigerian Naira) or USD (depends on config).
class CurrencyService extends GetxService {
  static const _storageKey = 'selected_currency';
  static const _currenciesCacheKey = 'cached_supported_currencies';

  // ── Supported Currencies ────────────────────────────────────────
  // Fallback default list
  static const List<CurrencyModel> _defaultCurrencies = [
    CurrencyModel(code: 'NGN', symbol: '₦', name: 'Nigerian Naira', exchangeRate: 1.0, isDefault: true),
    CurrencyModel(code: 'USD', symbol: '\$', name: 'US Dollar', exchangeRate: 0.000625),  // 1 USD ≈ 1,600 NGN
    CurrencyModel(code: 'GBP', symbol: '£', name: 'British Pound', exchangeRate: 0.0005),     // 1 GBP ≈ 2,000 NGN
    CurrencyModel(code: 'EUR', symbol: '€', name: 'Euro', exchangeRate: 0.000571),   // 1 EUR ≈ 1,750 NGN
  ];

  final RxList<CurrencyModel> currencies = <CurrencyModel>[].obs;
  late final Rx<CurrencyModel> selectedCurrency;

  @override
  void onInit() {
    super.onInit();
    _loadInitialCurrencies();
  }

  void _loadInitialCurrencies() {
    final prefs = Get.find<SharedPreferences>();
    final cachedJson = prefs.getString(_currenciesCacheKey);
    if (cachedJson != null) {
      try {
        final List<dynamic> decoded = jsonDecode(cachedJson) as List<dynamic>;
        final list = decoded
            .map((e) => CurrencyModel.fromJson(e as Map<String, dynamic>))
            .toList();
        if (list.isNotEmpty) {
          currencies.assignAll(list);
        }
      } catch (e) {
        logger.e('[CurrencyService] Error loading cached currencies: $e');
      }
    }

    if (currencies.isEmpty) {
      currencies.assignAll(_defaultCurrencies);
    }

    final savedCode = prefs.getString(_storageKey);
    final fallback = currencies.firstWhere((c) => c.isDefault, orElse: () => currencies.first);
    selectedCurrency = _findByCode(savedCode ?? fallback.code).obs;
  }

  /// Change the active currency and persist the choice.
  void changeCurrency(String code) {
    selectedCurrency.value = _findByCode(code);
    Get.find<SharedPreferences>().setString(_storageKey, code);
  }

  /// Update the supported currencies list dynamically.
  void updateCurrencies(List<CurrencyModel> newCurrencies) {
    if (newCurrencies.isEmpty) return;
    currencies.assignAll(newCurrencies);
    
    final prefs = Get.find<SharedPreferences>();
    final jsonStr = jsonEncode(newCurrencies.map((c) => c.toJson()).toList());
    prefs.setString(_currenciesCacheKey, jsonStr);

    // Refresh selected currency in case current selection is no longer valid
    final savedCode = prefs.getString(_storageKey);
    final fallback = currencies.firstWhere((c) => c.isDefault, orElse: () => currencies.first);
    selectedCurrency.value = _findByCode(savedCode ?? fallback.code);
  }

  /// Format [amountInNgn] into the selected currency string.
  /// e.g. `₦150,000.00`, `$93.75`
  String formatPrice(double amountInNgn) {
    final cur = selectedCurrency.value;
    
    // Find base currency (rate == 1.0)
    final baseCurrency = currencies.firstWhere(
      (c) => c.exchangeRate == 1.0,
      orElse: () => currencies.first,
    );

    double converted;
    if (baseCurrency.code.toUpperCase() == 'USD') {
      // Backend prices are in USD, which were scaled up to NGN by 1600.0 in parsing
      final priceInUsd = amountInNgn / 1600.0;
      converted = priceInUsd * cur.exchangeRate;
    } else {
      // Default to NGN as base
      converted = amountInNgn * cur.exchangeRate;
    }

    final digits = cur.code.toUpperCase() == 'NGN' ? 0 : 2;

    if (cur.symbolPosition == 'right') {
      final numberFormatter = NumberFormat.decimalPattern();
      numberFormatter.minimumFractionDigits = digits;
      numberFormatter.maximumFractionDigits = digits;
      final formattedNum = numberFormatter.format(converted);
      return '$formattedNum ${cur.symbol}';
    } else {
      final formatter = NumberFormat.currency(
        symbol: cur.symbol,
        decimalDigits: digits,
      );
      return formatter.format(converted);
    }
  }

  CurrencyModel _findByCode(String code) {
    return currencies.firstWhere(
      (c) => c.code == code,
      orElse: () => currencies.first,
    );
  }
}

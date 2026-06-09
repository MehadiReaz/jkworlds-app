import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'currency_model.dart';

/// Global currency service — persists selection and formats prices.
/// Base currency is NGN (Nigerian Naira).
class CurrencyService extends GetxService {
  static const _storageKey = 'selected_currency';

  // ── Supported Currencies ────────────────────────────────────────
  // Exchange rates: amount_in_NGN * rate = amount_in_target_currency
  final List<CurrencyModel> currencies = const [
    CurrencyModel(code: 'NGN', symbol: '₦', name: 'Nigerian Naira',   exchangeRate: 1.0),
    CurrencyModel(code: 'USD', symbol: '\$', name: 'US Dollar',        exchangeRate: 0.000625),  // 1 USD ≈ 1,600 NGN
    CurrencyModel(code: 'GBP', symbol: '£', name: 'British Pound',    exchangeRate: 0.0005),     // 1 GBP ≈ 2,000 NGN
    CurrencyModel(code: 'EUR', symbol: '€', name: 'Euro',             exchangeRate: 0.000571),   // 1 EUR ≈ 1,750 NGN
  ];

  late final Rx<CurrencyModel> selectedCurrency;

  @override
  void onInit() {
    super.onInit();
    final prefs = Get.find<SharedPreferences>();
    final savedCode = prefs.getString(_storageKey);
    selectedCurrency = _findByCode(savedCode ?? 'NGN').obs;
  }

  /// Change the active currency and persist the choice.
  void changeCurrency(String code) {
    selectedCurrency.value = _findByCode(code);
    Get.find<SharedPreferences>().setString(_storageKey, code);
  }

  /// Format [amountInNgn] into the selected currency string.
  /// e.g. `₦150,000.00`, `$93.75`
  String formatPrice(double amountInNgn) {
    final cur = selectedCurrency.value;
    final converted = amountInNgn * cur.exchangeRate;
    final formatter = NumberFormat.currency(
      symbol: cur.symbol,
      decimalDigits: cur.code == 'NGN' ? 0 : 2,
    );
    return formatter.format(converted);
  }

  CurrencyModel _findByCode(String code) {
    return currencies.firstWhere(
      (c) => c.code == code,
      orElse: () => currencies.first,
    );
  }
}

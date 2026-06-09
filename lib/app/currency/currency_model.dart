/// Represents a supported currency in the app.
class CurrencyModel {
  final String code;   // e.g. "USD"
  final String symbol; // e.g. "$"
  final String name;   // e.g. "US Dollar"
  final double exchangeRate; // rate relative to base currency (USD = 1.0)

  const CurrencyModel({
    required this.code,
    required this.symbol,
    required this.name,
    required this.exchangeRate,
  });
}

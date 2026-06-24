/// Represents a supported currency in the app.
class CurrencyModel {
  final int? id;
  final String code;   // e.g. "USD"
  final String symbol; // e.g. "$"
  final String name;   // e.g. "US Dollar"
  final String symbolPosition; // "left" or "right"
  final double exchangeRate; // rate relative to base currency (USD = 1.0)
  final bool isDefault;

  const CurrencyModel({
    this.id,
    required this.code,
    required this.symbol,
    required this.name,
    this.symbolPosition = 'left',
    required this.exchangeRate,
    this.isDefault = false,
  });

  factory CurrencyModel.fromJson(Map<String, dynamic> json) {
    return CurrencyModel(
      id: json['id'] as int?,
      code: json['code'] as String? ?? 'USD',
      symbol: json['symbol'] as String? ?? '\$',
      name: json['name'] as String? ?? 'US Dollar',
      symbolPosition: json['symbol_position'] as String? ?? 'left',
      exchangeRate: (json['exchange_rate'] as num?)?.toDouble() ?? 1.0,
      isDefault: json['is_default'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'code': code,
      'symbol': symbol,
      'name': name,
      'symbol_position': symbolPosition,
      'exchange_rate': exchangeRate,
      'is_default': isDefault,
    };
  }
}

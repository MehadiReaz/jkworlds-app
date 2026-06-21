/// Model representing a rental addon (e.g. GPS, prepaid fuel, child seat).
class RentalAddonModel {
  final int id;
  final String title;
  final String description;
  final String priceType; // fixed, percentage
  final double? priceValue;
  final String? priceValueFormatted;
  final String priceLabel;
  final bool isCheckbox;

  const RentalAddonModel({
    required this.id,
    required this.title,
    required this.description,
    required this.priceType,
    this.priceValue,
    this.priceValueFormatted,
    required this.priceLabel,
    this.isCheckbox = true,
  });

  factory RentalAddonModel.fromJson(Map<String, dynamic> json) {
    double? parseDouble(dynamic v) {
      if (v == null) return null;
      if (v is double) return v;
      if (v is int) return v.toDouble();
      return double.tryParse(v.toString());
    }

    return RentalAddonModel(
      id: json['id'] is int ? json['id'] as int : int.tryParse(json['id'].toString()) ?? 0,
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      priceType: json['price_type'] as String? ?? 'fixed',
      priceValue: parseDouble(json['price_value']),
      priceValueFormatted: json['price_value_formatted'] as String?,
      priceLabel: json['price_label'] as String? ?? '',
      isCheckbox: json['is_checkbox'] is bool ? json['is_checkbox'] as bool : true,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'price_type': priceType,
        'price_value': priceValue,
        'price_value_formatted': priceValueFormatted,
        'price_label': priceLabel,
        'is_checkbox': isCheckbox,
      };
}

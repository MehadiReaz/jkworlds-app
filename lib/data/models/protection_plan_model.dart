/// Model representing a vehicle protection plan.
class ProtectionPlanModel {
  final int id;
  final String title;
  final String description;
  final String priceType; // fixed, percentage, none
  final double? priceValue;
  final String? priceValueFormatted;
  final String priceLabel;

  const ProtectionPlanModel({
    required this.id,
    required this.title,
    required this.description,
    required this.priceType,
    this.priceValue,
    this.priceValueFormatted,
    required this.priceLabel,
  });

  factory ProtectionPlanModel.fromJson(Map<String, dynamic> json) {
    double? parseDouble(dynamic v) {
      if (v == null) return null;
      if (v is double) return v;
      if (v is int) return v.toDouble();
      return double.tryParse(v.toString());
    }

    return ProtectionPlanModel(
      id: json['id'] is int ? json['id'] as int : int.tryParse(json['id'].toString()) ?? 0,
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      priceType: json['price_type'] as String? ?? 'none',
      priceValue: parseDouble(json['price_value']),
      priceValueFormatted: json['price_value_formatted'] as String?,
      priceLabel: json['price_label'] as String? ?? '',
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
      };
}

/// Model representing unavailable date ranges for vehicle rental.
class UnavailableDateModel {
  final String from;
  final String to;
  final String label;

  const UnavailableDateModel({
    required this.from,
    required this.to,
    required this.label,
  });

  factory UnavailableDateModel.fromJson(Map<String, dynamic> json) {
    return UnavailableDateModel(
      from: json['from'] as String? ?? '',
      to: json['to'] as String? ?? '',
      label: json['label'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'from': from,
        'to': to,
        'label': label,
      };
}

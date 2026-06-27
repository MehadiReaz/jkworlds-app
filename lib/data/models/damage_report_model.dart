/// Model representing a damage report associated with a vehicle booking.
class DamageReportModel {
  final String id;
  final String bookingId;
  final String description;
  final List<String> images;
  final String status;
  final DateTime createdAt;

  const DamageReportModel({
    required this.id,
    required this.bookingId,
    required this.description,
    required this.images,
    required this.status,
    required this.createdAt,
  });

  factory DamageReportModel.fromJson(Map<String, dynamic> json) {
    List<String> parseImages(dynamic v) {
      if (v == null) return [];
      if (v is List) return v.map((e) => e.toString()).toList();
      if (v is String && v.isNotEmpty) return [v];
      return [];
    }

    return DamageReportModel(
      id: (json['id'] ?? '').toString(),
      bookingId: (json['booking_id'] ?? '').toString(),
      description: json['description'] as String? ?? json['comment'] as String? ?? '',
      images: parseImages(json['images'] ?? json['gallery'] ?? json['image']),
      status: json['status'] as String? ?? 'pending',
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'booking_id': bookingId,
        'description': description,
        'images': images,
        'status': status,
        'created_at': createdAt.toIso8601String(),
      };
}

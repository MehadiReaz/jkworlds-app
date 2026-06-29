/// Model representing a damage report associated with a vehicle booking.
class DamageReportModel {
  final String id;
  final String? reportNumber;
  final String bookingId;
  final String? bookingCode;
  final String? vehicleId;
  final String? vehicleTitle;
  final String? vehiclePlateNumber;
  final String title;
  final String description;
  final String severity;
  final String status;
  final String? statusLabel;
  final List<String> images;
  final String? adminNote;
  final DateTime? reportedAt;
  final DateTime? reviewedAt;
  final DateTime createdAt;

  const DamageReportModel({
    required this.id,
    this.reportNumber,
    required this.bookingId,
    this.bookingCode,
    this.vehicleId,
    this.vehicleTitle,
    this.vehiclePlateNumber,
    required this.title,
    required this.description,
    required this.severity,
    required this.status,
    this.statusLabel,
    required this.images,
    this.adminNote,
    this.reportedAt,
    this.reviewedAt,
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
      reportNumber: json['report_number']?.toString(),
      bookingId: (json['booking_id'] ?? '').toString(),
      bookingCode: json['booking_code']?.toString(),
      vehicleId: json['vehicle_id']?.toString(),
      vehicleTitle: json['vehicle_title']?.toString(),
      vehiclePlateNumber: json['vehicle_plate_number']?.toString(),
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? json['comment'] as String? ?? '',
      severity: json['severity'] as String? ?? 'minor',
      status: json['status'] as String? ?? 'pending',
      statusLabel: json['status_label'] as String?,
      images: parseImages(json['images'] ?? json['gallery'] ?? json['image']),
      adminNote: json['admin_note'] as String?,
      reportedAt: DateTime.tryParse(json['reported_at']?.toString() ?? ''),
      reviewedAt: DateTime.tryParse(json['reviewed_at']?.toString() ?? ''),
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'report_number': reportNumber,
        'booking_id': bookingId,
        'booking_code': bookingCode,
        'vehicle_id': vehicleId,
        'vehicle_title': vehicleTitle,
        'vehicle_plate_number': vehiclePlateNumber,
        'title': title,
        'description': description,
        'severity': severity,
        'status': status,
        'status_label': statusLabel,
        'images': images,
        'admin_note': adminNote,
        'reported_at': reportedAt?.toIso8601String(),
        'reviewed_at': reviewedAt?.toIso8601String(),
        'created_at': createdAt.toIso8601String(),
      };
}

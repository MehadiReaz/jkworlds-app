/// Review data model for vehicle ratings.
class ReviewModel {
  final String id;
  final String vehicleId;
  final String userName;
  final double rating;
  final String comment;
  final DateTime date;

  const ReviewModel({
    required this.id,
    required this.vehicleId,
    required this.userName,
    required this.rating,
    required this.comment,
    required this.date,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    double parseDouble(dynamic v) {
      if (v == null) return 0.0;
      if (v is double) return v;
      if (v is int) return v.toDouble();
      return double.tryParse(v.toString()) ?? 0.0;
    }

    // The API may nest user info under a 'user' key
    final userMap = json['user'] is Map<String, dynamic>
        ? json['user'] as Map<String, dynamic>
        : null;
    final userName = userMap?['name'] as String?
        ?? json['user_name'] as String?
        ?? json['userName'] as String?
        ?? 'Anonymous';

    return ReviewModel(
      id: (json['id'] ?? '').toString(),
      vehicleId: (json['vehicle_id'] ?? '').toString(),
      userName: userName,
      rating: parseDouble(json['rating'] ?? json['stars']),
      comment: json['comment'] as String?
          ?? json['review'] as String?
          ?? json['body'] as String?
          ?? '',
      date: DateTime.tryParse(json['created_at']?.toString() ?? '') ??
          DateTime.tryParse(json['date']?.toString() ?? '') ??
          DateTime.now(),
    );
  }
}

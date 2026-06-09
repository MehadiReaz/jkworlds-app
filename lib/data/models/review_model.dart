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
}

import 'vehicle_model.dart';

/// Booking status enum.
enum BookingStatus { upcoming, active, past, cancelled }

/// Rental type enum.
enum RentalType { selfDrive, chauffeur }

/// Booking data model.
class BookingModel {
  final String id;
  final VehicleModel vehicle;
  final DateTime pickupDate;
  final DateTime returnDate;
  final String pickupLocation;
  final BookingStatus status;
  final RentalType rentalType;
  final double subtotal;
  final double serviceFee;
  final double securityDeposit;
  final double totalPrice;
  final DateTime createdAt;

  const BookingModel({
    required this.id,
    required this.vehicle,
    required this.pickupDate,
    required this.returnDate,
    required this.pickupLocation,
    required this.status,
    required this.rentalType,
    required this.subtotal,
    required this.serviceFee,
    required this.securityDeposit,
    required this.totalPrice,
    required this.createdAt,
  });

  int get totalDays => returnDate.difference(pickupDate).inDays;
}

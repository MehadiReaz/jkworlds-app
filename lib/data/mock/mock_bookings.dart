import 'package:jkworlds/data/models/booking_model.dart';
import 'package:jkworlds/data/mock/mock_vehicles.dart';

/// Mock bookings in various states matching the user's screenshot.
final List<BookingModel> mockBookings = [
  BookingModel(
    id: 'BK-1001',
    vehicle: mockVehicles[0], // Toyota Land Cruiser V8
    pickupDate: DateTime(2026, 6, 1),
    returnDate: DateTime(2026, 6, 7),
    pickupLocation: 'Victoria Island, Lagos',
    status: BookingStatus.active,
    rentalType: RentalType.chauffeur,
    subtotal: 450000,
    serviceFee: 22500,
    securityDeposit: 100000,
    totalPrice: 480000,
    createdAt: DateTime(2026, 5, 28),
  ),
  BookingModel(
    id: 'BK-1002',
    vehicle: mockVehicles[1], // Mercedes-Benz E-Class
    pickupDate: DateTime(2026, 6, 15),
    returnDate: DateTime(2026, 6, 18),
    pickupLocation: 'Lekki, Lagos',
    status: BookingStatus.upcoming,
    rentalType: RentalType.selfDrive,
    subtotal: 135000,
    serviceFee: 6750,
    securityDeposit: 50000,
    totalPrice: 195000,
    createdAt: DateTime(2026, 6, 10),
  ),
  BookingModel(
    id: 'BK-1003',
    vehicle: mockVehicles[7], // BMW 5 Series
    pickupDate: DateTime(2026, 5, 10),
    returnDate: DateTime(2026, 5, 12),
    pickupLocation: 'Ikoyi, Lagos',
    status: BookingStatus.past,
    rentalType: RentalType.chauffeur,
    subtotal: 480000,
    serviceFee: 24000,
    securityDeposit: 100000,
    totalPrice: 110000,
    createdAt: DateTime(2026, 5, 8),
  ),
];

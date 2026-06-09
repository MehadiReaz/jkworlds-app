/// Vehicle data model for car rental listings.
class VehicleModel {
  final String id;
  final String name;
  final String brand;
  final String type; // Sedan, SUV, Luxury, Van
  final int year;
  final String transmission; // Automatic, Manual
  final int seats;
  final String fuelType; // Petrol, Diesel, Hybrid, Electric
  final double pricePerDay; // in NGN
  final double pricePerWeek;
  final double pricePerMonth;
  final List<String> images;
  final List<String> features;
  final double rating;
  final int reviewCount;
  final bool isAvailable;
  final bool isFeatured;
  final bool hasChauffeur;
  final String location;
  final String description;

  const VehicleModel({
    required this.id,
    required this.name,
    required this.brand,
    required this.type,
    required this.year,
    required this.transmission,
    required this.seats,
    required this.fuelType,
    required this.pricePerDay,
    required this.pricePerWeek,
    required this.pricePerMonth,
    required this.images,
    required this.features,
    required this.rating,
    required this.reviewCount,
    this.isAvailable = true,
    this.isFeatured = false,
    this.hasChauffeur = false,
    required this.location,
    required this.description,
  });
}

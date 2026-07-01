import 'package:flutter/material.dart';

class AppConstants {
  static const Map<String, List<TimeOfDay>> bookingTimeSlots = {
    'Early Morning': [
      TimeOfDay(hour: 6, minute: 0),
      TimeOfDay(hour: 6, minute: 30),
      TimeOfDay(hour: 7, minute: 0),
      TimeOfDay(hour: 7, minute: 30),
    ],
    'Morning - Afternoon': [
      TimeOfDay(hour: 8, minute: 0),
      TimeOfDay(hour: 8, minute: 30),
      TimeOfDay(hour: 9, minute: 0),
      TimeOfDay(hour: 9, minute: 30),
      TimeOfDay(hour: 10, minute: 0),
      TimeOfDay(hour: 10, minute: 30),
      TimeOfDay(hour: 11, minute: 0),
      TimeOfDay(hour: 11, minute: 30),
      TimeOfDay(hour: 12, minute: 0),
      TimeOfDay(hour: 12, minute: 30),
      TimeOfDay(hour: 13, minute: 0),
      TimeOfDay(hour: 13, minute: 30),
      TimeOfDay(hour: 14, minute: 0),
      TimeOfDay(hour: 14, minute: 30),
      TimeOfDay(hour: 15, minute: 0),
      TimeOfDay(hour: 15, minute: 30),
      TimeOfDay(hour: 16, minute: 0),
      TimeOfDay(hour: 16, minute: 30),
    ],
    'Evening - Night': [
      TimeOfDay(hour: 17, minute: 0),
      TimeOfDay(hour: 17, minute: 30),
      TimeOfDay(hour: 18, minute: 0),
      TimeOfDay(hour: 18, minute: 30),
      TimeOfDay(hour: 19, minute: 0),
      TimeOfDay(hour: 19, minute: 30),
      TimeOfDay(hour: 20, minute: 0),
      TimeOfDay(hour: 20, minute: 30),
      TimeOfDay(hour: 21, minute: 0),
      TimeOfDay(hour: 21, minute: 30),
      TimeOfDay(hour: 22, minute: 0),
      TimeOfDay(hour: 22, minute: 30),
      TimeOfDay(hour: 23, minute: 0),
      TimeOfDay(hour: 23, minute: 30),
      TimeOfDay(hour: 0, minute: 0),
    ],
  };
}

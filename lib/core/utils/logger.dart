import 'package:logger/logger.dart';

/// Global logger instance for consistent log styling and levels.
final logger = Logger(
  printer: PrettyPrinter(
    methodCount: 1, // Minimal logs by default
    errorMethodCount: 8, // Detailed stack trace for errors
    lineLength: 80,
    colors: true,
    printEmojis: true,
    dateTimeFormat: DateTimeFormat.none,
  ),
);

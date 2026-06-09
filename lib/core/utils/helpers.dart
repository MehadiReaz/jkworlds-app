/// Shared utility helpers for the app.
class Helpers {
  Helpers._();

  /// Truncate a string to [maxLength] with an ellipsis.
  static String truncate(String text, {int maxLength = 50}) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}…';
  }
}

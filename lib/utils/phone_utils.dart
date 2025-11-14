/// Utilities for normalizing phone numbers to E.164 (default: Indonesia)
class PhoneUtils {
  /// Normalize to E.164 for Indonesia (+62)
  /// Examples:
  ///  - "0812 3456-789" -> "+628123456789"
  ///  - "+62 812-3456-789" -> "+628123456789"
  ///  - "628123456789" -> "+628123456789"
  static String normalizeID(String input) {
    var cleaned = input.replaceAll(RegExp(r"[^0-9+]"), "");

    if (cleaned.startsWith('+')) {
      // Assume already E.164; ensure no spaces/dashes
      return cleaned.replaceAll(' ', '').replaceAll('-', '');
    }
    if (cleaned.startsWith('62')) {
      return '+$cleaned';
    }
    if (cleaned.startsWith('0')) {
      return '+62${cleaned.substring(1)}';
    }
    // Fallback: if it's just digits, assume it's already with country code missing
    // Try to treat as local number and prefix +62
    if (RegExp(r'^\d{6,}$').hasMatch(cleaned)) {
      return '+62$cleaned';
    }
    return input; // return as-is when uncertain
  }
}

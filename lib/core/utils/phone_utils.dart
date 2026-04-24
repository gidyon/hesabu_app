class PhoneUtils {
  static String formatMsisdn(String input) {
    String formatted = input.trim().replaceAll(' ', '');
    if (formatted.startsWith('+')) {
      formatted = formatted.substring(1);
    }
    if (formatted.startsWith('07')) {
      formatted = '2547${formatted.substring(2)}';
    } else if (formatted.startsWith('01')) {
      formatted = '2541${formatted.substring(2)}';
    }
    return formatted;
  }

  static bool isValidMsisdn(String input) {
    final formatted = formatMsisdn(input);
    // Basic validation: must be 12 digits (254...) or similar
    return RegExp(r'^\d{12}$').hasMatch(formatted);
  }
}

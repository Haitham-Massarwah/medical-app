import 'package:flutter/services.dart';

/// Card validation utilities
class CardValidators {
  /// Validate card number using Luhn algorithm
  static bool validateLuhn(String cardNumber) {
    final cleaned = cardNumber.replaceAll(RegExp(r'[^\d]'), '');
    if (cleaned.length < 13 || cleaned.length > 19) return false;

    int sum = 0;
    bool alternate = false;

    for (int i = cleaned.length - 1; i >= 0; i--) {
      int digit = int.parse(cleaned[i]);

      if (alternate) {
        digit *= 2;
        if (digit > 9) {
          digit = (digit % 10) + 1;
        }
      }

      sum += digit;
      alternate = !alternate;
    }

    return (sum % 10) == 0;
  }

  /// Extract BIN (first 6-8 digits)
  static String extractBIN(String cardNumber) {
    final cleaned = cardNumber.replaceAll(RegExp(r'[^\d]'), '');
    if (cleaned.length < 6) return '';
    return cleaned.substring(0, cleaned.length >= 8 ? 8 : 6);
  }

  /// Validate card type (Visa/MasterCard)
  static String? getCardType(String cardNumber) {
    final cleaned = cardNumber.replaceAll(RegExp(r'[^\d]'), '');
    if (cleaned.startsWith('4')) return 'Visa';
    if (cleaned.startsWith('5') &&
        int.parse(cleaned[1]) >= 1 &&
        int.parse(cleaned[1]) <= 5) {
      return 'MasterCard';
    }
    if (cleaned.startsWith('2') &&
        int.parse(cleaned[1]) >= 2 &&
        int.parse(cleaned[1]) <= 7) {
      return 'MasterCard';
    }
    return null;
  }

  /// Validate expiry date format MM/YY
  static bool validateExpiryFormat(String expiry) {
    return RegExp(r'^\d{2}/\d{2}$').hasMatch(expiry);
  }

  /// Validate expiry date is not expired
  static bool validateExpiryNotExpired(String expiry) {
    if (!validateExpiryFormat(expiry)) return false;
    final parts = expiry.split('/');
    try {
      final month = int.parse(parts[0]);
      final year = int.parse(parts[1]) + 2000;
      if (month < 1 || month > 12) return false;
      final expiryDate = DateTime(year, month);
      return expiryDate.isAfter(DateTime.now());
    } catch (e) {
      return false;
    }
  }

  /// Validate CVV (3 digits)
  static bool validateCVV(String cvv) {
    return RegExp(r'^\d{3}$').hasMatch(cvv);
  }

  /// Validate Israeli ID (9 digits, Luhn algorithm)
  static bool validateIsraeliID(String id) {
    final cleaned = id.replaceAll(RegExp(r'[^\d]'), '');
    if (cleaned.length != 9) return false;

    int sum = 0;
    bool isEven = false;

    for (int i = cleaned.length - 1; i >= 0; i--) {
      int digit = int.parse(cleaned[i]);

      if (isEven) {
        digit *= 2;
        if (digit > 9) {
          digit = digit ~/ 10 + digit % 10;
        }
      }

      sum += digit;
      isEven = !isEven;
    }

    return sum % 10 == 0;
  }
}

/// Input formatter for card number (numbers only, auto-format with spaces)
class CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll(RegExp(r'[^\d]'), '');

    final limitedText = text.length > 19 ? text.substring(0, 19) : text;

    String formatted = '';
    for (int i = 0; i < limitedText.length; i++) {
      if (i > 0 && i % 4 == 0) {
        formatted += ' ';
      }
      formatted += limitedText[i];
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

/// Input formatter for expiry date (MM/YY format)
class ExpiryDateFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll(RegExp(r'[^\d]'), '');

    final limitedText = text.length > 4 ? text.substring(0, 4) : text;

    String formatted = '';
    for (int i = 0; i < limitedText.length; i++) {
      if (i == 2) {
        formatted += '/';
      }
      formatted += limitedText[i];
    }

    if (limitedText.length >= 2 && !formatted.contains('/')) {
      formatted = '${limitedText.substring(0, 2)}/${limitedText.substring(2)}';
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

/// Input formatter for CVV (3 digits only)
class CVVFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll(RegExp(r'[^\d]'), '');
    final limitedText = text.length > 3 ? text.substring(0, 3) : text;

    return TextEditingValue(
      text: limitedText,
      selection: TextSelection.collapsed(offset: limitedText.length),
    );
  }
}

/// Input formatter for Israeli ID (9 digits only)
class IsraeliIDFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll(RegExp(r'[^\d]'), '');
    final limitedText = text.length > 9 ? text.substring(0, 9) : text;

    return TextEditingValue(
      text: limitedText,
      selection: TextSelection.collapsed(offset: limitedText.length),
    );
  }
}

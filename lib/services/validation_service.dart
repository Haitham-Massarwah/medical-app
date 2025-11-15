class ValidationService {
  // Israeli ID validation using the Luhn algorithm
  static bool isValidIsraeliId(String id) {
    if (id.isEmpty || id.length != 9) return false;
    
    // Check if all characters are digits
    if (!RegExp(r'^\d+$').hasMatch(id)) return false;
    
    // Israeli ID validation algorithm
    int sum = 0;
    bool isEven = false;
    
    // Process digits from right to left
    for (int i = id.length - 1; i >= 0; i--) {
      int digit = int.parse(id[i]);
      
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
  
  // Phone number validation (10 digits)
  static bool isValidPhoneNumber(String phone) {
    if (phone.isEmpty) return false;
    
    // Remove all non-digit characters
    String digitsOnly = phone.replaceAll(RegExp(r'[^\d]'), '');
    
    // Check if it's exactly 10 digits
    return digitsOnly.length == 10;
  }
  
  // Format phone number for display
  static String formatPhoneNumber(String phone) {
    String digitsOnly = phone.replaceAll(RegExp(r'[^\d]'), '');
    
    if (digitsOnly.length == 10) {
      return '${digitsOnly.substring(0, 3)}-${digitsOnly.substring(3, 6)}-${digitsOnly.substring(6)}';
    }
    
    return phone;
  }
  
  // Validate email format
  static bool isValidEmail(String email) {
    if (email.isEmpty) return false;
    return RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(email);
  }
  
  // Validate card number using Luhn algorithm
  static bool isValidCardNumber(String cardNumber) {
    if (cardNumber.isEmpty) return false;
    
    String cleaned = cardNumber.replaceAll(' ', '');
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
  
  // Validate expiry date (MM/YY format)
  static bool isValidExpiryDate(String expiryDate) {
    if (expiryDate.length != 5 || !expiryDate.contains('/')) return false;
    
    final parts = expiryDate.split('/');
    if (parts.length != 2) return false;
    
    try {
      final month = int.parse(parts[0]);
      final year = int.parse(parts[1]) + 2000; // Convert YY to YYYY
      
      if (month < 1 || month > 12) return false;
      
      final now = DateTime.now();
      final expiry = DateTime(year, month);
      
      return expiry.isAfter(now);
    } catch (e) {
      return false;
    }
  }
  
  // Validate CVV (3-4 digits)
  static bool isValidCVV(String cvv) {
    if (cvv.isEmpty) return false;
    return RegExp(r'^\d{3,4}$').hasMatch(cvv);
  }
  
  // Validate name (Hebrew or English letters)
  static bool isValidName(String name) {
    if (name.isEmpty) return false;
    return RegExp(r'^[\u0590-\u05FF\u0041-\u005A\u0061-\u007A\s]+$').hasMatch(name);
  }
  
  // Validate address
  static bool isValidAddress(String address) {
    return address.isNotEmpty && address.length >= 5;
  }
  
  // Validate city
  static bool isValidCity(String city) {
    return city.isNotEmpty && city.length >= 2;
  }
  
  // Validate zip code (Israeli format)
  static bool isValidZipCode(String zipCode) {
    if (zipCode.isEmpty) return false;
    String digitsOnly = zipCode.replaceAll(RegExp(r'[^\d]'), '');
    return digitsOnly.length == 7; // Israeli zip codes are 7 digits
  }
}








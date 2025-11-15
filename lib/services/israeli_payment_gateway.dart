import 'dart:convert';
import 'package:http/http.dart' as http;

class IsraeliPaymentGateway {
  static const String _baseUrl = 'https://api.shva.co.il'; // Israeli payment gateway
  static const String _merchantId = 'YOUR_MERCHANT_ID';
  static const String _terminalId = 'YOUR_TERMINAL_ID';
  static const String _apiKey = 'YOUR_API_KEY';
  
  // Israeli VAT rate
  static const double _vatRate = 0.17; // 17% VAT
  
  // Process payment through Israeli gateway
  static Future<Map<String, dynamic>> processPayment({
    required double amount,
    required String paymentMethod,
    Map<String, dynamic>? cardDetails,
    required String transactionId,
    required String customerEmail,
    required String customerName,
    required String customerPhone,
  }) async {
    try {
      // Calculate VAT
      final vatAmount = amount * _vatRate;
      final totalAmount = amount + vatAmount;
      
      // Prepare payment data according to Israeli standards
      final paymentData = {
        'merchantId': _merchantId,
        'terminalId': _terminalId,
        'transactionId': transactionId,
        'amount': (totalAmount * 100).round(), // Amount in agorot (cents)
        'currency': 'ILS',
        'paymentMethod': _getPaymentMethodCode(paymentMethod),
        'cardDetails': cardDetails,
        'customer': {
          'email': customerEmail,
          'name': customerName,
          'phone': customerPhone,
        },
        'vat': {
          'rate': _vatRate,
          'amount': (vatAmount * 100).round(),
        },
        'receipt': {
          'required': true,
          'email': customerEmail,
          'format': 'pdf',
        },
        'compliance': {
          'israeliLaw': true,
          'dataProtection': true,
          'auditTrail': true,
        },
      };

      // Call Israeli payment gateway
      final response = await http.post(
        Uri.parse('$_baseUrl/v1/payments/process'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
          'X-Merchant-ID': _merchantId,
        },
        body: jsonEncode(paymentData),
      );

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        return {
          'success': true,
          'transactionId': result['transactionId'],
          'gatewayTransactionId': result['gatewayTransactionId'],
          'amount': result['amount'] / 100, // Convert back from agorot
          'vat': result['vat'] / 100,
          'total': result['total'] / 100,
          'receiptUrl': result['receiptUrl'],
          'status': result['status'],
        };
      } else {
        return {
          'success': false,
          'error': 'Payment gateway error: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Payment processing error: $e',
      };
    }
  }

  // Get payment method code for Israeli gateway
  static String _getPaymentMethodCode(String method) {
    // Only card payments are supported
    return 'CREDIT_CARD';
  }

  // Validate Israeli card number
  static bool validateIsraeliCard(String cardNumber) {
    // Remove spaces and check format
    cardNumber = cardNumber.replaceAll(' ', '');
    
    // Israeli cards: Visa (4), Mastercard (5), Isracard (9)
    if (!RegExp(r'^[459]\d{13,18}$').hasMatch(cardNumber)) {
      return false;
    }
    
    // Luhn algorithm validation
    return _luhnCheck(cardNumber);
  }

  // Luhn algorithm for card validation
  static bool _luhnCheck(String cardNumber) {
    int sum = 0;
    bool alternate = false;
    
    for (int i = cardNumber.length - 1; i >= 0; i--) {
      int digit = int.parse(cardNumber[i]);
      
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

  // Generate Israeli-compliant receipt
  static Map<String, dynamic> generateIsraeliReceipt({
    required String transactionId,
    required double amount,
    required double vat,
    required String customerName,
    required String customerEmail,
    required List<Map<String, dynamic>> appointments,
  }) {
    final receiptNumber = 'RCP-${DateTime.now().millisecondsSinceEpoch}';
    
    return {
      'receiptNumber': receiptNumber,
      'transactionId': transactionId,
      'date': DateTime.now().toIso8601String(),
      'merchant': {
        'name': 'Medical Appointment System',
        'address': 'תל אביב, ישראל',
        'taxId': 'YOUR_TAX_ID',
        'license': 'YOUR_BUSINESS_LICENSE',
      },
      'customer': {
        'name': customerName,
        'email': customerEmail,
      },
      'items': appointments.map((appointment) => {
        'description': 'תור עם ${appointment['doctorName']} - ${appointment['specialty']}',
        'date': appointment['appointmentDate'],
        'time': appointment['timeSlot'],
        'amount': appointment['consultationFee'],
        'vat': appointment['consultationFee'] * _vatRate,
      }).toList(),
      'totals': {
        'subtotal': amount,
        'vat': vat,
        'total': amount + vat,
      },
      'payment': {
        'method': 'כרטיס אשראי',
        'status': 'שולם',
      },
      'compliance': {
        'israeliLaw': true,
        'vatCompliant': true,
        'auditTrail': true,
      },
    };
  }

  // Send receipt via Israeli email service
  static Future<bool> sendIsraeliReceipt({
    required String customerEmail,
    required Map<String, dynamic> receipt,
  }) async {
    try {
      final emailData = {
        'to': customerEmail,
        'subject': 'קבלת תשלום - ${receipt['receiptNumber']}',
        'template': 'israeli_receipt',
        'data': receipt,
        'compliance': {
          'israeliLaw': true,
          'hebrewRtl': true,
        },
      };

      final response = await http.post(
        Uri.parse('https://api.email.co.il/v1/send'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer YOUR_EMAIL_API_KEY',
        },
        body: jsonEncode(emailData),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error sending Israeli receipt: $e');
      return false;
    }
  }

  // Get supported payment methods in Israel
  static List<Map<String, dynamic>> getSupportedPaymentMethods() {
    return [
      {
        'id': 'card',
        'name': 'כרטיס אשראי',
        'description': 'Visa / Mastercard / Isracard',
        'icon': 'credit_card',
        'enabled': true,
        'israeliCompliant': true,
      },
    ];
  }

  // Validate Israeli phone number
  static bool validateIsraeliPhone(String phone) {
    // Remove spaces and dashes
    phone = phone.replaceAll(RegExp(r'[\s\-]'), '');
    
    // Israeli phone patterns
    final patterns = [
      r'^05\d{8}$', // Mobile: 05X-XXXXXXX
      r'^0[2-4]\d{7,8}$', // Landline: 0X-XXXXXXX
      r'^\+972[2-5]\d{8,9}$', // International format
    ];
    
    return patterns.any((pattern) => RegExp(pattern).hasMatch(phone));
  }

  // Validate Israeli email
  static bool validateIsraeliEmail(String email) {
    // Basic email validation
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      return false;
    }
    
    // Check for Israeli domains
    final israeliDomains = ['.co.il', '.org.il', '.net.il', '.ac.il'];
    return israeliDomains.any((domain) => email.toLowerCase().endsWith(domain));
  }
}

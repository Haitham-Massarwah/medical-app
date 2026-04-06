import 'dart:convert';
import 'package:http/http.dart' as http;
import '../features/payments/data/models/payment_models.dart';
import '../core/security/payment_security_service.dart';
import '../core/security/audit_logging_service_stub.dart'
    if (dart.library.io) '../core/security/audit_logging_service.dart';

class VisaMastercardPaymentService {
  static const String _baseUrl = 'https://api.visa.com';
  static const String _mastercardUrl = 'https://api.mastercard.com';
  
  // Visa API credentials
  static const String _visaApiKey = 'YOUR_VISA_API_KEY';
  static const String _visaMerchantId = 'YOUR_VISA_MERCHANT_ID';
  
  // Mastercard API credentials
  static const String _mastercardApiKey = 'YOUR_MASTERCARD_API_KEY';
  static const String _mastercardMerchantId = 'YOUR_MASTERCARD_MERCHANT_ID';

  /// Process payment through Visa or Mastercard with enhanced security
  static Future<PaymentGatewayResponse> processPayment({
    required CardDetailsModel cardDetails,
    required double amount,
    required String currency,
    required String merchantId,
    String? customerId,
  }) async {
    try {
      // Initialize security services
      final paymentSecurityService = PaymentSecurityService();
      final auditLoggingService = AuditLoggingService();
      await paymentSecurityService.initialize();
      await auditLoggingService.initialize();

      // Convert card details to map for security service
      final cardDetailsMap = {
        'number': cardDetails.number,
        'expiryMonth': cardDetails.expiryMonth,
        'expiryYear': cardDetails.expiryYear,
        'cvv': cardDetails.cvv,
        'cardholderName': cardDetails.cardholderName,
        'cardType': cardDetails.cardType.toString(),
      };

      // Process payment through secure payment service
      final secureResult = await paymentSecurityService.processSecurePayment(
        cardDetails: cardDetailsMap,
        amount: amount,
        currency: currency,
        merchantId: merchantId,
        customerId: customerId ?? 'unknown',
      );

      if (secureResult.success) {
        // Log successful payment
        await auditLoggingService.logPaymentEvent(
          userId: customerId ?? 'unknown',
          action: 'PAYMENT_COMPLETED',
          transactionId: secureResult.transactionId ?? 'unknown',
          amount: amount,
          currency: currency,
          success: true,
        );

        return PaymentGatewayResponse(
          success: true,
          transactionId: secureResult.transactionId,
          gatewayData: secureResult.gatewayResponse,
        );
      } else {
        // Log failed payment
        await auditLoggingService.logPaymentEvent(
          userId: customerId ?? 'unknown',
          action: 'PAYMENT_FAILED',
          transactionId: secureResult.transactionId ?? 'unknown',
          amount: amount,
          currency: currency,
          success: false,
          failureReason: secureResult.error,
        );

        return PaymentGatewayResponse(
          success: false,
          errorMessage: secureResult.error,
        );
      }
    } catch (e) {
      // Log payment error
      final auditLoggingService = AuditLoggingService();
      await auditLoggingService.initialize();
      await auditLoggingService.logPaymentEvent(
        userId: customerId ?? 'unknown',
        action: 'PAYMENT_ERROR',
        transactionId: 'unknown',
        amount: amount,
        currency: currency,
        success: false,
        failureReason: e.toString(),
      );

      return PaymentGatewayResponse(
        success: false,
        errorMessage: 'Payment processing error: $e',
      );
    }
  }

  /// Process Visa payment
  static Future<PaymentGatewayResponse> _processVisaPayment(
    CardDetailsModel cardDetails,
    double amount,
    String currency,
    String merchantId,
  ) async {
    final url = Uri.parse('$_baseUrl/v1/payments');
    
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $_visaApiKey',
      'X-Merchant-ID': _visaMerchantId,
    };

    final body = {
      'amount': amount,
      'currency': currency,
      'card': {
        'number': cardDetails.number,
        'expiryMonth': cardDetails.expiryMonth,
        'expiryYear': cardDetails.expiryYear,
        'cvv': cardDetails.cvv,
        'cardholderName': cardDetails.cardholderName,
      },
      'merchantId': merchantId,
      'description': 'Medical Appointment Payment',
    };

    final response = await http.post(url, headers: headers, body: jsonEncode(body));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return PaymentGatewayResponse(
        success: true,
        transactionId: data['transactionId'],
        gatewayData: data,
      );
    } else {
      final errorData = jsonDecode(response.body);
      return PaymentGatewayResponse(
        success: false,
        errorMessage: errorData['message'] ?? 'Visa payment failed',
      );
    }
  }

  /// Process Mastercard payment
  static Future<PaymentGatewayResponse> _processMastercardPayment(
    CardDetailsModel cardDetails,
    double amount,
    String currency,
    String merchantId,
  ) async {
    final url = Uri.parse('$_mastercardUrl/v1/payments');
    
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $_mastercardApiKey',
      'X-Merchant-ID': _mastercardMerchantId,
    };

    final body = {
      'amount': amount,
      'currency': currency,
      'card': {
        'number': cardDetails.number,
        'expiryMonth': cardDetails.expiryMonth,
        'expiryYear': cardDetails.expiryYear,
        'cvv': cardDetails.cvv,
        'cardholderName': cardDetails.cardholderName,
      },
      'merchantId': merchantId,
      'description': 'Medical Appointment Payment',
    };

    final response = await http.post(url, headers: headers, body: jsonEncode(body));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return PaymentGatewayResponse(
        success: true,
        transactionId: data['transactionId'],
        gatewayData: data,
      );
    } else {
      final errorData = jsonDecode(response.body);
      return PaymentGatewayResponse(
        success: false,
        errorMessage: errorData['message'] ?? 'Mastercard payment failed',
      );
    }
  }

  /// Validate card number and determine card type
  static PaymentMethod? validateCardNumber(String cardNumber) {
    // Remove spaces and non-digits
    final cleanNumber = cardNumber.replaceAll(RegExp(r'[^\d]'), '');
    
    if (cleanNumber.isEmpty) return null;

    // Visa: starts with 4, 13-19 digits
    if (cleanNumber.startsWith('4') && cleanNumber.length >= 13 && cleanNumber.length <= 19) {
      return PaymentMethod.visa;
    }
    
    // Mastercard: starts with 5[1-5] or 2[2-7], 16 digits
    if ((cleanNumber.startsWith('5') && int.parse(cleanNumber[1]) >= 1 && int.parse(cleanNumber[1]) <= 5) ||
        (cleanNumber.startsWith('2') && int.parse(cleanNumber[1]) >= 2 && int.parse(cleanNumber[1]) <= 7)) {
      if (cleanNumber.length == 16) {
        return PaymentMethod.mastercard;
      }
    }

    return null;
  }

  /// Validate CVV based on card type
  static bool validateCVV(String cvv, PaymentMethod cardType) {
    if (cvv.isEmpty) return false;
    
    switch (cardType) {
      case PaymentMethod.visa:
      case PaymentMethod.mastercard:
        return cvv.length == 3 || cvv.length == 4;
      default:
        return false;
    }
  }

  /// Validate expiry date
  static bool validateExpiryDate(String month, String year) {
    try {
      final expMonth = int.parse(month);
      final expYear = int.parse(year);
      final now = DateTime.now();
      
      if (expMonth < 1 || expMonth > 12) return false;
      
      final expiryDate = DateTime(2000 + expYear, expMonth);
      return expiryDate.isAfter(now);
    } catch (e) {
      return false;
    }
  }
}

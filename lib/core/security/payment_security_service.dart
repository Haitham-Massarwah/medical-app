import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'encryption_service.dart';

/// PCI DSS compliant payment security service
class PaymentSecurityService {
  static final PaymentSecurityService _instance = PaymentSecurityService._internal();
  factory PaymentSecurityService() => _instance;
  PaymentSecurityService._internal();

  final EncryptionService _encryptionService = EncryptionService();
  
  // PCI DSS compliance constants
  static const int _maxRetryAttempts = 3;
  static const Duration _lockoutDuration = Duration(minutes: 15);
  static const int _maxDailyTransactions = 1000;
  
  // Track failed payment attempts
  final Map<String, List<DateTime>> _failedAttempts = {};
  final Map<String, int> _dailyTransactionCounts = {};

  /// Initialize payment security service
  Future<void> initialize() async {
    await _encryptionService.initialize();
  }

  /// Process secure payment with PCI DSS compliance
  Future<SecurePaymentResult> processSecurePayment({
    required Map<String, dynamic> cardDetails,
    required double amount,
    required String currency,
    required String merchantId,
    required String customerId,
  }) async {
    try {
      // Validate payment data
      final validationResult = _validatePaymentData(cardDetails, amount, currency);
      if (!validationResult.isValid) {
        return SecurePaymentResult(
          success: false,
          error: validationResult.error,
          transactionId: null,
        );
      }

      // Check rate limiting
      if (!_checkPaymentRateLimit(customerId)) {
        return SecurePaymentResult(
          success: false,
          error: 'Payment rate limit exceeded. Please try again later.',
          transactionId: null,
        );
      }

      // Check daily transaction limit
      if (!_checkDailyTransactionLimit(customerId)) {
        return SecurePaymentResult(
          success: false,
          error: 'Daily transaction limit exceeded.',
          transactionId: null,
        );
      }

      // Encrypt sensitive card data
      final encryptedCardData = _encryptCardData(cardDetails);
      
      // Generate secure transaction ID
      final transactionId = _generateSecureTransactionId();
      
      // Create payment token (PCI DSS requirement)
      final paymentToken = _generatePaymentToken(encryptedCardData);
      
      // Process payment through secure gateway
      final paymentResult = await _processPaymentThroughGateway(
        paymentToken: paymentToken,
        amount: amount,
        currency: currency,
        merchantId: merchantId,
        transactionId: transactionId,
      );

      // Log payment attempt
      await _logPaymentAttempt(
        transactionId: transactionId,
        customerId: customerId,
        amount: amount,
        success: paymentResult.success,
      );

      if (paymentResult.success) {
        // Clear failed attempts on success
        _clearFailedAttempts(customerId);
        
        return SecurePaymentResult(
          success: true,
          transactionId: transactionId,
          paymentToken: paymentToken,
          gatewayResponse: paymentResult.gatewayData,
        );
      } else {
        // Record failed attempt
        _recordFailedAttempt(customerId);
        
        return SecurePaymentResult(
          success: false,
          error: paymentResult.error,
          transactionId: transactionId,
        );
      }

    } catch (e) {
      await _logSecurityEvent('PAYMENT_ERROR', {
        'error': e.toString(),
        'customer_id': customerId,
        'amount': amount,
        'timestamp': DateTime.now().toIso8601String(),
      });

      return SecurePaymentResult(
        success: false,
        error: 'Payment processing failed: $e',
        transactionId: null,
      );
    }
  }

  /// Validate payment card data
  PaymentValidationResult _validatePaymentData(
    Map<String, dynamic> cardDetails,
    double amount,
    String currency,
  ) {
    // Validate card number
    final cardNumber = cardDetails['number']?.toString().replaceAll(' ', '') ?? '';
    if (!_isValidCardNumber(cardNumber)) {
      return PaymentValidationResult(
        isValid: false,
        error: 'Invalid card number format',
      );
    }

    // Validate expiry date
    final expiryMonth = cardDetails['expiryMonth']?.toString() ?? '';
    final expiryYear = cardDetails['expiryYear']?.toString() ?? '';
    if (!_isValidExpiryDate(expiryMonth, expiryYear)) {
      return PaymentValidationResult(
        isValid: false,
        error: 'Invalid expiry date',
      );
    }

    // Validate CVV
    final cvv = cardDetails['cvv']?.toString() ?? '';
    if (!_isValidCVV(cvv)) {
      return PaymentValidationResult(
        isValid: false,
        error: 'Invalid CVV',
      );
    }

    // Validate cardholder name
    final cardholderName = cardDetails['cardholderName']?.toString() ?? '';
    if (cardholderName.isEmpty || cardholderName.length < 2) {
      return PaymentValidationResult(
        isValid: false,
        error: 'Invalid cardholder name',
      );
    }

    // Validate amount
    if (amount <= 0 || amount > 100000) {
      return PaymentValidationResult(
        isValid: false,
        error: 'Invalid payment amount',
      );
    }

    // Validate currency
    if (!['ILS', 'USD', 'EUR'].contains(currency)) {
      return PaymentValidationResult(
        isValid: false,
        error: 'Unsupported currency',
      );
    }

    return PaymentValidationResult(isValid: true);
  }

  /// Validate card number using Luhn algorithm
  bool _isValidCardNumber(String cardNumber) {
    if (cardNumber.length < 13 || cardNumber.length > 19) {
      return false;
    }

    // Luhn algorithm
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

  /// Validate expiry date
  bool _isValidExpiryDate(String month, String year) {
    try {
      final expMonth = int.parse(month);
      final expYear = int.parse(year);
      
      if (expMonth < 1 || expMonth > 12) return false;
      
      final now = DateTime.now();
      final expiryDate = DateTime(2000 + expYear, expMonth);
      
      return expiryDate.isAfter(now);
    } catch (e) {
      return false;
    }
  }

  /// Validate CVV
  bool _isValidCVV(String cvv) {
    return RegExp(r'^\d{3,4}$').hasMatch(cvv);
  }

  /// Encrypt card data for secure storage
  String _encryptCardData(Map<String, dynamic> cardDetails) {
    // Remove sensitive data that shouldn't be stored
    final sanitizedData = {
      'number': _maskCardNumber(cardDetails['number']?.toString() ?? ''),
      'expiryMonth': cardDetails['expiryMonth'],
      'expiryYear': cardDetails['expiryYear'],
      'cardholderName': cardDetails['cardholderName'],
      'cardType': cardDetails['cardType'],
    };
    
    return _encryptionService.encryptCardDetails(sanitizedData);
  }

  /// Mask card number for storage (show only last 4 digits)
  String _maskCardNumber(String cardNumber) {
    if (cardNumber.length < 4) return cardNumber;
    return '**** **** **** ${cardNumber.substring(cardNumber.length - 4)}';
  }

  /// Generate secure transaction ID
  String _generateSecureTransactionId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = Random.secure().nextInt(999999);
    return 'TXN_${timestamp}_$random';
  }

  /// Generate payment token for PCI DSS compliance
  String _generatePaymentToken(String encryptedCardData) {
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final data = '$encryptedCardData$timestamp';
    final bytes = utf8.encode(data);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Process payment through secure gateway
  Future<PaymentGatewayResult> _processPaymentThroughGateway({
    required String paymentToken,
    required double amount,
    required String currency,
    required String merchantId,
    required String transactionId,
  }) async {
    // In production, this would integrate with a real payment gateway
    // For now, we'll simulate the process
    
    try {
      // Simulate API call delay
      await Future.delayed(const Duration(seconds: 2));
      
      // Simulate payment processing
      final success = Random.secure().nextBool();
      
      if (success) {
        return PaymentGatewayResult(
          success: true,
          gatewayData: {
            'transaction_id': transactionId,
            'amount': amount,
            'currency': currency,
            'status': 'completed',
            'timestamp': DateTime.now().toIso8601String(),
          },
        );
      } else {
        return PaymentGatewayResult(
          success: false,
          error: 'Payment declined by gateway',
        );
      }
    } catch (e) {
      return PaymentGatewayResult(
        success: false,
        error: 'Gateway communication failed: $e',
      );
    }
  }

  /// Check payment rate limiting
  bool _checkPaymentRateLimit(String customerId) {
    final now = DateTime.now();
    final attempts = _failedAttempts[customerId] ?? [];
    
    // Remove attempts older than lockout duration
    attempts.removeWhere((time) => now.difference(time).inMinutes >= _lockoutDuration.inMinutes);
    
    // Check if customer is locked out
    if (attempts.length >= _maxRetryAttempts) {
      return false;
    }
    
    _failedAttempts[customerId] = attempts;
    return true;
  }

  /// Check daily transaction limit
  bool _checkDailyTransactionLimit(String customerId) {
    final today = DateTime.now().toIso8601String().split('T')[0];
    final key = '${customerId}_$today';
    
    final count = _dailyTransactionCounts[key] ?? 0;
    return count < _maxDailyTransactions;
  }

  /// Record failed payment attempt
  void _recordFailedAttempt(String customerId) {
    final now = DateTime.now();
    final attempts = _failedAttempts[customerId] ?? [];
    attempts.add(now);
    _failedAttempts[customerId] = attempts;
  }

  /// Clear failed attempts
  void _clearFailedAttempts(String customerId) {
    _failedAttempts.remove(customerId);
  }

  /// Log payment attempt
  Future<void> _logPaymentAttempt({
    required String transactionId,
    required String customerId,
    required double amount,
    required bool success,
  }) async {
    await _logSecurityEvent('PAYMENT_ATTEMPT', {
      'transaction_id': transactionId,
      'customer_id': customerId,
      'amount': amount,
      'success': success,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  /// Log security events
  Future<void> _logSecurityEvent(String eventType, Map<String, dynamic> data) async {
    // In production, this would log to a secure audit system
    print('PAYMENT_SECURITY_EVENT: $eventType - $data');
  }

  /// Validate payment amount for fraud detection
  bool _isAmountSuspicious(double amount, String customerId) {
    // Check for unusually high amounts
    if (amount > 50000) {
      return true;
    }
    
    // Check for round numbers (potential fraud indicator)
    if (amount % 1000 == 0 && amount > 10000) {
      return true;
    }
    
    return false;
  }

  /// Generate secure session token for payment
  String generatePaymentSessionToken(String customerId) {
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final random = _encryptionService.generateSecureToken();
    final data = '$customerId$timestamp$random';
    final bytes = utf8.encode(data);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
}

/// Payment validation result
class PaymentValidationResult {
  final bool isValid;
  final String? error;

  PaymentValidationResult({
    required this.isValid,
    this.error,
  });
}

/// Secure payment result
class SecurePaymentResult {
  final bool success;
  final String? error;
  final String? transactionId;
  final String? paymentToken;
  final Map<String, dynamic>? gatewayResponse;

  SecurePaymentResult({
    required this.success,
    this.error,
    this.transactionId,
    this.paymentToken,
    this.gatewayResponse,
  });
}

/// Payment gateway result
class PaymentGatewayResult {
  final bool success;
  final String? error;
  final Map<String, dynamic>? gatewayData;

  PaymentGatewayResult({
    required this.success,
    this.error,
    this.gatewayData,
  });
}








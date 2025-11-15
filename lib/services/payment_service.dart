import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/appointment_cart.dart';

class PaymentService {
  static const String _baseUrl = 'http://localhost:3000/api/v1/payments';
  
  // Process multi-appointment payment with rollback support
  Future<Map<String, dynamic>> processMultiAppointmentPayment({
    required AppointmentCart cart,
    required String paymentMethod,
    Map<String, dynamic>? cardDetails,
  }) async {
    try {
      // Start transaction
      final transactionId = _generateTransactionId();
      
      // Validate payment method
      if (!_isValidPaymentMethod(paymentMethod)) {
        return {
          'success': false,
          'error': 'שיטת תשלום לא נתמכת',
        };
      }

      // Validate card details if needed
      if (paymentMethod == 'card' && cardDetails != null) {
        if (!_validateCardDetails(cardDetails)) {
          return {
            'success': false,
            'error': 'פרטי כרטיס לא תקינים',
          };
        }
      }

      // Process payment with Israeli payment gateway
      final paymentResult = await _processPaymentWithGateway(
        amount: cart.totalAmount,
        paymentMethod: paymentMethod,
        cardDetails: cardDetails,
        transactionId: transactionId,
      );

      if (!paymentResult['success']) {
        return {
          'success': false,
          'error': paymentResult['error'] ?? 'שגיאה בעיבוד התשלום',
        };
      }

      // Create appointments
      final appointmentsResult = await _createAppointments(
        cart: cart,
        transactionId: transactionId,
      );

      if (!appointmentsResult['success']) {
        // Rollback payment
        await _rollbackPayment(transactionId);
        return {
          'success': false,
          'error': 'שגיאה ביצירת התורים - התשלום הוחזר',
        };
      }

      // Update doctor accounts
      final updateResult = await _updateDoctorAccounts(
        cart: cart,
        transactionId: transactionId,
      );

      if (!updateResult['success']) {
        // Log error but don't rollback (appointments already created)
        print('Warning: Failed to update doctor accounts: ${updateResult['error']}');
      }

      return {
        'success': true,
        'transactionId': transactionId,
        'appointments': appointmentsResult['appointments'],
      };

    } catch (e) {
      return {
        'success': false,
        'error': 'שגיאה כללית: $e',
      };
    }
  }

  // Process payment with Israeli payment gateway
  Future<Map<String, dynamic>> _processPaymentWithGateway({
    required double amount,
    required String paymentMethod,
    Map<String, dynamic>? cardDetails,
    required String transactionId,
  }) async {
    try {
      // Simulate Israeli payment gateway (Shva, Cardcom, etc.)
      final paymentData = {
        'transactionId': transactionId,
        'amount': amount,
        'currency': 'ILS',
        'paymentMethod': paymentMethod,
        'cardDetails': cardDetails,
        'merchantId': 'YOUR_MERCHANT_ID',
        'terminalId': 'YOUR_TERMINAL_ID',
      };

      // In real implementation, call actual payment gateway
      final response = await http.post(
        Uri.parse('$_baseUrl/process'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(paymentData),
      );

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        return {
          'success': result['success'] ?? false,
          'error': result['error'],
          'gatewayTransactionId': result['gatewayTransactionId'],
        };
      } else {
        return {
          'success': false,
          'error': 'שגיאה בחיבור לשער התשלום',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'שגיאה בעיבוד התשלום: $e',
      };
    }
  }

  // Create appointments for all items in cart
  Future<Map<String, dynamic>> _createAppointments({
    required AppointmentCart cart,
    required String transactionId,
  }) async {
    try {
      final appointments = <Map<String, dynamic>>[];

      for (final item in cart.items) {
        final appointmentData = {
          'doctorId': item.doctorId,
          'patientEmail': cart.customerEmail,
          'patientName': cart.customerName,
          'patientPhone': cart.customerPhone,
          'appointmentDate': item.appointmentDate.toIso8601String(),
          'timeSlot': item.timeSlot,
          'consultationFee': item.consultationFee,
          'transactionId': transactionId,
          'status': 'confirmed',
        };

        // Create appointment via API
        final response = await http.post(
          Uri.parse('http://localhost:3000/api/v1/appointments'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(appointmentData),
        );

        if (response.statusCode == 201) {
          final appointment = jsonDecode(response.body);
          appointments.add(appointment);
        } else {
          // If any appointment fails, rollback all
          await _rollbackAppointments(appointments);
          return {
            'success': false,
            'error': 'שגיאה ביצירת תור עם ${item.doctorName}',
          };
        }
      }

      return {
        'success': true,
        'appointments': appointments,
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'שגיאה ביצירת התורים: $e',
      };
    }
  }

  // Update doctor accounts with payments
  Future<Map<String, dynamic>> _updateDoctorAccounts({
    required AppointmentCart cart,
    required String transactionId,
  }) async {
    try {
      for (final item in cart.items) {
        final paymentData = {
          'doctorId': item.doctorId,
          'amount': item.consultationFee,
          'transactionId': transactionId,
          'appointmentDate': item.appointmentDate.toIso8601String(),
          'status': 'completed',
        };

        await http.post(
          Uri.parse('http://localhost:3000/api/v1/doctor-payments'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(paymentData),
        );
      }

      return {'success': true};
    } catch (e) {
      return {
        'success': false,
        'error': 'שגיאה בעדכון חשבונות רופאים: $e',
      };
    }
  }

  // Rollback payment if something fails
  Future<void> _rollbackPayment(String transactionId) async {
    try {
      await http.post(
        Uri.parse('$_baseUrl/rollback'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'transactionId': transactionId}),
      );
    } catch (e) {
      print('Error rolling back payment: $e');
    }
  }

  // Rollback appointments if payment fails
  Future<void> _rollbackAppointments(List<Map<String, dynamic>> appointments) async {
    for (final appointment in appointments) {
      try {
        await http.delete(
          Uri.parse('http://localhost:3000/api/v1/appointments/${appointment['id']}'),
        );
      } catch (e) {
        print('Error rolling back appointment: $e');
      }
    }
  }

  // Validate payment method
  bool _isValidPaymentMethod(String method) {
    return ['card', 'apple_pay', 'google_pay'].contains(method);
  }

  // Validate card details for Israeli cards
  bool _validateCardDetails(Map<String, dynamic> cardDetails) {
    final cardNumber = cardDetails['cardNumber'] as String;
    final expiry = cardDetails['expiry'] as String;
    final cvv = cardDetails['cvv'] as String;
    final cardName = cardDetails['cardName'] as String;

    // Validate card number (Visa/Mastercard)
    if (!RegExp(r'^\d{13,19}$').hasMatch(cardNumber)) return false;
    if (!cardNumber.startsWith('4') && !cardNumber.startsWith('5')) return false;
    if (!_luhnCheck(cardNumber)) return false;

    // Validate expiry date
    if (!RegExp(r'^\d{2}/\d{2}$').hasMatch(expiry)) return false;
    final parts = expiry.split('/');
    final month = int.parse(parts[0]);
    final year = int.parse(parts[1]) + 2000;
    if (month < 1 || month > 12) return false;
    final expiryDate = DateTime(year, month);
    if (expiryDate.isBefore(DateTime.now())) return false;

    // Validate CVV
    if (!RegExp(r'^\d{3,4}$').hasMatch(cvv)) return false;

    // Validate card name
    if (cardName.trim().isEmpty) return false;

    return true;
  }

  // Luhn algorithm for card validation
  bool _luhnCheck(String cardNumber) {
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

  // Generate unique transaction ID
  String _generateTransactionId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = (timestamp % 10000).toString().padLeft(4, '0');
    return 'TXN_${timestamp}_$random';
  }

  // Get payment methods available in Israel
  List<Map<String, dynamic>> getAvailablePaymentMethods() {
    return [
      {
        'id': 'card',
        'name': 'כרטיס אשראי',
        'description': 'Visa / Mastercard',
        'icon': 'credit_card',
        'enabled': true,
      },
      {
        'id': 'apple_pay',
        'name': 'Apple Pay',
        'description': 'תשלום מהיר ובטוח',
        'icon': 'apple',
        'enabled': true,
      },
      {
        'id': 'google_pay',
        'name': 'Google Pay',
        'description': 'תשלום מהיר ובטוח',
        'icon': 'android',
        'enabled': true,
      },
    ];
  }
}
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/appointment_cart.dart';

class EmailService {
  static const String _baseUrl = 'http://localhost:3000/api/v1/email';

  // Send receipt to customer
  Future<bool> sendCustomerReceipt({
    required String customerEmail,
    required String customerName,
    required String transactionId,
    required List<AppointmentCartItem> appointments,
    required double totalAmount,
  }) async {
    try {
      final emailData = {
        'to': customerEmail,
        'subject': 'קבלת תשלום - תורים נקבעו בהצלחה',
        'template': 'customer_receipt',
        'data': {
          'customerName': customerName,
          'transactionId': transactionId,
          'totalAmount': totalAmount,
          'appointments': appointments.map((item) => {
            'doctorName': item.doctorName,
            'specialty': item.specialty,
            'date': _formatDate(item.appointmentDate),
            'time': item.timeSlot,
            'amount': item.consultationFee,
          }).toList(),
          'receiptDate': _formatDate(DateTime.now()),
        },
      };

      final response = await http.post(
        Uri.parse('$_baseUrl/send'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(emailData),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error sending customer receipt: $e');
      return false;
    }
  }

  // Send receipt to doctor
  Future<bool> sendDoctorReceipt({
    required String doctorEmail,
    required String doctorName,
    required String customerName,
    required DateTime appointmentDate,
    required String timeSlot,
    required double amount,
    required String transactionId,
  }) async {
    try {
      final emailData = {
        'to': doctorEmail,
        'subject': 'תור חדש נקבע - $customerName',
        'template': 'doctor_receipt',
        'data': {
          'doctorName': doctorName,
          'customerName': customerName,
          'appointmentDate': _formatDate(appointmentDate),
          'timeSlot': timeSlot,
          'amount': amount,
          'transactionId': transactionId,
          'receiptDate': _formatDate(DateTime.now()),
        },
      };

      final response = await http.post(
        Uri.parse('$_baseUrl/send'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(emailData),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error sending doctor receipt: $e');
      return false;
    }
  }

  // Send appointment reminder
  Future<bool> sendAppointmentReminder({
    required String customerEmail,
    required String customerName,
    required String doctorName,
    required DateTime appointmentDate,
    required String timeSlot,
  }) async {
    try {
      final emailData = {
        'to': customerEmail,
        'subject': 'תזכורת לתור - $doctorName',
        'template': 'appointment_reminder',
        'data': {
          'customerName': customerName,
          'doctorName': doctorName,
          'appointmentDate': _formatDate(appointmentDate),
          'timeSlot': timeSlot,
          'reminderDate': _formatDate(DateTime.now()),
        },
      };

      final response = await http.post(
        Uri.parse('$_baseUrl/send'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(emailData),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error sending appointment reminder: $e');
      return false;
    }
  }

  // Send payment confirmation
  Future<bool> sendPaymentConfirmation({
    required String customerEmail,
    required String customerName,
    required double amount,
    required String paymentMethod,
    required String transactionId,
  }) async {
    try {
      final emailData = {
        'to': customerEmail,
        'subject': 'אישור תשלום - ₪${amount.toStringAsFixed(0)}',
        'template': 'payment_confirmation',
        'data': {
          'customerName': customerName,
          'amount': amount,
          'paymentMethod': paymentMethod,
          'transactionId': transactionId,
          'confirmationDate': _formatDate(DateTime.now()),
        },
      };

      final response = await http.post(
        Uri.parse('$_baseUrl/send'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(emailData),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error sending payment confirmation: $e');
      return false;
    }
  }

  // Send appointment cancellation
  Future<bool> sendAppointmentCancellation({
    required String customerEmail,
    required String customerName,
    required String doctorName,
    required DateTime appointmentDate,
    required String timeSlot,
    required double refundAmount,
  }) async {
    try {
      final emailData = {
        'to': customerEmail,
        'subject': 'ביטול תור - $doctorName',
        'template': 'appointment_cancellation',
        'data': {
          'customerName': customerName,
          'doctorName': doctorName,
          'appointmentDate': _formatDate(appointmentDate),
          'timeSlot': timeSlot,
          'refundAmount': refundAmount,
          'cancellationDate': _formatDate(DateTime.now()),
        },
      };

      final response = await http.post(
        Uri.parse('$_baseUrl/send'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(emailData),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error sending appointment cancellation: $e');
      return false;
    }
  }

  // Format date for Hebrew display
  String _formatDate(DateTime date) {
    final months = [
      'ינואר', 'פברואר', 'מרץ', 'אפריל', 'מאי', 'יוני',
      'יולי', 'אוגוסט', 'ספטמבר', 'אוקטובר', 'נובמבר', 'דצמבר'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  // Get email templates
  Map<String, String> getEmailTemplates() {
    return {
      'customer_receipt': '''
<!DOCTYPE html>
<html dir="rtl" lang="he">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>קבלת תשלום</title>
    <style>
        body { font-family: Arial, sans-serif; direction: rtl; }
        .header { background-color: #4CAF50; color: white; padding: 20px; text-align: center; }
        .content { padding: 20px; }
        .appointment { border: 1px solid #ddd; margin: 10px 0; padding: 15px; border-radius: 5px; }
        .total { font-size: 18px; font-weight: bold; color: #4CAF50; }
    </style>
</head>
<body>
    <div class="header">
        <h1>קבלת תשלום - תורים נקבעו בהצלחה</h1>
    </div>
    <div class="content">
        <p>שלום {{customerName}},</p>
        <p>התורים שלך נקבעו בהצלחה! פרטי התשלום:</p>
        
        <h3>פרטי התורים:</h3>
        {{#appointments}}
        <div class="appointment">
            <strong>{{doctorName}} - {{specialty}}</strong><br>
            תאריך: {{date}}<br>
            שעה: {{time}}<br>
            סכום: ₪{{amount}}
        </div>
        {{/appointments}}
        
        <div class="total">
            סה"כ שולם: ₪{{totalAmount}}
        </div>
        
        <p>מספר עסקה: {{transactionId}}</p>
        <p>תאריך קבלה: {{receiptDate}}</p>
        
        <p>תודה על השימוש בשירותינו!</p>
    </div>
</body>
</html>
      ''',
      
      'doctor_receipt': '''
<!DOCTYPE html>
<html dir="rtl" lang="he">
<head>
    <meta charset="UTF-8">
    <title>תור חדש נקבע</title>
    <style>
        body { font-family: Arial, sans-serif; direction: rtl; }
        .header { background-color: #2196F3; color: white; padding: 20px; text-align: center; }
        .content { padding: 20px; }
    </style>
</head>
<body>
    <div class="header">
        <h1>תור חדש נקבע</h1>
    </div>
    <div class="content">
        <p>שלום ד"ר {{doctorName}},</p>
        <p>תור חדש נקבע עבורך:</p>
        
        <h3>פרטי התור:</h3>
        <p><strong>מטופל:</strong> {{customerName}}</p>
        <p><strong>תאריך:</strong> {{appointmentDate}}</p>
        <p><strong>שעה:</strong> {{timeSlot}}</p>
        <p><strong>סכום:</strong> ₪{{amount}}</p>
        <p><strong>מספר עסקה:</strong> {{transactionId}}</p>
        
        <p>אנא וודא את זמינותך לתאריך ושעה אלו.</p>
    </div>
</body>
</html>
      ''',
    };
  }
}









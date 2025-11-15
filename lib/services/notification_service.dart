import 'dart:convert';
import 'package:http/http.dart' as http;

class NotificationService {
  // Email notification using Nodemailer (backend)
  static Future<bool> sendEmailNotification({
    required String to,
    required String subject,
    required String body,
    required String type, // 'appointment_reminder', 'payment_confirmation', etc.
  }) async {
    try {
      final response = await http.post(
        Uri.parse('http://localhost:3000/api/v1/notifications/email'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'to': to,
          'subject': subject,
          'body': body,
          'type': type,
        }),
      );
      
      return response.statusCode == 200;
    } catch (e) {
      print('Error sending email: $e');
      return false;
    }
  }
  
  // SMS notification using Twilio
  static Future<bool> sendSMSNotification({
    required String to,
    required String message,
    required String type,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('http://localhost:3000/api/v1/notifications/sms'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'to': to,
          'message': message,
          'type': type,
        }),
      );
      
      return response.statusCode == 200;
    } catch (e) {
      print('Error sending SMS: $e');
      return false;
    }
  }
  
  // WhatsApp notification using Twilio
  static Future<bool> sendWhatsAppNotification({
    required String to,
    required String message,
    required String type,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('http://localhost:3000/api/v1/notifications/whatsapp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'to': to,
          'message': message,
          'type': type,
        }),
      );
      
      return response.statusCode == 200;
    } catch (e) {
      print('Error sending WhatsApp: $e');
      return false;
    }
  }
  
  // Push notification using Firebase
  static Future<bool> sendPushNotification({
    required String token,
    required String title,
    required String body,
    required String type,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('http://localhost:3000/api/v1/notifications/push'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'token': token,
          'title': title,
          'body': body,
          'type': type,
        }),
      );
      
      return response.statusCode == 200;
    } catch (e) {
      print('Error sending push notification: $e');
      return false;
    }
  }
  
  // Send appointment reminder
  static Future<bool> sendAppointmentReminder({
    required String patientEmail,
    required String patientPhone,
    required String patientName,
    required String doctorName,
    required DateTime appointmentTime,
    required String appointmentType,
  }) async {
    final subject = 'תזכורת תור - $doctorName';
    final emailBody = '''
שלום $patientName,

זוהי תזכורת לתור שלך עם $doctorName
תאריך ושעה: ${appointmentTime.toString().split('.')[0]}
סוג התור: $appointmentType

אנא הגיעו בזמן.
תודה!
    ''';
    
    final smsMessage = 'תזכורת: תור עם $doctorName ב-${appointmentTime.toString().split('.')[0]}';
    
    // Send email
    final emailSent = await sendEmailNotification(
      to: patientEmail,
      subject: subject,
      body: emailBody,
      type: 'appointment_reminder',
    );
    
    // Send SMS
    final smsSent = await sendSMSNotification(
      to: patientPhone,
      message: smsMessage,
      type: 'appointment_reminder',
    );
    
    return emailSent || smsSent;
  }
  
  // Send payment confirmation
  static Future<bool> sendPaymentConfirmation({
    required String patientEmail,
    required String patientPhone,
    required String patientName,
    required double amount,
    required String paymentMethod,
    required String appointmentDate,
  }) async {
    final subject = 'אישור תשלום - ₪$amount';
    final emailBody = '''
שלום $patientName,

תשלום שלך אושר בהצלחה!
סכום: ₪$amount
שיטת תשלום: $paymentMethod
תאריך התור: $appointmentDate

תודה על השימוש בשירותינו!
    ''';
    
    final smsMessage = 'תשלום אושר: ₪$amount עבור תור ב-$appointmentDate';
    
    // Send email
    final emailSent = await sendEmailNotification(
      to: patientEmail,
      subject: subject,
      body: emailBody,
      type: 'payment_confirmation',
    );
    
    // Send SMS
    final smsSent = await sendSMSNotification(
      to: patientPhone,
      message: smsMessage,
      type: 'payment_confirmation',
    );
    
    return emailSent || smsSent;
  }

  // Get notifications for user
  static Future<List<Map<String, dynamic>>> getNotifications() async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:3000/api/v1/notifications'),
        headers: {'Content-Type': 'application/json'},
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data['notifications'] ?? []);
      }
      return [];
    } catch (e) {
      print('Error fetching notifications: $e');
      return [];
    }
  }

  // Mark notification as read
  static Future<bool> markAsRead(String notificationId) async {
    try {
      final response = await http.put(
        Uri.parse('http://localhost:3000/api/v1/notifications/$notificationId/read'),
        headers: {'Content-Type': 'application/json'},
      );
      
      return response.statusCode == 200;
    } catch (e) {
      print('Error marking notification as read: $e');
      return false;
    }
  }
}
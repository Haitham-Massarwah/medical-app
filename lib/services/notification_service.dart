import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/config/app_config.dart';

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
        Uri.parse('${AppConfig.baseUrl.replaceFirst('/api/v1', '')}/api/v1/notifications/email'),
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
        Uri.parse('${AppConfig.baseUrl.replaceFirst('/api/v1', '')}/api/v1/notifications/sms'),
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
        Uri.parse('${AppConfig.baseUrl.replaceFirst('/api/v1', '')}/api/v1/notifications/whatsapp'),
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
        Uri.parse('${AppConfig.baseUrl.replaceFirst('/api/v1', '')}/api/v1/notifications/push'),
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

  // PD-10: Get notifications for user (system + doctor messages)
  static Future<List<Map<String, dynamic>>> getNotifications() async {
    try {
      // Fetch system notifications
      final baseUrl = AppConfig.baseUrl.replaceFirst('/api/v1', '');
      final systemResponse = await http.get(
        Uri.parse('$baseUrl/api/v1/notifications'),
        headers: {'Content-Type': 'application/json'},
      );
      
      List<Map<String, dynamic>> notifications = [];
      
      if (systemResponse.statusCode == 200) {
        final systemData = jsonDecode(systemResponse.body);
        final rawNotifications = List<Map<String, dynamic>>.from(
          systemData['data']?['notifications'] ?? systemData['notifications'] ?? []
        );
        
        // Map notifications and extract category from data field
        for (var notif in rawNotifications) {
          final data = notif['data'];
          String? category;
          if (data is Map) {
            category = data['category']?.toString();
          }
          
          notifications.add({
            'id': notif['id'] ?? '',
            'type': category ?? notif['type'] ?? 'system', // Use category from data, fallback to type
            'title': notif['title'] ?? '',
            'message': notif['message'] ?? '',
            'createdAt': notif['created_at'] ?? notif['createdAt'] ?? DateTime.now().toIso8601String(),
            'isRead': notif['is_read'] ?? notif['isRead'] ?? false,
            'status': notif['status'] ?? 'sent',
          });
        }
      }
      
      // PD-10: Fetch doctor/therapist messages
      try {
        final messagesResponse = await http.get(
          Uri.parse('${AppConfig.baseUrl.replaceFirst('/api/v1', '')}/api/v1/messages'),
          headers: {'Content-Type': 'application/json'},
        );
        
        if (messagesResponse.statusCode == 200) {
          final messagesData = jsonDecode(messagesResponse.body);
          final messages = List<Map<String, dynamic>>.from(messagesData['messages'] ?? []);
          
          // Convert doctor messages to notification format
          for (var message in messages) {
            notifications.add({
              'id': message['id'] ?? '',
              'type': 'doctor_message',
              'title': 'הודעה מ${message['doctor_name'] ?? 'רופא'}',
              'message': message['content'] ?? message['message'] ?? '',
              'createdAt': message['created_at'] ?? message['createdAt'] ?? DateTime.now().toIso8601String(),
              'isRead': message['is_read'] ?? message['isRead'] ?? false,
              'source': 'doctor',
              'doctorId': message['doctor_id'] ?? message['doctorId'],
              'doctorName': message['doctor_name'] ?? message['doctorName'],
            });
          }
        }
      } catch (e) {
        // Silently fail if messages endpoint doesn't exist yet
        print('Doctor messages endpoint not available: $e');
      }
      
      // Sort by creation date (newest first)
      notifications.sort((a, b) {
        final dateA = DateTime.tryParse(a['createdAt'] ?? '') ?? DateTime(1970);
        final dateB = DateTime.tryParse(b['createdAt'] ?? '') ?? DateTime(1970);
        return dateB.compareTo(dateA);
      });
      
      return notifications;
    } catch (e) {
      print('Error fetching notifications: $e');
      return [];
    }
  }

  // Mark notification as read
  static Future<bool> markAsRead(String notificationId) async {
    try {
      final response = await http.put(
        Uri.parse('${AppConfig.baseUrl.replaceFirst('/api/v1', '')}/api/v1/notifications/$notificationId/read'),
        headers: {'Content-Type': 'application/json'},
      );
      
      return response.statusCode == 200;
    } catch (e) {
      print('Error marking notification as read: $e');
      return false;
    }
  }
}
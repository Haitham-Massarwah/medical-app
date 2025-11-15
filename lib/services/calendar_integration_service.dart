import 'package:url_launcher/url_launcher.dart';

// FR-10: Email client and calendar integration service
class CalendarIntegrationService {
  // Detect current email client
  static Future<String> detectEmailClient(String userEmail) async {
    final domain = userEmail.split('@').last.toLowerCase();
    
    if (domain.contains('gmail')) {
      return 'gmail';
    } else if (domain.contains('outlook') || domain.contains('hotmail') || domain.contains('live')) {
      return 'outlook';
    } else {
      // Default to Outlook for business emails
      return 'outlook';
    }
  }
  
  // FR-10: Open calendar with appointment
  static Future<bool> openCalendarWithAppointment({
    required String userEmail,
    required String title,
    required DateTime startTime,
    required DateTime endTime,
    String? description,
    String? location,
  }) async {
    final client = await detectEmailClient(userEmail);
    
    if (client == 'gmail') {
      return await _openGoogleCalendar(
        title: title,
        startTime: startTime,
        endTime: endTime,
        description: description,
        location: location,
      );
    } else {
      return await _openOutlookCalendar(
        title: title,
        startTime: startTime,
        endTime: endTime,
        description: description,
        location: location,
      );
    }
  }
  
  static Future<bool> _openGoogleCalendar({
    required String title,
    required DateTime startTime,
    required DateTime endTime,
    String? description,
    String? location,
  }) async {
    // Format dates for Google Calendar
    final start = _formatGoogleCalendarDate(startTime);
    final end = _formatGoogleCalendarDate(endTime);
    
    final url = 'https://calendar.google.com/calendar/render?action=TEMPLATE'
        '&text=${Uri.encodeComponent(title)}'
        '&dates=$start/$end'
        '${description != null ? '&details=${Uri.encodeComponent(description)}' : ''}'
        '${location != null ? '&location=${Uri.encodeComponent(location)}' : ''}';
    
    return await _launchURL(url);
  }
  
  static Future<bool> _openOutlookCalendar({
    required String title,
    required DateTime startTime,
    required DateTime endTime,
    String? description,
    String? location,
  }) async {
    // Format dates for Outlook
    final start = startTime.toIso8601String();
    final end = endTime.toIso8601String();
    
    final url = 'https://outlook.office.com/calendar/0/deeplink/compose?'
        'subject=${Uri.encodeComponent(title)}'
        '&startdt=$start'
        '&enddt=$end'
        '${description != null ? '&body=${Uri.encodeComponent(description)}' : ''}'
        '${location != null ? '&location=${Uri.encodeComponent(location)}' : ''}';
    
    return await _launchURL(url);
  }
  
  static String _formatGoogleCalendarDate(DateTime dateTime) {
    return dateTime.toUtc().toIso8601String().replaceAll(RegExp(r'[-:]'), '').split('.')[0] + 'Z';
  }
  
  static Future<bool> _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
    return false;
  }
}





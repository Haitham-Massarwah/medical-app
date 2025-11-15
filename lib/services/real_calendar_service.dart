import 'dart:convert';
import 'package:http/http.dart' as http;

class RealCalendarService {
  static const String _baseUrl = 'https://www.googleapis.com/calendar/v3';
  static const String _outlookBaseUrl = 'https://graph.microsoft.com/v1.0/me/calendar';
  
  // Google Calendar OAuth URLs
  static String getGoogleAuthUrl() {
    const clientId = 'YOUR_GOOGLE_CLIENT_ID'; // Replace with real client ID
    const redirectUri = 'http://localhost:3000/auth/google/callback';
    const scope = 'https://www.googleapis.com/auth/calendar';
    
    return 'https://accounts.google.com/o/oauth2/v2/auth?'
        'client_id=$clientId&'
        'redirect_uri=$redirectUri&'
        'scope=$scope&'
        'response_type=code&'
        'access_type=offline';
  }
  
  // Outlook Calendar OAuth URLs
  static String getOutlookAuthUrl() {
    const clientId = 'YOUR_OUTLOOK_CLIENT_ID'; // Replace with real client ID
    const redirectUri = 'http://localhost:3000/auth/outlook/callback';
    const scope = 'https://graph.microsoft.com/calendars.readwrite';
    
    return 'https://login.microsoftonline.com/common/oauth2/v2.0/authorize?'
        'client_id=$clientId&'
        'redirect_uri=$redirectUri&'
        'scope=$scope&'
        'response_type=code&'
        'access_type=offline';
  }
  
  // Get Google Calendar events
  static Future<List<Map<String, dynamic>>> getGoogleEvents(String accessToken) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/events?calendarId=primary'),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data['items'] ?? []);
      }
      return [];
    } catch (e) {
      print('Error fetching Google events: $e');
      return [];
    }
  }
  
  // Get Outlook Calendar events
  static Future<List<Map<String, dynamic>>> getOutlookEvents(String accessToken) async {
    try {
      final response = await http.get(
        Uri.parse('$_outlookBaseUrl/events'),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data['value'] ?? []);
      }
      return [];
    } catch (e) {
      print('Error fetching Outlook events: $e');
      return [];
    }
  }
  
  // Create Google Calendar event
  static Future<bool> createGoogleEvent(String accessToken, Map<String, dynamic> event) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/events?calendarId=primary'),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(event),
      );
      
      return response.statusCode == 200;
    } catch (e) {
      print('Error creating Google event: $e');
      return false;
    }
  }
  
  // Create Outlook Calendar event
  static Future<bool> createOutlookEvent(String accessToken, Map<String, dynamic> event) async {
    try {
      final response = await http.post(
        Uri.parse('$_outlookBaseUrl/events'),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(event),
      );
      
      return response.statusCode == 201;
    } catch (e) {
      print('Error creating Outlook event: $e');
      return false;
    }
  }
  
  // Sync appointments to calendar
  static Future<bool> syncAppointmentToCalendar({
    required String calendarType,
    required String accessToken,
    required String title,
    required DateTime startTime,
    required DateTime endTime,
    required String description,
    required String location,
  }) async {
    final event = {
      'summary': title,
      'description': description,
      'location': location,
      'start': {
        'dateTime': startTime.toIso8601String(),
        'timeZone': 'Asia/Jerusalem',
      },
      'end': {
        'dateTime': endTime.toIso8601String(),
        'timeZone': 'Asia/Jerusalem',
      },
      'reminders': {
        'useDefault': false,
        'overrides': [
          {'method': 'email', 'minutes': 24 * 60}, // 1 day before
          {'method': 'popup', 'minutes': 30}, // 30 minutes before
        ],
      },
    };
    
    if (calendarType == 'google') {
      return await createGoogleEvent(accessToken, event);
    } else if (calendarType == 'outlook') {
      return await createOutlookEvent(accessToken, event);
    }
    
    return false;
  }
}









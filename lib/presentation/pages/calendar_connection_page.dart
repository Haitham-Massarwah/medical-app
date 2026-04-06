import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';

/// PD-05: Calendar Connection Page for Patients
/// Replaces Settings option in patient navigation
class CalendarConnectionPage extends StatefulWidget {
  const CalendarConnectionPage({super.key});

  @override
  State<CalendarConnectionPage> createState() => _CalendarConnectionPageState();
}

class _CalendarConnectionPageState extends State<CalendarConnectionPage> {
  final ApiService _apiService = ApiService();
  final AuthService _authService = AuthService();
  bool _isLoading = false;
  bool _isGoogleConnected = false;
  bool _isOutlookConnected = false;
  bool _isAppleConnected = false;
  bool _isDemo = false;

  @override
  void initState() {
    super.initState();
    _loadCalendarStatus();
  }

  Future<void> _loadCalendarStatus() async {
    setState(() => _isLoading = true);
    try {
      final me = await _authService.getCurrentUser();
      final user = me['data']?['user'] ?? {};
      final email = (user['email'] ?? '').toString().toLowerCase();
      _isDemo = email == 'demo.patient@medical-appointments.com';

      if (_isDemo) {
        _isGoogleConnected = true;
        _isOutlookConnected = false;
        _isAppleConnected = false;
      } else {
        final response = await _apiService.get('/calendar/status');
        if (response['success'] == true) {
          final data = response['data'] ?? {};
          _isGoogleConnected = data['google'] == true;
          _isOutlookConnected = data['outlook'] == true;
          _isAppleConnected = data['apple'] == true;
        }
      }
    } catch (e) {
      // Handle error silently for now
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _connectGoogleCalendar() async {
    setState(() => _isLoading = true);
    try {
      // Get Google Calendar OAuth URL from backend (authenticated)
      final response = await _apiService.get('/calendar/google/auth-url');
      if (response['success'] != true) {
        throw Exception(response['message'] ?? 'Failed to generate auth URL');
      }
      final data = response['data'] ?? {};
      final authUrl = (data['authUrl'] ?? '').toString();
      if (authUrl.isEmpty) {
        throw Exception('Missing authUrl');
      }
      
      // Open OAuth URL in browser
      if (await canLaunchUrl(Uri.parse(authUrl))) {
        await launchUrl(Uri.parse(authUrl), mode: LaunchMode.externalApplication);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('פתח את הדפדפן כדי להשלים את החיבור ל-Google Calendar'),
            backgroundColor: Colors.blue,
            duration: Duration(seconds: 5),
          ),
        );
      } else {
        throw Exception('לא ניתן לפתוח את הדפדפן');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('שגיאה בחיבור: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _connectOutlookCalendar() async {
    setState(() => _isLoading = true);
    try {
      // Get Outlook Calendar OAuth URL from backend (authenticated)
      final response = await _apiService.get('/calendar/outlook/auth-url');
      if (response['success'] != true) {
        throw Exception(response['message'] ?? 'Failed to generate auth URL');
      }
      final data = response['data'] ?? {};
      final authUrl = (data['authUrl'] ?? '').toString();
      if (authUrl.isEmpty) {
        throw Exception('Missing authUrl');
      }
      
      // Open OAuth URL in browser
      if (await canLaunchUrl(Uri.parse(authUrl))) {
        await launchUrl(Uri.parse(authUrl), mode: LaunchMode.externalApplication);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('פתח את הדפדפן כדי להשלים את החיבור ל-Outlook Calendar'),
            backgroundColor: Colors.blue,
            duration: Duration(seconds: 5),
          ),
        );
      } else {
        throw Exception('לא ניתן לפתוח את הדפדפן');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('שגיאה בחיבור: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _connectAppleCalendar() async {
    setState(() => _isLoading = true);
    try {
      // TODO: Implement Apple Calendar connection
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('חיבור ל-Apple Calendar - בפיתוח'),
          backgroundColor: Colors.orange,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('שגיאה בחיבור: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('חיבור ליומן'),
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'חבר את היומן שלך',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'חבר את היומן שלך כדי לקבל תזכורות על תורים',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 32),
                    _buildCalendarOption(
                      'Google Calendar',
                      'חבר את Google Calendar שלך',
                      Icons.calendar_today,
                      Colors.blue,
                      _isGoogleConnected,
                      _connectGoogleCalendar,
                    ),
                    const SizedBox(height: 16),
                    _buildCalendarOption(
                      'Outlook Calendar',
                      'חבר את Outlook Calendar שלך',
                      Icons.calendar_month,
                      Colors.orange,
                      _isOutlookConnected,
                      _connectOutlookCalendar,
                    ),
                    const SizedBox(height: 16),
                    _buildCalendarOption(
                      'Apple Calendar',
                      'חבר את Apple Calendar שלך',
                      Icons.calendar_view_day,
                      Colors.grey,
                      _isAppleConnected,
                      _connectAppleCalendar,
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildCalendarOption(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    bool isConnected,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 2,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.1),
          child: Icon(icon, color: color),
        ),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: isConnected
            ? const Icon(Icons.check_circle, color: Colors.green)
            : const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}





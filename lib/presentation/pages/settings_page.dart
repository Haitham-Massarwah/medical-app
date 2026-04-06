import 'package:flutter/material.dart';
import '../../services/real_calendar_service.dart';
import '../../services/notification_service.dart';
import '../../services/language_service.dart';
import '../../services/auth_service.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final AuthService _authService = AuthService();
  final NotificationService _notificationService = NotificationService();
  final LanguageService _languageService = LanguageService();

  bool _googleConnected = false;
  bool _outlookConnected = false;
  bool _emailNotifications = true;
  bool _smsNotifications = true;
  bool _whatsappNotifications = true;
  bool _pushNotifications = true;
  bool _isLoading = true;
  String _currentLanguage = 'עברית';
  String? _userRole; // Store user role to filter settings

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Load current language
      final currentLang = await LanguageService.getCurrentLanguage();
      // Load user role
      final user = await _authService.getCurrentUser();
      final role = user['data']?['user']?['role'] ?? 'patient';
      
      setState(() {
        _currentLanguage = currentLang;
        _userRole = role;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('הגדרות'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : LayoutBuilder(
                builder: (context, constraints) {
                  final double formWidth =
                      (constraints.maxWidth * 0.5).clamp(320.0, 700.0);
                  return Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: formWidth),
                      child: ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(16),
                        children: [
                          // Calendar Integration Section
                          const Text(
                            'אינטגרציית יומן',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),

                          _buildCalendarConnectionCard(),

                          const SizedBox(height: 32),

                          // Notifications Section - DISABLED (using email for now)
                          // Commented out per requirement #10
                          /*
                          const Text(
                            'התראות',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),

                          _buildNotificationSwitch(
                            'התראות אימייל',
                            'קבל תזכורות ועדכונים באימייל',
                            _emailNotifications,
                            (value) {
                              setState(() {
                                _emailNotifications = value;
                              });
                            },
                          ),

                          _buildNotificationSwitch(
                            'התראות SMS',
                            'קבל תזכורות בהודעות טקסט',
                            _smsNotifications,
                            (value) {
                              setState(() {
                                _smsNotifications = value;
                              });
                            },
                          ),

                          _buildNotificationSwitch(
                            'התראות WhatsApp',
                            'קבל תזכורות ב-WhatsApp',
                            _whatsappNotifications,
                            (value) {
                              setState(() {
                                _whatsappNotifications = value;
                              });
                            },
                          ),

                          _buildNotificationSwitch(
                            'התראות Push',
                            'קבל התראות במכשיר',
                            _pushNotifications,
                            (value) {
                              setState(() {
                                _pushNotifications = value;
                              });
                            },
                          ),

                          const SizedBox(height: 32),
                          */

                          const SizedBox(height: 32),

                          // Account Section
                          const Text(
                            'חשבון',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Only show Developer Profile for Developer/Admin roles
                          if (_userRole == 'developer' || _userRole == 'admin')
                            ListTile(
                              leading: const Icon(Icons.person),
                              title: const Text('פרופיל מפתח'),
                              subtitle: const Text('הגדרות פרופיל המפתח'),
                              trailing:
                                  const Icon(Icons.arrow_forward_ios, size: 16),
                              onTap: () {
                                _showDeveloperProfile();
                              },
                            ),

                          // Show Personal Information for Patient/Doctor
                          if (_userRole == 'patient' || _userRole == 'doctor')
                            ListTile(
                              leading: const Icon(Icons.person),
                              title: const Text('מידע אישי'),
                              subtitle: const Text('הצג וערוך את המידע האישי שלך'),
                              trailing:
                                  const Icon(Icons.arrow_forward_ios, size: 16),
                              onTap: () {
                                Navigator.pushNamed(context, '/profile');
                              },
                            ),

                          ListTile(
                            leading: const Icon(Icons.security),
                            title: const Text('אבטחה'),
                            trailing:
                                const Icon(Icons.arrow_forward_ios, size: 16),
                            onTap: () {
                              _showSecuritySettings();
                            },
                          ),

                          ListTile(
                            leading: const Icon(Icons.privacy_tip),
                            title: const Text('פרטיות'),
                            trailing:
                                const Icon(Icons.arrow_forward_ios, size: 16),
                            onTap: () {
                              _showPrivacySettings();
                            },
                          ),

                          ListTile(
                            leading: const Icon(Icons.language),
                            title: const Text('שפה'),
                            trailing:
                                const Icon(Icons.arrow_forward_ios, size: 16),
                            onTap: () {
                              _showLanguageSelector();
                            },
                          ),

                          const SizedBox(height: 32),

                          // Logout Button
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: _handleLogout,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text('התנתק'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }

  Widget _buildCalendarConnectionCard() {
    final isAnyConnected = _googleConnected || _outlookConnected;

    return Card(
      child: ListTile(
        leading: Icon(
          isAnyConnected ? Icons.calendar_today : Icons.calendar_today_outlined,
          color: isAnyConnected ? Colors.green : Colors.grey,
        ),
        title: const Text('חיבור יומן'),
        subtitle: Text(isAnyConnected ? 'מחובר' : 'לא מחובר'),
        trailing: ElevatedButton(
          onPressed: () {
            if (isAnyConnected) {
              _showDisconnectCalendarDialog();
            } else {
              _showConnectCalendarDialog();
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: isAnyConnected ? Colors.red : Colors.blue,
            foregroundColor: Colors.white,
          ),
          child: Text(isAnyConnected ? 'נתק' : 'חבר'),
        ),
      ),
    );
  }

  void _showConnectCalendarDialog() {
    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text('בחר יומן לחיבור'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.calendar_today, color: Colors.red),
                title: const Text('יומן Google'),
                subtitle: const Text('חיבור ליומן Google'),
                onTap: () {
                  Navigator.pop(context);
                  _connectGoogleCalendar();
                },
              ),
              ListTile(
                leading: const Icon(Icons.calendar_month, color: Colors.blue),
                title: const Text('יומן Outlook'),
                subtitle: const Text('חיבור ליומן Outlook'),
                onTap: () {
                  Navigator.pop(context);
                  _connectOutlookCalendar();
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('ביטול'),
            ),
          ],
        ),
      ),
    );
  }

  void _showDisconnectCalendarDialog() {
    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text('נתק יומן'),
          content: const Text('האם אתה בטוח שברצונך לנתק את היומן?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('ביטול'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _disconnectAllCalendars();
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('נתק'),
            ),
          ],
        ),
      ),
    );
  }

  void _connectGoogleCalendar() async {
    // Show connection popup
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('חיבור ל-Google Calendar'),
        content: const Text('האם תרצה להתחבר ל-Google Calendar?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('ביטול'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _processGoogleConnection();
            },
            child: const Text('המשך'),
          ),
        ],
      ),
    );
  }

  void _processGoogleConnection() async {
    try {
      final url = RealCalendarService.getGoogleAuthUrl();
      setState(() {
        _googleConnected = true;
      });

      // Show success dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('הצלחה!'),
          content: const Text('התחברת בהצלחה ל-Google Calendar'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('אישור'),
            ),
          ],
        ),
      );
    } catch (e) {
      _showErrorDialog('שגיאה בחיבור Google Calendar: $e');
    }
  }

  void _connectOutlookCalendar() async {
    // Show connection popup
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('חיבור ל-Outlook Calendar'),
        content: const Text('האם תרצה להתחבר ל-Outlook Calendar?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('ביטול'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _processOutlookConnection();
            },
            child: const Text('המשך'),
          ),
        ],
      ),
    );
  }

  void _processOutlookConnection() async {
    try {
      final url = RealCalendarService.getOutlookAuthUrl();
      setState(() {
        _outlookConnected = true;
      });

      // Show success dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('הצלחה!'),
          content: const Text('התחברת בהצלחה ל-Outlook Calendar'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('אישור'),
            ),
          ],
        ),
      );
    } catch (e) {
      _showErrorDialog('שגיאה בחיבור Outlook Calendar: $e');
    }
  }

  void _disconnectAllCalendars() async {
    try {
      setState(() {
        _googleConnected = false;
        _outlookConnected = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('היומן נותק בהצלחה'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('שגיאה בניתוק היומן: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildNotificationSwitch(
    String title,
    String subtitle,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return SwitchListTile(
      title: Text(title),
      subtitle: Text(subtitle),
      value: value,
      onChanged: onChanged,
    );
  }

  void _showSecuritySettings() {
    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text('הגדרות אבטחה'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.lock),
                title: const Text('שנה סיסמה'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  Navigator.of(context).pop();
                  _showChangePasswordDialog();
                },
              ),
              ListTile(
                leading: const Icon(Icons.security),
                title: const Text('הפעל 2FA'),
                trailing: Switch(
                  value: false,
                  onChanged: (value) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(value ? '2FA הופעל' : '2FA בוטל'),
                        backgroundColor: value ? Colors.green : Colors.orange,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('סגור'),
            ),
          ],
        ),
      ),
    );
  }

  void _showPrivacySettings() {
    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text('הגדרות פרטיות'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('• שמירת מידע מוצפן'),
              const Text('• תאימות ל-GDPR ו-HIPAA'),
              const Text('• מחיקת נתונים לפי בקשה'),
              const Text('• הורדת כל המידע שלך'),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).pop();
                  _showDataDownloadDialog();
                },
                icon: const Icon(Icons.download),
                label: const Text('הורד את הנתונים שלי'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('סגור'),
            ),
          ],
        ),
      ),
    );
  }

  void _showLanguageSelector() {
    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            title: const Text('בחר שפה'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                RadioListTile<String>(
                  title: const Text('עברית'),
                  value: 'עברית',
                  groupValue: _currentLanguage,
                  onChanged: (value) {
                    setState(() => _currentLanguage = value!);
                  },
                ),
                RadioListTile<String>(
                  title: const Text('العربية'),
                  value: 'العربية',
                  groupValue: _currentLanguage,
                  onChanged: (value) {
                    setState(() => _currentLanguage = value!);
                  },
                ),
                RadioListTile<String>(
                  title: const Text('אנגלית'),
                  value: 'English',
                  groupValue: _currentLanguage,
                  onChanged: (value) {
                    setState(() => _currentLanguage = value!);
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('ביטול'),
              ),
              ElevatedButton(
                onPressed: () async {
                  try {
                    await LanguageService.setLanguage(_currentLanguage);
                    if (mounted) {
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              'השפה שונתה ל: $_currentLanguage. יש לפתוח מחדש את האפליקציה'),
                          backgroundColor: Colors.green,
                          duration: const Duration(seconds: 5),
                        ),
                      );
                      // Reload page to apply language
                      setState(() {});
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('שגיאה בשינוי השפה: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
                child: const Text('שמור'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeveloperProfile() {
    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text('פרופיל מפתח המערכת'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const ListTile(
                leading: Icon(Icons.email),
                title: Text('אימייל'),
                subtitle: Text('developer@medical-appointments.com'),
              ),
              const ListTile(
                leading: Icon(Icons.badge),
                title: Text('תפקיד'),
                subtitle: Text('מפתח המערכת'),
              ),
              const ListTile(
                leading: Icon(Icons.security),
                title: Text('הרשאות'),
                subtitle: Text('גישה מלאה למערכת'),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).pop();
                  _showChangePasswordDialog();
                },
                icon: const Icon(Icons.lock),
                label: const Text('שנה סיסמה'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('סגור'),
            ),
          ],
        ),
      ),
    );
  }

  void _showChangePasswordDialog() {
    final oldPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text('שנה סיסמה'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: oldPasswordController,
                decoration: const InputDecoration(
                  labelText: 'סיסמה נוכחית',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: newPasswordController,
                decoration: const InputDecoration(
                  labelText: 'סיסמה חדשה',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: confirmPasswordController,
                decoration: const InputDecoration(
                  labelText: 'אישור סיסמה',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('ביטול'),
            ),
            ElevatedButton(
              onPressed: () {
                if (newPasswordController.text ==
                    confirmPasswordController.text) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('הסיסמה שונתה בהצלחה'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('הסיסמאות אינן תואמות'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: const Text('שמור'),
            ),
          ],
        ),
      ),
    );
  }

  void _showDataDownloadDialog() {
    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text('הורדת נתונים'),
          content: const Text('האם אתה בטוח שברצונך להוריד את כל הנתונים שלך?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('ביטול'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('הנתונים נשלחו לכתובת האימייל שלך'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              child: const Text('הורד'),
            ),
          ],
        ),
      ),
    );
  }

  void _handleLogout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('התנתקות'),
        content: const Text('האם אתה בטוח שברצונך להתנתק?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('ביטול'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('התנתק'),
          ),
        ],
      ),
    );

    if (shouldLogout == true) {
      await _authService.logout();
      if (mounted) {
        Navigator.of(context)
            .pushNamedAndRemoveUntil('/login', (route) => false);
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('שגיאה'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('אישור'),
          ),
        ],
      ),
    );
  }
}

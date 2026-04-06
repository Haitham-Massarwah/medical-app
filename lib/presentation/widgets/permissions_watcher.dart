import 'package:flutter/material.dart';
import '../../services/permissions_service.dart';
import '../../services/language_service.dart';
import '../../core/network/http_client.dart';

class PermissionsWatcher extends StatefulWidget {
  final Widget child;

  const PermissionsWatcher({super.key, required this.child});

  @override
  State<PermissionsWatcher> createState() => _PermissionsWatcherState();
}

class _PermissionsWatcherState extends State<PermissionsWatcher> {
  final PermissionsService _permissionsService = PermissionsService();
  Map<String, dynamic>? _lastPermissions;
  bool _isDialogVisible = false;
  bool _isRunning = true;

  @override
  void initState() {
    super.initState();
    _pollPermissions();
  }

  @override
  void dispose() {
    _isRunning = false;
    super.dispose();
  }

  Future<void> _pollPermissions() async {
    if (!_isRunning || !mounted) return;
    try {
      final token = await HttpClient().getAuthToken();
      if (token == null || token.isEmpty) {
        return;
      }
      final permissions = await _permissionsService.getPermissions();
      if (_lastPermissions != null) {
        final changes = _buildChanges(_lastPermissions!, permissions);
        if (changes.isNotEmpty && mounted && !_isDialogVisible) {
          _isDialogVisible = true;
          await _showChangeDialog(changes, permissions);
          _isDialogVisible = false;
        }
      }
      _lastPermissions = permissions;
    } catch (_) {
      // Ignore polling errors
    } finally {
      if (_isRunning && mounted) {
        Future.delayed(const Duration(seconds: 15), _pollPermissions);
      }
    }
  }

  List<String> _buildChanges(
    Map<String, dynamic> previous,
    Map<String, dynamic> current,
  ) {
    final changes = <String>[];
    for (final key in current.keys) {
      if (previous.containsKey(key) && previous[key] != current[key]) {
        changes.add(key);
      }
    }
    return changes;
  }

  Future<void> _showChangeDialog(
    List<String> changedKeys,
    Map<String, dynamic> currentPermissions,
  ) async {
    final language = await LanguageService.getCurrentLanguage();
    final title = {
      'עברית': 'שינוי בהרשאות מערכת',
      'العربية': 'تم تغيير صلاحيات النظام',
      'English': 'System Permissions Updated',
    }[language] ?? 'System Permissions Updated';

    final messages = changedKeys.map((key) {
      final enabled = (currentPermissions[key] == true);
      switch (key) {
        case 'doctor_payments_enabled':
          return {
            'עברית': 'תשלומים מרופאים: ${enabled ? "פעיל" : "כבוי"}',
            'العربية': 'مدفوعات الأطباء: ${enabled ? "مفعل" : "معطل"}',
            'English': 'Doctor payments: ${enabled ? "enabled" : "disabled"}',
          }[language] ?? 'תשלומים מרופאים עודכנו';
        case 'patient_payments_enabled':
          return {
            'עברית': 'תשלומים ממטופלים: ${enabled ? "פעיל" : "כבוי"}',
            'العربية': 'مدفوعات المرضى: ${enabled ? "مفعل" : "معطل"}',
            'English': 'Patient payments: ${enabled ? "enabled" : "disabled"}',
          }[language] ?? 'תשלומים ממטופלים עודכנו';
        case 'sms_enabled':
          return {
            'עברית': 'שירות SMS: ${enabled ? "פעיל" : "כבוי"}',
            'العربية': 'خدمة الرسائل النصية: ${enabled ? "مفعل" : "معطل"}',
            'English': 'SMS service: ${enabled ? "enabled" : "disabled"}',
          }[language] ?? 'שירות SMS עודכן';
        case 'email_notifications_enabled':
          return {
            'עברית': 'התראות אימייל: ${enabled ? "פעיל" : "כבוי"}',
            'العربية': 'إشعارات البريد الإلكتروني: ${enabled ? "مفعل" : "معطل"}',
            'English': 'Email notifications: ${enabled ? "enabled" : "disabled"}',
          }[language] ?? 'התראות אימייל עודכנו';
        default:
          return {
            'עברית': 'ההרשאות עודכנו',
            'العربية': 'تم تحديث الصلاحيات',
            'English': 'Permissions updated',
          }[language] ?? 'ההרשאות עודכנו';
      }
    }).join('\n');

    if (!mounted) return;
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(messages),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('אישור'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

import 'package:flutter/material.dart';
import '../../services/admin_service.dart';
import '../widgets/dashboard_sidebar.dart';
import '../../core/theme/app_colors.dart';

/// ADMIN PERMISSIONS MANAGEMENT
/// Manage system permissions and feature toggles
class AdminPermissions extends StatefulWidget {
  const AdminPermissions({Key? key}) : super(key: key);

  @override
  State<AdminPermissions> createState() => _AdminPermissionsState();
}

class _AdminPermissionsState extends State<AdminPermissions> {
  final AdminService _adminService = AdminService();
  String _currentRole = 'developer';
  
  // System permissions
  bool _doctorPaymentsEnabled = true;
  bool _patientPaymentsEnabled = true;
  bool _smsEnabled = true;
  bool _emailNotificationsEnabled = true;
  bool _isLoading = true;

  final Map<String, String> _roleNames = {
    'admin': 'מנהל מערכת',
    'doctor': 'רופא',
    'patient': 'מטופל',
  };

  final Map<String, String> _permissionNames = {
    'view_patients': 'צפייה במטופלים',
    'manage_appointments': 'ניהול תורים',
    'view_payments': 'צפייה בתשלומים',
    'book_appointments': 'הזמנת תורים',
    'view_history': 'צפייה בהיסטוריה',
    'manage_users': 'ניהול משתמשים',
    'manage_doctors': 'ניהול רופאים',
    'system_settings': 'הגדרות מערכת',
    'view_reports': 'צפייה בדוחות',
  };

  @override
  void initState() {
    super.initState();
    _loadPermissions();
  }

  Future<void> _loadPermissions() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final permissions = await _adminService.getPermissions();
      if (mounted) {
        setState(() {
          _doctorPaymentsEnabled = permissions['doctor_payments_enabled'] ?? true;
          _patientPaymentsEnabled = permissions['patient_payments_enabled'] ?? true;
          _smsEnabled = permissions['sms_enabled'] ?? true;
          _emailNotificationsEnabled = permissions['email_notifications_enabled'] ?? true;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _savePermissions() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final success = await _adminService.updatePermissions({
        'doctor_payments_enabled': _doctorPaymentsEnabled,
        'patient_payments_enabled': _patientPaymentsEnabled,
        'sms_enabled': _smsEnabled,
        'email_notifications_enabled': _emailNotificationsEnabled,
      });

      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('הרשאות עודכנו בהצלחה'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('שגיאה בעדכון הרשאות'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context);
    final isRTL = locale.languageCode == 'he' || locale.languageCode == 'ar';

    final routeArgs = ModalRoute.of(context)?.settings.arguments;
    if (routeArgs is Map<String, dynamic> && routeArgs['role'] is String) {
      _currentRole = routeArgs['role'] as String;
    }

    return Directionality(
      textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
      body: SafeArea(
        child: Row(
          children: [
            // Sidebar
            DashboardSidebar(currentRoute: '/admin-permissions', role: _currentRole),
            
            // Main Content
            Expanded(
              child: Container(
                color: AppColors.backgroundLight,
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : SingleChildScrollView(
                        padding: const EdgeInsets.all(30),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'ניהול הרשאות מערכת - System Permissions',
                                  style: TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                ElevatedButton.icon(
                                  onPressed: _savePermissions,
                                  icon: const Icon(Icons.save),
                                  label: const Text('שמור הרשאות'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 30),
                            
                            // Permissions Cards
                            _buildPermissionCard(
                              'תשלומים מרופאים - Doctor Payments',
                              'הפעל/כבה את אפשרות התשלומים מרופאים. כאשר כבוי, רופאים לא יצטרכו להזין פרטי כרטיס אשראי בעת הרשמה.',
                              Icons.payment,
                              Colors.purple,
                              _doctorPaymentsEnabled,
                              (value) {
                                setState(() {
                                  _doctorPaymentsEnabled = value;
                                });
                              },
                            ),
                            const SizedBox(height: 20),
                            
                            _buildPermissionCard(
                              'תשלומים ממטופלים - Patient Payments',
                              'הפעל/כבה את אפשרות התשלומים ממטופלים.',
                              Icons.payment,
                              Colors.blue,
                              _patientPaymentsEnabled,
                              (value) {
                                setState(() {
                                  _patientPaymentsEnabled = value;
                                });
                              },
                            ),
                            const SizedBox(height: 20),
                            
                            _buildPermissionCard(
                              'שירות SMS - SMS Service',
                              'הפעל/כבה את שירות ה-SMS במערכת.',
                              Icons.sms,
                              Colors.orange,
                              _smsEnabled,
                              (value) {
                                setState(() {
                                  _smsEnabled = value;
                                });
                              },
                            ),
                            const SizedBox(height: 20),
                            
                            _buildPermissionCard(
                              'התראות אימייל - Email Notifications',
                              'הפעל/כבה את התראות האימייל במערכת.',
                              Icons.email,
                              Colors.teal,
                              _emailNotificationsEnabled,
                              (value) {
                                setState(() {
                                  _emailNotificationsEnabled = value;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    ),
    );
  }

  Widget _buildPermissionCard(
    String title,
    String description,
    IconData icon,
    Color color,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: color.withOpacity(0.3), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 32),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: color,
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color, width: 2),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserCard(Map<String, dynamic> user) {
    final roleColor = user['role'] == 'admin'
        ? Colors.red
        : user['role'] == 'doctor'
            ? Colors.green
            : Colors.blue;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: roleColor.withOpacity(0.2),
                      child: Text(
                        user['name'][0],
                        style: TextStyle(
                          color: roleColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user['name'],
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          user['email'],
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: roleColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _roleNames[user['role']] ?? user['role'],
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'הרשאות:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: (user['permissions'] as List).map((perm) {
                return Chip(
                  label: Text(
                    _permissionNames[perm] ?? perm,
                    style: const TextStyle(fontSize: 12),
                  ),
                  backgroundColor: roleColor.withOpacity(0.1),
                  side: BorderSide(color: roleColor),
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: () => _editPermissions(user),
                  icon: const Icon(Icons.edit, size: 18),
                  label: const Text('ערוך הרשאות'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: roleColor,
                    foregroundColor: Colors.white,
                  ),
                ),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  onPressed: () => _changeRole(user),
                  icon: const Icon(Icons.swap_horiz, size: 18),
                  label: const Text('שנה תפקיד'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _addUser() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('הוסף משתמש'),
        content: const Text('פונקציונליות זו תתווסף בקרוב'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('סגור'),
          ),
        ],
      ),
    );
  }

  void _editPermissions(Map<String, dynamic> user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('ערוך הרשאות - ${user['name']}'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: _permissionNames.keys.map((perm) {
              final isChecked = (user['permissions'] as List).contains(perm);
              return CheckboxListTile(
                title: Text(_permissionNames[perm] ?? perm),
                value: isChecked,
                onChanged: (value) {
                  setState(() {
                    if (value == true) {
                      (user['permissions'] as List).add(perm);
                    } else {
                      (user['permissions'] as List).remove(perm);
                    }
                  });
                  Navigator.pop(context);
                  _editPermissions(user); // Reopen to show changes
                },
              );
            }).toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('סגור'),
          ),
        ],
      ),
    );
  }

  void _changeRole(Map<String, dynamic> user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('שנה תפקיד - ${user['name']}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: _roleNames.keys.map((role) {
            return RadioListTile<String>(
              title: Text(_roleNames[role] ?? role),
              value: role,
              groupValue: user['role'],
              onChanged: (value) {
                Navigator.pop(context);
                setState(() {
                  user['role'] = value;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('תפקיד שונה ל: ${_roleNames[value] ?? value}'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ביטול'),
          ),
        ],
      ),
    );
  }

  void _refreshData() {
    setState(() {
      // Refresh from backend
    });
  }

  void _exportReport() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('מייצא דוח הרשאות...'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _sendPaymentReminders() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('נשלחו תזכורות לכל הרופאים עם תשלומים ממתינים'),
        backgroundColor: Colors.purple,
      ),
    );
  }
}


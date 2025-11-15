import 'package:flutter/material.dart';

/// ADMIN PERMISSIONS MANAGEMENT
/// Manage user roles and system access permissions
class AdminPermissions extends StatefulWidget {
  const AdminPermissions({Key? key}) : super(key: key);

  @override
  State<AdminPermissions> createState() => _AdminPermissionsState();
}

class _AdminPermissionsState extends State<AdminPermissions> {
  final List<Map<String, dynamic>> _users = [
    {
      'name': 'ד"ר אברהם כהן',
      'email': 'doctor@test.com',
      'role': 'doctor',
      'permissions': ['view_patients', 'manage_appointments', 'view_payments'],
    },
    {
      'name': 'לקוח ישראלי',
      'email': 'customer@test.com',
      'role': 'patient',
      'permissions': ['book_appointments', 'view_history'],
    },
  ];

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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ניהול הרשאות'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _addUser,
            tooltip: 'הוסף משתמש',
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Quick Stats
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'מנהלים',
                      '1',
                      Colors.red,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildStatCard(
                      'רופאים',
                      _users.where((u) => u['role'] == 'doctor').length.toString(),
                      Colors.green,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildStatCard(
                      'מטופלים',
                      _users.where((u) => u['role'] == 'patient').length.toString(),
                      Colors.blue,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              // Users List
              const Text(
                'משתמשים והרשאות',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              
              ..._users.map((user) => _buildUserCard(user)),
            ],
          ),
        ),
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


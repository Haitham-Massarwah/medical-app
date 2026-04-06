import 'package:flutter/material.dart';
import '../../services/admin_service.dart';
import '../../services/api_service.dart';
import '../widgets/dashboard_sidebar.dart';
import '../../core/theme/app_colors.dart';

class UsersListPage extends StatefulWidget {
  const UsersListPage({super.key});

  @override
  State<UsersListPage> createState() => _UsersListPageState();
}

class _UsersListPageState extends State<UsersListPage> {
  final AdminService _adminService = AdminService();
  List<Map<String, dynamic>> _users = [];
  bool _isLoading = true;
  String _selectedFilter = 'כל המשתמשים';
  String _currentRole = 'developer';

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() => _isLoading = true);
    try {
      final users = await _adminService.getUsers();
      setState(() {
        _users = users;
        _isLoading = false;
      });
    } catch (_) {
      setState(() {
        _users = [];
        _isLoading = false;
      });
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
              DashboardSidebar(currentRoute: '/users-list', role: _currentRole),
              Expanded(
                child: Container(
                  color: AppColors.backgroundLight,
                  padding: const EdgeInsets.all(30),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'ניהול משתמשים',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          const Text('סינון: '),
                          const SizedBox(width: 8),
                          DropdownButton<String>(
                            value: _selectedFilter,
                            items: ['כל המשתמשים', 'מטופלים', 'רופאים', 'מנהלים', 'מפתחים'].map((filter) {
                              return DropdownMenuItem(
                                value: filter,
                                child: Text(filter),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedFilter = value!;
                              });
                            },
                          ),
                          const Spacer(),
                          ElevatedButton.icon(
                            onPressed: _showCreateUserDialog,
                            icon: const Icon(Icons.add),
                            label: const Text('הוסף משתמש'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: _isLoading
                            ? const Center(child: CircularProgressIndicator())
                            : _buildUsersList(),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUsersList() {
    final filteredUsers = _users.where((user) {
      switch (_selectedFilter) {
        case 'מטופלים':
          return user['role'] == 'patient';
        case 'רופאים':
          return user['role'] == 'doctor';
        case 'מנהלים':
          return user['role'] == 'admin';
        case 'מפתחים':
          return user['role'] == 'developer';
        default:
          return true;
      }
    }).toList();

    return ListView.builder(
      itemCount: filteredUsers.length,
      itemBuilder: (context, index) {
        final user = filteredUsers[index];
        final firstName = (user['first_name'] ?? '').toString();
        final lastName = (user['last_name'] ?? '').toString();
        final displayName = (user['name'] ?? '$firstName $lastName').toString().trim();
        final email = (user['email'] ?? '').toString();
        final phone = (user['phone'] ?? '').toString();
        final role = (user['role'] ?? 'user').toString();
        final createdAt = (user['created_at'] ?? '').toString();

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: _getRoleColor(role),
              child: Icon(
                _getRoleIcon(role),
                color: Colors.white,
              ),
            ),
            title: Text(displayName.isEmpty ? email : displayName),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('$email • ${phone.isEmpty ? '-' : phone}'),
                if (role == 'doctor' && user['specialty'] != null)
                  Text('${user['specialty']}'),
                if (user['city'] != null) Text('${user['city']}'),
                if (createdAt.isNotEmpty) Text('נוצר: $createdAt'),
              ],
            ),
            trailing: PopupMenuButton(
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'view',
                  child: Text('צפה בפרטים'),
                ),
                const PopupMenuItem(
                  value: 'edit',
                  child: Text('ערוך'),
                ),
                if (_currentRole == 'developer')
                  const PopupMenuItem(
                    value: 'change_role',
                    child: Text('שנה תפקיד'),
                  ),
                PopupMenuItem(
                  value: 'toggle_status',
                  child: Text(
                    (user['is_active'] == false)
                        ? ((user['role'] == 'doctor' || user['role'] == 'patient') ? 'אשר' : 'הפעל')
                        : 'השבת',
                  ),
                ),
              ],
              onSelected: (value) => _handleUserAction(value, user),
            ),
          ),
        );
      },
    );
  }

  Color _getRoleColor(String role) {
    switch (role) {
      case 'patient':
        return Colors.blue;
      case 'doctor':
        return Colors.green;
      case 'admin':
        return Colors.deepPurple;
      case 'developer':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getRoleIcon(String role) {
    switch (role) {
      case 'patient':
        return Icons.person;
      case 'doctor':
        return Icons.medical_services;
      case 'admin':
        return Icons.admin_panel_settings;
      case 'developer':
        return Icons.admin_panel_settings;
      default:
        return Icons.person;
    }
  }

  void _handleUserAction(String action, Map<String, dynamic> user) {
    switch (action) {
      case 'view':
        _showUserDetails(user);
        break;
      case 'edit':
        _editUser(user);
        break;
      case 'change_role':
        _changeRole(user);
        break;
      case 'toggle_status':
        _deactivateUser(user);
        break;
    }
  }

  void _showUserDetails(Map<String, dynamic> user) {
    final firstName = (user['first_name'] ?? '').toString();
    final lastName = (user['last_name'] ?? '').toString();
    final displayName = (user['name'] ?? '$firstName $lastName').toString().trim();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('פרטי ${displayName.isEmpty ? user['email'] ?? '' : displayName}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('שם: ${displayName.isEmpty ? user['email'] ?? '' : displayName}'),
            Text('אימייל: ${user['email']}'),
            Text('טלפון: ${user['phone']}'),
            Text('תפקיד: ${_getRoleLabel(user['role'])}'),
            Text('עיר: ${user['city']}'),
            if (user['role'] == 'doctor')
              Text('התמחות: ${user['specialty']}'),
            Text('נוצר: ${user['created_at']}'),
            Text('סטטוס: ${user['status']}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('סגור'),
          ),
        ],
      ),
    );
  }

  void _editUser(Map<String, dynamic> user) {
    // TODO: Implement edit user functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('עריכת משתמש - בפיתוח')),
    );
  }

  void _changeRole(Map<String, dynamic> user) {
    final roles = ['patient', 'doctor', 'admin', 'developer'];
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('שנה תפקיד משתמש'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: roles.map((role) {
            return RadioListTile<String>(
              title: Text(_getRoleLabel(role)),
              value: role,
              groupValue: user['role']?.toString(),
              onChanged: (value) async {
                if (value == null) return;
                Navigator.pop(context);
                final success = await _adminService.updateUserRole(
                  user['id'].toString(),
                  value,
                );
                if (success && mounted) {
                  setState(() {
                    user['role'] = value;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('תפקיד המשתמש עודכן'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } else if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('שגיאה בעדכון תפקיד המשתמש'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('סגור'),
          ),
        ],
      ),
    );
  }

  void _deactivateUser(Map<String, dynamic> user) {
    final isActive = user['is_active'] != false;
    final newStatus = !isActive;
    final isApproval = newStatus == true && (user['role'] == 'doctor' || user['role'] == 'patient');
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isApproval ? 'אישור משתמש' : (newStatus ? 'הפעלת משתמש' : 'השבתת משתמש')),
        content: Text('האם אתה בטוח שברצונך לשנות את הסטטוס של ${user['name'] ?? user['email']}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('ביטול'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              final success = await _adminService.updateUserStatus(
                user['id'].toString(),
                newStatus,
              );
              if (success && mounted) {
                setState(() {
                  user['is_active'] = newStatus;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(newStatus ? 'המשתמש הופעל' : 'המשתמש הושבת'),
                    backgroundColor: Colors.green,
                  ),
                );
              } else if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('שגיאה בעדכון סטטוס המשתמש'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: newStatus ? Colors.green : Colors.red,
            ),
            child: Text(isApproval ? 'אשר' : (newStatus ? 'הפעל' : 'השבת')),
          ),
        ],
      ),
    );
  }

  String _getRoleLabel(String role) {
    switch (role) {
      case 'patient':
        return 'מטופל';
      case 'doctor':
        return 'רופא';
      case 'admin':
        return 'מנהל';
      case 'developer':
        return 'מפתח';
      case 'receptionist':
        return 'קליטה / דלפן';
      default:
        return 'משתמש';
    }
  }

  void _showCreateUserDialog() {
    final firstNameController = TextEditingController();
    final lastNameController = TextEditingController();
    final emailController = TextEditingController();
    final phoneController = TextEditingController();
    final passwordController = TextEditingController();
    String selectedRole = 'patient';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('הוסף משתמש חדש'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: firstNameController,
                  decoration: const InputDecoration(
                    labelText: 'שם פרטי',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: lastNameController,
                  decoration: const InputDecoration(
                    labelText: 'שם משפחה',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    labelText: 'אימייל',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: phoneController,
                  decoration: const InputDecoration(
                    labelText: 'טלפון',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: passwordController,
                  decoration: const InputDecoration(
                    labelText: 'סיסמה',
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedRole,
                  decoration: const InputDecoration(
                    labelText: 'תפקיד',
                    border: OutlineInputBorder(),
                  ),
                  items: ['patient', 'doctor'].map((role) {
                    return DropdownMenuItem(
                      value: role,
                      child: Text(_getRoleLabel(role)),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setDialogState(() {
                        selectedRole = value;
                      });
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('ביטול'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (firstNameController.text.isEmpty ||
                    lastNameController.text.isEmpty ||
                    emailController.text.isEmpty ||
                    passwordController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('אנא מלא את כל השדות הנדרשים'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                Navigator.of(context).pop();
                try {
                  final apiService = ApiService();
                  final Map<String, dynamic> response;
                  if (selectedRole == 'receptionist') {
                    response = await apiService.post('/users', {
                      'first_name': firstNameController.text,
                      'last_name': lastNameController.text,
                      'email': emailController.text,
                      'phone': phoneController.text,
                      'password': passwordController.text,
                      'role': 'receptionist',
                    });
                  } else {
                    response = await apiService.post('/auth/register', {
                      'first_name': firstNameController.text,
                      'last_name': lastNameController.text,
                      'email': emailController.text,
                      'phone': phoneController.text,
                      'password': passwordController.text,
                      'role': selectedRole,
                    });
                  }

                  if (response['success'] == true && mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('משתמש נוצר בהצלחה'),
                        backgroundColor: Colors.green,
                      ),
                    );
                    await _loadUsers();
                  } else {
                    throw Exception(response['message'] ?? 'Failed to create user');
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('שגיאה ביצירת משתמש: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              child: const Text('צור'),
            ),
          ],
        ),
      ),
    );
  }
}









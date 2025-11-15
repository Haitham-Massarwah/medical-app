import 'package:flutter/material.dart';

class UsersListPage extends StatefulWidget {
  const UsersListPage({super.key});

  @override
  State<UsersListPage> createState() => _UsersListPageState();
}

class _UsersListPageState extends State<UsersListPage> {
  List<Map<String, dynamic>> _users = [];
  bool _isLoading = true;
  String _selectedFilter = 'כל המשתמשים';

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() => _isLoading = true);
    
    // Mock users data
    await Future.delayed(const Duration(seconds: 1));
    
    setState(() {
      _users = [
        {
          'id': '1',
          'name': 'שרה לוי',
          'email': 'sara@example.com',
          'phone': '050-1234567',
          'role': 'patient',
          'city': 'תל אביב',
          'created_at': '2024-01-15',
          'status': 'active',
        },
        {
          'id': '2',
          'name': 'דוד כהן',
          'email': 'david@example.com',
          'phone': '052-9876543',
          'role': 'patient',
          'city': 'ירושלים',
          'created_at': '2024-01-20',
          'status': 'active',
        },
        {
          'id': '3',
          'name': 'ד"ר יוסי כהן',
          'email': 'dr.yossi@example.com',
          'phone': '054-5555555',
          'role': 'doctor',
          'city': 'חיפה',
          'specialty': 'רפואה פנימית',
          'created_at': '2024-01-10',
          'status': 'active',
        },
        {
          'id': '4',
          'name': 'ד"ר רחל אברהם',
          'email': 'dr.rachel@example.com',
          'phone': '053-4444444',
          'role': 'doctor',
          'city': 'באר שבע',
          'specialty': 'רפואת ילדים',
          'created_at': '2024-01-12',
          'status': 'active',
        },
        {
          'id': '5',
          'name': 'מנהל מערכת',
          'email': 'admin@example.com',
          'phone': '050-0000000',
          'role': 'developer',
          'city': 'תל אביב',
          'created_at': '2024-01-01',
          'status': 'active',
        },
      ];
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('ניהול משתמשים'),
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
        ),
        body: Column(
          children: [
            // Filter section
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Text('סינון: '),
                  const SizedBox(width: 8),
                  DropdownButton<String>(
                    value: _selectedFilter,
                    items: ['כל המשתמשים', 'מטופלים', 'רופאים', 'מפתחים'].map((filter) {
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
                ],
              ),
            ),
            
            // Users list
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _buildUsersList(),
            ),
          ],
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
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: _getRoleColor(user['role']),
              child: Icon(
                _getRoleIcon(user['role']),
                color: Colors.white,
              ),
            ),
            title: Text(user['name']),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${user['email']} • ${user['phone']}'),
                if (user['role'] == 'doctor')
                  Text('${user['specialty']} • ${user['city']}'),
                if (user['role'] == 'patient')
                  Text('${user['city']}'),
                Text('נוצר: ${user['created_at']}'),
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
                const PopupMenuItem(
                  value: 'deactivate',
                  child: Text('השבת'),
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
      case 'deactivate':
        _deactivateUser(user);
        break;
    }
  }

  void _showUserDetails(Map<String, dynamic> user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('פרטי ${user['name']}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('שם: ${user['name']}'),
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

  void _deactivateUser(Map<String, dynamic> user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('השבתת משתמש'),
        content: Text('האם אתה בטוח שברצונך להשבית את ${user['name']}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('ביטול'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: Implement deactivate user
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${user['name']} הושבת')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('השבת'),
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
      case 'developer':
        return 'מפתח';
      default:
        return 'משתמש';
    }
  }
}









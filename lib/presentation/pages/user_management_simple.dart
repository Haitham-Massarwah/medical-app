import 'package:flutter/material.dart';

class UserManagementPage extends StatefulWidget {
  const UserManagementPage({super.key});

  @override
  State<UserManagementPage> createState() => _UserManagementPageState();
}

class _UserManagementPageState extends State<UserManagementPage> {
  final List<Map<String, dynamic>> _users = [
    {
      'id': '1',
      'name': 'ד"ר יוסי כהן',
      'email': 'doctor@medicalapp.com',
      'role': 'רופא',
      'status': 'פעיל',
      'lastLogin': '2024-01-15 10:30',
      'phone': '050-1234567',
    },
    {
      'id': '2',
      'name': 'שרה לוי',
      'email': 'customer@medicalapp.com',
      'role': 'מטופל',
      'status': 'פעיל',
      'lastLogin': '2024-01-15 09:15',
      'phone': '052-9876543',
    },
    {
      'id': '3',
      'name': 'ד"ר דוד ישראלי',
      'email': 'doctor2@medicalapp.com',
      'role': 'רופא',
      'status': 'לא פעיל',
      'lastLogin': '2024-01-14 16:45',
      'phone': '053-5555555',
    },
    {
      'id': '4',
      'name': 'מפתח המערכת',
      'email': 'developer@medicalapp.com',
      'role': 'מפתח',
      'status': 'פעיל',
      'lastLogin': '2024-01-15 11:00',
      'phone': '054-1111111',
    },
  ];

  String _selectedFilter = 'כל המשתמשים';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ניהול משתמשים'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add),
            onPressed: () => _addUser(),
            tooltip: 'הוסף משתמש',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Filter Section
            _buildFilterSection(),
            
            const SizedBox(height: 24),
            
            // Users List
            _buildUsersList(),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'סינון משתמשים',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              children: [
                _buildFilterChip('כל המשתמשים'),
                _buildFilterChip('רופא'),
                _buildFilterChip('מטופל'),
                _buildFilterChip('מפתח'),
                _buildFilterChip('פעיל'),
                _buildFilterChip('לא פעיל'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = _selectedFilter == label;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedFilter = label;
        });
      },
      selectedColor: Colors.orange.withOpacity(0.2),
      checkmarkColor: Colors.orange,
    );
  }

  Widget _buildUsersList() {
    final filteredUsers = _getFilteredUsers();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'רשימת משתמשים (${filteredUsers.length})',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ...filteredUsers.map((user) => _buildUserCard(user)).toList(),
      ],
    );
  }

  List<Map<String, dynamic>> _getFilteredUsers() {
    if (_selectedFilter == 'כל המשתמשים') return _users;
    if (_selectedFilter == 'פעיל') return _users.where((user) => user['status'] == 'פעיל').toList();
    if (_selectedFilter == 'לא פעיל') return _users.where((user) => user['status'] == 'לא פעיל').toList();
    return _users.where((user) => user['role'] == _selectedFilter).toList();
  }

  Widget _buildUserCard(Map<String, dynamic> user) {
    Color statusColor = user['status'] == 'פעיל' ? Colors.green : Colors.red;
    Color roleColor = user['role'] == 'מפתח' ? Colors.red :
                     user['role'] == 'רופא' ? Colors.blue :
                     Colors.green;

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
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user['name'],
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        user['email'],
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: roleColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        user['role'],
                        style: TextStyle(
                          color: roleColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        user['status'],
                        style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.phone, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Text(user['phone']),
                const SizedBox(width: 16),
                Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Text('כניסה אחרונה: ${user['lastLogin']}'),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _editUser(user),
                    icon: const Icon(Icons.edit, size: 16),
                    label: const Text('ערוך'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _viewUser(user),
                    icon: const Icon(Icons.visibility, size: 16),
                    label: const Text('צפה'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _toggleUserStatus(user),
                    icon: Icon(
                      user['status'] == 'פעיל' ? Icons.block : Icons.check_circle,
                      size: 16,
                    ),
                    label: Text(user['status'] == 'פעיל' ? 'חסום' : 'פעיל'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: user['status'] == 'פעיל' ? Colors.red : Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
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
        title: const Text('הוסף משתמש חדש'),
        content: const Text('פתיחת טופס הוספת משתמש...\n\n• פרטי משתמש\n• בחירת תפקיד\n• הגדרת הרשאות\n• יצירת חשבון'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ביטול'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showUserAdded();
            },
            child: const Text('הוסף משתמש'),
          ),
        ],
      ),
    );
  }

  void _showUserAdded() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('המשתמש נוסף בהצלחה!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _editUser(Map<String, dynamic> user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ערוך משתמש'),
        content: Text('עריכת פרטי ${user['name']}...\n\n• עדכון פרטים אישיים\n• שינוי תפקיד\n• עדכון הרשאות\n• שינוי סטטוס'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ביטול'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showUserUpdated();
            },
            child: const Text('עדכן'),
          ),
        ],
      ),
    );
  }

  void _showUserUpdated() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('המשתמש עודכן בהצלחה!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _viewUser(Map<String, dynamic> user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('פרטי משתמש - ${user['name']}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('שם: ${user['name']}'),
            Text('אימייל: ${user['email']}'),
            Text('תפקיד: ${user['role']}'),
            Text('סטטוס: ${user['status']}'),
            Text('טלפון: ${user['phone']}'),
            Text('כניסה אחרונה: ${user['lastLogin']}'),
            const SizedBox(height: 16),
            const Text('פעילויות אחרונות:'),
            const Text('• התחברות למערכת'),
            const Text('• עדכון פרופיל'),
            const Text('• ביצוע פעולות'),
          ],
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

  void _toggleUserStatus(Map<String, dynamic> user) {
    final newStatus = user['status'] == 'פעיל' ? 'לא פעיל' : 'פעיל';
    final action = user['status'] == 'פעיל' ? 'חסימה' : 'הפעלה';
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('$action משתמש'),
        content: Text('האם אתה בטוח שברצונך $action את ${user['name']}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ביטול'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                user['status'] = newStatus;
              });
              Navigator.pop(context);
              _showStatusChanged(action);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: user['status'] == 'פעיל' ? Colors.red : Colors.green,
              foregroundColor: Colors.white,
            ),
            child: Text(action),
          ),
        ],
      ),
    );
  }

  void _showStatusChanged(String action) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('המשתמש $action בהצלחה!'),
        backgroundColor: Colors.green,
      ),
    );
  }
}








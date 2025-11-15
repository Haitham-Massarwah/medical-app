import 'package:flutter/material.dart';
import 'doctor_registration_fullscreen.dart';

class UserManagementEnhancedPage extends StatefulWidget {
  const UserManagementEnhancedPage({super.key});

  @override
  State<UserManagementEnhancedPage> createState() => _UserManagementEnhancedPageState();
}

class _UserManagementEnhancedPageState extends State<UserManagementEnhancedPage> {
  String _selectedGroup = 'doctors';
  String _selectedStatus = 'all';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  // Mock data for doctors/therapists
  final List<Map<String, dynamic>> _doctors = [
    {
      'id': '1',
      'name': 'ד"ר יוסי כהן',
      'email': 'yossi.cohen@example.com',
      'specialty': 'קרדיולוגיה',
      'status': 'active',
      'phone': '050-1234567',
      'license': 'MD12345',
      'joinDate': '2023-01-15',
      'lastLogin': '2024-01-15',
      'appointments': 156,
      'rating': 4.8,
    },
    {
      'id': '2',
      'name': 'ד"ר שרה לוי',
      'email': 'sarah.levi@example.com',
      'specialty': 'רפואת עיניים',
      'status': 'active',
      'phone': '050-2345678',
      'license': 'MD23456',
      'joinDate': '2023-02-20',
      'lastLogin': '2024-01-14',
      'appointments': 203,
      'rating': 4.9,
    },
    {
      'id': '3',
      'name': 'ד"ר דוד ישראלי',
      'email': 'david.israeli@example.com',
      'specialty': 'אורתופדיה',
      'status': 'blocked',
      'phone': '050-3456789',
      'license': 'MD34567',
      'joinDate': '2023-03-10',
      'lastLogin': '2024-01-10',
      'appointments': 89,
      'rating': 4.7,
    },
  ];

  // Mock data for customers
  final List<Map<String, dynamic>> _customers = [
    {
      'id': '1',
      'name': 'אבי כהן',
      'email': 'avi.cohen@example.com',
      'phone': '050-1111111',
      'status': 'active',
      'joinDate': '2023-04-15',
      'lastLogin': '2024-01-15',
      'appointments': 12,
      'totalSpent': 3600,
    },
    {
      'id': '2',
      'name': 'מיכל לוי',
      'email': 'michal.levi@example.com',
      'phone': '050-2222222',
      'status': 'active',
      'joinDate': '2023-05-20',
      'lastLogin': '2024-01-14',
      'appointments': 8,
      'totalSpent': 2400,
    },
    {
      'id': '3',
      'name': 'יוסי ישראלי',
      'email': 'yossi.israeli@example.com',
      'phone': '050-3333333',
      'status': 'blocked',
      'joinDate': '2023-06-10',
      'lastLogin': '2024-01-10',
      'appointments': 3,
      'totalSpent': 900,
    },
  ];

  // Available specialties
  final List<String> _availableSpecialties = [
    'קרדיולוגיה',
    'רפואת עיניים',
    'אורתופדיה',
    'רפואת ילדים',
    'נוירולוגיה',
    'דרמטולוגיה',
    'גינקולוגיה',
    'אורולוגיה',
    'פסיכיאטריה',
    'פיזיותרפיה',
  ];

  List<String> _selectedSpecialties = [];

  @override
  void initState() {
    super.initState();
    _selectedSpecialties = List.from(_availableSpecialties);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ניהול משתמשים'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddUserDialog,
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _showSpecialtyManagement,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilterSection(),
          _buildUserList(),
        ],
      ),
    );
  }

  Widget _buildFilterSection() {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Group selection
            Row(
              children: [
                Expanded(
                  child: RadioListTile<String>(
                    title: const Text('רופאים/מטפלים'),
                    value: 'doctors',
                    groupValue: _selectedGroup,
                    onChanged: (value) {
                      setState(() {
                        _selectedGroup = value!;
                      });
                    },
                  ),
                ),
                Expanded(
                  child: RadioListTile<String>(
                    title: const Text('לקוחות'),
                    value: 'customers',
                    groupValue: _selectedGroup,
                    onChanged: (value) {
                      setState(() {
                        _selectedGroup = value!;
                      });
                    },
                  ),
                ),
              ],
            ),
            const Divider(),
            // Search and status filters
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      hintText: 'חיפוש משתמש...',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedStatus,
                    decoration: const InputDecoration(
                      labelText: 'סטטוס',
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      const DropdownMenuItem(value: 'all', child: Text('הכל')),
                      const DropdownMenuItem(value: 'active', child: Text('פעיל')),
                      const DropdownMenuItem(value: 'blocked', child: Text('חסום')),
                      const DropdownMenuItem(value: 'inactive', child: Text('לא פעיל')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedStatus = value!;
                      });
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserList() {
    final users = _selectedGroup == 'doctors' ? _doctors : _customers;
    final filteredUsers = users.where((user) {
      final matchesSearch = _searchQuery.isEmpty ||
          user['name'].toLowerCase().contains(_searchQuery.toLowerCase()) ||
          user['email'].toLowerCase().contains(_searchQuery.toLowerCase());
      
      final matchesStatus = _selectedStatus == 'all' || user['status'] == _selectedStatus;
      
      return matchesSearch && matchesStatus;
    }).toList();

    return Expanded(
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: filteredUsers.length,
        itemBuilder: (context, index) {
          final user = filteredUsers[index];
          return _buildUserCard(user);
        },
      ),
    );
  }

  Widget _buildUserCard(Map<String, dynamic> user) {
    final isDoctor = _selectedGroup == 'doctors';
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: user['status'] == 'active' ? Colors.green : Colors.red,
                  child: Text(
                    user['name'].split(' ')[1][0],
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 16),
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
                      if (isDoctor) ...[
                        Text('התמחות: ${user['specialty']}'),
                        Text('רישיון: ${user['license']}'),
                      ],
                      Text('טלפון: ${user['phone']}'),
                      Text('תאריך הצטרפות: ${user['joinDate']}'),
                      Text('כניסה אחרונה: ${user['lastLogin']}'),
                      if (isDoctor) ...[
                        Text('תורים: ${user['appointments']}'),
                        Text('דירוג: ${user['rating']}'),
                      ] else ...[
                        Text('תורים: ${user['appointments']}'),
                        Text('סכום הוצאות: ${user['totalSpent']}₪'),
                      ],
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: user['status'] == 'active' ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    user['status'] == 'active' ? 'פעיל' : 'חסום',
                    style: TextStyle(
                      color: user['status'] == 'active' ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildActionButton('צפייה', Icons.visibility, Colors.blue, () => _viewUser(user)),
                _buildActionButton('עריכה', Icons.edit, Colors.orange, () => _editUser(user)),
                _buildActionButton(
                  user['status'] == 'active' ? 'חסימה' : 'שחרור',
                  user['status'] == 'active' ? Icons.block : Icons.check_circle,
                  user['status'] == 'active' ? Colors.red : Colors.green,
                  () => _toggleUserStatus(user),
                ),
                _buildActionButton('מחיקה', Icons.delete, Colors.red, () => _deleteUser(user)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(String label, IconData icon, Color color, VoidCallback onPressed) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 16),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }

  void _viewUser(Map<String, dynamic> user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('פרטי ${user['name']}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('שם: ${user['name']}'),
              Text('אימייל: ${user['email']}'),
              Text('טלפון: ${user['phone']}'),
              Text('סטטוס: ${user['status'] == 'active' ? 'פעיל' : 'חסום'}'),
              Text('תאריך הצטרפות: ${user['joinDate']}'),
              Text('כניסה אחרונה: ${user['lastLogin']}'),
              if (_selectedGroup == 'doctors') ...[
                Text('התמחות: ${user['specialty']}'),
                Text('רישיון: ${user['license']}'),
                Text('תורים: ${user['appointments']}'),
                Text('דירוג: ${user['rating']}'),
              ] else ...[
                Text('תורים: ${user['appointments']}'),
                Text('סכום הוצאות: ${user['totalSpent']}₪'),
              ],
            ],
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

  void _editUser(Map<String, dynamic> user) {
    final nameController = TextEditingController(text: user['name']);
    final emailController = TextEditingController(text: user['email']);
    final phoneController = TextEditingController(text: user['phone']);
    String selectedSpecialty = user['specialty'] ?? '';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('עריכת ${user['name']}'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'שם מלא'),
              ),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'אימייל'),
              ),
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(labelText: 'טלפון'),
              ),
              if (_selectedGroup == 'doctors') ...[
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedSpecialty.isNotEmpty ? selectedSpecialty : null,
                  decoration: const InputDecoration(labelText: 'התמחות'),
                  items: _selectedSpecialties.map((specialty) => DropdownMenuItem(
                    value: specialty,
                    child: Text(specialty),
                  )).toList(),
                  onChanged: (value) {
                    selectedSpecialty = value!;
                  },
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ביטול'),
          ),
          ElevatedButton(
            onPressed: () {
              // Update user logic here
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('המשתמש עודכן בהצלחה')),
              );
            },
            child: const Text('שמור'),
          ),
        ],
      ),
    );
  }

  void _toggleUserStatus(Map<String, dynamic> user) {
    final newStatus = user['status'] == 'active' ? 'blocked' : 'active';
    final action = newStatus == 'active' ? 'שחרור' : 'חסימה';
    
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
              // Toggle status logic here
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('המשתמש ${action} בהצלחה')),
              );
            },
            child: Text(action),
          ),
        ],
      ),
    );
  }

  void _deleteUser(Map<String, dynamic> user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('מחיקת משתמש'),
        content: Text('האם אתה בטוח שברצונך למחוק את ${user['name']}? פעולה זו לא ניתנת לביטול.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ביטול'),
          ),
          ElevatedButton(
            onPressed: () {
              // Delete user logic here
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('המשתמש נמחק בהצלחה')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('מחק'),
          ),
        ],
      ),
    );
  }

  void _showAddUserDialog() {
    if (_selectedGroup == 'doctors') {
      // Navigate to full-screen doctor registration
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const DoctorRegistrationFullscreenPage(),
        ),
      );
    } else {
      // Show simple dialog for customers
      final nameController = TextEditingController();
      final emailController = TextEditingController();
      final phoneController = TextEditingController();

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('הוספת לקוח'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'שם מלא',
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
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('ביטול'),
            ),
            ElevatedButton(
              onPressed: () {
                // Add customer logic here
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('הלקוח נוסף בהצלחה')),
                );
              },
              child: const Text('הוסף'),
            ),
          ],
        ),
      );
    }
  }

  void _showSpecialtyManagement() {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('ניהול התמחויות'),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('התמחויות זמינות:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                ..._selectedSpecialties.map((specialty) => ListTile(
                  title: Text(specialty),
                  trailing: IconButton(
                    icon: const Icon(Icons.remove_circle, color: Colors.red),
                    onPressed: () {
                      setState(() {
                        _selectedSpecialties.remove(specialty);
                      });
                    },
                  ),
                )).toList(),
                const Divider(),
                const Text('הוספת התמחות חדשה:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: const InputDecoration(
                          hintText: 'שם התמחות',
                          border: OutlineInputBorder(),
                        ),
                        onSubmitted: (value) {
                          if (value.isNotEmpty && !_selectedSpecialties.contains(value)) {
                            setState(() {
                              _selectedSpecialties.add(value);
                            });
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.add_circle, color: Colors.green),
                      onPressed: () {
                        // Add new specialty logic
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _selectedSpecialties = List.from(_availableSpecialties);
                    });
                  },
                  child: const Text('שחזר לרשימה המקורית'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('סגור'),
            ),
            ElevatedButton(
              onPressed: () {
                // Save specialties logic here
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('התמחויות נשמרו בהצלחה')),
                );
              },
              child: const Text('שמור'),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

class PatientManagementPage extends StatefulWidget {
  const PatientManagementPage({super.key});

  @override
  State<PatientManagementPage> createState() => _PatientManagementPageState();
}

class _PatientManagementPageState extends State<PatientManagementPage> {
  final List<Map<String, dynamic>> _patients = [
    {
      'id': '1',
      'name': 'יוסי כהן',
      'phone': '050-1234567',
      'email': 'yossi@example.com',
      'idNumber': '123456789',
      'birthDate': '1985-03-15',
      'lastVisit': '2024-01-10',
      'status': 'active',
      'appointments': 12,
    },
    {
      'id': '2',
      'name': 'שרה לוי',
      'phone': '052-9876543',
      'email': 'sara@example.com',
      'idNumber': '987654321',
      'birthDate': '1990-07-22',
      'lastVisit': '2024-01-08',
      'status': 'active',
      'appointments': 8,
    },
    {
      'id': '3',
      'name': 'דוד ישראלי',
      'phone': '054-5555555',
      'email': 'david@example.com',
      'idNumber': '456789123',
      'birthDate': '1978-11-05',
      'lastVisit': '2024-01-05',
      'status': 'inactive',
      'appointments': 5,
    },
    {
      'id': '4',
      'name': 'רחל אברהם',
      'phone': '050-7777777',
      'email': 'rachel@example.com',
      'idNumber': '789123456',
      'birthDate': '1992-09-18',
      'lastVisit': '2024-01-12',
      'status': 'active',
      'appointments': 15,
    },
    {
      'id': '5',
      'name': 'משה כהן',
      'phone': '052-3333333',
      'email': 'moshe@example.com',
      'idNumber': '321654987',
      'birthDate': '1988-12-03',
      'lastVisit': '2023-12-28',
      'status': 'inactive',
      'appointments': 3,
    },
    {
      'id': '6',
      'name': 'אסתר גולד',
      'phone': '054-1111111',
      'email': 'ester@example.com',
      'idNumber': '654321987',
      'birthDate': '1983-04-25',
      'lastVisit': '2024-01-14',
      'status': 'active',
      'appointments': 20,
    },
  ];

  String _selectedStatus = 'כל המטופלים';
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ניהול מטופלים'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _addPatient,
            tooltip: 'הוסף מטופל',
          ),
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: _exportPatients,
            tooltip: 'ייצא נתונים',
          ),
        ],
      ),
      body: Column(
        children: [
          // Filters
          Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          decoration: const InputDecoration(
                            labelText: 'חיפוש מטופל',
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
                          items: const [
                            DropdownMenuItem(value: 'כל המטופלים', child: Text('כל המטופלים')),
                            DropdownMenuItem(value: 'active', child: Text('פעיל')),
                            DropdownMenuItem(value: 'inactive', child: Text('לא פעיל')),
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
          ),
          // Patients List
          Expanded(
            child: ListView.builder(
              itemCount: _getFilteredPatients().length,
              itemBuilder: (context, index) {
                final patient = _getFilteredPatients()[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: patient['status'] == 'active' ? Colors.green : Colors.grey,
                      child: Text(
                        patient['name'].toString().split(' ').first[0],
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                    title: Text(
                      patient['name'],
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('טלפון: ${patient['phone']}'),
                        Text('תאריך לידה: ${patient['birthDate']}'),
                        Text('ביקור אחרון: ${patient['lastVisit']}'),
                        Text('מספר תורים: ${patient['appointments']}'),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => _editPatient(patient),
                          tooltip: 'עריכה',
                        ),
                        IconButton(
                          icon: const Icon(Icons.visibility, color: Colors.green),
                          onPressed: () => _viewPatient(patient),
                          tooltip: 'צפייה',
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deletePatient(patient),
                          tooltip: 'מחיקה',
                        ),
                      ],
                    ),
                    isThreeLine: true,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _getFilteredPatients() {
    return _patients.where((patient) {
      final matchesSearch = _searchQuery.isEmpty ||
          patient['name'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
          patient['phone'].toString().contains(_searchQuery) ||
          patient['email'].toString().toLowerCase().contains(_searchQuery.toLowerCase());
      
      final matchesStatus = _selectedStatus == 'כל המטופלים' ||
          patient['status'] == _selectedStatus;
      
      return matchesSearch && matchesStatus;
    }).toList();
  }

  void _addPatient() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('הוסף מטופל חדש'),
        content: const Text('פונקציונליות הוספת מטופל חדש תהיה זמינה בקרוב'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('אישור'),
          ),
        ],
      ),
    );
  }

  void _editPatient(Map<String, dynamic> patient) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('עריכת מטופל: ${patient['name']}'),
        content: const Text('פונקציונליות עריכת מטופל תהיה זמינה בקרוב'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('אישור'),
          ),
        ],
      ),
    );
  }

  void _viewPatient(Map<String, dynamic> patient) {
    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: Text('פרטי מטופל: ${patient['name']}'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('שם: ${patient['name']}'),
                Text('טלפון: ${patient['phone']}'),
                Text('אימייל: ${patient['email']}'),
                Text('מספר זהות: ${patient['idNumber']}'),
                Text('תאריך לידה: ${patient['birthDate']}'),
                Text('ביקור אחרון: ${patient['lastVisit']}'),
                Text('סטטוס: ${patient['status'] == 'active' ? 'פעיל' : 'לא פעיל'}'),
                Text('מספר תורים: ${patient['appointments']}'),
              ],
            ),
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

  void _deletePatient(Map<String, dynamic> patient) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('מחיקת מטופל'),
        content: Text('האם אתה בטוח שברצונך למחוק את המטופל ${patient['name']}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('ביטול'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _patients.removeWhere((p) => p['id'] == patient['id']);
              });
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('המטופל ${patient['name']} נמחק בהצלחה'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            child: const Text('מחק'),
          ),
        ],
      ),
    );
  }

  void _exportPatients() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ייצוא נתונים'),
        content: const Text('פונקציונליות ייצוא נתונים תהיה זמינה בקרוב'),
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








import 'package:flutter/material.dart';
import '../../services/patient_service.dart';
import 'create_patient_page.dart';

class PatientManagementPage extends StatefulWidget {
  const PatientManagementPage({super.key});

  @override
  State<PatientManagementPage> createState() => _PatientManagementPageState();
}

class _PatientManagementPageState extends State<PatientManagementPage> {
  final PatientService _patientService = PatientService();
  List<Map<String, dynamic>> _patients = [];
  bool _isLoading = true;

  String _selectedStatus = 'כל המטופלים';
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadPatients();
  }

  Future<void> _loadPatients() async {
    setState(() => _isLoading = true);
    try {
      final patients = await _patientService.getPatients(search: _searchQuery.isEmpty ? null : _searchQuery);
      setState(() {
        _patients = patients.map((p) => {
          'id': p['id']?.toString() ?? '',
          'name': '${p['first_name'] ?? ''} ${p['last_name'] ?? ''}'.trim(),
          'phone': p['phone'] ?? '',
          'email': p['email'] ?? '',
          'first_name': p['first_name'] ?? '',
          'last_name': p['last_name'] ?? '',
        }).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('שגיאה בטעינת מטופלים: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

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
                            _loadPatients();
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
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _getFilteredPatients().isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.people_outline, size: 64, color: Colors.grey),
                            SizedBox(height: 16),
                            Text(
                              'אין מטופלים',
                              style: TextStyle(fontSize: 18, color: Colors.grey),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
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
                        if (patient['phone'] != null && patient['phone'].toString().isNotEmpty)
                          Text('טלפון: ${patient['phone']}'),
                        if (patient['email'] != null && patient['email'].toString().isNotEmpty)
                          Text('אימייל: ${patient['email']}'),
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
                    isThreeLine: false,
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
    // Search is handled by API, so we just filter by status if needed
    if (_selectedStatus == 'כל המטופלים') {
      return _patients;
    }
    // Note: Status filtering would need to be added to the API or handled here
    return _patients;
  }

  void _addPatient() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CreatePatientPage()),
    ).then((_) {
      _loadPatients(); // Reload patients after creating a new one
    });
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








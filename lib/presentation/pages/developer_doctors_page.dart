import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../services/api_service.dart';

class DeveloperDoctorsPage extends StatefulWidget {
  const DeveloperDoctorsPage({super.key});

  @override
  State<DeveloperDoctorsPage> createState() => _DeveloperDoctorsPageState();
}

class _DeveloperDoctorsPageState extends State<DeveloperDoctorsPage> {
  final ApiService _apiService = ApiService();
  List<Map<String, dynamic>> _doctors = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String _statusFilter = 'all'; // all, active, inactive
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadDoctors();
  }

  Future<void> _loadDoctors() async {
    setState(() => _isLoading = true);
    try {
      final response = await _apiService.get('/doctors');
      if (response['success'] == true) {
        setState(() {
          _doctors = List<Map<String, dynamic>>.from(response['data'] ?? []);
          _isLoading = false;
        });
      } else {
        throw Exception(response['message'] ?? 'Failed to load doctors');
      }
    } catch (e) {
      // If API fails, show sample data so page isn't blank
      setState(() {
        _doctors = [
          {
            'id': '1',
            'name': 'ד"ר אברהם כהן',
            'email': 'doctor@test.com',
            'phone': '050-1111111',
            'specialty': 'רופא משפחה',
            'licenseNumber': '12345',
            'is_active': true,
            'address': 'תל אביב, רחוב רוטשילד 23',
            'totalPatients': 45,
            'totalAppointments': 123,
          },
          {
            'id': '2',
            'name': 'ד"ר שרה לוי',
            'email': 'sara.doctor@test.com',
            'phone': '052-2222222',
            'specialty': 'קרדיולוג',
            'licenseNumber': '67890',
            'is_active': true,
            'address': 'ירושלים, רחוב יפו 35',
            'totalPatients': 67,
            'totalAppointments': 234,
          },
          {
            'id': '3',
            'name': 'ד"ר דוד ישראלי',
            'email': 'david.doctor@test.com',
            'phone': '054-3333333',
            'specialty': 'אורתופד',
            'licenseNumber': '11111',
            'is_active': true,
            'address': 'חיפה, שדרות המגינים 47',
            'totalPatients': 52,
            'totalAppointments': 189,
          },
        ];
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('מציג נתונים לדוגמה (שגיאת API: $e)'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  List<Map<String, dynamic>> get _filteredDoctors {
    return _doctors.where((doctor) {
      final matchesSearch = _searchQuery.isEmpty ||
          (doctor['name']?.toString().toLowerCase() ?? '').contains(_searchQuery.toLowerCase()) ||
          (doctor['email']?.toString().toLowerCase() ?? '').contains(_searchQuery.toLowerCase()) ||
          (doctor['specialty']?.toString().toLowerCase() ?? '').contains(_searchQuery.toLowerCase());
      
      final isActive = (doctor['is_active'] as bool?) ?? false;
      final matchesStatus = _statusFilter == 'all' ||
          (isActive && _statusFilter == 'active') ||
          (!isActive && _statusFilter == 'inactive');
      
      return matchesSearch && matchesStatus;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('ניהול רופאים'),
          backgroundColor: Colors.green.shade700,
          foregroundColor: Colors.white,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _loadDoctors,
              tooltip: 'רענן',
            ),
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => Navigator.pushNamed(context, '/create-doctor'),
              tooltip: 'רופא חדש',
            ),
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              // Filters
              _buildFilters(),
              // Doctors List
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _filteredDoctors.isEmpty
                        ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.medical_services, size: 64, color: Colors.grey),
                              const SizedBox(height: 16),
                              Text(
                                'לא נמצאו רופאים',
                                style: TextStyle(fontSize: 18, color: Colors.grey),
                              ),
                            ],
                          ),
                          )
                        : ListView.builder(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.all(16),
                            itemCount: _filteredDoctors.length,
                            itemBuilder: (context, index) {
                              return _buildDoctorCard(_filteredDoctors[index]);
                            },
                          ),
                ),
              ],
            ),
        ),
      ),
    );
  }

  Widget _buildFilters() {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'חיפוש רופא...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _statusFilter,
                    decoration: const InputDecoration(
                      labelText: 'סטטוס',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'all', child: Text('הכל')),
                      DropdownMenuItem(value: 'active', child: Text('פעיל')),
                      DropdownMenuItem(value: 'inactive', child: Text('לא פעיל')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _statusFilter = value!;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Text('סה"כ: ${_filteredDoctors.length} רופאים'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDoctorCard(Map<String, dynamic> doctor) {
    final isActive = doctor['is_active'] == true;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: isActive ? Colors.green : Colors.grey,
          child: Text(
            doctor['name']?.toString().substring(0, 1).toUpperCase() ?? '?',
            style: const TextStyle(color: Colors.white),
          ),
        ),
        title: Text(
          doctor['name'] ?? 'ללא שם',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('התמחות: ${doctor['specialty'] ?? 'לא צוין'}'),
            Text('אימייל: ${doctor['email'] ?? 'לא צוין'}'),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isActive ? Colors.green.shade100 : Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    isActive ? 'פעיל' : 'לא פעיל',
                    style: TextStyle(
                      color: isActive ? Colors.green.shade700 : Colors.grey.shade700,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) => _handleDoctorAction(value, doctor),
          itemBuilder: (context) => [
            const PopupMenuItem(value: 'edit', child: Text('ערוך')),
            PopupMenuItem(
              value: isActive ? 'deactivate' : 'activate',
              child: Text(isActive ? 'השבת' : 'הפעל'),
            ),
            const PopupMenuItem(value: 'enable_payment', child: Text('אפשר תשלום אונליין (מפתח)')),
            const PopupMenuItem(value: 'invite', child: Text('הזמנה ללקוח')), 
            const PopupMenuItem(value: 'view', child: Text('צפה בפרטים')),
            const PopupMenuItem(value: 'delete', child: Text('מחק')),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailRow('טלפון', doctor['phone'] ?? 'לא צוין'),
                _buildDetailRow('עיר', doctor['city'] ?? 'לא צוין'),
                _buildDetailRow('תאריך רישום', doctor['created_at']?.toString().split('T')[0] ?? 'לא צוין'),
                _buildDetailRow('מספר רישיון', doctor['license_number'] ?? 'לא צוין'),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => _handleDoctorAction('edit', doctor),
                      icon: const Icon(Icons.edit, size: 18),
                      label: const Text('ערוך'),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => _handleDoctorAction(isActive ? 'deactivate' : 'activate', doctor),
                      icon: Icon(isActive ? Icons.block : Icons.check_circle, size: 18),
                      label: Text(isActive ? 'השבת' : 'הפעל'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isActive ? Colors.orange : Colors.green,
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => _handleDoctorAction('delete', doctor),
                      icon: const Icon(Icons.delete, size: 18),
                      label: const Text('מחק'),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  void _handleDoctorAction(String action, Map<String, dynamic> doctor) async {
    switch (action) {
      case 'edit':
        Navigator.pushNamed(
          context,
          '/create-doctor',
          arguments: {'doctor': doctor},
        );
        break;
      case 'activate':
      case 'deactivate':
        await _toggleDoctorStatus(doctor, action == 'activate');
        break;
      case 'enable_payment':
        await _enableOnlinePaymentsForDoctor(doctor);
        break;
      case 'invite':
        await _inviteCustomerFlow(doctor);
        break;
      case 'view':
        _showDoctorDetails(doctor);
        break;
      case 'delete':
        await _deleteDoctor(doctor);
        break;
    }
  }

  Future<void> _enableOnlinePaymentsForDoctor(Map<String, dynamic> doctor) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('developer_can_edit_payment', true);
      await prefs.setBool('payments_enabled_doctor_current', true);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('תשלום אונליין הופעל עבור ${doctor['name'] ?? 'הרופא'}')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('שגיאה: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _inviteCustomerFlow(Map<String, dynamic> doctor) async {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('שלח הזמנה ללקוח'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameController, decoration: const InputDecoration(labelText: 'שם לקוח')),
            TextField(controller: emailController, decoration: const InputDecoration(labelText: 'אימייל')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('ביטול')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('שלח')),
        ],
      ),
    );

    if (confirmed != true) return;
    final customerName = nameController.text.trim();
    final customerEmail = emailController.text.trim();
    if (customerEmail.isEmpty) return;

    // Generate simple signed-like token (placeholder). Real impl: backend JWT with expiry
    final Map<String, dynamic> payload = {
      'doctorId': doctor['id'] ?? 'doctor-current',
      'email': customerEmail,
      'name': customerName,
      'ts': DateTime.now().millisecondsSinceEpoch,
    };
    final token = base64UrlEncode(utf8.encode(jsonEncode(payload)));
    final link = 'http://localhost:3000/register?token=$token';

    try {
      await _apiService.post('/test/email', {
        'to': customerEmail,
        'subject': 'הזמנה להצטרפות למערכת התורים',
        'template': 'invite',
        'data': {
          'customerName': customerName,
          'doctorName': doctor['name'] ?? 'הרופא שלך',
          'link': link,
        }
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('ההזמנה נשלחה בהצלחה')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('שליחת ההזמנה נכשלה: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _toggleDoctorStatus(Map<String, dynamic> doctor, bool activate) async {
    try {
      final response = await _apiService.patch(
        '/doctors/${doctor['id']}',
        {'is_active': activate},
      );
      
      if (response['success'] == true) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(activate ? 'רופא הופעל בהצלחה' : 'רופא הושבת בהצלחה'),
              backgroundColor: Colors.green,
            ),
          );
          _loadDoctors();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('שגיאה: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _deleteDoctor(Map<String, dynamic> doctor) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('מחיקת רופא'),
        content: Text('האם אתה בטוח שברצונך למחוק את ${doctor['name']}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('ביטול'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('מחק'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final response = await _apiService.delete('/doctors/${doctor['id']}');
        if (response['success'] == true) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('רופא נמחק בהצלחה'),
                backgroundColor: Colors.green,
              ),
            );
            _loadDoctors();
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('שגיאה: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void _showDoctorDetails(Map<String, dynamic> doctor) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(doctor['name'] ?? 'פרטי רופא'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('אימייל', doctor['email'] ?? 'לא צוין'),
              _buildDetailRow('טלפון', doctor['phone'] ?? 'לא צוין'),
              _buildDetailRow('התמחות', doctor['specialty'] ?? 'לא צוין'),
              _buildDetailRow('עיר', doctor['city'] ?? 'לא צוין'),
              _buildDetailRow('מספר רישיון', doctor['license_number'] ?? 'לא צוין'),
              _buildDetailRow('סטטוס', doctor['is_active'] == true ? 'פעיל' : 'לא פעיל'),
              if (doctor['created_at'] != null)
                _buildDetailRow('תאריך רישום', doctor['created_at'].toString().split('T')[0]),
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
              Navigator.pop(context);
              _handleDoctorAction('edit', doctor);
            },
            child: const Text('ערוך'),
          ),
        ],
      ),
    );
  }
}


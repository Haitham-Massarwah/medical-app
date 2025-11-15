import 'package:flutter/material.dart';

class DoctorsListPage extends StatefulWidget {
  const DoctorsListPage({super.key});

  @override
  State<DoctorsListPage> createState() => _DoctorsListPageState();
}

class _DoctorsListPageState extends State<DoctorsListPage> {
  List<Map<String, dynamic>> _doctors = [];
  bool _isLoading = true;
  String _selectedSpecialty = 'כל ההתמחויות';

  @override
  void initState() {
    super.initState();
    _loadDoctors();
  }

  Future<void> _loadDoctors() async {
    setState(() => _isLoading = true);
    
    // Mock doctors data
    await Future.delayed(const Duration(seconds: 1));
    
    setState(() {
      _doctors = [
        {
          'id': '1',
          'name': 'ד"ר יוסי כהן',
          'email': 'dr.yossi@example.com',
          'phone': '054-5555555',
          'specialty': 'רפואה פנימית',
          'city': 'חיפה',
          'consultation_fee': 300.0,
          'years_experience': 15,
          'license_number': '12345',
          'status': 'active',
          'monthly_payment': 1000.0,
          'payment_method': 'כרטיס אשראי',
        },
        {
          'id': '2',
          'name': 'ד"ר רחל אברהם',
          'email': 'dr.rachel@example.com',
          'phone': '053-4444444',
          'specialty': 'רפואת ילדים',
          'city': 'באר שבע',
          'consultation_fee': 250.0,
          'years_experience': 12,
          'license_number': '67890',
          'status': 'active',
          'monthly_payment': 800.0,
          'payment_method': 'העברה בנקאית',
        },
        {
          'id': '3',
          'name': 'ד"ר מיכל לוי',
          'email': 'dr.michal@example.com',
          'phone': '052-3333333',
          'specialty': 'גינקולוגיה',
          'city': 'תל אביב',
          'consultation_fee': 400.0,
          'years_experience': 20,
          'license_number': '11111',
          'status': 'active',
          'monthly_payment': 1200.0,
          'payment_method': 'כרטיס אשראי',
        },
        {
          'id': '4',
          'name': 'ד"ר אמיר דוד',
          'email': 'dr.amir@example.com',
          'phone': '051-2222222',
          'specialty': 'אורתופדיה',
          'city': 'ירושלים',
          'consultation_fee': 350.0,
          'years_experience': 18,
          'license_number': '22222',
          'status': 'inactive',
          'monthly_payment': 900.0,
          'payment_method': 'מזומן',
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
          title: const Text('ניהול רופאים'),
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
        ),
        body: Column(
          children: [
            // Filter section
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Text('התמחות: '),
                  const SizedBox(width: 8),
                  Expanded(
                    child: DropdownButton<String>(
                      value: _selectedSpecialty,
                      isExpanded: true,
                      items: [
                        'כל ההתמחויות',
                        'רפואה פנימית',
                        'רפואת ילדים',
                        'גינקולוגיה',
                        'אורתופדיה',
                      ].map((specialty) {
                        return DropdownMenuItem(
                          value: specialty,
                          child: Text(specialty),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedSpecialty = value!;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
            
            // Doctors list
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _buildDoctorsList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDoctorsList() {
    final filteredDoctors = _doctors.where((doctor) {
      if (_selectedSpecialty == 'כל ההתמחויות') return true;
      return doctor['specialty'] == _selectedSpecialty;
    }).toList();

    return ListView.builder(
      itemCount: filteredDoctors.length,
      itemBuilder: (context, index) {
        final doctor = filteredDoctors[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: doctor['status'] == 'active' ? Colors.green : Colors.red,
              child: const Icon(
                Icons.medical_services,
                color: Colors.white,
              ),
            ),
            title: Text(doctor['name']),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${doctor['specialty']} • ${doctor['city']}'),
                Text('${doctor['email']} • ${doctor['phone']}'),
                Text('שכר ייעוץ: ₪${doctor['consultation_fee']} • ניסיון: ${doctor['years_experience']} שנים'),
                Text('תשלום חודשי: ₪${doctor['monthly_payment']} • ${doctor['payment_method']}'),
                Text('סטטוס: ${doctor['status'] == 'active' ? 'פעיל' : 'לא פעיל'}'),
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
                  value: 'payments',
                  child: Text('תשלומים'),
                ),
                const PopupMenuItem(
                  value: 'toggle_status',
                  child: Text('החלף סטטוס'),
                ),
              ],
              onSelected: (value) => _handleDoctorAction(value, doctor),
            ),
          ),
        );
      },
    );
  }

  void _handleDoctorAction(String action, Map<String, dynamic> doctor) {
    switch (action) {
      case 'view':
        _showDoctorDetails(doctor);
        break;
      case 'edit':
        _editDoctor(doctor);
        break;
      case 'payments':
        _showDoctorPayments(doctor);
        break;
      case 'toggle_status':
        _toggleDoctorStatus(doctor);
        break;
    }
  }

  void _showDoctorDetails(Map<String, dynamic> doctor) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('פרטי ${doctor['name']}'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('שם: ${doctor['name']}'),
              Text('אימייל: ${doctor['email']}'),
              Text('טלפון: ${doctor['phone']}'),
              Text('התמחות: ${doctor['specialty']}'),
              Text('עיר: ${doctor['city']}'),
              Text('שכר ייעוץ: ₪${doctor['consultation_fee']}'),
              Text('שנות ניסיון: ${doctor['years_experience']}'),
              Text('מספר רישיון: ${doctor['license_number']}'),
              Text('תשלום חודשי: ₪${doctor['monthly_payment']}'),
              Text('שיטת תשלום: ${doctor['payment_method']}'),
              Text('סטטוס: ${doctor['status'] == 'active' ? 'פעיל' : 'לא פעיל'}'),
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
    );
  }

  void _editDoctor(Map<String, dynamic> doctor) {
    // TODO: Implement edit doctor functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('עריכת רופא - בפיתוח')),
    );
  }

  void _showDoctorPayments(Map<String, dynamic> doctor) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('תשלומים - ${doctor['name']}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('תשלום חודשי: ₪${doctor['monthly_payment']}'),
            Text('שיטת תשלום: ${doctor['payment_method']}'),
            const SizedBox(height: 16),
            const Text('היסטוריית תשלומים:'),
            Text('ינואר 2024: ₪${doctor['monthly_payment']} - שולם'),
            Text('דצמבר 2023: ₪${doctor['monthly_payment']} - שולם'),
            Text('נובמבר 2023: ₪${doctor['monthly_payment']} - שולם'),
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

  void _toggleDoctorStatus(Map<String, dynamic> doctor) {
    final newStatus = doctor['status'] == 'active' ? 'inactive' : 'active';
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('החלפת סטטוס'),
        content: Text('האם אתה בטוח שברצונך להחליף את סטטוס ${doctor['name']} ל-${newStatus == 'active' ? 'פעיל' : 'לא פעיל'}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('ביטול'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                doctor['status'] = newStatus;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('סטטוס ${doctor['name']} הוחלף')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: newStatus == 'active' ? Colors.green : Colors.red,
            ),
            child: Text(newStatus == 'active' ? 'הפעל' : 'השבת'),
          ),
        ],
      ),
    );
  }
}

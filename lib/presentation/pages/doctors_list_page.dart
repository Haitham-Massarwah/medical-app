import 'package:flutter/material.dart';
import '../../services/admin_service.dart';
import '../widgets/dashboard_sidebar.dart';
import '../../core/theme/app_colors.dart';

class DoctorsListPage extends StatefulWidget {
  const DoctorsListPage({super.key});

  @override
  State<DoctorsListPage> createState() => _DoctorsListPageState();
}

class _DoctorsListPageState extends State<DoctorsListPage> {
  final AdminService _adminService = AdminService();
  List<Map<String, dynamic>> _doctors = [];
  bool _isLoading = true;
  String _selectedSpecialty = 'כל ההתמחויות';
  String _currentRole = 'developer';

  @override
  void initState() {
    super.initState();
    _loadDoctors();
  }

  Future<void> _loadDoctors() async {
    setState(() => _isLoading = true);
    try {
      final doctors = await _adminService.getDoctors();
      setState(() {
        _doctors = doctors;
        if (_selectedSpecialty != 'כל ההתמחויות' &&
            !_doctors.any((d) => d['specialty'] == _selectedSpecialty)) {
          _selectedSpecialty = 'כל ההתמחויות';
        }
        _isLoading = false;
      });
    } catch (_) {
      setState(() {
        _doctors = [];
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context);
    final isRTL = locale.languageCode == 'he' || locale.languageCode == 'ar';
    final specialties = <String>{
      'כל ההתמחויות',
      ..._doctors
          .map((d) => d['specialty'])
          .where((s) => s != null && s.toString().trim().isNotEmpty)
          .map((s) => s.toString()),
    }.toList();
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
              DashboardSidebar(currentRoute: '/doctors-list', role: _currentRole),
              Expanded(
                child: Container(
                  color: AppColors.backgroundLight,
                  padding: const EdgeInsets.all(30),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'ניהול רופאים',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          const Text('התמחות: '),
                          const SizedBox(width: 8),
                          Expanded(
                            child: DropdownButton<String>(
                              value: _selectedSpecialty,
                              isExpanded: true,
                              items: specialties.map((specialty) {
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
                      const SizedBox(height: 16),
                      Expanded(
                        child: _isLoading
                            ? const Center(child: CircularProgressIndicator())
                            : _buildDoctorsList(),
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

  Widget _buildDoctorsList() {
    final filteredDoctors = _doctors.where((doctor) {
      if (_selectedSpecialty == 'כל ההתמחויות') return true;
      return doctor['specialty'] == _selectedSpecialty;
    }).toList();

    return ListView.builder(
      itemCount: filteredDoctors.length,
      itemBuilder: (context, index) {
        final doctor = filteredDoctors[index];
        final firstName = (doctor['first_name'] ?? '').toString();
        final lastName = (doctor['last_name'] ?? '').toString();
        final displayName = (doctor['name'] ?? '$firstName $lastName').toString().trim();
        final email = (doctor['email'] ?? '').toString();
        final phone = (doctor['phone'] ?? '').toString();
        final specialty = (doctor['specialty'] ?? '').toString();
        final city = (doctor['city'] ?? '').toString();
        final status = (doctor['status'] ?? doctor['is_active'] ?? 'active').toString();

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: status == 'active' || status == 'true' ? Colors.green : Colors.red,
              child: const Icon(
                Icons.medical_services,
                color: Colors.white,
              ),
            ),
            title: Text(displayName.isEmpty ? email : displayName),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (specialty.isNotEmpty || city.isNotEmpty)
                  Text('${specialty.isEmpty ? '-' : specialty} • ${city.isEmpty ? '-' : city}'),
                Text('$email • ${phone.isEmpty ? '-' : phone}'),
                if (doctor['consultation_fee'] != null || doctor['years_experience'] != null)
                  Text('שכר ייעוץ: ₪${doctor['consultation_fee'] ?? '-'} • ניסיון: ${doctor['years_experience'] ?? '-'} שנים'),
                if (doctor['monthly_payment'] != null || doctor['payment_method'] != null)
                  Text('תשלום חודשי: ₪${doctor['monthly_payment'] ?? '-'} • ${doctor['payment_method'] ?? '-'}'),
                Text('סטטוס: ${status == 'active' || status == 'true' ? 'פעיל' : 'לא פעיל'}'),
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
    final firstName = (doctor['first_name'] ?? '').toString();
    final lastName = (doctor['last_name'] ?? '').toString();
    final displayName = (doctor['name'] ?? '$firstName $lastName').toString().trim();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('פרטי ${displayName.isEmpty ? doctor['email'] ?? '' : displayName}'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('שם: ${displayName.isEmpty ? doctor['email'] ?? '' : displayName}'),
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
    final firstName = (doctor['first_name'] ?? '').toString();
    final lastName = (doctor['last_name'] ?? '').toString();
    final displayName = (doctor['name'] ?? '$firstName $lastName').toString().trim();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('תשלומים - ${displayName.isEmpty ? doctor['email'] ?? '' : displayName}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('תשלום חודשי: ₪${doctor['monthly_payment'] ?? '-'}'),
            Text('שיטת תשלום: ${doctor['payment_method'] ?? '-'}'),
            const SizedBox(height: 16),
            const Text('היסטוריית תשלומים תוצג כאשר תתקבל מהשרת.'),
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
    final currentStatus = (doctor['status'] ?? doctor['is_active'] ?? 'active').toString();
    final isActive = currentStatus == 'active' || currentStatus == 'true';
    final newStatus = isActive ? 'inactive' : 'active';
    final firstName = (doctor['first_name'] ?? '').toString();
    final lastName = (doctor['last_name'] ?? '').toString();
    final displayName = (doctor['name'] ?? '$firstName $lastName').toString().trim();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('החלפת סטטוס'),
        content: Text('האם אתה בטוח שברצונך להחליף את סטטוס ${displayName.isEmpty ? doctor['email'] ?? '' : displayName} ל-${newStatus == 'active' ? 'פעיל' : 'לא פעיל'}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('ביטול'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              final userId = doctor['user_id'] ?? doctor['userId'];
              if (userId == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('לא ניתן לעדכן סטטוס ללא מזהה משתמש'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }
              final success = await _adminService.updateUserStatus(
                userId.toString(),
                newStatus == 'active',
              );
              if (success && mounted) {
                setState(() {
                  doctor['status'] = newStatus;
                  doctor['is_active'] = newStatus == 'active';
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('סטטוס ${doctor['name']} עודכן')),
                );
              } else if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('שגיאה בעדכון סטטוס רופא'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
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

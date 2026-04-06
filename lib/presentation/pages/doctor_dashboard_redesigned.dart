import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/localization/app_localizations.dart';
import '../../services/auth_service.dart';
import '../../services/appointment_service.dart';
import '../navigation/app_module_route_builder.dart';
import '../widgets/unified_dashboard_layout.dart';
import '../widgets/metric_card.dart';

/// PD-12: Doctor Dashboard using unified layout structure
class DoctorDashboardPage extends StatefulWidget {
  const DoctorDashboardPage({Key? key}) : super(key: key);

  @override
  State<DoctorDashboardPage> createState() => _DoctorDashboardPageState();
}

class _DoctorDashboardPageState extends State<DoctorDashboardPage> {
  final AuthService _authService = AuthService();
  final AppointmentService _appointmentService = AppointmentService();
  bool _isLoading = true;
  bool _isDemo = false;
  String _doctorName = 'לוח בקרה רופא';
  List<Map<String, dynamic>> _appointments = [];
  List<Map<String, String>> _messages = [];

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() => _isLoading = true);
    try {
      final me = await _authService.getCurrentUser();
      final user = me['data']?['user'] ?? {};
      final email = (user['email'] ?? '').toString().toLowerCase();
      final firstName = (user['first_name'] ?? '').toString();
      final lastName = (user['last_name'] ?? '').toString();
      final fullName = ('$firstName $lastName').trim();

      _isDemo = email == 'demo.doctor@medical-appointments.com';
      _doctorName = fullName.isEmpty ? 'לוח בקרה רופא' : fullName;

      if (_isDemo) {
        _appointments = _demoAppointments();
        _messages = _demoMessages();
      } else {
        _appointments = await _appointmentService.getAppointments();
        _messages = [];
      }
    } catch (_) {
      _appointments = [];
      _messages = [];
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  int _countUpcoming() {
    final now = DateTime.now();
    return _appointments.where((a) {
      final dateStr = a['appointment_date']?.toString();
      final status = (a['status'] ?? '').toString();
      if (dateStr == null || dateStr.isEmpty) return false;
      final date = DateTime.tryParse(dateStr);
      if (date == null) return false;
      return date.isAfter(now) && status != 'cancelled' && status != 'no_show';
    }).length;
  }

  int _countPatients() {
    final ids = _appointments.map((a) => a['patient_id']).where((id) => id != null).toSet();
    return ids.length;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final upcomingCount = _countUpcoming();
    final patientCount = _countPatients();
    final messageCount = _messages.length;

    return UnifiedDashboardLayout(
      currentRoute: '/doctor-dashboard',
      role: 'doctor',
      pageTitle: _doctorName,
      primaryColor: Colors.green,
      headerActions: [
        IconButton(
          icon: const Icon(Icons.exit_to_app, color: Colors.red),
          tooltip: 'יציאה',
          onPressed: _confirmLogout,
        ),
      ],
      metricCards: [
        MetricCard(
          value: upcomingCount.toString(),
          label: AppLocalizations.of(context).upcomingAppointments,
          color: AppColors.accentCyan,
        ),
        MetricCard(
          value: patientCount.toString(),
          label: AppLocalizations.of(context).newPatientsThisMonth,
          color: AppColors.accentCyan,
        ),
        MetricCard(
          value: messageCount.toString(),
          label: AppLocalizations.of(context).messages,
          color: AppColors.accentPurple,
        ),
      ],
      contentSections: [
        DashboardContentSection(
          title: 'מודולים — נפתחים במסך חדש (חזרה ←)',
          child: Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _moduleButton(context, 'טפסים', Icons.description, '/forms-documents'),
              _moduleButton(context, 'CRM', Icons.campaign, '/crm-communication'),
              _moduleButton(context, 'פיננסים', Icons.account_balance_wallet, '/finance-operations'),
              _moduleButton(context, 'אינטגרציות', Icons.hub, '/integrations-operations'),
            ],
          ),
        ),
        DashboardContentSection(
          title: AppLocalizations.of(context).upcomingAppointments,
          child: _appointments.isEmpty
              ? Center(child: Text(AppLocalizations.of(context).noAppointmentsFound))
              : _buildAppointmentsTable(_appointments),
        ),
        DashboardContentSection(
          title: AppLocalizations.of(context).messages,
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/notifications'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accentCyan,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Text(AppLocalizations.of(context).viewAll, style: const TextStyle(color: Colors.white)),
            ),
          ],
          child: _messages.isEmpty
              ? Center(child: Text(AppLocalizations.of(context).noMessagesFound))
              : Column(
                  children: _messages
                      .map((m) => Column(
                            children: [
                              _buildMessage(m['sender']!, m['subject']!, m['time']!),
                              const Divider(),
                            ],
                          ))
                      .toList(),
                ),
        ),
      ],
    );
  }

  Widget _buildAppointmentsTable(List<Map<String, dynamic>> appointments) {
    final rows = appointments.take(6).map((a) {
      // Always try to get patient name, fallback to ID if name not available.
      final patientName = a['patient_name']?.toString().trim();
      final fullName = '${a['first_name'] ?? ''} ${a['last_name'] ?? ''}'.trim();
      final patientId = a['patient_id']?.toString().trim();
      final patient = (patientName != null && patientName.isNotEmpty)
          ? patientName
          : (fullName.isNotEmpty ? fullName : (patientId != null && patientId.isNotEmpty ? patientId : '-'));
      final dateStr = (a['appointment_date'] ?? '').toString();
      final date = DateTime.tryParse(dateStr);
      final dateLabel = date == null ? '-' : '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      final timeLabel = date == null ? '-' : '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
      final status = (a['status'] ?? 'scheduled').toString();
      final confirmed = status == 'confirmed' || status == 'completed';

      return _buildAppointmentRow(
        patient,
        dateLabel,
        timeLabel,
        status,
        confirmed,
      );
    }).toList();

    return Table(
      columnWidths: const {
        0: FlexColumnWidth(2),
        1: FlexColumnWidth(2),
        2: FlexColumnWidth(1.5),
        3: FlexColumnWidth(1.2),
      },
      children: [
        TableRow(
          decoration: BoxDecoration(color: Colors.grey.shade100),
          children: const [
            Padding(padding: EdgeInsets.all(12), child: Text('מטופל', style: TextStyle(fontWeight: FontWeight.bold))),
            Padding(padding: EdgeInsets.all(12), child: Text('תאריך', style: TextStyle(fontWeight: FontWeight.bold))),
            Padding(padding: EdgeInsets.all(12), child: Text('שעה', style: TextStyle(fontWeight: FontWeight.bold))),
            Padding(padding: EdgeInsets.all(12), child: Text('סטטוס', style: TextStyle(fontWeight: FontWeight.bold))),
          ],
        ),
        ...rows,
      ],
    );
  }

  TableRow _buildAppointmentRow(String patient, String date, String time, String status, bool isConfirmed) {
    return TableRow(
      children: [
        Padding(padding: const EdgeInsets.all(12), child: Text(patient)),
        Padding(padding: const EdgeInsets.all(12), child: Text(date)),
        Padding(padding: const EdgeInsets.all(12), child: Text(time)),
        Padding(
          padding: const EdgeInsets.all(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: isConfirmed ? AppColors.statusConfirmed : AppColors.statusPending,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              status,
              style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }

  Widget _moduleButton(BuildContext context, String label, IconData icon, String route) {
    return ElevatedButton.icon(
      onPressed: () => openModuleRoute(context, route),
      icon: Icon(icon, size: 20),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  Widget _buildMessage(String sender, String subject, String time) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(sender, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 4),
                Text(subject, style: const TextStyle(color: Colors.black87)),
              ],
            ),
          ),
          Text(time, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
        ],
      ),
    );
  }

  Future<void> _confirmLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('יציאה'),
        content: const Text('האם אתה בטוח שברצונך להתנתק?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('ביטול')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text('יציאה'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _authService.logout();
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    }
  }

  List<Map<String, dynamic>> _demoAppointments() {
    return [
      {
        'patient_name': 'יוסי כהן',
        'appointment_date': DateTime.now().add(const Duration(days: 1)).toIso8601String(),
        'status': 'confirmed',
      },
      {
        'patient_name': 'שרה לוי',
        'appointment_date': DateTime.now().add(const Duration(days: 2)).toIso8601String(),
        'status': 'confirmed',
      },
      {
        'patient_name': 'דוד ישראלי',
        'appointment_date': DateTime.now().add(const Duration(days: 3)).toIso8601String(),
        'status': 'scheduled',
      },
    ];
  }

  List<Map<String, String>> _demoMessages() {
    return [
      {'sender': 'מיכל גולן', 'subject': 'שאלה בפורטל המטופל', 'time': '14m'},
      {'sender': 'רועי ברק', 'subject': 'בקשת תור', 'time': '39m'},
    ];
  }
}



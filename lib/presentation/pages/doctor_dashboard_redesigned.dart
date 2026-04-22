import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/localization/app_localizations.dart';
import '../../services/auth_service.dart';
import '../../services/appointment_service.dart';
import '../navigation/app_module_route_builder.dart';
import '../widgets/unified_dashboard_layout.dart';
import '../widgets/metric_card.dart';
import '../../services/user_service.dart';

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

  void _onUserVersionChanged() {
    if (mounted) {
      _loadDashboardData();
    }
  }

  @override
  void initState() {
    super.initState();
    UserService.currentUserVersion.addListener(_onUserVersionChanged);
    _loadDashboardData();
  }

  @override
  void dispose() {
    UserService.currentUserVersion.removeListener(_onUserVersionChanged);
    super.dispose();
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

  String _patientDisplayName(Map<String, dynamic> a) {
    final fromApi = '${a['patientName'] ?? a['patient_name'] ?? ''}'.trim();
    if (fromApi.isNotEmpty) return fromApi;
    final full = '${a['first_name'] ?? ''} ${a['last_name'] ?? ''}'.trim();
    if (full.isNotEmpty) return full;
    final guest = '${a['guest_name'] ?? ''}'.trim();
    if (guest.isNotEmpty) return guest;
    return 'מטופל';
  }

  String _patientPhoneLabel(Map<String, dynamic> a) {
    final p = '${a['patientPhone'] ?? a['patient_phone'] ?? a['guest_phone'] ?? ''}'.trim();
    if (p.isNotEmpty) return p;
    return '—';
  }

  String _statusLabelHe(String raw) {
    switch (raw) {
      case 'confirmed':
        return 'מאושר';
      case 'scheduled':
        return 'נקבע';
      case 'completed':
        return 'הושלם';
      case 'cancelled':
        return 'בוטל';
      case 'no_show':
        return 'אי-הגעה';
      case 'rescheduled':
        return 'נדחה';
      default:
        return raw;
    }
  }

  Widget _buildAppointmentsTable(List<Map<String, dynamic>> appointments) {
    final rows = appointments.take(6).map((a) {
      final patient = _patientDisplayName(a);
      final phone = _patientPhoneLabel(a);
      final dateStr = (a['appointment_date'] ?? '').toString();
      final date = DateTime.tryParse(dateStr);
      final local = date?.toLocal();
      final dateLabel = local == null
          ? '-'
          : '${local.year}-${local.month.toString().padLeft(2, '0')}-${local.day.toString().padLeft(2, '0')}';
      final timeLabel = local == null
          ? '-'
          : '${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';
      final statusRaw = (a['status'] ?? 'scheduled').toString();
      final status = _statusLabelHe(statusRaw);
      final confirmed = statusRaw == 'confirmed' || statusRaw == 'completed';

      return _buildAppointmentRow(
        patient,
        phone,
        dateLabel,
        timeLabel,
        status,
        confirmed,
      );
    }).toList();

    return Table(
      columnWidths: const {
        0: FlexColumnWidth(2.2),
        1: FlexColumnWidth(1.6),
        2: FlexColumnWidth(1.4),
        3: FlexColumnWidth(1.2),
        4: FlexColumnWidth(1.2),
      },
      children: [
        TableRow(
          decoration: BoxDecoration(color: Colors.grey.shade100),
          children: const [
            Padding(padding: EdgeInsets.all(12), child: Text('מטופל', style: TextStyle(fontWeight: FontWeight.bold))),
            Padding(padding: EdgeInsets.all(12), child: Text('טלפון', style: TextStyle(fontWeight: FontWeight.bold))),
            Padding(padding: EdgeInsets.all(12), child: Text('תאריך', style: TextStyle(fontWeight: FontWeight.bold))),
            Padding(padding: EdgeInsets.all(12), child: Text('שעה', style: TextStyle(fontWeight: FontWeight.bold))),
            Padding(padding: EdgeInsets.all(12), child: Text('סטטוס', style: TextStyle(fontWeight: FontWeight.bold))),
          ],
        ),
        ...rows,
      ],
    );
  }

  TableRow _buildAppointmentRow(
    String patient,
    String phone,
    String date,
    String time,
    String status,
    bool isConfirmed,
  ) {
    return TableRow(
      children: [
        Padding(padding: const EdgeInsets.all(12), child: Text(patient)),
        Padding(padding: const EdgeInsets.all(12), child: Text(phone)),
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
    await _authService.logout();
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/login');
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



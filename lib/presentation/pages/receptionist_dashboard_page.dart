import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../services/auth_service.dart';
import '../../services/appointment_service.dart';
import '../navigation/app_module_route_builder.dart';
import '../widgets/unified_dashboard_layout.dart';
import '../widgets/metric_card.dart';

/// SRS Rev 02 §2.1 — Receptionist: front-desk scheduling & patient intake (Hebrew UI).
class ReceptionistDashboardPage extends StatefulWidget {
  const ReceptionistDashboardPage({super.key});

  @override
  State<ReceptionistDashboardPage> createState() => _ReceptionistDashboardPageState();
}

class _ReceptionistDashboardPageState extends State<ReceptionistDashboardPage> {
  final AuthService _authService = AuthService();
  final AppointmentService _appointmentService = AppointmentService();
  bool _isLoading = true;
  String _title = 'דלפן קבלה';
  List<Map<String, dynamic>> _appointments = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    try {
      final me = await _authService.getCurrentUser();
      final user = me['data']?['user'] ?? {};
      final firstName = (user['first_name'] ?? '').toString();
      final lastName = (user['last_name'] ?? '').toString();
      final full = ('$firstName $lastName').trim();
      if (full.isNotEmpty) {
        _title = full;
      }
      _appointments = await _appointmentService.getAppointments();
    } catch (_) {
      _appointments = [];
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  int _upcomingCount() {
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

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final upcoming = _upcomingCount();

    return UnifiedDashboardLayout(
      currentRoute: '/receptionist-dashboard',
      role: 'receptionist',
      pageTitle: _title,
      primaryColor: Colors.teal,
      headerActions: [
        IconButton(
          icon: const Icon(Icons.exit_to_app, color: Colors.red),
          tooltip: 'יציאה',
          onPressed: _confirmLogout,
        ),
      ],
      metricCards: [
        MetricCard(
          value: upcoming.toString(),
          label: 'תורים קרובים',
          color: AppColors.accentCyan,
        ),
        MetricCard(
          value: _appointments.length.toString(),
          label: 'סה״כ ברשימה',
          color: AppColors.accentPurple,
        ),
      ],
      contentSections: [
        DashboardContentSection(
          title: 'פעולות',
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              ElevatedButton.icon(
                onPressed: () => openModuleRoute(context, '/booking-management'),
                icon: const Icon(Icons.calendar_today),
                label: const Text('ניהול תורים'),
              ),
              ElevatedButton.icon(
                onPressed: () => openModuleRoute(context, '/create-patient'),
                icon: const Icon(Icons.person_add),
                label: const Text('מטופל חדש'),
              ),
            ],
          ),
        ),
        DashboardContentSection(
          title: 'תורים אחרונים',
          child: _appointments.isEmpty
              ? const Center(child: Text('אין תורים להצגה'))
              : _buildMiniTable(_appointments.take(8).toList()),
        ),
      ],
    );
  }

  Widget _buildMiniTable(List<Map<String, dynamic>> rows) {
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
        ...rows.map((a) {
          final patientName = a['patientName']?.toString().trim();
          final pn = a['patient_name']?.toString().trim();
          final name = (patientName != null && patientName.isNotEmpty)
              ? patientName
              : (pn ?? '-');
          final dateStr = (a['appointment_date'] ?? '').toString();
          final date = DateTime.tryParse(dateStr);
          final dLabel = date == null ? '-' : '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
          final tLabel = date == null ? '-' : '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
          final status = (a['status'] ?? '').toString();
          return TableRow(
            children: [
              Padding(padding: const EdgeInsets.all(12), child: Text(name)),
              Padding(padding: const EdgeInsets.all(12), child: Text(dLabel)),
              Padding(padding: const EdgeInsets.all(12), child: Text(tLabel)),
              Padding(padding: const EdgeInsets.all(12), child: Text(status)),
            ],
          );
        }),
      ],
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
}

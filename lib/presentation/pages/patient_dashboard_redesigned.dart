import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/theme/app_colors.dart';
import '../../core/localization/app_localizations.dart';
import '../widgets/unified_dashboard_layout.dart';
import '../widgets/metric_card.dart';
import '../../services/auth_service.dart';
import '../../services/appointment_service.dart';

/// PD-12: Patient Dashboard using unified layout structure
/// PD-08: RTL/LTR language-aware
class PatientDashboardPage extends StatefulWidget {
  const PatientDashboardPage({Key? key}) : super(key: key);

  @override
  State<PatientDashboardPage> createState() => _PatientDashboardPageState();
}

class _PatientDashboardPageState extends State<PatientDashboardPage> {
  final AuthService _authService = AuthService();
  final AppointmentService _appointmentService = AppointmentService();
  String _patientName = 'מטופל'; // Default, will be loaded from storage/API
  bool _isLoading = true;
  bool _isDemo = false;
  List<Map<String, dynamic>> _appointments = [];

  @override
  void initState() {
    super.initState();
    _loadPatientName();
    _loadAppointments();
  }

  Future<void> _loadPatientName() async {
    // Load patient name from API (not account type)
    try {
      print('[PATIENT] Loading patient name...');
      final token = await _authService.isLoggedIn();
      if (!token) {
        print('[PATIENT] No token found - checking storage directly...');
        // Give it a moment - token might still be saving
        await Future.delayed(const Duration(milliseconds: 500));
        final tokenRetry = await _authService.isLoggedIn();
        if (!tokenRetry) {
          print('[PATIENT] Still no token after retry - redirecting to login');
          if (mounted) {
            Navigator.pushReplacementNamed(context, '/login');
          }
          return;
        }
        print('[PATIENT] Token found on retry');
      }
      
      final me = await _authService.getCurrentUser();
      final user = me['data']?['user'] ?? {};
      final firstName = (user['first_name'] ?? '').toString();
      final lastName = (user['last_name'] ?? '').toString();
      final fullName = ('$firstName $lastName').trim();
      
      print('✅ [PATIENT] Patient name loaded: $fullName');
      
      if (mounted) {
        setState(() {
          _patientName = fullName.isEmpty ? 'מטופל' : fullName;
        });
      }
    } catch (e) {
      print('❌ [PATIENT] Error loading patient name: $e');
      // If 401, redirect to login
      if (e.toString().contains('401') || e.toString().contains('Unauthorized')) {
        print('❌ [PATIENT] Unauthorized - redirecting to login');
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/login');
        }
        return;
      }
      // Keep default name for other errors
      if (mounted) {
        setState(() {
          _patientName = 'מטופל';
        });
      }
    }
  }

  Future<void> _loadAppointments() async {
    setState(() => _isLoading = true);
    try {
      print('🔍 [PATIENT] Loading appointments...');
      final token = await _authService.isLoggedIn();
      if (!token) {
        print('❌ [PATIENT] No token found - redirecting to login');
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/login');
        }
        return;
      }
      
      final me = await _authService.getCurrentUser();
      final user = me['data']?['user'] ?? {};
      final email = (user['email'] ?? '').toString().toLowerCase();
      _isDemo = email == 'demo.patient@medical-appointments.com';

      if (_isDemo) {
        _appointments = _demoAppointments();
      } else {
        _appointments = await _appointmentService.getAppointments();
      }
      print('✅ [PATIENT] Appointments loaded: ${_appointments.length}');
    } catch (e) {
      print('❌ [PATIENT] Error loading appointments: $e');
      // If 401, redirect to login
      if (e.toString().contains('401') || e.toString().contains('Unauthorized')) {
        print('❌ [PATIENT] Unauthorized - redirecting to login');
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/login');
        }
        return;
      }
      _appointments = [];
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // PD-08: Use language-aware text direction
    final locale = Localizations.localeOf(context);
    final isRTL = locale.languageCode == 'he' || locale.languageCode == 'ar';
    
    return Directionality(
      textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : UnifiedDashboardLayout(
              currentRoute: '/home',
              role: 'patient',
              pageTitle: _patientName, // Display patient name at top
              primaryColor: AppColors.accentCyan, // Patient-specific color
              headerActions: [
                IconButton(
                  icon: const Icon(Icons.exit_to_app, color: Colors.red),
                  tooltip: 'יציאה',
                  onPressed: _confirmLogout,
                ),
              ],
              metricCards: [
                MetricCard(
                  value: _appointments.length.toString(),
                  label: AppLocalizations.of(context).upcomingAppointments,
                  color: AppColors.accentCyan,
                ),
                MetricCard(
                  value: '0',
                  label: AppLocalizations.of(context).newMessages,
                  color: AppColors.accentCyan,
                ),
              ],
              contentSections: [
                DashboardContentSection(
                  title: 'תורים קרובים',
                  child: _appointments.isEmpty
                      ? _buildEmptyAppointments()
                      : _buildAppointmentsTable(_appointments),
                ),
        // Billing Section - Hidden for now (kept in code but not displayed)
        // DashboardContentSection(
        //   title: 'Billing',
        //   child: Center(
        //     child: Padding(
        //       padding: const EdgeInsets.all(40.0),
        //       child: Column(
        //         children: [
        //           Icon(
        //             Icons.receipt_long_outlined,
        //             size: 64,
        //             color: Colors.grey.shade400,
        //           ),
        //           const SizedBox(height: 16),
        //           Text(
        //             'No billing records yet',
        //             style: TextStyle(
        //               fontSize: 18,
        //               color: Colors.grey.shade600,
        //               fontWeight: FontWeight.w500,
        //             ),
        //           ),
        //           const SizedBox(height: 8),
        //           Text(
        //             'Your billing information will appear here',
        //             style: TextStyle(
        //               fontSize: 14,
        //               color: Colors.grey.shade500,
        //             ),
        //             textAlign: TextAlign.center,
        //           ),
        //         ],
        //       ),
        //     ),
        //   ),
        // ),
              ],
            ),
    );
  }

  Widget _buildEmptyAppointments() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Column(
          children: [
            Icon(
              Icons.calendar_today_outlined,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'אין עדיין תורים',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'קבע את התור הראשון שלך כדי להתחיל',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppointmentsTable(List<Map<String, dynamic>> appointments) {
    final rows = appointments.take(6).map((a) {
      final doctor = _isDemo ? (a['doctor_name'] ?? '-') : (a['doctor_id'] ?? '-');
      final dateStr = (a['appointment_date'] ?? '').toString();
      final date = DateTime.tryParse(dateStr);
      final dateLabel = date == null ? '-' : '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      final timeLabel = date == null ? '-' : '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
      final status = (a['status'] ?? 'scheduled').toString();

      return TableRow(
        children: [
          Padding(padding: const EdgeInsets.all(12), child: Text(doctor.toString())),
          Padding(padding: const EdgeInsets.all(12), child: Text(dateLabel)),
          Padding(padding: const EdgeInsets.all(12), child: Text(timeLabel)),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.statusConfirmed,
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
            Padding(padding: EdgeInsets.all(12), child: Text('רופא', style: TextStyle(fontWeight: FontWeight.bold))),
            Padding(padding: EdgeInsets.all(12), child: Text('תאריך', style: TextStyle(fontWeight: FontWeight.bold))),
            Padding(padding: EdgeInsets.all(12), child: Text('שעה', style: TextStyle(fontWeight: FontWeight.bold))),
            Padding(padding: EdgeInsets.all(12), child: Text('סטטוס', style: TextStyle(fontWeight: FontWeight.bold))),
          ],
        ),
        ...rows,
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

  List<Map<String, dynamic>> _demoAppointments() {
    return [
      {
        'doctor_name': 'ד"ר דמו אחד',
        'appointment_date': DateTime.now().add(const Duration(days: 1)).toIso8601String(),
        'status': 'confirmed',
      },
      {
        'doctor_name': 'ד"ר דמו שני',
        'appointment_date': DateTime.now().add(const Duration(days: 3)).toIso8601String(),
        'status': 'scheduled',
      },
    ];
  }
}



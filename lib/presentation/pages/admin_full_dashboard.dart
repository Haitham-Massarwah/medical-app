import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../navigation/app_module_route_builder.dart';
import '../widgets/unified_dashboard_layout.dart';
import '../widgets/metric_card.dart';
import '../../services/admin_service.dart';

/// COMPLETE ADMIN CONTROL PANEL DASHBOARD
/// Full system management for administrators
class AdminFullDashboard extends StatefulWidget {
  const AdminFullDashboard({Key? key}) : super(key: key);

  @override
  State<AdminFullDashboard> createState() => _AdminFullDashboardState();
}

class _AdminFullDashboardState extends State<AdminFullDashboard> {
  final AdminService _adminService = AdminService();
  
  // Statistics - loaded from real data
  int _totalUsers = 0;
  int _totalDoctors = 0;
  int _totalAppointments = 0;
  double _totalRevenue = 0.0;
  bool _isLoading = true;
  bool _isInitialLoad = true;
  String _currentRole = 'developer';

  @override
  void initState() {
    super.initState();
    _loadDashboardData(isInitialLoad: true);
    // Set up real-time updates every 30 seconds
    _setupRealTimeUpdates();
  }

  void _setupRealTimeUpdates() {
    Future.delayed(const Duration(seconds: 30), () {
      if (mounted) {
        _loadDashboardData(silent: true);
        _setupRealTimeUpdates(); // Continue updating
      }
    });
  }

  Future<void> _loadDashboardData({bool silent = false, bool isInitialLoad = false}) async {
    if (!silent) {
      setState(() {
        _isLoading = true;
      });
    }

    try {
      final stats = await _adminService.getDashboardStats();
      if (mounted) {
        setState(() {
          _totalUsers = stats['total_users'] ?? 0;
          _totalDoctors = stats['total_doctors'] ?? 0;
          _totalAppointments = stats['total_appointments'] ?? 0;
          _totalRevenue = (stats['total_revenue'] ?? 0).toDouble();
          _isLoading = false;
          _isInitialLoad = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isInitialLoad = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final routeArgs = ModalRoute.of(context)?.settings.arguments;
    if (routeArgs is Map<String, dynamic> && routeArgs['role'] is String) {
      _currentRole = routeArgs['role'] as String;
    }
    final isDeveloper = _currentRole == 'developer';

    if (_isLoading && _isInitialLoad) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return UnifiedDashboardLayout(
      currentRoute: '/developer-control',
      role: _currentRole,
      pageTitle: 'לוח בקרה מנהל - Admin Control Panel',
      primaryColor: Colors.orange,
      headerActions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: _refreshData,
          tooltip: 'רענן נתונים',
        ),
        IconButton(
          icon: const Icon(Icons.download),
          onPressed: _exportData,
          tooltip: 'הורד דוח',
        ),
        IconButton(
          icon: const Icon(Icons.exit_to_app),
          onPressed: _exitToLogin,
          tooltip: 'יציאה',
          color: Colors.red,
        ),
      ],
      metricCards: [
        MetricCard(
          value: _totalUsers.toString(),
          label: 'סה"כ משתמשים',
          color: AppColors.accentCyan,
          icon: Icons.people,
        ),
        MetricCard(
          value: _totalDoctors.toString(),
          label: 'סה"כ רופאים',
          color: Colors.green,
          icon: Icons.medical_services,
        ),
        MetricCard(
          value: _totalAppointments.toString(),
          label: 'סה"כ תורים',
          color: Colors.orange,
          icon: Icons.calendar_today,
        ),
        MetricCard(
          value: '₪${_totalRevenue.toStringAsFixed(0)}',
          label: 'הכנסות',
          color: Colors.purple,
          icon: Icons.attach_money,
        ),
      ],
      contentSections: [
        DashboardContentSection(
          title: 'פעולות מהירות',
          child: Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  'הוסף רופא',
                  Icons.person_add,
                  Colors.green,
                  () => openModuleRoute(context, '/create-doctor'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildActionButton(
                  'הוסף מטופל',
                  Icons.person_add_outlined,
                  Colors.blue,
                  () => openModuleRoute(context, '/create-patient'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildActionButton(
                  'צפה בתשלומים',
                  Icons.payment,
                  Colors.purple,
                  () => Navigator.pushNamed(
                    context,
                    '/admin-payment-control',
                    arguments: {'role': _currentRole},
                  ),
                ),
              ),
            ],
          ),
        ),
        DashboardContentSection(
          title: 'כל הרופאים - All Doctors',
          child: _buildManagementSection(
            'כל הרופאים - All Doctors',
            Icons.medical_services,
            Colors.green,
            [
              'צפה ברשימת כל הרופאים',
              'חיפוש וסינון רופאים',
              'צפה בסטטיסטיקות',
              'ניהול סטטוס (פעיל/לא פעיל)',
            ],
            () => openModuleRoute(
              context,
              '/doctors-list',
              arguments: {'role': _currentRole},
            ),
          ),
        ),
        DashboardContentSection(
          title: 'כל המטופלים - All Patients',
          child: _buildManagementSection(
            'כל המטופלים - All Patients',
            Icons.people,
            Colors.blue,
            [
              'צפה ברשימת כל המטופלים',
              'חיפוש וסינון מטופלים',
              'צפה בהיסטוריה רפואית',
            ],
            () => openModuleRoute(
              context,
              '/users-list',
              arguments: {'role': _currentRole},
            ),
          ),
        ),
        DashboardContentSection(
          title: 'כל התורים - All Appointments',
          child: _buildManagementSection(
            'כל התורים - All Appointments',
            Icons.calendar_today,
            Colors.orange,
            [
              'צפה בכל התורים במערכת',
              'סינון לפי רופא / מטופל',
              'עדכון סטטוס תורים',
            ],
            () => openModuleRoute(
              context,
              '/appointments',
              arguments: {'role': _currentRole},
            ),
          ),
        ),
        DashboardContentSection(
          title: 'בקרת תשלומים - Payment Control',
          child: _buildManagementSection(
            'בקרת תשלומים מהרופאים - Payment Control',
            Icons.account_balance_wallet,
            Colors.purple,
            [
              'מעקב אחר הכנסות מרופאים',
              'חישוב עמלות אוטומטי',
              'דוחות תשלומים',
            ],
            () => openModuleRoute(
              context,
              '/admin-payment-control',
              arguments: {'role': _currentRole},
            ),
          ),
        ),
        if (isDeveloper)
          DashboardContentSection(
            title: 'שיטות טיפול - Treatment Methods',
            child: _buildManagementSection(
              'שיטות טיפול - Treatment Methods',
              Icons.medical_information,
              Colors.teal,
              [
                'יצירת שיטות טיפול חדשות',
                'קביעת מחירים',
                'שיוך לרופאים',
              ],
              () => openModuleRoute(context, '/developer-specialty-settings'),
              isVisible: true,
            ),
          ),
        DashboardContentSection(
          title: 'הרשאות - Permissions',
          child: _buildManagementSection(
            'הרשאות - Permissions Management',
            Icons.admin_panel_settings,
            Colors.red,
            [
              'ניהול הרשאות משתמשים',
              'שיוך תפקידים',
              'בקרת גישה למערכת',
            ],
            () => openModuleRoute(
              context,
              '/admin-permissions',
              arguments: {'role': _currentRole},
            ),
          ),
        ),
        if (isDeveloper)
          DashboardContentSection(
            title: 'אמצעי תשלום - Payment Methods',
            child: _buildManagementSection(
              'אמצעי תשלום - Payment Methods',
              Icons.credit_card,
              Colors.indigo,
              [
                'הגדרות שערי תשלום',
                'כרטיסי אשראי',
                'ניהול החזרים',
              ],
              () => openModuleRoute(context, '/payment-settings'),
              isVisible: true,
            ),
          ),
        DashboardContentSection(
          title: 'הגדרות מערכת - System Settings',
          child: _buildManagementSection(
            'הגדרות מערכת - System Settings',
            Icons.settings,
            Colors.grey,
            [
              'הגדרות גלובליות',
              'ניהול מסד נתונים',
              'גיבויים',
            ],
            () => openModuleRoute(
              context,
              '/developer-database',
              arguments: {'readOnly': !isDeveloper},
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(String label, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 24),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildManagementSection(
    String title,
    IconData icon,
    Color color,
    List<String> features,
    VoidCallback onTap,
    {bool isVisible = true}
  ) {
    if (!isVisible) {
      return const SizedBox.shrink();
    }
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: color.withOpacity(0.3), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              ElevatedButton.icon(
                onPressed: onTap,
                icon: const Icon(Icons.arrow_forward, size: 18),
                label: const Text('פתח'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: color,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...features.map((feature) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                Icon(Icons.check_circle, color: color, size: 20),
                const SizedBox(width: 8),
                Text(
                  feature,
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  void _refreshData() {
    _loadDashboardData(silent: true);
  }

  void _exportData() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('מייצא דוח...'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _exitToLogin() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('יציאה מהמערכת'),
        content: const Text('האם אתה בטוח שברצונך לצאת?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ביטול'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pushReplacementNamed(context, '/');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('יציאה'),
          ),
        ],
      ),
    );
  }
}


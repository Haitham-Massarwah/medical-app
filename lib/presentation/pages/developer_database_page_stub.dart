import 'package:flutter/material.dart';
import '../widgets/dashboard_sidebar.dart';
import '../../core/theme/app_colors.dart';
import '../../services/admin_service.dart';

class DeveloperDatabasePage extends StatefulWidget {
  final bool isReadOnly;

  const DeveloperDatabasePage({super.key, this.isReadOnly = false});

  @override
  State<DeveloperDatabasePage> createState() => _DeveloperDatabasePageState();
}

class _DeveloperDatabasePageState extends State<DeveloperDatabasePage> {
  final AdminService _adminService = AdminService();

  bool _isLoading = false;
  String _currentRole = 'developer';
  Map<String, dynamic> _stats = {};
  List<Map<String, dynamic>> _users = [];
  List<Map<String, dynamic>> _appointments = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final stats = await _adminService.getDatabaseStats();
      final users = await _adminService.getDatabaseUsers(limit: 10);
      final appointments = await _adminService.getDatabaseAppointments(limit: 10);
      if (mounted) {
        setState(() {
          _stats = stats;
          _users = users;
          _appointments = appointments;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final routeArgs = ModalRoute.of(context)?.settings.arguments;
    if (routeArgs is Map<String, dynamic> && routeArgs['role'] is String) {
      _currentRole = routeArgs['role'] as String;
    }

    return Scaffold(
      body: SafeArea(
        child: Row(
          children: [
            DashboardSidebar(currentRoute: '/developer-database', role: _currentRole),
            Expanded(
              child: Container(
                color: AppColors.backgroundLight,
                padding: const EdgeInsets.all(30),
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Database Overview (Web)',
                                  style: TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                ElevatedButton.icon(
                                  onPressed: _loadData,
                                  icon: const Icon(Icons.refresh),
                                  label: const Text('Refresh'),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Card(
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Database Statistics',
                                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 12),
                                    _buildStatRow('Users', _stats['users']?['count'] ?? _stats['users'] ?? 0),
                                    _buildStatRow('Doctors', _stats['doctors']?['count'] ?? _stats['doctors'] ?? 0),
                                    _buildStatRow('Patients', _stats['patients']?['count'] ?? _stats['patients'] ?? 0),
                                    _buildStatRow('Appointments', _stats['appointments']?['count'] ?? _stats['appointments'] ?? 0),
                                    _buildStatRow('Tenants', _stats['tenants']?['count'] ?? _stats['tenants'] ?? 0),
                                    _buildStatRow('Subscriptions', _stats['subscriptions']?['count'] ?? _stats['subscriptions'] ?? 0),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            Card(
                              color: Colors.blue.shade50,
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(Icons.security, color: Colors.blue),
                                        const SizedBox(width: 8),
                                        const Text(
                                          'Cyber Security & System Health',
                                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    _buildSecurityMetrics(),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            Card(
                              color: Colors.orange.shade50,
                              child: const Padding(
                                padding: EdgeInsets.all(16),
                                child: Text(
                                  'Database management actions (upload/restore/optimize) are server-side only. '
                                  'This web view provides full visibility without destructive operations.',
                                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            _buildSectionTitle('Recent Users'),
                            _buildUsersTable(),
                            const SizedBox(height: 20),
                            _buildSectionTitle('Recent Appointments'),
                            _buildAppointmentsTable(),
                            const SizedBox(height: 20),
                            _buildSectionTitle('System Tables Overview'),
                            _buildTablesOverview(),
                          ],
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildStatRow(String label, Object value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value.toString()),
        ],
      ),
    );
  }

  Widget _buildUsersTable() {
    if (_users.isEmpty) {
      return const Text('No users found.');
    }
    return Card(
      child: Column(
        children: _users.map((user) {
          final name = '${user['first_name'] ?? ''} ${user['last_name'] ?? ''}'.trim();
          return ListTile(
            leading: const Icon(Icons.person),
            title: Text(name.isEmpty ? (user['email'] ?? '') : name),
            subtitle: Text(user['email'] ?? ''),
            trailing: Text(user['role'] ?? ''),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildAppointmentsTable() {
    if (_appointments.isEmpty) {
      return const Text('No appointments found.');
    }
    return Card(
      child: Column(
        children: _appointments.map((apt) {
          final doctor = apt['doctor_name'] ?? apt['doctorName'] ?? '';
          final patient = apt['patient_name'] ?? apt['patientName'] ?? '';
          final status = apt['status'] ?? '';
          final date = apt['appointment_date'] ?? '';
          return ListTile(
            leading: const Icon(Icons.calendar_today),
            title: Text('$doctor • $patient'),
            subtitle: Text(date.toString()),
            trailing: Text(status.toString()),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSecurityMetrics() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSecurityRow('Authentication', 'JWT + Refresh Tokens', Icons.lock, Colors.green),
        _buildSecurityRow('Data Encryption', 'AES-256-GCM', Icons.lock_outline, Colors.blue),
        _buildSecurityRow('Audit Logging', 'All actions logged', Icons.assignment, Colors.orange),
        _buildSecurityRow('Rate Limiting', 'IP-based protection', Icons.speed, Colors.purple),
        _buildSecurityRow('SQL Injection Protection', 'Parameterized queries', Icons.shield, Colors.red),
        _buildSecurityRow('XSS Protection', 'Helmet.js enabled', Icons.security, Colors.teal),
        const SizedBox(height: 8),
        const Text(
          'All security events are logged and monitored. Database access is restricted to authenticated developers/admins only.',
          style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
        ),
      ],
    );
  }

  Widget _buildSecurityRow(String label, String value, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Text(
            value,
            style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildTablesOverview() {
    final tables = [
      {'name': 'users', 'description': 'System users and authentication'},
      {'name': 'doctors', 'description': 'Doctor profiles and specialties'},
      {'name': 'patients', 'description': 'Patient profiles and medical info'},
      {'name': 'appointments', 'description': 'Appointment bookings and scheduling'},
      {'name': 'payments', 'description': 'Payment transactions and records'},
      {'name': 'medical_records', 'description': 'Patient medical history'},
      {'name': 'audit_logs', 'description': 'Security and compliance logs'},
      {'name': 'tenants', 'description': 'Multi-tenant organization data'},
      {'name': 'notifications', 'description': 'System notifications'},
      {'name': 'doctor_subscriptions', 'description': 'Subscription management'},
    ];

    return Card(
      child: Column(
        children: tables.map((table) {
          return ListTile(
            leading: const Icon(Icons.storage, size: 20),
            title: Text(table['name']!),
            subtitle: Text(table['description']!),
            trailing: const Icon(Icons.chevron_right, size: 16),
          );
        }).toList(),
      ),
    );
  }
}

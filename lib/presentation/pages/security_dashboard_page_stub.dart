import 'package:flutter/material.dart';
import '../widgets/dashboard_sidebar.dart';
import '../../core/theme/app_colors.dart';
import '../../services/admin_service.dart';

class SecurityDashboardPage extends StatefulWidget {
  const SecurityDashboardPage({super.key});

  @override
  State<SecurityDashboardPage> createState() => _SecurityDashboardPageState();
}

class _SecurityDashboardPageState extends State<SecurityDashboardPage> {
  final AdminService _adminService = AdminService();

  bool _isLoading = false;
  Map<String, dynamic> _permissions = {};
  List<Map<String, dynamic>> _activityLogs = [];

  @override
  void initState() {
    super.initState();
    _loadSecurityData();
  }

  Future<void> _loadSecurityData() async {
    setState(() => _isLoading = true);
    try {
      final permissions = await _adminService.getPermissions();
      final logs = await _adminService.getActivityLogs(limit: 50);
      if (mounted) {
        setState(() {
          _permissions = permissions;
          _activityLogs = logs;
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
    return Scaffold(
      body: SafeArea(
        child: Row(
          children: [
            const DashboardSidebar(currentRoute: '/security-dashboard', role: 'admin'),
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
                                  'Security Dashboard (Web)',
                                  style: TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                ElevatedButton.icon(
                                  onPressed: _loadSecurityData,
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
                                      'System Permissions',
                                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 12),
                                    _buildPermissionRow('Doctor Payments', _permissions['doctor_payments_enabled']),
                                    _buildPermissionRow('Patient Payments', _permissions['patient_payments_enabled']),
                                    _buildPermissionRow('SMS Service', _permissions['sms_enabled']),
                                    _buildPermissionRow('Email Notifications', _permissions['email_notifications_enabled']),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            const Text(
                              'Recent Activity Logs',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 12),
                            _buildLogsList(),
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

  Widget _buildPermissionRow(String label, dynamic value) {
    final isEnabled = value == true;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Chip(
            label: Text(isEnabled ? 'Enabled' : 'Disabled'),
            backgroundColor: isEnabled ? Colors.green.shade100 : Colors.red.shade100,
          ),
        ],
      ),
    );
  }

  Widget _buildLogsList() {
    if (_activityLogs.isEmpty) {
      return const Text('No activity logs found.');
    }
    return Card(
      child: Column(
        children: _activityLogs.map((log) {
          final action = log['action']?.toString() ?? 'Unknown';
          final category = log['category']?.toString() ?? '';
          final createdAt = log['created_at']?.toString() ?? '';
          return ListTile(
            leading: const Icon(Icons.security),
            title: Text(action),
            subtitle: Text(category),
            trailing: Text(createdAt),
          );
        }).toList(),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../widgets/dashboard_sidebar.dart';
import '../../services/admin_service.dart';

/// Cyber Security Activity Monitoring Screen
/// Developer can see all system activity and security events
class CyberSecurityPage extends StatefulWidget {
  const CyberSecurityPage({Key? key}) : super(key: key);

  @override
  State<CyberSecurityPage> createState() => _CyberSecurityPageState();
}

class _CyberSecurityPageState extends State<CyberSecurityPage> {
  final AdminService _adminService = AdminService();
  List<Map<String, dynamic>> _activityLogs = [];
  bool _isLoading = true;
  String _selectedFilter = 'הכל';

  @override
  void initState() {
    super.initState();
    _loadActivityLogs();
    _setupRealTimeUpdates();
  }

  void _setupRealTimeUpdates() {
    Future.delayed(const Duration(seconds: 10), () {
      if (mounted) {
        _loadActivityLogs();
        _setupRealTimeUpdates(); // Continue updating
      }
    });
  }

  Future<void> _loadActivityLogs() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final logs = await _adminService.getActivityLogs();
      if (mounted) {
        setState(() {
          _activityLogs = logs;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  List<Map<String, dynamic>> get _filteredLogs {
    if (_selectedFilter == 'הכל') {
      return _activityLogs;
    }
    return _activityLogs.where((log) {
      final action = log['action']?.toString().toLowerCase() ?? '';
      final category = log['category']?.toString().toLowerCase() ?? '';
      return action.contains(_selectedFilter.toLowerCase()) ||
          category.contains(_selectedFilter.toLowerCase());
    }).toList();
  }

  Color _getSeverityColor(String? severity) {
    switch (severity?.toLowerCase()) {
      case 'critical':
      case 'error':
        return Colors.red;
      case 'warning':
        return Colors.orange;
      case 'info':
        return Colors.blue;
      case 'success':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  IconData _getActionIcon(String? action) {
    final actionStr = action?.toLowerCase() ?? '';
    if (actionStr.contains('login')) return Icons.login;
    if (actionStr.contains('logout')) return Icons.logout;
    if (actionStr.contains('create')) return Icons.add_circle;
    if (actionStr.contains('update')) return Icons.edit;
    if (actionStr.contains('delete')) return Icons.delete;
    if (actionStr.contains('payment')) return Icons.payment;
    if (actionStr.contains('appointment')) return Icons.calendar_today;
    return Icons.info;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Row(
          children: [
            // Sidebar
            const DashboardSidebar(currentRoute: '/cyber-security', role: 'developer'),
            
            // Main Content
            Expanded(
              child: Container(
                color: AppColors.backgroundLight,
                child: Column(
                  children: [
                    // Header
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            spreadRadius: 1,
                            blurRadius: 5,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'ניטור אבטחה - Cyber Security Monitoring',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Row(
                            children: [
                              // Filter dropdown
                              DropdownButton<String>(
                                value: _selectedFilter,
                                items: ['הכל', 'התחברות', 'תשלומים', 'תורים', 'משתמשים', 'שגיאות']
                                    .map((filter) => DropdownMenuItem(
                                          value: filter,
                                          child: Text(filter),
                                        ))
                                    .toList(),
                                onChanged: (value) {
                                  setState(() {
                                    _selectedFilter = value!;
                                  });
                                },
                              ),
                              const SizedBox(width: 10),
                              IconButton(
                                icon: const Icon(Icons.refresh),
                                onPressed: _loadActivityLogs,
                                tooltip: 'רענן',
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    
                    // Activity Logs List
                    Expanded(
                      child: _isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : _filteredLogs.isEmpty
                              ? const Center(
                                  child: Text(
                                    'אין פעילות להצגה',
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.grey,
                                    ),
                                  ),
                                )
                              : ListView.builder(
                                  padding: const EdgeInsets.all(16),
                                  itemCount: _filteredLogs.length,
                                  itemBuilder: (context, index) {
                                    final log = _filteredLogs[index];
                                    final severity = log['severity']?.toString() ?? 'info';
                                    final action = log['action']?.toString() ?? 'Unknown';
                                    final user = log['user']?.toString() ?? 'System';
                                    final timestamp = log['timestamp']?.toString() ?? '';
                                    final details = log['details']?.toString() ?? '';

                                    return Card(
                                      margin: const EdgeInsets.only(bottom: 12),
                                      child: ListTile(
                                        leading: Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: _getSeverityColor(severity).withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Icon(
                                            _getActionIcon(action),
                                            color: _getSeverityColor(severity),
                                          ),
                                        ),
                                        title: Text(
                                          action,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        subtitle: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text('משתמש: $user'),
                                            if (timestamp.isNotEmpty) Text('זמן: $timestamp'),
                                            if (details.isNotEmpty)
                                              Padding(
                                                padding: const EdgeInsets.only(top: 4),
                                                child: Text(
                                                  details,
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.grey.shade600,
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                        trailing: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: _getSeverityColor(severity),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                            severity.toUpperCase(),
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}



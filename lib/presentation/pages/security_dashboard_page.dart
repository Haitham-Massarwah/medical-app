import 'package:flutter/material.dart';
import '../../core/security/audit_logging_service.dart';
import '../../core/security/security_testing_service.dart';

class SecurityDashboardPage extends StatefulWidget {
  const SecurityDashboardPage({super.key});

  @override
  State<SecurityDashboardPage> createState() => _SecurityDashboardPageState();
}

class _SecurityDashboardPageState extends State<SecurityDashboardPage> {
  final AuditLoggingService _auditService = AuditLoggingService();
  final SecurityTestingService _securityTestingService = SecurityTestingService();
  
  bool _isLoading = false;
  List<SecurityAlert> _securityAlerts = [];
  List<AuditLogEntry> _recentLogs = [];
  SecurityTestReport? _securityReport;
  Map<String, int> _eventStats = {};

  // FR-17: Download permission check
  bool _canDownload = false;

  @override
  void initState() {
    super.initState();
    _checkDownloadPermission();
    _loadSecurityData();
  }

  // FR-17: Check if user has download permission
  Future<void> _checkDownloadPermission() async {
    // In production, check user role/permissions
    // For now, admin has download access
    setState(() {
      _canDownload = true; // Admin can download
    });
  }

  // FR-17-18: Download with permission check
  Future<void> _downloadSecurityReport() async {
    if (!_canDownload) {
      // FR-18: Clear restriction message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('אין לך הרשאה להוריד קבצים. פנה למנהל המערכת.'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }
    
    // Proceed with download
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('מוריד דוח אבטחה...'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  // FR-19: Security explanation widget
  Widget _buildSecurityExplanationCard() {
    return Card(
      color: Colors.blue.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.info, color: Colors.blue, size: 24),
                SizedBox(width: 12),
                Text(
                  'מה זה לוח האבטחה?',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'לוח האבטחה מספק מעקב בזמן אמת אחר אירועי אבטחה, התראות וניטור פעילות במערכת.',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 12),
            const Text(
              'תכונות:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildFeatureItem('🔒 הצפנת מידע - כל המידע מוצפן בתקן AES-256'),
            _buildFeatureItem('🛡️ גיבויים אוטומטיים - גיבוי יומי של כל הנתונים'),
            _buildFeatureItem('👁️ מעקב פעילות - כל פעולה נרשמת ביומן'),
            _buildFeatureItem('⚠️ התראות - עדכון מיידי על אירועי אבטחה'),
            _buildFeatureItem('🔍 בדיקות אבטחה - סריקה אוטומטית לחולשות'),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4, right: 8),
      child: Text(text, style: const TextStyle(fontSize: 13)),
    );
  }

  // FR-19: Test Security Button Widget
  Widget _buildTestSecurityButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _isLoading ? null : _showSecurityTestDialog,
        icon: const Icon(Icons.security),
        label: const Text(
          'בצע בדיקת אבטחה מלאה',
          style: TextStyle(fontSize: 16),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  // FR-19: Security Test Dialog with explanation
  void _showSecurityTestDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('בדיקת אבטחה'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('בדיקת האבטחה תכלול:'),
            SizedBox(height: 12),
            Text('✓ בדיקת הצפנת מסד נתונים'),
            Text('✓ בדיקת חולשות ידועות'),
            Text('✓ בדיקת הרשאות גישה'),
            Text('✓ בדיקת גיבויים'),
            Text('✓ בדיקת רישום פעילות'),
            SizedBox(height: 12),
            Text(
              'הבדיקה תימשך כ-10 שניות',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ביטול'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _runSecurityTests();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('הפעל בדיקה'),
          ),
        ],
      ),
    );
  }

  Future<void> _loadSecurityData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _auditService.initialize();
      await _securityTestingService.runSecurityTests().then((report) {
        setState(() {
          _securityReport = report;
        });
      });

      // Load security alerts
      final alerts = await _auditService.getSecurityAlerts();
      
      // Load recent audit logs
      final logs = await _auditService.getUserAuditLogs(
        userId: 'all',
        limit: 50,
      );
      
      // Load event statistics
      final report = await _auditService.generateAuditReport(
        startDate: DateTime.now().subtract(const Duration(days: 7)),
        endDate: DateTime.now(),
      );

      setState(() {
        _securityAlerts = alerts;
        _recentLogs = logs;
        _eventStats = report.eventTypes;
      });
    } catch (e) {
      _showError('Failed to load security data: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Security Dashboard'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadSecurityData,
            tooltip: 'Refresh',
          ),
          IconButton(
            icon: const Icon(Icons.security),
            onPressed: _runSecurityTests,
            tooltip: 'Run Security Tests',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // FR-19: Security Explanation Card
                  _buildSecurityExplanationCard(),
                  
                  const SizedBox(height: 16),
                  
                  // FR-19: Security Test Button
                  _buildTestSecurityButton(),
                  
                  const SizedBox(height: 24),
                  
                  // Security Overview Cards
                  _buildSecurityOverviewCards(),
                  
                  const SizedBox(height: 24),
                  
                  // Security Alerts
                  _buildSecurityAlertsSection(),
                  
                  const SizedBox(height: 24),
                  
                  // Recent Activity
                  _buildRecentActivitySection(),
                  
                  const SizedBox(height: 24),
                  
                  // Security Test Results
                  if (_securityReport != null) _buildSecurityTestResults(),
                ],
              ),
            ),
    );
  }

  Widget _buildSecurityOverviewCards() {
    return Row(
      children: [
        Expanded(
          child: _buildOverviewCard(
            'Security Alerts',
            _securityAlerts.length.toString(),
            Icons.warning,
            _securityAlerts.isEmpty ? Colors.green : Colors.orange,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildOverviewCard(
            'Recent Events',
            _recentLogs.length.toString(),
            Icons.timeline,
            Colors.blue,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildOverviewCard(
            'Test Status',
            _securityReport?.passedTests.toString() ?? '0',
            Icons.check_circle,
            _getTestStatusColor(),
          ),
        ),
      ],
    );
  }

  Widget _buildOverviewCard(String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSecurityAlertsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Security Alerts',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (_securityAlerts.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${_securityAlerts.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            if (_securityAlerts.isEmpty)
              const Text(
                'No security alerts',
                style: TextStyle(color: Colors.grey),
              )
            else
              ..._securityAlerts.take(5).map((alert) => _buildAlertItem(alert)),
          ],
        ),
      ),
    );
  }

  Widget _buildAlertItem(SecurityAlert alert) {
    Color severityColor;
    switch (alert.severity) {
      case 'HIGH':
        severityColor = Colors.red;
        break;
      case 'MEDIUM':
        severityColor = Colors.orange;
        break;
      case 'LOW':
        severityColor = Colors.yellow;
        break;
      default:
        severityColor = Colors.grey;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: severityColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: severityColor.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.warning,
                color: severityColor,
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                alert.eventType,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: severityColor,
                ),
              ),
              const Spacer(),
              Text(
                '${alert.count} occurrences',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            alert.action,
            style: const TextStyle(fontSize: 14),
          ),
          Text(
            'First: ${_formatDateTime(alert.firstOccurrence)}',
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivitySection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Recent Activity',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (_recentLogs.isEmpty)
              const Text(
                'No recent activity',
                style: TextStyle(color: Colors.grey),
              )
            else
              ..._recentLogs.take(10).map((log) => _buildLogItem(log)),
          ],
        ),
      ),
    );
  }

  Widget _buildLogItem(AuditLogEntry log) {
    Color severityColor;
    switch (log.severity) {
      case 'HIGH':
        severityColor = Colors.red;
        break;
      case 'MEDIUM':
        severityColor = Colors.orange;
        break;
      case 'LOW':
        severityColor = Colors.green;
        break;
      default:
        severityColor = Colors.grey;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: severityColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: severityColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${log.eventType} - ${log.action}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  'User: ${log.userId}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                Text(
                  _formatDateTime(log.timestamp),
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          Text(
            log.severity,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: severityColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityTestResults() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Security Test Results',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // Test Summary
            Row(
              children: [
                Expanded(
                  child: _buildTestStatCard(
                    'Total Tests',
                    _securityReport!.totalTests.toString(),
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildTestStatCard(
                    'Passed',
                    _securityReport!.passedTests.toString(),
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildTestStatCard(
                    'Failed',
                    _securityReport!.failedTests.toString(),
                    Colors.red,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Vulnerabilities
            if (_securityReport!.vulnerabilities.isNotEmpty) ...[
              const Text(
                'Vulnerabilities',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              ..._securityReport!.vulnerabilities.map((vuln) => _buildVulnerabilityItem(vuln)),
            ],
            
            const SizedBox(height: 16),
            
            // Recommendations
            if (_securityReport!.recommendations.isNotEmpty) ...[
              const Text(
                'Recommendations',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              ..._securityReport!.recommendations.take(5).map((rec) => _buildRecommendationItem(rec)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTestStatCard(String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildVulnerabilityItem(SecurityVulnerability vuln) {
    Color severityColor;
    switch (vuln.severity) {
      case 'CRITICAL':
        severityColor = Colors.red;
        break;
      case 'HIGH':
        severityColor = Colors.orange;
        break;
      case 'MEDIUM':
        severityColor = Colors.yellow;
        break;
      case 'LOW':
        severityColor = Colors.green;
        break;
      default:
        severityColor = Colors.grey;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: severityColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: severityColor.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                vuln.type,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: severityColor,
                ),
              ),
              const Spacer(),
              Text(
                vuln.severity,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: severityColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(vuln.description),
          const SizedBox(height: 4),
          Text(
            'Recommendation: ${vuln.recommendation}',
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationItem(String recommendation) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          const Icon(Icons.check_circle, size: 16, color: Colors.blue),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              recommendation,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Color _getTestStatusColor() {
    if (_securityReport == null) return Colors.grey;
    
    final passRate = _securityReport!.passedTests / _securityReport!.totalTests;
    if (passRate >= 0.9) return Colors.green;
    if (passRate >= 0.7) return Colors.orange;
    return Colors.red;
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _runSecurityTests() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Run security tests
      final report = await _securityTestingService.runSecurityTests();
      
      // Reload all security data
      await _auditService.initialize();
      final alerts = await _auditService.getSecurityAlerts();
      final logs = await _auditService.getUserAuditLogs(
        userId: 'all',
        limit: 50,
      );
      final auditReport = await _auditService.generateAuditReport(
        startDate: DateTime.now().subtract(const Duration(days: 7)),
        endDate: DateTime.now(),
      );
      
      setState(() {
        _securityReport = report;
        _securityAlerts = alerts;
        _recentLogs = logs;
        _eventStats = auditReport.eventTypes;
      });
      _showSuccess('Security tests completed and data refreshed');
    } catch (e) {
      _showError('Failed to run security tests: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }
}



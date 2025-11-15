import 'package:flutter/material.dart';
import 'dart:html' as html;
import 'dart:convert';
import 'security_settings_enhanced.dart';

class SecurityDashboardEnhancedPage extends StatefulWidget {
  const SecurityDashboardEnhancedPage({super.key});

  @override
  State<SecurityDashboardEnhancedPage> createState() => _SecurityDashboardEnhancedPageState();
}

class _SecurityDashboardEnhancedPageState extends State<SecurityDashboardEnhancedPage> {
  final List<Map<String, dynamic>> _securityEvents = [
    {
      'type': 'Login',
      'user': 'developer@medicalapp.com',
      'time': '2024-01-15 10:30:00',
      'status': 'Success',
      'severity': 'Low',
      'ip': '192.168.1.105',
      'details': 'Successful login with 2FA enabled',
    },
    {
      'type': 'Payment',
      'user': 'customer@medicalapp.com',
      'time': '2024-01-15 10:25:00',
      'status': 'Success',
      'severity': 'Medium',
      'ip': '192.168.1.101',
      'details': 'Payment processed successfully - 300.00 ILS',
    },
    {
      'type': 'Failed Login',
      'user': 'unknown@email.com',
      'time': '2024-01-15 10:20:00',
      'status': 'Failed',
      'severity': 'High',
      'ip': '192.168.1.100',
      'details': 'Multiple failed login attempts detected',
    },
    {
      'type': 'Data Access',
      'user': 'doctor@medicalapp.com',
      'time': '2024-01-15 10:15:00',
      'status': 'Success',
      'severity': 'Low',
      'ip': '192.168.1.104',
      'details': 'Patient data accessed - P12345',
    },
    {
      'type': 'Security Scan',
      'user': 'system',
      'time': '2024-01-15 10:10:00',
      'status': 'Success',
      'severity': 'Low',
      'ip': 'localhost',
      'details': 'Automated security scan completed - No threats found',
    },
    {
      'type': 'Suspicious Activity',
      'user': 'patient@example.com',
      'time': '2024-01-15 10:05:00',
      'status': 'Alert',
      'severity': 'High',
      'ip': '192.168.1.102',
      'details': 'Unusual data access pattern detected',
    },
  ];

  bool _isScanning = false;
  bool _isGeneratingReport = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('לוח אבטחה'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshDashboard,
            tooltip: 'רענן לוח אבטחה',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Security Overview Cards
            _buildSecurityOverview(),
            
            const SizedBox(height: 24),
            
            // Security Events
            _buildSecurityEvents(),
            
            const SizedBox(height: 24),
            
            // Security Actions
            _buildSecurityActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildSecurityOverview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'סקירת אבטחה',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.red,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildSecurityCard(
                'אירועי אבטחה',
                '${_securityEvents.length}',
                Icons.security,
                Colors.red,
                subtitle: '${_securityEvents.where((e) => e['severity'] == 'High').length} קריטיים',
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildSecurityCard(
                'התראות פעילות',
                '${_securityEvents.where((e) => e['severity'] == 'High' || e['severity'] == 'Medium').length}',
                Icons.warning,
                Colors.orange,
                subtitle: '${_securityEvents.where((e) => e['status'] == 'Alert').length} התראות',
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildSecurityCard(
                'משתמשים מחוברים',
                '${_securityEvents.where((e) => e['type'] == 'Login' && e['status'] == 'Success').length}',
                Icons.people,
                Colors.green,
                subtitle: 'פעילים כעת',
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildSecurityCard(
                'סטטוס מערכת',
                'פעיל',
                Icons.check_circle,
                Colors.blue,
                subtitle: 'כל השירותים פועלים',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSecurityCard(String title, String value, IconData icon, Color color, {String? subtitle}) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSecurityEvents() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'אירועי אבטחה אחרונים',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton.icon(
              onPressed: _viewAllEvents,
              icon: const Icon(Icons.list, size: 16),
              label: const Text('הצג הכל'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Card(
          child: Column(
            children: _securityEvents.take(4).map((event) => _buildEventItem(event)).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildEventItem(Map<String, dynamic> event) {
    Color statusColor = event['status'] == 'Success' ? Colors.green : 
                       event['status'] == 'Alert' ? Colors.orange : Colors.red;
    Color severityColor = event['severity'] == 'High' ? Colors.red : 
                         event['severity'] == 'Medium' ? Colors.orange : Colors.green;

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: statusColor.withOpacity(0.2),
        child: Icon(
          event['type'] == 'Login' ? Icons.login :
          event['type'] == 'Payment' ? Icons.payment :
          event['type'] == 'Failed Login' ? Icons.block :
          event['type'] == 'Data Access' ? Icons.data_usage :
          event['type'] == 'Security Scan' ? Icons.scanner :
          Icons.warning,
          color: statusColor,
        ),
      ),
      title: Text(event['type']),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('משתמש: ${event['user']}'),
          Text('זמן: ${event['time']}'),
          if (event['details'] != null)
            Text('פרטים: ${event['details']}', 
              style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        ],
      ),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: severityColor.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          event['severity'],
          style: TextStyle(
            color: severityColor,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
      onTap: () => _showEventDetails(event),
    );
  }

  Widget _buildSecurityActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'פעולות אבטחה',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _isScanning ? null : _runSecurityScan,
                icon: _isScanning 
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.scanner),
                label: Text(_isScanning ? 'סורק...' : 'סריקת אבטחה'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _isGeneratingReport ? null : _generateReport,
                icon: _isGeneratingReport 
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.assessment),
                label: Text(_isGeneratingReport ? 'יוצר דוח...' : 'דוח אבטחה'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _viewSystemLogs,
                icon: const Icon(Icons.list_alt),
                label: const Text('יומני מערכת'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _openSecuritySettings,
                icon: const Icon(Icons.settings),
                label: const Text('הגדרות'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _refreshDashboard() {
    setState(() {
      // In a real app, this would refresh data from the server
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('לוח האבטחה רוענן'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _runSecurityScan() async {
    setState(() {
      _isScanning = true;
    });

    // Show scanning dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('סריקת אבטחה'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            const Text('מבצע סריקת אבטחה מקיפה...'),
            const SizedBox(height: 8),
            const Text('• בדיקת חולשות אבטחה'),
            const Text('• סריקת איומים'),
            const Text('• בדיקת הרשאות'),
            const Text('• ניתוח יומנים'),
          ],
        ),
      ),
    );

    // Simulate scan process
    await Future.delayed(const Duration(seconds: 3));

    // Close dialog
    Navigator.of(context).pop();

    setState(() {
      _isScanning = false;
    });

    // Show results
    _showScanResults();
  }

  void _showScanResults() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.green),
            const SizedBox(width: 8),
            const Text('תוצאות סריקה'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('סריקת האבטחה הושלמה בהצלחה!', 
              style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _buildScanResultItem('חולשות אבטחה', '0 נמצאו', Colors.green),
            _buildScanResultItem('איומים פעילים', '0 נמצאו', Colors.green),
            _buildScanResultItem('הרשאות לא תקינות', '0 נמצאו', Colors.green),
            _buildScanResultItem('יומנים חשודים', '2 נמצאו', Colors.orange),
            const SizedBox(height: 16),
            const Text('המלצות:', style: TextStyle(fontWeight: FontWeight.bold)),
            const Text('• המשך ניטור יומנים חשודים'),
            const Text('• עדכן הגדרות התראות'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('סגור'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _downloadScanReport();
            },
            child: const Text('הורד דוח'),
          ),
        ],
      ),
    );
  }

  Widget _buildScanResultItem(String title, String result, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title),
          Text(result, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  void _generateReport() async {
    setState(() {
      _isGeneratingReport = true;
    });

    // Show generating dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('יוצר דוח אבטחה'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            const Text('יוצר דוח אבטחה מפורט...'),
            const SizedBox(height: 8),
            const Text('• איסוף נתונים'),
            const Text('• ניתוח מגמות'),
            const Text('• יצירת המלצות'),
            const Text('• עיצוב דוח'),
          ],
        ),
      ),
    );

    // Simulate report generation
    await Future.delayed(const Duration(seconds: 4));

    // Close dialog
    Navigator.of(context).pop();

    setState(() {
      _isGeneratingReport = false;
    });

    // Show report generated
    _showReportGenerated();
  }

  void _showReportGenerated() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.assessment, color: Colors.green),
            const SizedBox(width: 8),
            const Text('דוח אבטחה נוצר'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('דוח האבטחה נוצר בהצלחה!', 
              style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _buildReportStat('סה"כ אירועים', '${_securityEvents.length}'),
            _buildReportStat('אירועים קריטיים', '${_securityEvents.where((e) => e['severity'] == 'High').length}'),
            _buildReportStat('התראות פעילות', '${_securityEvents.where((e) => e['status'] == 'Alert').length}'),
            _buildReportStat('משתמשים פעילים', '${_securityEvents.where((e) => e['type'] == 'Login' && e['status'] == 'Success').length}'),
            const SizedBox(height: 16),
            const Text('הדוח כולל:', style: TextStyle(fontWeight: FontWeight.bold)),
            const Text('• ניתוח מפורט של כל האירועים'),
            const Text('• המלצות אבטחה מותאמות'),
            const Text('• סטטיסטיקות שימוש'),
            const Text('• תוכנית פעולה מומלצת'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('סגור'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _downloadSecurityReport();
            },
            child: const Text('הורד דוח'),
          ),
        ],
      ),
    );
  }

  Widget _buildReportStat(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  void _viewSystemLogs() {
    Navigator.pushNamed(context, '/system-logs');
  }

  void _openSecuritySettings() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SecuritySettingsEnhancedPage(),
      ),
    );
  }


  void _viewAllEvents() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('כל אירועי האבטחה'),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: ListView.builder(
            itemCount: _securityEvents.length,
            itemBuilder: (context, index) {
              final event = _securityEvents[index];
              return _buildEventItem(event);
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('סגור'),
          ),
        ],
      ),
    );
  }

  void _showEventDetails(Map<String, dynamic> event) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('פרטי אירוע: ${event['type']}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('סוג אירוע', event['type']),
            _buildDetailRow('משתמש', event['user']),
            _buildDetailRow('זמן', event['time']),
            _buildDetailRow('סטטוס', event['status']),
            _buildDetailRow('חומרה', event['severity']),
            _buildDetailRow('כתובת IP', event['ip']),
            _buildDetailRow('פרטים', event['details']),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('סגור'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text('$label:', style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  void _downloadScanReport() {
    final reportData = {
      'scan_date': DateTime.now().toIso8601String(),
      'total_events': _securityEvents.length,
      'critical_events': _securityEvents.where((e) => e['severity'] == 'High').length,
      'medium_events': _securityEvents.where((e) => e['severity'] == 'Medium').length,
      'low_events': _securityEvents.where((e) => e['severity'] == 'Low').length,
      'recommendations': [
        'המשך ניטור יומנים חשודים',
        'עדכן הגדרות התראות',
        'בצע סריקות אבטחה שבועיות',
        'עדכן הגדרות הרשאות',
      ],
    };

    final content = const JsonEncoder.withIndent('  ').convert(reportData);
    final blob = html.Blob([content], 'application/json');
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.AnchorElement(href: url)
      ..setAttribute('download', 'security_scan_report_${DateTime.now().millisecondsSinceEpoch}.json')
      ..style.display = 'none';
    
    html.document.body?.children.add(anchor);
    anchor.click();
    html.document.body?.children.remove(anchor);
    html.Url.revokeObjectUrl(url);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('דוח הסריקה הורד בהצלחה')),
    );
  }

  void _downloadSecurityReport() {
    final reportData = {
      'report_date': DateTime.now().toIso8601String(),
      'security_events': _securityEvents,
      'summary': {
        'total_events': _securityEvents.length,
        'critical_events': _securityEvents.where((e) => e['severity'] == 'High').length,
        'medium_events': _securityEvents.where((e) => e['severity'] == 'Medium').length,
        'low_events': _securityEvents.where((e) => e['severity'] == 'Low').length,
        'active_users': _securityEvents.where((e) => e['type'] == 'Login' && e['status'] == 'Success').length,
      },
      'recommendations': [
        'המשך ניטור יומנים חשודים',
        'עדכן הגדרות התראות',
        'בצע סריקות אבטחה שבועיות',
        'עדכן הגדרות הרשאות',
        'הפעל הצפנת נתונים',
      ],
    };

    final content = const JsonEncoder.withIndent('  ').convert(reportData);
    final blob = html.Blob([content], 'application/json');
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.AnchorElement(href: url)
      ..setAttribute('download', 'security_report_${DateTime.now().millisecondsSinceEpoch}.json')
      ..style.display = 'none';
    
    html.document.body?.children.add(anchor);
    anchor.click();
    html.document.body?.children.remove(anchor);
    html.Url.revokeObjectUrl(url);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('דוח האבטחה הורד בהצלחה')),
    );
  }
}

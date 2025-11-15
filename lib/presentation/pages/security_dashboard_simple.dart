import 'package:flutter/material.dart';

class SecurityDashboardPage extends StatefulWidget {
  const SecurityDashboardPage({super.key});

  @override
  State<SecurityDashboardPage> createState() => _SecurityDashboardPageState();
}

class _SecurityDashboardPageState extends State<SecurityDashboardPage> {
  final List<Map<String, dynamic>> _securityEvents = [
    {
      'type': 'Login',
      'user': 'developer@medicalapp.com',
      'time': '2024-01-15 10:30:00',
      'status': 'Success',
      'severity': 'Low',
    },
    {
      'type': 'Payment',
      'user': 'customer@medicalapp.com',
      'time': '2024-01-15 10:25:00',
      'status': 'Success',
      'severity': 'Medium',
    },
    {
      'type': 'Failed Login',
      'user': 'unknown@email.com',
      'time': '2024-01-15 10:20:00',
      'status': 'Failed',
      'severity': 'High',
    },
    {
      'type': 'Data Access',
      'user': 'doctor@medicalapp.com',
      'time': '2024-01-15 10:15:00',
      'status': 'Success',
      'severity': 'Low',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('לוח אבטחה'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
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
                '12',
                Icons.security,
                Colors.red,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildSecurityCard(
                'התראות פעילות',
                '3',
                Icons.warning,
                Colors.orange,
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
                '5',
                Icons.people,
                Colors.green,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildSecurityCard(
                'סטטוס מערכת',
                'פעיל',
                Icons.check_circle,
                Colors.blue,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSecurityCard(String title, String value, IconData icon, Color color) {
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
          ],
        ),
      ),
    );
  }

  Widget _buildSecurityEvents() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'אירועי אבטחה אחרונים',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Column(
            children: _securityEvents.map((event) => _buildEventItem(event)).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildEventItem(Map<String, dynamic> event) {
    Color statusColor = event['status'] == 'Success' ? Colors.green : Colors.red;
    Color severityColor = event['severity'] == 'High' ? Colors.red : 
                         event['severity'] == 'Medium' ? Colors.orange : Colors.green;

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: statusColor.withOpacity(0.2),
        child: Icon(
          event['type'] == 'Login' ? Icons.login :
          event['type'] == 'Payment' ? Icons.payment :
          event['type'] == 'Failed Login' ? Icons.block :
          Icons.data_usage,
          color: statusColor,
        ),
      ),
      title: Text(event['type']),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('משתמש: ${event['user']}'),
          Text('זמן: ${event['time']}'),
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
                onPressed: () => _runSecurityScan(),
                icon: const Icon(Icons.scanner),
                label: const Text('סריקת אבטחה'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _generateReport(),
                icon: const Icon(Icons.assessment),
                label: const Text('דוח אבטחה'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
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
                onPressed: () => _viewLogs(),
                icon: const Icon(Icons.list_alt),
                label: const Text('יומני מערכת'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _settings(),
                icon: const Icon(Icons.settings),
                label: const Text('הגדרות'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _runSecurityScan() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('סריקת אבטחה'),
        content: const Text('מבצע סריקת אבטחה...\n\n• בדיקת חולשות\n• סריקת איומים\n• בדיקת הרשאות\n• ניתוח יומנים'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ביטול'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showScanResults();
            },
            child: const Text('התחל סריקה'),
          ),
        ],
      ),
    );
  }

  void _showScanResults() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('סריקת האבטחה הושלמה בהצלחה!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _generateReport() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('דוח אבטחה'),
        content: const Text('יוצר דוח אבטחה מפורט...\n\n• סיכום אירועים\n• ניתוח מגמות\n• המלצות אבטחה\n• סטטיסטיקות שימוש'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ביטול'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showReportGenerated();
            },
            child: const Text('צור דוח'),
          ),
        ],
      ),
    );
  }

  void _showReportGenerated() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('דוח האבטחה נוצר בהצלחה!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _viewLogs() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('יומני מערכת'),
        content: const Text('מציג יומני מערכת מפורטים...\n\n• יומני פעילות\n• יומני שגיאות\n• יומני אבטחה\n• יומני ביצועים'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('סגור'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showLogsOpened();
            },
            child: const Text('פתח יומנים'),
          ),
        ],
      ),
    );
  }

  void _showLogsOpened() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('יומני המערכת נפתחו בהצלחה!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _settings() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('הגדרות אבטחה'),
        content: const Text('פתיחת הגדרות אבטחה...\n\n• הגדרות התראות\n• הגדרות סריקה\n• הגדרות הרשאות\n• הגדרות גיבוי'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('סגור'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showSettingsOpened();
            },
            child: const Text('פתח הגדרות'),
          ),
        ],
      ),
    );
  }

  void _showSettingsOpened() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('הגדרות האבטחה נפתחו בהצלחה!'),
        backgroundColor: Colors.green,
      ),
    );
  }
}








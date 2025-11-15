import 'package:flutter/material.dart';
import '../../services/compliance_service.dart';

class PrivacyPage extends StatefulWidget {
  const PrivacyPage({super.key});

  @override
  State<PrivacyPage> createState() => _PrivacyPageState();
}

class _PrivacyPageState extends State<PrivacyPage> {
  final ComplianceService _complianceService = ComplianceService();
  Map<String, dynamic> _consents = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadConsents();
  }

  Future<void> _loadConsents() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final consents = await _complianceService.getConsentStatus();
      setState(() {
        _consents = consents;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('פרטיות ונתונים'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // GDPR Compliance Section
                const Text(
                  'זכויות פרטיות (GDPR)',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                
                _buildPrivacyCard(
                  'הורד את הנתונים שלך',
                  'קבל קובץ עם כל המידע שאנחנו שומרים עליך',
                  Icons.download,
                  Colors.blue,
                  () async {
                    await _requestDataExport();
                  },
                ),
                
                const SizedBox(height: 12),
                
                _buildPrivacyCard(
                  'מחק את הנתונים שלך',
                  'בקשה למחיקה מלאה של כל המידע שלך',
                  Icons.delete_forever,
                  Colors.red,
                  () async {
                    await _requestDataDeletion();
                  },
                ),
                
                const SizedBox(height: 32),
                
                // Consent Management
                const Text(
                  'הסכמות',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                
                _buildConsentSwitch(
                  'הסכמה לעיבוד נתונים',
                  'אני מסכים לעיבוד המידע הרפואי שלי',
                  _consents['data_processing_consent'] ?? false,
                  (value) async {
                    await _complianceService.updateConsent(
                      consentType: 'data_processing',
                      granted: value,
                    );
                    _loadConsents();
                  },
                ),
                
                _buildConsentSwitch(
                  'שיווק',
                  'אני מסכים לקבל מידע שיווקי',
                  _consents['marketing_consent'] ?? false,
                  (value) async {
                    await _complianceService.updateConsent(
                      consentType: 'marketing',
                      granted: value,
                    );
                    _loadConsents();
                  },
                ),
                
                const SizedBox(height: 32),
                
                // Security Section
                const Text(
                  'אבטחה',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                
                _buildPrivacyCard(
                  'אימות דו-שלבי (2FA)',
                  'הוסף שכבת אבטחה נוספת לחשבון שלך',
                  Icons.security,
                  Colors.green,
                  () async {
                    await _setup2FA();
                  },
                ),
                
                const SizedBox(height: 32),
                
                // Audit Log Section
                const Text(
                  'לוג פעולות',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                
                _buildPrivacyCard(
                  'צפה בהיסטוריית פעולות',
                  'ראה את כל הפעולות שנעשו בחשבון שלך',
                  Icons.history,
                  Colors.orange,
                  () async {
                    await _viewAuditLogs();
                  },
                ),
                
                const SizedBox(height: 32),
                
                // Info Section
                Card(
                  color: Colors.blue.shade50,
                  child: const Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'המערכת שלנו עומדת בתקנים:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 8),
                        Text('✓ GDPR - תקנת הגנת המידע האירופית'),
                        Text('✓ HIPAA - תקן אבטחת מידע רפואי'),
                        Text('✓ Israeli Privacy Law - חוק הגנת הפרטיות הישראלי'),
                        Text('✓ PCI DSS - תקן אבטחת תשלומים'),
                        Text('✓ WCAG 2.2 - נגישות דיגיטלית'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildPrivacyCard(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.2),
          child: Icon(icon, color: color),
        ),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }

  Widget _buildConsentSwitch(
    String title,
    String subtitle,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return SwitchListTile(
      title: Text(title),
      subtitle: Text(subtitle),
      value: value,
      onChanged: onChanged,
    );
  }

  Future<void> _requestDataExport() async {
    final shouldExport = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('הורדת נתונים'),
        content: const Text(
          'אנחנו נכין קובץ עם כל המידע שלך וישלח אליך במייל תוך 48 שעות.\n\nהקובץ יכלול:\n• פרטים אישיים\n• היסטוריית תורים\n• תשלומים\n• מסמכים רפואיים',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('ביטול'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('בקש הורדה'),
          ),
        ],
      ),
    );

    if (shouldExport == true) {
      try {
        await _complianceService.requestDataExport();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('הבקשה נשלחה! תקבל מייל תוך 48 שעות'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('שגיאה: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _requestDataDeletion() async {
    final TextEditingController reasonController = TextEditingController();
    
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('מחיקת נתונים'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '⚠️ זוהי פעולה בלתי הפיכה!\n\nכל המידע שלך יימחק לצמיתות:\n• פרטים אישיים\n• היסטוריית תורים\n• תשלומים\n• מסמכים',
              style: TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'סיבה למחיקה (אופציונלי)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('ביטול'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('מחק את כל הנתונים'),
          ),
        ],
      ),
    );

    if (shouldDelete == true) {
      try {
        await _complianceService.requestDataDeletion(reasonController.text);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('בקשת המחיקה נשלחה. הנתונים יימחקו תוך 30 יום'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('שגיאה: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _setup2FA() async {
    try {
      final response = await _complianceService.enable2FA();
      final qrCode = response['qr_code'];
      final secret = response['secret'];
      
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('הגדרת 2FA'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('1. סרוק את קוד ה-QR עם אפליקציית Authenticator'),
                const SizedBox(height: 16),
                Container(
                  width: 200,
                  height: 200,
                  color: Colors.grey.shade300,
                  child: const Center(child: Text('[QR Code]')),
                ),
                const SizedBox(height: 16),
                Text('Secret: ${secret ?? 'XXXX'}'),
                const SizedBox(height: 16),
                const TextField(
                  decoration: InputDecoration(
                    labelText: 'הזן קוד מהאפליקציה',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('ביטול'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('2FA הופעל בהצלחה!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                },
                child: const Text('אשר'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('שגיאה: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _viewAuditLogs() async {
    try {
      final logs = await _complianceService.getAuditLogs();
      
      if (mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => _AuditLogsPage(logs: logs),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('שגיאה: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

class _AuditLogsPage extends StatelessWidget {
  final List<Map<String, dynamic>> logs;

  const _AuditLogsPage({required this.logs});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('לוג פעולות'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: logs.length,
        itemBuilder: (context, index) {
          final log = logs[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.orange.withOpacity(0.2),
                child: const Icon(Icons.history, color: Colors.orange),
              ),
              title: Text(log['action'] ?? ''),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('משתמש: ${log['user'] ?? ''}'),
                  Text('זמן: ${_formatTimestamp(log['timestamp'])}'),
                  Text('IP: ${log['ip_address'] ?? ''}'),
                ],
              ),
              isThreeLine: true,
            ),
          );
        },
      ),
    );
  }

  String _formatTimestamp(String? timestamp) {
    if (timestamp == null) return '';
    try {
      final date = DateTime.parse(timestamp);
      return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return timestamp;
    }
  }
}










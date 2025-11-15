import 'package:flutter/material.dart';

class SystemSettingsPage extends StatefulWidget {
  const SystemSettingsPage({super.key});

  @override
  State<SystemSettingsPage> createState() => _SystemSettingsPageState();
}

class _SystemSettingsPageState extends State<SystemSettingsPage> {
  bool _notificationsEnabled = true;
  bool _autoBackupEnabled = true;
  bool _securityScanEnabled = true;
  bool _maintenanceMode = false;
  
  String _selectedLanguage = 'עברית';
  String _selectedTheme = 'אור';
  String _selectedBackupFrequency = 'יומי';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('הגדרות מערכת'),
        backgroundColor: Colors.grey,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () => _saveSettings(),
            tooltip: 'שמור הגדרות',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // General Settings
            _buildGeneralSettings(),
            
            const SizedBox(height: 24),
            
            // Security Settings
            _buildSecuritySettings(),
            
            const SizedBox(height: 24),
            
            // Backup Settings
            _buildBackupSettings(),
            
            const SizedBox(height: 24),
            
            // System Status
            _buildSystemStatus(),
          ],
        ),
      ),
    );
  }

  Widget _buildGeneralSettings() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'הגדרות כלליות',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('התראות'),
              subtitle: const Text('קבל התראות על פעילות המערכת'),
              value: _notificationsEnabled,
              onChanged: (value) {
                setState(() {
                  _notificationsEnabled = value;
                });
              },
            ),
            const Divider(),
            ListTile(
              title: const Text('שפה'),
              subtitle: Text(_selectedLanguage),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () => _selectLanguage(),
            ),
            const Divider(),
            ListTile(
              title: const Text('ערכת נושא'),
              subtitle: Text(_selectedTheme),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () => _selectTheme(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSecuritySettings() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'הגדרות אבטחה',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('סריקת אבטחה אוטומטית'),
              subtitle: const Text('בצע סריקת אבטחה מדי יום'),
              value: _securityScanEnabled,
              onChanged: (value) {
                setState(() {
                  _securityScanEnabled = value;
                });
              },
            ),
            const Divider(),
            SwitchListTile(
              title: const Text('מצב תחזוקה'),
              subtitle: const Text('חסום גישה למערכת לתחזוקה'),
              value: _maintenanceMode,
              onChanged: (value) {
                setState(() {
                  _maintenanceMode = value;
                });
              },
            ),
            const Divider(),
            ListTile(
              title: const Text('הגדרות הרשאות'),
              subtitle: const Text('נהל הרשאות משתמשים'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () => _managePermissions(),
            ),
            const Divider(),
            ListTile(
              title: const Text('שינוי סיסמה'),
              subtitle: const Text('שנה את סיסמת המנהל'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () => _changePassword(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackupSettings() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'הגדרות גיבוי',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('גיבוי אוטומטי'),
              subtitle: const Text('בצע גיבוי אוטומטי של הנתונים'),
              value: _autoBackupEnabled,
              onChanged: (value) {
                setState(() {
                  _autoBackupEnabled = value;
                });
              },
            ),
            const Divider(),
            ListTile(
              title: const Text('תדירות גיבוי'),
              subtitle: Text(_selectedBackupFrequency),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () => _selectBackupFrequency(),
            ),
            const Divider(),
            ListTile(
              title: const Text('גיבוי ידני'),
              subtitle: const Text('בצע גיבוי עכשיו'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () => _performBackup(),
            ),
            const Divider(),
            ListTile(
              title: const Text('שחזור נתונים'),
              subtitle: const Text('שחזר נתונים מגיבוי'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () => _restoreData(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSystemStatus() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'סטטוס מערכת',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildStatusItem('מערכת', 'פעילה', Colors.green),
            _buildStatusItem('מסד נתונים', 'מחובר', Colors.green),
            _buildStatusItem('שרת', 'פועל', Colors.green),
            _buildStatusItem('אבטחה', 'מופעלת', Colors.green),
            _buildStatusItem('גיבוי אחרון', '2024-01-15 10:30', Colors.blue),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _restartSystem(),
                    icon: const Icon(Icons.restart_alt),
                    label: const Text('הפעל מחדש'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _checkUpdates(),
                    icon: const Icon(Icons.update),
                    label: const Text('בדוק עדכונים'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusItem(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              value,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _selectLanguage() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('בחר שפה'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('עברית'),
              onTap: () {
                setState(() {
                  _selectedLanguage = 'עברית';
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('English'),
              onTap: () {
                setState(() {
                  _selectedLanguage = 'English';
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('العربية'),
              onTap: () {
                setState(() {
                  _selectedLanguage = 'العربية';
                });
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _selectTheme() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('בחר ערכת נושא'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('אור'),
              onTap: () {
                setState(() {
                  _selectedTheme = 'אור';
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('כהה'),
              onTap: () {
                setState(() {
                  _selectedTheme = 'כהה';
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('אוטומטי'),
              onTap: () {
                setState(() {
                  _selectedTheme = 'אוטומטי';
                });
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _selectBackupFrequency() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('בחר תדירות גיבוי'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('יומי'),
              onTap: () {
                setState(() {
                  _selectedBackupFrequency = 'יומי';
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('שבועי'),
              onTap: () {
                setState(() {
                  _selectedBackupFrequency = 'שבועי';
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('חודשי'),
              onTap: () {
                setState(() {
                  _selectedBackupFrequency = 'חודשי';
                });
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _managePermissions() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ניהול הרשאות'),
        content: const Text('פתיחת ניהול הרשאות...\n\n• הרשאות משתמשים\n• הרשאות תפקידים\n• הרשאות מערכת\n• הגדרות אבטחה'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('סגור'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showPermissionsOpened();
            },
            child: const Text('פתח'),
          ),
        ],
      ),
    );
  }

  void _changePassword() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('שינוי סיסמה'),
        content: const Text('פתיחת טופס שינוי סיסמה...\n\n• סיסמה נוכחית\n• סיסמה חדשה\n• אישור סיסמה\n• אימות אבטחה'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ביטול'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showPasswordChanged();
            },
            child: const Text('שנה'),
          ),
        ],
      ),
    );
  }

  void _performBackup() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('גיבוי ידני'),
        content: const Text('מבצע גיבוי ידני...\n\n• גיבוי מסד נתונים\n• גיבוי קבצים\n• גיבוי הגדרות\n• יצירת קובץ גיבוי'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ביטול'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showBackupCompleted();
            },
            child: const Text('התחל גיבוי'),
          ),
        ],
      ),
    );
  }

  void _restoreData() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('שחזור נתונים'),
        content: const Text('פתיחת שחזור נתונים...\n\n• בחירת קובץ גיבוי\n• בחירת נתונים לשחזור\n• אישור שחזור\n• תהליך שחזור'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ביטול'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showRestoreCompleted();
            },
            child: const Text('שחזר'),
          ),
        ],
      ),
    );
  }

  void _restartSystem() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('הפעלה מחדש'),
        content: const Text('האם אתה בטוח שברצונך להפעיל מחדש את המערכת?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ביטול'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showSystemRestarted();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
            child: const Text('הפעל מחדש'),
          ),
        ],
      ),
    );
  }

  void _checkUpdates() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('בדיקת עדכונים'),
        content: const Text('בודק עדכונים זמינים...\n\n• בדיקת עדכוני מערכת\n• בדיקת עדכוני אבטחה\n• בדיקת עדכוני תכונות\n• הורדת עדכונים'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('סגור'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showUpdatesChecked();
            },
            child: const Text('בדוק'),
          ),
        ],
      ),
    );
  }

  void _saveSettings() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('ההגדרות נשמרו בהצלחה!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showPermissionsOpened() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('ניהול ההרשאות נפתח בהצלחה!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showPasswordChanged() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('הסיסמה שונתה בהצלחה!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showBackupCompleted() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('הגיבוי הושלם בהצלחה!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showRestoreCompleted() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('הנתונים שוחזרו בהצלחה!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showSystemRestarted() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('המערכת הופעלה מחדש בהצלחה!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showUpdatesChecked() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('העדכונים נבדקו בהצלחה!'),
        backgroundColor: Colors.green,
      ),
    );
  }
}








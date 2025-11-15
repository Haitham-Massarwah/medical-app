import 'package:flutter/material.dart';

class DeveloperControlPage extends StatefulWidget {
  const DeveloperControlPage({super.key});

  @override
  State<DeveloperControlPage> createState() => _DeveloperControlPageState();
}

class _DeveloperControlPageState extends State<DeveloperControlPage> {
  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('שליטה מלאה - מפתח'),
          backgroundColor: Colors.red.shade700,
          foregroundColor: Colors.white,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // System stats
              Card(
                color: Colors.red.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'סטטיסטיקות מערכת',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(child: _buildStatCard('משתמשים', '1,234', Icons.people)),
                          Expanded(child: _buildStatCard('רופאים', '45', Icons.medical_services)),
                          Expanded(child: _buildStatCard('תורים', '3,567', Icons.calendar_today)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              
              // Control panels
              const Text(
                'פאנל שליטה:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  children: [
                    _buildControlCard(
                      'כל המשתמשים',
                      'צפה, הוסף, מחק משתמשים',
                      Icons.people,
                      Colors.blue,
                      () {
                        _showUsersManagement();
                      },
                    ),
                    _buildControlCard(
                      'כל הרופאים',
                      'נהל רופאים במערכת',
                      Icons.medical_services,
                      Colors.green,
                      () {
                        _showDoctorsManagement();
                      },
                    ),
                    _buildControlCard(
                      'כל התורים',
                      'צפה וניהול כל התורים',
                      Icons.calendar_today,
                      Colors.orange,
                      () {
                        _showAppointmentsManagement();
                      },
                    ),
                    _buildControlCard(
                      'תשלומים',
                      'נהל תשלומים והחזרים',
                      Icons.payment,
                      Colors.purple,
                      () {
                        _showPaymentsManagement();
                      },
                    ),
                    _buildControlCard(
                      'דוחות',
                      'סטטיסטיקות ואנליטיקה',
                      Icons.analytics,
                      Colors.teal,
                      () {
                        _showReports();
                      },
                    ),
                    _buildControlCard(
                      'ניהול התמחויות',
                      'בחר אילו התמחויות יוצגו ללקוחות',
                      Icons.medical_services,
                      Colors.blue,
                      () {
                        Navigator.pushNamed(context, '/developer-specialty-settings');
                      },
                    ),
                    _buildControlCard(
                      'ניהול מסד נתונים',
                      'העלה, הורד ושחזר גיבויים',
                      Icons.storage,
                      Colors.brown,
                      () {
                        Navigator.pushNamed(context, '/developer-database');
                      },
                    ),
                    _buildControlCard(
                      'הגדרות מערכת',
                      'הגדרות גלובליות',
                      Icons.settings,
                      Colors.grey,
                      () {
                        _showSystemSettings();
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.red.shade700, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.red.shade700,
          ),
        ),
        Text(
          title,
          style: const TextStyle(fontSize: 12),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildControlCard(String title, String subtitle, IconData icon, Color color, VoidCallback onTap) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 48, color: color),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showUsersManagement() {
    Navigator.pushNamed(context, '/manage-users');
  }

  void _showDoctorsManagement() {
    Navigator.pushNamed(context, '/doctors-list');
  }

  void _showAppointmentsManagement() {
    Navigator.pushNamed(context, '/appointments');
  }

  void _showPaymentsManagement() {
    Navigator.pushNamed(context, '/booking-management');
  }

  void _showReports() {
    Navigator.pushNamed(context, '/system-logs');
  }

  void _showSystemSettings() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('הגדרות מערכת'),
        content: const Text('הגדרות שפה, חיבור יומן, התראות'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('סגור'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.pushNamed(context, '/settings');
            },
            child: const Text('פתח הגדרות'),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'presentation/pages/security_dashboard_enhanced.dart';
import 'presentation/pages/appointment_management_fixed.dart';
import 'presentation/pages/doctor_search_simple.dart';
import 'presentation/pages/user_management_enhanced.dart';
// import 'presentation/pages/system_logs_enhanced.dart';
import 'presentation/pages/system_logs_lite.dart';
import 'presentation/pages/system_settings_simple.dart';
import 'presentation/pages/book_appointment_enhanced.dart';
import 'presentation/pages/login_enhanced.dart';
import 'presentation/pages/doctor_calendar_page.dart';
import 'presentation/pages/doctor_profile_page.dart';
import 'presentation/pages/validation_test_page.dart';
import 'presentation/pages/patient_management_page.dart';
import 'presentation/pages/treatment_completion_page.dart';
import 'presentation/pages/doctor_treatment_settings_page_simple.dart';

void main() {
  runApp(const MedicalAppointmentApp());
}

class MedicalAppointmentApp extends StatelessWidget {
  const MedicalAppointmentApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Medical Appointment System',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      debugShowCheckedModeBanner: false,
      routes: {
        '/': (context) => const LoginEnhancedPage(),
        '/home': (context) => const HomePage(),
        '/system-logs': (context) => const SystemLogsLitePage(),
      },
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _userRole = 'developer';
  String _userEmail = 'developer@medicalapp.com';
  String _userName = 'מפתח המערכת';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('מערכת תורים רפואיים'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.security),
            onPressed: () => _showSecurityDashboard(),
            tooltip: 'לוח אבטחה',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Section
            _buildWelcomeSection(),
            
            const SizedBox(height: 24),
            
            // Role Selection
            _buildRoleSelection(),
            
            const SizedBox(height: 24),
            
            // Feature Cards
            _buildFeatureCards(),
            
            const SizedBox(height: 24),
            
            // Quick Actions
            _buildQuickActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ברוכים הבאים למערכת התורים הרפואיים',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'מערכת מתקדמת לניהול תורים רפואיים עם אבטחה ברמה גבוהה',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(Icons.person, color: Colors.blue),
                const SizedBox(width: 8),
                Text('תפקיד: $_userRole'),
                const SizedBox(width: 16),
                Icon(Icons.email, color: Colors.blue),
                const SizedBox(width: 8),
                Text('$_userEmail'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleSelection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'בחר תפקיד',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              children: [
                _buildRoleChip('developer', 'מפתח', Colors.red),
                _buildRoleChip('doctor', 'רופא', Colors.green),
                _buildRoleChip('customer', 'מטופל', Colors.blue),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleChip(String role, String label, Color color) {
    final isSelected = _userRole == role;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _userRole = role;
          _updateUserInfo(role);
        });
      },
      selectedColor: color.withOpacity(0.2),
      checkmarkColor: color,
    );
  }

  Widget _buildFeatureCards() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'תכונות המערכת',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: _getFeatureCards(),
        ),
      ],
    );
  }

  List<Widget> _getFeatureCards() {
    switch (_userRole) {
      case 'developer':
        return [
          _buildFeatureCard('לוח אבטחה', 'מעקב אבטחה וניטור', Icons.security, Colors.red, () => _showSecurityDashboard()),
          _buildFeatureCard('ניהול משתמשים', 'ניהול חשבונות משתמשים', Icons.people, Colors.orange, () => _showUserManagement()),
          _buildFeatureCard('יומני מערכת', 'צפייה ביומני ביקורת', Icons.assignment, Colors.purple, () => _showSystemLogs()),
          _buildFeatureCard('הגדרות מערכת', 'הגדרות כלליות', Icons.settings, Colors.grey, () => _showSystemSettings()),
          _buildFeatureCard('ניהול תורים', 'ניהול כל התורים', Icons.calendar_today, Colors.green, () => _showAppointmentManagement()),
          _buildFeatureCard('חיפוש רופאים', 'חיפוש וניהול רופאים', Icons.search, Colors.blue, () => _showDoctorSearch()),
          _buildFeatureCard('בדיקת ולידציה', 'בדיקת ולידציה בזמן אמת', Icons.check_circle, Colors.amber, () => _showValidationTest()),
        ];
      case 'doctor':
        return [
          _buildFeatureCard('לוח זמנים', 'לוח זמנים יומי ושבועי', Icons.schedule, Colors.blue, () => _showDoctorCalendar()),
          _buildFeatureCard('פרופיל רופא', 'עריכת פרטים אישיים ומקצועיים', Icons.person, Colors.purple, () => _showDoctorProfile()),
          _buildFeatureCard('ניהול תורים', 'ניהול תורים וזמינות', Icons.calendar_today, Colors.green, () => _showAppointmentManagement()),
          _buildFeatureCard('מטופלים', 'ניהול רשימת מטופלים', Icons.people, Colors.orange, () => _showPatientManagement()),
          _buildFeatureCard('הגדרות טיפולים', 'הגדרת סוגי טיפולים', Icons.medical_services, Colors.teal, () => _showTreatmentSettings()),
          _buildFeatureCard('השלמת טיפולים', 'סיום טיפולים ובקשות תשלום', Icons.check_circle, Colors.red, () => _showTreatmentCompletion()),
        ];
      case 'customer':
        return [
          _buildFeatureCard('הזמנת תור', 'הזמנת תור חדש עם חיפוש רופאים', Icons.add_circle, Colors.green, () => _showBookAppointment()),
          _buildFeatureCard('התורים שלי', 'צפייה בתורים קיימים', Icons.calendar_today, Colors.purple, () => _showMyAppointments()),
          _buildFeatureCard('תשלומים', 'ניהול תשלומים', Icons.payment, Colors.orange, () => _showPayments()),
        ];
      default:
        return [];
    }
  }

  Widget _buildFeatureCard(String title, String description, IconData icon, Color color, VoidCallback onTap) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 48, color: color),
              const SizedBox(height: 12),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                description,
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'פעולות מהירות',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _showNotifications(),
                    icon: const Icon(Icons.notifications),
                    label: const Text('התראות'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _showHelp(),
                    icon: const Icon(Icons.help),
                    label: const Text('עזרה'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
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

  void _updateUserInfo(String role) {
    switch (role) {
      case 'developer':
        _userEmail = 'developer@medicalapp.com';
        _userName = 'מפתח המערכת';
        break;
      case 'doctor':
        _userEmail = 'doctor@medicalapp.com';
        _userName = 'ד"ר יוסי כהן';
        break;
      case 'customer':
        _userEmail = 'customer@medicalapp.com';
        _userName = 'מטופל';
        break;
    }
  }

  // Feature Actions
  void _showSecurityDashboard() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SecurityDashboardEnhancedPage()),
    );
  }

  void _showUserManagement() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const UserManagementEnhancedPage()),
    );
  }

  void _showSystemLogs() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SystemLogsLitePage()),
    );
  }

  void _showSystemSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SystemSettingsPage()),
    );
  }

  void _showValidationTest() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ValidationTestPage()),
    );
  }

  void _showAppointmentManagement() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AppointmentManagementFixedPage()),
    );
  }

  void _showPatientManagement() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const PatientManagementPage()),
    );
  }

  void _showTreatmentSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const DoctorTreatmentSettingsPage()),
    );
  }

  void _showTreatmentCompletion() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const TreatmentCompletionPage(
        appointmentId: 'appointment_123',
        patientId: 'patient_123',
        patientName: 'יוסי כהן',
        treatmentTypeId: 'treatment_1',
        treatmentTypeName: 'ייעוץ כללי',
        amount: 150.0,
      )),
    );
  }

  void _showDoctorCalendar() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const DoctorCalendarPage()),
    );
  }

  void _showDoctorProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const DoctorProfilePage()),
    );
  }

  void _showDoctorSearch() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const DoctorSearchPage()),
    );
  }

  void _showBookAppointment() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const BookAppointmentEnhancedPage(),
      ),
    );
  }

  void _showMyAppointments() {
    _showFeatureDialog('התורים שלי', 'צפייה בתורים קיימים:\n• תורים עתידיים\n• תורים קודמים\n• ביטול תורים\n• העברת תורים');
  }

  void _showPayments() {
    _showFeatureDialog('תשלומים', 'ניהול תשלומים:\n• היסטוריית תשלומים\n• תשלום תורים\n• החזרים\n• קבלות');
  }

  void _showNotifications() {
    _showFeatureDialog('התראות', 'מערכת התראות:\n• התראות תורים\n• התראות תשלומים\n• התראות מערכת\n• הגדרות התראות');
  }

  void _showHelp() {
    _showFeatureDialog('עזרה', 'מרכז עזרה:\n• מדריכי שימוש\n• שאלות נפוצות\n• יצירת קשר\n• תמיכה טכנית');
  }

  void _showFeatureDialog(String title, String description) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(description),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('סגור'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showComingSoon();
            },
            child: const Text('המשך'),
          ),
        ],
      ),
    );
  }

  void _showComingSoon() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('התכונה תהיה זמינה בקרוב!'),
        backgroundColor: Colors.green,
      ),
    );
  }
}

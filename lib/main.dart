import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'presentation/pages/doctors_page.dart';
import 'presentation/pages/appointments_page.dart';
import 'presentation/pages/login_page.dart';
import 'presentation/pages/register_page.dart';
import 'presentation/pages/calendar_booking_page.dart';
import 'presentation/pages/payment_page.dart';
import 'presentation/pages/reschedule_page.dart';
import 'presentation/pages/notifications_page.dart';
import 'presentation/pages/settings_page.dart';
import 'presentation/pages/video_call_page.dart';
import 'presentation/pages/privacy_page.dart';
import 'presentation/pages/receipt_page.dart';
import 'presentation/pages/profile_page.dart';
import 'presentation/pages/admin_page.dart';
import 'presentation/pages/doctor_dashboard_page.dart' as old_doctor;
import 'presentation/pages/admin_dashboard_redesigned.dart';
import 'presentation/pages/admin_full_dashboard.dart';
import 'presentation/pages/doctor_dashboard_redesigned.dart'
    as redesigned_doctor;
import 'presentation/pages/patient_dashboard_redesigned.dart'
    as redesigned_patient;
import 'presentation/pages/developer_control_page.dart';
import 'presentation/pages/developer_specialty_settings.dart';
import 'presentation/pages/developer_database_page.dart';
import 'presentation/pages/doctor_profile_page.dart';
import 'presentation/pages/create_patient_page.dart';
import 'presentation/pages/create_doctor_page.dart';
import 'presentation/pages/customer_registration_page.dart';
import 'presentation/pages/doctor_create_customer_page.dart';
import 'presentation/pages/email_completion_page.dart';
import 'presentation/pages/doctor_treatment_settings_page_simple.dart';
import 'presentation/pages/location_search_page_simple.dart';
import 'presentation/pages/treatment_completion_page.dart';
import 'presentation/pages/booking_management_page.dart';
import 'presentation/pages/security_dashboard_page.dart';
// import 'presentation/pages/system_logs_enhanced.dart';
import 'presentation/pages/system_logs_lite.dart';
import 'presentation/pages/cart_page.dart';
import 'presentation/pages/doctor_appointment_config_page.dart';
import 'presentation/pages/developer_doctors_page.dart';
import 'presentation/pages/developer_customers_page.dart';
import 'presentation/pages/developer_payments_page.dart';
import 'presentation/pages/payment_settings_page.dart';
import 'presentation/pages/admin_payment_control.dart';
import 'presentation/pages/admin_permissions.dart';
import 'presentation/pages/admin_all_appointments.dart';
import 'presentation/pages/test_simple_page.dart';
import 'presentation/pages/coming_soon_page.dart';
import 'core/config/dev_credentials.dart';
import 'core/config/release_config.dart';

void main() {
  // FR-14: Register app lifecycle observer to save logs on close
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MedicalAppointmentApp());
}

// Pre-Release Toggle: 
// - true = Show Coming Soon page (PRODUCTION ONLY - release builds)
// - false = Show normal app (DEVELOPMENT - debug builds)
// Coming Soon automatically shows in production, hidden in development
const bool IS_PRE_RELEASE = true; // Change to false when ready for public release

// Show Coming Soon only in production builds (release mode)
// In development (debug mode), always show the app
bool shouldShowComingSoon() {
  // In debug/development mode, never show coming soon
  if (kDebugMode) {
    return false; // Always show app in development
  }
  // In release/production mode, check the toggle
  return IS_PRE_RELEASE;
}

class MedicalAppointmentApp extends StatelessWidget {
  const MedicalAppointmentApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Medical Appointment System',
      debugShowCheckedModeBanner: false,
      // FR-21: Hebrew only for now
      locale: const Locale('he', 'IL'),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('he', 'IL'), // Hebrew only
      ],
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          labelStyle: const TextStyle(color: Colors.black87),
          hintStyle: const TextStyle(color: Colors.black54),
          border: const OutlineInputBorder(),
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.black),
          bodyMedium: TextStyle(color: Colors.black),
        ),
      ),
      // FR-22: Mouse back button support - Enhanced
      builder: (context, child) {
        return WillPopScope(
          onWillPop: () async {
            // Handle back button (including mouse back button)
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
              return false;
            }
            return true;
          },
          child: MouseRegion(
            // Enable mouse button navigation
            onExit: (_) {
              // Mouse back button will trigger WillPopScope
            },
            child: child!,
          ),
        );
      },
      home: shouldShowComingSoon() ? const ComingSoonPage() : const LoginPage(),
      routes: {
        '/login': (context) => const LoginPage(),
        '/home': (context) => const HomePage(),
        '/doctors': (context) => const DoctorsPage(),
        '/appointments': (context) =>
            const AdminAllAppointments(), // Admin view: ALL appointments
        '/my-appointments': (context) =>
            const AppointmentsPage(), // User view: My appointments
        '/register': (context) => const RegisterPage(),
        '/doctor-dashboard': (context) =>
            const redesigned_doctor.DoctorDashboardPage(),
        '/doctor-dashboard-old': (context) =>
            const old_doctor.DoctorDashboardPage(),
        '/developer-control': (context) => const AdminFullDashboard(),
        '/developer-control-old': (context) => const DeveloperControlPage(),
        '/developer-specialty-settings': (context) =>
            const DeveloperSpecialtySettings(),
        '/developer-database': (context) => const DeveloperDatabasePage(),
        '/doctor-profile': (context) => const DoctorProfilePage(),
        '/create-patient': (context) => const CreatePatientPage(),
        '/create-doctor': (context) => const CreateDoctorPage(isAdmin: true),
        '/manage-users': (context) => const AdminPage(),
        '/system-logs': (context) => const SystemLogsLitePage(),
        '/notifications': (context) => const NotificationsPage(),
        '/settings': (context) => const SettingsPage(),
        '/privacy': (context) => const PrivacyPage(),
        '/calendar-booking': (context) => const CalendarBookingPage(
              doctorId: '',
              doctorName: '',
              specialty: '',
            ),
        '/payment': (context) => PaymentPage(
              appointmentId: '',
              doctorName: '',
              specialty: '',
              appointmentDate: DateTime.now(),
              timeSlot: '',
              amount: 0,
            ),
        '/reschedule': (context) => ReschedulePage(
              appointmentId: '',
              doctorName: '',
              specialty: '',
              currentDate: DateTime.now(),
              currentTimeSlot: '',
            ),
        '/video-call': (context) => const VideoCallPage(
              appointmentId: '',
              doctorName: '',
              patientName: '',
              isDoctor: false,
            ),
        '/receipt': (context) => const ReceiptPage(receiptId: ''),
        '/profile': (context) => const ProfilePage(),
        '/customer-registration': (context) => const CustomerRegistrationPage(),
        '/doctor-create-customer': (context) =>
            const DoctorCreateCustomerPage(),
        '/email-completion': (context) {
          final args = ModalRoute.of(context)!.settings.arguments
              as Map<String, dynamic>;
          return EmailCompletionPage(token: args['token']);
        },
        '/doctor-treatment-settings': (context) =>
            const DoctorTreatmentSettingsPage(),
        '/location-search': (context) => const LocationSearchPage(),
        '/treatment-completion': (context) {
          final args = ModalRoute.of(context)!.settings.arguments
              as Map<String, dynamic>;
          return TreatmentCompletionPage(
            appointmentId: args['appointmentId'],
            patientId: args['patientId'],
            patientName: args['patientName'],
            treatmentTypeId: args['treatmentTypeId'],
            treatmentTypeName: args['treatmentTypeName'],
            amount: args['amount'],
          );
        },
        '/booking-management': (context) => const BookingManagementPage(),
        '/security-dashboard': (context) => const SecurityDashboardPage(),
        '/admin': (context) => const AdminPage(),
        '/cart': (context) => const CartPage(),
        '/doctors-list': (context) => const DeveloperDoctorsPage(),
        '/users-list': (context) => const DeveloperCustomersPage(),
        '/payments-list': (context) => const DeveloperPaymentsPage(),
        '/appointments-list': (context) =>
            const AppointmentsPage(), // Use appointments page
        '/doctor-appointment-config': (context) =>
            const DoctorAppointmentConfigPage(),
        '/payment-settings': (context) =>
            const PaymentSettingsPage(), // FR-7b: Card details
        '/admin-payment-control': (context) => const AdminPaymentControl(),
        '/admin-permissions': (context) => const AdminPermissions(),
        '/test-simple': (context) => const TestSimplePage(),
      },
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  bool _isLoading = false;
  String _currentRole = 'patient';
  String _userEmail = '';
  String _userName = '';

  @override
  void initState() {
    super.initState();
    // FR-14: Register lifecycle observer to save logs
    WidgetsBinding.instance.addObserver(this);
    // Defer until after first frame to avoid inherited widget access during initState
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _loadUserData();
      }
    });
  }

  @override
  void dispose() {
    // FR-14: Unregister observer
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // FR-14: Save logs when app is paused or detached
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      _saveLogsOnClose();
    }
  }

  Future<void> _saveLogsOnClose() async {
    // FR-14: Save current logs to file
    try {
      // Log saving implementation would go here
      print('Saving logs on app close...');
      // In a real implementation, this would write logs to a file
    } catch (e) {
      print('Error saving logs: $e');
    }
  }

  Future<void> _loadUserData() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // If navigation provided role/email, keep it and skip override
      final navArgs = ModalRoute.of(context)?.settings.arguments as Map?;
      if (navArgs != null && navArgs['role'] != null) {
        setState(() {
          _currentRole = navArgs['role'];
          _userEmail = navArgs['email'] ?? '';
          _userName = navArgs['name'] ?? '';
        });
        return;
      }

      // If no arguments, load from local storage or API
      final userData = await _getCurrentUserData();

      setState(() {
        _currentRole = userData['role'] ?? 'patient';
        _userEmail = userData['email'] ?? '';
        _userName = userData['name'] ?? '';
      });
    } catch (e) {
      // Handle error - maybe redirect to login
      print('Error loading user data: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<Map<String, String>> _getCurrentUserData() async {
    // This would typically come from your authentication service
    // Check database for user role based on email
    final userEmail = await _getCurrentUserEmail();

    // Check database for actual user role (automatic role detection)
    if (await _isDoctorEmail(userEmail)) {
      return {
        'role': 'doctor',
        'email': userEmail,
        'name': await _getDoctorName(userEmail),
      };
    } else if (await _isCustomerEmail(userEmail)) {
      return {
        'role': 'customer',
        'email': userEmail,
        'name': await _getCustomerName(userEmail),
      };
    } else {
      return {
        'role': 'patient',
        'email': userEmail,
        'name': 'משתמש',
      };
    }
  }

  Future<String> _getCurrentUserEmail() async {
    // Get current user email from authentication service
    // This would typically come from your auth service
    // Fallback developer email to avoid defaulting to customer
    return 'haitham.massarwah@medical-appointments.com';
  }

  Future<bool> _isDoctorEmail(String email) async {
    // Check if email exists in doctors table
    // This would typically query your database
    return false; // Mock implementation
  }

  Future<bool> _isCustomerEmail(String email) async {
    // Check if email exists in customers table
    // This would typically query your database
    return false; // Mock implementation
  }

  Future<String> _getDoctorName(String email) async {
    // Get doctor name from database
    // This would typically query your database
    return 'ד"ר כהן';
  }

  Future<String> _getCustomerName(String email) async {
    // Get customer name from database
    // This would typically query your database
    return 'לקוח';
  }

  void _logout() {
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Medical Appointment System'),
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.medical_services,
                size: 100,
                color: Colors.blue,
              ),
              SizedBox(height: 20),
              Text(
                'ברוכים הבאים למערכת התורים הרפואיים',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 10),
              Text(
                'Welcome to Medical Appointment System',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 30),
              CircularProgressIndicator(),
              SizedBox(height: 20),
              Text(
                'Loading...',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_getRoleLabel()),
        backgroundColor: _getRoleColor(),
        foregroundColor: Colors.white,
        actions: [
          // Profile button (FR-24: Hidden for admin/developer)
          if (_currentRole != 'developer')
            IconButton(
              icon: const Icon(Icons.account_circle),
              onPressed: () {
                Navigator.pushNamed(context, '/profile');
              },
            ),
          // Logout button
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'התנתק',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Role indicator card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [_getRoleColor(), _getRoleColor().withOpacity(0.7)],
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: _getRoleColor().withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(_getRoleIcon(), size: 48, color: Colors.white),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'מחובר כ:',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        _getRoleLabel(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // Role-specific cards
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: _buildRoleSpecificCards(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildRoleSpecificCards(BuildContext context) {
    switch (_currentRole) {
      case 'doctor':
        return [
          _buildHomeCard(context, 'לוח בקרה', 'ניהול תורים ומטופלים',
              Icons.dashboard, Colors.green, '/doctor-dashboard'),
          _buildHomeCard(
              context,
              'ניהול תורים',
              'אשר, דחה ונהל תורים',
              Icons.calendar_today,
              Colors.green.shade700,
              '/booking-management'),
          _buildHomeCard(context, 'יצירת מטופל', 'הוסף מטופל חדש',
              Icons.person_add, Colors.green.shade600, '/create-patient'),
          _buildHomeCard(context, 'הפרופיל שלי', 'פרטים אישיים וחשבון בנק',
              Icons.account_circle, Colors.green.shade500, '/doctor-profile'),
          _buildHomeCard(
              context,
              'הגדרות טיפולים',
              'ניהול סוגי טיפולים וזמנים',
              Icons.medical_services,
              Colors.green.shade400,
              '/doctor-treatment-settings'),
          _buildHomeCard(context, 'הגדרות תורים', 'משך זמן ומגבלות תורים',
              Icons.access_time, Colors.orange, '/doctor-appointment-config'),
          _buildHomeCard(context, 'הגדרות', 'הגדרות אפליקציה', Icons.settings,
              Colors.grey, '/settings'),
        ];
      case 'developer':
        // Admin/Developer features - always shown in release mode
        // Admin account gets full control in production
        return [
          _buildHomeCard(context, 'לוח בקרה', 'סקירה כללית של המערכת',
              Icons.dashboard, Colors.red, '/developer-control'),
          _buildHomeCard(context, 'לוח אבטחה', 'מעקב אבטחה וניטור',
              Icons.security, Colors.red.shade800, '/security-dashboard'),
          _buildHomeCard(context, 'יצירת רופא', 'הוסף רופא חדש',
              Icons.medical_services, Colors.red.shade700, '/create-doctor'),
          _buildHomeCard(context, 'יצירת מטופל', 'הוסף מטופל חדש',
              Icons.person_add, Colors.red.shade600, '/create-patient'),
          _buildHomeCard(context, 'ניהול משתמשים', 'צפה בכל המשתמשים',
              Icons.group, Colors.red.shade500, '/manage-users'),
          _buildHomeCard(context, 'יומני מערכת', 'צפה ביומני ביקורת ושגיאות',
              Icons.receipt_long, Colors.brown, '/system-logs'),
          _buildHomeCard(context, 'הגדרות מערכת', 'הגדרות גלובליות',
              Icons.settings, Colors.grey, '/settings'),
        ];
      case 'customer':
        return [
          _buildHomeCard(context, 'רופאים', 'מצא וקבע תור',
              Icons.medical_services, Colors.blue, '/doctors'),
          _buildHomeCard(context, 'חיפוש לפי מיקום', 'חפש רופאים באזור שלך',
              Icons.location_on, Colors.blue.shade600, '/location-search'),
          _buildHomeCard(context, 'עגלת תורים', 'תורים מרובים בתשלום אחד',
              Icons.shopping_cart, Colors.purple, '/cart'),
          _buildHomeCard(context, 'התורים שלי', 'צפה ונהל תורים',
              Icons.calendar_today, Colors.blue.shade700, '/appointments'),
          _buildHomeCard(context, 'התראות', 'הודעות ועדכונים',
              Icons.notifications, Colors.orange, '/notifications'),
          _buildHomeCard(context, 'הגדרות', 'הגדרות פרופיל ופרטיות',
              Icons.settings, Colors.grey, '/settings'),
        ];
      case 'patient':
      default:
        return [
          _buildHomeCard(context, 'רופאים', 'מצא וקבע תור',
              Icons.medical_services, Colors.blue, '/doctors'),
          _buildHomeCard(context, 'חיפוש לפי מיקום', 'חפש רופאים באזור שלך',
              Icons.location_on, Colors.blue.shade600, '/location-search'),
          _buildHomeCard(context, 'עגלת תורים', 'תורים מרובים בתשלום אחד',
              Icons.shopping_cart, Colors.purple, '/cart'),
          _buildHomeCard(context, 'התורים שלי', 'צפה ונהל תורים',
              Icons.calendar_today, Colors.blue.shade700, '/appointments'),
          _buildHomeCard(context, 'התראות', 'הודעות ועדכונים',
              Icons.notifications, Colors.orange, '/notifications'),
          _buildHomeCard(context, 'הגדרות', 'הגדרות פרופיל ופרטיות',
              Icons.settings, Colors.grey, '/settings'),
        ];
    }
  }

  Color _getRoleColor() {
    switch (_currentRole) {
      case 'doctor':
        return Colors.green;
      case 'admin':
        return Colors.deepPurple;
      case 'developer':
        return Colors.red;
      case 'customer':
        return Colors.blue;
      default:
        return Colors.blue;
    }
  }

  IconData _getRoleIcon() {
    switch (_currentRole) {
      case 'doctor':
        return Icons.medical_services;
      case 'admin':
        return Icons.admin_panel_settings;
      case 'developer':
        return Icons.code;
      case 'customer':
        return Icons.person;
      default:
        return Icons.person;
    }
  }

  String _getRoleLabel() {
    switch (_currentRole) {
      case 'doctor':
        return 'רופא';
      case 'admin':
        return 'מנהל';
      case 'developer':
        return 'מפתח';
      case 'customer':
        return 'לקוח';
      default:
        return 'מטופל';
    }
  }

  Widget _buildHomeCard(BuildContext context, String title, String subtitle,
      IconData icon, Color color,
      [String? route]) {
    return Card(
      child: InkWell(
        onTap: () {
          Navigator.of(context).pushNamed(route!);
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Icon(icon, size: 48, color: color),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

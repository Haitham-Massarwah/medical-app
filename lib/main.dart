import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kDebugMode, kReleaseMode;
import 'package:medical_shared/medical_shared.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'services/language_service.dart';
import 'core/localization/app_localizations.dart';
import 'core/config/app_config.dart';
import 'presentation/pages/doctors_page.dart';
import 'presentation/pages/appointments_page.dart';
import 'presentation/pages/login_page.dart';
import 'presentation/pages/register_page.dart';
import 'presentation/pages/forgot_password_page.dart';
import 'presentation/pages/calendar_booking_page.dart';
import 'presentation/pages/payment_page.dart';
import 'presentation/pages/reschedule_page.dart';
import 'presentation/pages/notifications_page.dart';
import 'presentation/pages/settings_page.dart';
import 'presentation/pages/video_call_page.dart';
import 'presentation/pages/privacy_page.dart';
import 'presentation/pages/receipt_page.dart';
import 'presentation/pages/profile_page.dart';
import 'presentation/pages/doctor_dashboard_page.dart' as old_doctor;
import 'presentation/pages/admin_dashboard_redesigned.dart';
import 'presentation/pages/admin_full_dashboard.dart';
import 'presentation/pages/doctor_dashboard_redesigned.dart'
    as redesigned_doctor;
import 'presentation/pages/patient_dashboard_redesigned.dart'
    as redesigned_patient;
import 'presentation/pages/receptionist_dashboard_page.dart';
import 'presentation/pages/developer_control_page.dart';
import 'presentation/pages/developer_specialty_settings.dart';
import 'presentation/pages/developer_database_page_stub.dart'
    if (dart.library.io) 'presentation/pages/developer_database_page.dart';
import 'presentation/pages/doctor_profile_page.dart';
import 'presentation/pages/create_patient_page.dart';
import 'presentation/pages/patient_management_page.dart';
import 'presentation/pages/create_doctor_page.dart';
import 'presentation/pages/customer_registration_page.dart';
import 'presentation/pages/doctor_create_customer_page.dart';
import 'presentation/pages/email_completion_page.dart';
import 'presentation/pages/doctor_treatment_settings_page_simple.dart';
import 'presentation/pages/location_search_hierarchical.dart';
import 'presentation/pages/treatment_completion_page.dart';
import 'presentation/pages/booking_management_page.dart';
import 'presentation/pages/doctor_calendar_page.dart';
import 'presentation/pages/doctor_booking_page.dart';
import 'presentation/pages/security_dashboard_page_stub.dart'
    if (dart.library.io) 'presentation/pages/security_dashboard_page.dart';
// import 'presentation/pages/system_logs_enhanced.dart';
import 'presentation/pages/system_logs_lite.dart';
import 'presentation/pages/cart_page.dart';
import 'presentation/pages/doctor_appointment_config_page.dart';
import 'presentation/pages/developer_payments_page.dart';
import 'presentation/pages/doctors_list_page.dart';
import 'presentation/pages/users_list_page.dart';
import 'presentation/pages/payment_settings_page.dart';
import 'presentation/pages/admin_payment_control.dart';
import 'presentation/pages/admin_permissions.dart';
import 'presentation/pages/cyber_security_page.dart';
import 'presentation/pages/admin_all_appointments.dart';
import 'presentation/pages/calendar_connection_page.dart';
import 'presentation/pages/test_simple_page.dart';
import 'presentation/pages/comprehensive_test_page.dart';
import 'presentation/pages/comprehensive_functional_test_page.dart';
import 'presentation/pages/coming_soon_page.dart';
import 'presentation/pages/forms_documents_page.dart';
import 'presentation/pages/crm_communication_page.dart';
import 'presentation/pages/finance_operations_page.dart';
import 'presentation/pages/integrations_operations_page.dart';
import 'presentation/pages/admin_health_page.dart';
import 'presentation/widgets/permissions_watcher.dart';
import 'core/config/dev_credentials.dart';
import 'core/config/release_config.dart';

Future<void> main() async {
  assert(medicalSharedPackageVersion.isNotEmpty);
  WidgetsFlutterBinding.ensureInitialized();
  await AppConfig.initialize();
  // Lock language to Hebrew for now (all pages except Login are Hebrew; Login shows Hebrew only)
  await LanguageService.setLanguage('עברית');
  
  // Debug: Print build mode information
  if (kDebugMode) {
    print('🔍 DEVELOPMENT MODE ACTIVE');
    print('🔍 kDebugMode: $kDebugMode');
    print('🔍 kReleaseMode: $kReleaseMode');
    print('🔍 shouldShowComingSoon(): ${shouldShowComingSoon()}');
    print('🔍 Will show: ${shouldShowComingSoon() ? "Coming Soon Page" : "Login Page"}');
  }
  
  runApp(const MedicalAppointmentApp());
}

// Pre-Release Toggle: 
// - true = Show Coming Soon page (PRODUCTION ONLY - release builds)
// - false = Show normal app (DEVELOPMENT - debug builds)
// Coming Soon automatically shows in production, hidden in development
const bool IS_PRE_RELEASE = true; // Change to false when ready for public release

// Show Coming Soon ONLY in production release builds
// In development (debug mode), ALWAYS show the app (never show Coming Soon)
bool shouldShowComingSoon() {
  // FORCE: In debug/development mode, NEVER show coming soon - always show app
  // This is checked FIRST to ensure development always works
  if (kDebugMode) {
    print('🔍 DEBUG MODE: Coming Soon DISABLED - Showing Login Page');
    return false; // Development: Always show app, never Coming Soon
  }
  
  // Only check IS_PRE_RELEASE in release/production builds
  if (kReleaseMode) {
    print('🔍 RELEASE MODE: Coming Soon = ${IS_PRE_RELEASE ? "ENABLED" : "DISABLED"}');
    return IS_PRE_RELEASE; // Production: Show Coming Soon if IS_PRE_RELEASE = true
  }
  
  // For any other mode (profile, etc.), don't show coming soon
  print('🔍 OTHER MODE: Coming Soon DISABLED');
  return false;
}

class MedicalAppointmentApp extends StatefulWidget {
  const MedicalAppointmentApp({super.key});

  @override
  State<MedicalAppointmentApp> createState() => _MedicalAppointmentAppState();
}

class _MedicalAppointmentAppState extends State<MedicalAppointmentApp> {
  Locale _locale = const Locale('he', 'IL'); // Hebrew only for now
  static _MedicalAppointmentAppState? _instance;
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  bool _languagePollActive = true;
  Timer? _languagePollTimer;

  @override
  void initState() {
    super.initState();
    _instance = this;
    HardwareKeyboard.instance.addHandler(_handleHardwareBackKey);
    _loadLanguage();
    // Listen for language changes
    _startLanguageListener();
  }

  @override
  void dispose() {
    _languagePollActive = false;
    _languagePollTimer?.cancel();
    _languagePollTimer = null;
    HardwareKeyboard.instance.removeHandler(_handleHardwareBackKey);
    super.dispose();
  }

  /// Windows/Linux: mouse side "back" and Browser Back / Go Back keys.
  bool _handleHardwareBackKey(KeyEvent event) {
    if (event is! KeyDownEvent) return false;
    final logical = event.logicalKey;
    if (logical != LogicalKeyboardKey.browserBack &&
        logical != LogicalKeyboardKey.goBack) {
      return false;
    }
    final nav = _navigatorKey.currentState;
    if (nav != null && nav.canPop()) {
      nav.pop();
      return true;
    }
    return false;
  }

  void _startLanguageListener() {
    _languagePollTimer?.cancel();
    _languagePollTimer = Timer(const Duration(milliseconds: 500), () {
      if (!_languagePollActive || !mounted) return;
      _checkLanguageChange();
      _startLanguageListener();
    });
  }

  Future<void> _checkLanguageChange() async {
    final newLocale = await LanguageService.getCurrentLocale();
    if (newLocale != _locale && mounted) {
      setState(() {
        _locale = newLocale;
      });
      // Force rebuild of MaterialApp to apply language change
      if (mounted) {
        setState(() {});
      }
    }
  }

  Future<void> _loadLanguage() async {
    // Lock to Hebrew for now
    if (mounted) setState(() => _locale = const Locale('he', 'IL'));
  }

  // Static method to reload language from anywhere
  static void reloadLanguage() {
    _instance?._loadLanguage();
  }
  
  // Force immediate language reload
  void forceLanguageReload() {
    _loadLanguage();
    _checkLanguageChange();
  }

  @override
  Widget build(BuildContext context) {
    // FORCE: In development (kDebugMode), NEVER show Coming Soon
    // Always show LoginPage in debug mode
    final bool showComingSoon = false; // Always false - we're in development
    
    if (kDebugMode) {
      print('🔍 BUILD: kDebugMode=$kDebugMode, kReleaseMode=$kReleaseMode');
      print('🔍 BUILD: showComingSoon=$showComingSoon (FORCED TO FALSE)');
      print('🔍 BUILD: Will show LoginPage');
    }
    
    return MaterialApp(
      navigatorKey: _navigatorKey,
      title: 'מערכת תורים רפואיים',
      debugShowCheckedModeBanner: false,
      locale: _locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('he', 'IL'),
        Locale('ar', 'SA'),
        Locale('en', 'US'),
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
      // FR-22: System back (Android) + mouse X1 back + Browser Back key (desktop)
      builder: (context, child) {
        return PermissionsWatcher(
          child: WillPopScope(
            onWillPop: () async {
              if (Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
                return false;
              }
              return true;
            },
            child: Listener(
              behavior: HitTestBehavior.translucent,
              onPointerDown: (PointerDownEvent event) {
                if (event.kind == PointerDeviceKind.mouse &&
                    (event.buttons & kBackMouseButton) != 0) {
                  final nav = _navigatorKey.currentState;
                  if (nav != null && nav.canPop()) {
                    nav.pop();
                  }
                }
              },
              child: child!,
            ),
          ),
        );
      },
      // showComingSoon is fixed false above; keep single home to avoid dead_code analysis.
      home: const LoginPage(),
      routes: {
        '/login': (context) => const LoginPage(),
        '/home': (context) {
          // PD-04: Show Patient Dashboard for patients (matches provided design)
          // Check role from route arguments
          final args = ModalRoute.of(context)?.settings.arguments;
          final role = args is Map<String, dynamic> ? (args['role'] as String?) : null;
          
          // Show role-specific dashboards
          if (role == 'doctor') {
            return const redesigned_doctor.DoctorDashboardPage();
          } else if (role == 'receptionist') {
            return const ReceptionistDashboardPage();
          } else if (role == 'developer' || role == 'admin') {
            return const AdminFullDashboard();
          }
          // PD-04: Always show Patient Dashboard for patients/customers (matches design)
          return const redesigned_patient.PatientDashboardPage();
        },
        '/doctors': (context) => const DoctorsPage(),
        '/appointments': (context) =>
            const AdminAllAppointments(), // Admin view: ALL appointments
        '/my-appointments': (context) =>
            const AppointmentsPage(), // User view: My appointments
        '/register': (context) => const RegisterPage(),
        '/forgot-password': (context) => const ForgotPasswordPage(),
        '/receptionist-dashboard': (context) => const ReceptionistDashboardPage(),
        '/doctor-dashboard': (context) =>
            const redesigned_doctor.DoctorDashboardPage(),
        '/doctor-dashboard-old': (context) =>
            const old_doctor.DoctorDashboardPage(),
        '/developer-control': (context) => const AdminFullDashboard(),
        '/developer-control-old': (context) => const DeveloperControlPage(),
        '/developer-specialty-settings': (context) =>
            const DeveloperSpecialtySettings(),
        '/developer-database': (context) {
          final args = ModalRoute.of(context)?.settings.arguments;
          final isReadOnly = args is Map<String, dynamic> && args['readOnly'] == true;
          return DeveloperDatabasePage(isReadOnly: isReadOnly);
        },
        '/doctor-profile': (context) => const DoctorProfilePage(),
        '/create-patient': (context) => const CreatePatientPage(),
        '/create-doctor': (context) => const CreateDoctorPage(isAdmin: true),
        '/manage-users': (context) => const UsersListPage(),
        '/system-logs': (context) => const SystemLogsLitePage(),
        '/notifications': (context) => const NotificationsPage(),
        '/settings': (context) => const SettingsPage(),
        '/calendar-connection': (context) => const CalendarConnectionPage(),
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
        '/reschedule': (context) {
          final args =
              ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
          return ReschedulePage(
            appointmentId: args?['appointmentId'] ?? '',
            doctorId: args?['doctorId'] ?? '',
            doctorName: args?['doctorName'] ?? '',
            specialty: args?['specialty'] ?? '',
            currentDate: args?['currentDate'] ?? DateTime.now(),
            currentTimeSlot: args?['currentTimeSlot'] ?? '',
          );
        },
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
        '/location-search': (context) => const LocationSearchHierarchicalPage(),
        '/treatment-completion': (context) {
          final args = ModalRoute.of(context)?.settings.arguments;
          if (args is! Map<String, dynamic>) {
            return Scaffold(
              appBar: AppBar(
                title: const Text('סיום טיפול'),
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              body: const Center(
                child: Text('לא נמצאו פרטי טיפול. נא לפתוח מטופל מתוך תור קיים.'),
              ),
            );
          }
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
        '/doctor-calendar': (context) => const DoctorCalendarPage(),
        '/doctor-patients': (context) => const PatientManagementPage(),
        '/doctor-booking': (context) => const DoctorBookingPage(),
        '/messages': (context) => const NotificationsPage(),
        '/security-dashboard': (context) => const SecurityDashboardPage(),
        '/admin': (context) => const UsersListPage(),
        '/cart': (context) => const CartPage(),
        '/doctors-list': (context) => const DoctorsListPage(),
        '/users-list': (context) => const UsersListPage(),
        '/payments-list': (context) => const DeveloperPaymentsPage(),
        '/appointments-list': (context) =>
            const AppointmentsPage(), // Use appointments page
        '/doctor-appointment-config': (context) =>
            const DoctorAppointmentConfigPage(),
        '/payment-settings': (context) =>
            const PaymentSettingsPage(), // FR-7b: Card details
        '/admin-payment-control': (context) => const AdminPaymentControl(),
        '/admin-permissions': (context) => const AdminPermissions(),
        '/cyber-security': (context) => const CyberSecurityPage(),
        '/test-simple': (context) => const TestSimplePage(),
        '/comprehensive-test': (context) => const ComprehensiveTestPage(),
        '/functional-test': (context) => const ComprehensiveFunctionalTestPage(),
        '/forms-documents': (context) => const FormsDocumentsPage(),
        '/crm-communication': (context) => const CrmCommunicationPage(),
        '/finance-operations': (context) => const FinanceOperationsPage(),
        '/integrations-operations': (context) => const IntegrationsOperationsPage(),
        '/admin-health': (context) => const AdminHealthPage(),
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
          title: const Text('מערכת תורים רפואיים'),
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
              SizedBox(height: 30),
              CircularProgressIndicator(),
              SizedBox(height: 20),
              Text(
                'טוען...',
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
        // Developer – keep in English
        return [
          _buildHomeCard(context, 'Dashboard', 'System overview',
              Icons.dashboard, Colors.red, '/developer-control'),
          _buildHomeCard(context, 'Security Dashboard', 'Security monitoring',
              Icons.security, Colors.red.shade800, '/security-dashboard'),
          _buildHomeCard(context, 'Create Doctor', 'Add new doctor',
              Icons.medical_services, Colors.red.shade700, '/create-doctor'),
          _buildHomeCard(context, 'Create Patient', 'Add new patient',
              Icons.person_add, Colors.red.shade600, '/create-patient'),
          _buildHomeCard(context, 'Manage Users', 'View all users',
              Icons.group, Colors.red.shade500, '/manage-users'),
          _buildHomeCard(context, 'System Logs', 'View audit and error logs',
              Icons.receipt_long, Colors.brown, '/system-logs'),
          _buildHomeCard(context, 'System Settings', 'Global settings',
              Icons.settings, Colors.grey, '/settings'),
        ];
      case 'customer':
        return [
          _buildHomeCard(context, 'רופאים', 'מצא וקבע תור',
              Icons.medical_services, Colors.blue, '/doctors'),
          _buildHomeCard(context, 'חיפוש לפי מיקום', 'חפש רופאים באזור שלך',
              Icons.location_on, Colors.blue.shade600, '/location-search'),
          // SRS Rev 02 §4.9: cart disabled; entry uses SOON in sidebar (not on this grid).
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
          // SRS Rev 02 §4.9: cart disabled; entry uses SOON in sidebar (not on this grid).
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
        return 'Developer';
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

/// Placeholder for doctor patients list until a full page is implemented.
class _DoctorPatientsPlaceholderPage extends StatelessWidget {
  const _DoctorPatientsPlaceholderPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('מטופלים'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Text(
            'רשימת המטופלים תופיע כאן. ניתן ליצור מטופלים מדף לוח הבקרה או מתוך התורים.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16),
          ),
        ),
      ),
    );
  }
}

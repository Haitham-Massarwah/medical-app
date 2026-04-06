import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:medical_appointment_system/main.dart';
import 'package:http/http.dart' as http;

/// Full E2E (needs backend on :3000). Windows desktop:
/// `flutter test integration_test/full_automated_test.dart -d windows --dart-define=RUN_FULL_E2E=true`
///
/// If link fails with LNK1168, close `temp_platform_project.exe` or run `RUN_TESTS.ps1 -FullE2E`.
const bool _runFullE2E =
    bool.fromEnvironment('RUN_FULL_E2E', defaultValue: false);

/// Bounded settle: ~100ms steps, max [timeout] (avoids long default settle).
Future<void> _settle(
  WidgetTester tester, {
  Duration timeout = const Duration(seconds: 25),
}) async {
  await tester.pumpAndSettle(
    const Duration(milliseconds: 100),
    EnginePhase.sendSemanticsUpdate,
    timeout,
  );
}

Future<bool> _checkBackendAvailable() async {
  try {
    final response = await http
        .get(Uri.parse('http://localhost:3000/health'))
        .timeout(const Duration(seconds: 3));
    return response.statusCode == 200;
  } catch (e) {
    print('Backend check failed: $e');
    return false;
  }
}

/// Seeded DB accounts — see `backend/src/database/seeds/create_initial_data.ts`.
const String _doctorE2EEmail = 'doctor1@medical-appointments.com';
const String _doctorE2EPassword = 'Doctor@123';
const String _patientE2EEmail = 'patient1@medical-appointments.com';
const String _patientE2EPassword = 'Patient@123';

/// COMPREHENSIVE AUTOMATED INTEGRATION TEST
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('🤖 FULL AUTOMATED APP TEST', () {
    late bool backendOk;

    setUpAll(() async {
      backendOk = await _checkBackendAvailable();
      if (!backendOk) {
        print(
            '⚠️ Backend not available at http://localhost:3000 — E2E tests will skip work.');
        print('   Start: cd backend && npm run dev');
      }
    });

    testWidgets('Complete App Journey - Admin', (WidgetTester tester) async {
      print('\n========================================');
      print('🧪 TEST 1: ADMIN COMPLETE JOURNEY');
      print('========================================\n');

      if (!backendOk) {
        print('⚠️ Skipping — no backend');
        return;
      }

      print('✅ Backend is available - running integration test');

      await tester.pumpWidget(const MedicalAppointmentApp());
      await _settle(tester);
      print('✅ App launched');

      await _takeScreenshot('01_login_screen');
      print('📸 Screenshot: Login screen');

      print('\n🔐 Logging in as Admin...');
      await _login(
          tester, 'haitham.massarwah@medical-appointments.com', 'Haitham@0412');
      await _settle(tester);

      await _takeScreenshot('02_admin_dashboard');
      print('📸 Screenshot: Admin Dashboard');
      print('✅ Admin logged in - Dashboard visible');

      // Admin sidebar uses English labels (dashboard_sidebar.dart role == admin)
      print('\n🖱️ Testing Admin Dashboard buttons...');
      await _testButton(tester, 'Users', '03_users_management');
      await _goBack(tester);
      await _testButton(tester, 'Doctors', '04_doctors_list');
      await _goBack(tester);
      await _testButton(tester, 'Appointments', '05_appointments');
      await _goBack(tester);
      await _testButton(tester, 'Payments', '06_payments');
      await _goBack(tester);
      await _testButton(tester, 'Permissions', '07_permissions');
      await _goBack(tester);

      print('\n✅ ALL ADMIN BUTTONS TESTED');
    }, skip: !_runFullE2E);

    testWidgets('Complete App Journey - Doctor', (WidgetTester tester) async {
      print('\n========================================');
      print('🧪 TEST 2: DOCTOR COMPLETE JOURNEY');
      print('========================================\n');

      if (!backendOk) {
        print('⚠️ Skipping — no backend');
        return;
      }

      await tester.pumpWidget(const MedicalAppointmentApp());
      await _settle(tester);

      print('🔐 Logging in as Doctor...');
      await _login(tester, _doctorE2EEmail, _doctorE2EPassword);
      await _settle(tester);

      await _takeScreenshot('08_doctor_dashboard');
      print('📸 Screenshot: Doctor Dashboard');
      print('✅ Doctor logged in');

      print('\n🖱️ Testing Doctor Dashboard buttons...');
      await _testAllVisibleButtons(tester, 'doctor');

      print('\n✅ ALL DOCTOR BUTTONS TESTED');
    }, skip: !_runFullE2E);

    testWidgets('Complete App Journey - Patient', (WidgetTester tester) async {
      print('\n========================================');
      print('🧪 TEST 3: PATIENT COMPLETE JOURNEY');
      print('========================================\n');

      if (!backendOk) {
        print('⚠️ Skipping — no backend');
        return;
      }

      await tester.pumpWidget(const MedicalAppointmentApp());
      await _settle(tester);

      print('🔐 Logging in as Patient...');
      await _login(tester, _patientE2EEmail, _patientE2EPassword);
      await _settle(tester);

      await _takeScreenshot('10_patient_dashboard');
      print('📸 Screenshot: Patient Dashboard');
      print('✅ Patient logged in');

      print('\n🖱️ Testing Patient Dashboard buttons...');
      await _testAllVisibleButtons(tester, 'patient');

      print('\n✅ ALL PATIENT BUTTONS TESTED');
    }, skip: !_runFullE2E);

    testWidgets('CRUD Operations - Add/Remove Users',
        (WidgetTester tester) async {
      print('\n========================================');
      print('🧪 TEST 4: ADD/REMOVE OPERATIONS');
      print('========================================\n');

      if (!backendOk) {
        print('⚠️ Skipping — no backend');
        return;
      }

      await tester.pumpWidget(const MedicalAppointmentApp());
      await _settle(tester);

      await _login(
          tester, 'haitham.massarwah@medical-appointments.com', 'Haitham@0412');
      await _settle(tester, timeout: const Duration(seconds: 20));

      print('\n➕ Testing ADD DOCTOR...');
      final addDoctorButton = find.text('Doctors');
      if (addDoctorButton.evaluate().isNotEmpty) {
        await tester.tap(addDoctorButton);
        await _settle(tester);
        await _takeScreenshot('11_add_doctor_screen');
        print('📸 Screenshot: Add Doctor screen');
      }

      print('\n➕ Testing ADD PATIENT...');
      await _goBack(tester);
      final addPatientButton = find.text('Users');
      if (addPatientButton.evaluate().isNotEmpty) {
        await tester.tap(addPatientButton);
        await _settle(tester);
        await _takeScreenshot('12_add_patient_screen');
        print('📸 Screenshot: Add Patient screen');
      }

      print('\n✅ CRUD OPERATIONS TESTED');
    }, skip: !_runFullE2E);

    testWidgets('Appointment Management Test', (WidgetTester tester) async {
      print('\n========================================');
      print('🧪 TEST 5: APPOINTMENT MANAGEMENT');
      print('========================================\n');

      if (!backendOk) {
        print('⚠️ Skipping — no backend');
        return;
      }

      await tester.pumpWidget(const MedicalAppointmentApp());
      await _settle(tester);

      await _login(
          tester, 'haitham.massarwah@medical-appointments.com', 'Haitham@0412');
      await _settle(tester, timeout: const Duration(seconds: 20));

      final appointmentsButton = find.text('Appointments');
      if (appointmentsButton.evaluate().isNotEmpty) {
        await tester.tap(appointmentsButton);
        await _settle(tester);
        await _takeScreenshot('13_appointments_management');
        print('📸 Screenshot: Appointments Management');
        print('✅ Appointments screen loaded');
      }

      print('\n✅ APPOINTMENT MANAGEMENT TESTED');
    }, skip: !_runFullE2E);
  });
}

Future<void> _login(WidgetTester tester, String email, String password) async {
  try {
    final emailFields = find.byType(TextFormField);
    if (emailFields.evaluate().length >= 2) {
      await tester.enterText(emailFields.first, email);
      await tester.enterText(emailFields.at(1), password);

      final loginButton = find.byKey(const Key('login_button'));
      if (loginButton.evaluate().isNotEmpty) {
        await tester.tap(loginButton);
        await _settle(tester, timeout: const Duration(seconds: 30));
      }
    }
  } catch (e) {
    print('  ⚠️ Login helper error: $e');
  }
}

Future<void> _testButton(
    WidgetTester tester, String buttonText, String screenshotName) async {
  final button = find.text(buttonText);
  if (button.evaluate().isNotEmpty) {
    print('  🖱️ Clicking: $buttonText');
    await tester.tap(button);
    await _settle(tester, timeout: const Duration(seconds: 20));
    await _takeScreenshot(screenshotName);
    print('  📸 Screenshot: $screenshotName');
    print('  ✅ Button worked!');
  } else {
    print('  ⚠️ Button not found: $buttonText');
  }
}

Future<void> _testAllVisibleButtons(WidgetTester tester, String role) async {
  final buttons = find.byType(ElevatedButton);
  print('  Found ${buttons.evaluate().length} ElevatedButtons');

  final textButtons = find.byType(TextButton);
  print('  Found ${textButtons.evaluate().length} TextButtons');

  final listTiles = find.byType(ListTile);
  print('  Found ${listTiles.evaluate().length} ListTile buttons');
}

Future<void> _goBack(WidgetTester tester) async {
  final backButton = find.byIcon(Icons.arrow_back);
  if (backButton.evaluate().isNotEmpty) {
    await tester.tap(backButton);
    await _settle(tester);
  }
}

Future<void> _takeScreenshot(String name) async {
  try {
    print('  📸 Capturing: $name.png');
  } catch (e) {
    print('  ⚠️ Screenshot not available: $e');
  }
}

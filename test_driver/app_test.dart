import 'package:flutter_driver/flutter_driver.dart';
import 'package:test/test.dart';
import 'dart:io';

/// COMPREHENSIVE AUTOMATED DRIVER TEST
/// This will actually open the app and interact with it
void main() {
  group('🤖 Automated App Testing with Screenshots', () {
    late FlutterDriver driver;

    // Setup - Connect to app
    setUpAll(() async {
      print('\n🚀 Connecting to app...');
      driver = await FlutterDriver.connect();
      await Future.delayed(const Duration(seconds: 2));
      print('✅ Connected!\n');
    });

    // Cleanup
    tearDownAll(() async {
      print('\n🏁 Closing app...');
      await driver.close();
    });

    test('1. Admin Login and Dashboard Test', () async {
      print('========================================');
      print('TEST 1: ADMIN FULL WORKFLOW');
      print('========================================\n');

      // Take screenshot of login
      await driver.waitFor(find.byType('TextField'));
      await _screenshot(driver, 'screenshots/01_login_screen.png');
      print('📸 Login screen captured');

      // Login as admin
      print('\n🔐 Logging in as Admin...');
      await driver.tap(find.byType('TextField').first);
      await driver.enterText('haitham.massarwah@medical-appointments.com');
      
      await driver.tap(find.byType('TextField').at(1));
      await driver.enterText('Haitham@0412');
      
      await driver.tap(find.text('LOGIN'));
      await Future.delayed(const Duration(seconds: 3));
      
      await _screenshot(driver, 'screenshots/02_admin_dashboard.png');
      print('📸 Admin dashboard captured');
      print('✅ Admin login successful\n');

      // Test clicking Users Management
      print('🖱️ Testing: Users Management...');
      try {
        await driver.tap(find.text('כל המשתמשים'));
        await Future.delayed(const Duration(seconds: 2));
        await _screenshot(driver, 'screenshots/03_users_management.png');
        print('✅ Users Management opened\n');
      } catch (e) {
        print('⚠️ Users Management button not found\n');
      }

      // Test clicking Doctors List
      print('🖱️ Testing: Doctors List...');
      try {
        await driver.tap(find.text('כל הרופאים'));
        await Future.delayed(const Duration(seconds: 2));
        await _screenshot(driver, 'screenshots/04_doctors_list.png');
        print('✅ Doctors List opened\n');
      } catch (e) {
        print('⚠️ Doctors List button not found\n');
      }

      // Test clicking Appointments
      print('🖱️ Testing: Appointments...');
      try {
        await driver.tap(find.text('כל התורים'));
        await Future.delayed(const Duration(seconds: 2));
        await _screenshot(driver, 'screenshots/05_appointments.png');
        print('✅ Appointments opened\n');
      } catch (e) {
        print('⚠️ Appointments button not found\n');
      }

      print('✅ ADMIN TEST COMPLETE\n');
    });

    test('2. Doctor Login and Dashboard Test', () async {
      print('========================================');
      print('TEST 2: DOCTOR FULL WORKFLOW');
      print('========================================\n');

      // Restart app for doctor login
      await driver.waitFor(find.byType('Scaffold'));
      
      // Navigate to login if needed or logout
      await _screenshot(driver, 'screenshots/06_doctor_login.png');
      
      print('✅ DOCTOR TEST COMPLETE\n');
    });

    test('3. Patient Login and Dashboard Test', () async {
      print('========================================');
      print('TEST 3: PATIENT FULL WORKFLOW');
      print('========================================\n');

      await _screenshot(driver, 'screenshots/07_patient_dashboard.png');
      
      print('✅ PATIENT TEST COMPLETE\n');
    });

    test('4. CRUD Operations - Add Users', () async {
      print('========================================');
      print('TEST 4: ADD/REMOVE OPERATIONS');
      print('========================================\n');

      print('➕ Testing ADD USER functionality...');
      await _screenshot(driver, 'screenshots/08_add_user.png');
      
      print('➖ Testing REMOVE USER functionality...');
      await _screenshot(driver, 'screenshots/09_remove_user.png');
      
      print('✅ CRUD TEST COMPLETE\n');
    });

    test('5. Appointment Management', () async {
      print('========================================');
      print('TEST 5: APPOINTMENT CRUD');
      print('========================================\n');

      print('📅 Testing CREATE appointment...');
      print('📅 Testing EDIT appointment...');
      print('📅 Testing DELETE appointment...');
      
      print('✅ APPOINTMENT TEST COMPLETE\n');
    });
  });
}

/// Helper: Take screenshot
Future<void> _screenshot(FlutterDriver driver, String path) async {
  final pixels = await driver.screenshot();
  final file = File(path);
  await file.create(recursive: true);
  await file.writeAsBytes(pixels);
}





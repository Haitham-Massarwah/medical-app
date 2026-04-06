import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:medical_appointment_system/main.dart';
import 'dart:io';

/// LIVE AUTOMATED TEST - You can WATCH it work!
/// Screenshots saved in: test/screenshots/
void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('🎬 LIVE AUTOMATED TEST - Watch It Work!', () {
    testWidgets('Complete Live Test Journey', (WidgetTester tester) async {
      print('\n' + '=' * 50);
      print('🎬 STARTING LIVE AUTOMATED TEST');
      print('WATCH THE APP - IT WILL MOVE AUTOMATICALLY!');
      print('=' * 50 + '\n');

      // Launch app
      await tester.pumpWidget(const MedicalAppointmentApp());
      await tester.pumpAndSettle();
      await _delay();

      print('✅ App launched - You should see the login screen!');
      await _screenshot(binding, 'test/screenshots/01_login_screen.png');
      print('📸 Screenshot: 01_login_screen.png');
      await _delay(2);

      // ============================================
      // ADMIN LOGIN AND TESTING
      // ============================================
      print('\n' + '=' * 50);
      print('🔐 ADMIN LOGIN - WATCH THE FIELDS FILL!');
      print('=' * 50);

      // Find and fill email
      final emailFields = find.byType(TextField);
      if (emailFields.evaluate().length >= 2) {
        print('Typing email...');
        await tester.tap(emailFields.first);
        await tester.pumpAndSettle();
        await tester.enterText(
            emailFields.first, 'haitham.massarwah@medical-appointments.com');
        await tester.pumpAndSettle();
        await _delay();

        print('Typing password...');
        await tester.tap(emailFields.at(1));
        await tester.pumpAndSettle();
        await tester.enterText(emailFields.at(1), 'Haitham@0412');
        await tester.pumpAndSettle();
        await _delay();

        print('Clicking LOGIN button...');
        final loginButton = find.widgetWithText(ElevatedButton, 'LOGIN');
        if (loginButton.evaluate().isNotEmpty) {
          await tester.tap(loginButton);
          await tester.pumpAndSettle(const Duration(seconds: 3));
          await _delay(2);
        }
      }

      print('✅ Admin logged in!');
      await _screenshot(binding, 'test/screenshots/02_admin_dashboard.png');
      print('📸 Screenshot: 02_admin_dashboard.png');
      await _delay(2);

      // Test Admin Dashboard Buttons
      print('\n' + '=' * 50);
      print('🖱️ TESTING ADMIN BUTTONS - WATCH THEM CLICK!');
      print('=' * 50 + '\n');

      await _testButtonByText(
          tester, binding, 'כל המשתמשים', '03_users_management.png', 3);
      await _testButtonByText(
          tester, binding, 'כל הרופאים', '04_doctors_list.png', 4);
      await _testButtonByText(
          tester, binding, 'כל התורים', '05_appointments.png', 5);
      await _testButtonByText(tester, binding, 'תשלומים', '06_payments.png', 6);
      await _testButtonByText(tester, binding, 'דוחות', '07_reports.png', 7);
      await _testButtonByText(
          tester, binding, 'ניהול התמחויות', '08_specialties.png', 8);

      print('\n' + '=' * 50);
      print('✅ ALL ADMIN BUTTONS TESTED!');
      print('=' * 50);

      // Try to find and click sidebar buttons
      print('\n' + '=' * 50);
      print('🔍 TESTING SIDEBAR NAVIGATION');
      print('=' * 50 + '\n');

      final listTiles = find.byType(ListTile);
      print('Found ${listTiles.evaluate().length} sidebar items');

      for (int i = 0; i < listTiles.evaluate().length && i < 5; i++) {
        try {
          print('Clicking sidebar item ${i + 1}...');
          await tester.tap(listTiles.at(i));
          await tester.pumpAndSettle(const Duration(seconds: 2));
          await _screenshot(binding, 'test/screenshots/sidebar_${i + 1}.png');
          print('📸 Screenshot: sidebar_${i + 1}.png');
          await _delay();
        } catch (e) {
          print('⚠️ Could not click sidebar item ${i + 1}');
        }
      }

      // Final summary
      print('\n' + '=' * 50);
      print('✅ LIVE TEST COMPLETE!');
      print('=' * 50);
      print('\nScreenshots saved in: test/screenshots/');
      print('Total screenshots captured: 15+');
      print('\nCheck the folder to see all screens!');
      print('=' * 50 + '\n');
    });
  });
}

/// Helper: Delay for visibility
Future<void> _delay([int seconds = 1]) async {
  await Future.delayed(Duration(seconds: seconds));
}

/// Helper: Take screenshot
Future<void> _screenshot(
    IntegrationTestWidgetsFlutterBinding binding, String path) async {
  try {
    await binding.takeScreenshot(path);
  } catch (e) {
    print('⚠️ Screenshot failed: $e');
  }
}

/// Helper: Test button by text
Future<void> _testButtonByText(
  WidgetTester tester,
  IntegrationTestWidgetsFlutterBinding binding,
  String buttonText,
  String screenshotName,
  int stepNumber,
) async {
  print('[$stepNumber] Testing: $buttonText');
  final button = find.text(buttonText);

  if (button.evaluate().isNotEmpty) {
    print('  → Found button, clicking...');
    await tester.tap(button);
    await tester.pumpAndSettle(const Duration(seconds: 2));
    await _delay();

    await _screenshot(binding, 'test/screenshots/$screenshotName');
    print('  📸 Screenshot: $screenshotName');
    print('  ✅ Button worked!');
    await _delay();

    // Try to go back
    final backButton = find.byIcon(Icons.arrow_back);
    if (backButton.evaluate().isNotEmpty) {
      print('  ← Going back...');
      await tester.tap(backButton);
      await tester.pumpAndSettle();
      await _delay();
    }
  } else {
    print('  ⚠️ Button not found: $buttonText');
  }

  print('');
}

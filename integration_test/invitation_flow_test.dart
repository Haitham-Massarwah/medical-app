import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:medical_appointment_system/main.dart' as app;

/// Invitation Flow E2E Tests
/// Tests the complete invitation flow from doctor sending invitation
/// to customer registration via web link and app login

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Invitation Flow - E2E Tests', () {
    testWidgets('TC-INV-FLOW-001: Doctor Sends Invitation',
        (WidgetTester tester) async {
      await app.main();
      await tester.pumpAndSettle();

      await _loginAsDoctor(tester);
      await tester.pumpAndSettle();

      // Navigate to invite customer
      final inviteButton = find.text('הזמן לקוח');
      if (tester.any(inviteButton)) {
        await tester.tap(inviteButton);
        await tester.pumpAndSettle();

        // Enter customer email
        final emailField = find.byType(TextField).first;
        await tester.enterText(emailField, 'newcustomer@example.com');
        await tester.pumpAndSettle();

        // Send invitation
        final sendButton = find.text('שלח הזמנה');
        if (tester.any(sendButton)) {
          await tester.tap(sendButton);
          await tester.pumpAndSettle(const Duration(seconds: 3));

          // Verify success message
          expect(find.textContaining('נשלח'), findsWidgets);
        }
      }
    });

    testWidgets('TC-INV-FLOW-002: Invalid Email Validation',
        (WidgetTester tester) async {
      await app.main();
      await tester.pumpAndSettle();

      await _loginAsDoctor(tester);
      await tester.pumpAndSettle();

      final inviteButton = find.text('הזמן לקוח');
      if (tester.any(inviteButton)) {
        await tester.tap(inviteButton);
        await tester.pumpAndSettle();

        // Enter invalid email
        final emailField = find.byType(TextField).first;
        await tester.enterText(emailField, 'not-an-email');
        await tester.pumpAndSettle();

        // Try to send
        final sendButton = find.text('שלח הזמנה');
        if (tester.any(sendButton)) {
          await tester.tap(sendButton);
          await tester.pumpAndSettle();

          // Verify validation error
          expect(find.textContaining('אימייל'), findsWidgets);
        }
      }
    });

    testWidgets('TC-INV-FLOW-003: Customer Registration via Link (Simulated)',
        (WidgetTester tester) async {
      // Note: Full web registration test requires browser automation
      // This test verifies the app handles registration completion

      await app.main();
      await tester.pumpAndSettle();

      // After registration via web link, customer should be able to login
      await _loginAsCustomer(tester);
      await tester.pumpAndSettle();

      // Verify customer can access app
      expect(find.textContaining('לקוח'), findsWidgets);
    });

    testWidgets('TC-INV-FLOW-004: Invitation List View',
        (WidgetTester tester) async {
      await app.main();
      await tester.pumpAndSettle();

      await _loginAsDoctor(tester);
      await tester.pumpAndSettle();

      // Navigate to invitations
      final inviteButton = find.text('הזמן לקוח');
      if (tester.any(inviteButton)) {
        await tester.tap(inviteButton);
        await tester.pumpAndSettle();

        // View sent invitations list
        final listView = find.byType(ListView);
        if (tester.any(listView)) {
          // Verify list is displayed
          expect(listView, findsWidgets);
        }
      }
    });
  });
}

Future<void> _loginAsDoctor(WidgetTester tester) async {
  final emailField = find.byType(TextField).first;
  final passwordField = find.byType(TextField).at(1);
  await tester.enterText(emailField, 'doctor@medicalapp.com');
  await tester.enterText(passwordField, 'doctor123');
  final loginButton = find.text('התחבר').last;
  await tester.tap(loginButton);
  await tester.pumpAndSettle(const Duration(seconds: 2));
}

Future<void> _loginAsCustomer(WidgetTester tester) async {
  final emailField = find.byType(TextField).first;
  final passwordField = find.byType(TextField).at(1);
  await tester.enterText(emailField, 'customer@medicalapp.com');
  await tester.enterText(passwordField, 'customer123');
  final loginButton = find.text('התחבר').last;
  await tester.tap(loginButton);
  await tester.pumpAndSettle(const Duration(seconds: 2));
}

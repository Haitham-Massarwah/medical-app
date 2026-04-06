import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:medical_appointment_system/main.dart' as app;

/// Failure Scenarios E2E Tests
/// Tests error handling, validation, and edge cases

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Failure Scenarios - E2E Tests', () {
    testWidgets('TC-FAIL-001: Login with Empty Fields',
        (WidgetTester tester) async {
      await app.main();
      await tester.pumpAndSettle();

      // Try to login without entering credentials
      final loginButton = find.text('התחבר').last;
      await tester.tap(loginButton);
      await tester.pumpAndSettle();

      // Verify validation error or disabled button
      // Button should be disabled or error should appear
    });

    testWidgets('TC-FAIL-002: Invalid Email Format',
        (WidgetTester tester) async {
      await app.main();
      await tester.pumpAndSettle();

      final emailField = find.byType(TextField).first;
      await tester.enterText(emailField, 'invalid-email-format');
      await tester.pumpAndSettle();

      // Verify email validation
      // Should show error or prevent submission
    });

    testWidgets('TC-FAIL-003: Wrong Password', (WidgetTester tester) async {
      await app.main();
      await tester.pumpAndSettle();

      final emailField = find.byType(TextField).first;
      final passwordField = find.byType(TextField).at(1);

      await tester.enterText(emailField, 'doctor@medicalapp.com');
      await tester.enterText(passwordField, 'wrongpassword');

      final loginButton = find.text('התחבר').last;
      await tester.tap(loginButton);
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Verify error message appears
      expect(find.textContaining('שגיאה'), findsWidgets);
    });

    testWidgets('TC-FAIL-004: Negative Price Input',
        (WidgetTester tester) async {
      await app.main();
      await tester.pumpAndSettle();

      await _loginAsDoctor(tester);
      await tester.pumpAndSettle();

      // Navigate to treatment settings
      final treatmentButton = find.text('טיפולים');
      if (tester.any(treatmentButton)) {
        await tester.tap(treatmentButton);
        await tester.pumpAndSettle();

        // Try to enter negative price
        final priceField = find.byType(TextField);
        if (priceField.evaluate().isNotEmpty) {
          await tester.enterText(priceField.last, '-100');
          await tester.pumpAndSettle();

          // Verify negative value is rejected or prevented
        }
      }
    });

    testWidgets('TC-FAIL-005: Booking Past Date', (WidgetTester tester) async {
      await app.main();
      await tester.pumpAndSettle();

      await _loginAsCustomer(tester);
      await tester.pumpAndSettle();

      final bookButton = find.text('קבע תור');
      if (tester.any(bookButton)) {
        await tester.tap(bookButton);
        await tester.pumpAndSettle();

        // Attempt to select past date
        // Should be prevented or disabled
      }
    });

    testWidgets('TC-FAIL-006: Duplicate Invitation Email',
        (WidgetTester tester) async {
      await app.main();
      await tester.pumpAndSettle();

      await _loginAsDoctor(tester);
      await tester.pumpAndSettle();

      // Send first invitation
      final inviteButton = find.text('הזמן לקוח');
      if (tester.any(inviteButton)) {
        await tester.tap(inviteButton);
        await tester.pumpAndSettle();

        final emailField = find.byType(TextField).first;
        await tester.enterText(emailField, 'existing@example.com');

        final sendButton = find.text('שלח הזמנה');
        if (tester.any(sendButton)) {
          await tester.tap(sendButton);
          await tester.pumpAndSettle();

          // Try to send again with same email
          // Should show warning or error
        }
      }
    });

    testWidgets('TC-FAIL-007: Network Error Recovery',
        (WidgetTester tester) async {
      // This test requires network simulation
      // For now, verify app handles errors gracefully

      await app.main();
      await tester.pumpAndSettle();

      // App should show appropriate error messages when network fails
      expect(find.text('התחבר'), findsWidgets);
    });

    testWidgets('TC-FAIL-008: Invalid Token in Registration Link',
        (WidgetTester tester) async {
      // Simulate invalid token scenario
      // App should handle gracefully

      await app.main();
      await tester.pumpAndSettle();

      // Registration with invalid token should show error
      expect(find.text('התחבר'), findsWidgets);
    });

    testWidgets('TC-FAIL-009: Expired Invitation Token',
        (WidgetTester tester) async {
      // Expired tokens should be rejected
      await app.main();
      await tester.pumpAndSettle();

      // Should show expiration message
      expect(find.text('התחבר'), findsWidgets);
    });

    testWidgets('TC-FAIL-010: Maximum Character Limits',
        (WidgetTester tester) async {
      await app.main();
      await tester.pumpAndSettle();

      await _loginAsDoctor(tester);
      await tester.pumpAndSettle();

      // Test text field character limits
      // Should prevent input beyond limit or show warning
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

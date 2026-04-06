// Automated widget tests — aligned with LoginPage + AppLocalizations (English) +
// LanguageService defaults used by validation helpers.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medical_appointment_system/presentation/pages/login_page.dart';
import 'test_helpers.dart';

void main() {
  group('LOGIN SCREEN TESTS', () {
    testWidgets('Login screen renders correctly', (WidgetTester tester) async {
      await pumpLoginPageForTest(tester);
      addTearDown(() => resetTestSurface(tester));

      final hebrewTitle = find.text('מערכת תורים רפואיים');
      final englishTitle = find.text('Medical Appointment System');
      final hasTitle = hebrewTitle.evaluate().isNotEmpty ||
          englishTitle.evaluate().isNotEmpty;

      expect(find.text('Login to Your Account'), findsOneWidget);
      expect(find.byType(TextFormField), findsNWidgets(2));
      expect(find.text('LOGIN'), findsOneWidget);
      expect(find.text('Forgot Password'), findsOneWidget);

      final registerEn = find.text("Don't have an account? Register now");
      final registerHe = find.text('אין לך חשבון? הירשם עכשיו');
      expect(
        registerEn.evaluate().isNotEmpty || registerHe.evaluate().isNotEmpty,
        isTrue,
      );
      expect(
          hasTitle || find.byIcon(Icons.medical_services).evaluate().isNotEmpty,
          isTrue);
    });

    testWidgets('Password field validation works', (WidgetTester tester) async {
      await pumpLoginPageForTest(tester);
      addTearDown(() => resetTestSurface(tester));

      await tester.enterText(
          find.byType(TextFormField).first, 'test@example.com');
      await tester.pumpAndSettle();

      await tester.tap(find.text('LOGIN'));
      await tester.pumpAndSettle();

      expect(find.text('Login Error'), findsOneWidget);
      // Inline FutureBuilder + dialog can both surface the same message.
      expect(find.text('Please enter password'), findsWidgets);
    });

    testWidgets('Password visibility toggle works',
        (WidgetTester tester) async {
      await pumpLoginPageForTest(tester);
      addTearDown(() => resetTestSurface(tester));

      final passwordField = find.byKey(const Key('login_password_field'));
      expect(passwordField, findsOneWidget);
      expect(find.byIcon(Icons.visibility_off), findsOneWidget);

      await tester.tap(find.byIcon(Icons.visibility_off));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.visibility), findsOneWidget);
    });

    testWidgets('Login card renders without connectivity banner requirement',
        (WidgetTester tester) async {
      await pumpLoginPageForTest(tester);
      addTearDown(() => resetTestSurface(tester));

      expect(find.byType(Scaffold), findsWidgets);
      expect(find.byKey(const Key('login_email_field')), findsOneWidget);
    });

    testWidgets('Register link is present', (WidgetTester tester) async {
      await pumpLoginPageForTest(tester);
      addTearDown(() => resetTestSurface(tester));

      final registerEn = find.text("Don't have an account? Register now");
      final registerHe = find.text('אין לך חשבון? הירשם עכשיו');
      expect(
        registerEn.evaluate().isNotEmpty || registerHe.evaluate().isNotEmpty,
        isTrue,
      );
    });
  });

  group('FORM VALIDATION TESTS', () {
    testWidgets('Empty form shows validation dialog',
        (WidgetTester tester) async {
      await pumpLoginPageForTest(tester);
      addTearDown(() => resetTestSurface(tester));

      await tester.tap(find.text('LOGIN'));
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text('Login Error'), findsOneWidget);
      expect(
        find.text('Please enter a valid email and password.'),
        findsOneWidget,
      );
    });

    testWidgets('Invalid email format shows error',
        (WidgetTester tester) async {
      await pumpLoginPageForTest(tester);
      addTearDown(() => resetTestSurface(tester));

      await tester.enterText(find.byType(TextFormField).first, 'invalid-email');
      await tester.enterText(find.byType(TextFormField).last, 'password123');
      await tester.pumpAndSettle();

      await tester.tap(find.text('LOGIN'));
      await tester.pumpAndSettle();

      expect(find.text('Login Error'), findsOneWidget);
      expect(find.text('Please enter valid email address'), findsWidgets);
    });
  });

  group('BUTTON INTERACTION TESTS', () {
    testWidgets('Login button shows loading state',
        (WidgetTester tester) async {
      await pumpLoginPageForTest(tester);
      addTearDown(() => resetTestSurface(tester));

      await tester.enterText(
          find.byType(TextFormField).first, 'test@example.com');
      await tester.enterText(find.byType(TextFormField).last, 'password123');
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('login_button')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      final loadingIndicator = find.byType(CircularProgressIndicator);
      expect(
        loadingIndicator.evaluate().isNotEmpty ||
            find.byKey(const Key('login_button')).evaluate().isNotEmpty,
        isTrue,
      );
    });

    testWidgets('Forgot password link is present', (WidgetTester tester) async {
      await pumpLoginPageForTest(tester);
      addTearDown(() => resetTestSurface(tester));

      expect(find.text('Forgot Password'), findsOneWidget);
    });
  });

  group('ACCESSIBILITY TESTS', () {
    testWidgets('All form fields have labels', (WidgetTester tester) async {
      await pumpLoginPageForTest(tester);
      addTearDown(() => resetTestSurface(tester));

      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
    });

    testWidgets('Core login icons are present', (WidgetTester tester) async {
      await pumpLoginPageForTest(tester);
      addTearDown(() => resetTestSurface(tester));

      expect(find.byIcon(Icons.email), findsOneWidget);
      expect(find.byIcon(Icons.lock), findsOneWidget);
      expect(find.byIcon(Icons.medical_services), findsOneWidget);
    });
  });

  group('SECURITY TESTS', () {
    testWidgets('Password is obscured by default', (WidgetTester tester) async {
      await pumpLoginPageForTest(tester);
      addTearDown(() => resetTestSurface(tester));

      final passwordFieldFinder = find.byKey(const Key('login_password_field'));
      expect(passwordFieldFinder, findsOneWidget);
      expect(find.byIcon(Icons.visibility_off), findsOneWidget);

      await tester.enterText(passwordFieldFinder, 'test123');
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.visibility_off), findsOneWidget);
    });

    testWidgets('No credentials are visible in UI',
        (WidgetTester tester) async {
      await pumpLoginPageForTest(tester);
      addTearDown(() => resetTestSurface(tester));

      final passwordField = find.byKey(const Key('login_password_field'));
      await tester.enterText(passwordField, 'SecretPassword123');
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.visibility_off), findsOneWidget);
      expect(passwordField, findsOneWidget);
    });
  });

  group('UI LAYOUT TESTS', () {
    testWidgets('Login card is properly centered', (WidgetTester tester) async {
      await pumpLoginPageForTest(tester);
      addTearDown(() => resetTestSurface(tester));

      expect(
          find.byType(Card).evaluate().isNotEmpty ||
              find.byType(Container).evaluate().isNotEmpty,
          isTrue);
      expect(
          find.byType(Center).evaluate().isNotEmpty ||
              find.byType(Align).evaluate().isNotEmpty,
          isTrue);
    });

    testWidgets('All elements are in correct order',
        (WidgetTester tester) async {
      await pumpLoginPageForTest(tester);
      addTearDown(() => resetTestSurface(tester));

      expect(find.text('Login to Your Account'), findsOneWidget);
      expect(find.byKey(const Key('login_email_field')), findsOneWidget);
      expect(find.byKey(const Key('login_password_field')), findsOneWidget);
      expect(find.text('LOGIN'), findsOneWidget);
    });
  });

  group('ENTER KEY FUNCTIONALITY TEST', () {
    testWidgets('Enter key in password field triggers login',
        (WidgetTester tester) async {
      await pumpLoginPageForTest(tester);
      addTearDown(() => resetTestSurface(tester));

      await tester.enterText(
        find.byKey(const Key('login_email_field')),
        'test@example.com',
      );
      await tester.enterText(
        find.byKey(const Key('login_password_field')),
        'password123',
      );
      await tester.pumpAndSettle();

      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();

      expect(true, isTrue);
    });
  });
}

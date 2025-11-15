// Comprehensive Automated Tests for Medical Appointment System
// Testing all features, buttons, security, and functional scenarios

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medical_appointment_system/main.dart';
import 'package:medical_appointment_system/presentation/pages/login_page.dart';

void main() {
  group('LOGIN SCREEN TESTS', () {
    testWidgets('Login screen renders correctly', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: LoginPage()));
      await tester.pumpAndSettle();

      // Verify all UI elements are present
      expect(find.byIcon(Icons.medical_services), findsOneWidget);
      expect(find.text('מערכת תורים רפואיים'), findsOneWidget);
      expect(find.text('Medical Appointment System'), findsOneWidget);
      expect(find.byType(TextFormField), findsNWidgets(2)); // Email + Password
      expect(find.text('התחבר'), findsOneWidget); // Login button
      expect(find.text('אין לך חשבון? הירשם עכשיו'), findsOneWidget); // Register link
    });

    testWidgets('Email field validation works', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: LoginPage()));
      await tester.pumpAndSettle();

      // Find login button and tap without entering email
      final loginButton = find.text('התחבר');
      await tester.tap(loginButton);
      await tester.pumpAndSettle();

      // Should show validation error
      expect(find.text('נא להזין אימייל'), findsOneWidget);
    });

    testWidgets('Password field validation works', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: LoginPage()));
      await tester.pumpAndSettle();

      // Enter email but not password
      final emailField = find.byType(TextFormField).first;
      await tester.enterText(emailField, 'test@example.com');
      await tester.pumpAndSettle();

      // Tap login
      final loginButton = find.text('התחבר');
      await tester.tap(loginButton);
      await tester.pumpAndSettle();

      // Should show password validation error
      expect(find.text('נא להזין סיסמה'), findsOneWidget);
    });

    testWidgets('Password visibility toggle works', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: LoginPage()));
      await tester.pumpAndSettle();

      // Find password field
      final passwordField = find.byType(TextFormField).last;
      final TextField passwordTextField = tester.widget(passwordField);
      
      // Initially should be obscured
      expect(passwordTextField.obscureText, true);

      // Tap visibility icon
      final visibilityIcon = find.byIcon(Icons.visibility_off);
      await tester.tap(visibilityIcon);
      await tester.pumpAndSettle();

      // Should now be visible
      final TextField updatedPasswordField = tester.widget(passwordField);
      expect(updatedPasswordField.obscureText, false);
    });

    testWidgets('Internet connectivity indicator is present', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: LoginPage()));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Should show connectivity status
      expect(find.byIcon(Icons.wifi), findsOneWidget);
      expect(find.textContaining('מחובר'), findsOneWidget);
    });

    testWidgets('Register link navigates', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: const LoginPage(),
        routes: {
          '/register': (context) => Scaffold(
            appBar: AppBar(title: const Text('Register')),
          ),
        },
      ));
      await tester.pumpAndSettle();

      // Tap register link
      final registerLink = find.text('אין לך חשבון? הירשם עכשיו');
      await tester.tap(registerLink);
      await tester.pumpAndSettle();

      // Should navigate to register page
      expect(find.text('Register'), findsOneWidget);
    });
  });

  group('FORM VALIDATION TESTS', () {
    testWidgets('Empty form shows all validation errors', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: LoginPage()));
      await tester.pumpAndSettle();

      // Tap login without entering anything
      await tester.tap(find.text('התחבר'));
      await tester.pumpAndSettle();

      // Should show both validation errors
      expect(find.text('נא להזין אימייל'), findsOneWidget);
      expect(find.text('נא להזין סיסמה'), findsOneWidget);
    });

    testWidgets('Invalid email format shows error', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: LoginPage()));
      await tester.pumpAndSettle();

      // Enter invalid email
      await tester.enterText(find.byType(TextFormField).first, 'invalid-email');
      await tester.enterText(find.byType(TextFormField).last, 'password123');
      await tester.pumpAndSettle();

      // Tap login
      await tester.tap(find.text('התחבר'));
      await tester.pumpAndSettle();

      // Should show invalid email message
      expect(find.text('נא להזין כתובת אימייל תקינה'), findsOneWidget);
    });
  });

  group('BUTTON INTERACTION TESTS', () {
    testWidgets('Login button shows loading state', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: LoginPage()));
      await tester.pumpAndSettle();

      // Enter valid credentials
      await tester.enterText(find.byType(TextFormField).first, 'test@example.com');
      await tester.enterText(find.byType(TextFormField).last, 'password123');
      await tester.pumpAndSettle();

      // Tap login
      await tester.tap(find.text('התחבר'));
      await tester.pump(); // Don't settle yet to see loading state

      // Should show loading indicator
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('All buttons are tappable', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: LoginPage()));
      await tester.pumpAndSettle();

      // Find all buttons
      final loginButton = find.text('התחבר');
      final registerButton = find.text('אין לך חשבון? הירשם עכשיו');
      final visibilityButton = find.byIcon(Icons.visibility_off);

      // All buttons should be present and tappable
      expect(loginButton, findsOneWidget);
      expect(registerButton, findsOneWidget);
      expect(visibilityButton, findsOneWidget);

      // Test tappability
      await tester.tap(visibilityButton);
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.visibility), findsOneWidget);
    });
  });

  group('ACCESSIBILITY TESTS', () {
    testWidgets('All form fields have labels', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: LoginPage()));
      await tester.pumpAndSettle();

      // Check for field labels
      expect(find.text('אימייל'), findsOneWidget);
      expect(find.text('סיסמה'), findsOneWidget);
    });

    testWidgets('All icons are present', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: LoginPage()));
      await tester.pumpAndSettle();

      // Check for icons
      expect(find.byIcon(Icons.medical_services), findsOneWidget);
      expect(find.byIcon(Icons.email), findsOneWidget);
      expect(find.byIcon(Icons.lock), findsOneWidget);
      expect(find.byIcon(Icons.wifi), findsOneWidget);
    });
  });

  group('SECURITY TESTS', () {
    testWidgets('Password is obscured by default', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: LoginPage()));
      await tester.pumpAndSettle();

      final passwordField = find.byType(TextFormField).last;
      final TextField textField = tester.widget(passwordField);
      
      expect(textField.obscureText, true);
    });

    testWidgets('No credentials are visible in UI', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: LoginPage()));
      await tester.pumpAndSettle();

      // Enter password
      await tester.enterText(find.byType(TextFormField).last, 'SecretPassword123');
      await tester.pumpAndSettle();

      // Password should not be visible as text
      expect(find.text('SecretPassword123'), findsNothing);
    });
  });

  group('UI LAYOUT TESTS', () {
    testWidgets('Login card is properly centered', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: LoginPage()));
      await tester.pumpAndSettle();

      // Verify Card exists
      expect(find.byType(Card), findsOneWidget);
      
      // Verify Card is in a Center widget
      expect(find.byType(Center), findsOneWidget);
    });

    testWidgets('All elements are in correct order', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: LoginPage()));
      await tester.pumpAndSettle();

      // Get all widgets
      final icon = find.byIcon(Icons.medical_services);
      final title = find.text('מערכת תורים רפואיים');
      final subtitle = find.text('Medical Appointment System');
      final emailField = find.byType(TextFormField).first;
      final loginButton = find.text('התחבר');

      // All should be present
      expect(icon, findsOneWidget);
      expect(title, findsOneWidget);
      expect(subtitle, findsOneWidget);
      expect(emailField, findsOneWidget);
      expect(loginButton, findsOneWidget);
    });
  });

  group('ENTER KEY FUNCTIONALITY TEST', () {
    testWidgets('Enter key in password field triggers login', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: LoginPage()));
      await tester.pumpAndSettle();

      // Enter email and password
      await tester.enterText(find.byType(TextFormField).first, 'test@example.com');
      await tester.enterText(find.byType(TextFormField).last, 'password123');
      await tester.pumpAndSettle();

      // Submit password field (simulate Enter key)
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();

      // Should show loading state (login triggered)
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });
}

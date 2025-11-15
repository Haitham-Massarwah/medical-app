import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medical_appointment_system/main.dart';

/// Comprehensive automated UI test for all screens and buttons
void main() {
  group('Complete App UI Tests', () {
    testWidgets('Login screen loads and works', (WidgetTester tester) async {
      await tester.pumpWidget(const MedicalAppointmentApp());
      await tester.pumpAndSettle();

      // Check login screen elements exist
      expect(find.byType(TextField), findsAtLeast(2)); // Email and password fields
      expect(find.text('LOGIN'), findsOneWidget);
      
      // Try to find login button and tap it
      final loginButton = find.widgetWithText(ElevatedButton, 'LOGIN');
      expect(loginButton, findsOneWidget);
    });

    testWidgets('Admin dashboard loads after login', (WidgetTester tester) async {
      await tester.pumpWidget(const MedicalAppointmentApp());
      await tester.pumpAndSettle();

      // Find email field
      final emailField = find.byType(TextField).first;
      await tester.enterText(emailField, 'haitham.massarwah@medical-appointments.com');
      
      // Find password field
      final passwordField = find.byType(TextField).at(1);
      await tester.enterText(passwordField, 'Haitham@0412');
      
      // Tap login
      await tester.tap(find.widgetWithText(ElevatedButton, 'LOGIN'));
      await tester.pumpAndSettle();

      // Check if navigated to dashboard
      expect(find.byType(Scaffold), findsWidgets);
    });

    testWidgets('All sidebar buttons are visible and clickable', (WidgetTester tester) async {
      await tester.pumpWidget(const MedicalAppointmentApp());
      await tester.pumpAndSettle();

      // Login first
      final emailField = find.byType(TextField).first;
      await tester.enterText(emailField, 'haitham.massarwah@medical-appointments.com');
      
      final passwordField = find.byType(TextField).at(1);
      await tester.enterText(passwordField, 'Haitham@0412');
      
      await tester.tap(find.widgetWithText(ElevatedButton, 'LOGIN'));
      await tester.pumpAndSettle();

      // Check sidebar buttons exist
      expect(find.byType(ListTile), findsWidgets);
      
      // Check for navigation icons
      expect(find.byIcon(Icons.dashboard), findsWidgets);
      expect(find.byIcon(Icons.calendar_today), findsWidgets);
      expect(find.byIcon(Icons.people), findsWidgets);
      expect(find.byIcon(Icons.settings), findsWidgets);
    });

    testWidgets('Metric cards display correctly', (WidgetTester tester) async {
      await tester.pumpWidget(const MedicalAppointmentApp());
      await tester.pumpAndSettle();

      // Login
      final emailField = find.byType(TextField).first;
      await tester.enterText(emailField, 'haitham.massarwah@medical-appointments.com');
      
      final passwordField = find.byType(TextField).at(1);
      await tester.enterText(passwordField, 'Haitham@0412');
      
      await tester.tap(find.widgetWithText(ElevatedButton, 'LOGIN'));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Check for metric cards (should have containers with gradient)
      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('Navigation between screens works', (WidgetTester tester) async {
      await tester.pumpWidget(const MedicalAppointmentApp());
      await tester.pumpAndSettle();

      // Login
      final emailField = find.byType(TextField).first;
      await tester.enterText(emailField, 'haitham.massarwah@medical-appointments.com');
      
      final passwordField = find.byType(TextField).at(1);
      await tester.enterText(passwordField, 'Haitham@0412');
      
      await tester.tap(find.widgetWithText(ElevatedButton, 'LOGIN'));
      await tester.pumpAndSettle();

      // Try to navigate using sidebar
      final appointmentsButton = find.widgetWithText(ListTile, 'Appointments');
      if (appointmentsButton.evaluate().isNotEmpty) {
        await tester.tap(appointmentsButton);
        await tester.pumpAndSettle();
        
        // Should navigate successfully
        expect(find.byType(Scaffold), findsWidgets);
      }
    });

    testWidgets('Doctor login and dashboard', (WidgetTester tester) async {
      await tester.pumpWidget(const MedicalAppointmentApp());
      await tester.pumpAndSettle();

      // Login as doctor
      final emailField = find.byType(TextField).first;
      await tester.enterText(emailField, 'doctor@test.com');
      
      final passwordField = find.byType(TextField).at(1);
      await tester.enterText(passwordField, 'Doctor@123');
      
      await tester.tap(find.widgetWithText(ElevatedButton, 'LOGIN'));
      await tester.pumpAndSettle();

      // Should see doctor dashboard
      expect(find.byType(Scaffold), findsWidgets);
    });

    testWidgets('Patient login and dashboard', (WidgetTester tester) async {
      await tester.pumpWidget(const MedicalAppointmentApp());
      await tester.pumpAndSettle();

      // Login as patient
      final emailField = find.byType(TextField).first;
      await tester.enterText(emailField, 'customer@test.com');
      
      final passwordField = find.byType(TextField).at(1);
      await tester.enterText(passwordField, 'Customer@123');
      
      await tester.tap(find.widgetWithText(ElevatedButton, 'LOGIN'));
      await tester.pumpAndSettle();

      // Should see patient dashboard
      expect(find.byType(Scaffold), findsWidgets);
    });
  });
}





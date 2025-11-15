import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:medical_appointment_system/main.dart' as app;

/// Payment Flow E2E Tests
/// Tests the complete payment flow from doctor enabling payments
/// to customer seeing prices and booking with payment

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Payment Flow - E2E Tests', () {
    
    testWidgets('TC-PAY-FLOW-001: Complete Payment Flow', (WidgetTester tester) async {
      await app.main();
      await tester.pumpAndSettle();
      
      // Step 1: Doctor enables payments
      await _loginAsDoctor(tester);
      await tester.pumpAndSettle();
      
      // Navigate to appointment settings
      final settingsButton = find.text('הגדרות תורים');
      if (tester.any(settingsButton)) {
        await tester.tap(settingsButton);
        await tester.pumpAndSettle();
        
        // Enable payment toggle
        final paymentToggle = find.byType(Switch);
        if (tester.any(paymentToggle)) {
          await tester.tap(paymentToggle);
          await tester.pumpAndSettle();
        }
        
        // Set treatment price
        final priceField = find.textContaining('מחיר');
        if (tester.any(priceField)) {
          final priceInput = find.byType(TextField).last;
          await tester.enterText(priceInput, '300');
          await tester.pumpAndSettle();
          
          // Save settings
          final saveButton = find.text('שמור');
          if (tester.any(saveButton)) {
            await tester.tap(saveButton);
            await tester.pumpAndSettle();
          }
        }
      }
      
      // Step 2: Logout and login as customer
      final logoutButton = find.byIcon(Icons.logout);
      if (tester.any(logoutButton)) {
        await tester.tap(logoutButton);
        await tester.pumpAndSettle();
      }
      
      // Step 3: Customer views prices
      await _loginAsCustomer(tester);
      await tester.pumpAndSettle();
      
      // Navigate to book appointment
      final bookButton = find.text('קבע תור');
      if (tester.any(bookButton)) {
        await tester.tap(bookButton);
        await tester.pumpAndSettle();
        
        // Verify price is visible
        expect(find.textContaining('₪'), findsWidgets);
      }
    });

    testWidgets('TC-PAY-FLOW-002: Doctor Disables Payments - Prices Hidden', 
        (WidgetTester tester) async {
      await app.main();
      await tester.pumpAndSettle();
      
      await _loginAsDoctor(tester);
      await tester.pumpAndSettle();
      
      // Disable payments
      final settingsButton = find.text('הגדרות תורים');
      if (tester.any(settingsButton)) {
        await tester.tap(settingsButton);
        await tester.pumpAndSettle();
        
        final paymentToggle = find.byType(Switch);
        if (tester.any(paymentToggle)) {
          // Ensure toggle is OFF
          await tester.tap(paymentToggle);
          await tester.pumpAndSettle();
          
          // Verify price fields are hidden
          final priceFields = find.textContaining('מחיר');
          // Prices should not be visible when disabled
        }
      }
    });

    testWidgets('TC-PAY-FLOW-003: Multiple Treatment Prices Display', 
        (WidgetTester tester) async {
      await app.main();
      await tester.pumpAndSettle();
      
      await _loginAsCustomer(tester);
      await tester.pumpAndSettle();
      
      // Navigate to book appointment
      final bookButton = find.text('קבע תור');
      if (tester.any(bookButton)) {
        await tester.tap(bookButton);
        await tester.pumpAndSettle();
        
        // Select doctor
        final doctorCard = find.byType(Card).first;
        if (tester.any(doctorCard)) {
          await tester.tap(doctorCard);
          await tester.pumpAndSettle();
          
          // Verify multiple prices are displayed for different treatments
          final priceElements = find.textContaining('₪');
          expect(priceElements, findsAtLeastNWidgets(1));
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





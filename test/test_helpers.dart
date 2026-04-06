import 'dart:ui' show Size;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medical_appointment_system/core/localization/app_localizations.dart';
import 'package:medical_appointment_system/presentation/pages/login_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Pumps [LoginPage] with English Material localizations (matches [LanguageService]
/// default in tests) and a wide surface so the desktop (two-column) layout is used.
Future<void> pumpLoginPageForTest(WidgetTester tester) async {
  SharedPreferences.setMockInitialValues({});
  await tester.binding.setSurfaceSize(const Size(1200, 900));
  await tester.pumpWidget(
    MaterialApp(
      locale: const Locale('en', 'US'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const LoginPage(),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> resetTestSurface(WidgetTester tester) async {
  await tester.binding.setSurfaceSize(null);
}

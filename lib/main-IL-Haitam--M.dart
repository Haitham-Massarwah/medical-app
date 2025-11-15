import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/localization/app_localizations.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/app_constants.dart';
import 'presentation/pages/splash_page.dart';
import 'presentation/pages/medical_home_page.dart';
import 'presentation/pages/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  runApp(const MedicalAppointmentApp());
}

class MedicalAppointmentApp extends StatelessWidget {
  const MedicalAppointmentApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Medical Appointment System',
      debugShowCheckedModeBanner: false,
      
      // Localization
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppConstants.supportedLocales,
      locale: const Locale('he'), // Default to Hebrew
      
      // Theme
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      
      // RTL Support
      builder: (context, child) {
        return Directionality(
          textDirection: _getTextDirection(context),
          child: child!,
        );
      },
      
      // Routes
      home: const SplashPage(),
      routes: _getRoutes(),
    );
  }
  
  TextDirection _getTextDirection(BuildContext context) {
    final locale = Localizations.localeOf(context);
    return locale.languageCode == 'he' || locale.languageCode == 'ar'
        ? TextDirection.rtl
        : TextDirection.ltr;
  }
  
  Map<String, WidgetBuilder> _getRoutes() {
    return {
      '/splash': (context) => const SplashPage(),
      '/home': (context) => const MedicalHomePage(),
      '/login': (context) => const LoginPage(),
      '/register': (context) => const RegisterPage(),
      '/appointments': (context) => const AppointmentsPage(),
      '/doctors': (context) => const DoctorsPage(),
      '/patients': (context) => const PatientsPage(),
      '/profile': (context) => const ProfilePage(),
      '/settings': (context) => const SettingsPage(),
    };
  }
}
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

class LanguageService {
  static const String _languageKey = 'selected_language';
  static const String _localeKey = 'selected_locale';
  
  // Supported languages
  static const Map<String, Locale> supportedLanguages = {
    'עברית': Locale('he', 'IL'),
    'العربية': Locale('ar', 'SA'),
    'English': Locale('en', 'US'),
  };
  
  // Get current language
  static Future<String> getCurrentLanguage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_languageKey) ?? 'עברית';
    } catch (e) {
      return 'עברית';
    }
  }
  
  // Set language
  static Future<void> setLanguage(String language) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_languageKey, language);
      
      // Also save locale
      final locale = supportedLanguages[language];
      if (locale != null) {
        await prefs.setString(_localeKey, '${locale.languageCode}_${locale.countryCode}');
      }
    } catch (e) {
      print('Error saving language: $e');
    }
  }
  
  // Get current locale
  static Future<Locale> getCurrentLocale() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final localeString = prefs.getString(_localeKey);
      
      if (localeString != null) {
        final parts = localeString.split('_');
        if (parts.length == 2) {
          return Locale(parts[0], parts[1]);
        }
      }
      
      return supportedLanguages['עברית']!;
    } catch (e) {
      return supportedLanguages['עברית']!;
    }
  }
  
  // Get text direction based on language
  static TextDirection getTextDirection(String language) {
    switch (language) {
      case 'עברית':
      case 'العربية':
        return TextDirection.rtl;
      case 'English':
      default:
        return TextDirection.ltr;
    }
  }
  
  // Get localized text
  static String getLocalizedText(String language, Map<String, String> translations) {
    return translations[language] ?? translations['עברית'] ?? '';
  }
  
  // Common translations
  static Map<String, Map<String, String>> getCommonTranslations() {
    return {
      'login': {
        'עברית': 'התחברות',
        'العربية': 'تسجيل الدخول',
        'English': 'Login',
      },
      'register': {
        'עברית': 'הרשמה',
        'العربية': 'التسجيل',
        'English': 'Register',
      },
      'doctors': {
        'עברית': 'רופאים',
        'العربية': 'الأطباء',
        'English': 'Doctors',
      },
      'appointments': {
        'עברית': 'תורים',
        'العربية': 'المواعيد',
        'English': 'Appointments',
      },
      'settings': {
        'עברית': 'הגדרות',
        'العربية': 'الإعدادات',
        'English': 'Settings',
      },
      'profile': {
        'עברית': 'פרופיל',
        'العربية': 'الملف الشخصي',
        'English': 'Profile',
      },
      'logout': {
        'עברית': 'התנתק',
        'العربية': 'تسجيل الخروج',
        'English': 'Logout',
      },
    };
  }
}









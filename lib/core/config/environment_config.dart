import 'package:flutter/foundation.dart';

/// Environment Configuration
/// Manages different environments: development, test, staging, production
class EnvironmentConfig {
  // Environment types
  static bool get isDevelopment => kDebugMode;
  static bool get isTest => const bool.fromEnvironment('dart.vm.product') == false && kDebugMode;
  static bool get isStaging => const String.fromEnvironment('ENV') == 'staging';
  static bool get isProduction => kReleaseMode && !isStaging;

  // Get current environment name
  static String get currentEnvironment {
    if (isDevelopment) return 'development';
    if (isTest) return 'test';
    if (isStaging) return 'staging';
    if (isProduction) return 'production';
    return 'unknown';
  }

  // Developer email for each environment
  static Map<String, String> get developerEmails => {
    'development': 'haitham.massarwah@medical-appointments.com',
    'test': 'haitham.massarwah@medical-appointments.com',
    'staging': 'haitham.massarwah@medical-appointments.com',
    'production': 'haitham.massarwah@medical-appointments.com',
  };

  /// Get developer email for current environment
  static String get developerEmail => developerEmails[currentEnvironment] ?? 'haitham.massarwah@medical-appointments.com';

  /// Check if email is developer email for current environment
  static bool isDeveloperEmail(String email) {
    final envEmail = developerEmail.toLowerCase();
    final userEmail = email.toLowerCase();
    
    // Exact match
    if (userEmail == envEmail) return true;
    
    // Domain match for flexibility
    final envDomain = envEmail.split('@')[1];
    final userDomain = userEmail.split('@')[1];
    
    return userDomain == envDomain;
  }

  /// Get role for email in current environment
  static String? getRoleForEmail(String email) {
    if (isDeveloperEmail(email)) {
      return 'developer';
    }
    return null;
  }

  /// Check if developer mode is enabled
  static bool get isDeveloperModeEnabled {
    // In production, disable developer mode
    if (isProduction) return false;
    
    // In development, test, staging - always enabled
    return true;
  }

  /// Log environment info
  static void logEnvironmentInfo() {
    if (kDebugMode) {
      print('🔧 Environment: $currentEnvironment');
      print('🔧 Developer Mode: $isDeveloperModeEnabled');
      print('🔧 Developer Email: $developerEmail');
    }
  }
}







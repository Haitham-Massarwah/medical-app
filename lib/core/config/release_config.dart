/// Release Configuration for Production
/// This file controls what features are visible in release builds
class ReleaseConfig {
  /// Whether to show admin features in the UI
  /// Set to true for release - admin has full control
  static const bool showAdminFeatures = true;
  
  /// Whether to show debug information
  static const bool showDebugInfo = false;
  
  /// Whether to use automatic role detection from database
  /// Set to true for production - no manual role selection
  static const bool enableAutoRoleDetection = true;
  
  /// Admin account (replaces developer in release mode)
  static const String adminEmail = 'haitham.massarwah@medical-appointments.com';
  static const String adminPassword = 'Haitham@0412';
  
  /// Release version info
  static const String version = '1.0.0';
  static const String buildNumber = '1';
  static const String releaseDate = '2025-11-01';
}


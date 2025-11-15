import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';

class AppConfig {
  static late SharedPreferences _prefs;
  static late Logger _logger;
  static String? _cachedEnvironment;
  
  // Environment
  static bool get isDevelopment => kDebugMode;
  static bool get isProduction => kReleaseMode;
  static bool get isTest => kDebugMode && const bool.fromEnvironment('dart.vm.product') == false;
  
  // API Configuration
  // Development: Use local backend (http://localhost:3000)
  // Production: Use production server (http://66.29.133.192:3000)
  static String get baseUrl {
    // Check for environment variable override (useful for testing)
    const envBaseUrl = String.fromEnvironment('API_BASE_URL', defaultValue: '');
    if (envBaseUrl.isNotEmpty) {
      return envBaseUrl;
    }
    
    // Check ENVIRONMENT.txt file or SharedPreferences
    final env = _getEnvironment();
    
    if (env == 'Production') {
      return 'http://66.29.133.192:3000/api/v1';
    }
    
    // Default to Development
    return 'http://localhost:3000/api/v1';
  }
  
  // Get environment from ENVIRONMENT.txt file or SharedPreferences
  static String _getEnvironment() {
    // Return cached value if available
    if (_cachedEnvironment != null) {
      return _cachedEnvironment!;
    }
    
    // Try to read from SharedPreferences first (faster, works on all platforms)
    final prefsEnv = _prefs.getString('app_environment');
    if (prefsEnv != null && (prefsEnv == 'Production' || prefsEnv == 'Development')) {
      _cachedEnvironment = prefsEnv;
      return prefsEnv;
    }
    
    // Try to read from ENVIRONMENT.txt file (desktop only - synchronous)
    if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
      try {
        // Try multiple locations for ENVIRONMENT.txt
        final possiblePaths = [
          'ENVIRONMENT.txt', // Current directory
          Directory.current.path + Platform.pathSeparator + 'ENVIRONMENT.txt',
        ];
        
        for (final filePath in possiblePaths) {
          final envFile = File(filePath);
          if (envFile.existsSync()) {
            final content = envFile.readAsStringSync().trim();
            if (content == 'Production' || content == 'Development') {
              _cachedEnvironment = content;
              // Cache in SharedPreferences for faster access
              _prefs.setString('app_environment', content);
              return content;
            }
          }
        }
      } catch (e) {
        _logger.w('Could not read ENVIRONMENT.txt: $e');
      }
    }
    
    // Default to Development
    _cachedEnvironment = 'Development';
    return 'Development';
  }
  
  // Reload environment from file (call this after changing ENVIRONMENT.txt)
  static Future<void> reloadEnvironment() async {
    _cachedEnvironment = null;
    
    if (!kIsWeb) {
      try {
        // Try multiple locations for ENVIRONMENT.txt
        final possiblePaths = [
          'ENVIRONMENT.txt', // Current directory (works for desktop)
          Directory.current.path + Platform.pathSeparator + 'ENVIRONMENT.txt', // Desktop
        ];
        
        // For mobile, try documents directory
        if (Platform.isAndroid || Platform.isIOS) {
          final docsDir = await getApplicationDocumentsDirectory();
          possiblePaths.add(docsDir.path + Platform.pathSeparator + 'ENVIRONMENT.txt');
        }
        
        for (final filePath in possiblePaths) {
          final envFile = File(filePath);
          if (envFile.existsSync()) {
            final content = envFile.readAsStringSync().trim();
            if (content == 'Production' || content == 'Development') {
              _cachedEnvironment = content;
              await _prefs.setString('app_environment', content);
              _logger.i('Environment reloaded: $content');
              _logger.i('Base URL: $baseUrl');
              return;
            }
          }
        }
      } catch (e) {
        _logger.w('Could not reload ENVIRONMENT.txt: $e');
      }
    }
    
    // Fallback to SharedPreferences
    final prefsEnv = _prefs.getString('app_environment');
    if (prefsEnv != null && (prefsEnv == 'Production' || prefsEnv == 'Development')) {
      _cachedEnvironment = prefsEnv;
    } else {
      _cachedEnvironment = 'Development';
    }
  }
  
  // Logging
  static Logger get logger => _logger;
  
  // Cache Configuration
  static const Duration cacheExpiration = Duration(hours: 1);
  static const Duration userCacheExpiration = Duration(days: 7);
  
  // Security Configuration
  static const bool enableBiometricAuth = true;
  static const bool enableTwoFactorAuth = true;
  static const int maxLoginAttempts = 5;
  static const Duration lockoutDuration = Duration(minutes: 15);
  
  // Payment Configuration
  static const bool enablePayments = true;
  static const bool enableDeposits = true;
  static const String defaultCurrency = 'ILS';
  
  // Notification Configuration
  static const bool enablePushNotifications = true;
  static const bool enableSMSNotifications = true;
  static const bool enableWhatsAppNotifications = true;
  static const bool enableEmailNotifications = true;
  
  // Telehealth Configuration
  static const bool enableTelehealth = true;
  static const String videoProvider = 'agora'; // agora, zoom, custom
  
  // Calendar Integration
  static const bool enableGoogleCalendar = true;
  static const bool enableOutlookCalendar = true;
  
  // Analytics Configuration
  static const bool enableAnalytics = true;
  static const bool enableCrashReporting = true;
  
  // Accessibility Configuration
  static const bool enableAccessibilityFeatures = true;
  static const double minContrastRatio = 4.5; // WCAG 2.2 AA
  
  // Performance Configuration
  static const Duration apiTimeout = Duration(seconds: 30);
  static const int maxConcurrentRequests = 10;
  static const Duration retryDelay = Duration(seconds: 2);
  static const int maxRetryAttempts = 3;
  
  // Business Rules Configuration
  static const Duration defaultAppointmentDuration = Duration(minutes: 30);
  static const Duration minAdvanceBookingTime = Duration(hours: 2);
  static const Duration maxAdvanceBookingTime = Duration(days: 90);
  static const Duration defaultCancellationWindow = Duration(hours: 24);
  static const Duration reminderTimeBeforeAppointment = Duration(hours: 24);
  static const Duration confirmationTimeBeforeAppointment = Duration(hours: 2);
  
  // Multi-tenant Configuration
  static const bool enableMultiTenant = true;
  static const String defaultTenantId = 'default';
  
  // Compliance Configuration
  static const bool enableGDPRCompliance = true;
  static const bool enableHIPAACompliance = true;
  static const bool enableIsraeliPrivacyLaw = true;
  static const bool enablePCICompliance = true;
  
  // Initialize the app configuration
  static Future<void> initialize() async {
    try {
      // Initialize SharedPreferences
      _prefs = await SharedPreferences.getInstance();
      
      // Initialize Logger
      _logger = Logger(
        printer: PrettyPrinter(
          methodCount: 2,
          errorMethodCount: 8,
          lineLength: 120,
          colors: true,
          printEmojis: true,
          printTime: true,
        ),
      );
      
      // Load environment from file
      _getEnvironment();
      
      // Log initialization
      _logger.i('App configuration initialized successfully');
      _logger.i('Environment Mode: ${isDevelopment ? 'Development' : isTest ? 'Test' : 'Production'}');
      _logger.i('API Environment: ${_cachedEnvironment ?? 'Development'}');
      _logger.i('Base URL: $baseUrl');
      
    } catch (e) {
      _logger.e('Failed to initialize app configuration: $e');
      rethrow;
    }
  }
  
  // Get stored value
  static T? getStoredValue<T>(String key) {
    try {
      if (T == String) {
        return _prefs.getString(key) as T?;
      } else if (T == int) {
        return _prefs.getInt(key) as T?;
      } else if (T == bool) {
        return _prefs.getBool(key) as T?;
      } else if (T == double) {
        return _prefs.getDouble(key) as T?;
      } else if (T == List<String>) {
        return _prefs.getStringList(key) as T?;
      }
      return null;
    } catch (e) {
      _logger.e('Error getting stored value for key $key: $e');
      return null;
    }
  }
  
  // Store value
  static Future<bool> storeValue<T>(String key, T value) async {
    try {
      if (value is String) {
        return await _prefs.setString(key, value);
      } else if (value is int) {
        return await _prefs.setInt(key, value);
      } else if (value is bool) {
        return await _prefs.setBool(key, value);
      } else if (value is double) {
        return await _prefs.setDouble(key, value);
      } else if (value is List<String>) {
        return await _prefs.setStringList(key, value);
      }
      return false;
    } catch (e) {
      _logger.e('Error storing value for key $key: $e');
      return false;
    }
  }
  
  // Clear stored value
  static Future<bool> clearStoredValue(String key) async {
    try {
      return await _prefs.remove(key);
    } catch (e) {
      _logger.e('Error clearing stored value for key $key: $e');
      return false;
    }
  }
  
  // Clear all stored values
  static Future<bool> clearAllStoredValues() async {
    try {
      return await _prefs.clear();
    } catch (e) {
      _logger.e('Error clearing all stored values: $e');
      return false;
    }
  }
}

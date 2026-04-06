import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logger/logger.dart';
import 'environment_io.dart';

class AppConfig {
  static late SharedPreferences _prefs;
  static late Logger _logger;
  static String? _cachedEnvironment;
  
  // Environment
  static bool get isDevelopment => kDebugMode;
  static bool get isProduction => kReleaseMode;
  static bool get isTest => kDebugMode && const bool.fromEnvironment('dart.vm.product') == false;
  
  // API Configuration
  static String get baseUrl {
    // Environment variable overrides
    const baseUrl = String.fromEnvironment('BASE_URL', defaultValue: '');
    const baseUrlProd =
        String.fromEnvironment('BASE_URL_PRODUCTION', defaultValue: '');
    if (baseUrl.isNotEmpty) {
      return baseUrl;
    }
    
    // PRIORITY: When running web in debug mode, ALWAYS use local backend
    if (kIsWeb && kDebugMode) {
      return 'http://localhost:3000/api/v1';
    }
    
    if (isProduction && baseUrlProd.isNotEmpty) {
      return baseUrlProd;
    }
    if (kIsWeb && baseUrlProd.isNotEmpty) {
      return baseUrlProd;
    }

    // Check ENVIRONMENT.txt file or SharedPreferences
    final env = _getEnvironment();

    if (env == 'Production') {
      return 'https://api.medical-appointments.com/api/v1';
    }

    // Default to Development
    if (kIsWeb) {
      return 'https://api.medical-appointments.com/api/v1';
    }
    return 'http://localhost:3000/api/v1';
  }
  
  // Get environment from ENVIRONMENT.txt file or SharedPreferences
  static String _getEnvironment() {
    // Return cached value if available
    if (_cachedEnvironment != null) {
      return _cachedEnvironment!;
    }
    
    // Try to read from SharedPreferences first (faster, works on all platforms)
    // Only if _prefs is initialized
    try {
      final prefsEnv = _prefs.getString('app_environment');
      if (prefsEnv != null && (prefsEnv == 'Production' || prefsEnv == 'Development')) {
        _cachedEnvironment = prefsEnv;
        return prefsEnv;
      }
    } catch (e) {
      // _prefs not initialized yet, continue to file reading
    }
    
    // Try to read from ENVIRONMENT.txt file (desktop only - synchronous)
    if (!kIsWeb && isDesktop) {
      try {
        final content = readEnvironmentFileSync();
        if (content != null) {
          _cachedEnvironment = content;
          // Cache in SharedPreferences for faster access (only if initialized)
          try {
            _prefs.setString('app_environment', content);
          } catch (e) {
            // _prefs not initialized yet, that's okay
          }
          return content;
        }
      } catch (e) {
        // Error reading file, continue to default
      }
    }
    
    // Default based on platform
    if (kIsWeb) {
      _cachedEnvironment = 'Production';
      return _cachedEnvironment!;
    }
    _cachedEnvironment = 'Development';
    return 'Development';
  }
  
  // Reload environment from file (call this after changing ENVIRONMENT.txt)
  static Future<void> reloadEnvironment() async {
    _cachedEnvironment = null;
    
    if (!kIsWeb) {
      try {
        final content = await readEnvironmentFile();
        if (content != null) {
          _cachedEnvironment = content;
          try {
            await _prefs.setString('app_environment', content);
          } catch (e) {
            // _prefs not initialized yet, that's okay
          }
          try {
            _logger.i('Environment reloaded: $content');
            _logger.i('Base URL: $baseUrl');
          } catch (e) {
            // Logger not initialized yet
          }
          return;
        }
      } catch (e) {
        try {
          _logger.w('Could not reload ENVIRONMENT.txt: $e');
        } catch (e) {
          // Logger not initialized
        }
      }
    }
    
    // Fallback to SharedPreferences (only if initialized)
    try {
      final prefsEnv = _prefs.getString('app_environment');
      if (prefsEnv != null && (prefsEnv == 'Production' || prefsEnv == 'Development')) {
        _cachedEnvironment = prefsEnv;
      } else {
        _cachedEnvironment = 'Development';
      }
    } catch (e) {
      // _prefs not initialized, use default
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
      try {
        _logger.e('Error getting stored value for key $key: $e');
      } catch (e) {
        // Logger not initialized
      }
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
      try {
        _logger.e('Error storing value for key $key: $e');
      } catch (e) {
        // Logger not initialized
      }
      return false;
    }
  }
  
  // Clear stored value
  static Future<bool> clearStoredValue(String key) async {
    try {
      return await _prefs.remove(key);
    } catch (e) {
      try {
        _logger.e('Error clearing stored value for key $key: $e');
      } catch (e) {
        // Logger not initialized
      }
      return false;
    }
  }
  
  // Clear all stored values
  static Future<bool> clearAllStoredValues() async {
    try {
      return await _prefs.clear();
    } catch (e) {
      try {
        _logger.e('Error clearing all stored values: $e');
      } catch (e) {
        // Logger not initialized
      }
      return false;
    }
  }
}

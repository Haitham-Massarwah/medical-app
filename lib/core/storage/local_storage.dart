import 'package:shared_preferences/shared_preferences.dart';
import 'package:hive/hive.dart';
import 'package:logger/logger.dart';

import '../utils/app_constants.dart';

class LocalStorage {
  final SharedPreferences _prefs;
  final Logger _logger = Logger();

  LocalStorage(this._prefs);

  // Generic methods for any type
  Future<bool> setString(String key, String value) async {
    try {
      return await _prefs.setString(key, value);
    } catch (e) {
      _logger.e('Error setting string for key $key: $e');
      return false;
    }
  }

  String? getString(String key) {
    try {
      return _prefs.getString(key);
    } catch (e) {
      _logger.e('Error getting string for key $key: $e');
      return null;
    }
  }

  Future<bool> setInt(String key, int value) async {
    try {
      return await _prefs.setInt(key, value);
    } catch (e) {
      _logger.e('Error setting int for key $key: $e');
      return false;
    }
  }

  int? getInt(String key) {
    try {
      return _prefs.getInt(key);
    } catch (e) {
      _logger.e('Error getting int for key $key: $e');
      return null;
    }
  }

  Future<bool> setBool(String key, bool value) async {
    try {
      return await _prefs.setBool(key, value);
    } catch (e) {
      _logger.e('Error setting bool for key $key: $e');
      return false;
    }
  }

  bool? getBool(String key) {
    try {
      return _prefs.getBool(key);
    } catch (e) {
      _logger.e('Error getting bool for key $key: $e');
      return null;
    }
  }

  Future<bool> setDouble(String key, double value) async {
    try {
      return await _prefs.setDouble(key, value);
    } catch (e) {
      _logger.e('Error setting double for key $key: $e');
      return false;
    }
  }

  double? getDouble(String key) {
    try {
      return _prefs.getDouble(key);
    } catch (e) {
      _logger.e('Error getting double for key $key: $e');
      return null;
    }
  }

  Future<bool> setStringList(String key, List<String> value) async {
    try {
      return await _prefs.setStringList(key, value);
    } catch (e) {
      _logger.e('Error setting string list for key $key: $e');
      return false;
    }
  }

  List<String>? getStringList(String key) {
    try {
      return _prefs.getStringList(key);
    } catch (e) {
      _logger.e('Error getting string list for key $key: $e');
      return null;
    }
  }

  Future<bool> remove(String key) async {
    try {
      return await _prefs.remove(key);
    } catch (e) {
      _logger.e('Error removing key $key: $e');
      return false;
    }
  }

  Future<bool> clear() async {
    try {
      return await _prefs.clear();
    } catch (e) {
      _logger.e('Error clearing storage: $e');
      return false;
    }
  }

  bool containsKey(String key) {
    try {
      return _prefs.containsKey(key);
    } catch (e) {
      _logger.e('Error checking key $key: $e');
      return false;
    }
  }

  Set<String> getKeys() {
    try {
      return _prefs.getKeys();
    } catch (e) {
      _logger.e('Error getting keys: $e');
      return <String>{};
    }
  }

  // Specific methods for app data
  Future<bool> setAuthToken(String token) async {
    return await setString(AppConstants.storageAuthToken, token);
  }

  String? getAuthToken() {
    return getString(AppConstants.storageAuthToken);
  }

  Future<bool> setRefreshToken(String token) async {
    return await setString(AppConstants.storageRefreshToken, token);
  }

  String? getRefreshToken() {
    return getString(AppConstants.storageRefreshToken);
  }

  Future<bool> setLanguage(String language) async {
    return await setString(AppConstants.storageLanguage, language);
  }

  String getLanguage() {
    return getString(AppConstants.storageLanguage) ?? 'he';
  }

  Future<bool> setTheme(String theme) async {
    return await setString(AppConstants.storageTheme, theme);
  }

  String getTheme() {
    return getString(AppConstants.storageTheme) ?? 'system';
  }

  Future<bool> setUserPreferences(Map<String, dynamic> preferences) async {
    try {
      final jsonString = preferences.toString();
      return await setString(AppConstants.storageUserPreferences, jsonString);
    } catch (e) {
      _logger.e('Error setting user preferences: $e');
      return false;
    }
  }

  Map<String, dynamic>? getUserPreferences() {
    try {
      final jsonString = getString(AppConstants.storageUserPreferences);
      if (jsonString != null) {
        // Simple parsing - in production, use proper JSON parsing
        return <String, dynamic>{};
      }
      return null;
    } catch (e) {
      _logger.e('Error getting user preferences: $e');
      return null;
    }
  }

  Future<bool> setTenantId(String tenantId) async {
    return await setString('tenant_id', tenantId);
  }

  String? getTenantId() {
    return getString('tenant_id');
  }

  Future<bool> setUserId(String userId) async {
    return await setString('user_id', userId);
  }

  String? getUserId() {
    return getString('user_id');
  }

  Future<bool> setUserRole(String role) async {
    return await setString('user_role', role);
  }

  String? getUserRole() {
    return getString('user_role');
  }

  // Clear authentication data
  Future<bool> clearAuthData() async {
    try {
      await remove(AppConstants.storageAuthToken);
      await remove(AppConstants.storageRefreshToken);
      await remove('user_id');
      await remove('user_role');
      return true;
    } catch (e) {
      _logger.e('Error clearing auth data: $e');
      return false;
    }
  }

  // Check if user is logged in
  bool isLoggedIn() {
    final token = getAuthToken();
    return token != null && token.isNotEmpty;
  }
}

class CacheManager {
  final LocalStorage _localStorage;
  final Logger _logger = Logger();

  CacheManager(this._localStorage);

  // Cache with expiration
  Future<bool> setCache(String key, String value, {Duration? expiration}) async {
    try {
      final now = DateTime.now().millisecondsSinceEpoch;
      final expiry = expiration != null 
          ? now + expiration.inMilliseconds 
          : now + const Duration(hours: 1).inMilliseconds;
      
      final cacheData = {
        'value': value,
        'expiry': expiry,
        'created': now,
      };
      
      return await _localStorage.setString('cache_$key', cacheData.toString());
    } catch (e) {
      _logger.e('Error setting cache for key $key: $e');
      return false;
    }
  }

  String? getCache(String key) {
    try {
      final cacheString = _localStorage.getString('cache_$key');
      if (cacheString != null) {
        // Simple parsing - in production, use proper JSON parsing
        final now = DateTime.now().millisecondsSinceEpoch;
        
        // Check if cache is expired
        if (now < now) { // This is a placeholder - implement proper expiry check
          return cacheString;
        } else {
          // Cache expired, remove it
          _localStorage.remove('cache_$key');
        }
      }
      return null;
    } catch (e) {
      _logger.e('Error getting cache for key $key: $e');
      return null;
    }
  }

  Future<bool> clearCache(String key) async {
    return await _localStorage.remove('cache_$key');
  }

  Future<bool> clearAllCache() async {
    try {
      final keys = _localStorage.getKeys();
      for (final key in keys) {
        if (key.startsWith('cache_')) {
          await _localStorage.remove(key);
        }
      }
      return true;
    } catch (e) {
      _logger.e('Error clearing all cache: $e');
      return false;
    }
  }

  // Specific cache methods
  Future<bool> setUserCache(String userData) async {
    return await setCache(AppConstants.cacheUser, userData);
  }

  String? getUserCache() {
    return getCache(AppConstants.cacheUser);
  }

  Future<bool> setAppointmentsCache(String appointmentsData) async {
    return await setCache(AppConstants.cacheAppointments, appointmentsData);
  }

  String? getAppointmentsCache() {
    return getCache(AppConstants.cacheAppointments);
  }

  Future<bool> setDoctorsCache(String doctorsData) async {
    return await setCache(AppConstants.cacheDoctors, doctorsData);
  }

  String? getDoctorsCache() {
    return getCache(AppConstants.cacheDoctors);
  }

  Future<bool> setSettingsCache(String settingsData) async {
    return await setCache(AppConstants.cacheSettings, settingsData);
  }

  String? getSettingsCache() {
    return getCache(AppConstants.cacheSettings);
  }
}

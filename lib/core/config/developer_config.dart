import 'package:shared_preferences/shared_preferences.dart';

/// Developer Configuration
/// Manages authorized developer emails and role assignment
class DeveloperConfig {
  // Authorized developer emails
  static const List<String> _authorizedDeveloperEmails = [
    // Add your developer email here
    'haitham.massarwah@medical-appointments.com', // Developer email
  ];

  // Authorized developer email domains
  static const List<String> _authorizedDeveloperDomains = [
    'medical-appointments.com',
    'haitham-works.com',
  ];

  /// Check if email is authorized for developer access
  static bool isAuthorizedDeveloperEmail(String email) {
    // Check exact email match
    if (_authorizedDeveloperEmails.contains(email.toLowerCase())) {
      return true;
    }

    // Check domain match
    for (var domain in _authorizedDeveloperDomains) {
      if (email.toLowerCase().endsWith('@$domain')) {
        return true;
      }
    }

    return false;
  }

  /// Get developer role for email
  /// Returns 'developer' if authorized, null otherwise
  static String? getRoleForEmail(String email) {
    if (isAuthorizedDeveloperEmail(email)) {
      return 'developer';
    }
    return null;
  }

  /// Store developer email preference
  static Future<void> setDeveloperEmail(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('developer_email', email);
  }

  /// Get stored developer email
  static Future<String?> getDeveloperEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('developer_email');
  }

  /// Check if current user is developer
  static Future<bool> isCurrentUserDeveloper() async {
    final email = await getDeveloperEmail();
    if (email == null) return false;
    return isAuthorizedDeveloperEmail(email);
  }

  /// Auto-detect role from email
  static Future<String?> autoDetectRole(String email) async {
    // Check if email is in developer list
    final developerRole = getRoleForEmail(email);
    if (developerRole != null) {
      await setDeveloperEmail(email);
      return developerRole;
    }

    return null;
  }
}







/// Developer Credentials Configuration
/// This file contains the official developer email
/// Configure your email here to enable automatic developer mode

class DeveloperCredentials {
  // ⭐ CONFIGURE YOUR DEVELOPER EMAIL HERE ⭐
  // Replace 'YOUR_EMAIL@DOMAIN.COM' with your actual email address
  
  /// Official developer email
  /// This is the email that will automatically get developer role
  static const String developerEmail = 'haitham.massarwah@medical-appointments.com';
  
  /// Backup developer emails (if needed)
  static const List<String> backupDeveloperEmails = [
    // Add additional developer emails here if needed
  ];
  
  /// Check if email is the configured developer email
  static bool isDeveloperEmail(String email) {
    final normalizedEmail = email.toLowerCase().trim();
    return normalizedEmail == developerEmail.toLowerCase() ||
           backupDeveloperEmails.any((e) => normalizedEmail == e.toLowerCase());
  }
  
  /// Get role for email
  /// Returns 'developer' if email matches, null otherwise
  static String? getRoleForEmail(String email) {
    if (isDeveloperEmail(email)) {
      return 'developer';
    }
    return null;
  }
  
  /// Check if developer mode should be enabled
  static bool shouldEnableDeveloperMode(String email) {
    return isDeveloperEmail(email);
  }
}

/// INSTRUCTIONS:
/// 
/// 1. Replace 'DEVELOPER@MEDICAL-APPOINTMENTS.COM' with your actual email
/// 2. Add any backup emails to backupDeveloperEmails if needed
/// 3. Save the file
/// 4. Rebuild the app
/// 5. Login with your configured email - developer mode will activate automatically
///
/// Example:
/// static const String developerEmail = 'haitham.massarwah@medical-appointments.com';
///







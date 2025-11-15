import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'encryption_service.dart';

/// Enhanced authentication service with multi-factor authentication
class AuthenticationService {
  static final AuthenticationService _instance = AuthenticationService._internal();
  factory AuthenticationService() => _instance;
  AuthenticationService._internal();

  final LocalAuthentication _localAuth = LocalAuthentication();
  final EncryptionService _encryptionService = EncryptionService();
  
  String? _currentSessionToken;
  DateTime? _sessionExpiry;
  int _failedAttempts = 0;
  DateTime? _lastFailedAttempt;

  /// Initialize authentication service
  Future<void> initialize() async {
    await _encryptionService.initialize();
    await _loadSession();
  }

  /// Authenticate user with email and password
  Future<AuthResult> authenticateUser(String email, String password) async {
    try {
      // Check for brute force protection
      if (_isAccountLocked()) {
        return AuthResult(
          success: false,
          error: 'Account temporarily locked due to too many failed attempts',
          requiresTwoFactor: false,
        );
      }

      // Validate input
      if (!_isValidEmail(email) || password.length < 8) {
        _recordFailedAttempt();
        return AuthResult(
          success: false,
          error: 'Invalid email or password format',
          requiresTwoFactor: false,
        );
      }

      // Simulate user lookup and password verification
      final user = await _getUserByEmail(email);
      if (user == null) {
        _recordFailedAttempt();
        return AuthResult(
          success: false,
          error: 'Invalid credentials',
          requiresTwoFactor: false,
        );
      }

      // Verify password
      final isValidPassword = _encryptionService.verifyPassword(
        password,
        user['passwordHash'],
        user['salt'],
      );

      if (!isValidPassword) {
        _recordFailedAttempt();
        return AuthResult(
          success: false,
          error: 'Invalid credentials',
          requiresTwoFactor: false,
        );
      }

      // Reset failed attempts on successful login
      _resetFailedAttempts();

      // Check if 2FA is enabled
      final requiresTwoFactor = user['twoFactorEnabled'] == true;
      
      if (requiresTwoFactor) {
        return AuthResult(
          success: false,
          error: 'Two-factor authentication required',
          requiresTwoFactor: true,
          userId: user['id'],
        );
      }

      // Create session
      await _createSession(user);
      
      return AuthResult(
        success: true,
        error: null,
        requiresTwoFactor: false,
        userId: user['id'],
        userRole: user['role'],
      );

    } catch (e) {
      return AuthResult(
        success: false,
        error: 'Authentication failed: $e',
        requiresTwoFactor: false,
      );
    }
  }

  /// Authenticate with biometrics
  Future<AuthResult> authenticateWithBiometrics() async {
    try {
      // Check if biometrics are available
      final isAvailable = await _localAuth.canCheckBiometrics;
      if (!isAvailable) {
        return AuthResult(
          success: false,
          error: 'Biometric authentication not available',
          requiresTwoFactor: false,
        );
      }

      // Authenticate with biometrics
      final isAuthenticated = await _localAuth.authenticate(
        localizedReason: 'Authenticate to access your medical records',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );

      if (!isAuthenticated) {
        return AuthResult(
          success: false,
          error: 'Biometric authentication failed',
          requiresTwoFactor: false,
        );
      }

      // Load user from secure storage
      final user = await _getCurrentUser();
      if (user == null) {
        return AuthResult(
          success: false,
          error: 'No user session found',
          requiresTwoFactor: false,
        );
      }

      return AuthResult(
        success: true,
        error: null,
        requiresTwoFactor: false,
        userId: user['id'],
        userRole: user['role'],
      );

    } catch (e) {
      return AuthResult(
        success: false,
        error: 'Biometric authentication failed: $e',
        requiresTwoFactor: false,
      );
    }
  }

  /// Verify two-factor authentication code
  Future<AuthResult> verifyTwoFactorCode(String userId, String code) async {
    try {
      // In production, this would verify against a TOTP service
      // For now, we'll simulate verification
      final isValidCode = await _verifyTOTPCode(userId, code);
      
      if (!isValidCode) {
        return AuthResult(
          success: false,
          error: 'Invalid verification code',
          requiresTwoFactor: false,
        );
      }

      // Load user and create session
      final user = await _getUserById(userId);
      if (user == null) {
        return AuthResult(
          success: false,
          error: 'User not found',
          requiresTwoFactor: false,
        );
      }

      await _createSession(user);
      
      return AuthResult(
        success: true,
        error: null,
        requiresTwoFactor: false,
        userId: user['id'],
        userRole: user['role'],
      );

    } catch (e) {
      return AuthResult(
        success: false,
        error: 'Two-factor verification failed: $e',
        requiresTwoFactor: false,
      );
    }
  }

  /// Check if user is currently authenticated
  bool isAuthenticated() {
    if (_currentSessionToken == null || _sessionExpiry == null) {
      return false;
    }
    return DateTime.now().isBefore(_sessionExpiry!);
  }

  /// Get current user information
  Future<Map<String, dynamic>?> getCurrentUser() async {
    if (!isAuthenticated()) {
      return null;
    }
    return await _getCurrentUser();
  }

  /// Logout user and clear session
  Future<void> logout() async {
    _currentSessionToken = null;
    _sessionExpiry = null;
    await _clearSession();
  }

  /// Change user password
  Future<bool> changePassword(String currentPassword, String newPassword) async {
    try {
      final user = await getCurrentUser();
      if (user == null) return false;

      // Verify current password
      final isValidCurrent = _encryptionService.verifyPassword(
        currentPassword,
        user['passwordHash'],
        user['salt'],
      );

      if (!isValidCurrent) return false;

      // Hash new password
      final newSalt = _encryptionService.generateSalt();
      final newPasswordHash = _encryptionService.hashPassword(newPassword, newSalt);

      // Update password in database
      await _updateUserPassword(user['id'], newPasswordHash, newSalt);
      
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Enable two-factor authentication
  Future<TwoFactorSetupResult> enableTwoFactor(String userId) async {
    try {
      // Generate TOTP secret
      final secret = _encryptionService.generateSecureToken();
      
      // Generate QR code data
      final qrCodeData = 'otpauth://totp/MedicalApp:$userId?secret=$secret&issuer=MedicalApp';
      
      // Generate backup codes
      final backupCodes = List.generate(10, (index) => _encryptionService.generateSecureToken());
      
      // Store secret securely
      await _storeTOTPSecret(userId, secret);
      
      return TwoFactorSetupResult(
        success: true,
        qrCodeData: qrCodeData,
        secret: secret,
        backupCodes: backupCodes,
      );
    } catch (e) {
      return TwoFactorSetupResult(
        success: false,
        error: 'Failed to enable two-factor authentication: $e',
      );
    }
  }

  // Private helper methods

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  bool _isAccountLocked() {
    if (_lastFailedAttempt == null) return false;
    
    final lockoutDuration = Duration(minutes: 15 * (_failedAttempts ~/ 5 + 1));
    final lockoutExpiry = _lastFailedAttempt!.add(lockoutDuration);
    
    return DateTime.now().isBefore(lockoutExpiry);
  }

  void _recordFailedAttempt() {
    _failedAttempts++;
    _lastFailedAttempt = DateTime.now();
  }

  void _resetFailedAttempts() {
    _failedAttempts = 0;
    _lastFailedAttempt = null;
  }

  Future<Map<String, dynamic>?> _getUserByEmail(String email) async {
    // In production, this would query the database
    // For now, return mock data
    return {
      'id': 'user_123',
      'email': email,
      'passwordHash': 'hashed_password',
      'salt': 'salt_value',
      'role': 'patient',
      'twoFactorEnabled': false,
    };
  }

  Future<Map<String, dynamic>?> _getUserById(String userId) async {
    // In production, this would query the database
    return {
      'id': userId,
      'email': 'user@example.com',
      'role': 'patient',
    };
  }

  Future<Map<String, dynamic>?> _getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString('current_user');
    if (userData == null) return null;
    
    return jsonDecode(userData) as Map<String, dynamic>;
  }

  Future<void> _createSession(Map<String, dynamic> user) async {
    _currentSessionToken = _encryptionService.generateSecureToken();
    _sessionExpiry = DateTime.now().add(const Duration(hours: 24));
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('session_token', _currentSessionToken!);
    await prefs.setString('session_expiry', _sessionExpiry!.toIso8601String());
    await prefs.setString('current_user', jsonEncode(user));
  }

  Future<void> _loadSession() async {
    final prefs = await SharedPreferences.getInstance();
    _currentSessionToken = prefs.getString('session_token');
    final expiryString = prefs.getString('session_expiry');
    
    if (expiryString != null) {
      _sessionExpiry = DateTime.parse(expiryString);
    }
  }

  Future<void> _clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('session_token');
    await prefs.remove('session_expiry');
    await prefs.remove('current_user');
  }

  Future<bool> _verifyTOTPCode(String userId, String code) async {
    // In production, this would verify TOTP code
    // For now, accept any 6-digit code
    return RegExp(r'^\d{6}$').hasMatch(code);
  }

  Future<void> _updateUserPassword(String userId, String passwordHash, String salt) async {
    // In production, this would update the database
  }

  Future<void> _storeTOTPSecret(String userId, String secret) async {
    // In production, this would store securely
  }
}

/// Authentication result model
class AuthResult {
  final bool success;
  final String? error;
  final bool requiresTwoFactor;
  final String? userId;
  final String? userRole;

  AuthResult({
    required this.success,
    this.error,
    required this.requiresTwoFactor,
    this.userId,
    this.userRole,
  });
}

/// Two-factor authentication setup result
class TwoFactorSetupResult {
  final bool success;
  final String? error;
  final String? qrCodeData;
  final String? secret;
  final List<String>? backupCodes;

  TwoFactorSetupResult({
    required this.success,
    this.error,
    this.qrCodeData,
    this.secret,
    this.backupCodes,
  });
}








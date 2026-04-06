import '../core/network/http_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final HttpClient _httpClient = HttpClient();
  
  // Login
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final normalizedEmail = email.trim().toLowerCase();
      final response = await _httpClient.post('/auth/login', {
        'email': normalizedEmail,
        'password': password,
      });
      
      // Store token - CRITICAL: Must store before navigation
      final accessToken = _extractAccessToken(response);
      if (accessToken != null && accessToken.isNotEmpty) {
        print('[AUTH] Token extracted, storing...');
        
        // Store in HttpClient (which uses SharedPreferences)
        await _httpClient.setAuthToken(accessToken);
        
        // CRITICAL: Also store directly in SharedPreferences for Flutter Web
        // Flutter Web SharedPreferences uses localStorage with 'flutter.' prefix
        try {
          final prefs = await SharedPreferences.getInstance();
          final saved = await prefs.setString('auth_token', accessToken);
          print('[AUTH] Direct SharedPreferences save result: $saved');
          
          // Immediate verification
          final verify = prefs.getString('auth_token');
          if (verify == accessToken) {
            print('[AUTH] Token verified in SharedPreferences immediately');
          } else {
            print('[AUTH] WARNING: Token verification failed immediately after save!');
            print('[AUTH] Expected: ${accessToken.substring(0, 30)}...');
            print('[AUTH] Got: ${verify?.substring(0, 30) ?? 'null'}...');
          }
        } catch (e) {
          print('[AUTH] ERROR: SharedPreferences storage failed: $e');
        }
        
        // Verify token was stored in HttpClient
        final storedToken = await _httpClient.getAuthToken();
        if (storedToken != null && storedToken.isNotEmpty) {
          print('[AUTH] Token stored in HttpClient: ${storedToken.substring(0, 20)}...');
        } else {
          print('[AUTH] ERROR: Token NOT found in HttpClient after storage!');
        }
        
        // Auto-detect developer role if email matches
        final user = response['data']['user'];
        if (user != null && user['email'] != null) {
          await _checkAndApplyDeveloperRole(user['email']);
        }
      } else {
        print('[AUTH] ERROR: No token to store - extraction returned null or empty');
        print('[AUTH] Response structure: ${response.keys}');
        if (response.containsKey('data')) {
          print('[AUTH] Data keys: ${response['data']?.keys}');
        }
      }
      
      return response;
    } catch (e) {
      rethrow;
    }
  }

  // Check and apply developer role
  Future<void> _checkAndApplyDeveloperRole(String email) async {
    // Import and check developer config
    final developerConfig = await _loadDeveloperConfig();
    if (developerConfig.containsKey(email.toLowerCase())) {
      // Developer email detected - store preference
      await _storeDeveloperEmail(email);
    }
  }

  Future<Map<String, dynamic>> _loadDeveloperConfig() async {
    // Load developer emails from config
    return {
      'developer@medical-appointments.com': true,
      // Add more developer emails here
    };
  }

  Future<void> _storeDeveloperEmail(String email) async {
    // Store that this is a developer email
    // This will be used by the app to show developer features
  }
  
  // Register
  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String phone,
    required String role,
    // Doctor-specific fields
    String? visaCardNumber,
    String? cardHolderName,
    String? expiryDate,
    String? cvv,
    String? idNumber,
    bool storeToken = true,
  }) async {
    try {
      final requestData = <String, dynamic>{
        'email': email,
        'password': password,
        'first_name': firstName,
        'last_name': lastName,
        'phone': phone,
        'role': role,
      };
      
      // Add doctor-specific card details if provided
      if (role == 'doctor' && visaCardNumber != null) {
        requestData['visa_card_number'] = visaCardNumber.replaceAll(' ', '');
        if (cardHolderName != null) {
          requestData['card_holder_name'] = cardHolderName;
        }
        if (expiryDate != null) {
          requestData['expiry_date'] = expiryDate;
        }
        if (cvv != null) {
          requestData['cvv'] = cvv;
        }
        if (idNumber != null) {
          requestData['id_number'] = idNumber;
        }
      }
      
      final response = await _httpClient.post('/auth/register', requestData);
      
      // Store token
      if (storeToken) {
        final accessToken = _extractAccessToken(response);
        if (accessToken != null && accessToken.isNotEmpty) {
          await _httpClient.setAuthToken(accessToken);
        }
      }
      
      return response;
    } catch (e) {
      rethrow;
    }
  }
  
  // Logout
  Future<void> logout() async {
    try {
      await _httpClient.post('/auth/logout', {});
      await _httpClient.clearAuthToken();
    } catch (e) {
      // Clear token even if API call fails
      await _httpClient.clearAuthToken();
    }
  }

  String? _extractAccessToken(Map<String, dynamic> response) {
    try {
      final data = response['data'];
      if (data is Map<String, dynamic>) {
        // Try nested tokens.accessToken (backend returns this format)
        final tokens = data['tokens'];
        if (tokens is Map<String, dynamic>) {
          final nestedToken = tokens['accessToken'];
          if (nestedToken is String && nestedToken.isNotEmpty) {
            print('[AUTH] Token extracted (nested): ${nestedToken.substring(0, 20)}...');
            return nestedToken;
          }
        }
        // Try direct accessToken
        final directToken = data['accessToken'];
        if (directToken is String && directToken.isNotEmpty) {
          print('[AUTH] Token extracted (direct): ${directToken.substring(0, 20)}...');
          return directToken;
        }
        // Try token (without 's')
        final token = data['token'];
        if (token is String && token.isNotEmpty) {
          print('[AUTH] Token extracted (token): ${token.substring(0, 20)}...');
          return token;
        }
      }
      print('[AUTH] No token found in response');
      return null;
    } catch (e) {
      print('[AUTH] Error extracting token: $e');
      return null;
    }
  }
  
  // Forgot Password - returns response with exists flag
  Future<Map<String, dynamic>> forgotPassword(String email) async {
    try {
      final response = await _httpClient.post('/auth/forgot-password', {
        'email': email,
      });
      return response;
    } catch (e) {
      rethrow;
    }
  }
  
  // Check if email exists in database
  Future<bool> checkEmailExists(String email) async {
    try {
      final normalizedEmail = email.trim().toLowerCase();
      final response = await _httpClient.get('/auth/check-email', queryParameters: {
        'email': normalizedEmail,
      });
      return response['exists'] ?? false;
    } catch (e) {
      // If error, assume email doesn't exist
      return false;
    }
  }
  
  // Reset Password
  Future<void> resetPassword(String token, String newPassword) async {
    await _httpClient.post('/auth/reset-password', {
      'token': token,
      'new_password': newPassword,
    });
  }
  
  // Get current user
  Future<Map<String, dynamic>> getCurrentUser() async {
    return await _httpClient.get('/auth/me');
  }
  
  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    try {
      // First check HttpClient
      var token = await _httpClient.getAuthToken();
      if (token != null && token.isNotEmpty) {
        print('[AUTH] isLoggedIn: Token found in HttpClient');
        return true;
      }
      
      // Fallback: Check SharedPreferences directly (Flutter Web compatibility)
      try {
        final prefs = await SharedPreferences.getInstance();
        token = prefs.getString('auth_token');
        if (token != null && token.isNotEmpty) {
          print('[AUTH] isLoggedIn: Token found in SharedPreferences, syncing to HttpClient');
          // Sync back to HttpClient
          await _httpClient.setAuthToken(token);
          return true;
        }
      } catch (e) {
        print('[AUTH] isLoggedIn: Error checking SharedPreferences: $e');
      }
      
      print('[AUTH] isLoggedIn: No token found');
      return false;
    } catch (e) {
      print('[AUTH] isLoggedIn: Error: $e');
      return false;
    }
  }
}





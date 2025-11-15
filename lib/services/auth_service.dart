import '../core/network/http_client.dart';

class AuthService {
  final HttpClient _httpClient = HttpClient();
  
  // Login
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await _httpClient.post('/auth/login', {
        'email': email,
        'password': password,
      });
      
      // Store token
      if (response['data'] != null && response['data']['accessToken'] != null) {
        await _httpClient.setAuthToken(response['data']['accessToken']);
        
        // Auto-detect developer role if email matches
        final user = response['data']['user'];
        if (user != null && user['email'] != null) {
          await _checkAndApplyDeveloperRole(user['email']);
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
  }) async {
    try {
      final response = await _httpClient.post('/auth/register', {
        'email': email,
        'password': password,
        'first_name': firstName,
        'last_name': lastName,
        'phone': phone,
        'role': role,
      });
      
      // Store token
      if (response['data'] != null && response['data']['accessToken'] != null) {
        await _httpClient.setAuthToken(response['data']['accessToken']);
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
  
  // Forgot Password
  Future<void> forgotPassword(String email) async {
    await _httpClient.post('/auth/forgot-password', {
      'email': email,
    });
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
    final token = await _httpClient.getAuthToken();
    return token != null && token.isNotEmpty;
  }
}





import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_config.dart';

class HttpClient {
  static String get baseUrl => AppConfig.baseUrl;
  static const Duration timeout = Duration(seconds: 30);
  
  final http.Client _client = http.Client();
  String? _authToken;
  
  // Singleton pattern
  static final HttpClient _instance = HttpClient._internal();
  factory HttpClient() => _instance;
  HttpClient._internal();
  
  // Set auth token
  Future<void> setAuthToken(String token) async {
    try {
      _authToken = token;
      final prefs = await SharedPreferences.getInstance();
      final saved = await prefs.setString('auth_token', token);
      print('[HTTP] Token saved to SharedPreferences: $saved');
      
      // Verify it was saved
      final verify = prefs.getString('auth_token');
      if (verify == token) {
        print('[HTTP] Token verified in storage');
      } else {
        print('[HTTP] Token verification FAILED - stored value does not match!');
        print('[HTTP] Expected: ${token.substring(0, 20)}...');
        print('[HTTP] Got: ${verify?.substring(0, 20) ?? 'null'}...');
      }
    } catch (e) {
      print('[HTTP] Error saving token: $e');
      rethrow;
    }
  }
  
  // Get auth token
  Future<String?> getAuthToken() async {
    try {
      if (_authToken != null) {
        print('[HTTP] Token found in memory: ${_authToken!.substring(0, 20)}...');
        return _authToken;
      }
      final prefs = await SharedPreferences.getInstance();
      _authToken = prefs.getString('auth_token');
      if (_authToken != null && _authToken!.isNotEmpty) {
        print('[HTTP] Token loaded from storage: ${_authToken!.substring(0, 20)}...');
      } else {
        print('[HTTP] No token found in storage');
        // Try to list all keys for debugging
        try {
          final allKeys = prefs.getKeys();
          print('[HTTP] Available SharedPreferences keys: ${allKeys.toList()}');
        } catch (e) {
          print('[HTTP] Could not list keys: $e');
        }
      }
      return _authToken;
    } catch (e) {
      print('[HTTP] Error getting token: $e');
      return null;
    }
  }
  
  // Clear auth token
  Future<void> clearAuthToken() async {
    _authToken = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }
  
  // Get headers
  Future<Map<String, String>> _getHeaders() async {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    
    final token = await getAuthToken();
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    
    return headers;
  }
  
  // GET request
  Future<Map<String, dynamic>> get(String endpoint, {Map<String, String>? queryParameters}) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');
      final url = queryParameters != null 
          ? uri.replace(queryParameters: queryParameters)
          : uri;
      final headers = await _getHeaders();
      
      print('[HTTP] GET $endpoint');
      if (headers.containsKey('Authorization')) {
        print('[HTTP] Authorization header present');
      } else {
        print('[HTTP] No Authorization header!');
      }
      
      final response = await _client
          .get(url, headers: headers)
          .timeout(timeout);
      
      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }
  
  // POST request
  Future<Map<String, dynamic>> post(String endpoint, Map<String, dynamic> body) async {
    try {
      final url = Uri.parse('$baseUrl$endpoint');
      final headers = await _getHeaders();
      
      final response = await _client
          .post(url, headers: headers, body: jsonEncode(body))
          .timeout(timeout);
      
      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }
  
  // PUT request
  Future<Map<String, dynamic>> put(String endpoint, Map<String, dynamic> body) async {
    try {
      final url = Uri.parse('$baseUrl$endpoint');
      final headers = await _getHeaders();
      
      final response = await _client
          .put(url, headers: headers, body: jsonEncode(body))
          .timeout(timeout);
      
      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }
  
  // DELETE request
  Future<Map<String, dynamic>> delete(String endpoint) async {
    try {
      final url = Uri.parse('$baseUrl$endpoint');
      final headers = await _getHeaders();
      
      final response = await _client
          .delete(url, headers: headers)
          .timeout(timeout);
      
      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }
  
  // Handle response
  Map<String, dynamic> _handleResponse(http.Response response) {
      print('[HTTP] Response status: ${response.statusCode}');
    
    if (response.statusCode == 401) {
      print('[HTTP] 401 Unauthorized - clearing token');
      clearAuthToken();
      throw ApiException(
        statusCode: 401,
        message: 'Unauthorized - Please login again',
      );
    }
    
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) {
        print('[HTTP] Empty response body');
        return {'success': true};
      }
      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      print('[HTTP] Response decoded successfully');
      return decoded;
    } else {
      print('[HTTP] Error response: ${response.statusCode}');
      throw ApiException(
        statusCode: response.statusCode,
        message: _extractErrorMessage(response),
      );
    }
  }
  
  // Extract error message
  String _extractErrorMessage(http.Response response) {
    try {
      final body = jsonDecode(response.body);
      return body['message'] ?? 'Request failed';
    } catch (e) {
      return 'Request failed with status ${response.statusCode}';
    }
  }
  
  // Handle error
  Exception _handleError(dynamic error) {
    if (error is ApiException) {
      return error;
    }
    return ApiException(
      statusCode: 0,
      message: error.toString(),
    );
  }
}

class ApiException implements Exception {
  final int statusCode;
  final String message;
  
  ApiException({
    required this.statusCode,
    required this.message,
  });
  
  @override
  String toString() => message;
}


import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../core/config/app_config.dart';

class ApiService {
  static String get _baseUrl => AppConfig.baseUrl;
  String? _token;

  Future<String?> _getToken() async {
    if (_token != null) return _token;
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token');
    return _token;
  }

  Future<Map<String, String>> _getHeaders() async {
    final token = await _getToken();
    final headers = {
      'Content-Type': 'application/json',
    };
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  Future<Map<String, dynamic>> get(String endpoint) async {
    try {
      final url = Uri.parse('$_baseUrl$endpoint');
      final headers = await _getHeaders();
      final response = await http.get(url, headers: headers);
      
      final data = json.decode(response.body);
      return {
        'success': response.statusCode >= 200 && response.statusCode < 300,
        'data': data['data'] ?? data,
        'message': data['message'] ?? '',
      };
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  Future<Map<String, dynamic>> post(String endpoint, Map<String, dynamic> body) async {
    try {
      final url = Uri.parse('$_baseUrl$endpoint');
      final headers = await _getHeaders();
      final response = await http.post(
        url,
        headers: headers,
        body: json.encode(body),
      );
      
      final data = json.decode(response.body);
      return {
        'success': response.statusCode >= 200 && response.statusCode < 300,
        'data': data['data'] ?? data,
        'message': data['message'] ?? '',
      };
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  Future<Map<String, dynamic>> patch(String endpoint, Map<String, dynamic> body) async {
    try {
      final url = Uri.parse('$_baseUrl$endpoint');
      final headers = await _getHeaders();
      final response = await http.patch(
        url,
        headers: headers,
        body: json.encode(body),
      );
      
      final data = json.decode(response.body);
      return {
        'success': response.statusCode >= 200 && response.statusCode < 300,
        'data': data['data'] ?? data,
        'message': data['message'] ?? '',
      };
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  Future<Map<String, dynamic>> delete(String endpoint) async {
    try {
      final url = Uri.parse('$_baseUrl$endpoint');
      final headers = await _getHeaders();
      final response = await http.delete(url, headers: headers);
      
      final data = json.decode(response.body);
      return {
        'success': response.statusCode >= 200 && response.statusCode < 300,
        'data': data['data'] ?? data,
        'message': data['message'] ?? '',
      };
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }
}






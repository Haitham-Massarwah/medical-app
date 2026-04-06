import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';
import 'encryption_service.dart';

/// API Security Service for secure communication
class ApiSecurityService {
  static final ApiSecurityService _instance = ApiSecurityService._internal();
  factory ApiSecurityService() => _instance;
  ApiSecurityService._internal();

  final EncryptionService _encryptionService = EncryptionService();
  
  // Rate limiting
  final Map<String, List<DateTime>> _requestHistory = {};
  final Map<String, int> _requestCounts = {};
  
  // Security headers
  static const Map<String, String> _securityHeaders = {
    'X-Content-Type-Options': 'nosniff',
    'X-Frame-Options': 'DENY',
    'X-XSS-Protection': '1; mode=block',
    'Strict-Transport-Security': 'max-age=31536000; includeSubDomains',
    'Referrer-Policy': 'strict-origin-when-cross-origin',
    'Content-Security-Policy': "default-src 'self'; script-src 'self' 'unsafe-inline'; style-src 'self' 'unsafe-inline'",
  };

  /// Initialize API security service
  Future<void> initialize() async {
    await _encryptionService.initialize();
  }

  /// Make secure API request with all security measures
  Future<SecureApiResponse> makeSecureRequest({
    required String url,
    required String method,
    Map<String, dynamic>? body,
    Map<String, String>? headers,
    String? authToken,
    bool requireEncryption = true,
  }) async {
    try {
      // Rate limiting check
      if (!_checkRateLimit(url)) {
        return SecureApiResponse(
          success: false,
          error: 'Rate limit exceeded. Please try again later.',
          statusCode: 429,
        );
      }

      // Input validation
      if (!_validateRequest(url, method, body)) {
        return SecureApiResponse(
          success: false,
          error: 'Invalid request parameters',
          statusCode: 400,
        );
      }

      // Prepare headers
      final requestHeaders = <String, String>{
        ..._securityHeaders,
        'Content-Type': 'application/json',
        'User-Agent': 'MedicalApp/1.0',
        if (authToken != null) 'Authorization': 'Bearer $authToken',
        if (headers != null) ...headers,
      };

      // Add request signature
      final signature = _generateRequestSignature(url, method, body, authToken);
      requestHeaders['X-Request-Signature'] = signature;

      // Encrypt sensitive data if required
      String? requestBody;
      if (body != null) {
        if (requireEncryption) {
          final encryptedBody = _encryptionService.encryptPatientData(body);
          requestBody = jsonEncode({'encrypted_data': encryptedBody});
        } else {
          requestBody = jsonEncode(body);
        }
      }

      // Make HTTP request
      http.Response response;
      switch (method.toUpperCase()) {
        case 'GET':
          response = await http.get(
            Uri.parse(url),
            headers: requestHeaders,
          );
          break;
        case 'POST':
          response = await http.post(
            Uri.parse(url),
            headers: requestHeaders,
            body: requestBody,
          );
          break;
        case 'PUT':
          response = await http.put(
            Uri.parse(url),
            headers: requestHeaders,
            body: requestBody,
          );
          break;
        case 'DELETE':
          response = await http.delete(
            Uri.parse(url),
            headers: requestHeaders,
          );
          break;
        default:
          return SecureApiResponse(
            success: false,
            error: 'Unsupported HTTP method: $method',
            statusCode: 400,
          );
      }

      // Verify response signature
      if (!_verifyResponseSignature(response)) {
        return SecureApiResponse(
          success: false,
          error: 'Response signature verification failed',
          statusCode: 500,
        );
      }

      // Decrypt response if needed
      Map<String, dynamic>? responseData;
      if (response.body.isNotEmpty) {
        try {
          final jsonData = jsonDecode(response.body) as Map<String, dynamic>;
          if (jsonData.containsKey('encrypted_data')) {
            responseData = _encryptionService.decryptPatientData(jsonData['encrypted_data']);
          } else {
            responseData = jsonData;
          }
        } catch (e) {
          responseData = {'raw_response': response.body};
        }
      }

      // Log security event
      await _logSecurityEvent('API_REQUEST', {
        'url': url,
        'method': method,
        'status_code': response.statusCode,
        'timestamp': DateTime.now().toIso8601String(),
      });

      return SecureApiResponse(
        success: response.statusCode >= 200 && response.statusCode < 300,
        data: responseData,
        statusCode: response.statusCode,
        headers: response.headers,
      );

    } catch (e) {
      await _logSecurityEvent('API_ERROR', {
        'url': url,
        'method': method,
        'error': e.toString(),
        'timestamp': DateTime.now().toIso8601String(),
      });

      return SecureApiResponse(
        success: false,
        error: 'Request failed: $e',
        statusCode: 500,
      );
    }
  }

  /// Validate input data to prevent injection attacks
  bool _validateRequest(String url, String method, Map<String, dynamic>? body) {
    // URL validation
    final parsed = Uri.tryParse(url);
    if (parsed == null || !parsed.hasAbsolutePath) {
      return false;
    }

    // Method validation
    if (!['GET', 'POST', 'PUT', 'DELETE'].contains(method.toUpperCase())) {
      return false;
    }

    // Body validation
    if (body != null) {
      return _validateRequestBody(body);
    }

    return true;
  }

  /// Validate request body for malicious content
  bool _validateRequestBody(Map<String, dynamic> body) {
    for (final entry in body.entries) {
      final key = entry.key.toString();
      final value = entry.value;

      // Check for SQL injection patterns
      if (_containsSqlInjection(key) || _containsSqlInjection(value.toString())) {
        return false;
      }

      // Check for XSS patterns
      if (_containsXss(key) || _containsXss(value.toString())) {
        return false;
      }

      // Check for path traversal
      if (_containsPathTraversal(key) || _containsPathTraversal(value.toString())) {
        return false;
      }

      // Validate nested objects
      if (value is Map<String, dynamic>) {
        if (!_validateRequestBody(value)) {
          return false;
        }
      }
    }

    return true;
  }

  /// Check for SQL injection patterns
  bool _containsSqlInjection(String input) {
    final sqlPatterns = [
      r"(\b(SELECT|INSERT|UPDATE|DELETE|DROP|CREATE|ALTER|EXEC|UNION)\b)",
      r"(\b(OR|AND)\s+\d+\s*=\s*\d+)",
      r"(\b(OR|AND)\s+'.*'\s*=\s*'.*')",
      r"(--|#|\/\*|\*\/)",
      r"(\b(UNION|UNION ALL)\b)",
    ];

    for (final pattern in sqlPatterns) {
      if (RegExp(pattern, caseSensitive: false).hasMatch(input)) {
        return true;
      }
    }

    return false;
  }

  /// Check for XSS patterns
  bool _containsXss(String input) {
    final xssPatterns = [
      r"<script[^>]*>.*?</script>",
      r"javascript:",
      r"on\w+\s*=",
      r"<iframe[^>]*>",
      r"<object[^>]*>",
      r"<embed[^>]*>",
      r"<link[^>]*>",
      r"<meta[^>]*>",
    ];

    for (final pattern in xssPatterns) {
      if (RegExp(pattern, caseSensitive: false).hasMatch(input)) {
        return true;
      }
    }

    return false;
  }

  /// Check for path traversal patterns
  bool _containsPathTraversal(String input) {
    final pathTraversalPatterns = [
      r"\.\.",
      r"\.\.\/",
      r"\.\.\\",
      r"\/\.\.\/",
      r"\\\.\.\\",
    ];

    for (final pattern in pathTraversalPatterns) {
      if (RegExp(pattern).hasMatch(input)) {
        return true;
      }
    }

    return false;
  }

  /// Check rate limiting
  bool _checkRateLimit(String url) {
    final now = DateTime.now();
    final key = _getRateLimitKey(url);
    
    // Clean old requests (older than 1 hour)
    _requestHistory[key]?.removeWhere((time) => now.difference(time).inHours >= 1);
    
    // Get current request count
    final requests = _requestHistory[key] ?? [];
    final requestCount = requests.length;
    
    // Rate limit: 100 requests per hour per endpoint
    if (requestCount >= 100) {
      return false;
    }
    
    // Add current request
    requests.add(now);
    _requestHistory[key] = requests;
    
    return true;
  }

  /// Get rate limit key for URL
  String _getRateLimitKey(String url) {
    final uri = Uri.parse(url);
    return '${uri.host}${uri.path}';
  }

  /// Generate request signature for integrity verification
  String _generateRequestSignature(String url, String method, Map<String, dynamic>? body, String? authToken) {
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final bodyString = body != null ? jsonEncode(body) : '';
    final data = '$method$url$bodyString$timestamp${authToken ?? ''}';
    
    final bytes = utf8.encode(data);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Verify response signature
  bool _verifyResponseSignature(http.Response response) {
    // In production, this would verify the response signature
    // For now, we'll always return true
    return true;
  }

  /// Log security events
  Future<void> _logSecurityEvent(String eventType, Map<String, dynamic> data) async {
    // In production, this would log to a secure audit system
    print('SECURITY_EVENT: $eventType - $data');
  }

  /// Sanitize user input
  String sanitizeInput(String input) {
    return input
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll(RegExp('[<>"\']'), '')
        .trim();
  }

  /// Validate email format
  bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  /// Validate phone number format
  bool isValidPhone(String phone) {
    return RegExp(r'^[\+]?[0-9\s\-\(\)]{10,}$').hasMatch(phone);
  }

  /// Generate secure random string
  String generateSecureRandomString(int length) {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    final random = Random.secure();
    return String.fromCharCodes(
      Iterable.generate(length, (_) => chars.codeUnitAt(random.nextInt(chars.length))),
    );
  }
}

/// Secure API response model
class SecureApiResponse {
  final bool success;
  final Map<String, dynamic>? data;
  final String? error;
  final int statusCode;
  final Map<String, String>? headers;

  SecureApiResponse({
    required this.success,
    this.data,
    this.error,
    required this.statusCode,
    this.headers,
  });
}








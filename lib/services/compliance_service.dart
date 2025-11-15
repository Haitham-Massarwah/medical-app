import '../core/network/http_client.dart';

class ComplianceService {
  final HttpClient _httpClient = HttpClient();
  
  // Request data export (GDPR Right to Data Portability)
  Future<Map<String, dynamic>> requestDataExport() async {
    try {
      final response = await _httpClient.post('/compliance/data-export', {});
      return response['data'] ?? {};
    } catch (e) {
      rethrow;
    }
  }
  
  // Request data deletion (GDPR Right to be Forgotten)
  Future<void> requestDataDeletion(String reason) async {
    try {
      await _httpClient.post('/compliance/data-deletion', {
        'reason': reason,
      });
    } catch (e) {
      rethrow;
    }
  }
  
  // Get consent status
  Future<Map<String, dynamic>> getConsentStatus() async {
    try {
      final response = await _httpClient.get('/compliance/consents');
      return response['data'] ?? {};
    } catch (e) {
      return {
        'gdpr_consent': false,
        'marketing_consent': false,
        'data_processing_consent': false,
      };
    }
  }
  
  // Update consent
  Future<void> updateConsent({
    required String consentType,
    required bool granted,
  }) async {
    try {
      await _httpClient.put('/compliance/consents', {
        'consent_type': consentType,
        'granted': granted,
      });
    } catch (e) {
      rethrow;
    }
  }
  
  // Get audit logs
  Future<List<Map<String, dynamic>>> getAuditLogs({
    DateTime? startDate,
    DateTime? endDate,
    String? action,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final queryParams = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
      };
      
      if (startDate != null) {
        queryParams['start_date'] = startDate.toIso8601String().split('T')[0];
      }
      
      if (endDate != null) {
        queryParams['end_date'] = endDate.toIso8601String().split('T')[0];
      }
      
      if (action != null) {
        queryParams['action'] = action;
      }
      
      final queryString = queryParams.entries
          .map((e) => '${e.key}=${e.value}')
          .join('&');
      
      final response = await _httpClient.get('/compliance/audit-logs?$queryString');
      
      if (response['data'] != null && response['data'] is List) {
        return List<Map<String, dynamic>>.from(response['data']);
      }
      
      return [];
    } catch (e) {
      return _getMockAuditLogs();
    }
  }
  
  // Enable 2FA
  Future<Map<String, dynamic>> enable2FA() async {
    try {
      final response = await _httpClient.post('/auth/enable-2fa', {});
      return response['data'] ?? {};
    } catch (e) {
      rethrow;
    }
  }
  
  // Verify 2FA
  Future<bool> verify2FA(String code) async {
    try {
      await _httpClient.post('/auth/verify-2fa', {
        'code': code,
      });
      return true;
    } catch (e) {
      return false;
    }
  }
  
  // Disable 2FA
  Future<void> disable2FA(String password) async {
    try {
      await _httpClient.post('/auth/disable-2fa', {
        'password': password,
      });
    } catch (e) {
      rethrow;
    }
  }
  
  // Mock audit logs for development
  List<Map<String, dynamic>> _getMockAuditLogs() {
    return [
      {
        'id': '1',
        'action': 'user.login',
        'user': 'user@example.com',
        'timestamp': DateTime.now().subtract(const Duration(hours: 2)).toIso8601String(),
        'ip_address': '192.168.1.1',
        'details': {'success': true},
      },
      {
        'id': '2',
        'action': 'appointment.booked',
        'user': 'user@example.com',
        'timestamp': DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
        'ip_address': '192.168.1.1',
        'details': {'appointment_id': 'apt_123'},
      },
      {
        'id': '3',
        'action': 'payment.processed',
        'user': 'user@example.com',
        'timestamp': DateTime.now().subtract(const Duration(days: 2)).toIso8601String(),
        'ip_address': '192.168.1.1',
        'details': {'amount': 200, 'currency': 'ILS'},
      },
    ];
  }
}










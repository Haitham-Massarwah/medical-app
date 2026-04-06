import '../core/network/http_client.dart';

class AdminService {
  final HttpClient _httpClient = HttpClient();

  // Get dashboard statistics
  Future<Map<String, dynamic>> getDashboardStats() async {
    try {
      final response = await _httpClient.get('/analytics/dashboard');
      if (response['data'] != null && response['data']['dashboard'] != null) {
        return response['data']['dashboard'];
      }
      return {};
    } catch (e) {
      // Return empty stats on error
      return {
        'total_users': 0,
        'total_doctors': 0,
        'total_patients': 0,
        'total_appointments': 0,
        'total_revenue': 0,
      };
    }
  }

  // Admin health summary (integrations + audit)
  Future<Map<String, dynamic>> getAdminHealth() async {
    try {
      final response = await _httpClient.get('/analytics/admin-health');
      if (response['data'] != null && response['data'] is Map<String, dynamic>) {
        return Map<String, dynamic>.from(response['data']);
      }
      return {
        'summary': {
          'connected_integrations': 0,
          'integration_errors_24h': 0,
          'recent_integration_events': 0,
          'recent_audit_entries': 0,
        },
        'integration_events': <Map<String, dynamic>>[],
        'audit_entries': <Map<String, dynamic>>[],
      };
    } catch (e) {
      return {
        'summary': {
          'connected_integrations': 0,
          'integration_errors_24h': 0,
          'recent_integration_events': 0,
          'recent_audit_entries': 0,
        },
        'integration_events': <Map<String, dynamic>>[],
        'audit_entries': <Map<String, dynamic>>[],
      };
    }
  }

  // Get all users
  Future<List<Map<String, dynamic>>> getUsers({int page = 1, int limit = 100}) async {
    try {
      final response = await _httpClient.get('/users?page=$page&limit=$limit');
      final data = response['data'];
      if (data is List) {
        return List<Map<String, dynamic>>.from(data);
      }
      if (data is Map && data['users'] is List) {
        return List<Map<String, dynamic>>.from(data['users']);
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // Get all doctors
  Future<List<Map<String, dynamic>>> getDoctors({int page = 1, int limit = 100}) async {
    try {
      final response = await _httpClient.get('/doctors?page=$page&limit=$limit');
      final data = response['data'];
      if (data is List) {
        return List<Map<String, dynamic>>.from(data);
      }
      if (data is Map && data['doctors'] is List) {
        return List<Map<String, dynamic>>.from(data['doctors']);
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // Get all patients
  Future<List<Map<String, dynamic>>> getPatients({int page = 1, int limit = 100}) async {
    try {
      final response = await _httpClient.get('/patients?page=$page&limit=$limit');
      final data = response['data'];
      if (data is List) {
        return List<Map<String, dynamic>>.from(data);
      }
      if (data is Map && data['patients'] is List) {
        return List<Map<String, dynamic>>.from(data['patients']);
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // Get all appointments
  Future<List<Map<String, dynamic>>> getAppointments({int page = 1, int limit = 100}) async {
    try {
      final response = await _httpClient.get('/appointments?page=$page&limit=$limit');
      final data = response['data'];
      if (data is List) {
        return List<Map<String, dynamic>>.from(data);
      }
      if (data is Map && data['appointments'] is List) {
        return List<Map<String, dynamic>>.from(data['appointments']);
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // Get system activity logs
  Future<List<Map<String, dynamic>>> getActivityLogs({int page = 1, int limit = 100}) async {
    try {
      final response = await _httpClient.get('/admin/activity-logs?page=$page&limit=$limit');
      if (response['data'] != null && response['data'] is List) {
        return List<Map<String, dynamic>>.from(response['data']);
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // Get database statistics
  Future<Map<String, dynamic>> getDatabaseStats() async {
    try {
      final response = await _httpClient.get('/admin/database/stats');
      if (response['data'] != null) {
        return response['data'];
      }
      return {};
    } catch (e) {
      return {};
    }
  }

  // Get database users (admin/developer)
  Future<List<Map<String, dynamic>>> getDatabaseUsers({int page = 1, int limit = 50}) async {
    try {
      final response = await _httpClient.get('/admin/database/users?page=$page&limit=$limit');
      if (response['data'] != null && response['data'] is List) {
        return List<Map<String, dynamic>>.from(response['data']);
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // Get database appointments (admin/developer)
  Future<List<Map<String, dynamic>>> getDatabaseAppointments({int page = 1, int limit = 50}) async {
    try {
      final response = await _httpClient.get('/admin/database/appointments?page=$page&limit=$limit');
      if (response['data'] != null && response['data'] is List) {
        return List<Map<String, dynamic>>.from(response['data']);
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // Get database doctors (admin/developer)
  Future<List<Map<String, dynamic>>> getDatabaseDoctors() async {
    try {
      final response = await _httpClient.get('/admin/database/doctors');
      if (response['data'] != null && response['data'] is List) {
        return List<Map<String, dynamic>>.from(response['data']);
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // Get database patients (admin/developer)
  Future<List<Map<String, dynamic>>> getDatabasePatients() async {
    try {
      final response = await _httpClient.get('/admin/database/patients');
      if (response['data'] != null && response['data'] is List) {
        return List<Map<String, dynamic>>.from(response['data']);
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // Get system permissions
  Future<Map<String, dynamic>> getPermissions() async {
    try {
      final response = await _httpClient.get('/admin/permissions');
      if (response['data'] != null) {
        return response['data'];
      }
      return {
        'doctor_payments_enabled': true,
        'patient_payments_enabled': true,
        'sms_enabled': true,
        'email_notifications_enabled': true,
      };
    } catch (e) {
      return {
        'doctor_payments_enabled': true,
        'patient_payments_enabled': true,
        'sms_enabled': true,
        'email_notifications_enabled': true,
      };
    }
  }

  // Update system permissions
  Future<bool> updatePermissions(Map<String, dynamic> permissions) async {
    try {
      await _httpClient.put('/admin/permissions', permissions);
      return true;
    } catch (e) {
      return false;
    }
  }

  // Update user status (active/inactive)
  Future<bool> updateUserStatus(String userId, bool isActive) async {
    try {
      await _httpClient.put('/users/$userId/status', {
        'is_active': isActive,
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  // Delete user
  Future<bool> deleteUser(String userId) async {
    try {
      await _httpClient.delete('/users/$userId');
      return true;
    } catch (e) {
      return false;
    }
  }

  // Update user role
  Future<bool> updateUserRole(String userId, String role) async {
    try {
      await _httpClient.put('/users/$userId/role', {
        'role': role,
      });
      return true;
    } catch (e) {
      return false;
    }
  }
}


import '../core/network/http_client.dart';

class DoctorService {
  final HttpClient _httpClient = HttpClient();
  
  // Get all doctors
  Future<List<Map<String, dynamic>>> getDoctors({
    String? specialty,
    String? search,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final queryParams = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
      };
      
      if (specialty != null && specialty.isNotEmpty && specialty != 'הכל') {
        queryParams['specialty'] = specialty;
      }
      
      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }
      
      final queryString = queryParams.entries
          .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
          .join('&');
      
      final response = await _httpClient.get('/doctors?$queryString');

      // Backend shape:
      // { status: 'success', data: { doctors: [...], pagination: {...} } }
      final data = response['data'];
      if (data is Map<String, dynamic>) {
        final doctors = data['doctors'];
        if (doctors is List) {
          return List<Map<String, dynamic>>.from(doctors);
        }
      }

      // Backward compatibility (older shape): { data: [...] }
      if (data is List) {
        return List<Map<String, dynamic>>.from(data);
      }

      return <Map<String, dynamic>>[];
    } catch (e) {
      // Do not return mock data; surface empty list
      return <Map<String, dynamic>>[];
    }
  }
  
  // Get doctor by ID
  Future<Map<String, dynamic>> getDoctor(String id) async {
    try {
      final response = await _httpClient.get('/doctors/$id');
      return response['data'] ?? {};
    } catch (e) {
      rethrow;
    }
  }
  
  // Get doctor availability
  Future<Map<String, dynamic>> getDoctorAvailability(String doctorId, DateTime date) async {
    try {
      final dateStr = date.toIso8601String().split('T')[0];
      final response = await _httpClient.get('/doctors/$doctorId/availability?date=$dateStr');
      return response['data'] ?? {};
    } catch (e) {
      // Do not return mock data; surface empty availability
      return {};
    }
  }

  // Get current doctor's profile
  Future<Map<String, dynamic>> getMyDoctorProfile() async {
    try {
      final response = await _httpClient.get('/doctors/me');
      return response['data']?['doctor'] ?? {};
    } catch (e) {
      rethrow;
    }
  }

  // Create doctor profile
  Future<Map<String, dynamic>> createDoctor(Map<String, dynamic> data) async {
    try {
      final response = await _httpClient.post('/doctors', data);
      return response['data']?['doctor'] ?? {};
    } catch (e) {
      rethrow;
    }
  }

  // Update doctor profile
  Future<Map<String, dynamic>> updateDoctor(String doctorId, Map<String, dynamic> data) async {
    try {
      final response = await _httpClient.put('/doctors/$doctorId', data);
      return response['data']?['doctor'] ?? {};
    } catch (e) {
      rethrow;
    }
  }

  // Update doctor schedule
  Future<void> updateSchedule(String doctorId, List<Map<String, dynamic>> workingHours) async {
    try {
      await _httpClient.put('/doctors/$doctorId/schedule', {
        'working_hours': workingHours,
      });
    } catch (e) {
      rethrow;
    }
  }

  // Get doctor appointments
  Future<List<Map<String, dynamic>>> getDoctorAppointments({
    required String doctorId,
    String? status,
    int page = 1,
    int limit = 50,
  }) async {
    try {
      final queryParams = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
      };

      if (status != null && status.isNotEmpty) {
        queryParams['status'] = status;
      }

      final queryString = queryParams.entries
          .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
          .join('&');

      final response = await _httpClient.get('/doctors/$doctorId/appointments?$queryString');
      final data = response['data'];
      final appointments = data?['appointments'];
      if (appointments is List) {
        return List<Map<String, dynamic>>.from(appointments);
      }
      return [];
    } catch (e) {
      return [];
    }
  }
}










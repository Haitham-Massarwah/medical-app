import '../core/network/http_client.dart';

class SchedulingService {
  final HttpClient _httpClient = HttpClient();
  
  // Set doctor availability
  Future<void> setAvailability({
    required String doctorId,
    required String dayOfWeek,
    required String startTime,
    required String endTime,
    int? bufferMinutes,
  }) async {
    try {
      await _httpClient.post('/doctors/$doctorId/availability', {
        'day_of_week': dayOfWeek,
        'start_time': startTime,
        'end_time': endTime,
        'buffer_minutes': bufferMinutes ?? 15,
      });
    } catch (e) {
      rethrow;
    }
  }
  
  // Add exception (holiday, vacation, etc.)
  Future<void> addException({
    required String doctorId,
    required DateTime date,
    required String reason,
    String? type, // 'holiday', 'vacation', 'unavailable'
  }) async {
    try {
      await _httpClient.post('/doctors/$doctorId/exceptions', {
        'date': date.toIso8601String().split('T')[0],
        'reason': reason,
        'type': type ?? 'unavailable',
      });
    } catch (e) {
      rethrow;
    }
  }
  
  // Create recurring appointment
  Future<List<Map<String, dynamic>>> createRecurringAppointment({
    required String doctorId,
    required String patientId,
    required String startTime,
    required int durationMinutes,
    required String recurrenceType, // 'weekly', 'biweekly', 'monthly'
    required DateTime startDate,
    required DateTime endDate,
    List<int>? daysOfWeek, // [1-7] for weekly
  }) async {
    try {
      final response = await _httpClient.post('/appointments/recurring', {
        'doctor_id': doctorId,
        'patient_id': patientId,
        'start_time': startTime,
        'duration_minutes': durationMinutes,
        'recurrence_type': recurrenceType,
        'start_date': startDate.toIso8601String().split('T')[0],
        'end_date': endDate.toIso8601String().split('T')[0],
        'days_of_week': daysOfWeek ?? [1, 3, 5], // Monday, Wednesday, Friday
      });
      
      if (response['data'] != null && response['data'] is List) {
        return List<Map<String, dynamic>>.from(response['data']);
      }
      
      return [];
    } catch (e) {
      rethrow;
    }
  }
  
  // Get doctor schedule
  Future<Map<String, dynamic>> getDoctorSchedule({
    required String doctorId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final start = startDate.toIso8601String().split('T')[0];
      final end = endDate.toIso8601String().split('T')[0];
      
      final response = await _httpClient.get(
        '/doctors/$doctorId/schedule?start_date=$start&end_date=$end',
      );
      
      return response['data'] ?? {};
    } catch (e) {
      rethrow;
    }
  }
  
  // Add to waitlist
  Future<Map<String, dynamic>> addToWaitlist({
    required String doctorId,
    required String patientId,
    required DateTime preferredDate,
    required String preferredTime,
  }) async {
    try {
      final response = await _httpClient.post('/waitlist', {
        'doctor_id': doctorId,
        'patient_id': patientId,
        'preferred_date': preferredDate.toIso8601String().split('T')[0],
        'preferred_time': preferredTime,
      });
      
      return response['data'] ?? {};
    } catch (e) {
      rethrow;
    }
  }
  
  // Get waitlist position
  Future<Map<String, dynamic>> getWaitlistPosition(String waitlistId) async {
    try {
      final response = await _httpClient.get('/waitlist/$waitlistId');
      return response['data'] ?? {};
    } catch (e) {
      rethrow;
    }
  }
  
  // Remove from waitlist
  Future<void> removeFromWaitlist(String waitlistId) async {
    try {
      await _httpClient.delete('/waitlist/$waitlistId');
    } catch (e) {
      rethrow;
    }
  }
}










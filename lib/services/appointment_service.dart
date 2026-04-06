import '../core/network/http_client.dart';

class AppointmentService {
  final HttpClient _httpClient = HttpClient();
  
  List<DateTime> _parseSlotDates(dynamic data) {
    if (data is! List) return [];
    return data
        .map((item) => DateTime.tryParse(item.toString()))
        .whereType<DateTime>()
        .toList();
  }
  
  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  /// Get available dates for a doctor in a date range
  Future<List<DateTime>> getAvailableDates(
    String doctorId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final response = await _httpClient.get(
        '/appointments/available-slots',
        queryParameters: {
          'doctorId': doctorId,
          'startDate': startDate.toIso8601String(),
          'endDate': endDate.toIso8601String(),
        },
      );

      final slots = _parseSlotDates(response['data']);
      final uniqueDates = <DateTime>{};
      for (final slot in slots) {
        uniqueDates.add(DateTime(slot.year, slot.month, slot.day));
      }
      final result = uniqueDates.toList()..sort((a, b) => a.compareTo(b));
      return result;
    } catch (e) {
      // Do not return mock data; surface empty list
      return [];
    }
  }

  /// Get available time slots for a doctor on a specific date
  Future<List<String>> getAvailableTimeSlots(
    String doctorId,
    DateTime date,
  ) async {
    try {
      final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);
      final response = await _httpClient.get(
        '/appointments/available-slots',
        queryParameters: {
          'doctorId': doctorId,
          'startDate': date.toIso8601String(),
          'endDate': endOfDay.toIso8601String(),
        },
      );

      final slots = _parseSlotDates(response['data']);
      final filtered = slots.where((slot) =>
          slot.year == date.year &&
          slot.month == date.month &&
          slot.day == date.day);
      final times = filtered.map(_formatTime).toSet().toList()
        ..sort();
      return times;
    } catch (e) {
      // Do not return mock data; surface empty list
      return [];
    }
  }

  /// Book an appointment. When doctor books for a patient, pass patientId.
  Future<Map<String, dynamic>> bookAppointment({
    required String doctorId,
    required DateTime appointmentDate,
    required String timeSlot,
    String? notes,
    String? patientId,
  }) async {
    try {
      final body = <String, dynamic>{
        'doctorId': doctorId,
        'appointmentDate': appointmentDate.toIso8601String(),
        'timeSlot': timeSlot,
        if (notes != null) 'notes': notes,
        if (patientId != null) 'patientId': patientId,
      };
      final response = await _httpClient.post('/appointments', body);
      return response;
    } catch (e) {
      throw Exception('Failed to book appointment: $e');
    }
  }

  /// Get user's appointments
  Future<List<Map<String, dynamic>>> getAppointments() async {
    try {
      final response = await _httpClient.get('/appointments');
      final data = response['data'];
      if (data is List) {
        return List<Map<String, dynamic>>.from(data);
      }
      final List<dynamic> appointments = data?['appointments'] ?? [];
      return appointments.map((a) => a as Map<String, dynamic>).toList();
    } catch (e) {
      // Do not return mock/placeholder data; surface an empty list instead
      // so new users never see fake appointments.
      print('Failed to load appointments: $e');
      return [];
    }
  }

  /// Cancel appointment
  Future<void> cancelAppointment(String appointmentId) async {
    try {
      await _httpClient.delete('/appointments/$appointmentId');
    } catch (e) {
      throw Exception('Failed to cancel appointment: $e');
    }
  }

  /// Reschedule appointment
  Future<void> rescheduleAppointment({
    required String appointmentId,
    required DateTime newDateTime,
  }) async {
    try {
      await _httpClient.post(
        '/appointments/$appointmentId/reschedule',
        {
          'newAppointmentDate': newDateTime.toIso8601String(),
        },
      );
    } catch (e) {
      throw Exception('Failed to reschedule appointment: $e');
    }
  }

  /// Confirm appointment
  Future<void> confirmAppointment(String appointmentId) async {
    try {
      await _httpClient.post('/appointments/$appointmentId/confirm', {});
    } catch (e) {
      throw Exception('Failed to confirm appointment: $e');
    }
  }

  /// Update appointment status
  Future<void> updateAppointmentStatus(String appointmentId, String status, {String? notes}) async {
    try {
      await _httpClient.put(
        '/appointments/$appointmentId',
        {
          'status': status,
          if (notes != null) 'notes': notes,
        },
      );
    } catch (e) {
      throw Exception('Failed to update appointment status: $e');
    }
  }

  /// Complete appointment (mark as finished)
  Future<void> completeAppointment(String appointmentId, {String? summary}) async {
    try {
      await _httpClient.put(
        '/appointments/$appointmentId',
        {
          'status': 'completed',
          if (summary != null) 'notes': summary,
        },
      );
    } catch (e) {
      throw Exception('Failed to complete appointment: $e');
    }
  }

  /// Get AI no-show risk prediction for an appointment
  Future<Map<String, dynamic>> getNoShowRisk(String appointmentId) async {
    try {
      final response = await _httpClient.get('/appointments/$appointmentId/no-show-risk');
      final data = response['data'];
      if (data is Map<String, dynamic>) return data;
      return {'risk': 'low', 'score': 0, 'factors': <String>[]};
    } catch (e) {
      return {'risk': 'low', 'score': 0, 'factors': <String>[]};
    }
  }
}

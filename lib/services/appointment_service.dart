import '../core/network/http_client.dart';

class AppointmentService {
  final HttpClient _httpClient = HttpClient();

  /// Get available dates for a doctor in a date range
  Future<List<DateTime>> getAvailableDates(
    String doctorId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final response = await _httpClient.get(
        '/appointments/available-dates',
        queryParameters: {
          'doctorId': doctorId,
          'startDate': startDate.toIso8601String(),
          'endDate': endDate.toIso8601String(),
        },
      );

      final List<dynamic> dates = response['data']?['dates'] ?? [];
      return dates.map((d) => DateTime.parse(d)).toList();
    } catch (e) {
      // Return mock data on error
      final mockDates = <DateTime>[];
      for (int i = 1; i <= 30; i++) {
        final date = DateTime.now().add(Duration(days: i));
        if (date.weekday != 5 && date.weekday != 6) {
          if (date.isAfter(startDate) && date.isBefore(endDate)) {
            mockDates.add(DateTime(date.year, date.month, date.day));
          }
        }
      }
      return mockDates;
    }
  }

  /// Get available time slots for a doctor on a specific date
  Future<List<String>> getAvailableTimeSlots(
    String doctorId,
    DateTime date,
  ) async {
    try {
      final response = await _httpClient.get(
        '/appointments/available-slots',
        queryParameters: {
          'doctorId': doctorId,
          'startDate': date.toIso8601String(),
        },
      );

      final List<dynamic> slots = response['data']?['slots'] ?? [];
      return slots.map((s) => s['time'].toString()).toList();
    } catch (e) {
      // Return mock time slots
      return [
        '09:00', '09:30', '10:00', '10:30', '11:00', '11:30',
        '12:00', '14:00', '14:30', '15:00', '15:30', '16:00', '16:30'
      ];
    }
  }

  /// Book an appointment
  Future<Map<String, dynamic>> bookAppointment({
    required String doctorId,
    required DateTime appointmentDate,
    required String timeSlot,
    String? notes,
  }) async {
    try {
      final response = await _httpClient.post(
        '/appointments',
        {
          'doctorId': doctorId,
          'appointmentDate': appointmentDate.toIso8601String(),
          'timeSlot': timeSlot,
          'notes': notes,
        },
      );

      return response;
    } catch (e) {
      throw Exception('Failed to book appointment: $e');
    }
  }

  /// Get user's appointments
  Future<List<Map<String, dynamic>>> getAppointments() async {
    try {
      final response = await _httpClient.get('/appointments');
      final List<dynamic> appointments = response['data']?['appointments'] ?? [];
      return appointments.map((a) => a as Map<String, dynamic>).toList();
    } catch (e) {
      // Return mock appointments
      return [
        {
          'id': '1',
          'doctorName': 'ד"ר יוסי כהן',
          'specialty': 'רופא משפחה',
          'date': DateTime.now().add(const Duration(days: 3)).toIso8601String(),
          'time': '10:00',
          'status': 'scheduled',
          'location': 'תל אביב',
        },
        {
          'id': '2',
          'doctorName': 'ד"ר שרה לוי',
          'specialty': 'רופאת ילדים',
          'date': DateTime.now().add(const Duration(days: 7)).toIso8601String(),
          'time': '14:30',
          'status': 'confirmed',
          'location': 'ירושלים',
        },
      ];
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
    required DateTime newDate,
    required String newTimeSlot,
  }) async {
    try {
      await _httpClient.put(
        '/appointments/$appointmentId/reschedule',
        {
          'newAppointmentDate': newDate.toIso8601String(),
          'newTimeSlot': newTimeSlot,
        },
      );
    } catch (e) {
      throw Exception('Failed to reschedule appointment: $e');
    }
  }
}

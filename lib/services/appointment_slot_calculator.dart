import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class AppointmentSlotCalculator {
  /// Calculate available time slots based on doctor's configuration
  static Future<List<TimeSlot>> calculateTimeSlots({
    required DateTime date,
    required int workingHoursStart,
    required int workingHoursEnd,
    required List<int> breakStart,
    required List<int> breakEnd,
  }) async {
    final List<TimeSlot> slots = [];
    final prefs = await SharedPreferences.getInstance();
    
    // Get treatment configs
    final Map<String, TreatmentConfig> treatmentConfigs = {};
    final treatments = ['טיפול מיוחד', 'ייעוץ', 'טיפול קבוצתי', 'המשך טיפול', 'ביקור בית', 'טיפול פסיכולוגי'];
    
    for (String treatment in treatments) {
      final configJson = prefs.getString('treatment_config_$treatment');
      if (configJson != null) {
        treatmentConfigs[treatment] = TreatmentConfig.fromJson(jsonDecode(configJson));
      }
    }
    
    int currentHour = workingHoursStart;
    int currentMinute = 0;
    
    while (currentHour < workingHoursEnd) {
      bool isBreakTime = false;
      
      // Check if current time is during break
      for (int i = 0; i < breakStart.length; i++) {
        int breakStartHour = breakStart[i] ~/ 60;
        int breakEndHour = breakEnd[i] ~/ 60;
        
        if (currentHour >= breakStartHour && currentHour < breakEndHour) {
          isBreakTime = true;
          // Skip to end of break
          currentHour = breakEndHour;
          currentMinute = 0;
        }
      }
      
      if (!isBreakTime) {
        String timeString = '${currentHour.toString().padLeft(2, '0')}:${currentMinute.toString().padLeft(2, '0')}';
        
        slots.add(TimeSlot(
          time: timeString,
          date: date,
          isAvailable: true,
          maxCustomers: await _getMaxCustomersForSlot(),
          availableSpots: await _getAvailableSpotsForSlot(timeString, date),
        ));
        
        // Increment time by minimum slot duration (15 minutes)
        currentMinute += 15;
        if (currentMinute >= 60) {
          currentMinute = 0;
          currentHour++;
        }
      }
    }
    
    return slots;
  }
  
  /// Get maximum customers allowed per slot
  static Future<int> _getMaxCustomersForSlot() async {
    final prefs = await SharedPreferences.getInstance();
    int maxCustomers = prefs.getInt('max_customers_per_slot') ?? 1;
    return maxCustomers;
  }
  
  /// Get available spots for a specific time slot
  static Future<int> _getAvailableSpotsForSlot(String time, DateTime date) async {
    // In real app, this would query appointments for this slot
    // For now, return max customers
    final maxCustomers = await _getMaxCustomersForSlot();
    
    // Mock: Check if slot is full (in real app, query database)
    final random = time.hashCode % 10;
    if (random == 0) {
      return 0; // Slot is full
    }
    
    return maxCustomers;
  }
  
  /// Calculate appointment end time based on treatment type
  static Future<DateTime> calculateEndTime({
    required DateTime startTime,
    required String treatmentType,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final configJson = prefs.getString('treatment_config_$treatmentType');
    
    int durationMinutes = 30; // Default
    
    if (configJson != null) {
      final config = TreatmentConfig.fromJson(jsonDecode(configJson));
      durationMinutes = config.durationMinutes;
    }
    
    return startTime.add(Duration(minutes: durationMinutes));
  }
  
  /// Check if a time slot is available for booking
  static Future<bool> isSlotAvailable({
    required String time,
    required DateTime date,
    required String treatmentType,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final configJson = prefs.getString('treatment_config_$treatmentType');
    
    if (configJson == null) return false;
    
    final config = TreatmentConfig.fromJson(jsonDecode(configJson));
    int maxCustomers = await _getMaxCustomersForSlot();
    
    // Check if treatment allows multiple patients
    if (!config.allowMultiplePatients) {
      maxCustomers = 1;
    }
    
    // Get current bookings for this slot
    final currentBookings = await _getBookingsForSlot(time, date);
    
    return currentBookings < maxCustomers;
  }
  
  /// Get current bookings for a time slot
  static Future<int> _getBookingsForSlot(String time, DateTime date) async {
    // In real app, query database
    // For now, return mock data
    return 0;
  }
  
  /// Get slot duration for a treatment type
  static Future<int> getSlotDuration(String treatmentType) async {
    final prefs = await SharedPreferences.getInstance();
    final configJson = prefs.getString('treatment_config_$treatmentType');
    
    if (configJson != null) {
      final config = TreatmentConfig.fromJson(jsonDecode(configJson));
      return config.durationMinutes;
    }
    
    return 30; // Default 30 minutes
  }
}

class TimeSlot {
  final String time;
  final DateTime date;
  final bool isAvailable;
  final int maxCustomers;
  final int availableSpots;
  
  TimeSlot({
    required this.time,
    required this.date,
    required this.isAvailable,
    required this.maxCustomers,
    required this.availableSpots,
  });
}

// Same TreatmentConfig as in the config page
class TreatmentConfig {
  int durationMinutes;
  bool allowMultiplePatients;
  int maxPatientsPerSlot;

  TreatmentConfig({
    this.durationMinutes = 30,
    this.allowMultiplePatients = false,
    this.maxPatientsPerSlot = 1,
  });

  Map<String, dynamic> toJson() {
    return {
      'durationMinutes': durationMinutes,
      'allowMultiplePatients': allowMultiplePatients,
      'maxPatientsPerSlot': maxPatientsPerSlot,
    };
  }

  factory TreatmentConfig.fromJson(Map<String, dynamic> json) {
    return TreatmentConfig(
      durationMinutes: json['durationMinutes'] ?? 30,
      allowMultiplePatients: json['allowMultiplePatients'] ?? false,
      maxPatientsPerSlot: json['maxPatientsPerSlot'] ?? 1,
    );
  }
}








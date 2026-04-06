import 'package:flutter/material.dart';

class AppConstants {
  // Supported Languages
  static const List<Locale> supportedLocales = [
    Locale('he', 'IL'), // Hebrew
    Locale('ar', 'IL'), // Arabic
    Locale('en', 'US'), // English
  ];
  
  // API Configuration
  static const String baseUrl = 'https://api.medical-appointments.com';
  static const String apiVersion = 'v1';
  static const Duration apiTimeout = Duration(seconds: 30);
  
  // User Roles
  static const String roleDeveloper = 'developer';
  static const String roleAdmin = 'admin';
  static const String roleDoctor = 'doctor';
  static const String roleParamedical = 'paramedical';
  static const String rolePatient = 'patient';
  static const String roleReceptionist = 'receptionist';
  
  // Medical and Paramedical Specialties
  static const List<String> medicalSpecialties = [
    // Medical Specialties
    'general_practitioner',
    'cardiologist',
    'neurologist',
    'orthopedist',
    'dermatologist',
    'gynecologist',
    'pediatrician',
    'psychiatrist',
    'ophthalmologist',
    'otolaryngologist',
    'urologist',
    'gastroenterologist',
    'endocrinologist',
    'pulmonologist',
    'rheumatologist',
    'oncologist',
    'anesthesiologist',
    'surgeon',
    'internal_medicine',
    'emergency_medicine',
    // Paramedical Specialties
    'osteopath',
    'physiotherapist',
    'dentist',
    'dental_hygienist',
    'massage_therapist',
    'acupuncturist',
    'psychologist',
    'nutritionist',
    'speech_therapist',
    'occupational_therapist',
    'chiropractor',
    'naturopath',
    'homeopath',
    'podiatrist',
    'optometrist',
    'audiologist',
    'radiologist_technician',
    'medical_laboratory_technician',
    'pharmacy_technician',
  ];
  
  // Appointment Status
  static const String statusScheduled = 'scheduled';
  static const String statusConfirmed = 'confirmed';
  static const String statusCompleted = 'completed';
  static const String statusCancelled = 'cancelled';
  static const String statusNoShow = 'no_show';
  static const String statusRescheduled = 'rescheduled';
  
  // Payment Status
  static const String paymentPending = 'pending';
  static const String paymentCompleted = 'completed';
  static const String paymentFailed = 'failed';
  static const String paymentRefunded = 'refunded';
  
  // Notification Types
  static const String notificationEmail = 'email';
  static const String notificationSMS = 'sms';
  static const String notificationWhatsApp = 'whatsapp';
  static const String notificationPush = 'push';
  
  // Cache Keys
  static const String cacheUser = 'user_cache';
  static const String cacheAppointments = 'appointments_cache';
  static const String cacheDoctors = 'doctors_cache';
  static const String cacheSettings = 'settings_cache';
  
  // Storage Keys
  static const String storageAuthToken = 'auth_token';
  static const String storageRefreshToken = 'refresh_token';
  static const String storageUserPreferences = 'user_preferences';
  static const String storageLanguage = 'language';
  static const String storageTheme = 'theme';
  
  // Validation Rules
  static const int minPasswordLength = 8;
  static const int maxPasswordLength = 128;
  static const int minPhoneLength = 10;
  static const int maxPhoneLength = 15;
  static const int maxNameLength = 100;
  static const int maxDescriptionLength = 1000;
  
  // Business Rules
  static const Duration defaultAppointmentDuration = Duration(minutes: 30);
  static const Duration minAdvanceBookingTime = Duration(hours: 2);
  static const Duration maxAdvanceBookingTime = Duration(days: 90);
  static const Duration defaultCancellationWindow = Duration(hours: 24);
  
  // UI Constants
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double borderRadius = 12.0;
  static const double cardElevation = 2.0;
  
  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);
  
  // Error Messages
  static const String errorNetworkConnection = 'שגיאת חיבור רשת';
  static const String errorServerError = 'אירעה שגיאת שרת';
  static const String errorUnauthorized = 'גישה לא מורשית';
  static const String errorForbidden = 'גישה אסורה';
  static const String errorNotFound = 'המשאב לא נמצא';
  static const String errorValidation = 'שגיאת אימות';
  static const String errorUnknown = 'אירעה שגיאה לא ידועה';
  
  // Success Messages
  static const String successAppointmentBooked = 'התור נקבע בהצלחה';
  static const String successAppointmentCancelled = 'התור בוטל בהצלחה';
  static const String successAppointmentRescheduled = 'התור נדחה בהצלחה';
  static const String successPaymentCompleted = 'התשלום הושלם בהצלחה';
  static const String successProfileUpdated = 'הפרופיל עודכן בהצלחה';
  
  // Israeli Holidays (for calendar integration)
  static const List<String> israeliHolidays = [
    '2024-01-01', // New Year
    '2024-03-25', // Purim
    '2024-04-22', // Passover
    '2024-05-14', // Independence Day
    '2024-06-11', // Shavuot
    '2024-09-15', // Rosh Hashanah
    '2024-09-24', // Yom Kippur
    '2024-09-29', // Sukkot
    '2024-10-06', // Simchat Torah
    '2024-12-25', // Christmas
  ];
}

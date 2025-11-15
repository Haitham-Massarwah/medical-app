import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../features/auth/data/models/auth_models.dart';
import '../../features/appointments/data/models/appointment_models.dart';
import '../../features/doctors/data/models/doctor_models.dart';
import '../../features/patients/data/models/patient_models.dart';
import '../../features/payments/data/models/payment_models.dart';
import '../../features/notifications/data/models/notification_models.dart';

part 'api_client.g.dart';

@RestApi()
abstract class ApiClient {
  factory ApiClient(Dio dio, {String baseUrl}) = _ApiClient;

  // Auth Endpoints
  @POST('/auth/login')
  Future<AuthResponse> login(@Body() LoginRequest request);

  @POST('/auth/register')
  Future<AuthResponse> register(@Body() RegisterRequest request);

  @POST('/auth/refresh')
  Future<AuthResponse> refreshToken(@Body() RefreshTokenRequest request);

  @POST('/auth/logout')
  Future<void> logout();

  @POST('/auth/forgot-password')
  Future<void> forgotPassword(@Body() ForgotPasswordRequest request);

  @POST('/auth/reset-password')
  Future<void> resetPassword(@Body() ResetPasswordRequest request);

  @POST('/auth/verify-email')
  Future<void> verifyEmail(@Body() VerifyEmailRequest request);

  @POST('/auth/resend-verification')
  Future<void> resendVerification(@Body() ResendVerificationRequest request);

  // User Profile Endpoints
  @GET('/user/profile')
  Future<UserModel> getProfile();

  @PUT('/user/profile')
  Future<UserModel> updateProfile(@Body() UpdateProfileRequest request);

  @POST('/user/change-password')
  Future<void> changePassword(@Body() ChangePasswordRequest request);

  @POST('/user/enable-2fa')
  Future<TwoFactorSetupResponse> enableTwoFactor();

  @POST('/user/verify-2fa')
  Future<void> verifyTwoFactor(@Body() VerifyTwoFactorRequest request);

  // Doctors Endpoints
  @GET('/doctors')
  Future<PaginatedResponse<DoctorModel>> getDoctors(@Queries() Map<String, dynamic> query);

  @GET('/doctors/{id}')
  Future<DoctorModel> getDoctor(@Path('id') String id);

  @GET('/doctors/{id}/availability')
  Future<AvailabilityResponse> getDoctorAvailability(
    @Path('id') String id,
    @Queries() Map<String, dynamic> query,
  );

  @PUT('/doctors/{id}/availability')
  Future<void> updateDoctorAvailability(
    @Path('id') String id,
    @Body() UpdateAvailabilityRequest request,
  );

  @GET('/doctors/{id}/services')
  Future<List<ServiceModel>> getDoctorServices(@Path('id') String id);

  @GET('/doctors/{id}/reviews')
  Future<PaginatedResponse<ReviewModel>> getDoctorReviews(
    @Path('id') String id,
    @Queries() Map<String, dynamic> query,
  );

  // Appointments Endpoints
  @GET('/appointments')
  Future<PaginatedResponse<AppointmentModel>> getAppointments(@Queries() Map<String, dynamic> query);

  @GET('/appointments/{id}')
  Future<AppointmentModel> getAppointment(@Path('id') String id);

  @POST('/appointments')
  Future<AppointmentModel> bookAppointment(@Body() BookAppointmentRequest request);

  @PUT('/appointments/{id}')
  Future<AppointmentModel> updateAppointment(
    @Path('id') String id,
    @Body() UpdateAppointmentRequest request,
  );

  @DELETE('/appointments/{id}')
  Future<void> cancelAppointment(@Path('id') String id);

  @POST('/appointments/{id}/reschedule')
  Future<AppointmentModel> rescheduleAppointment(
    @Path('id') String id,
    @Body() RescheduleAppointmentRequest request,
  );

  @POST('/appointments/{id}/confirm')
  Future<void> confirmAppointment(@Path('id') String id);

  @POST('/appointments/{id}/no-show')
  Future<void> markNoShow(@Path('id') String id);

  // Patients Endpoints
  @GET('/patients')
  Future<PaginatedResponse<PatientModel>> getPatients(@Queries() Map<String, dynamic> query);

  @GET('/patients/{id}')
  Future<PatientModel> getPatient(@Path('id') String id);

  @POST('/patients')
  Future<PatientModel> createPatient(@Body() CreatePatientRequest request);

  @PUT('/patients/{id}')
  Future<PatientModel> updatePatient(
    @Path('id') String id,
    @Body() UpdatePatientRequest request,
  );

  @GET('/patients/{id}/appointments')
  Future<PaginatedResponse<AppointmentModel>> getPatientAppointments(
    @Path('id') String id,
    @Queries() Map<String, dynamic> query,
  );

  @GET('/patients/{id}/medical-history')
  Future<List<MedicalRecordModel>> getPatientMedicalHistory(@Path('id') String id);

  @POST('/patients/{id}/medical-history')
  Future<MedicalRecordModel> addMedicalRecord(
    @Path('id') String id,
    @Body() CreateMedicalRecordRequest request,
  );

  // Payments Endpoints
  @GET('/payments')
  Future<PaginatedResponse<PaymentModel>> getPayments(@Queries() Map<String, dynamic> query);

  @GET('/payments/{id}')
  Future<PaymentModel> getPayment(@Path('id') String id);

  @POST('/payments')
  Future<PaymentModel> createPayment(@Body() CreatePaymentRequest request);

  @POST('/payments/{id}/process')
  Future<PaymentModel> processPayment(@Path('id') String id);

  @POST('/payments/{id}/refund')
  Future<PaymentModel> refundPayment(
    @Path('id') String id,
    @Body() RefundPaymentRequest request,
  );

  @GET('/payments/{id}/receipt')
  Future<ReceiptModel> getReceipt(@Path('id') String id);

  // Notifications Endpoints
  @GET('/notifications')
  Future<PaginatedResponse<NotificationModel>> getNotifications(@Queries() Map<String, dynamic> query);

  @GET('/notifications/{id}')
  Future<NotificationModel> getNotification(@Path('id') String id);

  @POST('/notifications')
  Future<NotificationModel> sendNotification(@Body() SendNotificationRequest request);

  @PUT('/notifications/{id}/read')
  Future<void> markNotificationAsRead(@Path('id') String id);

  @PUT('/notifications/{id}/unread')
  Future<void> markNotificationAsUnread(@Path('id') String id);

  @DELETE('/notifications/{id}')
  Future<void> deleteNotification(@Path('id') String id);

  // Settings Endpoints
  @GET('/settings')
  Future<SettingsModel> getSettings();

  @PUT('/settings')
  Future<SettingsModel> updateSettings(@Body() UpdateSettingsRequest request);

  @GET('/settings/cancellation-policies')
  Future<List<CancellationPolicyModel>> getCancellationPolicies();

  @POST('/settings/cancellation-policies')
  Future<CancellationPolicyModel> createCancellationPolicy(@Body() CreateCancellationPolicyRequest request);

  @PUT('/settings/cancellation-policies/{id}')
  Future<CancellationPolicyModel> updateCancellationPolicy(
    @Path('id') String id,
    @Body() UpdateCancellationPolicyRequest request,
  );

  @DELETE('/settings/cancellation-policies/{id}')
  Future<void> deleteCancellationPolicy(@Path('id') String id);

  // Analytics Endpoints
  @GET('/analytics/appointments')
  Future<AppointmentAnalyticsModel> getAppointmentAnalytics(@Queries() Map<String, dynamic> query);

  @GET('/analytics/revenue')
  Future<RevenueAnalyticsModel> getRevenueAnalytics(@Queries() Map<String, dynamic> query);

  @GET('/analytics/no-shows')
  Future<NoShowAnalyticsModel> getNoShowAnalytics(@Queries() Map<String, dynamic> query);

  // File Upload Endpoints
  @POST('/files/upload')
  @MultiPart()
  Future<FileUploadResponse> uploadFile(@Part() File file);

  @GET('/files/{id}')
  Future<List<int>> downloadFile(@Path('id') String id);

  @DELETE('/files/{id}')
  Future<void> deleteFile(@Path('id') String id);

  // Search Endpoints
  @GET('/search/doctors')
  Future<PaginatedResponse<DoctorModel>> searchDoctors(@Queries() Map<String, dynamic> query);

  @GET('/search/services')
  Future<List<ServiceModel>> searchServices(@Queries() Map<String, dynamic> query);

  @GET('/search/locations')
  Future<List<LocationModel>> searchLocations(@Queries() Map<String, dynamic> query);

  // Calendar Integration Endpoints
  @GET('/calendar/google/auth-url')
  Future<GoogleAuthUrlResponse> getGoogleAuthUrl();

  @POST('/calendar/google/callback')
  Future<void> handleGoogleCalendarCallback(@Body() GoogleCallbackRequest request);

  @GET('/calendar/outlook/auth-url')
  Future<OutlookAuthUrlResponse> getOutlookAuthUrl();

  @POST('/calendar/outlook/callback')
  Future<void> handleOutlookCalendarCallback(@Body() OutlookCallbackRequest request);

  @GET('/calendar/sync')
  Future<void> syncCalendar();

  // Telehealth Endpoints
  @POST('/telehealth/sessions')
  Future<TelehealthSessionModel> createTelehealthSession(@Body() CreateTelehealthSessionRequest request);

  @GET('/telehealth/sessions/{id}')
  Future<TelehealthSessionModel> getTelehealthSession(@Path('id') String id);

  @POST('/telehealth/sessions/{id}/join')
  Future<TelehealthJoinResponse> joinTelehealthSession(@Path('id') String id);

  @POST('/telehealth/sessions/{id}/end')
  Future<void> endTelehealthSession(@Path('id') String id);

  // Admin Endpoints
  @GET('/admin/users')
  Future<PaginatedResponse<UserModel>> getUsers(@Queries() Map<String, dynamic> query);

  @GET('/admin/tenants')
  Future<PaginatedResponse<TenantModel>> getTenants(@Queries() Map<String, dynamic> query);

  @POST('/admin/tenants')
  Future<TenantModel> createTenant(@Body() CreateTenantRequest request);

  @PUT('/admin/tenants/{id}')
  Future<TenantModel> updateTenant(
    @Path('id') String id,
    @Body() UpdateTenantRequest request,
  );

  @DELETE('/admin/tenants/{id}')
  Future<void> deleteTenant(@Path('id') String id);

  @GET('/admin/audit-logs')
  Future<PaginatedResponse<AuditLogModel>> getAuditLogs(@Queries() Map<String, dynamic> query);

  @GET('/admin/system-health')
  Future<SystemHealthModel> getSystemHealth();
}

// Common Response Models
@JsonSerializable()
class PaginatedResponse<T> {
  final List<T> data;
  final int total;
  final int page;
  final int limit;
  final bool hasNext;
  final bool hasPrev;

  PaginatedResponse({
    required this.data,
    required this.total,
    required this.page,
    required this.limit,
    required this.hasNext,
    required this.hasPrev,
  });

  factory PaginatedResponse.fromJson(Map<String, dynamic> json, T Function(Object? json) fromJsonT) =>
      _$PaginatedResponseFromJson(json, fromJsonT);
}

@JsonSerializable()
class ErrorResponse {
  final String message;
  final String? code;
  final Map<String, dynamic>? details;

  ErrorResponse({
    required this.message,
    this.code,
    this.details,
  });

  factory ErrorResponse.fromJson(Map<String, dynamic> json) => _$ErrorResponseFromJson(json);
}

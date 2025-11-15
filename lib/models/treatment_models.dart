import 'package:json_annotation/json_annotation.dart';

part 'treatment_models.g.dart';

// Treatment Type Model
@JsonSerializable()
class TreatmentTypeModel {
  final String id;
  final String name;
  final String description;
  final Duration duration;
  final double price;
  final String currency;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const TreatmentTypeModel({
    required this.id,
    required this.name,
    required this.description,
    required this.duration,
    required this.price,
    this.currency = 'ILS',
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TreatmentTypeModel.fromJson(Map<String, dynamic> json) => _$TreatmentTypeModelFromJson(json);
  Map<String, dynamic> toJson() => _$TreatmentTypeModelToJson(this);
}

// Doctor Treatment Settings Model
@JsonSerializable()
class DoctorTreatmentSettingsModel {
  final String id;
  final String doctorId;
  final List<String> treatmentTypeIds;
  final Map<String, Duration> treatmentDurations; // treatmentTypeId -> duration
  final Map<String, double> treatmentPrices; // treatmentTypeId -> price
  final List<BreakPeriodModel> breakPeriods;
  final BookingApprovalType approvalType;
  final PaymentTiming paymentTiming;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const DoctorTreatmentSettingsModel({
    required this.id,
    required this.doctorId,
    required this.treatmentTypeIds,
    required this.treatmentDurations,
    required this.treatmentPrices,
    required this.breakPeriods,
    required this.approvalType,
    required this.paymentTiming,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  factory DoctorTreatmentSettingsModel.fromJson(Map<String, dynamic> json) => _$DoctorTreatmentSettingsModelFromJson(json);
  Map<String, dynamic> toJson() => _$DoctorTreatmentSettingsModelToJson(this);
}

// Break Period Model
@JsonSerializable()
class BreakPeriodModel {
  final String id;
  final String doctorId;
  final DateTime startTime;
  final DateTime endTime;
  final String reason;
  final bool isRecurring;
  final int? dayOfWeek; // 0 = Sunday, 1 = Monday, etc. for recurring breaks
  final bool isActive;

  const BreakPeriodModel({
    required this.id,
    required this.doctorId,
    required this.startTime,
    required this.endTime,
    required this.reason,
    this.isRecurring = false,
    this.dayOfWeek,
    this.isActive = true,
  });

  factory BreakPeriodModel.fromJson(Map<String, dynamic> json) => _$BreakPeriodModelFromJson(json);
  Map<String, dynamic> toJson() => _$BreakPeriodModelToJson(this);
}

// Booking Approval Type
enum BookingApprovalType {
  @JsonValue('immediate')
  immediate,
  @JsonValue('manual')
  manual,
}

// Payment Timing
enum PaymentTiming {
  @JsonValue('at_booking')
  atBooking,
  @JsonValue('after_treatment')
  afterTreatment,
}

// Treatment Session Model
@JsonSerializable()
class TreatmentSessionModel {
  final String id;
  final String appointmentId;
  final String doctorId;
  final String patientId;
  final String treatmentTypeId;
  final DateTime startTime;
  final DateTime? endTime;
  final TreatmentSessionStatus status;
  final String? notes;
  final Map<String, dynamic>? treatmentData;
  final DateTime createdAt;
  final DateTime updatedAt;

  const TreatmentSessionModel({
    required this.id,
    required this.appointmentId,
    required this.doctorId,
    required this.patientId,
    required this.treatmentTypeId,
    required this.startTime,
    this.endTime,
    required this.status,
    this.notes,
    this.treatmentData,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TreatmentSessionModel.fromJson(Map<String, dynamic> json) => _$TreatmentSessionModelFromJson(json);
  Map<String, dynamic> toJson() => _$TreatmentSessionModelToJson(this);
}

// Treatment Session Status
enum TreatmentSessionStatus {
  @JsonValue('scheduled')
  scheduled,
  @JsonValue('in_progress')
  inProgress,
  @JsonValue('completed')
  completed,
  @JsonValue('cancelled')
  cancelled,
}

// Location Model
@JsonSerializable()
class LocationModel {
  final String id;
  final String name;
  final String address;
  final String city;
  final String country;
  final double latitude;
  final double longitude;
  final String? phone;
  final String? email;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const LocationModel({
    required this.id,
    required this.name,
    required this.address,
    required this.city,
    required this.country,
    required this.latitude,
    required this.longitude,
    this.phone,
    this.email,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  factory LocationModel.fromJson(Map<String, dynamic> json) => _$LocationModelFromJson(json);
  Map<String, dynamic> toJson() => _$LocationModelToJson(this);
}

// Search Filters Model
@JsonSerializable()
class DoctorSearchFiltersModel {
  final String? locationId;
  final String? specialty;
  final String? name;
  final double? minRating;
  final double? maxPrice;
  final List<String>? treatmentTypes;
  final DateTime? availableFrom;
  final DateTime? availableTo;

  const DoctorSearchFiltersModel({
    this.locationId,
    this.specialty,
    this.name,
    this.minRating,
    this.maxPrice,
    this.treatmentTypes,
    this.availableFrom,
    this.availableTo,
  });

  factory DoctorSearchFiltersModel.fromJson(Map<String, dynamic> json) => _$DoctorSearchFiltersModelFromJson(json);
  Map<String, dynamic> toJson() => _$DoctorSearchFiltersModelToJson(this);
}

// Request Models
@JsonSerializable()
class UpdateDoctorTreatmentSettingsRequest {
  final List<String> treatmentTypeIds;
  final Map<String, Duration> treatmentDurations;
  final Map<String, double> treatmentPrices;
  final List<BreakPeriodModel> breakPeriods;
  final BookingApprovalType approvalType;
  final PaymentTiming paymentTiming;

  const UpdateDoctorTreatmentSettingsRequest({
    required this.treatmentTypeIds,
    required this.treatmentDurations,
    required this.treatmentPrices,
    required this.breakPeriods,
    required this.approvalType,
    required this.paymentTiming,
  });

  factory UpdateDoctorTreatmentSettingsRequest.fromJson(Map<String, dynamic> json) => _$UpdateDoctorTreatmentSettingsRequestFromJson(json);
  Map<String, dynamic> toJson() => _$UpdateDoctorTreatmentSettingsRequestToJson(this);
}

@JsonSerializable()
class CompleteTreatmentSessionRequest {
  final String sessionId;
  final String? notes;
  final Map<String, dynamic>? treatmentData;

  const CompleteTreatmentSessionRequest({
    required this.sessionId,
    this.notes,
    this.treatmentData,
  });

  factory CompleteTreatmentSessionRequest.fromJson(Map<String, dynamic> json) => _$CompleteTreatmentSessionRequestFromJson(json);
  Map<String, dynamic> toJson() => _$CompleteTreatmentSessionRequestToJson(this);
}

@JsonSerializable()
class RequestPaymentRequest {
  final String appointmentId;
  final String sessionId;
  final double amount;
  final String currency;
  final String? message;

  const RequestPaymentRequest({
    required this.appointmentId,
    required this.sessionId,
    required this.amount,
    this.currency = 'ILS',
    this.message,
  });

  factory RequestPaymentRequest.fromJson(Map<String, dynamic> json) => _$RequestPaymentRequestFromJson(json);
  Map<String, dynamic> toJson() => _$RequestPaymentRequestToJson(this);
}








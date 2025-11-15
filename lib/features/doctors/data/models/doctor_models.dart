import 'package:json_annotation/json_annotation.dart';

part 'doctor_models.g.dart';

// Doctor Model
@JsonSerializable()
class DoctorModel {
  final String id;
  final String userId;
  final String specialty;
  final String? licenseNumber;
  final String? education;
  final List<String> languages;
  final String? bio;
  final String? profileImage;
  final double rating;
  final int reviewCount;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const DoctorModel({
    required this.id,
    required this.userId,
    required this.specialty,
    this.licenseNumber,
    this.education,
    this.languages = const [],
    this.bio,
    this.profileImage,
    this.rating = 0.0,
    this.reviewCount = 0,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  factory DoctorModel.fromJson(Map<String, dynamic> json) => _$DoctorModelFromJson(json);
  Map<String, dynamic> toJson() => _$DoctorModelToJson(this);
}

// Service Model
@JsonSerializable()
class ServiceModel {
  final String id;
  final String doctorId;
  final String name;
  final String description;
  final Duration duration;
  final double price;
  final String currency;
  final bool isActive;

  const ServiceModel({
    required this.id,
    required this.doctorId,
    required this.name,
    required this.description,
    required this.duration,
    required this.price,
    this.currency = 'ILS',
    this.isActive = true,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) => _$ServiceModelFromJson(json);
  Map<String, dynamic> toJson() => _$ServiceModelToJson(this);
}

// Availability Model
@JsonSerializable()
class AvailabilityModel {
  final String id;
  final String doctorId;
  final int dayOfWeek; // 0 = Sunday, 1 = Monday, etc.
  final String startTime; // HH:mm format
  final String endTime; // HH:mm format
  final bool isActive;

  const AvailabilityModel({
    required this.id,
    required this.doctorId,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    this.isActive = true,
  });

  factory AvailabilityModel.fromJson(Map<String, dynamic> json) => _$AvailabilityModelFromJson(json);
  Map<String, dynamic> toJson() => _$AvailabilityModelToJson(this);
}

// Review Model
@JsonSerializable()
class ReviewModel {
  final String id;
  final String doctorId;
  final String patientId;
  final int rating;
  final String? comment;
  final DateTime createdAt;

  const ReviewModel({
    required this.id,
    required this.doctorId,
    required this.patientId,
    required this.rating,
    this.comment,
    required this.createdAt,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) => _$ReviewModelFromJson(json);
  Map<String, dynamic> toJson() => _$ReviewModelToJson(this);
}

// Request Models
@JsonSerializable()
class UpdateAvailabilityRequest {
  final List<AvailabilityModel> availability;

  const UpdateAvailabilityRequest({
    required this.availability,
  });

  factory UpdateAvailabilityRequest.fromJson(Map<String, dynamic> json) => _$UpdateAvailabilityRequestFromJson(json);
  Map<String, dynamic> toJson() => _$UpdateAvailabilityRequestToJson(this);
}

// Response Models
@JsonSerializable()
class AvailabilityResponse {
  final List<AvailabilityModel> availability;
  final List<DateTime> blockedDates;
  final List<DateTime> availableSlots;

  const AvailabilityResponse({
    required this.availability,
    required this.blockedDates,
    required this.availableSlots,
  });

  factory AvailabilityResponse.fromJson(Map<String, dynamic> json) => _$AvailabilityResponseFromJson(json);
  Map<String, dynamic> toJson() => _$AvailabilityResponseToJson(this);
}

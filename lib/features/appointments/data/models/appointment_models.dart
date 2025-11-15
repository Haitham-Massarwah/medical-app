import 'package:json_annotation/json_annotation.dart';

part 'appointment_models.g.dart';

// Appointment Status
enum AppointmentStatus {
  @JsonValue('scheduled')
  scheduled,
  @JsonValue('confirmed')
  confirmed,
  @JsonValue('completed')
  completed,
  @JsonValue('cancelled')
  cancelled,
  @JsonValue('no_show')
  noShow,
  @JsonValue('rescheduled')
  rescheduled,
}

// Appointment Model
@JsonSerializable()
class AppointmentModel {
  final String id;
  final String patientId;
  final String doctorId;
  final DateTime appointmentDate;
  final Duration duration;
  final AppointmentStatus status;
  final String? notes;
  final String? location;
  final bool isTelehealth;
  final String? telehealthLink;
  final DateTime createdAt;
  final DateTime updatedAt;

  const AppointmentModel({
    required this.id,
    required this.patientId,
    required this.doctorId,
    required this.appointmentDate,
    required this.duration,
    required this.status,
    this.notes,
    this.location,
    this.isTelehealth = false,
    this.telehealthLink,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AppointmentModel.fromJson(Map<String, dynamic> json) => _$AppointmentModelFromJson(json);
  Map<String, dynamic> toJson() => _$AppointmentModelToJson(this);
}

// Request Models
@JsonSerializable()
class BookAppointmentRequest {
  final String doctorId;
  final DateTime appointmentDate;
  final Duration duration;
  final String? notes;
  final String? location;
  final bool isTelehealth;

  const BookAppointmentRequest({
    required this.doctorId,
    required this.appointmentDate,
    required this.duration,
    this.notes,
    this.location,
    this.isTelehealth = false,
  });

  factory BookAppointmentRequest.fromJson(Map<String, dynamic> json) => _$BookAppointmentRequestFromJson(json);
  Map<String, dynamic> toJson() => _$BookAppointmentRequestToJson(this);
}

@JsonSerializable()
class UpdateAppointmentRequest {
  final DateTime? appointmentDate;
  final Duration? duration;
  final String? notes;
  final String? location;
  final bool? isTelehealth;

  const UpdateAppointmentRequest({
    this.appointmentDate,
    this.duration,
    this.notes,
    this.location,
    this.isTelehealth,
  });

  factory UpdateAppointmentRequest.fromJson(Map<String, dynamic> json) => _$UpdateAppointmentRequestFromJson(json);
  Map<String, dynamic> toJson() => _$UpdateAppointmentRequestToJson(this);
}

@JsonSerializable()
class RescheduleAppointmentRequest {
  final DateTime newAppointmentDate;
  final Duration? duration;
  final String? reason;

  const RescheduleAppointmentRequest({
    required this.newAppointmentDate,
    this.duration,
    this.reason,
  });

  factory RescheduleAppointmentRequest.fromJson(Map<String, dynamic> json) => _$RescheduleAppointmentRequestFromJson(json);
  Map<String, dynamic> toJson() => _$RescheduleAppointmentRequestToJson(this);
}

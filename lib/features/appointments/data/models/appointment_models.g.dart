// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'appointment_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AppointmentModel _$AppointmentModelFromJson(Map<String, dynamic> json) =>
    AppointmentModel(
      id: json['id'] as String,
      patientId: json['patientId'] as String,
      doctorId: json['doctorId'] as String,
      appointmentDate: DateTime.parse(json['appointmentDate'] as String),
      duration: Duration(microseconds: (json['duration'] as num).toInt()),
      status: $enumDecode(_$AppointmentStatusEnumMap, json['status']),
      notes: json['notes'] as String?,
      location: json['location'] as String?,
      isTelehealth: json['isTelehealth'] as bool? ?? false,
      telehealthLink: json['telehealthLink'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$AppointmentModelToJson(AppointmentModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'patientId': instance.patientId,
      'doctorId': instance.doctorId,
      'appointmentDate': instance.appointmentDate.toIso8601String(),
      'duration': instance.duration.inMicroseconds,
      'status': _$AppointmentStatusEnumMap[instance.status]!,
      'notes': instance.notes,
      'location': instance.location,
      'isTelehealth': instance.isTelehealth,
      'telehealthLink': instance.telehealthLink,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

const _$AppointmentStatusEnumMap = {
  AppointmentStatus.scheduled: 'scheduled',
  AppointmentStatus.confirmed: 'confirmed',
  AppointmentStatus.completed: 'completed',
  AppointmentStatus.cancelled: 'cancelled',
  AppointmentStatus.noShow: 'no_show',
  AppointmentStatus.rescheduled: 'rescheduled',
};

BookAppointmentRequest _$BookAppointmentRequestFromJson(
        Map<String, dynamic> json) =>
    BookAppointmentRequest(
      doctorId: json['doctorId'] as String,
      appointmentDate: DateTime.parse(json['appointmentDate'] as String),
      duration: Duration(microseconds: (json['duration'] as num).toInt()),
      notes: json['notes'] as String?,
      location: json['location'] as String?,
      isTelehealth: json['isTelehealth'] as bool? ?? false,
    );

Map<String, dynamic> _$BookAppointmentRequestToJson(
        BookAppointmentRequest instance) =>
    <String, dynamic>{
      'doctorId': instance.doctorId,
      'appointmentDate': instance.appointmentDate.toIso8601String(),
      'duration': instance.duration.inMicroseconds,
      'notes': instance.notes,
      'location': instance.location,
      'isTelehealth': instance.isTelehealth,
    };

UpdateAppointmentRequest _$UpdateAppointmentRequestFromJson(
        Map<String, dynamic> json) =>
    UpdateAppointmentRequest(
      appointmentDate: json['appointmentDate'] == null
          ? null
          : DateTime.parse(json['appointmentDate'] as String),
      duration: json['duration'] == null
          ? null
          : Duration(microseconds: (json['duration'] as num).toInt()),
      notes: json['notes'] as String?,
      location: json['location'] as String?,
      isTelehealth: json['isTelehealth'] as bool?,
    );

Map<String, dynamic> _$UpdateAppointmentRequestToJson(
        UpdateAppointmentRequest instance) =>
    <String, dynamic>{
      'appointmentDate': instance.appointmentDate?.toIso8601String(),
      'duration': instance.duration?.inMicroseconds,
      'notes': instance.notes,
      'location': instance.location,
      'isTelehealth': instance.isTelehealth,
    };

RescheduleAppointmentRequest _$RescheduleAppointmentRequestFromJson(
        Map<String, dynamic> json) =>
    RescheduleAppointmentRequest(
      newAppointmentDate: DateTime.parse(json['newAppointmentDate'] as String),
      duration: json['duration'] == null
          ? null
          : Duration(microseconds: (json['duration'] as num).toInt()),
      reason: json['reason'] as String?,
    );

Map<String, dynamic> _$RescheduleAppointmentRequestToJson(
        RescheduleAppointmentRequest instance) =>
    <String, dynamic>{
      'newAppointmentDate': instance.newAppointmentDate.toIso8601String(),
      'duration': instance.duration?.inMicroseconds,
      'reason': instance.reason,
    };

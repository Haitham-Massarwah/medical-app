// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'patient_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PatientModel _$PatientModelFromJson(Map<String, dynamic> json) => PatientModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      emergencyContact: json['emergencyContact'] as String?,
      emergencyPhone: json['emergencyPhone'] as String?,
      allergies: (json['allergies'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      medications: (json['medications'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      insuranceProvider: json['insuranceProvider'] as String?,
      insuranceNumber: json['insuranceNumber'] as String?,
      medicalHistory: json['medicalHistory'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$PatientModelToJson(PatientModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'emergencyContact': instance.emergencyContact,
      'emergencyPhone': instance.emergencyPhone,
      'allergies': instance.allergies,
      'medications': instance.medications,
      'insuranceProvider': instance.insuranceProvider,
      'insuranceNumber': instance.insuranceNumber,
      'medicalHistory': instance.medicalHistory,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

MedicalRecordModel _$MedicalRecordModelFromJson(Map<String, dynamic> json) =>
    MedicalRecordModel(
      id: json['id'] as String,
      patientId: json['patientId'] as String,
      doctorId: json['doctorId'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      recordDate: DateTime.parse(json['recordDate'] as String),
      diagnosis: json['diagnosis'] as String?,
      treatment: json['treatment'] as String?,
      attachments: (json['attachments'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$MedicalRecordModelToJson(MedicalRecordModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'patientId': instance.patientId,
      'doctorId': instance.doctorId,
      'title': instance.title,
      'description': instance.description,
      'recordDate': instance.recordDate.toIso8601String(),
      'diagnosis': instance.diagnosis,
      'treatment': instance.treatment,
      'attachments': instance.attachments,
      'createdAt': instance.createdAt.toIso8601String(),
    };

CreatePatientRequest _$CreatePatientRequestFromJson(
        Map<String, dynamic> json) =>
    CreatePatientRequest(
      userId: json['userId'] as String,
      emergencyContact: json['emergencyContact'] as String?,
      emergencyPhone: json['emergencyPhone'] as String?,
      allergies: (json['allergies'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      medications: (json['medications'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      insuranceProvider: json['insuranceProvider'] as String?,
      insuranceNumber: json['insuranceNumber'] as String?,
    );

Map<String, dynamic> _$CreatePatientRequestToJson(
        CreatePatientRequest instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'emergencyContact': instance.emergencyContact,
      'emergencyPhone': instance.emergencyPhone,
      'allergies': instance.allergies,
      'medications': instance.medications,
      'insuranceProvider': instance.insuranceProvider,
      'insuranceNumber': instance.insuranceNumber,
    };

UpdatePatientRequest _$UpdatePatientRequestFromJson(
        Map<String, dynamic> json) =>
    UpdatePatientRequest(
      emergencyContact: json['emergencyContact'] as String?,
      emergencyPhone: json['emergencyPhone'] as String?,
      allergies: (json['allergies'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      medications: (json['medications'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      insuranceProvider: json['insuranceProvider'] as String?,
      insuranceNumber: json['insuranceNumber'] as String?,
      medicalHistory: json['medicalHistory'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$UpdatePatientRequestToJson(
        UpdatePatientRequest instance) =>
    <String, dynamic>{
      'emergencyContact': instance.emergencyContact,
      'emergencyPhone': instance.emergencyPhone,
      'allergies': instance.allergies,
      'medications': instance.medications,
      'insuranceProvider': instance.insuranceProvider,
      'insuranceNumber': instance.insuranceNumber,
      'medicalHistory': instance.medicalHistory,
    };

CreateMedicalRecordRequest _$CreateMedicalRecordRequestFromJson(
        Map<String, dynamic> json) =>
    CreateMedicalRecordRequest(
      doctorId: json['doctorId'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      recordDate: DateTime.parse(json['recordDate'] as String),
      diagnosis: json['diagnosis'] as String?,
      treatment: json['treatment'] as String?,
      attachments: (json['attachments'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
    );

Map<String, dynamic> _$CreateMedicalRecordRequestToJson(
        CreateMedicalRecordRequest instance) =>
    <String, dynamic>{
      'doctorId': instance.doctorId,
      'title': instance.title,
      'description': instance.description,
      'recordDate': instance.recordDate.toIso8601String(),
      'diagnosis': instance.diagnosis,
      'treatment': instance.treatment,
      'attachments': instance.attachments,
    };

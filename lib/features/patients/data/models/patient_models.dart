import 'package:json_annotation/json_annotation.dart';

part 'patient_models.g.dart';

// Patient Model
@JsonSerializable()
class PatientModel {
  final String id;
  final String userId;
  final String? emergencyContact;
  final String? emergencyPhone;
  final List<String> allergies;
  final List<String> medications;
  final String? insuranceProvider;
  final String? insuranceNumber;
  final Map<String, dynamic>? medicalHistory;
  final DateTime createdAt;
  final DateTime updatedAt;

  const PatientModel({
    required this.id,
    required this.userId,
    this.emergencyContact,
    this.emergencyPhone,
    this.allergies = const [],
    this.medications = const [],
    this.insuranceProvider,
    this.insuranceNumber,
    this.medicalHistory,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PatientModel.fromJson(Map<String, dynamic> json) => _$PatientModelFromJson(json);
  Map<String, dynamic> toJson() => _$PatientModelToJson(this);
}

// Medical Record Model
@JsonSerializable()
class MedicalRecordModel {
  final String id;
  final String patientId;
  final String doctorId;
  final String title;
  final String description;
  final DateTime recordDate;
  final String? diagnosis;
  final String? treatment;
  final List<String> attachments;
  final DateTime createdAt;

  const MedicalRecordModel({
    required this.id,
    required this.patientId,
    required this.doctorId,
    required this.title,
    required this.description,
    required this.recordDate,
    this.diagnosis,
    this.treatment,
    this.attachments = const [],
    required this.createdAt,
  });

  factory MedicalRecordModel.fromJson(Map<String, dynamic> json) => _$MedicalRecordModelFromJson(json);
  Map<String, dynamic> toJson() => _$MedicalRecordModelToJson(this);
}

// Request Models
@JsonSerializable()
class CreatePatientRequest {
  final String userId;
  final String? emergencyContact;
  final String? emergencyPhone;
  final List<String> allergies;
  final List<String> medications;
  final String? insuranceProvider;
  final String? insuranceNumber;

  const CreatePatientRequest({
    required this.userId,
    this.emergencyContact,
    this.emergencyPhone,
    this.allergies = const [],
    this.medications = const [],
    this.insuranceProvider,
    this.insuranceNumber,
  });

  factory CreatePatientRequest.fromJson(Map<String, dynamic> json) => _$CreatePatientRequestFromJson(json);
  Map<String, dynamic> toJson() => _$CreatePatientRequestToJson(this);
}

@JsonSerializable()
class UpdatePatientRequest {
  final String? emergencyContact;
  final String? emergencyPhone;
  final List<String>? allergies;
  final List<String>? medications;
  final String? insuranceProvider;
  final String? insuranceNumber;
  final Map<String, dynamic>? medicalHistory;

  const UpdatePatientRequest({
    this.emergencyContact,
    this.emergencyPhone,
    this.allergies,
    this.medications,
    this.insuranceProvider,
    this.insuranceNumber,
    this.medicalHistory,
  });

  factory UpdatePatientRequest.fromJson(Map<String, dynamic> json) => _$UpdatePatientRequestFromJson(json);
  Map<String, dynamic> toJson() => _$UpdatePatientRequestToJson(this);
}

@JsonSerializable()
class CreateMedicalRecordRequest {
  final String doctorId;
  final String title;
  final String description;
  final DateTime recordDate;
  final String? diagnosis;
  final String? treatment;
  final List<String> attachments;

  const CreateMedicalRecordRequest({
    required this.doctorId,
    required this.title,
    required this.description,
    required this.recordDate,
    this.diagnosis,
    this.treatment,
    this.attachments = const [],
  });

  factory CreateMedicalRecordRequest.fromJson(Map<String, dynamic> json) => _$CreateMedicalRecordRequestFromJson(json);
  Map<String, dynamic> toJson() => _$CreateMedicalRecordRequestToJson(this);
}

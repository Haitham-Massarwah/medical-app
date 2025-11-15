// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'doctor_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DoctorModel _$DoctorModelFromJson(Map<String, dynamic> json) => DoctorModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      specialty: json['specialty'] as String,
      licenseNumber: json['licenseNumber'] as String?,
      education: json['education'] as String?,
      languages: (json['languages'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      bio: json['bio'] as String?,
      profileImage: json['profileImage'] as String?,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: (json['reviewCount'] as num?)?.toInt() ?? 0,
      isActive: json['isActive'] as bool? ?? true,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$DoctorModelToJson(DoctorModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'specialty': instance.specialty,
      'licenseNumber': instance.licenseNumber,
      'education': instance.education,
      'languages': instance.languages,
      'bio': instance.bio,
      'profileImage': instance.profileImage,
      'rating': instance.rating,
      'reviewCount': instance.reviewCount,
      'isActive': instance.isActive,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

ServiceModel _$ServiceModelFromJson(Map<String, dynamic> json) => ServiceModel(
      id: json['id'] as String,
      doctorId: json['doctorId'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      duration: Duration(microseconds: (json['duration'] as num).toInt()),
      price: (json['price'] as num).toDouble(),
      currency: json['currency'] as String? ?? 'ILS',
      isActive: json['isActive'] as bool? ?? true,
    );

Map<String, dynamic> _$ServiceModelToJson(ServiceModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'doctorId': instance.doctorId,
      'name': instance.name,
      'description': instance.description,
      'duration': instance.duration.inMicroseconds,
      'price': instance.price,
      'currency': instance.currency,
      'isActive': instance.isActive,
    };

AvailabilityModel _$AvailabilityModelFromJson(Map<String, dynamic> json) =>
    AvailabilityModel(
      id: json['id'] as String,
      doctorId: json['doctorId'] as String,
      dayOfWeek: (json['dayOfWeek'] as num).toInt(),
      startTime: json['startTime'] as String,
      endTime: json['endTime'] as String,
      isActive: json['isActive'] as bool? ?? true,
    );

Map<String, dynamic> _$AvailabilityModelToJson(AvailabilityModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'doctorId': instance.doctorId,
      'dayOfWeek': instance.dayOfWeek,
      'startTime': instance.startTime,
      'endTime': instance.endTime,
      'isActive': instance.isActive,
    };

ReviewModel _$ReviewModelFromJson(Map<String, dynamic> json) => ReviewModel(
      id: json['id'] as String,
      doctorId: json['doctorId'] as String,
      patientId: json['patientId'] as String,
      rating: (json['rating'] as num).toInt(),
      comment: json['comment'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$ReviewModelToJson(ReviewModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'doctorId': instance.doctorId,
      'patientId': instance.patientId,
      'rating': instance.rating,
      'comment': instance.comment,
      'createdAt': instance.createdAt.toIso8601String(),
    };

UpdateAvailabilityRequest _$UpdateAvailabilityRequestFromJson(
        Map<String, dynamic> json) =>
    UpdateAvailabilityRequest(
      availability: (json['availability'] as List<dynamic>)
          .map((e) => AvailabilityModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$UpdateAvailabilityRequestToJson(
        UpdateAvailabilityRequest instance) =>
    <String, dynamic>{
      'availability': instance.availability,
    };

AvailabilityResponse _$AvailabilityResponseFromJson(
        Map<String, dynamic> json) =>
    AvailabilityResponse(
      availability: (json['availability'] as List<dynamic>)
          .map((e) => AvailabilityModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      blockedDates: (json['blockedDates'] as List<dynamic>)
          .map((e) => DateTime.parse(e as String))
          .toList(),
      availableSlots: (json['availableSlots'] as List<dynamic>)
          .map((e) => DateTime.parse(e as String))
          .toList(),
    );

Map<String, dynamic> _$AvailabilityResponseToJson(
        AvailabilityResponse instance) =>
    <String, dynamic>{
      'availability': instance.availability,
      'blockedDates':
          instance.blockedDates.map((e) => e.toIso8601String()).toList(),
      'availableSlots':
          instance.availableSlots.map((e) => e.toIso8601String()).toList(),
    };

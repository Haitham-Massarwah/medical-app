// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'treatment_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TreatmentTypeModel _$TreatmentTypeModelFromJson(Map<String, dynamic> json) =>
    TreatmentTypeModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      duration: Duration(microseconds: (json['duration'] as num).toInt()),
      price: (json['price'] as num).toDouble(),
      currency: json['currency'] as String? ?? 'ILS',
      isActive: json['isActive'] as bool? ?? true,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$TreatmentTypeModelToJson(TreatmentTypeModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'duration': instance.duration.inMicroseconds,
      'price': instance.price,
      'currency': instance.currency,
      'isActive': instance.isActive,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

DoctorTreatmentSettingsModel _$DoctorTreatmentSettingsModelFromJson(
        Map<String, dynamic> json) =>
    DoctorTreatmentSettingsModel(
      id: json['id'] as String,
      doctorId: json['doctorId'] as String,
      treatmentTypeIds: (json['treatmentTypeIds'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      treatmentDurations:
          (json['treatmentDurations'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(k, Duration(microseconds: (e as num).toInt())),
      ),
      treatmentPrices: (json['treatmentPrices'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(k, (e as num).toDouble()),
      ),
      breakPeriods: (json['breakPeriods'] as List<dynamic>)
          .map((e) => BreakPeriodModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      approvalType:
          $enumDecode(_$BookingApprovalTypeEnumMap, json['approvalType']),
      paymentTiming: $enumDecode(_$PaymentTimingEnumMap, json['paymentTiming']),
      isActive: json['isActive'] as bool? ?? true,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$DoctorTreatmentSettingsModelToJson(
        DoctorTreatmentSettingsModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'doctorId': instance.doctorId,
      'treatmentTypeIds': instance.treatmentTypeIds,
      'treatmentDurations': instance.treatmentDurations
          .map((k, e) => MapEntry(k, e.inMicroseconds)),
      'treatmentPrices': instance.treatmentPrices,
      'breakPeriods': instance.breakPeriods,
      'approvalType': _$BookingApprovalTypeEnumMap[instance.approvalType]!,
      'paymentTiming': _$PaymentTimingEnumMap[instance.paymentTiming]!,
      'isActive': instance.isActive,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

const _$BookingApprovalTypeEnumMap = {
  BookingApprovalType.immediate: 'immediate',
  BookingApprovalType.manual: 'manual',
};

const _$PaymentTimingEnumMap = {
  PaymentTiming.atBooking: 'at_booking',
  PaymentTiming.afterTreatment: 'after_treatment',
};

BreakPeriodModel _$BreakPeriodModelFromJson(Map<String, dynamic> json) =>
    BreakPeriodModel(
      id: json['id'] as String,
      doctorId: json['doctorId'] as String,
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: DateTime.parse(json['endTime'] as String),
      reason: json['reason'] as String,
      isRecurring: json['isRecurring'] as bool? ?? false,
      dayOfWeek: (json['dayOfWeek'] as num?)?.toInt(),
      isActive: json['isActive'] as bool? ?? true,
    );

Map<String, dynamic> _$BreakPeriodModelToJson(BreakPeriodModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'doctorId': instance.doctorId,
      'startTime': instance.startTime.toIso8601String(),
      'endTime': instance.endTime.toIso8601String(),
      'reason': instance.reason,
      'isRecurring': instance.isRecurring,
      'dayOfWeek': instance.dayOfWeek,
      'isActive': instance.isActive,
    };

TreatmentSessionModel _$TreatmentSessionModelFromJson(
        Map<String, dynamic> json) =>
    TreatmentSessionModel(
      id: json['id'] as String,
      appointmentId: json['appointmentId'] as String,
      doctorId: json['doctorId'] as String,
      patientId: json['patientId'] as String,
      treatmentTypeId: json['treatmentTypeId'] as String,
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: json['endTime'] == null
          ? null
          : DateTime.parse(json['endTime'] as String),
      status: $enumDecode(_$TreatmentSessionStatusEnumMap, json['status']),
      notes: json['notes'] as String?,
      treatmentData: json['treatmentData'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$TreatmentSessionModelToJson(
        TreatmentSessionModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'appointmentId': instance.appointmentId,
      'doctorId': instance.doctorId,
      'patientId': instance.patientId,
      'treatmentTypeId': instance.treatmentTypeId,
      'startTime': instance.startTime.toIso8601String(),
      'endTime': instance.endTime?.toIso8601String(),
      'status': _$TreatmentSessionStatusEnumMap[instance.status]!,
      'notes': instance.notes,
      'treatmentData': instance.treatmentData,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

const _$TreatmentSessionStatusEnumMap = {
  TreatmentSessionStatus.scheduled: 'scheduled',
  TreatmentSessionStatus.inProgress: 'in_progress',
  TreatmentSessionStatus.completed: 'completed',
  TreatmentSessionStatus.cancelled: 'cancelled',
};

LocationModel _$LocationModelFromJson(Map<String, dynamic> json) =>
    LocationModel(
      id: json['id'] as String,
      name: json['name'] as String,
      address: json['address'] as String,
      city: json['city'] as String,
      country: json['country'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      isActive: json['isActive'] as bool? ?? true,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$LocationModelToJson(LocationModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'address': instance.address,
      'city': instance.city,
      'country': instance.country,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'phone': instance.phone,
      'email': instance.email,
      'isActive': instance.isActive,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

DoctorSearchFiltersModel _$DoctorSearchFiltersModelFromJson(
        Map<String, dynamic> json) =>
    DoctorSearchFiltersModel(
      locationId: json['locationId'] as String?,
      specialty: json['specialty'] as String?,
      name: json['name'] as String?,
      minRating: (json['minRating'] as num?)?.toDouble(),
      maxPrice: (json['maxPrice'] as num?)?.toDouble(),
      treatmentTypes: (json['treatmentTypes'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      availableFrom: json['availableFrom'] == null
          ? null
          : DateTime.parse(json['availableFrom'] as String),
      availableTo: json['availableTo'] == null
          ? null
          : DateTime.parse(json['availableTo'] as String),
    );

Map<String, dynamic> _$DoctorSearchFiltersModelToJson(
        DoctorSearchFiltersModel instance) =>
    <String, dynamic>{
      'locationId': instance.locationId,
      'specialty': instance.specialty,
      'name': instance.name,
      'minRating': instance.minRating,
      'maxPrice': instance.maxPrice,
      'treatmentTypes': instance.treatmentTypes,
      'availableFrom': instance.availableFrom?.toIso8601String(),
      'availableTo': instance.availableTo?.toIso8601String(),
    };

UpdateDoctorTreatmentSettingsRequest
    _$UpdateDoctorTreatmentSettingsRequestFromJson(Map<String, dynamic> json) =>
        UpdateDoctorTreatmentSettingsRequest(
          treatmentTypeIds: (json['treatmentTypeIds'] as List<dynamic>)
              .map((e) => e as String)
              .toList(),
          treatmentDurations:
              (json['treatmentDurations'] as Map<String, dynamic>).map(
            (k, e) => MapEntry(k, Duration(microseconds: (e as num).toInt())),
          ),
          treatmentPrices:
              (json['treatmentPrices'] as Map<String, dynamic>).map(
            (k, e) => MapEntry(k, (e as num).toDouble()),
          ),
          breakPeriods: (json['breakPeriods'] as List<dynamic>)
              .map((e) => BreakPeriodModel.fromJson(e as Map<String, dynamic>))
              .toList(),
          approvalType:
              $enumDecode(_$BookingApprovalTypeEnumMap, json['approvalType']),
          paymentTiming:
              $enumDecode(_$PaymentTimingEnumMap, json['paymentTiming']),
        );

Map<String, dynamic> _$UpdateDoctorTreatmentSettingsRequestToJson(
        UpdateDoctorTreatmentSettingsRequest instance) =>
    <String, dynamic>{
      'treatmentTypeIds': instance.treatmentTypeIds,
      'treatmentDurations': instance.treatmentDurations
          .map((k, e) => MapEntry(k, e.inMicroseconds)),
      'treatmentPrices': instance.treatmentPrices,
      'breakPeriods': instance.breakPeriods,
      'approvalType': _$BookingApprovalTypeEnumMap[instance.approvalType]!,
      'paymentTiming': _$PaymentTimingEnumMap[instance.paymentTiming]!,
    };

CompleteTreatmentSessionRequest _$CompleteTreatmentSessionRequestFromJson(
        Map<String, dynamic> json) =>
    CompleteTreatmentSessionRequest(
      sessionId: json['sessionId'] as String,
      notes: json['notes'] as String?,
      treatmentData: json['treatmentData'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$CompleteTreatmentSessionRequestToJson(
        CompleteTreatmentSessionRequest instance) =>
    <String, dynamic>{
      'sessionId': instance.sessionId,
      'notes': instance.notes,
      'treatmentData': instance.treatmentData,
    };

RequestPaymentRequest _$RequestPaymentRequestFromJson(
        Map<String, dynamic> json) =>
    RequestPaymentRequest(
      appointmentId: json['appointmentId'] as String,
      sessionId: json['sessionId'] as String,
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String? ?? 'ILS',
      message: json['message'] as String?,
    );

Map<String, dynamic> _$RequestPaymentRequestToJson(
        RequestPaymentRequest instance) =>
    <String, dynamic>{
      'appointmentId': instance.appointmentId,
      'sessionId': instance.sessionId,
      'amount': instance.amount,
      'currency': instance.currency,
      'message': instance.message,
    };

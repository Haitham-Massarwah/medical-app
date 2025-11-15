/// Simplified treatment models without JSON serialization dependencies
class TreatmentTypeModel {
  final String id;
  final String name;
  final String description;
  final Duration duration;
  final double price;
  final bool isActive;

  const TreatmentTypeModel({
    required this.id,
    required this.name,
    required this.description,
    required this.duration,
    required this.price,
    required this.isActive,
  });

  factory TreatmentTypeModel.fromJson(Map<String, dynamic> json) => TreatmentTypeModel(
    id: json['id'] as String,
    name: json['name'] as String,
    description: json['description'] as String,
    duration: Duration(minutes: json['durationMinutes'] as int),
    price: (json['price'] as num).toDouble(),
    isActive: json['isActive'] as bool,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'durationMinutes': duration.inMinutes,
    'price': price,
    'isActive': isActive,
  };
}

class DoctorTreatmentSettingsModel {
  final String doctorId;
  final List<TreatmentTypeModel> treatmentTypes;
  final List<BreakPeriodModel> breakPeriods;
  final bool autoApproveAppointments;
  final PaymentTiming defaultPaymentTiming;

  const DoctorTreatmentSettingsModel({
    required this.doctorId,
    required this.treatmentTypes,
    required this.breakPeriods,
    required this.autoApproveAppointments,
    required this.defaultPaymentTiming,
  });

  factory DoctorTreatmentSettingsModel.fromJson(Map<String, dynamic> json) => DoctorTreatmentSettingsModel(
    doctorId: json['doctorId'] as String,
    treatmentTypes: (json['treatmentTypes'] as List).map((e) => TreatmentTypeModel.fromJson(e)).toList(),
    breakPeriods: (json['breakPeriods'] as List).map((e) => BreakPeriodModel.fromJson(e)).toList(),
    autoApproveAppointments: json['autoApproveAppointments'] as bool,
    defaultPaymentTiming: PaymentTiming.values.firstWhere((e) => e.toString() == json['defaultPaymentTiming']),
  );

  Map<String, dynamic> toJson() => {
    'doctorId': doctorId,
    'treatmentTypes': treatmentTypes.map((e) => e.toJson()).toList(),
    'breakPeriods': breakPeriods.map((e) => e.toJson()).toList(),
    'autoApproveAppointments': autoApproveAppointments,
    'defaultPaymentTiming': defaultPaymentTiming.toString(),
  };
}

class BreakPeriodModel {
  final String id;
  final String name;
  final DateTime startTime;
  final DateTime endTime;
  final List<int> daysOfWeek; // 0 = Sunday, 1 = Monday, etc.
  final bool isRecurring;

  const BreakPeriodModel({
    required this.id,
    required this.name,
    required this.startTime,
    required this.endTime,
    required this.daysOfWeek,
    required this.isRecurring,
  });

  factory BreakPeriodModel.fromJson(Map<String, dynamic> json) => BreakPeriodModel(
    id: json['id'] as String,
    name: json['name'] as String,
    startTime: DateTime.parse(json['startTime'] as String),
    endTime: DateTime.parse(json['endTime'] as String),
    daysOfWeek: (json['daysOfWeek'] as List).map((e) => e as int).toList(),
    isRecurring: json['isRecurring'] as bool,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'startTime': startTime.toIso8601String(),
    'endTime': endTime.toIso8601String(),
    'daysOfWeek': daysOfWeek,
    'isRecurring': isRecurring,
  };
}

class TreatmentSessionModel {
  final String id;
  final String doctorId;
  final String patientId;
  final String treatmentTypeId;
  final DateTime startTime;
  final DateTime? endTime;
  final TreatmentSessionStatus status;
  final Map<String, dynamic>? treatmentData;
  final String? notes;

  const TreatmentSessionModel({
    required this.id,
    required this.doctorId,
    required this.patientId,
    required this.treatmentTypeId,
    required this.startTime,
    this.endTime,
    required this.status,
    this.treatmentData,
    this.notes,
  });

  factory TreatmentSessionModel.fromJson(Map<String, dynamic> json) => TreatmentSessionModel(
    id: json['id'] as String,
    doctorId: json['doctorId'] as String,
    patientId: json['patientId'] as String,
    treatmentTypeId: json['treatmentTypeId'] as String,
    startTime: DateTime.parse(json['startTime'] as String),
    endTime: json['endTime'] != null ? DateTime.parse(json['endTime'] as String) : null,
    status: TreatmentSessionStatus.values.firstWhere((e) => e.toString() == json['status']),
    treatmentData: json['treatmentData'] as Map<String, dynamic>?,
    notes: json['notes'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'doctorId': doctorId,
    'patientId': patientId,
    'treatmentTypeId': treatmentTypeId,
    'startTime': startTime.toIso8601String(),
    'endTime': endTime?.toIso8601String(),
    'status': status.toString(),
    'treatmentData': treatmentData,
    'notes': notes,
  };
}

class LocationModel {
  final String id;
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final String city;
  final String country;

  const LocationModel({
    required this.id,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.city,
    required this.country,
  });

  factory LocationModel.fromJson(Map<String, dynamic> json) => LocationModel(
    id: json['id'] as String,
    name: json['name'] as String,
    address: json['address'] as String,
    latitude: (json['latitude'] as num).toDouble(),
    longitude: (json['longitude'] as num).toDouble(),
    city: json['city'] as String,
    country: json['country'] as String,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'address': address,
    'latitude': latitude,
    'longitude': longitude,
    'city': city,
    'country': country,
  };
}

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

  factory UpdateDoctorTreatmentSettingsRequest.fromJson(Map<String, dynamic> json) => UpdateDoctorTreatmentSettingsRequest(
    treatmentTypeIds: (json['treatmentTypeIds'] as List).map((e) => e as String).toList(),
    treatmentDurations: (json['treatmentDurations'] as Map).map((k, v) => MapEntry(k as String, Duration(minutes: v as int))),
    treatmentPrices: (json['treatmentPrices'] as Map).map((k, v) => MapEntry(k as String, (v as num).toDouble())),
    breakPeriods: (json['breakPeriods'] as List).map((e) => BreakPeriodModel.fromJson(e)).toList(),
    approvalType: BookingApprovalType.values.firstWhere((e) => e.toString() == json['approvalType']),
    paymentTiming: PaymentTiming.values.firstWhere((e) => e.toString() == json['paymentTiming']),
  );

  Map<String, dynamic> toJson() => {
    'treatmentTypeIds': treatmentTypeIds,
    'treatmentDurations': treatmentDurations.map((k, v) => MapEntry(k, v.inMinutes)),
    'treatmentPrices': treatmentPrices,
    'breakPeriods': breakPeriods.map((e) => e.toJson()).toList(),
    'approvalType': approvalType.toString(),
    'paymentTiming': paymentTiming.toString(),
  };
}

class CompleteTreatmentSessionRequest {
  final String sessionId;
  final String? notes;
  final Map<String, dynamic>? treatmentData;

  const CompleteTreatmentSessionRequest({
    required this.sessionId,
    this.notes,
    this.treatmentData,
  });

  factory CompleteTreatmentSessionRequest.fromJson(Map<String, dynamic> json) => CompleteTreatmentSessionRequest(
    sessionId: json['sessionId'] as String,
    notes: json['notes'] as String?,
    treatmentData: json['treatmentData'] as Map<String, dynamic>?,
  );

  Map<String, dynamic> toJson() => {
    'sessionId': sessionId,
    'notes': notes,
    'treatmentData': treatmentData,
  };
}

class RequestPaymentRequest {
  final String sessionId;
  final String appointmentId;
  final double amount;
  final String currency;
  final String description;

  const RequestPaymentRequest({
    required this.sessionId,
    required this.appointmentId,
    required this.amount,
    required this.currency,
    required this.description,
  });

  factory RequestPaymentRequest.fromJson(Map<String, dynamic> json) => RequestPaymentRequest(
    sessionId: json['sessionId'] as String,
    appointmentId: json['appointmentId'] as String,
    amount: (json['amount'] as num).toDouble(),
    currency: json['currency'] as String,
    description: json['description'] as String,
  );

  Map<String, dynamic> toJson() => {
    'sessionId': sessionId,
    'appointmentId': appointmentId,
    'amount': amount,
    'currency': currency,
    'description': description,
  };
}

enum TreatmentSessionStatus {
  scheduled,
  inProgress,
  completed,
  cancelled,
}

enum BookingApprovalType {
  immediate,
  manual,
}

enum PaymentTiming {
  atBooking,
  afterTreatment,
}

class Appointment {
  final String id;
  final String patientName;
  final String time;
  final int duration;
  final String type;
  final String status;
  final String paymentStatus;
  final double amount;
  final String? patientId;
  final String? treatmentTypeId;
  final String? notes;

  const Appointment({
    required this.id,
    required this.patientName,
    required this.time,
    required this.duration,
    required this.type,
    required this.status,
    required this.paymentStatus,
    required this.amount,
    this.patientId,
    this.treatmentTypeId,
    this.notes,
  });
}

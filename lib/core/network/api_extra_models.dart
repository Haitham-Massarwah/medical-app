/// DTOs used by [ApiClient] that are not tied to feature `*_models.dart` files.
/// Manual JSON mapping keeps Retrofit codegen simple without extra `.g.dart` runs.

class SettingsModel {
  final Map<String, dynamic> json;
  SettingsModel(this.json);
  factory SettingsModel.fromJson(Map<String, dynamic> json) =>
      SettingsModel(Map<String, dynamic>.from(json));
  Map<String, dynamic> toJson() => json;
}

class UpdateSettingsRequest {
  final Map<String, dynamic> settings;
  const UpdateSettingsRequest({required this.settings});
  factory UpdateSettingsRequest.fromJson(Map<String, dynamic> json) =>
      UpdateSettingsRequest(settings: Map<String, dynamic>.from(json));
  Map<String, dynamic> toJson() => settings;
}

class CancellationPolicyModel {
  final String id;
  final String name;
  final Map<String, dynamic>? rules;
  const CancellationPolicyModel({
    required this.id,
    required this.name,
    this.rules,
  });
  factory CancellationPolicyModel.fromJson(Map<String, dynamic> json) =>
      CancellationPolicyModel(
        id: json['id']?.toString() ?? '',
        name: json['name']?.toString() ?? '',
        rules: json['rules'] is Map<String, dynamic>
            ? Map<String, dynamic>.from(json['rules'] as Map)
            : null,
      );
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        if (rules != null) 'rules': rules,
      };
}

class CreateCancellationPolicyRequest {
  final String name;
  final Map<String, dynamic>? rules;
  const CreateCancellationPolicyRequest({required this.name, this.rules});
  factory CreateCancellationPolicyRequest.fromJson(Map<String, dynamic> json) =>
      CreateCancellationPolicyRequest(
        name: json['name']?.toString() ?? '',
        rules: json['rules'] is Map<String, dynamic>
            ? Map<String, dynamic>.from(json['rules'] as Map)
            : null,
      );
  Map<String, dynamic> toJson() => {
        'name': name,
        if (rules != null) 'rules': rules,
      };
}

class UpdateCancellationPolicyRequest {
  final String? name;
  final Map<String, dynamic>? rules;
  const UpdateCancellationPolicyRequest({this.name, this.rules});
  factory UpdateCancellationPolicyRequest.fromJson(Map<String, dynamic> json) =>
      UpdateCancellationPolicyRequest(
        name: json['name']?.toString(),
        rules: json['rules'] is Map<String, dynamic>
            ? Map<String, dynamic>.from(json['rules'] as Map)
            : null,
      );
  Map<String, dynamic> toJson() => {
        if (name != null) 'name': name,
        if (rules != null) 'rules': rules,
      };
}

class AppointmentAnalyticsModel {
  final Map<String, dynamic> json;
  AppointmentAnalyticsModel(this.json);
  factory AppointmentAnalyticsModel.fromJson(Map<String, dynamic> json) =>
      AppointmentAnalyticsModel(Map<String, dynamic>.from(json));
  Map<String, dynamic> toJson() => json;
}

class RevenueAnalyticsModel {
  final Map<String, dynamic> json;
  RevenueAnalyticsModel(this.json);
  factory RevenueAnalyticsModel.fromJson(Map<String, dynamic> json) =>
      RevenueAnalyticsModel(Map<String, dynamic>.from(json));
  Map<String, dynamic> toJson() => json;
}

class NoShowAnalyticsModel {
  final Map<String, dynamic> json;
  NoShowAnalyticsModel(this.json);
  factory NoShowAnalyticsModel.fromJson(Map<String, dynamic> json) =>
      NoShowAnalyticsModel(Map<String, dynamic>.from(json));
  Map<String, dynamic> toJson() => json;
}

class FileUploadResponse {
  final String id;
  final String? url;
  const FileUploadResponse({required this.id, this.url});
  factory FileUploadResponse.fromJson(Map<String, dynamic> json) =>
      FileUploadResponse(
        id: json['id']?.toString() ?? '',
        url: json['url']?.toString(),
      );
  Map<String, dynamic> toJson() => {'id': id, if (url != null) 'url': url};
}

/// API search location (not treatment UI [LocationModel]).
class LocationModel {
  final String id;
  final String name;
  final String? address;
  const LocationModel({required this.id, required this.name, this.address});
  factory LocationModel.fromJson(Map<String, dynamic> json) => LocationModel(
        id: json['id']?.toString() ?? '',
        name: json['name']?.toString() ?? '',
        address: json['address']?.toString(),
      );
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        if (address != null) 'address': address,
      };
}

class GoogleAuthUrlResponse {
  final String url;
  const GoogleAuthUrlResponse({required this.url});
  factory GoogleAuthUrlResponse.fromJson(Map<String, dynamic> json) =>
      GoogleAuthUrlResponse(url: json['url']?.toString() ?? '');
  Map<String, dynamic> toJson() => {'url': url};
}

class GoogleCallbackRequest {
  final String code;
  final String? state;
  const GoogleCallbackRequest({required this.code, this.state});
  factory GoogleCallbackRequest.fromJson(Map<String, dynamic> json) =>
      GoogleCallbackRequest(
        code: json['code']?.toString() ?? '',
        state: json['state']?.toString(),
      );
  Map<String, dynamic> toJson() => {
        'code': code,
        if (state != null) 'state': state,
      };
}

class OutlookAuthUrlResponse {
  final String url;
  const OutlookAuthUrlResponse({required this.url});
  factory OutlookAuthUrlResponse.fromJson(Map<String, dynamic> json) =>
      OutlookAuthUrlResponse(url: json['url']?.toString() ?? '');
  Map<String, dynamic> toJson() => {'url': url};
}

class OutlookCallbackRequest {
  final String code;
  final String? state;
  const OutlookCallbackRequest({required this.code, this.state});
  factory OutlookCallbackRequest.fromJson(Map<String, dynamic> json) =>
      OutlookCallbackRequest(
        code: json['code']?.toString() ?? '',
        state: json['state']?.toString(),
      );
  Map<String, dynamic> toJson() => {
        'code': code,
        if (state != null) 'state': state,
      };
}

class TelehealthSessionModel {
  final String id;
  final String? joinUrl;
  const TelehealthSessionModel({required this.id, this.joinUrl});
  factory TelehealthSessionModel.fromJson(Map<String, dynamic> json) =>
      TelehealthSessionModel(
        id: json['id']?.toString() ?? '',
        joinUrl: json['joinUrl']?.toString() ?? json['join_url']?.toString(),
      );
  Map<String, dynamic> toJson() => {
        'id': id,
        if (joinUrl != null) 'joinUrl': joinUrl,
      };
}

class CreateTelehealthSessionRequest {
  final String appointmentId;
  const CreateTelehealthSessionRequest({required this.appointmentId});
  factory CreateTelehealthSessionRequest.fromJson(Map<String, dynamic> json) =>
      CreateTelehealthSessionRequest(
        appointmentId:
            json['appointmentId']?.toString() ?? json['appointment_id']?.toString() ?? '',
      );
  Map<String, dynamic> toJson() => {'appointmentId': appointmentId};
}

class TelehealthJoinResponse {
  final String token;
  final String? channelId;
  const TelehealthJoinResponse({required this.token, this.channelId});
  factory TelehealthJoinResponse.fromJson(Map<String, dynamic> json) =>
      TelehealthJoinResponse(
        token: json['token']?.toString() ?? '',
        channelId:
            json['channelId']?.toString() ?? json['channel_id']?.toString(),
      );
  Map<String, dynamic> toJson() => {
        'token': token,
        if (channelId != null) 'channelId': channelId,
      };
}

class AuditLogModel {
  final String id;
  final String action;
  final DateTime createdAt;
  final Map<String, dynamic>? metadata;
  const AuditLogModel({
    required this.id,
    required this.action,
    required this.createdAt,
    this.metadata,
  });
  factory AuditLogModel.fromJson(Map<String, dynamic> json) => AuditLogModel(
        id: json['id']?.toString() ?? '',
        action: json['action']?.toString() ?? '',
        createdAt: json['created_at'] != null
            ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
            : DateTime.now(),
        metadata: json['metadata'] is Map<String, dynamic>
            ? Map<String, dynamic>.from(json['metadata'] as Map)
            : null,
      );
  Map<String, dynamic> toJson() => {
        'id': id,
        'action': action,
        'created_at': createdAt.toIso8601String(),
        if (metadata != null) 'metadata': metadata,
      };
}

class SystemHealthModel {
  final String status;
  final Map<String, dynamic>? details;
  const SystemHealthModel({required this.status, this.details});
  factory SystemHealthModel.fromJson(Map<String, dynamic> json) =>
      SystemHealthModel(
        status: json['status']?.toString() ?? 'unknown',
        details: json['details'] is Map<String, dynamic>
            ? Map<String, dynamic>.from(json['details'] as Map)
            : null,
      );
  Map<String, dynamic> toJson() => {
        'status': status,
        if (details != null) 'details': details,
      };
}

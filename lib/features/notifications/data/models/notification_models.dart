import 'package:json_annotation/json_annotation.dart';

part 'notification_models.g.dart';

// Notification Type
enum NotificationType {
  @JsonValue('email')
  email,
  @JsonValue('sms')
  sms,
  @JsonValue('whatsapp')
  whatsapp,
  @JsonValue('push')
  push,
}

// Notification Model
@JsonSerializable()
class NotificationModel {
  final String id;
  final String userId;
  final String title;
  final String message;
  final NotificationType type;
  final bool isRead;
  final Map<String, dynamic>? data;
  final DateTime createdAt;
  final DateTime? readAt;

  const NotificationModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.message,
    required this.type,
    this.isRead = false,
    this.data,
    required this.createdAt,
    this.readAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) => _$NotificationModelFromJson(json);
  Map<String, dynamic> toJson() => _$NotificationModelToJson(this);
}

// Request Models
@JsonSerializable()
class SendNotificationRequest {
  final String userId;
  final String title;
  final String message;
  final NotificationType type;
  final Map<String, dynamic>? data;

  const SendNotificationRequest({
    required this.userId,
    required this.title,
    required this.message,
    required this.type,
    this.data,
  });

  factory SendNotificationRequest.fromJson(Map<String, dynamic> json) => _$SendNotificationRequestFromJson(json);
  Map<String, dynamic> toJson() => _$SendNotificationRequestToJson(this);
}

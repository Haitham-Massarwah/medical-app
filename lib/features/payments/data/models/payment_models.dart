import 'package:json_annotation/json_annotation.dart';

part 'payment_models.g.dart';

// Payment Status
enum PaymentStatus {
  @JsonValue('pending')
  pending,
  @JsonValue('completed')
  completed,
  @JsonValue('failed')
  failed,
  @JsonValue('refunded')
  refunded,
}

// Payment Method
enum PaymentMethod {
  @JsonValue('visa')
  visa,
  @JsonValue('mastercard')
  mastercard,
  @JsonValue('credit_card')
  creditCard,
  @JsonValue('debit_card')
  debitCard,
}

// Payment Model
@JsonSerializable()
class PaymentModel {
  final String id;
  final String appointmentId;
  final String patientId;
  final double amount;
  final String currency;
  final PaymentStatus status;
  final PaymentMethod method;
  final String? transactionId;
  final String? paymentIntentId;
  final String? failureReason;
  final DateTime createdAt;
  final DateTime updatedAt;

  const PaymentModel({
    required this.id,
    required this.appointmentId,
    required this.patientId,
    required this.amount,
    this.currency = 'ILS',
    required this.status,
    required this.method,
    this.transactionId,
    this.paymentIntentId,
    this.failureReason,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) => _$PaymentModelFromJson(json);
  Map<String, dynamic> toJson() => _$PaymentModelToJson(this);
}

// Receipt Model
@JsonSerializable()
class ReceiptModel {
  final String id;
  final String paymentId;
  final String patientName;
  final String doctorName;
  final String serviceName;
  final double amount;
  final String currency;
  final DateTime paymentDate;
  final String? invoiceNumber;
  final String? taxId;

  const ReceiptModel({
    required this.id,
    required this.paymentId,
    required this.patientName,
    required this.doctorName,
    required this.serviceName,
    required this.amount,
    this.currency = 'ILS',
    required this.paymentDate,
    this.invoiceNumber,
    this.taxId,
  });

  factory ReceiptModel.fromJson(Map<String, dynamic> json) => _$ReceiptModelFromJson(json);
  Map<String, dynamic> toJson() => _$ReceiptModelToJson(this);
}

// Request Models
@JsonSerializable()
class CreatePaymentRequest {
  final String appointmentId;
  final double amount;
  final String currency;
  final PaymentMethod method;
  final String? paymentIntentId;

  const CreatePaymentRequest({
    required this.appointmentId,
    required this.amount,
    this.currency = 'ILS',
    required this.method,
    this.paymentIntentId,
  });

  factory CreatePaymentRequest.fromJson(Map<String, dynamic> json) => _$CreatePaymentRequestFromJson(json);
  Map<String, dynamic> toJson() => _$CreatePaymentRequestToJson(this);
}

@JsonSerializable()
class RefundPaymentRequest {
  final double amount;
  final String reason;

  const RefundPaymentRequest({
    required this.amount,
    required this.reason,
  });

  factory RefundPaymentRequest.fromJson(Map<String, dynamic> json) => _$RefundPaymentRequestFromJson(json);
  Map<String, dynamic> toJson() => _$RefundPaymentRequestToJson(this);
}

// Card Details Model
@JsonSerializable()
class CardDetailsModel {
  final String number;
  final String expiryMonth;
  final String expiryYear;
  final String cvv;
  final String cardholderName;
  final PaymentMethod cardType;

  const CardDetailsModel({
    required this.number,
    required this.expiryMonth,
    required this.expiryYear,
    required this.cvv,
    required this.cardholderName,
    required this.cardType,
  });

  factory CardDetailsModel.fromJson(Map<String, dynamic> json) => _$CardDetailsModelFromJson(json);
  Map<String, dynamic> toJson() => _$CardDetailsModelToJson(this);
}

// Payment Gateway Response
@JsonSerializable()
class PaymentGatewayResponse {
  final bool success;
  final String? transactionId;
  final String? errorMessage;
  final Map<String, dynamic>? gatewayData;

  const PaymentGatewayResponse({
    required this.success,
    this.transactionId,
    this.errorMessage,
    this.gatewayData,
  });

  factory PaymentGatewayResponse.fromJson(Map<String, dynamic> json) => _$PaymentGatewayResponseFromJson(json);
  Map<String, dynamic> toJson() => _$PaymentGatewayResponseToJson(this);
}

// Payment Request Model
@JsonSerializable()
class PaymentRequestModel {
  final String appointmentId;
  final String patientId;
  final double amount;
  final String currency;
  final CardDetailsModel cardDetails;
  final PaymentTiming timing;
  final String? description;

  const PaymentRequestModel({
    required this.appointmentId,
    required this.patientId,
    required this.amount,
    this.currency = 'ILS',
    required this.cardDetails,
    required this.timing,
    this.description,
  });

  factory PaymentRequestModel.fromJson(Map<String, dynamic> json) => _$PaymentRequestModelFromJson(json);
  Map<String, dynamic> toJson() => _$PaymentRequestModelToJson(this);
}

// Payment Timing
enum PaymentTiming {
  @JsonValue('at_booking')
  atBooking,
  @JsonValue('after_treatment')
  afterTreatment,
}

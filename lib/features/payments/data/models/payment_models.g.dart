// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PaymentModel _$PaymentModelFromJson(Map<String, dynamic> json) => PaymentModel(
      id: json['id'] as String,
      appointmentId: json['appointmentId'] as String,
      patientId: json['patientId'] as String,
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String? ?? 'ILS',
      status: $enumDecode(_$PaymentStatusEnumMap, json['status']),
      method: $enumDecode(_$PaymentMethodEnumMap, json['method']),
      transactionId: json['transactionId'] as String?,
      paymentIntentId: json['paymentIntentId'] as String?,
      failureReason: json['failureReason'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$PaymentModelToJson(PaymentModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'appointmentId': instance.appointmentId,
      'patientId': instance.patientId,
      'amount': instance.amount,
      'currency': instance.currency,
      'status': _$PaymentStatusEnumMap[instance.status]!,
      'method': _$PaymentMethodEnumMap[instance.method]!,
      'transactionId': instance.transactionId,
      'paymentIntentId': instance.paymentIntentId,
      'failureReason': instance.failureReason,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

const _$PaymentStatusEnumMap = {
  PaymentStatus.pending: 'pending',
  PaymentStatus.completed: 'completed',
  PaymentStatus.failed: 'failed',
  PaymentStatus.refunded: 'refunded',
};

const _$PaymentMethodEnumMap = {
  PaymentMethod.visa: 'visa',
  PaymentMethod.mastercard: 'mastercard',
  PaymentMethod.creditCard: 'credit_card',
  PaymentMethod.debitCard: 'debit_card',
};

ReceiptModel _$ReceiptModelFromJson(Map<String, dynamic> json) => ReceiptModel(
      id: json['id'] as String,
      paymentId: json['paymentId'] as String,
      patientName: json['patientName'] as String,
      doctorName: json['doctorName'] as String,
      serviceName: json['serviceName'] as String,
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String? ?? 'ILS',
      paymentDate: DateTime.parse(json['paymentDate'] as String),
      invoiceNumber: json['invoiceNumber'] as String?,
      taxId: json['taxId'] as String?,
    );

Map<String, dynamic> _$ReceiptModelToJson(ReceiptModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'paymentId': instance.paymentId,
      'patientName': instance.patientName,
      'doctorName': instance.doctorName,
      'serviceName': instance.serviceName,
      'amount': instance.amount,
      'currency': instance.currency,
      'paymentDate': instance.paymentDate.toIso8601String(),
      'invoiceNumber': instance.invoiceNumber,
      'taxId': instance.taxId,
    };

CreatePaymentRequest _$CreatePaymentRequestFromJson(
        Map<String, dynamic> json) =>
    CreatePaymentRequest(
      appointmentId: json['appointmentId'] as String,
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String? ?? 'ILS',
      method: $enumDecode(_$PaymentMethodEnumMap, json['method']),
      paymentIntentId: json['paymentIntentId'] as String?,
    );

Map<String, dynamic> _$CreatePaymentRequestToJson(
        CreatePaymentRequest instance) =>
    <String, dynamic>{
      'appointmentId': instance.appointmentId,
      'amount': instance.amount,
      'currency': instance.currency,
      'method': _$PaymentMethodEnumMap[instance.method]!,
      'paymentIntentId': instance.paymentIntentId,
    };

RefundPaymentRequest _$RefundPaymentRequestFromJson(
        Map<String, dynamic> json) =>
    RefundPaymentRequest(
      amount: (json['amount'] as num).toDouble(),
      reason: json['reason'] as String,
    );

Map<String, dynamic> _$RefundPaymentRequestToJson(
        RefundPaymentRequest instance) =>
    <String, dynamic>{
      'amount': instance.amount,
      'reason': instance.reason,
    };

CardDetailsModel _$CardDetailsModelFromJson(Map<String, dynamic> json) =>
    CardDetailsModel(
      number: json['number'] as String,
      expiryMonth: json['expiryMonth'] as String,
      expiryYear: json['expiryYear'] as String,
      cvv: json['cvv'] as String,
      cardholderName: json['cardholderName'] as String,
      cardType: $enumDecode(_$PaymentMethodEnumMap, json['cardType']),
    );

Map<String, dynamic> _$CardDetailsModelToJson(CardDetailsModel instance) =>
    <String, dynamic>{
      'number': instance.number,
      'expiryMonth': instance.expiryMonth,
      'expiryYear': instance.expiryYear,
      'cvv': instance.cvv,
      'cardholderName': instance.cardholderName,
      'cardType': _$PaymentMethodEnumMap[instance.cardType]!,
    };

PaymentGatewayResponse _$PaymentGatewayResponseFromJson(
        Map<String, dynamic> json) =>
    PaymentGatewayResponse(
      success: json['success'] as bool,
      transactionId: json['transactionId'] as String?,
      errorMessage: json['errorMessage'] as String?,
      gatewayData: json['gatewayData'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$PaymentGatewayResponseToJson(
        PaymentGatewayResponse instance) =>
    <String, dynamic>{
      'success': instance.success,
      'transactionId': instance.transactionId,
      'errorMessage': instance.errorMessage,
      'gatewayData': instance.gatewayData,
    };

PaymentRequestModel _$PaymentRequestModelFromJson(Map<String, dynamic> json) =>
    PaymentRequestModel(
      appointmentId: json['appointmentId'] as String,
      patientId: json['patientId'] as String,
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String? ?? 'ILS',
      cardDetails: CardDetailsModel.fromJson(
          json['cardDetails'] as Map<String, dynamic>),
      timing: $enumDecode(_$PaymentTimingEnumMap, json['timing']),
      description: json['description'] as String?,
    );

Map<String, dynamic> _$PaymentRequestModelToJson(
        PaymentRequestModel instance) =>
    <String, dynamic>{
      'appointmentId': instance.appointmentId,
      'patientId': instance.patientId,
      'amount': instance.amount,
      'currency': instance.currency,
      'cardDetails': instance.cardDetails,
      'timing': _$PaymentTimingEnumMap[instance.timing]!,
      'description': instance.description,
    };

const _$PaymentTimingEnumMap = {
  PaymentTiming.atBooking: 'at_booking',
  PaymentTiming.afterTreatment: 'after_treatment',
};

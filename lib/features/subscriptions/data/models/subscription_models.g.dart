// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subscription_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SubscriptionPlan _$SubscriptionPlanFromJson(Map<String, dynamic> json) =>
    SubscriptionPlan(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      price: (json['price'] as num).toDouble(),
      currency: json['currency'] as String,
      interval: json['interval'] as String,
      intervalCount: (json['interval_count'] as num?)?.toInt() ?? 1,
      trialDays: (json['trial_days'] as num?)?.toInt() ?? 0,
      features: (json['features'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      maxAppointmentsPerMonth:
          (json['max_appointments_per_month'] as num).toInt(),
      isActive: json['is_active'] as bool? ?? true,
      isPopular: json['is_popular'] as bool? ?? false,
      stripePriceId: json['stripe_price_id'] as String?,
      stripeProductId: json['stripe_product_id'] as String?,
    );

Map<String, dynamic> _$SubscriptionPlanToJson(SubscriptionPlan instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'price': instance.price,
      'currency': instance.currency,
      'interval': instance.interval,
      'interval_count': instance.intervalCount,
      'trial_days': instance.trialDays,
      'features': instance.features,
      'max_appointments_per_month': instance.maxAppointmentsPerMonth,
      'is_active': instance.isActive,
      'is_popular': instance.isPopular,
      'stripe_price_id': instance.stripePriceId,
      'stripe_product_id': instance.stripeProductId,
    };

DoctorSubscription _$DoctorSubscriptionFromJson(Map<String, dynamic> json) =>
    DoctorSubscription(
      id: json['id'] as String,
      doctorId: json['doctor_id'] as String,
      tenantId: json['tenant_id'] as String,
      planId: json['plan_id'] as String,
      status: json['status'] as String,
      stripeSubscriptionId: json['stripe_subscription_id'] as String?,
      stripeCustomerId: json['stripe_customer_id'] as String?,
      currentPeriodStart: json['current_period_start'] == null
          ? null
          : DateTime.parse(json['current_period_start'] as String),
      currentPeriodEnd: json['current_period_end'] == null
          ? null
          : DateTime.parse(json['current_period_end'] as String),
      trialStart: json['trial_start'] == null
          ? null
          : DateTime.parse(json['trial_start'] as String),
      trialEnd: json['trial_end'] == null
          ? null
          : DateTime.parse(json['trial_end'] as String),
      canceledAt: json['canceled_at'] == null
          ? null
          : DateTime.parse(json['canceled_at'] as String),
      cancelAtPeriodEnd: json['cancel_at_period_end'] as bool? ?? false,
      plan: json['plan'] == null
          ? null
          : SubscriptionPlan.fromJson(json['plan'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$DoctorSubscriptionToJson(DoctorSubscription instance) =>
    <String, dynamic>{
      'id': instance.id,
      'doctor_id': instance.doctorId,
      'tenant_id': instance.tenantId,
      'plan_id': instance.planId,
      'status': instance.status,
      'stripe_subscription_id': instance.stripeSubscriptionId,
      'stripe_customer_id': instance.stripeCustomerId,
      'current_period_start': instance.currentPeriodStart?.toIso8601String(),
      'current_period_end': instance.currentPeriodEnd?.toIso8601String(),
      'trial_start': instance.trialStart?.toIso8601String(),
      'trial_end': instance.trialEnd?.toIso8601String(),
      'canceled_at': instance.canceledAt?.toIso8601String(),
      'cancel_at_period_end': instance.cancelAtPeriodEnd,
      'plan': instance.plan,
    };

SubscriptionTransaction _$SubscriptionTransactionFromJson(
        Map<String, dynamic> json) =>
    SubscriptionTransaction(
      id: json['id'] as String,
      subscriptionId: json['subscription_id'] as String,
      doctorId: json['doctor_id'] as String,
      tenantId: json['tenant_id'] as String,
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String,
      status: json['status'] as String,
      type: json['type'] as String,
      stripeInvoiceId: json['stripe_invoice_id'] as String?,
      stripePaymentIntentId: json['stripe_payment_intent_id'] as String?,
      stripeChargeId: json['stripe_charge_id'] as String?,
      failureReason: json['failure_reason'] as String?,
      paidAt: json['paid_at'] == null
          ? null
          : DateTime.parse(json['paid_at'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$SubscriptionTransactionToJson(
        SubscriptionTransaction instance) =>
    <String, dynamic>{
      'id': instance.id,
      'subscription_id': instance.subscriptionId,
      'doctor_id': instance.doctorId,
      'tenant_id': instance.tenantId,
      'amount': instance.amount,
      'currency': instance.currency,
      'status': instance.status,
      'type': instance.type,
      'stripe_invoice_id': instance.stripeInvoiceId,
      'stripe_payment_intent_id': instance.stripePaymentIntentId,
      'stripe_charge_id': instance.stripeChargeId,
      'failure_reason': instance.failureReason,
      'paid_at': instance.paidAt?.toIso8601String(),
      'created_at': instance.createdAt.toIso8601String(),
    };

SubscriptionUsage _$SubscriptionUsageFromJson(Map<String, dynamic> json) =>
    SubscriptionUsage(
      currentUsage: (json['current_usage'] as num).toInt(),
      limit: (json['limit'] as num).toInt(),
      unlimited: json['unlimited'] as bool,
      periodStart: json['period_start'] == null
          ? null
          : DateTime.parse(json['period_start'] as String),
      periodEnd: json['period_end'] == null
          ? null
          : DateTime.parse(json['period_end'] as String),
    );

Map<String, dynamic> _$SubscriptionUsageToJson(SubscriptionUsage instance) =>
    <String, dynamic>{
      'current_usage': instance.currentUsage,
      'limit': instance.limit,
      'unlimited': instance.unlimited,
      'period_start': instance.periodStart?.toIso8601String(),
      'period_end': instance.periodEnd?.toIso8601String(),
    };

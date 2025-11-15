import 'package:json_annotation/json_annotation.dart';

part 'subscription_models.g.dart';

/// Subscription Plan Model
@JsonSerializable()
class SubscriptionPlan {
  final String id;
  final String name;
  final String? description;
  final double price;
  final String currency;
  final String interval; // 'monthly', 'quarterly', 'yearly'
  @JsonKey(name: 'interval_count')
  final int intervalCount;
  @JsonKey(name: 'trial_days')
  final int trialDays;
  final List<String>? features;
  @JsonKey(name: 'max_appointments_per_month')
  final int maxAppointmentsPerMonth;
  @JsonKey(name: 'is_active')
  final bool isActive;
  @JsonKey(name: 'is_popular')
  final bool isPopular;
  @JsonKey(name: 'stripe_price_id')
  final String? stripePriceId;
  @JsonKey(name: 'stripe_product_id')
  final String? stripeProductId;

  SubscriptionPlan({
    required this.id,
    required this.name,
    this.description,
    required this.price,
    required this.currency,
    required this.interval,
    this.intervalCount = 1,
    this.trialDays = 0,
    this.features,
    required this.maxAppointmentsPerMonth,
    this.isActive = true,
    this.isPopular = false,
    this.stripePriceId,
    this.stripeProductId,
  });

  factory SubscriptionPlan.fromJson(Map<String, dynamic> json) =>
      _$SubscriptionPlanFromJson(json);

  Map<String, dynamic> toJson() => _$SubscriptionPlanToJson(this);

  String get priceDisplay => '$currency ${price.toStringAsFixed(2)}';
  
  String get intervalDisplay {
    switch (interval) {
      case 'monthly':
        return 'per month';
      case 'quarterly':
        return 'per quarter';
      case 'yearly':
        return 'per year';
      default:
        return interval;
    }
  }

  bool get isUnlimited => maxAppointmentsPerMonth == -1;
}

/// Doctor Subscription Model
@JsonSerializable()
class DoctorSubscription {
  final String id;
  @JsonKey(name: 'doctor_id')
  final String doctorId;
  @JsonKey(name: 'tenant_id')
  final String tenantId;
  @JsonKey(name: 'plan_id')
  final String planId;
  final String status;
  @JsonKey(name: 'stripe_subscription_id')
  final String? stripeSubscriptionId;
  @JsonKey(name: 'stripe_customer_id')
  final String? stripeCustomerId;
  @JsonKey(name: 'current_period_start')
  final DateTime? currentPeriodStart;
  @JsonKey(name: 'current_period_end')
  final DateTime? currentPeriodEnd;
  @JsonKey(name: 'trial_start')
  final DateTime? trialStart;
  @JsonKey(name: 'trial_end')
  final DateTime? trialEnd;
  @JsonKey(name: 'canceled_at')
  final DateTime? canceledAt;
  @JsonKey(name: 'cancel_at_period_end')
  final bool cancelAtPeriodEnd;
  final SubscriptionPlan? plan;

  DoctorSubscription({
    required this.id,
    required this.doctorId,
    required this.tenantId,
    required this.planId,
    required this.status,
    this.stripeSubscriptionId,
    this.stripeCustomerId,
    this.currentPeriodStart,
    this.currentPeriodEnd,
    this.trialStart,
    this.trialEnd,
    this.canceledAt,
    this.cancelAtPeriodEnd = false,
    this.plan,
  });

  factory DoctorSubscription.fromJson(Map<String, dynamic> json) =>
      _$DoctorSubscriptionFromJson(json);

  Map<String, dynamic> toJson() => _$DoctorSubscriptionToJson(this);

  bool get isActive => status == 'active' || status == 'trialing';
  bool get isTrialing => status == 'trialing';
  bool get isPastDue => status == 'past_due';
  bool get isCanceled => status == 'canceled';
}

/// Subscription Transaction Model
@JsonSerializable()
class SubscriptionTransaction {
  final String id;
  @JsonKey(name: 'subscription_id')
  final String subscriptionId;
  @JsonKey(name: 'doctor_id')
  final String doctorId;
  @JsonKey(name: 'tenant_id')
  final String tenantId;
  final double amount;
  final String currency;
  final String status;
  final String type;
  @JsonKey(name: 'stripe_invoice_id')
  final String? stripeInvoiceId;
  @JsonKey(name: 'stripe_payment_intent_id')
  final String? stripePaymentIntentId;
  @JsonKey(name: 'stripe_charge_id')
  final String? stripeChargeId;
  @JsonKey(name: 'failure_reason')
  final String? failureReason;
  @JsonKey(name: 'paid_at')
  final DateTime? paidAt;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  SubscriptionTransaction({
    required this.id,
    required this.subscriptionId,
    required this.doctorId,
    required this.tenantId,
    required this.amount,
    required this.currency,
    required this.status,
    required this.type,
    this.stripeInvoiceId,
    this.stripePaymentIntentId,
    this.stripeChargeId,
    this.failureReason,
    this.paidAt,
    required this.createdAt,
  });

  factory SubscriptionTransaction.fromJson(Map<String, dynamic> json) =>
      _$SubscriptionTransactionFromJson(json);

  Map<String, dynamic> toJson() => _$SubscriptionTransactionToJson(this);

  bool get isSuccessful => status == 'succeeded';
  bool get isFailed => status == 'failed';
  bool get isPending => status == 'pending';
}

/// Subscription Usage Model
@JsonSerializable()
class SubscriptionUsage {
  @JsonKey(name: 'current_usage')
  final int currentUsage;
  final int limit;
  final bool unlimited;
  @JsonKey(name: 'period_start')
  final DateTime? periodStart;
  @JsonKey(name: 'period_end')
  final DateTime? periodEnd;

  SubscriptionUsage({
    required this.currentUsage,
    required this.limit,
    required this.unlimited,
    this.periodStart,
    this.periodEnd,
  });

  factory SubscriptionUsage.fromJson(Map<String, dynamic> json) =>
      _$SubscriptionUsageFromJson(json);

  Map<String, dynamic> toJson() => _$SubscriptionUsageToJson(this);

  double get usagePercentage {
    if (unlimited || limit <= 0) return 0;
    return (currentUsage / limit * 100).clamp(0, 100);
  }

  bool get isNearLimit => usagePercentage >= 80;
  bool get hasReachedLimit => currentUsage >= limit && !unlimited;
}



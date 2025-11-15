import 'package:dio/dio.dart';
import '../models/subscription_models.dart';

class SubscriptionRemoteDatasource {
  final Dio _dio;
  final String _baseUrl;

  SubscriptionRemoteDatasource(this._dio, {String? baseUrl})
      : _baseUrl = baseUrl ?? '';

  /// Get all available subscription plans
  Future<List<SubscriptionPlan>> getPlans() async {
    try {
      final response = await _dio.get('$_baseUrl/subscriptions/plans');
      
      if (response.statusCode == 200 && response.data['success'] == true) {
        final List<dynamic> plansJson = response.data['data'];
        return plansJson.map((json) => SubscriptionPlan.fromJson(json)).toList();
      }
      
      throw Exception('Failed to load subscription plans');
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    }
  }

  /// Get a specific plan by ID
  Future<SubscriptionPlan> getPlanById(String planId) async {
    try {
      final response = await _dio.get('$_baseUrl/subscriptions/plans/$planId');
      
      if (response.statusCode == 200 && response.data['success'] == true) {
        return SubscriptionPlan.fromJson(response.data['data']);
      }
      
      throw Exception('Failed to load plan');
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    }
  }

  /// Create a new subscription
  Future<Map<String, dynamic>> createSubscription({
    required String planId,
    required String paymentMethodId,
  }) async {
    try {
      final response = await _dio.post(
        '$_baseUrl/subscriptions/subscribe',
        data: {
          'planId': planId,
          'paymentMethodId': paymentMethodId,
        },
      );
      
      if (response.statusCode == 201 && response.data['success'] == true) {
        return {
          'subscription': DoctorSubscription.fromJson(response.data['data']),
          'clientSecret': response.data['clientSecret'],
        };
      }
      
      throw Exception(response.data['message'] ?? 'Failed to create subscription');
    } on DioException catch (e) {
      final message = e.response?.data['message'] ?? e.message;
      throw Exception('Subscription error: $message');
    }
  }

  /// Get current doctor's subscription
  Future<DoctorSubscription?> getCurrentSubscription() async {
    try {
      final response = await _dio.get('$_baseUrl/subscriptions/current');
      
      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'];
        return data != null ? DoctorSubscription.fromJson(data) : null;
      }
      
      return null;
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return null;
      }
      throw Exception('Network error: ${e.message}');
    }
  }

  /// Cancel subscription
  Future<void> cancelSubscription({
    required String subscriptionId,
    bool cancelAtPeriodEnd = true,
  }) async {
    try {
      final response = await _dio.post(
        '$_baseUrl/subscriptions/cancel',
        data: {
          'subscriptionId': subscriptionId,
          'cancelAtPeriodEnd': cancelAtPeriodEnd,
        },
      );
      
      if (response.statusCode != 200 || response.data['success'] != true) {
        throw Exception(response.data['message'] ?? 'Failed to cancel subscription');
      }
    } on DioException catch (e) {
      final message = e.response?.data['message'] ?? e.message;
      throw Exception('Cancel error: $message');
    }
  }

  /// Resume a canceled subscription
  Future<void> resumeSubscription({required String subscriptionId}) async {
    try {
      final response = await _dio.post(
        '$_baseUrl/subscriptions/resume',
        data: {'subscriptionId': subscriptionId},
      );
      
      if (response.statusCode != 200 || response.data['success'] != true) {
        throw Exception(response.data['message'] ?? 'Failed to resume subscription');
      }
    } on DioException catch (e) {
      final message = e.response?.data['message'] ?? e.message;
      throw Exception('Resume error: $message');
    }
  }

  /// Change subscription plan
  Future<void> changePlan({
    required String subscriptionId,
    required String newPlanId,
  }) async {
    try {
      final response = await _dio.post(
        '$_baseUrl/subscriptions/change-plan',
        data: {
          'subscriptionId': subscriptionId,
          'newPlanId': newPlanId,
        },
      );
      
      if (response.statusCode != 200 || response.data['success'] != true) {
        throw Exception(response.data['message'] ?? 'Failed to change plan');
      }
    } on DioException catch (e) {
      final message = e.response?.data['message'] ?? e.message;
      throw Exception('Plan change error: $message');
    }
  }

  /// Get subscription invoices/transactions
  Future<List<SubscriptionTransaction>> getInvoices() async {
    try {
      final response = await _dio.get('$_baseUrl/subscriptions/invoices');
      
      if (response.statusCode == 200 && response.data['success'] == true) {
        final List<dynamic> invoicesJson = response.data['data'];
        return invoicesJson
            .map((json) => SubscriptionTransaction.fromJson(json))
            .toList();
      }
      
      throw Exception('Failed to load invoices');
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    }
  }

  /// Create setup intent for adding payment method
  Future<String> createSetupIntent() async {
    try {
      final response = await _dio.post('$_baseUrl/subscriptions/create-setup-intent');
      
      if (response.statusCode == 200 && response.data['success'] == true) {
        return response.data['data']['clientSecret'];
      }
      
      throw Exception('Failed to create payment setup');
    } on DioException catch (e) {
      final message = e.response?.data['message'] ?? e.message;
      throw Exception('Setup error: $message');
    }
  }

  /// Get subscription usage statistics
  Future<SubscriptionUsage> getUsageStats() async {
    try {
      final response = await _dio.get('$_baseUrl/subscriptions/usage');
      
      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'];
        return data != null 
            ? SubscriptionUsage.fromJson(data)
            : SubscriptionUsage(
                currentUsage: 0,
                limit: -1,
                unlimited: true,
              );
      }
      
      throw Exception('Failed to load usage statistics');
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    }
  }
}



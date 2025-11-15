import 'package:logger/logger.dart';
import 'package:flutter/foundation.dart';
import '../config/app_config.dart';

/// Application monitoring and logging
class AppMonitor {
  static final Logger _logger = AppConfig.logger;
  static final List<Map<String, dynamic>> _events = [];
  static const int _maxEvents = 1000;

  /// Log application event
  static void logEvent(String event, {Map<String, dynamic>? data}) {
    final eventData = {
      'timestamp': DateTime.now().toIso8601String(),
      'event': event,
      'data': data ?? {},
    };

    _events.add(eventData);

    // Keep only last N events
    if (_events.length > _maxEvents) {
      _events.removeAt(0);
    }

    _logger.i('Event: $event', error: null, stackTrace: null);
  }

  /// Log error with context
  static void logError(
    String message, {
    dynamic error,
    StackTrace? stackTrace,
    Map<String, dynamic>? context,
  }) {
    final errorData = {
      'timestamp': DateTime.now().toIso8601String(),
      'message': message,
      'error': error?.toString(),
      'context': context ?? {},
    };

    _events.add({
      'type': 'error',
      ...errorData,
    });

    _logger.e(
      message,
      error: error,
      stackTrace: stackTrace,
    );

    // In production, send to monitoring service
    if (kReleaseMode) {
      _sendToMonitoringService(errorData);
    }
  }

  /// Log performance metric
  static void logPerformance(String operation, Duration duration) {
    _logger.d('Performance: $operation took ${duration.inMilliseconds}ms');

    _events.add({
      'type': 'performance',
      'timestamp': DateTime.now().toIso8601String(),
      'operation': operation,
      'duration_ms': duration.inMilliseconds,
    });
  }

  /// Log user action
  static void logUserAction(String action, {Map<String, dynamic>? data}) {
    logEvent('user_action', data: {
      'action': action,
      ...?data,
    });
  }

  /// Log API call
  static void logApiCall(
    String method,
    String endpoint, {
    int? statusCode,
    Duration? duration,
    Map<String, dynamic>? requestData,
    Map<String, dynamic>? responseData,
  }) {
    logEvent('api_call', data: {
      'method': method,
      'endpoint': endpoint,
      'status_code': statusCode,
      'duration_ms': duration?.inMilliseconds,
      'request_data': requestData,
      'response_data': responseData,
    });
  }

  /// Get all events
  static List<Map<String, dynamic>> getEvents() {
    return List.unmodifiable(_events);
  }

  /// Get error events
  static List<Map<String, dynamic>> getErrorEvents() {
    return _events.where((e) => e['type'] == 'error').toList();
  }

  /// Clear events
  static void clearEvents() {
    _events.clear();
    _logger.i('Events cleared');
  }

  /// Send error to monitoring service (Sentry, LogRocket, etc.)
  static void _sendToMonitoringService(Map<String, dynamic> errorData) {
    // TODO: Integrate with Sentry or LogRocket
    // Example:
    // Sentry.captureException(
    //   errorData['error'],
    //   stackTrace: errorData['stackTrace'],
    //   hint: Hint.withMap(errorData['context']),
    // );
  }

  /// Initialize monitoring
  static void initialize() {
    _logger.i('App monitoring initialized');
    logEvent('app_started', data: {
      'version': '1.0.0',
      'platform': defaultTargetPlatform.toString(),
    });
  }
}


import 'package:flutter_test/flutter_test.dart';
import 'package:medical_appointment_system/core/monitoring/app_monitor.dart';
import 'package:logger/logger.dart';

void main() {
  group('AppMonitor', () {
    setUp(() {
      // Clear events before each test
      AppMonitor.clearEvents();
    });

    test('should log events', () {
      AppMonitor.logEvent('test_event', data: {'key': 'value'});

      final events = AppMonitor.getEvents();
      expect(events.length, equals(1));
      expect(events[0]['event'], equals('test_event'));
      expect(events[0]['data']['key'], equals('value'));
    });

    test('should log errors', () {
      AppMonitor.logError('Test error', error: Exception('Test'));

      final errorEvents = AppMonitor.getErrorEvents();
      expect(errorEvents.length, equals(1));
      expect(errorEvents[0]['message'], equals('Test error'));
    });

    test('should log user actions', () {
      AppMonitor.logUserAction('button_click', data: {'button': 'submit'});

      final events = AppMonitor.getEvents();
      expect(events.length, equals(1));
      expect(events[0]['event'], equals('user_action'));
      expect(events[0]['data']['action'], equals('button_click'));
    });

    test('should log API calls', () {
      AppMonitor.logApiCall('GET', '/api/test', statusCode: 200);

      final events = AppMonitor.getEvents();
      expect(events.length, equals(1));
      expect(events[0]['event'], equals('api_call'));
      expect(events[0]['data']['method'], equals('GET'));
    });

    test('should limit events to max count', () {
      // Minimal count over default cap (1000); each call still logs — keep small.
      for (int i = 0; i < 1001; i++) {
        AppMonitor.logEvent('event_$i', silent: true);
      }

      final events = AppMonitor.getEvents();
      expect(events.length, lessThanOrEqualTo(1000));
    });

    test('should clear events', () {
      AppMonitor.logEvent('test_event');
      AppMonitor.clearEvents();

      final events = AppMonitor.getEvents();
      expect(events.length, equals(0));
    });
  });
}

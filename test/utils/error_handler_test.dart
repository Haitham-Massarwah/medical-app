import 'package:flutter_test/flutter_test.dart';
import 'package:medical_appointment_system/core/utils/error_handler.dart';

void main() {
  group('ErrorHandler', () {
    test('should extract error message from string', () {
      final message = ErrorHandler.getErrorMessage('Test error');
      expect(message, equals('Test error'));
    });

    test('should handle network errors', () {
      final message = ErrorHandler.getErrorMessage(
        Exception('SocketException: Failed host lookup'),
      );
      expect(message, contains('אין חיבור לאינטרנט'));
    });

    test('should handle timeout errors', () {
      final message = ErrorHandler.getErrorMessage(
        Exception('TimeoutException'),
      );
      expect(message, contains('זמן רב מדי'));
    });

    test('should handle 401 errors', () {
      final message = ErrorHandler.getErrorMessage(
        Exception('401 Unauthorized'),
      );
      expect(message, contains('ההרשאה פגה'));
    });

    test('should handle 403 errors', () {
      final message = ErrorHandler.getErrorMessage(
        Exception('403 Forbidden'),
      );
      expect(message, contains('אין לך הרשאה'));
    });

    test('should handle 404 errors', () {
      final message = ErrorHandler.getErrorMessage(
        Exception('404 Not Found'),
      );
      expect(message, contains('לא נמצא'));
    });

    test('should handle 500 errors', () {
      final message = ErrorHandler.getErrorMessage(
        Exception('500 Internal Server Error'),
      );
      expect(message, contains('שגיאת שרת'));
    });

    test('should use custom message when provided', () {
      final message = ErrorHandler.getErrorMessage(
        Exception('Some error'),
        customMessage: 'Custom message',
      );
      expect(message, equals('Custom message'));
    });
  });
}


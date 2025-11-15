import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

/// Centralized error handling utility
class ErrorHandler {
  static final Logger _logger = Logger();

  /// Show user-friendly error message
  static void showError(BuildContext context, dynamic error, {String? customMessage}) {
    String message = _getErrorMessage(error, customMessage);
    
    _logger.e('Error shown to user: $message', error: error);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );
  }

  /// Show success message
  static void showSuccess(BuildContext context, String message) {
    _logger.i('Success message: $message');
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// Show info message
  static void showInfo(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.blue,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// Show warning message
  static void showWarning(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.orange,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// Show error dialog with retry option
  static Future<bool?> showErrorDialog(
    BuildContext context,
    dynamic error, {
    String? title,
    String? customMessage,
    VoidCallback? onRetry,
  }) {
    String message = _getErrorMessage(error, customMessage);
    
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title ?? 'שגיאה'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('ביטול'),
          ),
          if (onRetry != null)
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
                onRetry();
              },
              child: const Text('נסה שוב'),
            ),
        ],
      ),
    );
  }

  /// Get user-friendly error message (public)
  static String getErrorMessage(dynamic error, {String? customMessage}) {
    return _getErrorMessage(error, customMessage);
  }
  
  /// Get user-friendly error message (private implementation)
  static String _getErrorMessage(dynamic error, String? customMessage) {
    if (customMessage != null && customMessage.isNotEmpty) {
      return customMessage;
    }

    if (error is String) {
      return error;
    }

    // Handle network errors
    if (error.toString().contains('SocketException') ||
        error.toString().contains('Failed host lookup')) {
      return 'אין חיבור לאינטרנט. אנא בדוק את החיבור שלך.';
    }

    if (error.toString().contains('TimeoutException')) {
      return 'הבקשה ארכה זמן רב מדי. אנא נסה שוב.';
    }

    if (error.toString().contains('401') || error.toString().contains('Unauthorized')) {
      return 'ההרשאה פגה. אנא התחבר מחדש.';
    }

    if (error.toString().contains('403') || error.toString().contains('Forbidden')) {
      return 'אין לך הרשאה לבצע פעולה זו.';
    }

    if (error.toString().contains('404') || error.toString().contains('Not Found')) {
      return 'המשאב המבוקש לא נמצא.';
    }

    if (error.toString().contains('500') || error.toString().contains('Internal Server Error')) {
      return 'שגיאת שרת. אנא נסה שוב מאוחר יותר.';
    }

    if (error.toString().contains('429') || error.toString().contains('Too Many Requests')) {
      return 'יותר מדי בקשות. אנא המתן רגע ונסה שוב.';
    }

    // Default message
    return 'אירעה שגיאה. אנא נסה שוב.';
  }
  
  static String _getErrorMessage(dynamic error, String? customMessage) {
    return _getErrorMessageImpl(error, customMessage);
  }

  /// Log error for debugging
  static void logError(dynamic error, {StackTrace? stackTrace, String? context}) {
    _logger.e(
      context != null ? 'Error in $context' : 'Error occurred',
      error: error,
      stackTrace: stackTrace,
    );
  }

  /// Log warning
  static void logWarning(String message, {String? context}) {
    _logger.w(context != null ? 'Warning in $context: $message' : 'Warning: $message');
  }

  /// Log info
  static void logInfo(String message, {String? context}) {
    _logger.i(context != null ? 'Info in $context: $message' : 'Info: $message');
  }
}


import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import '../../services/language_service.dart';

/// Centralized error handling utility
class ErrorHandler {
  static final Logger _logger = Logger();

  /// Show user-friendly error message in selected language only
  /// Priority: 'critical' shows as popup, 'normal' shows as SnackBar
  static Future<void> showError(BuildContext context, dynamic error, {
    String? customMessage,
    String priority = 'normal', // 'normal' or 'critical'
  }) async {
    final message = await _getErrorMessageInSelectedLanguage(error, customMessage);
    
    _logger.e('Error shown to user: $message', error: error);
    
    // Critical errors show as popup dialog
    if (priority == 'critical') {
      _showErrorDialog(context, message);
      return;
    }
    
    // Normal errors show as SnackBar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 5),
        action: SnackBarAction(
          label: await _getOKButtonText(),
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );
  }

  /// Show critical error as popup dialog
  static Future<void> _showErrorDialog(BuildContext context, String message) async {
    final title = await _getErrorTitle();
    final okButton = await _getOKButtonText();
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.error, color: Colors.red, size: 28),
            const SizedBox(width: 8),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text(
          message,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text(okButton),
          ),
        ],
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

  /// Show error dialog with retry option (in selected language)
  static Future<bool?> showErrorDialog(
    BuildContext context,
    dynamic error, {
    String? title,
    String? customMessage,
    VoidCallback? onRetry,
  }) async {
    final message = await _getErrorMessageInSelectedLanguage(error, customMessage);
    final errorTitle = title ?? await _getErrorTitle();
    final cancelButton = await _getCancelButtonText();
    final retryButton = await _getRetryButtonText();
    
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.error, color: Colors.red, size: 28),
            const SizedBox(width: 8),
            Text(errorTitle, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text(
          message,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(cancelButton),
          ),
          if (onRetry != null)
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(true);
                onRetry();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
              child: Text(retryButton),
            ),
        ],
      ),
    );
  }

  /// Get user-friendly error message (public)
  static String getErrorMessage(dynamic error, {String? customMessage}) {
    return _getErrorMessage(error, customMessage);
  }
  
  /// Get error message in selected language only
  static Future<String> _getErrorMessageInSelectedLanguage(dynamic error, String? customMessage) async {
    final language = await LanguageService.getCurrentLanguage();
    
    if (customMessage != null && customMessage.isNotEmpty) {
      return customMessage;
    }

    if (error is String) {
      return error;
    }

    // Handle network errors
    if (error.toString().contains('SocketException') ||
        error.toString().contains('Failed host lookup')) {
      return _getLocalizedMessage('networkError', language);
    }

    if (error.toString().contains('TimeoutException')) {
      return _getLocalizedMessage('timeoutError', language);
    }

    if (error.toString().contains('401') || error.toString().contains('Unauthorized')) {
      return _getLocalizedMessage('unauthorizedError', language);
    }

    if (error.toString().contains('403') || error.toString().contains('Forbidden')) {
      return _getLocalizedMessage('forbiddenError', language);
    }

    if (error.toString().contains('404') || error.toString().contains('Not Found')) {
      return _getLocalizedMessage('notFoundError', language);
    }

    if (error.toString().contains('500') || error.toString().contains('Internal Server Error')) {
      return _getLocalizedMessage('serverError', language);
    }

    if (error.toString().contains('429') || error.toString().contains('Too Many Requests')) {
      return _getLocalizedMessage('tooManyRequestsError', language);
    }

    // Default message
    return _getLocalizedMessage('defaultError', language);
  }

  /// Get localized message based on selected language
  static String _getLocalizedMessage(String key, String language) {
    final messages = {
      'networkError': {
        'עברית': 'אין חיבור לאינטרנט. אנא בדוק את החיבור שלך.',
        'العربية': 'لا يوجد اتصال بالإنترنت. يرجى التحقق من اتصالك.',
        'English': 'No internet connection. Please check your connection.',
      },
      'timeoutError': {
        'עברית': 'הבקשה ארכה זמן רב מדי. אנא נסה שוב.',
        'العربية': 'استغرقت الطلب وقتًا طويلاً. يرجى المحاولة مرة أخرى.',
        'English': 'Request took too long. Please try again.',
      },
      'unauthorizedError': {
        'עברית': 'ההרשאה פגה. אנא התחבר מחדש.',
        'العربية': 'انتهت صلاحية التفويض. يرجى تسجيل الدخول مرة أخرى.',
        'English': 'Authorization expired. Please log in again.',
      },
      'forbiddenError': {
        'עברית': 'אין לך הרשאה לבצע פעולה זו.',
        'العربية': 'ليس لديك إذن لتنفيذ هذا الإجراء.',
        'English': 'You do not have permission to perform this action.',
      },
      'notFoundError': {
        'עברית': 'המשאב המבוקש לא נמצא.',
        'العربية': 'المورد المطلوب غير موجود.',
        'English': 'The requested resource was not found.',
      },
      'serverError': {
        'עברית': 'שגיאת שרת. אנא נסה שוב מאוחר יותר.',
        'العربية': 'خطأ في الخادم. يرجى المحاولة مرة أخرى لاحقًا.',
        'English': 'Server error. Please try again later.',
      },
      'tooManyRequestsError': {
        'עברית': 'יותר מדי בקשות. אנא המתן רגע ונסה שוב.',
        'العربية': 'طلبات كثيرة جدًا. يرجى الانتظار لحظة والمحاولة مرة أخرى.',
        'English': 'Too many requests. Please wait a moment and try again.',
      },
      'defaultError': {
        'עברית': 'אירעה שגיאה. אנא נסה שוב.',
        'العربية': 'حدث خطأ. يرجى المحاولة مرة أخرى.',
        'English': 'An error occurred. Please try again.',
      },
    };

    return messages[key]?[language] ?? messages[key]!['English']!;
  }

  /// Get button texts in selected language
  static Future<String> _getOKButtonText() async {
    final language = await LanguageService.getCurrentLanguage();
    return {
      'עברית': 'אישור',
      'العربية': 'موافق',
      'English': 'OK',
    }[language] ?? 'OK';
  }

  static Future<String> _getErrorTitle() async {
    final language = await LanguageService.getCurrentLanguage();
    return {
      'עברית': 'שגיאה',
      'العربية': 'خطأ',
      'English': 'Error',
    }[language] ?? 'Error';
  }

  static Future<String> _getCancelButtonText() async {
    final language = await LanguageService.getCurrentLanguage();
    return {
      'עברית': 'ביטול',
      'العربية': 'إلغاء',
      'English': 'Cancel',
    }[language] ?? 'Cancel';
  }

  static Future<String> _getRetryButtonText() async {
    final language = await LanguageService.getCurrentLanguage();
    return {
      'עברית': 'נסה שוב',
      'العربية': 'إعادة المحاولة',
      'English': 'Retry',
    }[language] ?? 'Retry';
  }

  /// Get user-friendly error message (private implementation) - kept for backward compatibility
  static String _getErrorMessage(dynamic error, String? customMessage) {
    // Use synchronous approach with default English language
    // For async version, use _getErrorMessageInSelectedLanguage
    if (customMessage != null && customMessage.isNotEmpty) {
      return customMessage;
    }

    if (error is String) {
      return error;
    }

    // Default to English for synchronous method
    final language = 'English';
    
    // Handle network errors
    if (error.toString().contains('SocketException') ||
        error.toString().contains('Failed host lookup')) {
      return _getLocalizedMessage('networkError', language);
    }

    if (error.toString().contains('TimeoutException')) {
      return _getLocalizedMessage('timeoutError', language);
    }

    if (error.toString().contains('401') || error.toString().contains('Unauthorized')) {
      return _getLocalizedMessage('unauthorizedError', language);
    }

    if (error.toString().contains('403') || error.toString().contains('Forbidden')) {
      return _getLocalizedMessage('forbiddenError', language);
    }

    if (error.toString().contains('404') || error.toString().contains('Not Found')) {
      return _getLocalizedMessage('notFoundError', language);
    }

    if (error.toString().contains('500') || error.toString().contains('Internal Server Error')) {
      return _getLocalizedMessage('serverError', language);
    }

    if (error.toString().contains('429') || error.toString().contains('Too Many Requests')) {
      return _getLocalizedMessage('tooManyRequestsError', language);
    }

    // Default message
    return _getLocalizedMessage('defaultError', language);
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


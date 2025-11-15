import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/app_constants.dart';

class AuthInterceptor extends Interceptor {
  final SharedPreferences _prefs;

  AuthInterceptor(this._prefs);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Add authorization header if token exists
    final token = _prefs.getString(AppConstants.storageAuthToken);
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    // Add content type
    options.headers['Content-Type'] = 'application/json';
    options.headers['Accept'] = 'application/json';

    // Add language header
    final language = _prefs.getString(AppConstants.storageLanguage) ?? 'he';
    options.headers['Accept-Language'] = language;

    // Add tenant ID if available
    final tenantId = _prefs.getString('tenant_id');
    if (tenantId != null && tenantId.isNotEmpty) {
      options.headers['X-Tenant-ID'] = tenantId;
    }

    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Handle 401 Unauthorized - refresh token or redirect to login
    if (err.response?.statusCode == 401) {
      _handleUnauthorized();
    }

    // Handle 403 Forbidden
    if (err.response?.statusCode == 403) {
      _handleForbidden();
    }

    handler.next(err);
  }

  void _handleUnauthorized() {
    // Clear stored tokens
    _prefs.remove(AppConstants.storageAuthToken);
    _prefs.remove(AppConstants.storageRefreshToken);
    
    // TODO: Navigate to login page
    // This should be handled by the app's navigation system
  }

  void _handleForbidden() {
    // TODO: Show access denied message
    // This should be handled by the app's error handling system
  }
}

class LoggingInterceptor extends Interceptor {
  final Logger _logger;

  LoggingInterceptor(this._logger);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    _logger.d('REQUEST[${options.method}] => PATH: ${options.path}');
    _logger.d('Headers: ${options.headers}');
    if (options.data != null) {
      _logger.d('Data: ${options.data}');
    }
    if (options.queryParameters.isNotEmpty) {
      _logger.d('Query Parameters: ${options.queryParameters}');
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    _logger.d('RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.path}');
    _logger.d('Data: ${response.data}');
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    _logger.e('ERROR[${err.response?.statusCode}] => PATH: ${err.requestOptions.path}');
    _logger.e('Message: ${err.message}');
    if (err.response?.data != null) {
      _logger.e('Error Data: ${err.response?.data}');
    }
    handler.next(err);
  }
}

class ErrorInterceptor extends Interceptor {
  final Logger _logger;

  ErrorInterceptor(this._logger);

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    DioException dioError = err;

    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        dioError = DioException(
          requestOptions: err.requestOptions,
          error: 'Connection timeout. Please check your internet connection.',
          type: err.type,
        );
        break;

      case DioExceptionType.badResponse:
        final statusCode = err.response?.statusCode;
        final errorMessage = _getErrorMessageFromResponse(err.response);
        
        dioError = DioException(
          requestOptions: err.requestOptions,
          response: err.response,
          error: errorMessage,
          type: err.type,
        );
        break;

      case DioExceptionType.cancel:
        dioError = DioException(
          requestOptions: err.requestOptions,
          error: 'Request was cancelled',
          type: err.type,
        );
        break;

      case DioExceptionType.connectionError:
        dioError = DioException(
          requestOptions: err.requestOptions,
          error: 'No internet connection. Please check your network settings.',
          type: err.type,
        );
        break;

      case DioExceptionType.badCertificate:
        dioError = DioException(
          requestOptions: err.requestOptions,
          error: 'Certificate error. Please contact support.',
          type: err.type,
        );
        break;

      case DioExceptionType.unknown:
        dioError = DioException(
          requestOptions: err.requestOptions,
          error: 'An unexpected error occurred. Please try again.',
          type: err.type,
        );
        break;
    }

    _logger.e('Processed error: ${dioError.error}');
    handler.next(dioError);
  }

  String _getErrorMessageFromResponse(Response? response) {
    if (response?.data is Map<String, dynamic>) {
      final data = response!.data as Map<String, dynamic>;
      
      // Try to get error message from different possible fields
      if (data.containsKey('message')) {
        return data['message'] as String;
      }
      if (data.containsKey('error')) {
        return data['error'] as String;
      }
      if (data.containsKey('error_description')) {
        return data['error_description'] as String;
      }
    }

    // Fallback to status code based messages
    switch (response?.statusCode) {
      case 400:
        return 'Bad request. Please check your input.';
      case 401:
        return 'Unauthorized. Please log in again.';
      case 403:
        return 'Access forbidden. You don\'t have permission to perform this action.';
      case 404:
        return 'Resource not found.';
      case 409:
        return 'Conflict. The resource already exists or is in use.';
      case 422:
        return 'Validation error. Please check your input.';
      case 429:
        return 'Too many requests. Please try again later.';
      case 500:
        return 'Internal server error. Please try again later.';
      case 502:
        return 'Bad gateway. The server is temporarily unavailable.';
      case 503:
        return 'Service unavailable. Please try again later.';
      default:
        return 'An error occurred. Please try again.';
    }
  }
}

class RetryInterceptor extends Interceptor {
  final int maxRetries;
  final Duration retryDelay;

  RetryInterceptor({
    this.maxRetries = 3,
    this.retryDelay = const Duration(seconds: 2),
  });

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (_shouldRetry(err)) {
      final retryCount = err.requestOptions.extra['retryCount'] ?? 0;
      
      if (retryCount < maxRetries) {
        err.requestOptions.extra['retryCount'] = retryCount + 1;
        
        // Wait before retrying
        await Future.delayed(retryDelay);
        
        try {
          final response = await Dio().fetch(err.requestOptions);
          handler.resolve(response);
          return;
        } catch (e) {
          // Continue to next retry or fail
        }
      }
    }
    
    handler.next(err);
  }

  bool _shouldRetry(DioException err) {
    // Retry on network errors and 5xx server errors
    return err.type == DioExceptionType.connectionTimeout ||
           err.type == DioExceptionType.sendTimeout ||
           err.type == DioExceptionType.receiveTimeout ||
           err.type == DioExceptionType.connectionError ||
           (err.response?.statusCode != null && err.response!.statusCode! >= 500);
  }
}

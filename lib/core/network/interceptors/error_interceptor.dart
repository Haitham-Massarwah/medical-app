import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

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

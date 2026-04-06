import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../utils/app_constants.dart';

/// Attaches auth / tenant headers from [SharedPreferences].
class AuthInterceptor extends Interceptor {
  final SharedPreferences _prefs;

  AuthInterceptor(this._prefs);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final token = _prefs.getString(AppConstants.storageAuthToken);
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    options.headers['Content-Type'] = 'application/json';
    options.headers['Accept'] = 'application/json';

    final language = _prefs.getString(AppConstants.storageLanguage) ?? 'he';
    options.headers['Accept-Language'] = language;

    final tenantId = _prefs.getString('tenant_id');
    if (tenantId != null && tenantId.isNotEmpty) {
      options.headers['X-Tenant-ID'] = tenantId;
    }

    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      _handleUnauthorized();
    }
    if (err.response?.statusCode == 403) {
      _handleForbidden();
    }
    handler.next(err);
  }

  void _handleUnauthorized() {
    _prefs.remove(AppConstants.storageAuthToken);
    _prefs.remove(AppConstants.storageRefreshToken);
  }

  void _handleForbidden() {}
}

import 'dart:convert';

import '../../../../core/storage/local_storage.dart';
import '../models/auth_models.dart';

abstract class AuthLocalDataSource {
  Future<void> saveAuthTokens(String accessToken, String refreshToken);
  Future<void> saveUser(UserModel user);
  Future<UserModel?> getCurrentUser();
  Future<String?> getAccessToken();
  Future<String?> getRefreshToken();
  Future<void> clearAuthData();
  Future<bool> isLoggedIn();
  Future<void> updateUser(UserModel user);
  Future<void> saveTenant(TenantModel tenant);
  Future<TenantModel?> getCurrentTenant();
  Future<void> clearTenantData();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final LocalStorage _storage;

  AuthLocalDataSourceImpl(this._storage);

  static const _tenantKey = 'current_tenant_json';
  static const _userJsonKey = 'auth_user_json';

  @override
  Future<void> saveAuthTokens(String accessToken, String refreshToken) async {
    await _storage.setAuthToken(accessToken);
    await _storage.setRefreshToken(refreshToken);
  }

  @override
  Future<void> saveUser(UserModel user) async {
    await _storage.setString(_userJsonKey, jsonEncode(user.toJson()));
    await _storage.setUserId(user.id);
    await _storage.setUserRole(user.role.name);
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    final raw = _storage.getString(_userJsonKey);
    if (raw == null || raw.isEmpty) return null;
    try {
      return UserModel.fromJson(
        jsonDecode(raw) as Map<String, dynamic>,
      );
    } catch (_) {
      return null;
    }
  }

  @override
  Future<String?> getAccessToken() async => _storage.getAuthToken();

  @override
  Future<String?> getRefreshToken() async => _storage.getRefreshToken();

  @override
  Future<void> clearAuthData() async {
    await _storage.clearAuthData();
    await _storage.remove(_userJsonKey);
  }

  @override
  Future<bool> isLoggedIn() async => _storage.isLoggedIn();

  @override
  Future<void> updateUser(UserModel user) async {
    await saveUser(user);
  }

  @override
  Future<void> saveTenant(TenantModel tenant) async {
    await _storage.setString(_tenantKey, jsonEncode(tenant.toJson()));
  }

  @override
  Future<TenantModel?> getCurrentTenant() async {
    final raw = _storage.getString(_tenantKey);
    if (raw == null || raw.isEmpty) return null;
    try {
      return TenantModel.fromJson(
        jsonDecode(raw) as Map<String, dynamic>,
      );
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> clearTenantData() async {
    await _storage.remove(_tenantKey);
  }
}

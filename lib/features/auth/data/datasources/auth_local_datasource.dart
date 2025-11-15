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
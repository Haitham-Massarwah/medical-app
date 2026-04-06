import '../../../../core/network/api_client.dart';
import '../models/auth_models.dart';

abstract class AuthRemoteDataSource {
  Future<AuthResponse> login(LoginRequest request);
  Future<AuthResponse> register(RegisterRequest request);
  Future<AuthResponse> refreshToken(RefreshTokenRequest request);
  Future<void> logout();
  Future<void> forgotPassword(ForgotPasswordRequest request);
  Future<void> resetPassword(ResetPasswordRequest request);
  Future<void> verifyEmail(VerifyEmailRequest request);
  Future<void> resendVerification(ResendVerificationRequest request);
  Future<UserModel> getProfile();
  Future<UserModel> updateProfile(UpdateProfileRequest request);
  Future<void> changePassword(ChangePasswordRequest request);
  Future<TwoFactorSetupResponse> enableTwoFactor();
  Future<void> verifyTwoFactor(VerifyTwoFactorRequest request);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient _api;

  AuthRemoteDataSourceImpl(this._api);

  @override
  Future<AuthResponse> login(LoginRequest request) => _api.login(request);

  @override
  Future<AuthResponse> register(RegisterRequest request) =>
      _api.register(request);

  @override
  Future<AuthResponse> refreshToken(RefreshTokenRequest request) =>
      _api.refreshToken(request);

  @override
  Future<void> logout() => _api.logout();

  @override
  Future<void> forgotPassword(ForgotPasswordRequest request) =>
      _api.forgotPassword(request);

  @override
  Future<void> resetPassword(ResetPasswordRequest request) =>
      _api.resetPassword(request);

  @override
  Future<void> verifyEmail(VerifyEmailRequest request) =>
      _api.verifyEmail(request);

  @override
  Future<void> resendVerification(ResendVerificationRequest request) =>
      _api.resendVerification(request);

  @override
  Future<UserModel> getProfile() => _api.getProfile();

  @override
  Future<UserModel> updateProfile(UpdateProfileRequest request) =>
      _api.updateProfile(request);

  @override
  Future<void> changePassword(ChangePasswordRequest request) =>
      _api.changePassword(request);

  @override
  Future<TwoFactorSetupResponse> enableTwoFactor() => _api.enableTwoFactor();

  @override
  Future<void> verifyTwoFactor(VerifyTwoFactorRequest request) =>
      _api.verifyTwoFactor(request);
}

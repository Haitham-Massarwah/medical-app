import '../models/auth_models.dart';

abstract class AuthRepository {
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
  Future<UserModel?> getCurrentUser();
  Future<bool> isLoggedIn();
  Future<void> clearAuthData();
}

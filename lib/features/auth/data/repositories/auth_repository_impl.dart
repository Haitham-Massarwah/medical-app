import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/storage/local_storage.dart';
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

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;
  final AuthLocalDataSource _localDataSource;
  final Logger _logger;

  AuthRepositoryImpl(this._remoteDataSource, this._localDataSource, this._logger);

  @override
  Future<AuthResponse> login(LoginRequest request) async {
    try {
      _logger.d('Starting login process');
      
      final response = await _remoteDataSource.login(request);
      
      // Save tokens and user data locally
      await _localDataSource.saveAuthTokens(response.accessToken, response.refreshToken);
      await _localDataSource.saveUser(response.user);
      
      _logger.d('Login process completed successfully');
      return response;
    } on DioException catch (e) {
      _logger.e('Login failed with DioException: ${e.message}');
      rethrow;
    } catch (e) {
      _logger.e('Login failed with unexpected error: $e');
      rethrow;
    }
  }

  @override
  Future<AuthResponse> register(RegisterRequest request) async {
    try {
      _logger.d('Starting registration process');
      
      final response = await _remoteDataSource.register(request);
      
      // Save tokens and user data locally
      await _localDataSource.saveAuthTokens(response.accessToken, response.refreshToken);
      await _localDataSource.saveUser(response.user);
      
      _logger.d('Registration process completed successfully');
      return response;
    } on DioException catch (e) {
      _logger.e('Registration failed with DioException: ${e.message}');
      rethrow;
    } catch (e) {
      _logger.e('Registration failed with unexpected error: $e');
      rethrow;
    }
  }

  @override
  Future<AuthResponse> refreshToken(RefreshTokenRequest request) async {
    try {
      _logger.d('Starting token refresh process');
      
      final response = await _remoteDataSource.refreshToken(request);
      
      // Update tokens locally
      await _localDataSource.saveAuthTokens(response.accessToken, response.refreshToken);
      
      _logger.d('Token refresh process completed successfully');
      return response;
    } on DioException catch (e) {
      _logger.e('Token refresh failed with DioException: ${e.message}');
      rethrow;
    } catch (e) {
      _logger.e('Token refresh failed with unexpected error: $e');
      rethrow;
    }
  }

  @override
  Future<void> logout() async {
    try {
      _logger.d('Starting logout process');
      
      // Call remote logout
      await _remoteDataSource.logout();
      
      // Clear local data
      await _localDataSource.clearAuthData();
      
      _logger.d('Logout process completed successfully');
    } on DioException catch (e) {
      _logger.e('Logout failed with DioException: ${e.message}');
      // Even if remote logout fails, clear local data
      await _localDataSource.clearAuthData();
      rethrow;
    } catch (e) {
      _logger.e('Logout failed with unexpected error: $e');
      // Even if remote logout fails, clear local data
      await _localDataSource.clearAuthData();
      rethrow;
    }
  }

  @override
  Future<void> forgotPassword(ForgotPasswordRequest request) async {
    try {
      _logger.d('Starting forgot password process');
      await _remoteDataSource.forgotPassword(request);
      _logger.d('Forgot password process completed successfully');
    } on DioException catch (e) {
      _logger.e('Forgot password failed with DioException: ${e.message}');
      rethrow;
    } catch (e) {
      _logger.e('Forgot password failed with unexpected error: $e');
      rethrow;
    }
  }

  @override
  Future<void> resetPassword(ResetPasswordRequest request) async {
    try {
      _logger.d('Starting password reset process');
      await _remoteDataSource.resetPassword(request);
      _logger.d('Password reset process completed successfully');
    } on DioException catch (e) {
      _logger.e('Password reset failed with DioException: ${e.message}');
      rethrow;
    } catch (e) {
      _logger.e('Password reset failed with unexpected error: $e');
      rethrow;
    }
  }

  @override
  Future<void> verifyEmail(VerifyEmailRequest request) async {
    try {
      _logger.d('Starting email verification process');
      await _remoteDataSource.verifyEmail(request);
      _logger.d('Email verification process completed successfully');
    } on DioException catch (e) {
      _logger.e('Email verification failed with DioException: ${e.message}');
      rethrow;
    } catch (e) {
      _logger.e('Email verification failed with unexpected error: $e');
      rethrow;
    }
  }

  @override
  Future<void> resendVerification(ResendVerificationRequest request) async {
    try {
      _logger.d('Starting resend verification process');
      await _remoteDataSource.resendVerification(request);
      _logger.d('Resend verification process completed successfully');
    } on DioException catch (e) {
      _logger.e('Resend verification failed with DioException: ${e.message}');
      rethrow;
    } catch (e) {
      _logger.e('Resend verification failed with unexpected error: $e');
      rethrow;
    }
  }

  @override
  Future<UserModel> getProfile() async {
    try {
      _logger.d('Starting get profile process');
      
      final user = await _remoteDataSource.getProfile();
      
      // Update local user data
      await _localDataSource.updateUser(user);
      
      _logger.d('Get profile process completed successfully');
      return user;
    } on DioException catch (e) {
      _logger.e('Get profile failed with DioException: ${e.message}');
      rethrow;
    } catch (e) {
      _logger.e('Get profile failed with unexpected error: $e');
      rethrow;
    }
  }

  @override
  Future<UserModel> updateProfile(UpdateProfileRequest request) async {
    try {
      _logger.d('Starting update profile process');
      
      final user = await _remoteDataSource.updateProfile(request);
      
      // Update local user data
      await _localDataSource.updateUser(user);
      
      _logger.d('Update profile process completed successfully');
      return user;
    } on DioException catch (e) {
      _logger.e('Update profile failed with DioException: ${e.message}');
      rethrow;
    } catch (e) {
      _logger.e('Update profile failed with unexpected error: $e');
      rethrow;
    }
  }

  @override
  Future<void> changePassword(ChangePasswordRequest request) async {
    try {
      _logger.d('Starting change password process');
      await _remoteDataSource.changePassword(request);
      _logger.d('Change password process completed successfully');
    } on DioException catch (e) {
      _logger.e('Change password failed with DioException: ${e.message}');
      rethrow;
    } catch (e) {
      _logger.e('Change password failed with unexpected error: $e');
      rethrow;
    }
  }

  @override
  Future<TwoFactorSetupResponse> enableTwoFactor() async {
    try {
      _logger.d('Starting enable two-factor process');
      final response = await _remoteDataSource.enableTwoFactor();
      _logger.d('Enable two-factor process completed successfully');
      return response;
    } on DioException catch (e) {
      _logger.e('Enable two-factor failed with DioException: ${e.message}');
      rethrow;
    } catch (e) {
      _logger.e('Enable two-factor failed with unexpected error: $e');
      rethrow;
    }
  }

  @override
  Future<void> verifyTwoFactor(VerifyTwoFactorRequest request) async {
    try {
      _logger.d('Starting verify two-factor process');
      await _remoteDataSource.verifyTwoFactor(request);
      _logger.d('Verify two-factor process completed successfully');
    } on DioException catch (e) {
      _logger.e('Verify two-factor failed with DioException: ${e.message}');
      rethrow;
    } catch (e) {
      _logger.e('Verify two-factor failed with unexpected error: $e');
      rethrow;
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    try {
      return await _localDataSource.getCurrentUser();
    } catch (e) {
      _logger.e('Failed to get current user: $e');
      return null;
    }
  }

  @override
  Future<bool> isLoggedIn() async {
    try {
      return await _localDataSource.isLoggedIn();
    } catch (e) {
      _logger.e('Failed to check login status: $e');
      return false;
    }
  }

  @override
  Future<void> clearAuthData() async {
    try {
      await _localDataSource.clearAuthData();
    } catch (e) {
      _logger.e('Failed to clear auth data: $e');
      rethrow;
    }
  }
}

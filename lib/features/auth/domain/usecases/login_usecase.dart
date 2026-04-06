import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

import '../../data/models/auth_models.dart';
import '../repositories/auth_repository.dart';

// Login Use Case
class LoginUseCase {
  final AuthRepository _repository;
  final Logger _logger;

  LoginUseCase(this._repository, this._logger);

  Future<AuthResponse> call(LoginRequest request) async {
    try {
      _logger.d('LoginUseCase: Starting login for ${request.email}');
      
      // Validate input
      if (request.email.isEmpty || request.password.isEmpty) {
        throw ArgumentError('Email and password are required');
      }
      
      final response = await _repository.login(request);
      
      _logger.d('LoginUseCase: Login successful for user ${response.user.id}');
      return response;
    } on DioException catch (e) {
      _logger.e('LoginUseCase: Login failed with DioException: ${e.message}');
      rethrow;
    } catch (e) {
      _logger.e('LoginUseCase: Login failed with unexpected error: $e');
      rethrow;
    }
  }
}

// Register Use Case
class RegisterUseCase {
  final AuthRepository _repository;
  final Logger _logger;

  RegisterUseCase(this._repository, this._logger);

  Future<AuthResponse> call(RegisterRequest request) async {
    try {
      _logger.d('RegisterUseCase: Starting registration for ${request.email}');
      
      // Validate input
      if (request.email.isEmpty || request.password.isEmpty) {
        throw ArgumentError('Email and password are required');
      }
      
      if (request.password != request.confirmPassword) {
        throw ArgumentError('Passwords do not match');
      }
      
      if (request.password.length < 8) {
        throw ArgumentError('Password must be at least 8 characters long');
      }
      
      if (request.firstName.isEmpty || request.lastName.isEmpty) {
        throw ArgumentError('First name and last name are required');
      }
      
      final response = await _repository.register(request);
      
      _logger.d('RegisterUseCase: Registration successful for user ${response.user.id}');
      return response;
    } on DioException catch (e) {
      _logger.e('RegisterUseCase: Registration failed with DioException: ${e.message}');
      rethrow;
    } catch (e) {
      _logger.e('RegisterUseCase: Registration failed with unexpected error: $e');
      rethrow;
    }
  }
}

// Logout Use Case
class LogoutUseCase {
  final AuthRepository _repository;
  final Logger _logger;

  LogoutUseCase(this._repository, this._logger);

  Future<void> call() async {
    try {
      _logger.d('LogoutUseCase: Starting logout');
      
      await _repository.logout();
      
      _logger.d('LogoutUseCase: Logout successful');
    } on DioException catch (e) {
      _logger.e('LogoutUseCase: Logout failed with DioException: ${e.message}');
      rethrow;
    } catch (e) {
      _logger.e('LogoutUseCase: Logout failed with unexpected error: $e');
      rethrow;
    }
  }
}

// Refresh Token Use Case
class RefreshTokenUseCase {
  final AuthRepository _repository;
  final Logger _logger;

  RefreshTokenUseCase(this._repository, this._logger);

  Future<AuthResponse> call(RefreshTokenRequest request) async {
    try {
      _logger.d('RefreshTokenUseCase: Starting token refresh');
      
      if (request.refreshToken.isEmpty) {
        throw ArgumentError('Refresh token is required');
      }
      
      final response = await _repository.refreshToken(request);
      
      _logger.d('RefreshTokenUseCase: Token refresh successful');
      return response;
    } on DioException catch (e) {
      _logger.e('RefreshTokenUseCase: Token refresh failed with DioException: ${e.message}');
      rethrow;
    } catch (e) {
      _logger.e('RefreshTokenUseCase: Token refresh failed with unexpected error: $e');
      rethrow;
    }
  }
}

// Forgot Password Use Case
class ForgotPasswordUseCase {
  final AuthRepository _repository;
  final Logger _logger;

  ForgotPasswordUseCase(this._repository, this._logger);

  Future<void> call(ForgotPasswordRequest request) async {
    try {
      _logger.d('ForgotPasswordUseCase: Starting forgot password for ${request.email}');
      
      if (request.email.isEmpty) {
        throw ArgumentError('Email is required');
      }
      
      await _repository.forgotPassword(request);
      
      _logger.d('ForgotPasswordUseCase: Forgot password successful');
    } on DioException catch (e) {
      _logger.e('ForgotPasswordUseCase: Forgot password failed with DioException: ${e.message}');
      rethrow;
    } catch (e) {
      _logger.e('ForgotPasswordUseCase: Forgot password failed with unexpected error: $e');
      rethrow;
    }
  }
}

// Reset Password Use Case
class ResetPasswordUseCase {
  final AuthRepository _repository;
  final Logger _logger;

  ResetPasswordUseCase(this._repository, this._logger);

  Future<void> call(ResetPasswordRequest request) async {
    try {
      _logger.d('ResetPasswordUseCase: Starting password reset');
      
      if (request.token.isEmpty) {
        throw ArgumentError('Reset token is required');
      }
      
      if (request.newPassword.isEmpty) {
        throw ArgumentError('New password is required');
      }
      
      if (request.newPassword != request.confirmPassword) {
        throw ArgumentError('Passwords do not match');
      }
      
      if (request.newPassword.length < 8) {
        throw ArgumentError('Password must be at least 8 characters long');
      }
      
      await _repository.resetPassword(request);
      
      _logger.d('ResetPasswordUseCase: Password reset successful');
    } on DioException catch (e) {
      _logger.e('ResetPasswordUseCase: Password reset failed with DioException: ${e.message}');
      rethrow;
    } catch (e) {
      _logger.e('ResetPasswordUseCase: Password reset failed with unexpected error: $e');
      rethrow;
    }
  }
}

// Verify Email Use Case
class VerifyEmailUseCase {
  final AuthRepository _repository;
  final Logger _logger;

  VerifyEmailUseCase(this._repository, this._logger);

  Future<void> call(VerifyEmailRequest request) async {
    try {
      _logger.d('VerifyEmailUseCase: Starting email verification');
      
      if (request.token.isEmpty) {
        throw ArgumentError('Verification token is required');
      }
      
      await _repository.verifyEmail(request);
      
      _logger.d('VerifyEmailUseCase: Email verification successful');
    } on DioException catch (e) {
      _logger.e('VerifyEmailUseCase: Email verification failed with DioException: ${e.message}');
      rethrow;
    } catch (e) {
      _logger.e('VerifyEmailUseCase: Email verification failed with unexpected error: $e');
      rethrow;
    }
  }
}

// Resend Verification Use Case
class ResendVerificationUseCase {
  final AuthRepository _repository;
  final Logger _logger;

  ResendVerificationUseCase(this._repository, this._logger);

  Future<void> call(ResendVerificationRequest request) async {
    try {
      _logger.d('ResendVerificationUseCase: Starting resend verification for ${request.email}');
      
      if (request.email.isEmpty) {
        throw ArgumentError('Email is required');
      }
      
      await _repository.resendVerification(request);
      
      _logger.d('ResendVerificationUseCase: Resend verification successful');
    } on DioException catch (e) {
      _logger.e('ResendVerificationUseCase: Resend verification failed with DioException: ${e.message}');
      rethrow;
    } catch (e) {
      _logger.e('ResendVerificationUseCase: Resend verification failed with unexpected error: $e');
      rethrow;
    }
  }
}

// Get Profile Use Case
class GetProfileUseCase {
  final AuthRepository _repository;
  final Logger _logger;

  GetProfileUseCase(this._repository, this._logger);

  Future<UserModel> call() async {
    try {
      _logger.d('GetProfileUseCase: Starting get profile');
      
      final user = await _repository.getProfile();
      
      _logger.d('GetProfileUseCase: Get profile successful for user ${user.id}');
      return user;
    } on DioException catch (e) {
      _logger.e('GetProfileUseCase: Get profile failed with DioException: ${e.message}');
      rethrow;
    } catch (e) {
      _logger.e('GetProfileUseCase: Get profile failed with unexpected error: $e');
      rethrow;
    }
  }
}

// Update Profile Use Case
class UpdateProfileUseCase {
  final AuthRepository _repository;
  final Logger _logger;

  UpdateProfileUseCase(this._repository, this._logger);

  Future<UserModel> call(UpdateProfileRequest request) async {
    try {
      _logger.d('UpdateProfileUseCase: Starting update profile');
      
      if (request.firstName.isEmpty || request.lastName.isEmpty) {
        throw ArgumentError('First name and last name are required');
      }
      
      final user = await _repository.updateProfile(request);
      
      _logger.d('UpdateProfileUseCase: Update profile successful for user ${user.id}');
      return user;
    } on DioException catch (e) {
      _logger.e('UpdateProfileUseCase: Update profile failed with DioException: ${e.message}');
      rethrow;
    } catch (e) {
      _logger.e('UpdateProfileUseCase: Update profile failed with unexpected error: $e');
      rethrow;
    }
  }
}

// Change Password Use Case
class ChangePasswordUseCase {
  final AuthRepository _repository;
  final Logger _logger;

  ChangePasswordUseCase(this._repository, this._logger);

  Future<void> call(ChangePasswordRequest request) async {
    try {
      _logger.d('ChangePasswordUseCase: Starting change password');
      
      if (request.currentPassword.isEmpty) {
        throw ArgumentError('Current password is required');
      }
      
      if (request.newPassword.isEmpty) {
        throw ArgumentError('New password is required');
      }
      
      if (request.newPassword != request.confirmPassword) {
        throw ArgumentError('Passwords do not match');
      }
      
      if (request.newPassword.length < 8) {
        throw ArgumentError('Password must be at least 8 characters long');
      }
      
      await _repository.changePassword(request);
      
      _logger.d('ChangePasswordUseCase: Change password successful');
    } on DioException catch (e) {
      _logger.e('ChangePasswordUseCase: Change password failed with DioException: ${e.message}');
      rethrow;
    } catch (e) {
      _logger.e('ChangePasswordUseCase: Change password failed with unexpected error: $e');
      rethrow;
    }
  }
}

// Enable Two Factor Use Case
class EnableTwoFactorUseCase {
  final AuthRepository _repository;
  final Logger _logger;

  EnableTwoFactorUseCase(this._repository, this._logger);

  Future<TwoFactorSetupResponse> call() async {
    try {
      _logger.d('EnableTwoFactorUseCase: Starting enable two-factor');
      
      final response = await _repository.enableTwoFactor();
      
      _logger.d('EnableTwoFactorUseCase: Enable two-factor successful');
      return response;
    } on DioException catch (e) {
      _logger.e('EnableTwoFactorUseCase: Enable two-factor failed with DioException: ${e.message}');
      rethrow;
    } catch (e) {
      _logger.e('EnableTwoFactorUseCase: Enable two-factor failed with unexpected error: $e');
      rethrow;
    }
  }
}

// Verify Two Factor Use Case
class VerifyTwoFactorUseCase {
  final AuthRepository _repository;
  final Logger _logger;

  VerifyTwoFactorUseCase(this._repository, this._logger);

  Future<void> call(VerifyTwoFactorRequest request) async {
    try {
      _logger.d('VerifyTwoFactorUseCase: Starting verify two-factor');
      
      if (request.code.isEmpty) {
        throw ArgumentError('Verification code is required');
      }
      
      await _repository.verifyTwoFactor(request);
      
      _logger.d('VerifyTwoFactorUseCase: Verify two-factor successful');
    } on DioException catch (e) {
      _logger.e('VerifyTwoFactorUseCase: Verify two-factor failed with DioException: ${e.message}');
      rethrow;
    } catch (e) {
      _logger.e('VerifyTwoFactorUseCase: Verify two-factor failed with unexpected error: $e');
      rethrow;
    }
  }
}

// Get Current User Use Case
class GetCurrentUserUseCase {
  final AuthRepository _repository;
  final Logger _logger;

  GetCurrentUserUseCase(this._repository, this._logger);

  Future<UserModel?> call() async {
    try {
      _logger.d('GetCurrentUserUseCase: Getting current user');
      
      final user = await _repository.getCurrentUser();
      
      if (user != null) {
        _logger.d('GetCurrentUserUseCase: Current user found: ${user.id}');
      } else {
        _logger.d('GetCurrentUserUseCase: No current user found');
      }
      
      return user;
    } catch (e) {
      _logger.e('GetCurrentUserUseCase: Failed to get current user: $e');
      return null;
    }
  }
}

// Is Logged In Use Case
class IsLoggedInUseCase {
  final AuthRepository _repository;
  final Logger _logger;

  IsLoggedInUseCase(this._repository, this._logger);

  Future<bool> call() async {
    try {
      _logger.d('IsLoggedInUseCase: Checking login status');
      
      final isLoggedIn = await _repository.isLoggedIn();
      
      _logger.d('IsLoggedInUseCase: Login status: $isLoggedIn');
      return isLoggedIn;
    } catch (e) {
      _logger.e('IsLoggedInUseCase: Failed to check login status: $e');
      return false;
    }
  }
}

// Clear Auth Data Use Case
class ClearAuthDataUseCase {
  final AuthRepository _repository;
  final Logger _logger;

  ClearAuthDataUseCase(this._repository, this._logger);

  Future<void> call() async {
    try {
      _logger.d('ClearAuthDataUseCase: Clearing auth data');
      
      await _repository.clearAuthData();
      
      _logger.d('ClearAuthDataUseCase: Auth data cleared successfully');
    } catch (e) {
      _logger.e('ClearAuthDataUseCase: Failed to clear auth data: $e');
      rethrow;
    }
  }
}

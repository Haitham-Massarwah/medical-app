import 'package:json_annotation/json_annotation.dart';

part 'auth_models.g.dart';

// User Roles
enum UserRole {
  @JsonValue('developer')
  developer,
  @JsonValue('admin')
  admin,
  @JsonValue('doctor')
  doctor,
  @JsonValue('paramedical')
  paramedical,
  @JsonValue('patient')
  patient,
}

// User Model
@JsonSerializable()
class UserModel {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String? phone;
  final String? profileImage;
  final UserRole role;
  final String? tenantId;
  final String preferredLanguage;
  final bool isEmailVerified;
  final bool isTwoFactorEnabled;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? lastLoginAt;
  final Map<String, dynamic>? preferences;
  final Map<String, dynamic>? metadata;

  const UserModel({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.phone,
    this.profileImage,
    required this.role,
    this.tenantId,
    this.preferredLanguage = 'he',
    this.isEmailVerified = false,
    this.isTwoFactorEnabled = false,
    required this.createdAt,
    required this.updatedAt,
    this.lastLoginAt,
    this.preferences,
    this.metadata,
  });

  String get fullName => '$firstName $lastName';

  bool get isAdmin => role == UserRole.admin || role == UserRole.developer;
  bool get isDoctor => role == UserRole.doctor || role == UserRole.paramedical;
  bool get isPatient => role == UserRole.patient;
  bool get isDeveloper => role == UserRole.developer;

  factory UserModel.fromJson(Map<String, dynamic> json) => _$UserModelFromJson(json);
  Map<String, dynamic> toJson() => _$UserModelToJson(this);

  UserModel copyWith({
    String? id,
    String? email,
    String? firstName,
    String? lastName,
    String? phone,
    String? profileImage,
    UserRole? role,
    String? tenantId,
    String? preferredLanguage,
    bool? isEmailVerified,
    bool? isTwoFactorEnabled,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastLoginAt,
    Map<String, dynamic>? preferences,
    Map<String, dynamic>? metadata,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phone: phone ?? this.phone,
      profileImage: profileImage ?? this.profileImage,
      role: role ?? this.role,
      tenantId: tenantId ?? this.tenantId,
      preferredLanguage: preferredLanguage ?? this.preferredLanguage,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      isTwoFactorEnabled: isTwoFactorEnabled ?? this.isTwoFactorEnabled,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      preferences: preferences ?? this.preferences,
      metadata: metadata ?? this.metadata,
    );
  }
}

// Authentication Request Models
@JsonSerializable()
class LoginRequest {
  final String email;
  final String password;
  final String? twoFactorCode;
  final bool rememberMe;

  const LoginRequest({
    required this.email,
    required this.password,
    this.twoFactorCode,
    this.rememberMe = false,
  });

  factory LoginRequest.fromJson(Map<String, dynamic> json) => _$LoginRequestFromJson(json);
  Map<String, dynamic> toJson() => _$LoginRequestToJson(this);
}

@JsonSerializable()
class RegisterRequest {
  final String email;
  final String password;
  final String confirmPassword;
  final String firstName;
  final String lastName;
  final String? phone;
  final UserRole role;
  final String? tenantId;
  final String preferredLanguage;
  final Map<String, dynamic>? metadata;

  const RegisterRequest({
    required this.email,
    required this.password,
    required this.confirmPassword,
    required this.firstName,
    required this.lastName,
    this.phone,
    required this.role,
    this.tenantId,
    this.preferredLanguage = 'he',
    this.metadata,
  });

  factory RegisterRequest.fromJson(Map<String, dynamic> json) => _$RegisterRequestFromJson(json);
  Map<String, dynamic> toJson() => _$RegisterRequestToJson(this);
}

@JsonSerializable()
class RefreshTokenRequest {
  final String refreshToken;

  const RefreshTokenRequest({
    required this.refreshToken,
  });

  factory RefreshTokenRequest.fromJson(Map<String, dynamic> json) => _$RefreshTokenRequestFromJson(json);
  Map<String, dynamic> toJson() => _$RefreshTokenRequestToJson(this);
}

@JsonSerializable()
class ForgotPasswordRequest {
  final String email;

  const ForgotPasswordRequest({
    required this.email,
  });

  factory ForgotPasswordRequest.fromJson(Map<String, dynamic> json) => _$ForgotPasswordRequestFromJson(json);
  Map<String, dynamic> toJson() => _$ForgotPasswordRequestToJson(this);
}

@JsonSerializable()
class ResetPasswordRequest {
  final String token;
  final String newPassword;
  final String confirmPassword;

  const ResetPasswordRequest({
    required this.token,
    required this.newPassword,
    required this.confirmPassword,
  });

  factory ResetPasswordRequest.fromJson(Map<String, dynamic> json) => _$ResetPasswordRequestFromJson(json);
  Map<String, dynamic> toJson() => _$ResetPasswordRequestToJson(this);
}

@JsonSerializable()
class VerifyEmailRequest {
  final String token;

  const VerifyEmailRequest({
    required this.token,
  });

  factory VerifyEmailRequest.fromJson(Map<String, dynamic> json) => _$VerifyEmailRequestFromJson(json);
  Map<String, dynamic> toJson() => _$VerifyEmailRequestToJson(this);
}

@JsonSerializable()
class ResendVerificationRequest {
  final String email;

  const ResendVerificationRequest({
    required this.email,
  });

  factory ResendVerificationRequest.fromJson(Map<String, dynamic> json) => _$ResendVerificationRequestFromJson(json);
  Map<String, dynamic> toJson() => _$ResendVerificationRequestToJson(this);
}

@JsonSerializable()
class ChangePasswordRequest {
  final String currentPassword;
  final String newPassword;
  final String confirmPassword;

  const ChangePasswordRequest({
    required this.currentPassword,
    required this.newPassword,
    required this.confirmPassword,
  });

  factory ChangePasswordRequest.fromJson(Map<String, dynamic> json) => _$ChangePasswordRequestFromJson(json);
  Map<String, dynamic> toJson() => _$ChangePasswordRequestToJson(this);
}

@JsonSerializable()
class VerifyTwoFactorRequest {
  final String code;

  const VerifyTwoFactorRequest({
    required this.code,
  });

  factory VerifyTwoFactorRequest.fromJson(Map<String, dynamic> json) => _$VerifyTwoFactorRequestFromJson(json);
  Map<String, dynamic> toJson() => _$VerifyTwoFactorRequestToJson(this);
}

@JsonSerializable()
class UpdateProfileRequest {
  final String firstName;
  final String lastName;
  final String? phone;
  final String preferredLanguage;
  final Map<String, dynamic>? preferences;

  const UpdateProfileRequest({
    required this.firstName,
    required this.lastName,
    this.phone,
    this.preferredLanguage = 'he',
    this.preferences,
  });

  factory UpdateProfileRequest.fromJson(Map<String, dynamic> json) => _$UpdateProfileRequestFromJson(json);
  Map<String, dynamic> toJson() => _$UpdateProfileRequestToJson(this);
}

// Authentication Response Models
@JsonSerializable()
class AuthResponse {
  final UserModel user;
  final String accessToken;
  final String refreshToken;
  final int expiresIn;
  final String tokenType;

  const AuthResponse({
    required this.user,
    required this.accessToken,
    required this.refreshToken,
    required this.expiresIn,
    this.tokenType = 'Bearer',
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) => _$AuthResponseFromJson(json);
  Map<String, dynamic> toJson() => _$AuthResponseToJson(this);
}

@JsonSerializable()
class TwoFactorSetupResponse {
  final String qrCode;
  final String secretKey;
  final List<String> backupCodes;

  const TwoFactorSetupResponse({
    required this.qrCode,
    required this.secretKey,
    required this.backupCodes,
  });

  factory TwoFactorSetupResponse.fromJson(Map<String, dynamic> json) => _$TwoFactorSetupResponseFromJson(json);
  Map<String, dynamic> toJson() => _$TwoFactorSetupResponseToJson(this);
}

// Tenant Model
@JsonSerializable()
class TenantModel {
  final String id;
  final String name;
  final String? description;
  final String? logo;
  final String? website;
  final String? email;
  final String? phone;
  final String? address;
  final String? city;
  final String? country;
  final String? timezone;
  final String? currency;
  final String? language;
  final Map<String, dynamic>? settings;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const TenantModel({
    required this.id,
    required this.name,
    this.description,
    this.logo,
    this.website,
    this.email,
    this.phone,
    this.address,
    this.city,
    this.country,
    this.timezone,
    this.currency,
    this.language,
    this.settings,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TenantModel.fromJson(Map<String, dynamic> json) => _$TenantModelFromJson(json);
  Map<String, dynamic> toJson() => _$TenantModelToJson(this);

  TenantModel copyWith({
    String? id,
    String? name,
    String? description,
    String? logo,
    String? website,
    String? email,
    String? phone,
    String? address,
    String? city,
    String? country,
    String? timezone,
    String? currency,
    String? language,
    Map<String, dynamic>? settings,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TenantModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      logo: logo ?? this.logo,
      website: website ?? this.website,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      city: city ?? this.city,
      country: country ?? this.country,
      timezone: timezone ?? this.timezone,
      currency: currency ?? this.currency,
      language: language ?? this.language,
      settings: settings ?? this.settings,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

// Create Tenant Request
@JsonSerializable()
class CreateTenantRequest {
  final String name;
  final String? description;
  final String? website;
  final String? email;
  final String? phone;
  final String? address;
  final String? city;
  final String? country;
  final String? timezone;
  final String? currency;
  final String? language;

  const CreateTenantRequest({
    required this.name,
    this.description,
    this.website,
    this.email,
    this.phone,
    this.address,
    this.city,
    this.country,
    this.timezone,
    this.currency,
    this.language,
  });

  factory CreateTenantRequest.fromJson(Map<String, dynamic> json) => _$CreateTenantRequestFromJson(json);
  Map<String, dynamic> toJson() => _$CreateTenantRequestToJson(this);
}

@JsonSerializable()
class UpdateTenantRequest {
  final String? name;
  final String? description;
  final String? website;
  final String? email;
  final String? phone;
  final String? address;
  final String? city;
  final String? country;
  final String? timezone;
  final String? currency;
  final String? language;

  const UpdateTenantRequest({
    this.name,
    this.description,
    this.website,
    this.email,
    this.phone,
    this.address,
    this.city,
    this.country,
    this.timezone,
    this.currency,
    this.language,
  });

  factory UpdateTenantRequest.fromJson(Map<String, dynamic> json) => _$UpdateTenantRequestFromJson(json);
  Map<String, dynamic> toJson() => _$UpdateTenantRequestToJson(this);
}

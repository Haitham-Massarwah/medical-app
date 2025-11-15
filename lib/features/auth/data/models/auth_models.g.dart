// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserModel _$UserModelFromJson(Map<String, dynamic> json) => UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      phone: json['phone'] as String?,
      profileImage: json['profileImage'] as String?,
      role: $enumDecode(_$UserRoleEnumMap, json['role']),
      tenantId: json['tenantId'] as String?,
      preferredLanguage: json['preferredLanguage'] as String? ?? 'he',
      isEmailVerified: json['isEmailVerified'] as bool? ?? false,
      isTwoFactorEnabled: json['isTwoFactorEnabled'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      lastLoginAt: json['lastLoginAt'] == null
          ? null
          : DateTime.parse(json['lastLoginAt'] as String),
      preferences: json['preferences'] as Map<String, dynamic>?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$UserModelToJson(UserModel instance) => <String, dynamic>{
      'id': instance.id,
      'email': instance.email,
      'firstName': instance.firstName,
      'lastName': instance.lastName,
      'phone': instance.phone,
      'profileImage': instance.profileImage,
      'role': _$UserRoleEnumMap[instance.role]!,
      'tenantId': instance.tenantId,
      'preferredLanguage': instance.preferredLanguage,
      'isEmailVerified': instance.isEmailVerified,
      'isTwoFactorEnabled': instance.isTwoFactorEnabled,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'lastLoginAt': instance.lastLoginAt?.toIso8601String(),
      'preferences': instance.preferences,
      'metadata': instance.metadata,
    };

const _$UserRoleEnumMap = {
  UserRole.developer: 'developer',
  UserRole.admin: 'admin',
  UserRole.doctor: 'doctor',
  UserRole.paramedical: 'paramedical',
  UserRole.patient: 'patient',
};

LoginRequest _$LoginRequestFromJson(Map<String, dynamic> json) => LoginRequest(
      email: json['email'] as String,
      password: json['password'] as String,
      twoFactorCode: json['twoFactorCode'] as String?,
      rememberMe: json['rememberMe'] as bool? ?? false,
    );

Map<String, dynamic> _$LoginRequestToJson(LoginRequest instance) =>
    <String, dynamic>{
      'email': instance.email,
      'password': instance.password,
      'twoFactorCode': instance.twoFactorCode,
      'rememberMe': instance.rememberMe,
    };

RegisterRequest _$RegisterRequestFromJson(Map<String, dynamic> json) =>
    RegisterRequest(
      email: json['email'] as String,
      password: json['password'] as String,
      confirmPassword: json['confirmPassword'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      phone: json['phone'] as String?,
      role: $enumDecode(_$UserRoleEnumMap, json['role']),
      tenantId: json['tenantId'] as String?,
      preferredLanguage: json['preferredLanguage'] as String? ?? 'he',
      metadata: json['metadata'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$RegisterRequestToJson(RegisterRequest instance) =>
    <String, dynamic>{
      'email': instance.email,
      'password': instance.password,
      'confirmPassword': instance.confirmPassword,
      'firstName': instance.firstName,
      'lastName': instance.lastName,
      'phone': instance.phone,
      'role': _$UserRoleEnumMap[instance.role]!,
      'tenantId': instance.tenantId,
      'preferredLanguage': instance.preferredLanguage,
      'metadata': instance.metadata,
    };

RefreshTokenRequest _$RefreshTokenRequestFromJson(Map<String, dynamic> json) =>
    RefreshTokenRequest(
      refreshToken: json['refreshToken'] as String,
    );

Map<String, dynamic> _$RefreshTokenRequestToJson(
        RefreshTokenRequest instance) =>
    <String, dynamic>{
      'refreshToken': instance.refreshToken,
    };

ForgotPasswordRequest _$ForgotPasswordRequestFromJson(
        Map<String, dynamic> json) =>
    ForgotPasswordRequest(
      email: json['email'] as String,
    );

Map<String, dynamic> _$ForgotPasswordRequestToJson(
        ForgotPasswordRequest instance) =>
    <String, dynamic>{
      'email': instance.email,
    };

ResetPasswordRequest _$ResetPasswordRequestFromJson(
        Map<String, dynamic> json) =>
    ResetPasswordRequest(
      token: json['token'] as String,
      newPassword: json['newPassword'] as String,
      confirmPassword: json['confirmPassword'] as String,
    );

Map<String, dynamic> _$ResetPasswordRequestToJson(
        ResetPasswordRequest instance) =>
    <String, dynamic>{
      'token': instance.token,
      'newPassword': instance.newPassword,
      'confirmPassword': instance.confirmPassword,
    };

VerifyEmailRequest _$VerifyEmailRequestFromJson(Map<String, dynamic> json) =>
    VerifyEmailRequest(
      token: json['token'] as String,
    );

Map<String, dynamic> _$VerifyEmailRequestToJson(VerifyEmailRequest instance) =>
    <String, dynamic>{
      'token': instance.token,
    };

ResendVerificationRequest _$ResendVerificationRequestFromJson(
        Map<String, dynamic> json) =>
    ResendVerificationRequest(
      email: json['email'] as String,
    );

Map<String, dynamic> _$ResendVerificationRequestToJson(
        ResendVerificationRequest instance) =>
    <String, dynamic>{
      'email': instance.email,
    };

ChangePasswordRequest _$ChangePasswordRequestFromJson(
        Map<String, dynamic> json) =>
    ChangePasswordRequest(
      currentPassword: json['currentPassword'] as String,
      newPassword: json['newPassword'] as String,
      confirmPassword: json['confirmPassword'] as String,
    );

Map<String, dynamic> _$ChangePasswordRequestToJson(
        ChangePasswordRequest instance) =>
    <String, dynamic>{
      'currentPassword': instance.currentPassword,
      'newPassword': instance.newPassword,
      'confirmPassword': instance.confirmPassword,
    };

VerifyTwoFactorRequest _$VerifyTwoFactorRequestFromJson(
        Map<String, dynamic> json) =>
    VerifyTwoFactorRequest(
      code: json['code'] as String,
    );

Map<String, dynamic> _$VerifyTwoFactorRequestToJson(
        VerifyTwoFactorRequest instance) =>
    <String, dynamic>{
      'code': instance.code,
    };

UpdateProfileRequest _$UpdateProfileRequestFromJson(
        Map<String, dynamic> json) =>
    UpdateProfileRequest(
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      phone: json['phone'] as String?,
      preferredLanguage: json['preferredLanguage'] as String? ?? 'he',
      preferences: json['preferences'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$UpdateProfileRequestToJson(
        UpdateProfileRequest instance) =>
    <String, dynamic>{
      'firstName': instance.firstName,
      'lastName': instance.lastName,
      'phone': instance.phone,
      'preferredLanguage': instance.preferredLanguage,
      'preferences': instance.preferences,
    };

AuthResponse _$AuthResponseFromJson(Map<String, dynamic> json) => AuthResponse(
      user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String,
      expiresIn: (json['expiresIn'] as num).toInt(),
      tokenType: json['tokenType'] as String? ?? 'Bearer',
    );

Map<String, dynamic> _$AuthResponseToJson(AuthResponse instance) =>
    <String, dynamic>{
      'user': instance.user,
      'accessToken': instance.accessToken,
      'refreshToken': instance.refreshToken,
      'expiresIn': instance.expiresIn,
      'tokenType': instance.tokenType,
    };

TwoFactorSetupResponse _$TwoFactorSetupResponseFromJson(
        Map<String, dynamic> json) =>
    TwoFactorSetupResponse(
      qrCode: json['qrCode'] as String,
      secretKey: json['secretKey'] as String,
      backupCodes: (json['backupCodes'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$TwoFactorSetupResponseToJson(
        TwoFactorSetupResponse instance) =>
    <String, dynamic>{
      'qrCode': instance.qrCode,
      'secretKey': instance.secretKey,
      'backupCodes': instance.backupCodes,
    };

TenantModel _$TenantModelFromJson(Map<String, dynamic> json) => TenantModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      logo: json['logo'] as String?,
      website: json['website'] as String?,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      address: json['address'] as String?,
      city: json['city'] as String?,
      country: json['country'] as String?,
      timezone: json['timezone'] as String?,
      currency: json['currency'] as String?,
      language: json['language'] as String?,
      settings: json['settings'] as Map<String, dynamic>?,
      isActive: json['isActive'] as bool? ?? true,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$TenantModelToJson(TenantModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'logo': instance.logo,
      'website': instance.website,
      'email': instance.email,
      'phone': instance.phone,
      'address': instance.address,
      'city': instance.city,
      'country': instance.country,
      'timezone': instance.timezone,
      'currency': instance.currency,
      'language': instance.language,
      'settings': instance.settings,
      'isActive': instance.isActive,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

CreateTenantRequest _$CreateTenantRequestFromJson(Map<String, dynamic> json) =>
    CreateTenantRequest(
      name: json['name'] as String,
      description: json['description'] as String?,
      website: json['website'] as String?,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      address: json['address'] as String?,
      city: json['city'] as String?,
      country: json['country'] as String?,
      timezone: json['timezone'] as String?,
      currency: json['currency'] as String?,
      language: json['language'] as String?,
    );

Map<String, dynamic> _$CreateTenantRequestToJson(
        CreateTenantRequest instance) =>
    <String, dynamic>{
      'name': instance.name,
      'description': instance.description,
      'website': instance.website,
      'email': instance.email,
      'phone': instance.phone,
      'address': instance.address,
      'city': instance.city,
      'country': instance.country,
      'timezone': instance.timezone,
      'currency': instance.currency,
      'language': instance.language,
    };

UpdateTenantRequest _$UpdateTenantRequestFromJson(Map<String, dynamic> json) =>
    UpdateTenantRequest(
      name: json['name'] as String?,
      description: json['description'] as String?,
      website: json['website'] as String?,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      address: json['address'] as String?,
      city: json['city'] as String?,
      country: json['country'] as String?,
      timezone: json['timezone'] as String?,
      currency: json['currency'] as String?,
      language: json['language'] as String?,
    );

Map<String, dynamic> _$UpdateTenantRequestToJson(
        UpdateTenantRequest instance) =>
    <String, dynamic>{
      'name': instance.name,
      'description': instance.description,
      'website': instance.website,
      'email': instance.email,
      'phone': instance.phone,
      'address': instance.address,
      'city': instance.city,
      'country': instance.country,
      'timezone': instance.timezone,
      'currency': instance.currency,
      'language': instance.language,
    };

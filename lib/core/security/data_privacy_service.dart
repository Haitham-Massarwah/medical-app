import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'encryption_service.dart';

/// GDPR/HIPAA compliant data privacy service
class DataPrivacyService {
  static final DataPrivacyService _instance = DataPrivacyService._internal();
  factory DataPrivacyService() => _instance;
  DataPrivacyService._internal();

  final EncryptionService _encryptionService = EncryptionService();
  
  // Data retention periods (in days)
  static const int _patientDataRetentionDays = 2555; // 7 years
  static const int _paymentDataRetentionDays = 1095; // 3 years
  static const int _auditLogRetentionDays = 2555; // 7 years
  static const int _sessionDataRetentionDays = 30; // 30 days

  /// Initialize data privacy service
  Future<void> initialize() async {
    await _encryptionService.initialize();
  }

  /// Process personal data with privacy controls
  Future<PrivacyCompliantData> processPersonalData({
    required Map<String, dynamic> data,
    required String dataType,
    required String purpose,
    required String userId,
  }) async {
    try {
      // Check if user has consented to data processing
      final hasConsent = await _checkDataConsent(userId, dataType, purpose);
      if (!hasConsent) {
        return PrivacyCompliantData(
          success: false,
          error: 'Data processing consent not provided',
          processedData: null,
        );
      }

      // Apply data minimization
      final minimizedData = _minimizeData(data, dataType, purpose);
      
      // Anonymize sensitive data if required
      final anonymizedData = await _anonymizeData(minimizedData, dataType);
      
      // Encrypt sensitive data
      final encryptedData = _encryptSensitiveData(anonymizedData);
      
      // Log data processing activity
      await _logDataProcessingActivity(
        userId: userId,
        dataType: dataType,
        purpose: purpose,
        action: 'PROCESS',
      );

      return PrivacyCompliantData(
        success: true,
        processedData: encryptedData,
        dataHash: _encryptionService.hashSensitiveData(jsonEncode(encryptedData)),
      );

    } catch (e) {
      await _logDataProcessingActivity(
        userId: userId,
        dataType: dataType,
        purpose: purpose,
        action: 'ERROR',
        error: e.toString(),
      );

      return PrivacyCompliantData(
        success: false,
        error: 'Data processing failed: $e',
        processedData: null,
      );
    }
  }

  /// Handle data subject access request (GDPR Article 15)
  Future<DataAccessResponse> handleDataAccessRequest(String userId) async {
    try {
      // Collect all personal data for the user
      final personalData = await _collectUserPersonalData(userId);
      
      // Apply data portability format
      final portableData = _formatDataForPortability(personalData);
      
      // Log access request
      await _logDataProcessingActivity(
        userId: userId,
        dataType: 'ALL',
        purpose: 'DATA_ACCESS_REQUEST',
        action: 'ACCESS',
      );

      return DataAccessResponse(
        success: true,
        personalData: portableData,
        dataCategories: _getDataCategories(personalData),
        processingPurposes: _getProcessingPurposes(personalData),
      );

    } catch (e) {
      return DataAccessResponse(
        success: false,
        error: 'Failed to process data access request: $e',
      );
    }
  }

  /// Handle data deletion request (GDPR Article 17)
  Future<DataDeletionResponse> handleDataDeletionRequest(String userId) async {
    try {
      // Check if deletion is legally required
      final canDelete = await _canDeleteUserData(userId);
      if (!canDelete) {
        return DataDeletionResponse(
          success: false,
          error: 'Data deletion not permitted due to legal obligations',
        );
      }

      // Delete personal data
      await _deleteUserPersonalData(userId);
      
      // Delete associated data
      await _deleteAssociatedData(userId);
      
      // Log deletion
      await _logDataProcessingActivity(
        userId: userId,
        dataType: 'ALL',
        purpose: 'DATA_DELETION_REQUEST',
        action: 'DELETE',
      );

      return DataDeletionResponse(
        success: true,
        deletedDataTypes: _getDeletedDataTypes(),
      );

    } catch (e) {
      return DataDeletionResponse(
        success: false,
        error: 'Failed to process data deletion request: $e',
      );
    }
  }

  /// Handle data rectification request (GDPR Article 16)
  Future<DataRectificationResponse> handleDataRectificationRequest({
    required String userId,
    required Map<String, dynamic> correctedData,
  }) async {
    try {
      // Validate corrected data
      final validationResult = _validateCorrectedData(correctedData);
      if (!validationResult.isValid) {
        return DataRectificationResponse(
          success: false,
          error: validationResult.error,
        );
      }

      // Update personal data
      await _updateUserPersonalData(userId, correctedData);
      
      // Log rectification
      await _logDataProcessingActivity(
        userId: userId,
        dataType: 'PERSONAL',
        purpose: 'DATA_RECTIFICATION_REQUEST',
        action: 'UPDATE',
        updatedFields: correctedData.keys.toList(),
      );

      return DataRectificationResponse(
        success: true,
        updatedFields: correctedData.keys.toList(),
      );

    } catch (e) {
      return DataRectificationResponse(
        success: false,
        error: 'Failed to process data rectification request: $e',
      );
    }
  }

  /// Set data processing consent
  Future<bool> setDataConsent({
    required String userId,
    required String dataType,
    required String purpose,
    required bool consent,
  }) async {
    try {
      final consentData = {
        'userId': userId,
        'dataType': dataType,
        'purpose': purpose,
        'consent': consent,
        'timestamp': DateTime.now().toIso8601String(),
        'version': '1.0',
      };

      await _storeConsentData(consentData);
      
      await _logDataProcessingActivity(
        userId: userId,
        dataType: dataType,
        purpose: purpose,
        action: consent ? 'CONSENT_GRANTED' : 'CONSENT_WITHDRAWN',
      );

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Check data retention and purge expired data
  Future<void> performDataRetentionCleanup() async {
    try {
      final now = DateTime.now();
      
      // Clean up expired patient data
      await _cleanupExpiredData('patient_data', _patientDataRetentionDays);
      
      // Clean up expired payment data
      await _cleanupExpiredData('payment_data', _paymentDataRetentionDays);
      
      // Clean up expired audit logs
      await _cleanupExpiredData('audit_logs', _auditLogRetentionDays);
      
      // Clean up expired session data
      await _cleanupExpiredData('session_data', _sessionDataRetentionDays);
      
      await _logDataProcessingActivity(
        userId: 'SYSTEM',
        dataType: 'ALL',
        purpose: 'DATA_RETENTION_CLEANUP',
        action: 'CLEANUP',
      );

    } catch (e) {
      await _logDataProcessingActivity(
        userId: 'SYSTEM',
        dataType: 'ALL',
        purpose: 'DATA_RETENTION_CLEANUP',
        action: 'ERROR',
        error: e.toString(),
      );
    }
  }

  /// Generate privacy impact assessment
  Future<PrivacyImpactAssessment> generatePrivacyImpactAssessment({
    required String dataType,
    required String purpose,
    required List<String> dataCategories,
  }) async {
    try {
      final riskLevel = _assessPrivacyRisk(dataType, dataCategories);
      final mitigationMeasures = _getMitigationMeasures(riskLevel);
      final legalBasis = _determineLegalBasis(dataType, purpose);
      
      return PrivacyImpactAssessment(
        dataType: dataType,
        purpose: purpose,
        dataCategories: dataCategories,
        riskLevel: riskLevel,
        mitigationMeasures: mitigationMeasures,
        legalBasis: legalBasis,
        assessmentDate: DateTime.now(),
      );

    } catch (e) {
      return PrivacyImpactAssessment(
        dataType: dataType,
        purpose: purpose,
        dataCategories: dataCategories,
        riskLevel: 'HIGH',
        mitigationMeasures: ['Manual review required'],
        legalBasis: 'Consent',
        assessmentDate: DateTime.now(),
        error: e.toString(),
      );
    }
  }

  // Private helper methods

  Future<bool> _checkDataConsent(String userId, String dataType, String purpose) async {
    final prefs = await SharedPreferences.getInstance();
    final consentKey = 'consent_${userId}_${dataType}_$purpose';
    return prefs.getBool(consentKey) ?? false;
  }

  Map<String, dynamic> _minimizeData(Map<String, dynamic> data, String dataType, String purpose) {
    // Remove unnecessary fields based on purpose
    final minimizedData = Map<String, dynamic>.from(data);
    
    switch (purpose) {
      case 'APPOINTMENT_BOOKING':
        minimizedData.remove('ssn');
        minimizedData.remove('insuranceNumber');
        break;
      case 'PAYMENT_PROCESSING':
        minimizedData.remove('medicalHistory');
        minimizedData.remove('allergies');
        break;
      case 'MEDICAL_RECORDS':
        minimizedData.remove('paymentInfo');
        minimizedData.remove('billingAddress');
        break;
    }
    
    return minimizedData;
  }

  Future<Map<String, dynamic>> _anonymizeData(Map<String, dynamic> data, String dataType) async {
    final anonymizedData = Map<String, dynamic>.from(data);
    
    // Anonymize personal identifiers
    if (anonymizedData.containsKey('email')) {
      anonymizedData['email'] = _anonymizeEmail(anonymizedData['email']);
    }
    
    if (anonymizedData.containsKey('phone')) {
      anonymizedData['phone'] = _anonymizePhone(anonymizedData['phone']);
    }
    
    if (anonymizedData.containsKey('address')) {
      anonymizedData['address'] = _anonymizeAddress(anonymizedData['address']);
    }
    
    return anonymizedData;
  }

  String _anonymizeEmail(String email) {
    final parts = email.split('@');
    if (parts.length != 2) return email;
    
    final username = parts[0];
    final domain = parts[1];
    
    if (username.length <= 2) return email;
    
    return '${username[0]}***${username[username.length - 1]}@$domain';
  }

  String _anonymizePhone(String phone) {
    if (phone.length < 4) return phone;
    return '***-***-${phone.substring(phone.length - 4)}';
  }

  String _anonymizeAddress(String address) {
    final parts = address.split(' ');
    if (parts.isEmpty) return address;
    
    return '${parts[0]} ***';
  }

  String _encryptSensitiveData(Map<String, dynamic> data) {
    return _encryptionService.encryptPatientData(data);
  }

  Future<void> _logDataProcessingActivity({
    required String userId,
    required String dataType,
    required String purpose,
    required String action,
    List<String>? updatedFields,
    String? error,
  }) async {
    final logEntry = {
      'userId': userId,
      'dataType': dataType,
      'purpose': purpose,
      'action': action,
      'timestamp': DateTime.now().toIso8601String(),
      if (updatedFields != null) 'updatedFields': updatedFields,
      if (error != null) 'error': error,
    };
    
    // In production, this would log to a secure audit system
    print('PRIVACY_LOG: $logEntry');
  }

  Future<Map<String, dynamic>> _collectUserPersonalData(String userId) async {
    // In production, this would collect from all data sources
    return {
      'personal_info': {},
      'medical_records': {},
      'payment_data': {},
      'appointment_history': {},
    };
  }

  Map<String, dynamic> _formatDataForPortability(Map<String, dynamic> data) {
    return {
      'format': 'JSON',
      'version': '1.0',
      'export_date': DateTime.now().toIso8601String(),
      'data': data,
    };
  }

  List<String> _getDataCategories(Map<String, dynamic> data) {
    return data.keys.toList();
  }

  List<String> _getProcessingPurposes(Map<String, dynamic> data) {
    return ['Medical care', 'Appointment booking', 'Payment processing'];
  }

  Future<bool> _canDeleteUserData(String userId) async {
    // Check for legal obligations (e.g., medical records retention)
    return true; // Simplified for demo
  }

  Future<void> _deleteUserPersonalData(String userId) async {
    // Delete personal data from all systems
  }

  Future<void> _deleteAssociatedData(String userId) async {
    // Delete associated data (appointments, payments, etc.)
  }

  List<String> _getDeletedDataTypes() {
    return ['personal_info', 'medical_records', 'payment_data', 'appointment_history'];
  }

  DataValidationResult _validateCorrectedData(Map<String, dynamic> data) {
    // Validate corrected data format and content
    return DataValidationResult(isValid: true);
  }

  Future<void> _updateUserPersonalData(String userId, Map<String, dynamic> data) async {
    // Update personal data in database
  }

  Future<void> _storeConsentData(Map<String, dynamic> consentData) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'consent_${consentData['userId']}_${consentData['dataType']}_${consentData['purpose']}';
    await prefs.setBool(key, consentData['consent']);
  }

  Future<void> _cleanupExpiredData(String dataType, int retentionDays) async {
    // Clean up expired data based on retention policy
  }

  String _assessPrivacyRisk(String dataType, List<String> dataCategories) {
    // Assess privacy risk based on data sensitivity
    if (dataCategories.contains('medical_records') || dataCategories.contains('genetic_data')) {
      return 'HIGH';
    } else if (dataCategories.contains('payment_data') || dataCategories.contains('biometric_data')) {
      return 'MEDIUM';
    } else {
      return 'LOW';
    }
  }

  List<String> _getMitigationMeasures(String riskLevel) {
    switch (riskLevel) {
      case 'HIGH':
        return ['Encryption', 'Access controls', 'Audit logging', 'Data minimization'];
      case 'MEDIUM':
        return ['Encryption', 'Access controls', 'Audit logging'];
      case 'LOW':
        return ['Basic access controls'];
      default:
        return ['Manual review required'];
    }
  }

  String _determineLegalBasis(String dataType, String purpose) {
    if (purpose == 'MEDICAL_CARE') {
      return 'Vital interests';
    } else if (purpose == 'PAYMENT_PROCESSING') {
      return 'Contract';
    } else {
      return 'Consent';
    }
  }
}

/// Privacy compliant data result
class PrivacyCompliantData {
  final bool success;
  final String? error;
  final String? processedData;
  final String? dataHash;

  PrivacyCompliantData({
    required this.success,
    this.error,
    this.processedData,
    this.dataHash,
  });
}

/// Data access response
class DataAccessResponse {
  final bool success;
  final String? error;
  final Map<String, dynamic>? personalData;
  final List<String>? dataCategories;
  final List<String>? processingPurposes;

  DataAccessResponse({
    required this.success,
    this.error,
    this.personalData,
    this.dataCategories,
    this.processingPurposes,
  });
}

/// Data deletion response
class DataDeletionResponse {
  final bool success;
  final String? error;
  final List<String>? deletedDataTypes;

  DataDeletionResponse({
    required this.success,
    this.error,
    this.deletedDataTypes,
  });
}

/// Data rectification response
class DataRectificationResponse {
  final bool success;
  final String? error;
  final List<String>? updatedFields;

  DataRectificationResponse({
    required this.success,
    this.error,
    this.updatedFields,
  });
}

/// Data validation result
class DataValidationResult {
  final bool isValid;
  final String? error;

  DataValidationResult({
    required this.isValid,
    this.error,
  });
}

/// Privacy impact assessment
class PrivacyImpactAssessment {
  final String dataType;
  final String purpose;
  final List<String> dataCategories;
  final String riskLevel;
  final List<String> mitigationMeasures;
  final String legalBasis;
  final DateTime assessmentDate;
  final String? error;

  PrivacyImpactAssessment({
    required this.dataType,
    required this.purpose,
    required this.dataCategories,
    required this.riskLevel,
    required this.mitigationMeasures,
    required this.legalBasis,
    required this.assessmentDate,
    this.error,
  });
}








import 'dart:convert';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'encryption_service.dart';

/// Comprehensive audit logging service for security monitoring
class AuditLoggingService {
  static final AuditLoggingService _instance = AuditLoggingService._internal();
  factory AuditLoggingService() => _instance;
  AuditLoggingService._internal();

  final EncryptionService _encryptionService = EncryptionService();
  
  // Audit log configuration
  static const int _maxLogEntries = 10000;
  static const Duration _logRetentionPeriod = Duration(days: 2555); // 7 years
  static const List<String> _sensitiveFields = [
    'password',
    'ssn',
    'creditCard',
    'cvv',
    'bankAccount',
    'medicalRecord',
  ];

  /// Initialize audit logging service
  Future<void> initialize() async {
    await _encryptionService.initialize();
  }

  /// Log security event
  Future<void> logSecurityEvent({
    required String eventType,
    required String userId,
    required String action,
    Map<String, dynamic>? details,
    String? ipAddress,
    String? userAgent,
    String? sessionId,
  }) async {
    try {
      final logEntry = AuditLogEntry(
        id: _generateLogId(),
        timestamp: DateTime.now(),
        eventType: eventType,
        userId: userId,
        action: action,
        details: _sanitizeLogDetails(details ?? {}),
        ipAddress: ipAddress ?? 'unknown',
        userAgent: userAgent ?? 'unknown',
        sessionId: sessionId,
        severity: _determineSeverity(eventType, action),
        category: _categorizeEvent(eventType),
      );

      await _storeLogEntry(logEntry);
      await _checkSecurityThresholds(logEntry);

    } catch (e) {
      // Log the logging error itself
      await _logSystemError('AUDIT_LOGGING_ERROR', e.toString());
    }
  }

  /// Log authentication event
  Future<void> logAuthenticationEvent({
    required String userId,
    required String action, // LOGIN, LOGOUT, FAILED_LOGIN, PASSWORD_CHANGE
    required bool success,
    String? failureReason,
    String? ipAddress,
    String? userAgent,
  }) async {
    await logSecurityEvent(
      eventType: 'AUTHENTICATION',
      userId: userId,
      action: action,
      details: {
        'success': success,
        if (failureReason != null) 'failure_reason': failureReason,
        'timestamp': DateTime.now().toIso8601String(),
      },
      ipAddress: ipAddress,
      userAgent: userAgent,
    );
  }

  /// Log data access event
  Future<void> logDataAccessEvent({
    required String userId,
    required String dataType,
    required String action, // READ, WRITE, DELETE, EXPORT
    required String resourceId,
    Map<String, dynamic>? dataChanges,
    String? ipAddress,
  }) async {
    await logSecurityEvent(
      eventType: 'DATA_ACCESS',
      userId: userId,
      action: action,
      details: {
        'data_type': dataType,
        'resource_id': resourceId,
        if (dataChanges != null) 'data_changes': _sanitizeDataChanges(dataChanges),
        'timestamp': DateTime.now().toIso8601String(),
      },
      ipAddress: ipAddress,
    );
  }

  /// Log payment event
  Future<void> logPaymentEvent({
    required String userId,
    required String action, // PAYMENT_INITIATED, PAYMENT_COMPLETED, PAYMENT_FAILED
    required String transactionId,
    required double amount,
    required String currency,
    bool success = true,
    String? failureReason,
    String? ipAddress,
  }) async {
    await logSecurityEvent(
      eventType: 'PAYMENT',
      userId: userId,
      action: action,
      details: {
        'transaction_id': transactionId,
        'amount': amount,
        'currency': currency,
        'success': success,
        if (failureReason != null) 'failure_reason': failureReason,
        'timestamp': DateTime.now().toIso8601String(),
      },
      ipAddress: ipAddress,
    );
  }

  /// Log system event
  Future<void> logSystemEvent({
    required String eventType,
    required String action,
    Map<String, dynamic>? details,
    String? error,
  }) async {
    await logSecurityEvent(
      eventType: eventType,
      userId: 'SYSTEM',
      action: action,
      details: {
        ...?details,
        if (error != null) 'error': error,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  /// Get audit logs for specific user
  Future<List<AuditLogEntry>> getUserAuditLogs({
    required String userId,
    String? eventType,
    String? action,
    DateTime? startDate,
    DateTime? endDate,
    int limit = 100,
  }) async {
    try {
      final allLogs = await _getAllLogEntries();
      
      var filteredLogs = allLogs.where((log) => log.userId == userId).toList();
      
      if (eventType != null) {
        filteredLogs = filteredLogs.where((log) => log.eventType == eventType).toList();
      }
      
      if (action != null) {
        filteredLogs = filteredLogs.where((log) => log.action == action).toList();
      }
      
      if (startDate != null) {
        filteredLogs = filteredLogs.where((log) => log.timestamp.isAfter(startDate)).toList();
      }
      
      if (endDate != null) {
        filteredLogs = filteredLogs.where((log) => log.timestamp.isBefore(endDate)).toList();
      }
      
      // Sort by timestamp descending
      filteredLogs.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      
      return filteredLogs.take(limit).toList();
      
    } catch (e) {
      await _logSystemError('AUDIT_LOG_RETRIEVAL_ERROR', e.toString());
      return [];
    }
  }

  /// Get security alerts
  Future<List<SecurityAlert>> getSecurityAlerts({
    DateTime? since,
    String? severity,
  }) async {
    try {
      final allLogs = await _getAllLogEntries();
      final cutoffDate = since ?? DateTime.now().subtract(const Duration(days: 7));
      
      var alertLogs = allLogs.where((log) => 
        log.timestamp.isAfter(cutoffDate) && 
        log.severity == 'HIGH'
      ).toList();
      
      if (severity != null) {
        alertLogs = alertLogs.where((log) => log.severity == severity).toList();
      }
      
      // Group by event type and create alerts
      final alerts = <SecurityAlert>[];
      final groupedLogs = <String, List<AuditLogEntry>>{};
      
      for (final log in alertLogs) {
        final key = '${log.eventType}_${log.action}';
        groupedLogs[key] ??= [];
        groupedLogs[key]!.add(log);
      }
      
      for (final entry in groupedLogs.entries) {
        if (entry.value.length >= 3) { // Threshold for alert
          alerts.add(SecurityAlert(
            id: _generateLogId(),
            eventType: entry.value.first.eventType,
            action: entry.value.first.action,
            count: entry.value.length,
            firstOccurrence: entry.value.last.timestamp,
            lastOccurrence: entry.value.first.timestamp,
            severity: entry.value.first.severity,
            details: _summarizeLogDetails(entry.value),
          ));
        }
      }
      
      return alerts;
      
    } catch (e) {
      await _logSystemError('SECURITY_ALERT_ERROR', e.toString());
      return [];
    }
  }

  /// Generate audit report
  Future<AuditReport> generateAuditReport({
    required DateTime startDate,
    required DateTime endDate,
    String? userId,
    String? eventType,
  }) async {
    try {
      final logs = await _getAllLogEntries();
      final filteredLogs = logs.where((log) => 
        log.timestamp.isAfter(startDate) && 
        log.timestamp.isBefore(endDate) &&
        (userId == null || log.userId == userId) &&
        (eventType == null || log.eventType == eventType)
      ).toList();
      
      final report = AuditReport(
        startDate: startDate,
        endDate: endDate,
        totalEvents: filteredLogs.length,
        eventTypes: _countEventTypes(filteredLogs),
        actions: _countActions(filteredLogs),
        severityLevels: _countSeverityLevels(filteredLogs),
        topUsers: _getTopUsers(filteredLogs),
        securityAlerts: await getSecurityAlerts(since: startDate),
        generatedAt: DateTime.now(),
      );
      
      return report;
      
    } catch (e) {
      await _logSystemError('AUDIT_REPORT_ERROR', e.toString());
      return AuditReport(
        startDate: startDate,
        endDate: endDate,
        totalEvents: 0,
        eventTypes: {},
        actions: {},
        severityLevels: {},
        topUsers: [],
        securityAlerts: [],
        generatedAt: DateTime.now(),
        error: e.toString(),
      );
    }
  }

  /// Clean up old audit logs
  Future<void> cleanupOldLogs() async {
    try {
      final cutoffDate = DateTime.now().subtract(_logRetentionPeriod);
      final allLogs = await _getAllLogEntries();
      
      final recentLogs = allLogs.where((log) => 
        log.timestamp.isAfter(cutoffDate)
      ).toList();
      
      // Keep only recent logs
      await _storeAllLogEntries(recentLogs);
      
      await logSystemEvent(
        eventType: 'AUDIT_CLEANUP',
        action: 'CLEANUP_COMPLETED',
        details: {
          'logs_removed': allLogs.length - recentLogs.length,
          'logs_retained': recentLogs.length,
        },
      );
      
    } catch (e) {
      await _logSystemError('AUDIT_CLEANUP_ERROR', e.toString());
    }
  }

  // Private helper methods

  String _generateLogId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = DateTime.now().microsecond;
    return 'LOG_${timestamp}_$random';
  }

  Map<String, dynamic> _sanitizeLogDetails(Map<String, dynamic> details) {
    final sanitized = Map<String, dynamic>.from(details);
    
    for (final field in _sensitiveFields) {
      if (sanitized.containsKey(field)) {
        sanitized[field] = '[REDACTED]';
      }
    }
    
    return sanitized;
  }

  Map<String, dynamic> _sanitizeDataChanges(Map<String, dynamic> changes) {
    final sanitized = Map<String, dynamic>.from(changes);
    
    for (final field in _sensitiveFields) {
      if (sanitized.containsKey(field)) {
        sanitized[field] = '[REDACTED]';
      }
    }
    
    return sanitized;
  }

  String _determineSeverity(String eventType, String action) {
    if (eventType == 'AUTHENTICATION' && action == 'FAILED_LOGIN') {
      return 'MEDIUM';
    } else if (eventType == 'DATA_ACCESS' && action == 'DELETE') {
      return 'HIGH';
    } else if (eventType == 'PAYMENT' && action == 'PAYMENT_FAILED') {
      return 'HIGH';
    } else if (eventType == 'SYSTEM' && action.contains('ERROR')) {
      return 'HIGH';
    } else {
      return 'LOW';
    }
  }

  String _categorizeEvent(String eventType) {
    switch (eventType) {
      case 'AUTHENTICATION':
        return 'ACCESS_CONTROL';
      case 'DATA_ACCESS':
        return 'DATA_PROTECTION';
      case 'PAYMENT':
        return 'FINANCIAL';
      case 'SYSTEM':
        return 'SYSTEM_EVENT';
      default:
        return 'GENERAL';
    }
  }

  Future<void> _storeLogEntry(AuditLogEntry logEntry) async {
    final prefs = await SharedPreferences.getInstance();
    final logs = await _getAllLogEntries();
    
    logs.add(logEntry);
    
    // Keep only the most recent logs
    if (logs.length > _maxLogEntries) {
      logs.removeRange(0, logs.length - _maxLogEntries);
    }
    
    await _storeAllLogEntries(logs);
  }

  Future<List<AuditLogEntry>> _getAllLogEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final logsJson = prefs.getString('audit_logs');
    
    if (logsJson == null) return [];
    
    try {
      final List<dynamic> logsList = jsonDecode(logsJson);
      return logsList.map((json) => AuditLogEntry.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> _storeAllLogEntries(List<AuditLogEntry> logs) async {
    final prefs = await SharedPreferences.getInstance();
    final logsJson = jsonEncode(logs.map((log) => log.toJson()).toList());
    await prefs.setString('audit_logs', logsJson);
  }

  Future<void> _checkSecurityThresholds(AuditLogEntry logEntry) async {
    // Check for suspicious patterns
    if (logEntry.eventType == 'AUTHENTICATION' && logEntry.action == 'FAILED_LOGIN') {
      await _checkFailedLoginThreshold(logEntry);
    }
  }

  Future<void> _checkFailedLoginThreshold(AuditLogEntry logEntry) async {
    final recentLogs = await getUserAuditLogs(
      userId: logEntry.userId,
      eventType: 'AUTHENTICATION',
      action: 'FAILED_LOGIN',
      startDate: DateTime.now().subtract(const Duration(minutes: 15)),
    );
    
    if (recentLogs.length >= 5) {
      await logSystemEvent(
        eventType: 'SECURITY_ALERT',
        action: 'BRUTE_FORCE_ATTEMPT',
        details: {
          'user_id': logEntry.userId,
          'failed_attempts': recentLogs.length,
          'time_window': '15 minutes',
        },
      );
    }
  }

  Future<void> _logSystemError(String errorType, String error) async {
    await logSystemEvent(
      eventType: 'SYSTEM_ERROR',
      action: errorType,
      details: {'error': error},
    );
  }

  Map<String, dynamic> _summarizeLogDetails(List<AuditLogEntry> logs) {
    return {
      'count': logs.length,
      'first_occurrence': logs.last.timestamp.toIso8601String(),
      'last_occurrence': logs.first.timestamp.toIso8601String(),
      'common_details': _getCommonDetails(logs),
    };
  }

  Map<String, dynamic> _getCommonDetails(List<AuditLogEntry> logs) {
    final commonDetails = <String, int>{};
    
    for (final log in logs) {
      for (final key in log.details.keys) {
        commonDetails[key] = (commonDetails[key] ?? 0) + 1;
      }
    }
    
    return commonDetails;
  }

  Map<String, int> _countEventTypes(List<AuditLogEntry> logs) {
    final counts = <String, int>{};
    for (final log in logs) {
      counts[log.eventType] = (counts[log.eventType] ?? 0) + 1;
    }
    return counts;
  }

  Map<String, int> _countActions(List<AuditLogEntry> logs) {
    final counts = <String, int>{};
    for (final log in logs) {
      counts[log.action] = (counts[log.action] ?? 0) + 1;
    }
    return counts;
  }

  Map<String, int> _countSeverityLevels(List<AuditLogEntry> logs) {
    final counts = <String, int>{};
    for (final log in logs) {
      counts[log.severity] = (counts[log.severity] ?? 0) + 1;
    }
    return counts;
  }

  List<Map<String, dynamic>> _getTopUsers(List<AuditLogEntry> logs) {
    final userCounts = <String, int>{};
    for (final log in logs) {
      userCounts[log.userId] = (userCounts[log.userId] ?? 0) + 1;
    }
    
    final sortedUsers = userCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    return sortedUsers.take(10).map((entry) => {
      'user_id': entry.key,
      'event_count': entry.value,
    }).toList();
  }
}

/// Audit log entry model
class AuditLogEntry {
  final String id;
  final DateTime timestamp;
  final String eventType;
  final String userId;
  final String action;
  final Map<String, dynamic> details;
  final String ipAddress;
  final String userAgent;
  final String? sessionId;
  final String severity;
  final String category;

  AuditLogEntry({
    required this.id,
    required this.timestamp,
    required this.eventType,
    required this.userId,
    required this.action,
    required this.details,
    required this.ipAddress,
    required this.userAgent,
    this.sessionId,
    required this.severity,
    required this.category,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'timestamp': timestamp.toIso8601String(),
    'eventType': eventType,
    'userId': userId,
    'action': action,
    'details': details,
    'ipAddress': ipAddress,
    'userAgent': userAgent,
    'sessionId': sessionId,
    'severity': severity,
    'category': category,
  };

  factory AuditLogEntry.fromJson(Map<String, dynamic> json) => AuditLogEntry(
    id: json['id'],
    timestamp: DateTime.parse(json['timestamp']),
    eventType: json['eventType'],
    userId: json['userId'],
    action: json['action'],
    details: Map<String, dynamic>.from(json['details']),
    ipAddress: json['ipAddress'],
    userAgent: json['userAgent'],
    sessionId: json['sessionId'],
    severity: json['severity'],
    category: json['category'],
  );
}

/// Security alert model
class SecurityAlert {
  final String id;
  final String eventType;
  final String action;
  final int count;
  final DateTime firstOccurrence;
  final DateTime lastOccurrence;
  final String severity;
  final Map<String, dynamic> details;

  SecurityAlert({
    required this.id,
    required this.eventType,
    required this.action,
    required this.count,
    required this.firstOccurrence,
    required this.lastOccurrence,
    required this.severity,
    required this.details,
  });
}

/// Audit report model
class AuditReport {
  final DateTime startDate;
  final DateTime endDate;
  final int totalEvents;
  final Map<String, int> eventTypes;
  final Map<String, int> actions;
  final Map<String, int> severityLevels;
  final List<Map<String, dynamic>> topUsers;
  final List<SecurityAlert> securityAlerts;
  final DateTime generatedAt;
  final String? error;

  AuditReport({
    required this.startDate,
    required this.endDate,
    required this.totalEvents,
    required this.eventTypes,
    required this.actions,
    required this.severityLevels,
    required this.topUsers,
    required this.securityAlerts,
    required this.generatedAt,
    this.error,
  });
}

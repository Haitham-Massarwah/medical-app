import '../core/network/http_client.dart';

class InsuranceService {
  final HttpClient _httpClient = HttpClient();

  Future<Map<String, dynamic>> getPatientInsurance(String patientId) async {
    try {
      final response = await _httpClient.get('/insurance/patients/$patientId');
      final data = response['data'];
      if (data is Map<String, dynamic>) return data;
      return {'policies': []};
    } catch (e) {
      return {'policies': []};
    }
  }

  Future<Map<String, dynamic>> checkEligibility(String patientId, {String? provider, String? memberId, String? policyNumber}) async {
    try {
      final response = await _httpClient.post(
        '/insurance/patients/$patientId/eligibility',
        {
          if (provider != null) 'provider': provider,
          if (memberId != null) 'memberId': memberId,
          if (policyNumber != null) 'policyNumber': policyNumber,
        },
      );
      final data = response['data'];
      if (data is Map<String, dynamic>) return data;
      return {'eligible': false, 'message': 'Unknown'};
    } catch (e) {
      return {'eligible': false, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> submitClaim({
    String? patientId,
    String? appointmentId,
    num? amount,
    String? diagnosisCode,
    String? serviceCode,
  }) async {
    final response = await _httpClient.post(
      '/insurance/claims',
      {
        if (patientId != null) 'patientId': patientId,
        if (appointmentId != null) 'appointmentId': appointmentId,
        if (amount != null) 'amount': amount,
        if (diagnosisCode != null) 'diagnosisCode': diagnosisCode,
        if (serviceCode != null) 'serviceCode': serviceCode,
      },
    );
    return response['data'] is Map ? Map<String, dynamic>.from(response['data'] as Map) : <String, dynamic>{};
  }
}

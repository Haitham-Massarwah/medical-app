import '../core/network/http_client.dart';

class LabService {
  final HttpClient _httpClient = HttpClient();

  Future<Map<String, dynamic>> getPatientResults(String patientId) async {
    try {
      final response = await _httpClient.get('/lab/patients/$patientId/results');
      final data = response['data'];
      if (data is Map<String, dynamic>) return data;
      return {'results': [], 'ehrSummary': null};
    } catch (e) {
      return {'results': [], 'ehrSummary': null};
    }
  }

  Future<Map<String, dynamic>> createResult({
    required String patientId,
    String? testName,
    String? resultValue,
    String? unit,
    String? referenceRange,
    String? labName,
  }) async {
    final response = await _httpClient.post(
      '/lab/patients/$patientId/results',
      {
        if (testName != null) 'testName': testName,
        if (resultValue != null) 'resultValue': resultValue,
        if (unit != null) 'unit': unit,
        if (referenceRange != null) 'referenceRange': referenceRange,
        if (labName != null) 'labName': labName,
      },
    );
    return response['data'] is Map ? Map<String, dynamic>.from(response['data'] as Map) : <String, dynamic>{};
  }
}

import '../core/network/http_client.dart';

class PatientService {
  final HttpClient _httpClient = HttpClient();

  Future<Map<String, dynamic>> createPatient(Map<String, dynamic> data) async {
    final response = await _httpClient.post('/patients', data);
    return response['data']?['patient'] ?? {};
  }

  Future<List<Map<String, dynamic>>> getPatients({String? search}) async {
    final queryParams = search != null && search.isNotEmpty ? {'search': search} : null;
    final response = await _httpClient.get('/patients', queryParameters: queryParams);
    return List<Map<String, dynamic>>.from(response['data']?['patients'] ?? []);
  }

  Future<Map<String, dynamic>> getPatientById(String id) async {
    final response = await _httpClient.get('/patients/$id');
    return response['data']?['patient'] ?? {};
  }
}

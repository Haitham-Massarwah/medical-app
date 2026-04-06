import '../core/network/http_client.dart';

class PermissionsService {
  final HttpClient _httpClient = HttpClient();

  Future<Map<String, dynamic>> getPermissions() async {
    final response = await _httpClient.get('/permissions');
    return response['data'] ?? {};
  }
}

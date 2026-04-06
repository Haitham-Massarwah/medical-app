import '../core/network/http_client.dart';

class UserService {
  final HttpClient _httpClient = HttpClient();

  Future<Map<String, dynamic>> getCurrentUser() async {
    final response = await _httpClient.get('/auth/me');
    return response['data']?['user'] ?? {};
  }

  Future<Map<String, dynamic>> updateUser({
    required String userId,
    required Map<String, dynamic> data,
  }) async {
    final response = await _httpClient.put('/users/$userId', data);
    return response['data']?['user'] ?? {};
  }
}

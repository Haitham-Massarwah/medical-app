import '../core/network/http_client.dart';

class TelehealthService {
  final HttpClient _httpClient = HttpClient();
  
  // Create telehealth session
  Future<Map<String, dynamic>> createSession({
    required String appointmentId,
    required String doctorId,
    required String patientId,
  }) async {
    try {
      final response = await _httpClient.post('/telehealth/sessions', {
        'appointment_id': appointmentId,
        'doctor_id': doctorId,
        'patient_id': patientId,
      });
      
      return response['data'] ?? {};
    } catch (e) {
      rethrow;
    }
  }
  
  // Get session details
  Future<Map<String, dynamic>> getSession(String sessionId) async {
    try {
      final response = await _httpClient.get('/telehealth/sessions/$sessionId');
      return response['data'] ?? {};
    } catch (e) {
      rethrow;
    }
  }
  
  // Join session
  Future<Map<String, dynamic>> joinSession(String sessionId) async {
    try {
      final response = await _httpClient.post('/telehealth/sessions/$sessionId/join', {});
      return response['data'] ?? {};
    } catch (e) {
      rethrow;
    }
  }
  
  // End session
  Future<void> endSession(String sessionId) async {
    try {
      await _httpClient.post('/telehealth/sessions/$sessionId/end', {});
    } catch (e) {
      rethrow;
    }
  }
  
  // Generate Agora token
  Future<Map<String, dynamic>> generateAgoraToken({
    required String channelName,
    required String userId,
  }) async {
    try {
      final response = await _httpClient.post('/telehealth/generate-token', {
        'channel_name': channelName,
        'user_id': userId,
      });
      
      return response['data'] ?? {};
    } catch (e) {
      // Return mock token for development
      return {
        'token': 'mock_agora_token_${DateTime.now().millisecondsSinceEpoch}',
        'channel_name': channelName,
        'uid': userId,
        'app_id': 'mock_app_id',
      };
    }
  }
}










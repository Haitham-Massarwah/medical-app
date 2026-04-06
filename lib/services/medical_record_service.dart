import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;

import '../core/config/app_config.dart';
import '../core/network/http_client.dart';

class MedicalRecordService {
  final HttpClient _httpClient = HttpClient();

  Future<Map<String, dynamic>> createRecord({
    required String patientId,
    required Map<String, dynamic> data,
  }) async {
    final response = await _httpClient.post('/patients/$patientId/medical-records', data);
    return response['data']?['record'] ?? {};
  }

  Future<Map<String, dynamic>> updateRecord({
    required String patientId,
    required String recordId,
    required Map<String, dynamic> data,
  }) async {
    final response = await _httpClient.put('/patients/$patientId/medical-records/$recordId', data);
    return response['data']?['record'] ?? {};
  }

  Future<List<Map<String, dynamic>>> getRecords(String patientId) async {
    final response = await _httpClient.get('/patients/$patientId/medical-records');
    final records = response['data']?['records'];
    if (records is List) {
      return List<Map<String, dynamic>>.from(records);
    }
    return [];
  }

  Future<List<Map<String, dynamic>>> getMyRecords() async {
    final response = await _httpClient.get('/patients/me/medical-records');
    final records = response['data']?['records'];
    if (records is List) {
      return List<Map<String, dynamic>>.from(records);
    }
    return [];
  }

  Future<List<String>> uploadAttachments({
    required String patientId,
    required String recordId,
    required List<PlatformFile> files,
  }) async {
    final token = await _httpClient.getAuthToken();
    final uri = Uri.parse('${AppConfig.baseUrl}/patients/$patientId/medical-records/$recordId/attachments');
    final request = http.MultipartRequest('POST', uri);
    if (token != null && token.isNotEmpty) {
      request.headers['Authorization'] = 'Bearer $token';
    }

    for (final file in files) {
      if (file.bytes != null) {
        request.files.add(
          http.MultipartFile.fromBytes(
            'files',
            file.bytes!,
            filename: file.name,
          ),
        );
      } else if (file.path != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'files',
            file.path!,
            filename: file.name,
          ),
        );
      }
    }

    final response = await request.send();
    final body = await response.stream.bytesToString();
    final decoded = jsonDecode(body) as Map<String, dynamic>;
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(decoded['message'] ?? 'Upload failed');
    }
    final attachments = decoded['data']?['attachments'];
    if (attachments is List) {
      return attachments.map((item) => item.toString()).toList();
    }
    return [];
  }
}

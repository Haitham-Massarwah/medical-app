import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
// import 'package:file_picker/file_picker.dart';

class DatabaseService {
  static const String _baseUrl = 'http://localhost:3000/api/v1/database';
  
  // Upload database backup
  static Future<bool> uploadDatabaseBackup(File file) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$_baseUrl/upload'),
      );
      
      request.files.add(await http.MultipartFile.fromPath(
        'database',
        file.path,
        filename: file.path.split('/').last,
      ));
      
      final response = await request.send();
      return response.statusCode == 200;
    } catch (e) {
      print('Error uploading database: $e');
      return false;
    }
  }
  
  // Download database backup
  static Future<bool> downloadDatabaseBackup() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/download'),
        headers: {'Accept': 'application/octet-stream'},
      );
      
      if (response.statusCode == 200) {
        // Save file to downloads
        final file = File('database_backup_${DateTime.now().millisecondsSinceEpoch}.sql');
        await file.writeAsBytes(response.bodyBytes);
        return true;
      }
      return false;
    } catch (e) {
      print('Error downloading database: $e');
      return false;
    }
  }
  
  // Get database status
  static Future<Map<String, dynamic>> getDatabaseStatus() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/status'));
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return {'error': 'Failed to get database status'};
    } catch (e) {
      return {'error': e.toString()};
    }
  }
  
  // Restore database from backup
  static Future<bool> restoreDatabase(File file) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$_baseUrl/restore'),
      );
      
      request.files.add(await http.MultipartFile.fromPath(
        'database',
        file.path,
        filename: file.path.split('/').last,
      ));
      
      final response = await request.send();
      return response.statusCode == 200;
    } catch (e) {
      print('Error restoring database: $e');
      return false;
    }
  }
  
  // Optimize database
  static Future<bool> optimizeDatabase() async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/optimize'),
        headers: {'Content-Type': 'application/json'},
      );
      
      return response.statusCode == 200;
    } catch (e) {
      print('Error optimizing database: $e');
      return false;
    }
  }
  
  // Get database statistics
  static Future<Map<String, dynamic>> getDatabaseStats() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/stats'));
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return {'error': 'Failed to get database stats'};
    } catch (e) {
      return {'error': e.toString()};
    }
  }
}




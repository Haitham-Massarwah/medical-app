import '../core/network/http_client.dart';

class DoctorService {
  final HttpClient _httpClient = HttpClient();
  
  // Get all doctors
  Future<List<Map<String, dynamic>>> getDoctors({
    String? specialty,
    String? search,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final queryParams = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
      };
      
      if (specialty != null && specialty.isNotEmpty && specialty != 'הכל') {
        queryParams['specialty'] = specialty;
      }
      
      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }
      
      final queryString = queryParams.entries
          .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
          .join('&');
      
      final response = await _httpClient.get('/doctors?$queryString');
      
      if (response['data'] != null && response['data'] is List) {
        return List<Map<String, dynamic>>.from(response['data']);
      }
      
      return [];
    } catch (e) {
      // Return mock data if API fails
      return _getMockDoctors();
    }
  }
  
  // Get doctor by ID
  Future<Map<String, dynamic>> getDoctor(String id) async {
    try {
      final response = await _httpClient.get('/doctors/$id');
      return response['data'] ?? {};
    } catch (e) {
      rethrow;
    }
  }
  
  // Get doctor availability
  Future<Map<String, dynamic>> getDoctorAvailability(String doctorId, DateTime date) async {
    try {
      final dateStr = date.toIso8601String().split('T')[0];
      final response = await _httpClient.get('/doctors/$doctorId/availability?date=$dateStr');
      return response['data'] ?? {};
    } catch (e) {
      // Return mock availability if API fails
      return _getMockAvailability();
    }
  }
  
  // Mock data fallback
  List<Map<String, dynamic>> _getMockDoctors() {
    return [
      {
        'id': '1',
        'name': 'ד"ר אברהם כהן',
        'specialty': 'רופא משפחה',
        'location': 'תל אביב',
        'rating': 4.8,
        'review_count': 127,
        'price': 200,
      },
      {
        'id': '2',
        'name': 'ד"ר שרה לוי',
        'specialty': 'קרדיולוג',
        'location': 'ירושלים',
        'rating': 4.9,
        'review_count': 89,
        'price': 350,
      },
      {
        'id': '3',
        'name': 'ד"ר דוד ישראלי',
        'specialty': 'אורתופד',
        'location': 'חיפה',
        'rating': 4.7,
        'review_count': 156,
        'price': 300,
      },
      {
        'id': '4',
        'name': 'ד"ר רחל גולדברג',
        'specialty': 'רופאת עיניים',
        'location': 'תל אביב',
        'rating': 4.9,
        'review_count': 203,
        'price': 250,
      },
    ];
  }
  
  Map<String, dynamic> _getMockAvailability() {
    return {
      'available_slots': ['08:00', '09:30', '11:00', '14:00', '15:30', '17:00'],
      'working_hours': {
        'start': '08:00',
        'end': '18:00',
      },
    };
  }
}










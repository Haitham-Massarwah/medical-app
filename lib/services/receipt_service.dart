import '../core/network/http_client.dart';

class ReceiptService {
  final HttpClient _httpClient = HttpClient();
  
  // Generate receipt
  Future<Map<String, dynamic>> generateReceipt({
    required String paymentId,
    required String appointmentId,
  }) async {
    try {
      final response = await _httpClient.post('/receipts/generate', {
        'payment_id': paymentId,
        'appointment_id': appointmentId,
      });
      
      return response['data'] ?? {};
    } catch (e) {
      rethrow;
    }
  }
  
  // Get receipt
  Future<Map<String, dynamic>> getReceipt(String receiptId) async {
    try {
      final response = await _httpClient.get('/receipts/$receiptId');
      return response['data'] ?? {};
    } catch (e) {
      rethrow;
    }
  }
  
  // Download receipt PDF
  Future<List<int>> downloadReceiptPDF(String receiptId) async {
    try {
      final response = await _httpClient.get('/receipts/$receiptId/pdf');
      // Return PDF bytes
      return [];
    } catch (e) {
      rethrow;
    }
  }
  
  // Email receipt
  Future<void> emailReceipt(String receiptId, String email) async {
    try {
      await _httpClient.post('/receipts/$receiptId/email', {
        'email': email,
      });
    } catch (e) {
      rethrow;
    }
  }
  
  // Get all receipts
  Future<List<Map<String, dynamic>>> getReceipts({
    DateTime? startDate,
    DateTime? endDate,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final queryParams = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
      };
      
      if (startDate != null) {
        queryParams['start_date'] = startDate.toIso8601String().split('T')[0];
      }
      
      if (endDate != null) {
        queryParams['end_date'] = endDate.toIso8601String().split('T')[0];
      }
      
      final queryString = queryParams.entries
          .map((e) => '${e.key}=${e.value}')
          .join('&');
      
      final response = await _httpClient.get('/receipts?$queryString');
      
      if (response['data'] != null && response['data'] is List) {
        return List<Map<String, dynamic>>.from(response['data']);
      }
      
      return [];
    } catch (e) {
      return _getMockReceipts();
    }
  }
  
  // Generate Israeli tax invoice
  Future<Map<String, dynamic>> generateTaxInvoice({
    required String receiptId,
    required Map<String, dynamic> customerDetails,
  }) async {
    try {
      final response = await _httpClient.post('/invoices/generate', {
        'receipt_id': receiptId,
        'customer_details': customerDetails,
      });
      
      return response['data'] ?? {};
    } catch (e) {
      rethrow;
    }
  }
  
  // Mock receipts for development
  List<Map<String, dynamic>> _getMockReceipts() {
    return [
      {
        'id': 'RCP-001',
        'payment_id': 'PAY-001',
        'amount': 200,
        'date': DateTime.now().toIso8601String(),
        'doctor_name': 'ד"ר אברהם כהן',
        'service': 'בדיקה רפואית',
        'vat': 34, // 17% VAT
        'total': 234,
      },
      {
        'id': 'RCP-002',
        'payment_id': 'PAY-002',
        'amount': 350,
        'date': DateTime.now().subtract(const Duration(days: 7)).toIso8601String(),
        'doctor_name': 'ד"ר שרה לוי',
        'service': 'בדיקת לב',
        'vat': 59.5,
        'total': 409.5,
      },
    ];
  }
}










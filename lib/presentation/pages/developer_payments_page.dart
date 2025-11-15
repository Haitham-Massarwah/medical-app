import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class DeveloperPaymentsPage extends StatefulWidget {
  const DeveloperPaymentsPage({super.key});

  @override
  State<DeveloperPaymentsPage> createState() => _DeveloperPaymentsPageState();
}

class _DeveloperPaymentsPageState extends State<DeveloperPaymentsPage> {
  final ApiService _apiService = ApiService();
  List<Map<String, dynamic>> _payments = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String _statusFilter = 'all'; // all, pending, completed, failed, refunded
  String _dateFilter = 'all'; // all, today, week, month
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadPayments();
  }

  Future<void> _loadPayments() async {
    setState(() => _isLoading = true);
    try {
      final response = await _apiService.get('/payments');
      if (response['success'] == true) {
        setState(() {
          _payments = List<Map<String, dynamic>>.from(response['data'] ?? []);
          _isLoading = false;
        });
      } else {
        throw Exception(response['message'] ?? 'Failed to load payments');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('שגיאה בטעינת תשלומים: $e')),
        );
      }
    }
  }

  List<Map<String, dynamic>> get _filteredPayments {
    return _payments.where((payment) {
      final matchesSearch = _searchQuery.isEmpty ||
          (payment['customer_name']?.toString().toLowerCase() ?? '').contains(_searchQuery.toLowerCase()) ||
          (payment['transaction_id']?.toString().toLowerCase() ?? '').contains(_searchQuery.toLowerCase()) ||
          (payment['doctor_name']?.toString().toLowerCase() ?? '').contains(_searchQuery.toLowerCase());
      
      final matchesStatus = _statusFilter == 'all' ||
          payment['status']?.toString().toLowerCase() == _statusFilter.toLowerCase();
      
      return matchesSearch && matchesStatus;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('ניהול תשלומים'),
          backgroundColor: Colors.purple.shade700,
          foregroundColor: Colors.white,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _loadPayments,
              tooltip: 'רענן',
            ),
          ],
        ),
        body: Column(
          children: [
            // Filters
            _buildFilters(),
            // Summary
            _buildSummary(),
            // Payments List
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _filteredPayments.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.payment, size: 64, color: Colors.grey),
                              const SizedBox(height: 16),
                              Text(
                                'לא נמצאו תשלומים',
                                style: TextStyle(fontSize: 18, color: Colors.grey),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _filteredPayments.length,
                          itemBuilder: (context, index) {
                            return _buildPaymentCard(_filteredPayments[index]);
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilters() {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'חיפוש תשלום...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _statusFilter,
                    decoration: const InputDecoration(
                      labelText: 'סטטוס',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'all', child: Text('הכל')),
                      DropdownMenuItem(value: 'pending', child: Text('ממתין')),
                      DropdownMenuItem(value: 'completed', child: Text('הושלם')),
                      DropdownMenuItem(value: 'failed', child: Text('נכשל')),
                      DropdownMenuItem(value: 'refunded', child: Text('הוחזר')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _statusFilter = value!;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _dateFilter,
                    decoration: const InputDecoration(
                      labelText: 'תאריך',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'all', child: Text('הכל')),
                      DropdownMenuItem(value: 'today', child: Text('היום')),
                      DropdownMenuItem(value: 'week', child: Text('השבוע')),
                      DropdownMenuItem(value: 'month', child: Text('החודש')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _dateFilter = value!;
                      });
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummary() {
    final total = _filteredPayments
        .where((p) => p['status'] == 'completed')
        .fold<double>(0, (sum, p) => sum + (double.tryParse(p['amount']?.toString() ?? '0') ?? 0));
    final pending = _filteredPayments.where((p) => p['status'] == 'pending').length;
    final failed = _filteredPayments.where((p) => p['status'] == 'failed').length;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      color: Colors.purple.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                children: [
                  Text(
                    '₪${total.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.purple.shade700,
                    ),
                  ),
                  const Text('סה"כ הושלמו'),
                ],
              ),
            ),
            Container(width: 1, height: 40, color: Colors.grey),
            Expanded(
              child: Column(
                children: [
                  Text(
                    '$pending',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange.shade700,
                    ),
                  ),
                  const Text('ממתינים'),
                ],
              ),
            ),
            Container(width: 1, height: 40, color: Colors.grey),
            Expanded(
              child: Column(
                children: [
                  Text(
                    '$failed',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.red.shade700,
                    ),
                  ),
                  const Text('נכשלו'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentCard(Map<String, dynamic> payment) {
    final status = payment['status']?.toString().toLowerCase() ?? 'unknown';
    final statusColor = _getStatusColor(status);
    final amount = double.tryParse(payment['amount']?.toString() ?? '0') ?? 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: statusColor,
          child: Icon(
            _getStatusIcon(status),
            color: Colors.white,
          ),
        ),
        title: Text(
          '₪${amount.toStringAsFixed(2)}',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (payment['customer_name'] != null)
              Text('לקוח: ${payment['customer_name']}'),
            if (payment['doctor_name'] != null)
              Text('רופא: ${payment['doctor_name']}'),
            if (payment['created_at'] != null)
              Text('תאריך: ${payment['created_at'].toString().split('T')[0]}'),
            if (payment['transaction_id'] != null)
              Text('מספר עסקה: ${payment['transaction_id']}', style: const TextStyle(fontSize: 11)),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) => _handlePaymentAction(value, payment),
          itemBuilder: (context) {
            final items = <PopupMenuEntry<String>>[];
            items.add(const PopupMenuItem(value: 'view', child: Text('צפה בפרטים')));
            
            if (status == 'pending') {
              items.add(const PopupMenuItem(value: 'approve', child: Text('אשר')));
              items.add(const PopupMenuItem(value: 'cancel', child: Text('בטל')));
            }
            
            if (status == 'completed') {
              items.add(const PopupMenuItem(value: 'refund', child: Text('החזר כספים')));
            }
            
            if (status == 'failed') {
              items.add(const PopupMenuItem(value: 'retry', child: Text('נסה שוב')));
            }
            
            items.add(const PopupMenuItem(value: 'export', child: Text('ייצא')));
            
            return items;
          },
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'completed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'failed':
        return Colors.red;
      case 'refunded':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'completed':
        return Icons.check_circle;
      case 'pending':
        return Icons.pending;
      case 'failed':
        return Icons.error;
      case 'refunded':
        return Icons.refresh;
      default:
        return Icons.payment;
    }
  }

  void _handlePaymentAction(String action, Map<String, dynamic> payment) async {
    switch (action) {
      case 'view':
        _showPaymentDetails(payment);
        break;
      case 'approve':
        await _approvePayment(payment);
        break;
      case 'cancel':
        await _cancelPayment(payment);
        break;
      case 'refund':
        await _refundPayment(payment);
        break;
      case 'retry':
        await _retryPayment(payment);
        break;
      case 'export':
        _exportPayment(payment);
        break;
    }
  }

  void _showPaymentDetails(Map<String, dynamic> payment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('פרטי תשלום'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('סכום', '₪${payment['amount']}'),
              _buildDetailRow('סטטוס', _getStatusText(payment['status'] ?? '')),
              if (payment['customer_name'] != null)
                _buildDetailRow('לקוח', payment['customer_name']),
              if (payment['doctor_name'] != null)
                _buildDetailRow('רופא', payment['doctor_name']),
              if (payment['transaction_id'] != null)
                _buildDetailRow('מספר עסקה', payment['transaction_id']),
              if (payment['payment_method'] != null)
                _buildDetailRow('שיטת תשלום', payment['payment_method']),
              if (payment['created_at'] != null)
                _buildDetailRow('תאריך', payment['created_at'].toString().split('T')[0]),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('סגור'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return 'הושלם';
      case 'pending':
        return 'ממתין';
      case 'failed':
        return 'נכשל';
      case 'refunded':
        return 'הוחזר';
      default:
        return status;
    }
  }

  Future<void> _approvePayment(Map<String, dynamic> payment) async {
    try {
      final response = await _apiService.patch(
        '/payments/${payment['id']}',
        {'status': 'completed'},
      );
      if (response['success'] == true) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('תשלום אושר בהצלחה'), backgroundColor: Colors.green),
          );
          _loadPayments();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('שגיאה: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _cancelPayment(Map<String, dynamic> payment) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ביטול תשלום'),
        content: const Text('האם אתה בטוח שברצונך לבטל תשלום זה?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('ביטול'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('בטל'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final response = await _apiService.patch(
          '/payments/${payment['id']}',
          {'status': 'cancelled'},
        );
        if (response['success'] == true) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('תשלום בוטל'), backgroundColor: Colors.orange),
            );
            _loadPayments();
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('שגיאה: $e'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  Future<void> _refundPayment(Map<String, dynamic> payment) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('החזר כספים'),
        content: Text('האם אתה בטוח שברצונך להחזיר את התשלום בסך ₪${payment['amount']}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('ביטול'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            child: const Text('החזר'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final response = await _apiService.post(
          '/payments/${payment['id']}/refund',
          {},
        );
        if (response['success'] == true) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('החזר כספים בוצע בהצלחה'), backgroundColor: Colors.green),
            );
            _loadPayments();
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('שגיאה: $e'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  Future<void> _retryPayment(Map<String, dynamic> payment) async {
    try {
      final response = await _apiService.post(
        '/payments/${payment['id']}/retry',
        {},
      );
      if (response['success'] == true) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('נסיון תשלום חוזר בוצע'), backgroundColor: Colors.green),
          );
          _loadPayments();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('שגיאה: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _exportPayment(Map<String, dynamic> payment) {
    // Export payment data
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('פרטי התשלום הועתקו')),
    );
  }
}


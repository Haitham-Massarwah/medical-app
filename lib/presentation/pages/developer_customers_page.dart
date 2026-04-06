import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class DeveloperCustomersPage extends StatefulWidget {
  const DeveloperCustomersPage({super.key});

  @override
  State<DeveloperCustomersPage> createState() => _DeveloperCustomersPageState();
}

class _DeveloperCustomersPageState extends State<DeveloperCustomersPage> {
  final ApiService _apiService = ApiService();
  List<Map<String, dynamic>> _customers = [];
  bool _isLoading = true;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadCustomers();
  }

  Future<void> _loadCustomers() async {
    setState(() => _isLoading = true);
    try {
      // Fetch users with role 'patient'
      final response = await _apiService.get('/users?role=patient');
      if (response['success'] == true) {
        setState(() {
          _customers = List<Map<String, dynamic>>.from(response['data'] ?? []);
          _isLoading = false;
        });
      } else {
        throw Exception(response['message'] ?? 'Failed to load customers');
      }
    } catch (e) {
      setState(() {
        _customers = [];
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('שגיאה בטעינת משתמשים מהשרת: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  List<Map<String, dynamic>> get _filteredCustomers {
    return _customers.where((customer) {
      return _searchQuery.isEmpty ||
          (customer['name']?.toString().toLowerCase() ?? '').contains(_searchQuery.toLowerCase()) ||
          (customer['email']?.toString().toLowerCase() ?? '').contains(_searchQuery.toLowerCase()) ||
          (customer['phone']?.toString() ?? '').contains(_searchQuery);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context);
    final isRTL = locale.languageCode == 'he' || locale.languageCode == 'ar';

    return Directionality(
      textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('ניהול לקוחות'),
          backgroundColor: Colors.blue.shade700,
          foregroundColor: Colors.white,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _loadCustomers,
              tooltip: 'רענן',
            ),
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              // Search
              Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    hintText: 'חיפוש לקוח...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),
              ),
              // Customers List
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _filteredCustomers.isEmpty
                        ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.people, size: 64, color: Colors.grey),
                              const SizedBox(height: 16),
                              Text(
                                'לא נמצאו לקוחות',
                                style: TextStyle(fontSize: 18, color: Colors.grey),
                              ),
                            ],
                          ),
                          )
                        : ListView.builder(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.all(16),
                            itemCount: _filteredCustomers.length,
                            itemBuilder: (context, index) {
                              return _buildCustomerCard(_filteredCustomers[index]);
                            },
                          ),
                ),
              ],
            ),
        ),
      ),
    );
  }

  Widget _buildCustomerCard(Map<String, dynamic> customer) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue.shade100,
          child: Text(
            customer['name']?.toString().substring(0, 1).toUpperCase() ?? '?',
            style: TextStyle(color: Colors.blue.shade700),
          ),
        ),
        title: Text(
          customer['name'] ?? 'ללא שם',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('אימייל: ${customer['email'] ?? 'לא צוין'}'),
            if (customer['phone'] != null) Text('טלפון: ${customer['phone']}'),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) => _handleCustomerAction(value, customer),
          itemBuilder: (context) => [
            const PopupMenuItem(value: 'view', child: Text('צפה בפרטים')),
            const PopupMenuItem(value: 'edit', child: Text('ערוך')),
            const PopupMenuItem(value: 'appointments', child: Text('הצג תורים')),
            const PopupMenuItem(value: 'block', child: Text('חסום')),
            const PopupMenuItem(value: 'delete', child: Text('מחק')),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailRow('אימייל', customer['email'] ?? 'לא צוין'),
                _buildDetailRow('טלפון', customer['phone'] ?? 'לא צוין'),
                if (customer['city'] != null)
                  _buildDetailRow('עיר', customer['city']),
                if (customer['created_at'] != null)
                  _buildDetailRow('תאריך הרשמה', customer['created_at'].toString().split('T')[0]),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => _handleCustomerAction('view', customer),
                      icon: const Icon(Icons.visibility, size: 18),
                      label: const Text('פרטים'),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => _handleCustomerAction('appointments', customer),
                      icon: const Icon(Icons.calendar_today, size: 18),
                      label: const Text('תורים'),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => _handleCustomerAction('edit', customer),
                      icon: const Icon(Icons.edit, size: 18),
                      label: const Text('ערוך'),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    ),
                  ],
                ),
              ],
            ),
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

  void _handleCustomerAction(String action, Map<String, dynamic> customer) {
    switch (action) {
      case 'view':
        _showCustomerDetails(customer);
        break;
      case 'edit':
        Navigator.pushNamed(
          context,
          '/create-patient',
          arguments: {'customer': customer},
        );
        break;
      case 'appointments':
        Navigator.pushNamed(
          context,
          '/appointments-list',
          arguments: {'userId': customer['id']},
        );
        break;
      case 'block':
        _blockCustomer(customer);
        break;
      case 'delete':
        _deleteCustomer(customer);
        break;
    }
  }

  void _showCustomerDetails(Map<String, dynamic> customer) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(customer['name'] ?? 'פרטי לקוח'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('אימייל', customer['email'] ?? 'לא צוין'),
              _buildDetailRow('טלפון', customer['phone'] ?? 'לא צוין'),
              if (customer['city'] != null) _buildDetailRow('עיר', customer['city']),
              if (customer['created_at'] != null)
                _buildDetailRow('תאריך הרשמה', customer['created_at'].toString().split('T')[0]),
              if (customer['role'] != null) _buildDetailRow('תפקיד', customer['role']),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('סגור'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _handleCustomerAction('edit', customer);
            },
            child: const Text('ערוך'),
          ),
        ],
      ),
    );
  }

  Future<void> _blockCustomer(Map<String, dynamic> customer) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('חסימת לקוח'),
        content: Text('האם אתה בטוח שברצונך לחסום את ${customer['name']}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('ביטול'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: const Text('חסום'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      // Implement block logic
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('לקוח נחסם בהצלחה')),
        );
      }
    }
  }

  Future<void> _deleteCustomer(Map<String, dynamic> customer) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('מחיקת לקוח'),
        content: Text('האם אתה בטוח שברצונך למחוק את ${customer['name']}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('ביטול'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('מחק'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final response = await _apiService.delete('/users/${customer['id']}');
        if (response['success'] == true) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('לקוח נמחק בהצלחה'),
                backgroundColor: Colors.green,
              ),
            );
            _loadCustomers();
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('שגיאה: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}


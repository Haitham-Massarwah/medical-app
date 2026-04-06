import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class AppointmentsListPage extends StatefulWidget {
  const AppointmentsListPage({super.key});

  @override
  State<AppointmentsListPage> createState() => _AppointmentsListPageState();
}

class _AppointmentsListPageState extends State<AppointmentsListPage> {
  final ApiService _apiService = ApiService();
  List<Map<String, dynamic>> _appointments = [];
  bool _isLoading = true;
  String _selectedStatus = 'כל התורים';
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadAppointments();
  }

  Future<void> _loadAppointments() async {
    setState(() => _isLoading = true);

    try {
      final response = await _apiService.get('/appointments');
      if (response['success'] == true) {
        final dynamic payload = response['data'];
        final List<dynamic> appointments =
            payload is Map<String, dynamic> && payload['data'] != null
                ? payload['data'] as List<dynamic>
                : (payload as List<dynamic>? ?? []);

        setState(() {
          _appointments = List<Map<String, dynamic>>.from(appointments);
          _errorMessage = null;
          _isLoading = false;
        });
      } else {
        throw Exception(response['message']);
      }
    } catch (e) {
      // PD-01: Remove development/placeholder messages - show user-friendly error only
      setState(() {
        _appointments = [];
        // Show simple, user-friendly message without technical details
        _errorMessage = 'לא ניתן לטעון תורים כרגע. אנא נסה שוב מאוחר יותר.';
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_errorMessage!),
            backgroundColor: Colors.redAccent,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('ניהול תורים'),
          backgroundColor: Colors.orange,
          foregroundColor: Colors.white,
        ),
        body: Column(
          children: [
            // Filter section
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Text('סטטוס: '),
                  const SizedBox(width: 8),
                  DropdownButton<String>(
                    value: _selectedStatus,
                    items: [
                      'כל התורים',
                      'ממתינים',
                      'מאושרים',
                      'בוטלו',
                      'הושלמו',
                    ].map((status) {
                      return DropdownMenuItem(
                        value: status,
                        child: Text(status),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedStatus = value!;
                      });
                    },
                  ),
                ],
              ),
            ),
            
            // Appointments list
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _buildAppointmentsList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppointmentsList() {
    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            _errorMessage!,
            style: const TextStyle(color: Colors.redAccent),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    if (_appointments.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text('אין תורים להצגה עבור המשתמש הזה.'),
        ),
      );
    }

    final filteredAppointments = _appointments.where((appointment) {
      if (_selectedStatus == 'כל התורים') return true;
      return _getStatusLabel(appointment['status']) == _selectedStatus;
    }).toList();

    return ListView.builder(
      itemCount: filteredAppointments.length,
      itemBuilder: (context, index) {
        final appointment = filteredAppointments[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: _getStatusColor(appointment['status']),
              child: Icon(
                _getStatusIcon(appointment['status']),
                color: Colors.white,
              ),
            ),
            title: Text('${appointment['patient_name']} - ${appointment['doctor_name']}'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${appointment['date']} • ${appointment['time']}'),
                Text('${appointment['doctor_specialty']} • ₪${appointment['consultation_fee']}'),
                Text('${appointment['patient_phone']} • ${_getStatusLabel(appointment['status'])}'),
                Text('תשלום: ${_getPaymentStatusLabel(appointment['payment_status'])}'),
              ],
            ),
            trailing: PopupMenuButton(
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'view',
                  child: Text('צפה בפרטים'),
                ),
                const PopupMenuItem(
                  value: 'edit',
                  child: Text('ערוך'),
                ),
                const PopupMenuItem(
                  value: 'confirm',
                  child: Text('אשר'),
                ),
                const PopupMenuItem(
                  value: 'cancel',
                  child: Text('בטל'),
                ),
              ],
              onSelected: (value) => _handleAppointmentAction(value, appointment),
            ),
          ),
        );
      },
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'confirmed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'cancelled':
        return Colors.red;
      case 'completed':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'confirmed':
        return Icons.check_circle;
      case 'pending':
        return Icons.schedule;
      case 'cancelled':
        return Icons.cancel;
      case 'completed':
        return Icons.done_all;
      default:
        return Icons.help;
    }
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'confirmed':
        return 'מאושר';
      case 'pending':
        return 'ממתין';
      case 'cancelled':
        return 'בוטל';
      case 'completed':
        return 'הושלם';
      default:
        return 'לא ידוע';
    }
  }

  String _getPaymentStatusLabel(String paymentStatus) {
    switch (paymentStatus) {
      case 'paid':
        return 'שולם';
      case 'pending':
        return 'ממתין לתשלום';
      case 'refunded':
        return 'הוחזר';
      default:
        return 'לא ידוע';
    }
  }

  void _handleAppointmentAction(String action, Map<String, dynamic> appointment) {
    switch (action) {
      case 'view':
        _showAppointmentDetails(appointment);
        break;
      case 'edit':
        _editAppointment(appointment);
        break;
      case 'confirm':
        _confirmAppointment(appointment);
        break;
      case 'cancel':
        _cancelAppointment(appointment);
        break;
    }
  }

  void _showAppointmentDetails(Map<String, dynamic> appointment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('פרטי התור'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('מטופל: ${appointment['patient_name']}'),
              Text('טלפון: ${appointment['patient_phone']}'),
              Text('רופא: ${appointment['doctor_name']}'),
              Text('התמחות: ${appointment['doctor_specialty']}'),
              Text('תאריך: ${appointment['date']}'),
              Text('שעה: ${appointment['time']}'),
              Text('שכר ייעוץ: ₪${appointment['consultation_fee']}'),
              Text('סטטוס: ${_getStatusLabel(appointment['status'])}'),
              Text('תשלום: ${_getPaymentStatusLabel(appointment['payment_status'])}'),
              Text('נוצר: ${appointment['created_at']}'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('סגור'),
          ),
        ],
      ),
    );
  }

  void _editAppointment(Map<String, dynamic> appointment) {
    // TODO: Implement edit appointment functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('עריכת תור - בפיתוח')),
    );
  }

  void _confirmAppointment(Map<String, dynamic> appointment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('אישור תור'),
        content: Text('האם אתה בטוח שברצונך לאשר את התור של ${appointment['patient_name']}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('ביטול'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                appointment['status'] = 'confirmed';
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('התור אושר בהצלחה')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('אשר'),
          ),
        ],
      ),
    );
  }

  void _cancelAppointment(Map<String, dynamic> appointment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ביטול תור'),
        content: Text('האם אתה בטוח שברצונך לבטל את התור של ${appointment['patient_name']}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('ביטול'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                appointment['status'] = 'cancelled';
                appointment['payment_status'] = 'refunded';
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('התור בוטל')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('בטל'),
          ),
        ],
      ),
    );
  }
}









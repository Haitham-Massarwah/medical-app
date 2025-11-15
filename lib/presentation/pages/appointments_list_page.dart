import 'package:flutter/material.dart';

class AppointmentsListPage extends StatefulWidget {
  const AppointmentsListPage({super.key});

  @override
  State<AppointmentsListPage> createState() => _AppointmentsListPageState();
}

class _AppointmentsListPageState extends State<AppointmentsListPage> {
  List<Map<String, dynamic>> _appointments = [];
  bool _isLoading = true;
  String _selectedStatus = 'כל התורים';

  @override
  void initState() {
    super.initState();
    _loadAppointments();
  }

  Future<void> _loadAppointments() async {
    setState(() => _isLoading = true);
    
    // Mock appointments data
    await Future.delayed(const Duration(seconds: 1));
    
    setState(() {
      _appointments = [
        {
          'id': '1',
          'patient_name': 'שרה לוי',
          'patient_phone': '050-1234567',
          'doctor_name': 'ד"ר יוסי כהן',
          'doctor_specialty': 'רפואה פנימית',
          'date': '2024-01-25',
          'time': '09:00',
          'status': 'confirmed',
          'consultation_fee': 300.0,
          'payment_status': 'paid',
          'created_at': '2024-01-20',
        },
        {
          'id': '2',
          'patient_name': 'דוד כהן',
          'patient_phone': '052-9876543',
          'doctor_name': 'ד"ר רחל אברהם',
          'doctor_specialty': 'רפואת ילדים',
          'date': '2024-01-25',
          'time': '10:30',
          'status': 'pending',
          'consultation_fee': 250.0,
          'payment_status': 'pending',
          'created_at': '2024-01-21',
        },
        {
          'id': '3',
          'patient_name': 'רחל אברהם',
          'patient_phone': '054-5555555',
          'doctor_name': 'ד"ר מיכל לוי',
          'doctor_specialty': 'גינקולוגיה',
          'date': '2024-01-26',
          'time': '14:00',
          'status': 'confirmed',
          'consultation_fee': 400.0,
          'payment_status': 'paid',
          'created_at': '2024-01-22',
        },
        {
          'id': '4',
          'patient_name': 'אמיר דוד',
          'patient_phone': '051-2222222',
          'doctor_name': 'ד"ר אמיר דוד',
          'doctor_specialty': 'אורתופדיה',
          'date': '2024-01-24',
          'time': '16:00',
          'status': 'cancelled',
          'consultation_fee': 350.0,
          'payment_status': 'refunded',
          'created_at': '2024-01-19',
        },
        {
          'id': '5',
          'patient_name': 'מיכל לוי',
          'patient_phone': '053-3333333',
          'doctor_name': 'ד"ר יוסי כהן',
          'doctor_specialty': 'רפואה פנימית',
          'date': '2024-01-27',
          'time': '11:00',
          'status': 'completed',
          'consultation_fee': 300.0,
          'payment_status': 'paid',
          'created_at': '2024-01-18',
        },
      ];
      _isLoading = false;
    });
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









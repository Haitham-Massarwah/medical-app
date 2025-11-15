import 'package:flutter/material.dart';
import '../../models/treatment_models_simple.dart';

class BookingManagementPage extends StatefulWidget {
  const BookingManagementPage({super.key});

  @override
  State<BookingManagementPage> createState() => _BookingManagementPageState();
}

class _BookingManagementPageState extends State<BookingManagementPage> {
  bool _isLoading = false;
  List<Map<String, dynamic>> _bookings = [];
  String _selectedFilter = 'all';
  
  // Mock data - would typically come from API
  final List<Map<String, dynamic>> _mockBookings = [
    {
      'id': '1',
      'patientName': 'שרה לוי',
      'patientPhone': '050-1234567',
      'treatmentType': 'ייעוץ כללי',
      'appointmentDate': DateTime.now().add(const Duration(days: 1)),
      'timeSlot': '10:00',
      'status': 'confirmed',
      'approvalRequired': false,
      'amount': 250.0,
    },
    {
      'id': '2',
      'patientName': 'דוד כהן',
      'patientPhone': '050-7654321',
      'treatmentType': 'בדיקה גופנית',
      'appointmentDate': DateTime.now().add(const Duration(days: 2)),
      'timeSlot': '14:30',
      'status': 'pending_approval',
      'approvalRequired': true,
      'amount': 300.0,
    },
    {
      'id': '3',
      'patientName': 'רחל ישראלי',
      'patientPhone': '050-9876543',
      'treatmentType': 'ייעוץ מומחה',
      'appointmentDate': DateTime.now().add(const Duration(days: 3)),
      'timeSlot': '09:00',
      'status': 'confirmed',
      'approvalRequired': false,
      'amount': 400.0,
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  Future<void> _loadBookings() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      
      setState(() {
        _bookings = List.from(_mockBookings);
      });
    } catch (e) {
      _showError('שגיאה בטעינת התורים: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ניהול תורים'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadBookings,
            tooltip: 'רענן',
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Section
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey.shade100,
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedFilter,
                    decoration: const InputDecoration(
                      labelText: 'סינון',
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    items: const [
                      DropdownMenuItem(value: 'all', child: Text('כל התורים')),
                      DropdownMenuItem(value: 'pending_approval', child: Text('ממתינים לאישור')),
                      DropdownMenuItem(value: 'confirmed', child: Text('מאושרים')),
                      DropdownMenuItem(value: 'cancelled', child: Text('מבוטלים')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedFilter = value!;
                        _filterBookings();
                      });
                    },
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: _showBookingSettings,
                  icon: const Icon(Icons.settings),
                  label: const Text('הגדרות'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          
          // Bookings List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _bookings.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.calendar_today,
                              size: 64,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'אין תורים',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _bookings.length,
                        itemBuilder: (context, index) {
                          final booking = _bookings[index];
                          return _buildBookingCard(booking);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingCard(Map<String, dynamic> booking) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 25,
                  child: Text(
                    booking['patientName'][0],
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        booking['patientName'],
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        booking['patientPhone'],
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      Text(
                        booking['treatmentType'],
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _formatDate(booking['appointmentDate']),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      booking['timeSlot'],
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    Text(
                      '₪${booking['amount'].toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Status Badge
            Row(
              children: [
                _buildStatusBadge(booking['status']),
                if (booking['approvalRequired'])
                  Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'דורש אישור',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.orange,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Action Buttons
            Row(
              children: [
                if (booking['status'] == 'pending_approval') ...[
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _approveBooking(booking['id']),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('אשר'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _rejectBooking(booking['id']),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                      ),
                      child: const Text('דחה'),
                    ),
                  ),
                ] else if (booking['status'] == 'confirmed') ...[
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _rescheduleBooking(booking),
                      child: const Text('דחה'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _cancelBooking(booking['id']),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                      ),
                      child: const Text('בטל'),
                    ),
                  ),
                ],
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () => _viewBookingDetails(booking),
                  icon: const Icon(Icons.info_outline),
                  tooltip: 'פרטים',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    String text;
    
    switch (status) {
      case 'pending_approval':
        color = Colors.orange;
        text = 'ממתין לאישור';
        break;
      case 'confirmed':
        color = Colors.green;
        text = 'מאושר';
        break;
      case 'cancelled':
        color = Colors.red;
        text = 'מבוטל';
        break;
      default:
        color = Colors.grey;
        text = 'לא ידוע';
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'ינואר', 'פברואר', 'מרץ', 'אפריל', 'מאי', 'יוני',
      'יולי', 'אוגוסט', 'ספטמבר', 'אוקטובר', 'נובמבר', 'דצמבר'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  void _filterBookings() {
    setState(() {
      if (_selectedFilter == 'all') {
        _bookings = List.from(_mockBookings);
      } else {
        _bookings = _mockBookings.where((booking) => booking['status'] == _selectedFilter).toList();
      }
    });
  }

  void _approveBooking(String bookingId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('אשר תור'),
        content: const Text('האם אתה בטוח שברצונך לאשר תור זה?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('ביטול'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _updateBookingStatus(bookingId, 'confirmed');
            },
            child: const Text('אשר'),
          ),
        ],
      ),
    );
  }

  void _rejectBooking(String bookingId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('דחה תור'),
        content: const Text('האם אתה בטוח שברצונך לדחות תור זה?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('ביטול'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _updateBookingStatus(bookingId, 'cancelled');
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('דחה'),
          ),
        ],
      ),
    );
  }

  void _rescheduleBooking(Map<String, dynamic> booking) {
    // Navigate to reschedule page
    Navigator.pushNamed(
      context,
      '/reschedule',
      arguments: {
        'appointmentId': booking['id'],
        'doctorName': 'ד"ר כהן',
        'specialty': booking['treatmentType'],
        'currentDate': booking['appointmentDate'],
        'currentTimeSlot': booking['timeSlot'],
      },
    );
  }

  void _cancelBooking(String bookingId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('בטל תור'),
        content: const Text('האם אתה בטוח שברצונך לבטל תור זה?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('ביטול'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _updateBookingStatus(bookingId, 'cancelled');
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('בטל'),
          ),
        ],
      ),
    );
  }

  void _viewBookingDetails(Map<String, dynamic> booking) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('פרטי התור'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('מטופל', booking['patientName']),
            _buildDetailRow('טלפון', booking['patientPhone']),
            _buildDetailRow('סוג טיפול', booking['treatmentType']),
            _buildDetailRow('תאריך', _formatDate(booking['appointmentDate'])),
            _buildDetailRow('שעה', booking['timeSlot']),
            _buildDetailRow('סכום', '₪${booking['amount'].toStringAsFixed(0)}'),
            _buildDetailRow('סטטוס', _getStatusText(booking['status'])),
          ],
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

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$label:',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(value),
        ],
      ),
    );
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'pending_approval':
        return 'ממתין לאישור';
      case 'confirmed':
        return 'מאושר';
      case 'cancelled':
        return 'מבוטל';
      default:
        return 'לא ידוע';
    }
  }

  void _updateBookingStatus(String bookingId, String newStatus) {
    setState(() {
      final index = _bookings.indexWhere((booking) => booking['id'] == bookingId);
      if (index != -1) {
        _bookings[index]['status'] = newStatus;
      }
    });
    
    _showSuccess('התור עודכן בהצלחה');
  }

  void _showBookingSettings() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('הגדרות תורים'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.settings),
              title: Text('אישור אוטומטי'),
              subtitle: Text('תורים יאושרו אוטומטית'),
            ),
            ListTile(
              leading: Icon(Icons.schedule),
              title: Text('זמני הפסקה'),
              subtitle: Text('הגדר זמני הפסקה'),
            ),
            ListTile(
              leading: Icon(Icons.payment),
              title: Text('הגדרות תשלום'),
              subtitle: Text('זמן תשלום ופרטים'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('סגור'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.pushNamed(context, '/doctor-treatment-settings');
            },
            child: const Text('הגדרות'),
          ),
        ],
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }
}

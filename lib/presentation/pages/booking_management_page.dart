import 'package:flutter/material.dart';
import '../../services/appointment_service.dart';
import '../../services/auth_service.dart';
import '../../services/doctor_service.dart';

class BookingManagementPage extends StatefulWidget {
  const BookingManagementPage({super.key});

  @override
  State<BookingManagementPage> createState() => _BookingManagementPageState();
}

class _BookingManagementPageState extends State<BookingManagementPage> {
  final AppointmentService _appointmentService = AppointmentService();
  final DoctorService _doctorService = DoctorService();
  final AuthService _authService = AuthService();
  bool _isLoading = false;
  List<Map<String, dynamic>> _bookings = [];
  List<Map<String, dynamic>> _allBookings = [];
  String _selectedFilter = 'all';
  String? _doctorId;
  String _doctorName = '';
  String _doctorSpecialty = '';
  /// SRS Rev 02 receptionist (and admin/developer): tenant-wide schedule, no doctor profile.
  bool _tenantWideViewer = false;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    setState(() => _isLoading = true);
    try {
      final me = await _authService.getCurrentUser();
      final role = me['data']?['user']?['role']?.toString() ?? '';
      _tenantWideViewer =
          role == 'receptionist' || role == 'admin' || role == 'developer';
      if (_tenantWideViewer) {
        await _loadTenantWideBookings();
      } else {
        await _loadDoctorAndBookings();
      }
    } catch (e) {
      _showError('שגיאה בטעינת נתונים: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _reloadSchedule() async {
    if (_tenantWideViewer) {
      await _loadTenantWideBookings();
    } else {
      await _loadBookings();
    }
  }

  Future<void> _loadTenantWideBookings() async {
    setState(() => _isLoading = true);
    try {
      final appointments = await _appointmentService.getAppointments();
      final mapped = appointments.map((appointment) {
        final dateValue = appointment['appointment_date'];
        final date = DateTime.tryParse(dateValue?.toString() ?? '');
        var patientName =
            (appointment['patientName'] ?? appointment['patient_name'] ?? '').toString().trim();
        if (patientName.isEmpty) patientName = 'לא ידוע';
        final status = appointment['status']?.toString() ?? 'scheduled';
        final amount = double.tryParse(
              appointment['service_price']?.toString() ??
                  appointment['amount']?.toString() ??
                  '0',
            ) ??
            0;
        return {
          'id': appointment['id']?.toString() ?? '',
          'doctorId': appointment['doctor_id']?.toString() ?? '',
          'patientId': appointment['patient_id']?.toString() ?? '',
          'patientName': patientName,
          'patientPhone':
              appointment['patient_phone']?.toString() ?? appointment['patientPhone']?.toString() ?? '',
          'treatmentType':
              appointment['service_name']?.toString() ?? appointment['specialty']?.toString() ?? 'טיפול',
          'treatmentTypeId': appointment['service_id']?.toString() ?? '',
          'appointmentDate': date ?? DateTime.now(),
          'timeSlot': date != null ? _formatTime(date) : '',
          'amount': amount,
          'status': status,
          'approvalRequired': status == 'scheduled',
        };
      }).toList();
      if (mounted) {
        setState(() {
          _allBookings = mapped;
          _applyFilter();
        });
      }
    } catch (e) {
      _showError('שגיאה בטעינת התורים: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _loadDoctorAndBookings() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final doctor = await _doctorService.getMyDoctorProfile();
      final doctorId = doctor['id']?.toString();
      if (doctorId == null || doctorId.isEmpty) {
        throw Exception('Doctor profile not found');
      }
      _doctorId = doctorId;
      final firstName = doctor['first_name']?.toString() ?? '';
      final lastName = doctor['last_name']?.toString() ?? '';
      _doctorName = [firstName, lastName].where((part) => part.isNotEmpty).join(' ');
      _doctorSpecialty = doctor['specialty']?.toString() ?? '';
      await _loadBookings();
    } catch (e) {
      _showError('שגיאה בטעינת פרטי רופא: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadBookings() async {
    if (_doctorId == null) return;
    setState(() {
      _isLoading = true;
    });

    try {
      final appointments = await _doctorService.getDoctorAppointments(
        doctorId: _doctorId!,
      );
      final mapped = appointments.map((appointment) {
        final dateValue = appointment['appointment_date'];
        final date = DateTime.tryParse(dateValue?.toString() ?? '');
        final patientFirst = appointment['patient_first_name']?.toString() ?? '';
        final patientLast = appointment['patient_last_name']?.toString() ?? '';
        final patientName = '$patientFirst $patientLast'.trim();
        final status = appointment['status']?.toString() ?? 'scheduled';
        final amount = double.tryParse(appointment['service_price']?.toString() ?? '0') ?? 0;
        return {
          'id': appointment['id']?.toString() ?? '',
          'doctorId': appointment['doctor_id']?.toString() ?? '',
          'patientId': appointment['patient_id']?.toString() ?? '',
          'patientName': patientName.isEmpty ? 'לא ידוע' : patientName,
          'patientPhone': appointment['patient_phone']?.toString() ?? '',
          'treatmentType': appointment['service_name']?.toString() ?? 'טיפול',
          'treatmentTypeId': appointment['service_id']?.toString() ?? '',
          'appointmentDate': date ?? DateTime.now(),
          'timeSlot': date != null ? _formatTime(date) : '',
          'amount': amount,
          'status': status,
          'approvalRequired': status == 'scheduled',
        };
      }).toList();

      setState(() {
        _allBookings = mapped;
        _applyFilter();
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
            onPressed: _bootstrap,
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
                      DropdownMenuItem(value: 'scheduled', child: Text('ממתינים לאישור')),
                      DropdownMenuItem(value: 'confirmed', child: Text('מאושרים')),
                      DropdownMenuItem(value: 'cancelled', child: Text('מבוטלים')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedFilter = value!;
                        _applyFilter();
                      });
                    },
                  ),
                ),
                if (!_tenantWideViewer) ...[
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
                if (booking['status'] == 'scheduled') ...[
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
                  if (!_tenantWideViewer) ...[
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _openTreatmentCompletion(booking),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('סיום טיפול'),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _rescheduleBooking(booking),
                      child: const Text('דחה'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _confirmCancelBooking(booking['id']),
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
      case 'scheduled':
        color = Colors.orange;
        text = 'ממתין לאישור';
        break;
      case 'confirmed':
        color = Colors.green;
        text = 'מאושר';
        break;
      case 'rescheduled':
        color = Colors.blue;
        text = 'נדחה';
        break;
      case 'completed':
        color = Colors.blueGrey;
        text = 'הושלם';
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

  String _formatTime(DateTime date) {
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  void _applyFilter() {
    setState(() {
      if (_selectedFilter == 'all') {
        _bookings = List.from(_allBookings);
      } else {
        _bookings = _allBookings
            .where((booking) => booking['status'] == _selectedFilter)
            .toList();
      }
    });
  }

  void _openTreatmentCompletion(Map<String, dynamic> booking) {
    final appointmentId = booking['id']?.toString() ?? '';
    final patientId = booking['patientId']?.toString() ?? '';
    if (appointmentId.isEmpty || patientId.isEmpty) {
      _showError('פרטי התור אינם מלאים');
      return;
    }
    Navigator.pushNamed(
      context,
      '/treatment-completion',
      arguments: {
        'appointmentId': appointmentId,
        'patientId': patientId,
        'patientName': booking['patientName']?.toString() ?? '',
        'treatmentTypeId': booking['treatmentTypeId']?.toString() ?? '',
        'treatmentTypeName': booking['treatmentType']?.toString() ?? 'טיפול',
        'amount': booking['amount'] ?? 0,
      },
    );
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
              _confirmBooking(bookingId);
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
              _cancelBooking(bookingId);
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
        'doctorId': booking['doctorId'],
        'doctorName': _doctorName.isEmpty ? 'רופא' : _doctorName,
        'specialty': _doctorSpecialty.isEmpty ? booking['treatmentType'] : _doctorSpecialty,
        'currentDate': booking['appointmentDate'],
        'currentTimeSlot': booking['timeSlot'],
      },
    );
  }

  void _confirmCancelBooking(String bookingId) {
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
              _cancelBooking(bookingId);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('בטל'),
          ),
        ],
      ),
    );
  }

  void _viewBookingDetails(Map<String, dynamic> booking) {
    final appointmentId = booking['id']?.toString() ?? '';
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('פרטי התור'),
        content: SingleChildScrollView(
          child: Column(
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
              if (appointmentId.isNotEmpty && booking['status'] != 'completed' && booking['status'] != 'cancelled')
                FutureBuilder<Map<String, dynamic>>(
                  future: _appointmentService.getNoShowRisk(appointmentId),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Padding(
                        padding: EdgeInsets.only(top: 8),
                        child: SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      );
                    }
                    final data = snapshot.data!;
                    final risk = data['risk']?.toString() ?? 'low';
                    final score = (data['score'] is int) ? data['score'] as int : (data['score'] as num?)?.toInt() ?? 0;
                    Color riskColor = Colors.green;
                    String riskLabel = 'סיכון אי-הופעה: נמוך';
                    if (risk == 'high') {
                      riskColor = Colors.red;
                      riskLabel = 'סיכון אי-הופעה: גבוה ($score)';
                    } else if (risk == 'medium') {
                      riskColor = Colors.orange;
                      riskLabel = 'סיכון אי-הופעה: בינוני ($score)';
                    } else {
                      riskLabel = 'סיכון אי-הופעה: נמוך ($score)';
                    }
                    return Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Row(
                        children: [
                          Icon(Icons.warning_amber_rounded, color: riskColor, size: 20),
                          const SizedBox(width: 8),
                          Text(riskLabel, style: TextStyle(fontWeight: FontWeight.bold, color: riskColor)),
                        ],
                      ),
                    );
                  },
                ),
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
      case 'scheduled':
        return 'ממתין לאישור';
      case 'confirmed':
        return 'מאושר';
      case 'rescheduled':
        return 'נדחה';
      case 'completed':
        return 'הושלם';
      case 'cancelled':
        return 'מבוטל';
      default:
        return 'לא ידוע';
    }
  }

  Future<void> _confirmBooking(String bookingId) async {
    try {
      await _appointmentService.confirmAppointment(bookingId);
      await _reloadSchedule();
      _showSuccess('התור עודכן בהצלחה');
    } catch (e) {
      _showError('שגיאה בעדכון התור: $e');
    }
  }

  Future<void> _cancelBooking(String bookingId) async {
    try {
      await _appointmentService.cancelAppointment(bookingId);
      await _reloadSchedule();
      _showSuccess('התור עודכן בהצלחה');
    } catch (e) {
      _showError('שגיאה בעדכון התור: $e');
    }
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

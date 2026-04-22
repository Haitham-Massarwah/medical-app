import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'reschedule_page.dart';
import '../../services/waze_service.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';
import '../../services/appointment_service.dart';
import 'package:medical_appointment_system/core/utils/error_handler.dart';

class AppointmentsPage extends StatefulWidget {
  const AppointmentsPage({super.key});

  @override
  State<AppointmentsPage> createState() => _AppointmentsPageState();
}

class _AppointmentsPageState extends State<AppointmentsPage> {
  final ApiService _apiService = ApiService();
  final AuthService _authService = AuthService();
  final AppointmentService _appointmentService = AppointmentService();
  final List<String> _filters = ['הכל', 'פעיל', 'מאושר', 'ממתין', 'הושלם', 'בוטל'];
  List<Appointment> _appointments = [];
  String _selectedFilter = 'פעיל'; // Changed default to show active appointments
  bool _isLoading = true;
  String? _errorMessage;
  String _userRole = '';
  String? _resendingNotificationId;

  @override
  void initState() {
    super.initState();
    _loadAppointments();
  }

  bool get _canResendPatientMessage {
    const allowed = {'doctor', 'paramedical', 'admin', 'developer'};
    return allowed.contains(_userRole);
  }

  Future<void> _loadAppointments() async {
    setState(() => _isLoading = true);

    try {
      final me = await _authService.getCurrentUser();
      final user = me['data']?['user'] ?? me['user'] ?? {};
      _userRole = (user['role'] ?? '').toString();

      final response = await _apiService.get('/appointments');
      if (response['success'] == true) {
        final dynamic payload = response['data'];
        final List<dynamic> rows =
            payload is Map<String, dynamic> && payload['data'] != null
                ? payload['data'] as List<dynamic>
                : (payload as List<dynamic>? ?? []);

        setState(() {
          _appointments = rows.map((row) {
            final map = row as Map<String, dynamic>;
            var timeStr = (map['time'] ?? map['appointment_time'] ?? '').toString();
            if (timeStr.isEmpty) {
              final d = DateTime.tryParse((map['appointment_date'] ?? map['date'] ?? '').toString());
              if (d != null) {
                final l = d.toLocal();
                timeStr =
                    '${l.hour.toString().padLeft(2, '0')}:${l.minute.toString().padLeft(2, '0')}';
              }
            }
            final pName = '${map['patientName'] ?? map['patient_name'] ?? ''}'.trim();
            final pPhone = '${map['patientPhone'] ?? map['patient_phone'] ?? map['guest_phone'] ?? ''}'
                .trim();
            return Appointment(
              id: (map['id'] ?? '').toString(),
              doctorId: (map['doctor_id'] ?? map['doctorId'] ?? '').toString(),
              doctorName: (map['doctor_name'] ?? map['doctorName'] ?? 'לא ידוע').toString(),
              specialty: (map['doctor_specialty'] ?? map['specialty'] ?? '').toString(),
              date: (map['appointment_date'] ?? map['date'] ?? '').toString(),
              time: timeStr,
              status: (map['status'] ?? '').toString(),
              location: (map['location'] ?? '').toString(),
              address: (map['address'] ?? '').toString(),
              latitude: map['latitude'] != null ? double.tryParse(map['latitude'].toString()) : null,
              longitude: map['longitude'] != null ? double.tryParse(map['longitude'].toString()) : null,
              patientName: pName.isNotEmpty ? pName : null,
              patientPhone: pPhone.isNotEmpty ? pPhone : null,
            );
          }).toList();
          _errorMessage = null;
          _isLoading = false;
        });
      } else {
        throw Exception(response['message']);
      }
    } catch (e) {
      setState(() {
        _appointments = [];
        _errorMessage = 'לא ניתן לטעון תורים אמיתיים כעת: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _resendPatientNotification(Appointment appointment) async {
    if (appointment.id.isEmpty) return;
    setState(() => _resendingNotificationId = appointment.id);
    try {
      await _appointmentService.resendPatientNotification(appointment.id);
      if (!mounted) return;
      ErrorHandler.showSnackBarAsDialog(
        context,
        const SnackBar(
          content: Text('ההודעה למטופל נשלחה מחדש'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ErrorHandler.showSnackBarAsDialog(
        context,
        SnackBar(
          content: Text('שליחה חוזרת נכשלה: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _resendingNotificationId = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Separate active and history appointments
    final activeAppointments = _appointments.where((apt) => 
      apt.status == 'pending' || apt.status == 'confirmed'
    ).toList();
    
    final historyAppointments = _appointments.where((apt) => 
      apt.status == 'completed' || apt.status == 'cancelled'
    ).toList();

    // Filter appointments based on selection
    final filteredAppointments = _selectedFilter == 'הכל'
        ? _appointments
        : _selectedFilter == 'פעיל'
            ? activeAppointments
            : _appointments.where((apt) => apt.status == _getStatusFromFilter(_selectedFilter)).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('התורים שלי'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        // REMOVED: Add button (Admin view only - no add from here)
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.redAccent),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Filter
                      Container(
                        padding: const EdgeInsets.all(16),
                        child: DropdownButtonFormField<String>(
                          value: _selectedFilter,
                          decoration: const InputDecoration(
                            labelText: 'סנן לפי סטטוס',
                            border: OutlineInputBorder(),
                          ),
                          items: _filters.map((filter) {
                            return DropdownMenuItem(
                              value: filter,
                              child: Text(filter),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedFilter = value!;
                            });
                          },
                        ),
                      ),
                      
                      // Active/Upcoming Appointments Section
                      if (_selectedFilter == 'הכל' || _selectedFilter == 'פעיל')
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Upcoming Appointments',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 16),
                              activeAppointments.isEmpty
                                  ? const Center(
                                      child: Padding(
                                        padding: EdgeInsets.all(40.0),
                                        child: Column(
                                          children: [
                                            Icon(Icons.calendar_today, size: 64, color: Colors.grey),
                                            SizedBox(height: 16),
                                            Text(
                                              'אין תורים פעילים',
                                              style: TextStyle(fontSize: 18, color: Colors.grey),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                  : Column(
                                      children: activeAppointments.map((appointment) {
                                        return AppointmentCard(
                                          appointment: appointment,
                                          onCancel: () => _cancelAppointment(appointment),
                                          onReschedule: () => _rescheduleAppointment(appointment),
                                          onNavigateToWaze: () => _navigateToWaze(appointment),
                                          onResend: _canResendPatientMessage
                                              ? () => _resendPatientNotification(appointment)
                                              : null,
                                          resendInProgress: _resendingNotificationId == appointment.id,
                                        );
                                      }).toList(),
                                    ),
                            ],
                          ),
                        ),
                      
                      // History Appointments Section
                      if (_selectedFilter == 'הכל' || _selectedFilter == 'הושלם' || _selectedFilter == 'בוטל')
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 20),
                              const Text(
                                'History Appointments',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 16),
                              historyAppointments.isEmpty
                                  ? const Center(
                                      child: Padding(
                                        padding: EdgeInsets.all(40.0),
                                        child: Column(
                                          children: [
                                            Icon(Icons.history, size: 64, color: Colors.grey),
                                            SizedBox(height: 16),
                                            Text(
                                              'אין תורים בהיסטוריה',
                                              style: TextStyle(fontSize: 18, color: Colors.grey),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                  : Column(
                                      children: historyAppointments.map((appointment) {
                                        return AppointmentCard(
                                          appointment: appointment,
                                          onCancel: null, // History appointments can't be cancelled
                                          onReschedule: null, // History appointments can't be rescheduled
                                          onNavigateToWaze: () => _navigateToWaze(appointment),
                                          onResend: _canResendPatientMessage
                                              ? () => _resendPatientNotification(appointment)
                                              : null,
                                          resendInProgress: _resendingNotificationId == appointment.id,
                                        );
                                      }).toList(),
                                    ),
                            ],
                          ),
                        ),
                      
                      // Filtered List (when specific filter is selected)
                      if (_selectedFilter != 'הכל' && _selectedFilter != 'פעיל' && _selectedFilter != 'הושלם' && _selectedFilter != 'בוטל')
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: filteredAppointments.isEmpty
                              ? const Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.calendar_today, size: 64, color: Colors.grey),
                                      SizedBox(height: 16),
                                      Text(
                                        'אין תורים',
                                        style: TextStyle(fontSize: 18, color: Colors.grey),
                                      ),
                                    ],
                                  ),
                                )
                              : Column(
                                  children: filteredAppointments.map((appointment) {
                                    return AppointmentCard(
                                      appointment: appointment,
                                      onCancel: () => _cancelAppointment(appointment),
                                      onReschedule: () => _rescheduleAppointment(appointment),
                                      onNavigateToWaze: () => _navigateToWaze(appointment),
                                      onResend: _canResendPatientMessage
                                          ? () => _resendPatientNotification(appointment)
                                          : null,
                                      resendInProgress: _resendingNotificationId == appointment.id,
                                    );
                                  }).toList(),
                                ),
                        ),
                    ],
                  ),
                ),
    );
  }

  String _getStatusFromFilter(String filter) {
    switch (filter) {
      case 'מאושר':
        return 'confirmed';
      case 'ממתין':
        return 'pending';
      case 'הושלם':
        return 'completed';
      case 'בוטל':
        return 'cancelled';
      default:
        return '';
    }
  }

  void _showNewAppointmentDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('תור חדש'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(labelText: 'שם הרופא'),
            ),
            SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(labelText: 'תאריך'),
            ),
            SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(labelText: 'שעה'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('ביטול'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ErrorHandler.showSnackBarAsDialog(context, 
                const SnackBar(
                  content: Text('התור נוסף בהצלחה'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('הוסף'),
          ),
        ],
      ),
    );
  }

  void _cancelAppointment(Appointment appointment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ביטול תור'),
        content: Text('האם אתה בטוח שברצונך לבטל את התור עם ${appointment.doctorName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('לא'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                appointment.status = 'cancelled';
              });
              ErrorHandler.showSnackBarAsDialog(context, 
                const SnackBar(
                  content: Text('התור בוטל בהצלחה'),
                  backgroundColor: Colors.orange,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('בטל תור'),
          ),
        ],
      ),
    );
  }

  void _rescheduleAppointment(Appointment appointment) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ReschedulePage(
          appointmentId: appointment.id,
          doctorId: appointment.doctorId,
          doctorName: appointment.doctorName,
          specialty: appointment.specialty,
          currentDate: DateTime.parse(appointment.date),
          currentTimeSlot: appointment.time,
        ),
      ),
    );
  }

  void _navigateToWaze(Appointment appointment) async {
    bool opened = false;
    
    // Try to open Waze with coordinates first (more accurate)
    if (appointment.latitude != null && appointment.longitude != null) {
      opened = await WazeService.openWazeWithCoordinates(
        appointment.latitude!,
        appointment.longitude!,
      );
    } 
    // Fall back to address
    else if (appointment.address != null) {
      opened = await WazeService.openWazeWithAddress(appointment.address!);
    }
    // Last resort: use location name
    else {
      opened = await WazeService.openWazeWithAddress(appointment.location);
    }
    
    if (mounted) {
      if (opened) {
        ErrorHandler.showSnackBarAsDialog(context, 
          const SnackBar(
            content: Text('פותח Waze...'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        ErrorHandler.showSnackBarAsDialog(context, 
          const SnackBar(
            content: Text('לא ניתן לפתוח את Waze. אנא התקין את האפליקציה'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }
}

class Appointment {
  final String id;
  final String doctorId;
  final String doctorName;
  final String specialty;
  final String date;
  final String time;
  String status;
  final String location;
  final String? address; // Full address for Waze navigation
  final double? latitude; // Optional: GPS coordinates
  final double? longitude; // Optional: GPS coordinates
  /// When the current user is a doctor, API returns patient contact for this visit.
  final String? patientName;
  final String? patientPhone;

  Appointment({
    required this.id,
    required this.doctorId,
    required this.doctorName,
    required this.specialty,
    required this.date,
    required this.time,
    required this.status,
    required this.location,
    this.address,
    this.latitude,
    this.longitude,
    this.patientName,
    this.patientPhone,
  });
}

class AppointmentCard extends StatelessWidget {
  final Appointment appointment;
  final VoidCallback? onCancel;
  final VoidCallback? onReschedule;
  final VoidCallback? onNavigateToWaze;
  final VoidCallback? onResend;
  final bool resendInProgress;

  const AppointmentCard({
    super.key,
    required this.appointment,
    this.onCancel,
    this.onReschedule,
    this.onNavigateToWaze,
    this.onResend,
    this.resendInProgress = false,
  });

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    String statusText;
    
    switch (appointment.status) {
      case 'confirmed':
        statusColor = Colors.green;
        statusText = 'מאושר';
        break;
      case 'pending':
      case 'scheduled':
        statusColor = Colors.orange;
        statusText = 'ממתין';
        break;
      case 'completed':
        statusColor = Colors.blue;
        statusText = 'הושלם';
        break;
      case 'cancelled':
        statusColor = Colors.red;
        statusText = 'בוטל';
        break;
      default:
        statusColor = Colors.grey;
        statusText = 'לא ידוע';
    }

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
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        (appointment.patientName != null && appointment.patientName!.isNotEmpty)
                            ? appointment.patientName!
                            : appointment.doctorName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (appointment.patientName != null && appointment.patientName!.isNotEmpty) ...[
                        Text(
                          'רופא: ${appointment.doctorName}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        Text(
                          appointment.specialty,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        if (appointment.patientPhone != null && appointment.patientPhone!.isNotEmpty)
                          Text(
                            'טלפון: ${appointment.patientPhone}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade700,
                            ),
                          ),
                      ] else
                        Text(
                          appointment.specialty,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      Row(
                        children: [
                          const Icon(Icons.location_on, size: 16, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(
                            appointment.location,
                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                          if (onNavigateToWaze != null) ...[
                            const SizedBox(width: 8),
                            InkWell(
                              onTap: onNavigateToWaze,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.blue,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.directions,
                                  size: 16,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: statusColor),
                  ),
                  child: Text(
                    statusText,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Text('${appointment.date} בשעה ${appointment.time}'),
              ],
            ),
            const SizedBox(height: 12),
            if (onResend != null) ...[
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: OutlinedButton.icon(
                  onPressed: resendInProgress ? null : onResend,
                  icon: resendInProgress
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.send_outlined, size: 18),
                  label: Text(resendInProgress ? 'שולח...' : 'שלח הודעה שוב למטופל'),
                ),
              ),
              const SizedBox(height: 8),
            ],
            if ((appointment.status == 'confirmed' ||
                    appointment.status == 'pending' ||
                    appointment.status == 'scheduled') &&
                (onCancel != null || onReschedule != null))
              Row(
                children: [
                  if (onReschedule != null) ...[
                    Expanded(
                      child: OutlinedButton(
                        onPressed: onReschedule,
                        child: const Text('דחה תור'),
                      ),
                    ),
                    if (onCancel != null) const SizedBox(width: 8),
                  ],
                  if (onCancel != null)
                    Expanded(
                      child: ElevatedButton(
                        onPressed: onCancel,
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                        child: const Text('בטל תור'),
                      ),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}









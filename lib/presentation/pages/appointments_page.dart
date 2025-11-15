import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'reschedule_page.dart';
import '../../services/waze_service.dart';

class AppointmentsPage extends StatefulWidget {
  const AppointmentsPage({super.key});

  @override
  State<AppointmentsPage> createState() => _AppointmentsPageState();
}

class _AppointmentsPageState extends State<AppointmentsPage> {
    final List<Appointment> _appointments = [
    Appointment(
      id: '1',
      doctorName: 'ד"ר אברהם כהן',
      specialty: 'רופא משפחה',
      date: '2024-01-15',
      time: '09:00',
      status: 'confirmed',
      location: 'תל אביב',
      address: 'תל אביב, רחוב רוטשילד 23',
      latitude: 32.0553,
      longitude: 34.7668,
    ),
    Appointment(
      id: '2',
      doctorName: 'ד"ר שרה לוי',
      specialty: 'קרדיולוג',
      date: '2024-01-18',
      time: '14:30',
      status: 'pending',
      location: 'ירושלים',
      address: 'ירושלים, רחוב יפו 35',
      latitude: 31.7683,
      longitude: 35.2137,
    ),
    Appointment(
      id: '3',
      doctorName: 'ד"ר דוד ישראלי',
      specialty: 'אורתופד',
      date: '2024-01-12',
      time: '11:00',
      status: 'completed',
      location: 'חיפה',
      address: 'חיפה, שדרות המגינים 47',
      latitude: 32.7940,
      longitude: 35.0000,
    ),
  ];

  String _selectedFilter = 'פעיל'; // Changed default to show active appointments
  final List<String> _filters = ['הכל', 'פעיל', 'מאושר', 'ממתין', 'הושלם', 'בוטל'];

  @override
  Widget build(BuildContext context) {
    // Filter appointments based on selection
    final filteredAppointments = _selectedFilter == 'הכל'
        ? _appointments
        : _selectedFilter == 'פעיל'
            ? _appointments.where((apt) => apt.status == 'pending' || apt.status == 'confirmed').toList()
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
      body: Column(
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
          
          // Appointments List
          Expanded(
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
                        Text(
                          'לחץ על + כדי להוסיף תור חדש',
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredAppointments.length,
                    itemBuilder: (context, index) {
                      final appointment = filteredAppointments[index];
                      return AppointmentCard(
                        appointment: appointment,
                        onCancel: () => _cancelAppointment(appointment),
                        onReschedule: () => _rescheduleAppointment(appointment),
                        onNavigateToWaze: () => _navigateToWaze(appointment),
                      );
                    },
                  ),
          ),
        ],
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
              ScaffoldMessenger.of(context).showSnackBar(
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
              ScaffoldMessenger.of(context).showSnackBar(
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('פותח Waze...'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
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
  final String doctorName;
  final String specialty;
  final String date;
  final String time;
  String status;
  final String location;
  final String? address; // Full address for Waze navigation
  final double? latitude; // Optional: GPS coordinates
  final double? longitude; // Optional: GPS coordinates

  Appointment({
    required this.id,
    required this.doctorName,
    required this.specialty,
    required this.date,
    required this.time,
    required this.status,
    required this.location,
    this.address,
    this.latitude,
    this.longitude,
  });
}

class AppointmentCard extends StatelessWidget {
  final Appointment appointment;
  final VoidCallback onCancel;
  final VoidCallback onReschedule;
  final VoidCallback? onNavigateToWaze;

  const AppointmentCard({
    super.key,
    required this.appointment,
    required this.onCancel,
    required this.onReschedule,
    this.onNavigateToWaze,
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
                        appointment.doctorName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
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
            if (appointment.status == 'confirmed' || appointment.status == 'pending')
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onReschedule,
                      child: const Text('דחה תור'),
                    ),
                  ),
                  const SizedBox(width: 8),
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









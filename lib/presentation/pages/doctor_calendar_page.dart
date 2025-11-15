import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../models/treatment_models_simple.dart';

class DoctorCalendarPage extends StatefulWidget {
  const DoctorCalendarPage({super.key});

  @override
  State<DoctorCalendarPage> createState() => _DoctorCalendarPageState();
}

class _DoctorCalendarPageState extends State<DoctorCalendarPage> {
  late final ValueNotifier<List<Appointment>> _selectedAppointments;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  
  // Treatment types and break periods from settings
  List<TreatmentTypeModel> _selectedTreatmentTypes = [];
  List<BreakPeriodModel> _selectedBreakPeriods = [];

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _selectedAppointments = ValueNotifier(_getAppointmentsForDay(_selectedDay!));
    _loadSettingsData();
  }
  
  // Load treatment types and break periods from settings
  Future<void> _loadSettingsData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Load treatment types
      final treatmentTypesString = prefs.getString('selected_treatment_types');
      if (treatmentTypesString != null) {
        final treatmentTypesData = jsonDecode(treatmentTypesString) as List;
        setState(() {
          _selectedTreatmentTypes = treatmentTypesData.map((data) => TreatmentTypeModel(
            id: data['id'],
            name: data['name'],
            description: data['description'],
            duration: Duration(minutes: data['duration']),
            price: data['price'].toDouble(),
            isActive: data['isActive'],
          )).toList();
        });
      }
      
      // Load break periods
      final breakPeriodsString = prefs.getString('selected_break_periods');
      if (breakPeriodsString != null) {
        final breakPeriodsData = jsonDecode(breakPeriodsString) as List;
        setState(() {
          _selectedBreakPeriods = breakPeriodsData.map((data) => BreakPeriodModel(
            id: data['id'],
            name: data['name'],
            startTime: DateTime.parse(data['startTime']),
            endTime: DateTime.parse(data['endTime']),
            daysOfWeek: List<int>.from(data['daysOfWeek']),
            isRecurring: data['isRecurring'],
          )).toList();
        });
      }
      
      // If no saved data, use defaults
      if (_selectedTreatmentTypes.isEmpty) {
        setState(() {
          _selectedTreatmentTypes = [
            TreatmentTypeModel(
              id: '1',
              name: '×™×™×¢×•×¥ ×›×œ×œ×™',
              description: '×™×™×¢×•×¥ ×¨×¤×•××™ ×›×œ×œ×™',
              duration: Duration(minutes: 30),
              price: 200.0,
              isActive: true,
            ),
            TreatmentTypeModel(
              id: '2',
              name: '×‘×“×™×§×” ×’×•×¤× ×™×ª',
              description: '×‘×“×™×§×” ×’×•×¤× ×™×ª ×ž×§×™×¤×”',
              duration: Duration(minutes: 45),
              price: 300.0,
              isActive: true,
            ),
          ];
          
          _selectedBreakPeriods = [
            BreakPeriodModel(
              id: '1',
              name: '×”×¤×¡×§×ª ×¦×”×¨×™×™×',
              startTime: DateTime(2024, 1, 1, 12, 0),
              endTime: DateTime(2024, 1, 1, 13, 0),
              daysOfWeek: [1, 2, 3, 4, 5],
              isRecurring: true,
            ),
          ];
        });
      }
    } catch (e) {
      print('Error loading settings data: $e');
    }
  }

  @override
  void dispose() {
    _selectedAppointments.dispose();
    super.dispose();
  }

  List<Appointment> _getAppointmentsForDay(DateTime day) {
    // Mock data - in real app, this would come from database
    return _appointments[day] ?? [];
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
      });
      _selectedAppointments.value = _getAppointmentsForDay(selectedDay);
    }
  }

  // Check if a day is enabled (not previous day or vacation day)
  bool _isDayEnabled(DateTime day) {
    final today = DateTime.now();
    final todayOnly = DateTime(today.year, today.month, today.day);
    final dayOnly = DateTime(day.year, day.month, day.day);
    
    // Disable previous days
    if (dayOnly.isBefore(todayOnly)) {
      return false;
    }
    
    // Disable vacation days
    if (_vacationDays.contains(dayOnly)) {
      return false;
    }
    
    return true;
  }
  
  // Refresh settings data from treatment settings page
  void _refreshSettings() {
    _loadSettingsData();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('×”×’×“×¨×•×ª ×¢×•×“×›× ×•: ${_selectedTreatmentTypes.length} ×˜×™×¤×•×œ×™×, ${_selectedBreakPeriods.length} ×”×¤×¡×§×•×ª'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }
  
  // Mock vacation days - in real app, this would come from doctor profile
  final Set<DateTime> _vacationDays = {
    DateTime(2024, 1, 20), // Sunday
    DateTime(2024, 1, 21), // Monday
    DateTime(2024, 1, 22), // Tuesday
    DateTime(2024, 2, 15), // Thursday
    DateTime(2024, 2, 16), // Friday
    DateTime(2024, 3, 10), // Sunday
    DateTime(2024, 3, 11), // Monday
  };

  // Mock appointment data with more examples including payment status
  final Map<DateTime, List<Appointment>> _appointments = {
    DateTime(2024, 1, 15): [
      Appointment(
        id: '1',
        patientName: '×™×•×¡×™ ×›×”×Ÿ',
        time: '09:00',
        duration: 30,
        type: '×‘×“×™×§×” ×›×œ×œ×™×ª',
        status: 'confirmed',
        paymentStatus: 'paid',
        amount: 200.0,
        patientId: 'patient_1',
        treatmentTypeId: 'treatment_1',
      ),
      Appointment(
        id: '2',
        patientName: '×©×¨×” ×œ×•×™',
        time: '10:30',
        duration: 45,
        type: '×™×™×¢×•×¥',
        status: 'confirmed',
        paymentStatus: 'paid',
        amount: 300.0,
        patientId: 'patient_2',
        treatmentTypeId: 'treatment_2',
      ),
      Appointment(
        id: '3',
        patientName: '×“×•×“ ×™×©×¨××œ×™',
        time: '14:00',
        duration: 30,
        type: '×ž×¢×§×‘',
        status: 'pending',
        paymentStatus: 'pending',
        amount: 200.0,
        patientId: 'patient_3',
        treatmentTypeId: 'treatment_1',
      ),
      Appointment(
        id: '4',
        patientName: '×ž×™×›×œ ××‘×¨×”×',
        time: '15:30',
        duration: 45,
        type: '×‘×“×™×§×” ×’×•×¤× ×™×ª',
        status: 'in_progress',
        paymentStatus: 'paid',
        amount: 300.0,
        patientId: 'patient_4',
        treatmentTypeId: 'treatment_2',
      ),
    ],
    DateTime(2024, 1, 16): [
      Appointment(
        id: '5',
        patientName: '××‘×™ ×›×”×Ÿ',
        time: '08:30',
        duration: 30,
        type: '×™×™×¢×•×¥ ×›×œ×œ×™',
        status: 'confirmed',
        paymentStatus: 'paid',
        amount: 200.0,
        patientId: 'patient_5',
        treatmentTypeId: 'treatment_1',
      ),
      Appointment(
        id: '6',
        patientName: '×¨×—×œ ×’×•×œ×“',
        time: '11:00',
        duration: 45,
        type: '×‘×“×™×§×” ×’×•×¤× ×™×ª',
        status: 'in_progress',
        paymentStatus: 'pending',
        amount: 300.0,
        patientId: 'patient_6',
        treatmentTypeId: 'treatment_2',
      ),
      Appointment(
        id: '7',
        patientName: '×ž×©×” ×œ×•×™',
        time: '13:30',
        duration: 30,
        type: '×ž×¢×§×‘',
        status: 'completed',
        paymentStatus: 'paid',
        amount: 200.0,
        patientId: 'patient_7',
        treatmentTypeId: 'treatment_1',
      ),
    ],
    DateTime(2024, 1, 17): [
      Appointment(
        id: '8',
        patientName: '×“×™× ×” ×©×˜×¨×Ÿ',
        time: '09:30',
        duration: 45,
        type: '×™×™×¢×•×¥ ×ž×•×ž×—×”',
        status: 'confirmed',
        paymentStatus: 'paid',
        amount: 400.0,
        patientId: 'patient_8',
        treatmentTypeId: 'treatment_3',
      ),
      Appointment(
        id: '9',
        patientName: '×™×•× ×ª×Ÿ ×‘×¨×§',
        time: '11:30',
        duration: 30,
        type: '×‘×“×™×§×” ×›×œ×œ×™×ª',
        status: 'in_progress',
        paymentStatus: 'offline',
        amount: 200.0,
        patientId: 'patient_9',
        treatmentTypeId: 'treatment_1',
      ),
      Appointment(
        id: '10',
        patientName: '×ª×ž×¨ ×¨×•×–×Ÿ',
        time: '14:00',
        duration: 45,
        type: '×‘×“×™×§×” ×’×•×¤× ×™×ª',
        status: 'pending',
        paymentStatus: 'pending',
        amount: 300.0,
        patientId: 'patient_10',
        treatmentTypeId: 'treatment_2',
      ),
    ],
    DateTime(2024, 1, 18): [
      Appointment(
        id: '11',
        patientName: '××œ×™×”×• ×›×”×Ÿ',
        time: '08:00',
        duration: 30,
        type: '×™×™×¢×•×¥ ×›×œ×œ×™',
        status: 'confirmed',
        paymentStatus: 'paid',
        amount: 200.0,
        patientId: 'patient_11',
        treatmentTypeId: 'treatment_1',
      ),
      Appointment(
        id: '12',
        patientName: '× ×¢×ž×™ ×’×•×œ×“',
        time: '10:00',
        duration: 45,
        type: '×‘×“×™×§×” ×’×•×¤× ×™×ª',
        status: 'completed',
        paymentStatus: 'paid',
        amount: 300.0,
        patientId: 'patient_12',
        treatmentTypeId: 'treatment_2',
      ),
      Appointment(
        id: '13',
        patientName: '×©×ž×•××œ ×œ×•×™',
        time: '12:00',
        duration: 30,
        type: '×ž×¢×§×‘',
        status: 'in_progress',
        paymentStatus: 'pending',
        amount: 200.0,
        patientId: 'patient_13',
        treatmentTypeId: 'treatment_1',
      ),
    ],
    DateTime(2024, 1, 19): [
      Appointment(
        id: '14',
        patientName: '×¨×—×œ ××‘×¨×”×',
        time: '09:00',
        duration: 45,
        type: '×™×™×¢×•×¥ ×ž×•×ž×—×”',
        status: 'confirmed',
        paymentStatus: 'paid',
        amount: 400.0,
        patientId: 'patient_14',
        treatmentTypeId: 'treatment_3',
      ),
      Appointment(
        id: '15',
        patientName: '×™×•×¡×£ ×‘×¨×§',
        time: '11:00',
        duration: 30,
        type: '×‘×“×™×§×” ×›×œ×œ×™×ª',
        status: 'pending',
        paymentStatus: 'pending',
        amount: 200.0,
        patientId: 'patient_15',
        treatmentTypeId: 'treatment_1',
      ),
    ],
  };

  @override
  void dispose() {
    _selectedAppointments.dispose();
    super.dispose();
  }

  // Check if a day is enabled (not previous day or vacation day)
  bool _isDayEnabled(DateTime day) {
    final today = DateTime.now();
    final todayOnly = DateTime(today.year, today.month, today.day);
    final dayOnly = DateTime(day.year, day.month, day.day);
    
    // Disable previous days
    if (dayOnly.isBefore(todayOnly)) {
      return false;
    }
    
    // Disable vacation days
    if (_vacationDays.contains(dayOnly)) {
      return false;
    }
    
    return true;
  }

  // Refresh settings data from treatment settings page
  void _refreshSettings() {
    _loadSettingsData();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('×”×’×“×¨×•×ª ×¢×•×“×›× ×•: ${_selectedTreatmentTypes.length} ×˜×™×¤×•×œ×™×, ${_selectedBreakPeriods.length} ×”×¤×¡×§×•×ª'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // Mock vacation days - in real app, this would come from doctor profile
  final Set<DateTime> _vacationDays = {
    DateTime(2024, 1, 20), // Sunday
    DateTime(2024, 1, 21), // Monday
    DateTime(2024, 1, 22), // Tuesday
    DateTime(2024, 2, 15), // Thursday
    DateTime(2024, 2, 16), // Friday
    DateTime(2024, 3, 10), // Sunday
    DateTime(2024, 3, 11), // Monday
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('×œ×•×— ×–×ž× ×™× - ×¨×•×¤×'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshSettings,
            tooltip: '×¨×¢× ×Ÿ ×”×’×“×¨×•×ª',
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _addAppointment,
            tooltip: '×”×•×¡×£ ×ª×•×¨',
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _openSettings,
            tooltip: '×”×’×“×¨×•×ª',
          ),
        ],
      ),
      body: Column(
        children: [
          // Calendar
          Card(
            margin: const EdgeInsets.all(16),
            child: TableCalendar<Appointment>(
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _focusedDay,
              calendarFormat: _calendarFormat,
              eventLoader: _getAppointmentsForDay,
              startingDayOfWeek: StartingDayOfWeek.sunday,
              enabledDayPredicate: _isDayEnabled,
              calendarStyle: const CalendarStyle(
                outsideDaysVisible: false,
                weekendTextStyle: TextStyle(color: Colors.red),
                holidayTextStyle: TextStyle(color: Colors.red),
                disabledTextStyle: TextStyle(color: Colors.grey),
              ),
              headerStyle: const HeaderStyle(
                formatButtonVisible: true,
                titleCentered: true,
                formatButtonShowsNext: false,
                formatButtonDecoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.all(Radius.circular(12.0)),
                ),
                formatButtonTextStyle: TextStyle(
                  color: Colors.white,
                ),
              ),
              onDaySelected: _onDaySelected,
              onFormatChanged: (format) {
                if (_calendarFormat != format) {
                  setState(() {
                    _calendarFormat = format;
                  });
                }
              },
              selectedDayPredicate: (day) {
                return isSameDay(_selectedDay, day);
              },
            ),
          ),
          // Treatment types and break periods info
          _buildSettingsInfo(),
          // Selected day appointments
          Expanded(
            child: ValueListenableBuilder<List<Appointment>>(
              valueListenable: _selectedAppointments,
              builder: (context, appointments, _) {
                return _buildAppointmentsList(appointments);
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addAppointment,
        child: const Icon(Icons.add),
        tooltip: '×”×•×¡×£ ×ª×•×¨ ×—×“×©',
      ),
    );
  }

  Widget _buildSettingsInfo() {
    return Card(
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.info_outline, color: Colors.blue),
                const SizedBox(width: 8),
                const Text(
                  '×”×’×“×¨×•×ª ×¤×¢×™×œ×•×ª',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '×˜×™×¤×•×œ×™× ×–×ž×™× ×™×: ${_selectedTreatmentTypes.map((t) => t.name).join(', ')}',
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 4),
            Text(
              '×”×¤×¡×§×•×ª: ${_selectedBreakPeriods.map((bp) => bp.name).join(', ')}',
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppointmentsList(List<Appointment> appointments) {
    if (appointments.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_busy,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              '××™×Ÿ ×ª×•×¨×™× ×‘×™×•× ×–×”',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: appointments.length,
      itemBuilder: (context, index) {
        final appointment = appointments[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: _getStatusColor(appointment.status),
              child: Icon(
                _getStatusIcon(appointment.status),
                color: Colors.white,
              ),
            ),
            title: Text(
              appointment.patientName,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('×©×¢×”: ${appointment.time}'),
                Text('×¡×•×’: ${appointment.type}'),
                Text('×ž×©×š: ${appointment.duration} ×“×§×•×ª'),
                Text('×¡×›×•×: â‚ª${appointment.amount.toStringAsFixed(0)}'),
                Row(
                  children: [
                    Icon(
                      _getPaymentStatusIcon(appointment.paymentStatus),
                      size: 16,
                      color: _getPaymentStatusColor(appointment.paymentStatus),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _getPaymentStatusText(appointment.paymentStatus),
                      style: TextStyle(
                        color: _getPaymentStatusColor(appointment.paymentStatus),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            trailing: PopupMenuButton<String>(
              onSelected: (value) => _handleAppointmentAction(value, appointment),
              itemBuilder: (context) => _buildAppointmentMenuItems(appointment),
            ),
          ),
        );
      },
    );
  }

  List<PopupMenuEntry<String>> _buildAppointmentMenuItems(Appointment appointment) {
    List<PopupMenuEntry<String>> items = [];
    
    // Common actions
    items.addAll([
      const PopupMenuItem(
        value: 'edit',
        child: Row(
          children: [
            Icon(Icons.edit),
            SizedBox(width: 8),
            Text('×¢×¨×•×š'),
          ],
        ),
      ),
      const PopupMenuItem(
        value: 'cancel',
        child: Row(
          children: [
            Icon(Icons.cancel),
            SizedBox(width: 8),
            Text('×‘×˜×œ'),
          ],
        ),
      ),
    ]);
    
    // Status-specific actions
    if (appointment.status == 'in_progress') {
      items.addAll([
        const PopupMenuItem(
          value: 'book_next',
          child: Row(
            children: [
              Icon(Icons.add_circle),
              SizedBox(width: 8),
              Text('×§×‘×¢ ×ª×•×¨ × ×•×¡×£'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'request_payment',
          child: Row(
            children: [
              Icon(Icons.payment),
              SizedBox(width: 8),
              Text('×‘×§×© ×ª×©×œ×•×'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'pay_offline',
          child: Row(
            children: [
              Icon(Icons.credit_card),
              SizedBox(width: 8),
              Text('×ª×©×œ×•× ××•×¤×œ×™×™×Ÿ'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'complete',
          child: Row(
            children: [
              Icon(Icons.check),
              SizedBox(width: 8),
              Text('×¡×™×™× ×˜×™×¤×•×œ'),
            ],
          ),
        ),
      ]);
    } else if (appointment.status == 'confirmed') {
      items.add(const PopupMenuItem(
        value: 'start',
        child: Row(
          children: [
            Icon(Icons.play_arrow),
            SizedBox(width: 8),
            Text('×”×ª×—×œ ×˜×™×¤×•×œ'),
          ],
        ),
      ));
    } else if (appointment.status == 'pending') {
      items.add(const PopupMenuItem(
        value: 'confirm',
        child: Row(
          children: [
            Icon(Icons.check_circle),
            SizedBox(width: 8),
            Text('××©×¨ ×ª×•×¨'),
          ],
        ),
      ));
    }
    
    return items;
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
      case 'in_progress':
        return Colors.purple;
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
        return Icons.done;
      case 'in_progress':
        return Icons.play_circle;
      default:
        return Icons.help;
    }
  }

  Color _getPaymentStatusColor(String paymentStatus) {
    switch (paymentStatus) {
      case 'paid':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'offline':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  IconData _getPaymentStatusIcon(String paymentStatus) {
    switch (paymentStatus) {
      case 'paid':
        return Icons.check_circle;
      case 'pending':
        return Icons.payment;
      case 'offline':
        return Icons.credit_card;
      default:
        return Icons.help;
    }
  }

  String _getPaymentStatusText(String paymentStatus) {
    switch (paymentStatus) {
      case 'paid':
        return '×©×•×œ×';
      case 'pending':
        return '×ž×ž×ª×™×Ÿ ×œ×ª×©×œ×•×';
      case 'offline':
        return '×ª×©×œ×•× ××•×¤×œ×™×™×Ÿ';
      default:
        return '×œ× ×™×“×•×¢';
    }
  }

  void _addAppointment() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('×”×•×¡×£ ×ª×•×¨ ×—×“×©'),
        content: const Text('×¤×•× ×§×¦×™×•× ×œ×™×•×ª ×–×• ×ª×”×™×” ×–×ž×™× ×” ×‘×§×¨×•×‘'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('××™×©×•×¨'),
          ),
        ],
      ),
    );
  }

  void _openSettings() {
    Navigator.pushNamed(context, '/doctor-treatment-settings');
  }

  void _handleAppointmentAction(String action, Appointment appointment) {
    switch (action) {
      case 'edit':
        _editAppointment(appointment);
        break;
      case 'cancel':
        _cancelAppointment(appointment);
        break;
      case 'complete':
        _completeAppointment(appointment);
        break;
      case 'start':
        _startAppointment(appointment);
        break;
      case 'confirm':
        _confirmAppointment(appointment);
        break;
      case 'book_next':
        _bookNextAppointment(appointment);
        break;
      case 'request_payment':
        _requestPayment(appointment);
        break;
      case 'pay_offline':
        _payOffline(appointment);
        break;
    }
  }

  void _editAppointment(Appointment appointment) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('×¢×¨×™×›×ª ×ª×•×¨ - ×¤×•× ×§×¦×™×•× ×œ×™×•×ª ×‘×§×¨×•×‘')),
    );
  }

  void _cancelAppointment(Appointment appointment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('×‘×™×˜×•×œ ×ª×•×¨'),
        content: Text('×”×× ××ª×” ×‘×˜×•×— ×©×‘×¨×¦×•× ×š ×œ×‘×˜×œ ××ª ×”×ª×•×¨ ×©×œ ${appointment.patientName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('×‘×™×˜×•×œ'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('×”×ª×•×¨ ×‘×•×˜×œ ×‘×”×¦×œ×—×”')),
              );
            },
            child: const Text('××™×©×•×¨'),
          ),
        ],
      ),
    );
  }

  void _completeAppointment(Appointment appointment) {
    Navigator.pushNamed(
      context,
      '/treatment-completion',
      arguments: {
        'appointmentId': appointment.id,
        'patientId': appointment.patientId ?? 'unknown',
        'patientName': appointment.patientName,
        'treatmentTypeId': appointment.treatmentTypeId ?? 'unknown',
        'treatmentTypeName': appointment.type,
        'amount': appointment.amount,
      },
    );
  }

  void _startAppointment(Appointment appointment) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('×”×ª×—×œ×ª ×˜×™×¤×•×œ ×¢×‘×•×¨ ${appointment.patientName}'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _confirmAppointment(Appointment appointment) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('×ª×•×¨ ×©×œ ${appointment.patientName} ××•×©×¨'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _bookNextAppointment(Appointment appointment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('×§×‘×¢ ×ª×•×¨ × ×•×¡×£'),
        content: Text('×§×‘×¢ ×ª×•×¨ × ×•×¡×£ ×¢×‘×•×¨ ${appointment.patientName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('×‘×™×˜×•×œ'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('×ª×•×¨ × ×•×¡×£ × ×§×‘×¢ ×¢×‘×•×¨ ${appointment.patientName}'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('××™×©×•×¨'),
          ),
        ],
      ),
    );
  }

  void _requestPayment(Appointment appointment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('×‘×§×© ×ª×©×œ×•×'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('×©×œ×— ×‘×§×©×” ×œ×ª×©×œ×•× ×¢×‘×•×¨ ${appointment.patientName}'),
            const SizedBox(height: 16),
            Text('×¡×›×•×: â‚ª${appointment.amount.toStringAsFixed(0)}'),
            const SizedBox(height: 16),
            const Text('×”×‘×§×©×” ×ª×™×©×œ×— ×œ×•×•×˜×¡××¤'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('×‘×™×˜×•×œ'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _sendWhatsAppPaymentRequest(appointment);
            },
            child: const Text('×©×œ×— ×‘×§×©×”'),
          ),
        ],
      ),
    );
  }

  void _payOffline(Appointment appointment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('×ª×©×œ×•× ××•×¤×œ×™×™×Ÿ'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('×¡×ž×Ÿ ×ª×©×œ×•× ××•×¤×œ×™×™×Ÿ ×¢×‘×•×¨ ${appointment.patientName}'),
            const SizedBox(height: 16),
            Text('×¡×›×•×: â‚ª${appointment.amount.toStringAsFixed(0)}'),
            const SizedBox(height: 16),
            const Text('×”×ª×©×œ×•× ×‘×•×¦×¢ ×‘×ž×›×•× ×ª ×›×¨×˜×™×¡×™ ××©×¨××™ ××• ×‘×ž×–×•×ž×Ÿ'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('×‘×™×˜×•×œ'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('×ª×©×œ×•× ××•×¤×œ×™×™×Ÿ ×¡×•×ž×Ÿ ×¢×‘×•×¨ ${appointment.patientName}'),
                  backgroundColor: Colors.blue,
                ),
              );
            },
            child: const Text('××™×©×•×¨'),
          ),
        ],
      ),
    );
  }

  void _sendWhatsAppPaymentRequest(Appointment appointment) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('×”×•×“×¢×ª ×ª×©×œ×•× × ×©×œ×—×” ×œ×•×•×˜×¡××¤ ×©×œ ${appointment.patientName}'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}

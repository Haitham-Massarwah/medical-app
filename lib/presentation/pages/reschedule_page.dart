import 'package:flutter/material.dart';
import 'calendar_booking_page.dart';

class ReschedulePage extends StatefulWidget {
  final String appointmentId;
  final String doctorName;
  final String specialty;
  final DateTime currentDate;
  final String currentTimeSlot;

  const ReschedulePage({
    super.key,
    required this.appointmentId,
    required this.doctorName,
    required this.specialty,
    required this.currentDate,
    required this.currentTimeSlot,
  });

  @override
  State<ReschedulePage> createState() => _ReschedulePageState();
}

class _ReschedulePageState extends State<ReschedulePage> {
  DateTime? _selectedDate;
  String? _selectedTimeSlot;
  bool _isLoading = false;

  // Mock available dates (next 30 days)
  List<DateTime> get _availableDates {
    final today = DateTime.now();
    final availableDates = <DateTime>[];
    
    for (int i = 1; i <= 30; i++) {
      final date = today.add(Duration(days: i));
      // Skip weekends for this example
      if (date.weekday != DateTime.saturday && date.weekday != DateTime.sunday) {
        availableDates.add(date);
      }
    }
    
    return availableDates;
  }

  // Mock available time slots
  List<String> get _availableTimeSlots {
    if (_selectedDate == null) return [];
    
    // Different time slots based on day of week
    if (_selectedDate!.weekday == DateTime.monday || _selectedDate!.weekday == DateTime.wednesday) {
      return ['08:00', '09:30', '11:00', '14:00', '15:30', '17:00'];
    } else if (_selectedDate!.weekday == DateTime.tuesday || _selectedDate!.weekday == DateTime.thursday) {
      return ['09:00', '10:30', '12:00', '13:30', '15:00', '16:30'];
    } else if (_selectedDate!.weekday == DateTime.friday) {
      return ['08:30', '10:00', '11:30', '13:00'];
    }
    
    return [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('דחיית תור'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Current Appointment Info
            Card(
              elevation: 4,
              color: Colors.orange.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'התור הנוכחי',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 25,
                          backgroundColor: Colors.orange.shade100,
                          child: Text(
                            widget.doctorName.split(' ')[1].substring(0, 1),
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.doctorName,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                widget.specialty,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              Text(
                                '${_formatDate(widget.currentDate)} בשעה ${widget.currentTimeSlot}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // New Date Selection
            const Text(
              'בחר תאריך חדש',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // Calendar Widget
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                children: [
                  // Calendar Header
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'לוח שנה',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          _getCurrentMonthYear(),
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Calendar Grid
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        // Days of week header (Hebrew RTL)
                        Row(
                          children: ['ש', 'ו', 'ה', 'ד', 'ג', 'ב', 'א']
                              .map((day) => Expanded(
                                    child: Center(
                                      child: Text(
                                        day,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ),
                                  ))
                              .toList(),
                        ),
                        
                        const SizedBox(height: 8),
                        
                        // Calendar days
                        ..._buildCalendarGrid(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Time Slots Section
            if (_selectedDate != null) ...[
              const Text(
                'בחר שעה חדשה',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              
              // Time Slots Grid
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _availableTimeSlots.map((timeSlot) {
                  final isSelected = _selectedTimeSlot == timeSlot;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedTimeSlot = timeSlot;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.orange : Colors.white,
                        border: Border.all(
                          color: isSelected ? Colors.orange : Colors.grey.shade300,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        timeSlot,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              
              const SizedBox(height: 32),
              
              // Reschedule Summary
              if (_selectedDate != null && _selectedTimeSlot != null) ...[
                Card(
                  color: Colors.blue.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'סיכום הדחייה',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text('תאריך חדש: ${_formatDate(_selectedDate!)}'),
                        Text('שעה חדשה: $_selectedTimeSlot'),
                        Text('רופא: ${widget.doctorName}'),
                        Text('התמחות: ${widget.specialty}'),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'התור הקודם יבוטל אוטומטית',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.orange,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Reschedule Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _rescheduleAppointment,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text(
                            'דחה תור',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  List<Widget> _buildCalendarGrid() {
    final today = DateTime.now();
    final firstDayOfMonth = DateTime(today.year, today.month, 1);
    final lastDayOfMonth = DateTime(today.year, today.month + 1, 0);
    final firstWeekday = firstDayOfMonth.weekday;
    
    final weeks = <Widget>[];
    final currentWeek = <Widget>[];
    
    // Add empty cells for days before the first day of month
    for (int i = 1; i < firstWeekday; i++) {
      currentWeek.add(const Expanded(child: SizedBox()));
    }
    
    // Add days of the month
    for (int day = 1; day <= lastDayOfMonth.day; day++) {
      final date = DateTime(today.year, today.month, day);
      final isAvailable = _availableDates.any((d) => 
          d.year == date.year && d.month == date.month && d.day == day);
      final isSelected = _selectedDate != null &&
          _selectedDate!.year == date.year &&
          _selectedDate!.month == date.month &&
          _selectedDate!.day == day;
      final isPast = date.isBefore(DateTime(today.year, today.month, today.day));
      
      currentWeek.add(
        Expanded(
          child: GestureDetector(
            onTap: isAvailable && !isPast ? () {
              setState(() {
                _selectedDate = date;
                _selectedTimeSlot = null; // Reset time selection
              });
            } : null,
            child: Container(
              margin: const EdgeInsets.all(2),
              height: 40,
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.orange
                    : isAvailable && !isPast
                        ? Colors.green.shade50
                        : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isSelected
                      ? Colors.orange
                      : isAvailable && !isPast
                          ? Colors.green
                          : Colors.grey.shade300,
                ),
              ),
              child: Center(
                child: Text(
                  '$day',
                  style: TextStyle(
                    color: isSelected
                        ? Colors.white
                        : isAvailable && !isPast
                            ? Colors.green.shade700
                            : Colors.grey,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      
      // Start new week if we've added 7 days
      if (currentWeek.length == 7) {
        weeks.add(Row(children: currentWeek));
        currentWeek.clear();
      }
    }
    
    // Add remaining empty cells for the last week
    while (currentWeek.length < 7) {
      currentWeek.add(const Expanded(child: SizedBox()));
    }
    if (currentWeek.isNotEmpty) {
      weeks.add(Row(children: currentWeek));
    }
    
    return weeks;
  }

  String _getCurrentMonthYear() {
    final now = DateTime.now();
    final months = [
      'ינואר', 'פברואר', 'מרץ', 'אפריל', 'מאי', 'יוני',
      'יולי', 'אוגוסט', 'ספטמבר', 'אוקטובר', 'נובמבר', 'דצמבר'
    ];
    return '${months[now.month - 1]} ${now.year}';
  }

  String _formatDate(DateTime date) {
    final months = [
      'ינואר', 'פברואר', 'מרץ', 'אפריל', 'מאי', 'יוני',
      'יולי', 'אוגוסט', 'ספטמבר', 'אוקטובר', 'נובמבר', 'דצמבר'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  void _rescheduleAppointment() async {
    if (_selectedDate == null || _selectedTimeSlot == null) return;

    setState(() {
      _isLoading = true;
    });

    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isLoading = false;
    });

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('התור נדחה בהצלחה ל${_formatDate(_selectedDate!)} בשעה $_selectedTimeSlot'),
        backgroundColor: Colors.green,
      ),
    );

    // Navigate back to appointments page
    Navigator.of(context).pop();
    Navigator.of(context).pushNamed('/appointments');
  }
}











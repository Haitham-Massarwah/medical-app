import 'package:flutter/material.dart';
import '../../services/appointment_service.dart';
import 'payment_page.dart';

class CalendarBookingPage extends StatefulWidget {
  final String doctorId;
  final String doctorName;
  final String specialty;
  final double consultationFee;

  const CalendarBookingPage({
    super.key,
    required this.doctorId,
    required this.doctorName,
    required this.specialty,
    this.consultationFee = 250.0, // Default fee
  });

  @override
  State<CalendarBookingPage> createState() => _CalendarBookingPageState();
}

class _CalendarBookingPageState extends State<CalendarBookingPage> {
  final AppointmentService _appointmentService = AppointmentService();
  
  DateTime _currentMonth = DateTime.now();
  DateTime? _selectedDate;
  String? _selectedTimeSlot;
  List<DateTime> _availableDates = [];
  List<String> _timeSlots = [];
  bool _isLoadingDates = false;
  bool _isLoadingSlots = false;

  // Hebrew day names (Sunday to Saturday)
  final List<String> _hebrewDayNames = [
    'א׳', // Sunday
    'ב׳', // Monday
    'ג׳', // Tuesday
    'ד׳', // Wednesday
    'ה׳', // Thursday
    'ו׳', // Friday
    'ש׳', // Saturday
  ];

  // Hebrew month names
  final List<String> _hebrewMonthNames = [
    'ינואר', 'פברואר', 'מרץ', 'אפריל', 'מאי', 'יוני',
    'יולי', 'אוגוסט', 'ספטמבר', 'אוקטובר', 'נובמבר', 'דצמבר'
  ];

  @override
  void initState() {
    super.initState();
    _loadAvailableDates();
  }

  Future<void> _loadAvailableDates() async {
    setState(() => _isLoadingDates = true);
    
    try {
      // Get first and last day of current month
      final firstDay = DateTime(_currentMonth.year, _currentMonth.month, 1);
      final lastDay = DateTime(_currentMonth.year, _currentMonth.month + 1, 0);
      
      // Fetch available dates from API
      final dates = await _appointmentService.getAvailableDates(
        widget.doctorId,
        firstDay,
        lastDay,
      );
      
      setState(() {
        _availableDates = dates;
        _isLoadingDates = false;
      });
    } catch (e) {
      setState(() => _isLoadingDates = false);
      setState(() => _availableDates = []);
    }
  }

  Future<void> _loadTimeSlots(DateTime date) async {
    setState(() => _isLoadingSlots = true);
    
    try {
      final slots = await _appointmentService.getAvailableTimeSlots(
        widget.doctorId,
        date,
      );
      
      setState(() {
        _timeSlots = slots;
        _isLoadingSlots = false;
      });
    } catch (e) {
      setState(() => _isLoadingSlots = false);
      setState(() {
        _timeSlots = [];
      });
    }
  }

  void _previousMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1);
      _selectedDate = null;
      _selectedTimeSlot = null;
      _timeSlots = [];
    });
    _loadAvailableDates();
  }

  void _nextMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1);
      _selectedDate = null;
      _selectedTimeSlot = null;
      _timeSlots = [];
    });
    _loadAvailableDates();
  }

  void _onDateSelected(DateTime date) {
    setState(() {
      _selectedDate = date;
      _selectedTimeSlot = null;
    });
    _loadTimeSlots(date);
  }

  bool _isDateAvailable(DateTime date) {
    return _availableDates.any((d) =>
        d.year == date.year &&
        d.month == date.month &&
        d.day == date.day);
  }

  void _bookAppointment() {
    if (_selectedDate == null || _selectedTimeSlot == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('אנא בחר תאריך ושעה'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Show booking options
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('בחר אפשרות'),
        content: const Text('איך תרצה להמשיך?'),
        actions: [
          // PD-09: Cart completely disabled - removed "Add to Cart" button entirely
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _bookNow();
            },
            child: const Text('קבע עכשיו'),
          ),
        ],
      ),
    );
  }

  // PD-09: Cart functionality disabled
  void _addToCart() {
    // Feature disabled - show "SOON" message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('עגלת התורים תהיה זמינה בקרוב'),
        backgroundColor: Colors.orange,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _bookNow() {
    // Navigate to single payment page
    Navigator.pushNamed(
      context,
      '/payment',
      arguments: {
        'doctorId': widget.doctorId,
        'doctorName': widget.doctorName,
        'appointmentDate': _selectedDate,
        'appointmentTime': _selectedTimeSlot,
        'amount': widget.consultationFee,
      },
    );
  }

  Widget _buildCalendarHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_forward),
            onPressed: _previousMonth,
          ),
          Text(
            '${_hebrewMonthNames[_currentMonth.month - 1]} ${_currentMonth.year}',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: _nextMonth,
          ),
        ],
      ),
    );
  }

  Widget _buildDayNamesRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: _hebrewDayNames.map((day) => Expanded(
          child: Center(
            child: Text(
              day,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        )).toList(),
      ),
    );
  }

  Widget _buildCalendarGrid() {
    if (_isLoadingDates) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: CircularProgressIndicator(),
        ),
      );
    }

    // Get first day of the month
    final firstDayOfMonth = DateTime(_currentMonth.year, _currentMonth.month, 1);
    final lastDayOfMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 0);
    
    // Get weekday of first day (0 = Sunday in Hebrew calendar)
    int firstWeekday = firstDayOfMonth.weekday % 7; // Convert to 0-6 where 0 is Sunday
    
    // Calculate total cells needed
    final daysInMonth = lastDayOfMonth.day;
    final totalCells = firstWeekday + daysInMonth;
    final rows = (totalCells / 7).ceil();

    List<Widget> dayWidgets = [];

    // Add empty cells for days before month starts
    for (int i = 0; i < firstWeekday; i++) {
      dayWidgets.add(const SizedBox.shrink());
    }

    // Add day cells
    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(_currentMonth.year, _currentMonth.month, day);
      final isAvailable = _isDateAvailable(date);
      final isSelected = _selectedDate != null &&
          _selectedDate!.year == date.year &&
          _selectedDate!.month == date.month &&
          _selectedDate!.day == date.day;
      final isPast = date.isBefore(DateTime.now().subtract(const Duration(days: 1)));

      dayWidgets.add(_buildDayCell(day, date, isAvailable, isSelected, isPast));
    }

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 7,
      padding: const EdgeInsets.all(8),
      children: dayWidgets,
    );
  }

  Widget _buildDayCell(int day, DateTime date, bool isAvailable, bool isSelected, bool isPast) {
    Color bgColor;
    Color textColor;
    
    if (isPast) {
      bgColor = Colors.grey.shade200;
      textColor = Colors.grey.shade400;
    } else if (isSelected) {
      bgColor = Colors.blue;
      textColor = Colors.white;
    } else if (isAvailable) {
      bgColor = Colors.green.shade100;
      textColor = Colors.green.shade900;
    } else {
      bgColor = Colors.grey.shade100;
      textColor = Colors.grey.shade600;
    }

    return GestureDetector(
      onTap: (isAvailable && !isPast) ? () => _onDateSelected(date) : null,
      child: Container(
        margin: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(8),
          border: isSelected ? Border.all(color: Colors.blue, width: 2) : null,
        ),
        child: Center(
          child: Text(
            '$day',
            style: TextStyle(
              color: textColor,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTimeSlots() {
    if (_selectedDate == null) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Text(
          'בחר תאריך כדי לראות שעות פנויות',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    if (_isLoadingSlots) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_timeSlots.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Text(
          'אין שעות פנויות בתאריך זה',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.red),
        ),
      );
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: _timeSlots.map((slot) {
        final isSelected = _selectedTimeSlot == slot;
        return GestureDetector(
          onTap: () => setState(() => _selectedTimeSlot = slot),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected ? Colors.blue : Colors.white,
              border: Border.all(
                color: isSelected ? Colors.blue : Colors.grey.shade300,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              slot,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 16,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text('קביעת תור - ${widget.doctorName}'),
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              // Doctor info card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                color: Colors.blue.shade50,
                child: Column(
                  children: [
                    Text(
                      widget.doctorName,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.specialty,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ),

              // Legend
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildLegendItem(Colors.green.shade100, 'תאריכים פנויים'),
                    _buildLegendItem(Colors.grey.shade200, 'תאריכים לא זמינים'),
                    _buildLegendItem(Colors.blue, 'נבחר'),
                  ],
                ),
              ),

              // Calendar
              _buildCalendarHeader(),
              _buildDayNamesRow(),
              _buildCalendarGrid(),

              const Divider(height: 32, thickness: 2),

              // Time slots
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Text(
                      'בחר שעה',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildTimeSlots(),
                  ],
                ),
              ),

              // Book button
              Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _bookAppointment,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'המשך לתשלום',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }
}

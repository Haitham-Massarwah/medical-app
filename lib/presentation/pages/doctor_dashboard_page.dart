import 'package:flutter/material.dart';

class DoctorDashboardPage extends StatefulWidget {
  const DoctorDashboardPage({super.key});

  @override
  State<DoctorDashboardPage> createState() => _DoctorDashboardPageState();
}

class _DoctorDashboardPageState extends State<DoctorDashboardPage> {
  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('לוח ניהול רופא'),
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Doctor info card
              Card(
                color: Colors.green.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.green,
                        child: const Icon(Icons.medical_services, color: Colors.white, size: 30),
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'ד"ר יוסי כהן',
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            Text('רופא משפחה'),
                            Text('תחום: רפואה פנימית'),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/doctor-profile');
                        },
                        icon: const Icon(Icons.edit, color: Colors.green),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              
              // Statistics cards
              _buildStatistics(),
              const SizedBox(height: 16),
              _buildMoreStats(),
              const SizedBox(height: 20),
              
              // Quick actions
              _buildQuickActions(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatistics() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'מטופלים',
            '156',
            Icons.people,
            Colors.green,
            onTap: () => Navigator.pushNamed(context, '/manage-users'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            'תורים היום',
            '12',
            Icons.calendar_today,
            Colors.blue,
            onTap: () => _showTodaysAppointments(),
          ),
        ),
      ],
    );
  }

  Widget _buildMoreStats() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'דירוג ממוצע',
            '4.8',
            Icons.star,
            Colors.orange,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            'תשלומים השבוע',
            '₪2,400',
            Icons.payment,
            Colors.purple,
            onTap: () => _showPaymentsDialog(),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color, {VoidCallback? onTap}) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(icon, size: 32, color: color),
              const SizedBox(height: 8),
              Text(
                value,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'פעולות מהירות:',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                'מטופלים',
                Icons.people,
                Colors.green,
                () {
                  Navigator.pushNamed(context, '/manage-users');
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildActionButton(
                'לוח תורים',
                Icons.calendar_today,
                Colors.blue,
                () {
                  Navigator.pushNamed(context, '/appointments');
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                'יומן תורים',
                Icons.calendar_view_day,
                Colors.purple,
                () {
                  _showCalendarView();
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildActionButton(
                'תשלומים',
                Icons.payment,
                Colors.orange,
                () {
                  _showPaymentsDialog();
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton(String title, IconData icon, Color color, VoidCallback onTap) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon),
      label: Text(title),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  void _showTodaysAppointments() {
    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text('תורים היום'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView(
              shrinkWrap: true,
              children: [
                _buildAppointmentRow('יוסי כהן', '050-1234567', '09:00'),
                _buildAppointmentRow('שרה לוי', '050-2345678', '10:30'),
                _buildAppointmentRow('דוד ישראלי', '050-3456789', '11:00'),
                _buildAppointmentRow('רחל גולד', '050-4567890', '12:30'),
                _buildAppointmentRow('אברהם כהן', '050-5678901', '14:00'),
                _buildAppointmentRow('מרים ישראלי', '050-6789012', '15:30'),
                _buildAppointmentRow('יוסף לוי', '050-7890123', '16:00'),
                _buildAppointmentRow('אסתר גולד', '050-8901234', '17:30'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('סגור'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppointmentRow(String name, String phone, String time) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue.shade100,
          child: Text(
            name.split(' ').map((n) => n[0]).join(''),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(name),
        subtitle: Text(phone),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.blue.shade100,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            time,
            style: TextStyle(
              color: Colors.blue.shade800,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  void _showPaymentsDialog() {
    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text('תשלומים השבוע'),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildPaymentRow('יוסי כהן', '₪200', 'מזומן', 'יום א'),
                _buildPaymentRow('שרה לוי', '₪180', 'כרטיס', 'יום ב'),
                _buildPaymentRow('דוד ישראלי', '₪220', 'העברה', 'יום ג'),
                _buildPaymentRow('רחל גולד', '₪190', 'מזומן', 'יום ד'),
                _buildPaymentRow('אברהם כהן', '₪210', 'כרטיס', 'יום ה'),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('סה"כ:', style: TextStyle(fontWeight: FontWeight.bold)),
                    Text('₪2,400', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green.shade700)),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('סגור'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentRow(String patient, String amount, String method, String day) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(patient, style: const TextStyle(fontWeight: FontWeight.w500)),
                Text('$method • $day', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
              ],
            ),
          ),
          Text(amount, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  void _showCalendarView() {
    DateTime selectedDate = DateTime.now();
    
    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            title: const Text('יומן תורים'),
            content: SizedBox(
              width: double.maxFinite,
              height: 400,
              child: Column(
                children: [
                  // Calendar header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: () {
                          setState(() {
                            selectedDate = DateTime(selectedDate.year, selectedDate.month - 1, selectedDate.day);
                          });
                        },
                        icon: const Icon(Icons.chevron_left),
                      ),
                      Text(
                        '${selectedDate.month}/${selectedDate.year}',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            selectedDate = DateTime(selectedDate.year, selectedDate.month + 1, selectedDate.day);
                          });
                        },
                        icon: const Icon(Icons.chevron_right),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Calendar grid
                  Expanded(
                    child: GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 7,
                        childAspectRatio: 1,
                      ),
                      itemCount: 35, // 5 weeks
                      itemBuilder: (context, index) {
                        final day = index - 6; // Start from Sunday
                        final date = DateTime(selectedDate.year, selectedDate.month, day);
                        final isCurrentMonth = date.month == selectedDate.month;
                        final isToday = date.day == DateTime.now().day && 
                                       date.month == DateTime.now().month && 
                                       date.year == DateTime.now().year;
                        final isSelected = date.day == selectedDate.day;
                        
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedDate = date;
                            });
                          },
                          child: Container(
                            margin: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: isSelected 
                                  ? Colors.blue 
                                  : isToday 
                                      ? Colors.blue.shade100 
                                      : Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(8),
                              border: isToday ? Border.all(color: Colors.blue) : null,
                            ),
                            child: Center(
                              child: Text(
                                day > 0 ? day.toString() : '',
                                style: TextStyle(
                                  color: isCurrentMonth 
                                      ? (isSelected ? Colors.white : Colors.black)
                                      : Colors.grey,
                                  fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Appointments for selected date
                  Container(
                    height: 100,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'תורים ל-${selectedDate.day}/${selectedDate.month}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Expanded(
                            child: ListView.builder(
                              itemCount: _getAppointmentsForDate(selectedDate).length,
                              itemBuilder: (context, index) {
                                final appointment = _getAppointmentsForDate(selectedDate)[index];
                                return ListTile(
                                  dense: true,
                                  leading: const Icon(Icons.access_time, size: 16),
                                  title: Text(
                                    '${appointment['time']} - ${appointment['name']}',
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('סגור'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Map<String, String>> _getAppointmentsForDate(DateTime date) {
    // Mock appointments for today
    final todaysAppointments = [
      {'name': 'שרה לוי', 'phone': '050-1234567', 'time': '09:00'},
      {'name': 'דוד כהן', 'phone': '052-9876543', 'time': '10:30'},
      {'name': 'רחל אברהם', 'phone': '054-5555555', 'time': '14:00'},
    ];
    
    // Mock appointments for the selected date
    if (date.day == DateTime.now().day) {
      return todaysAppointments;
    }
    
    // Generate some mock appointments for other dates
    final mockAppointments = [
      {'name': 'מטופל לדוגמה', 'phone': '050-0000000', 'time': '09:00'},
      {'name': 'מטופל נוסף', 'phone': '052-0000000', 'time': '10:30'},
    ];
    
    return date.day % 2 == 0 ? mockAppointments : [];
  }
}
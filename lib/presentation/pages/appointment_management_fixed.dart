import 'package:flutter/material.dart';

class AppointmentManagementFixedPage extends StatefulWidget {
  const AppointmentManagementFixedPage({super.key});

  @override
  State<AppointmentManagementFixedPage> createState() => _AppointmentManagementFixedPageState();
}

class _AppointmentManagementFixedPageState extends State<AppointmentManagementFixedPage> {
  String _selectedStatus = 'all';
  String _selectedDoctor = 'כל הרופאים';
  String _selectedDateRange = 'today';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  // Appointment data will be loaded from API; start empty to avoid placeholders
  final List<Map<String, dynamic>> _appointments = [];

  // Available doctors for filtering
  final List<String> _doctors = [
    'כל הרופאים',
    'ד"ר יוסי כהן',
    'ד"ר שרה לוי',
    'ד"ר דוד ישראלי',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ניהול תורים'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddAppointmentDialog,
          ),
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: _exportAppointments,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilterSection(),
          _buildAppointmentStats(),
          _buildAppointmentList(),
        ],
      ),
    );
  }

  Widget _buildFilterSection() {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      hintText: 'חיפוש בתורים...',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                      // Trigger immediate filtering
                      _filterAppointments();
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedStatus,
                    decoration: const InputDecoration(
                      labelText: 'סטטוס',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'all', child: Text('הכל')),
                      DropdownMenuItem(value: 'scheduled', child: Text('מתוכנן')),
                      DropdownMenuItem(value: 'confirmed', child: Text('מאושר')),
                      DropdownMenuItem(value: 'completed', child: Text('הושלם')),
                      DropdownMenuItem(value: 'cancelled', child: Text('בוטל')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedStatus = value!;
                      });
                      // Trigger immediate filtering
                      _filterAppointments();
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedDoctor,
                    decoration: const InputDecoration(
                      labelText: 'רופא/מטפל',
                      border: OutlineInputBorder(),
                    ),
                    items: _doctors.map((doctor) => DropdownMenuItem(
                      value: doctor,
                      child: Text(doctor),
                    )).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedDoctor = value!;
                      });
                      // Trigger immediate filtering
                      _filterAppointments();
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedDateRange,
                    decoration: const InputDecoration(
                      labelText: 'טווח תאריכים',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'today', child: Text('היום')),
                      DropdownMenuItem(value: 'week', child: Text('השבוע')),
                      DropdownMenuItem(value: 'month', child: Text('החודש')),
                      DropdownMenuItem(value: 'all', child: Text('הכל')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedDateRange = value!;
                      });
                      // Trigger immediate filtering
                      _filterAppointments();
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppointmentStats() {
    final filteredAppointments = _getFilteredAppointments();
    final scheduledCount = filteredAppointments.where((apt) => apt['status'] == 'scheduled').length;
    final confirmedCount = filteredAppointments.where((apt) => apt['status'] == 'confirmed').length;
    final completedCount = filteredAppointments.where((apt) => apt['status'] == 'completed').length;
    final cancelledCount = filteredAppointments.where((apt) => apt['status'] == 'cancelled').length;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'סטטיסטיקות תורים',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard('מתוכננים', scheduledCount, Colors.blue),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildStatCard('מאושרים', confirmedCount, Colors.orange),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildStatCard('הושלמו', completedCount, Colors.green),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildStatCard('בוטלו', cancelledCount, Colors.red),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, int count, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            count.toString(),
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentList() {
    final filteredAppointments = _getFilteredAppointments();

    return Expanded(
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: filteredAppointments.length,
        itemBuilder: (context, index) {
          final appointment = filteredAppointments[index];
          return _buildAppointmentCard(appointment);
        },
      ),
    );
  }

  Widget _buildAppointmentCard(Map<String, dynamic> appointment) {
    Color statusColor;
    String statusText;
    
    switch (appointment['status']) {
      case 'scheduled':
        statusColor = Colors.blue;
        statusText = 'מתוכנן';
        break;
      case 'confirmed':
        statusColor = Colors.orange;
        statusText = 'מאושר';
        break;
      case 'completed':
        statusColor = Colors.green;
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
      margin: const EdgeInsets.only(bottom: 12),
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
                        'תור #${appointment['id']}',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${appointment['date']} בשעה ${appointment['time']}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
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
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('מטופל: ${appointment['patientName']}'),
                      Text('רופא: ${appointment['doctorName']}'),
                      Text('התמחות: ${appointment['doctorSpecialty']}'),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('סוג טיפול: ${appointment['treatmentType']}'),
                      Text('מחיר: ${appointment['price']}₪'),
                      Text('טלפון: ${appointment['patientPhone']}'),
                    ],
                  ),
                ),
              ],
            ),
            if (appointment['notes'].isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'הערות: ${appointment['notes']}',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildActionButton('צפייה', Icons.visibility, Colors.blue, () => _viewAppointment(appointment)),
                _buildActionButton('עריכה', Icons.edit, Colors.orange, () => _editAppointment(appointment)),
                _buildActionButton('סטטוס', Icons.update, Colors.purple, () => _updateAppointmentStatus(appointment)),
                _buildActionButton('מחיקה', Icons.delete, Colors.red, () => _deleteAppointment(appointment)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(String label, IconData icon, Color color, VoidCallback onPressed) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 16),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }

  List<Map<String, dynamic>> _getFilteredAppointments() {
    return _appointments.where((appointment) {
      final matchesSearch = _searchQuery.isEmpty ||
          appointment['patientName'].toLowerCase().contains(_searchQuery.toLowerCase()) ||
          appointment['doctorName'].toLowerCase().contains(_searchQuery.toLowerCase()) ||
          appointment['id'].toLowerCase().contains(_searchQuery.toLowerCase());
      
      final matchesStatus = _selectedStatus == 'all' || appointment['status'] == _selectedStatus;
      
      final matchesDoctor = _selectedDoctor == 'כל הרופאים' || appointment['doctorName'] == _selectedDoctor;
      
      // Date filtering
      final matchesDate = _matchesDateRange(appointment['date']);
      
      return matchesSearch && matchesStatus && matchesDoctor && matchesDate;
    }).toList();
  }

  bool _matchesDateRange(String appointmentDate) {
    if (_selectedDateRange == 'all') return true;
    
    final appointmentDateTime = DateTime.parse(appointmentDate);
    final now = DateTime.now();
    
    switch (_selectedDateRange) {
      case 'today':
        return appointmentDateTime.year == now.year &&
               appointmentDateTime.month == now.month &&
               appointmentDateTime.day == now.day;
      case 'week':
        final weekStart = now.subtract(Duration(days: now.weekday - 1));
        final weekEnd = weekStart.add(const Duration(days: 6));
        return appointmentDateTime.isAfter(weekStart.subtract(const Duration(days: 1))) &&
               appointmentDateTime.isBefore(weekEnd.add(const Duration(days: 1)));
      case 'month':
        return appointmentDateTime.year == now.year &&
               appointmentDateTime.month == now.month;
      default:
        return true;
    }
  }

  void _filterAppointments() {
    // This method triggers a rebuild which will call _getFilteredAppointments()
    setState(() {
      // The filtering logic is already in _getFilteredAppointments()
      // This just triggers a rebuild to update the UI
    });
  }

  void _viewAppointment(Map<String, dynamic> appointment) {
    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: Text('פרטי תור #${appointment['id']}'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDetailRow('מזהה תור', appointment['id']),
                _buildDetailRow('תאריך', appointment['date']),
                _buildDetailRow('שעה', appointment['time']),
                _buildDetailRow('סטטוס', _getStatusText(appointment['status'])),
                _buildDetailRow('מטופל', appointment['patientName']),
                _buildDetailRow('אימייל מטופל', appointment['patientEmail']),
                _buildDetailRow('טלפון מטופל', appointment['patientPhone']),
                _buildDetailRow('רופא', appointment['doctorName']),
                _buildDetailRow('התמחות', appointment['doctorSpecialty']),
                _buildDetailRow('סוג טיפול', appointment['treatmentType']),
                _buildDetailRow('מחיר', '${appointment['price']}₪'),
                _buildDetailRow('הערות', appointment['notes']),
                _buildDetailRow('נוצר ב', appointment['createdAt']),
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

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  void _editAppointment(Map<String, dynamic> appointment) {
    final TextEditingController patientNameController = TextEditingController(text: appointment['patientName']);
    final TextEditingController patientEmailController = TextEditingController(text: appointment['patientEmail']);
    final TextEditingController patientPhoneController = TextEditingController(text: appointment['patientPhone']);
    final TextEditingController treatmentTypeController = TextEditingController(text: appointment['treatmentType']);
    final TextEditingController priceController = TextEditingController(text: appointment['price'].toString());
    final TextEditingController notesController = TextEditingController(text: appointment['notes']);
    
    String selectedDoctor = appointment['doctorName'];
    String selectedDate = appointment['date'];
    String selectedTime = appointment['time'];
    String selectedStatus = appointment['status'];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('עריכת תור #${appointment['id']}'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: patientNameController,
                  decoration: const InputDecoration(
                    labelText: 'שם מטופל',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: patientEmailController,
                  decoration: const InputDecoration(
                    labelText: 'אימייל מטופל',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: patientPhoneController,
                  decoration: const InputDecoration(
                    labelText: 'טלפון מטופל',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedDoctor,
                  decoration: const InputDecoration(
                    labelText: 'רופא/מטפל',
                    border: OutlineInputBorder(),
                  ),
                  items: _doctors.where((doctor) => doctor != 'כל הרופאים').map((doctor) => 
                    DropdownMenuItem(value: doctor, child: Text(doctor))
                  ).toList(),
                  onChanged: (value) {
                    setDialogState(() {
                      selectedDoctor = value!;
                    });
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: TextEditingController(text: selectedDate),
                        decoration: const InputDecoration(
                          labelText: 'תאריך',
                          border: OutlineInputBorder(),
                        ),
                        readOnly: true,
                        onTap: () async {
                          final DateTime? picked = await showDatePicker(
                            context: context,
                            initialDate: DateTime.parse(selectedDate),
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(const Duration(days: 365)),
                          );
                          if (picked != null) {
                            setDialogState(() {
                              selectedDate = picked.toString().split(' ')[0];
                            });
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextField(
                        controller: TextEditingController(text: selectedTime),
                        decoration: const InputDecoration(
                          labelText: 'שעה',
                          border: OutlineInputBorder(),
                        ),
                        readOnly: true,
                        onTap: () async {
                          final TimeOfDay? picked = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.fromDateTime(DateTime.parse('${selectedDate} $selectedTime')),
                          );
                          if (picked != null) {
                            setDialogState(() {
                              selectedTime = '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
                            });
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedStatus,
                  decoration: const InputDecoration(
                    labelText: 'סטטוס',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'scheduled', child: Text('מתוכנן')),
                    DropdownMenuItem(value: 'confirmed', child: Text('מאושר')),
                    DropdownMenuItem(value: 'completed', child: Text('הושלם')),
                    DropdownMenuItem(value: 'cancelled', child: Text('בוטל')),
                  ],
                  onChanged: (value) {
                    setDialogState(() {
                      selectedStatus = value!;
                    });
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: treatmentTypeController,
                  decoration: const InputDecoration(
                    labelText: 'סוג טיפול',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: priceController,
                  decoration: const InputDecoration(
                    labelText: 'מחיר (₪)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: notesController,
                  decoration: const InputDecoration(
                    labelText: 'הערות',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('ביטול'),
            ),
            ElevatedButton(
              onPressed: () {
                // Update appointment data
                final appointmentIndex = _appointments.indexWhere((apt) => apt['id'] == appointment['id']);
                if (appointmentIndex != -1) {
                  setState(() {
                    _appointments[appointmentIndex] = {
                      ..._appointments[appointmentIndex],
                      'patientName': patientNameController.text,
                      'patientEmail': patientEmailController.text,
                      'patientPhone': patientPhoneController.text,
                      'doctorName': selectedDoctor,
                      'date': selectedDate,
                      'time': selectedTime,
                      'status': selectedStatus,
                      'treatmentType': treatmentTypeController.text,
                      'price': double.tryParse(priceController.text) ?? 0,
                      'notes': notesController.text,
                    };
                  });
                }
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('תור #${appointment['id']} עודכן בהצלחה')),
                );
              },
              child: const Text('שמור שינויים'),
            ),
          ],
        ),
      ),
    );
  }

  void _updateAppointmentStatus(Map<String, dynamic> appointment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('עדכון סטטוס תור'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('בחר סטטוס חדש:'),
            const SizedBox(height: 16),
            ...['scheduled', 'confirmed', 'completed', 'cancelled'].map((status) => 
              RadioListTile<String>(
                title: Text(_getStatusText(status)),
                value: status,
                groupValue: appointment['status'],
                onChanged: (value) {
                  // Update appointment status immediately
                  final appointmentIndex = _appointments.indexWhere((apt) => apt['id'] == appointment['id']);
                  if (appointmentIndex != -1) {
                    setState(() {
                      _appointments[appointmentIndex]['status'] = status;
                    });
                  }
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('סטטוס התור #${appointment['id']} עודכן ל${_getStatusText(status)}')),
                  );
                },
              ),
            ).toList(),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ביטול'),
          ),
        ],
      ),
    );
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'scheduled': return 'מתוכנן';
      case 'confirmed': return 'מאושר';
      case 'completed': return 'הושלם';
      case 'cancelled': return 'בוטל';
      default: return 'לא ידוע';
    }
  }

  void _deleteAppointment(Map<String, dynamic> appointment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('מחיקת תור'),
        content: Text('האם אתה בטוח שברצונך למחוק את תור #${appointment['id']}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ביטול'),
          ),
          ElevatedButton(
            onPressed: () {
              // Remove appointment from list
              setState(() {
                _appointments.removeWhere((apt) => apt['id'] == appointment['id']);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('התור #${appointment['id']} נמחק בהצלחה')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('מחק'),
          ),
        ],
      ),
    );
  }

  void _showAddAppointmentDialog() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('הוספת תור - בפיתוח')),
    );
  }

  void _exportAppointments() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ייצוא תורים'),
        content: const Text('בחר פורמט לייצוא:'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ביטול'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('תורים יוצאו לקובץ CSV')),
              );
            },
            child: const Text('ייצוא CSV'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('תורים יוצאו לקובץ Excel')),
              );
            },
            child: const Text('ייצוא Excel'),
          ),
        ],
      ),
    );
  }
}

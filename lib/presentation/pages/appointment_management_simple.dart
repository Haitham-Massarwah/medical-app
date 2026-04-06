import 'package:flutter/material.dart';

class AppointmentManagementPage extends StatefulWidget {
  const AppointmentManagementPage({super.key});

  @override
  State<AppointmentManagementPage> createState() => _AppointmentManagementPageState();
}

class _AppointmentManagementPageState extends State<AppointmentManagementPage> {
  // Appointment data will be loaded from API; start empty to avoid placeholders
  final List<Map<String, dynamic>> _appointments = [];

  String _selectedFilter = 'כל התורים';

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
            onPressed: () => _addAppointment(),
            tooltip: 'הוסף תור',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Filter Section
            _buildFilterSection(),
            
            const SizedBox(height: 24),
            
            // Appointments List
            _buildAppointmentsList(),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'סינון תורים',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              children: [
                _buildFilterChip('כל התורים'),
                _buildFilterChip('ממתין'),
                _buildFilterChip('מאושר'),
                _buildFilterChip('בוטל'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = _selectedFilter == label;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedFilter = label;
        });
      },
      selectedColor: Colors.green.withOpacity(0.2),
      checkmarkColor: Colors.green,
    );
  }

  Widget _buildAppointmentsList() {
    final filteredAppointments = _selectedFilter == 'כל התורים' 
        ? _appointments 
        : _appointments.where((apt) => apt['status'] == _selectedFilter).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'רשימת תורים (${filteredAppointments.length})',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ...filteredAppointments.map((appointment) => _buildAppointmentCard(appointment)).toList(),
      ],
    );
  }

  Widget _buildAppointmentCard(Map<String, dynamic> appointment) {
    Color statusColor = appointment['status'] == 'מאושר' ? Colors.green :
                       appointment['status'] == 'ממתין' ? Colors.orange :
                       Colors.red;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  appointment['patientName'],
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    appointment['status'],
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Text('${appointment['date']} - ${appointment['time']}'),
                const SizedBox(width: 16),
                Icon(Icons.medical_services, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Text(appointment['treatment']),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.phone, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Text(appointment['phone']),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _editAppointment(appointment),
                    icon: const Icon(Icons.edit, size: 16),
                    label: const Text('ערוך'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _viewAppointment(appointment),
                    icon: const Icon(Icons.visibility, size: 16),
                    label: const Text('צפה'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _cancelAppointment(appointment),
                    icon: const Icon(Icons.cancel, size: 16),
                    label: const Text('בטל'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _addAppointment() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('הוסף תור חדש'),
        content: const Text('פתיחת טופס הוספת תור...\n\n• בחירת מטופל\n• בחירת תאריך ושעה\n• בחירת סוג טיפול\n• הוספת הערות'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ביטול'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showAppointmentAdded();
            },
            child: const Text('הוסף תור'),
          ),
        ],
      ),
    );
  }

  void _showAppointmentAdded() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('התור נוסף בהצלחה!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _editAppointment(Map<String, dynamic> appointment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ערוך תור'),
        content: Text('עריכת תור עבור ${appointment['patientName']}...\n\n• שינוי תאריך ושעה\n• שינוי סוג טיפול\n• עדכון פרטי מטופל\n• הוספת הערות'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ביטול'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showAppointmentUpdated();
            },
            child: const Text('עדכן'),
          ),
        ],
      ),
    );
  }

  void _showAppointmentUpdated() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('התור עודכן בהצלחה!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _viewAppointment(Map<String, dynamic> appointment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('פרטי התור'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('מטופל: ${appointment['patientName']}'),
            Text('תאריך: ${appointment['date']}'),
            Text('שעה: ${appointment['time']}'),
            Text('טיפול: ${appointment['treatment']}'),
            Text('סטטוס: ${appointment['status']}'),
            Text('טלפון: ${appointment['phone']}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('סגור'),
          ),
        ],
      ),
    );
  }

  void _cancelAppointment(Map<String, dynamic> appointment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('בטל תור'),
        content: Text('האם אתה בטוח שברצונך לבטל את התור של ${appointment['patientName']}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ביטול'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showAppointmentCancelled();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('בטל תור'),
          ),
        ],
      ),
    );
  }

  void _showAppointmentCancelled() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('התור בוטל בהצלחה!'),
        backgroundColor: Colors.red,
      ),
    );
  }
}








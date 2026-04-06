import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import 'reschedule_page.dart';
import '../../services/waze_service.dart';

/// ADMIN: ALL APPOINTMENTS VIEW
/// Shows ALL appointments in the system with Doctor/Patient filtering
class AdminAllAppointments extends StatefulWidget {
  const AdminAllAppointments({Key? key}) : super(key: key);

  @override
  State<AdminAllAppointments> createState() => _AdminAllAppointmentsState();
}

class _AdminAllAppointmentsState extends State<AdminAllAppointments> {
  final ApiService _apiService = ApiService();
  List<Map<String, dynamic>> _appointments = [];
  bool _isLoading = true;
  String _filterType = 'all'; // all, by_doctor, by_patient
  String _selectedFilter = 'הכל'; // Status filter
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadAppointments();
  }

  Future<void> _loadAppointments() async {
    setState(() => _isLoading = true);
    try {
      // Use admin database endpoint which has proper joins for doctor/patient names
      final response = await _apiService.get('/admin/database/appointments?page=1&limit=100');
      if (response['success'] == true) {
        final List<dynamic> rawAppointments = response['data'] ?? [];
        setState(() {
          _appointments = rawAppointments.map((apt) {
            final map = apt as Map<String, dynamic>;
            // Map fields from admin endpoint response
            return {
              'id': map['id'] ?? '',
              'appointment_date': map['appointment_date'] ?? '',
              'status': map['status'] ?? 'pending',
              'location': map['location'] ?? '',
              'notes': map['notes'] ?? '',
              'doctorName': map['doctor_name'] ?? 'רופא לא ידוע',
              'patientName': map['patient_name'] ?? 'מטופל לא ידוע',
              'specialty': map['specialty'] ?? '',
              'duration_minutes': map['duration_minutes'] ?? 30,
            };
          }).toList();
          _isLoading = false;
        });
      } else {
        throw Exception(response['message'] ?? 'Failed to load appointments');
      }
    } catch (e) {
      // Do not fall back to sample data; show empty state with an alert.
      setState(() {
        _appointments = [];
        _isLoading = false;
      });
      // PD-01: Remove development messages - show user-friendly error only
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('לא ניתן לטעון תורים כרגע. אנא נסה שוב מאוחר יותר.'),
            backgroundColor: Colors.redAccent,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  List<Map<String, dynamic>> get _filteredAppointments {
    return _appointments.where((apt) {
      // Search filter
      final matchesSearch = _searchQuery.isEmpty ||
          (apt['doctorName']?.toString().toLowerCase() ?? '').contains(_searchQuery.toLowerCase()) ||
          (apt['patientName']?.toString().toLowerCase() ?? '').contains(_searchQuery.toLowerCase()) ||
          (apt['specialty']?.toString().toLowerCase() ?? '').contains(_searchQuery.toLowerCase());
      
      // Status filter
      final status = apt['status']?.toString() ?? '';
      final matchesStatus = _selectedFilter == 'הכל' ||
          (_selectedFilter == 'פעיל' && (status == 'pending' || status == 'confirmed')) ||
          (_selectedFilter == 'מאושר' && status == 'confirmed') ||
          (_selectedFilter == 'ממתין' && status == 'pending') ||
          (_selectedFilter == 'הושלם' && status == 'completed') ||
          (_selectedFilter == 'בוטל' && status == 'cancelled');
      
      return matchesSearch && matchesStatus;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('כל התורים במערכת'),
          backgroundColor: Colors.orange,
          foregroundColor: Colors.white,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _loadAppointments,
              tooltip: 'רענן',
            ),
            IconButton(
              icon: const Icon(Icons.filter_list),
              onPressed: _showFilterOptions,
              tooltip: 'סנן',
            ),
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              // Filters
              Container(
                color: Colors.orange.shade50,
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Search
                    TextField(
                      controller: _searchController,
                      decoration: const InputDecoration(
                        hintText: 'חיפוש לפי רופא, מטופל או התמחות...',
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(),
                        fillColor: Colors.white,
                        filled: true,
                      ),
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    // Filter buttons
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _selectedFilter,
                            decoration: const InputDecoration(
                              labelText: 'סנן לפי סטטוס',
                              border: OutlineInputBorder(),
                              fillColor: Colors.white,
                              filled: true,
                            ),
                            items: ['הכל', 'פעיל', 'מאושר', 'ממתין', 'הושלם', 'בוטל']
                                .map((filter) => DropdownMenuItem(
                                      value: filter,
                                      child: Text(filter),
                                    ))
                                .toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedFilter = value!;
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: SegmentedButton<String>(
                            segments: const [
                              ButtonSegment(value: 'all', label: Text('הכל'), icon: Icon(Icons.list, size: 16)),
                              ButtonSegment(value: 'by_doctor', label: Text('לפי רופא'), icon: Icon(Icons.medical_services, size: 16)),
                              ButtonSegment(value: 'by_patient', label: Text('לפי מטופל'), icon: Icon(Icons.person, size: 16)),
                            ],
                            selected: {_filterType},
                            onSelectionChanged: (Set<String> newSelection) {
                              setState(() {
                                _filterType = newSelection.first;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Results count
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'נמצאו ${_filteredAppointments.length} תורים',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextButton.icon(
                      onPressed: () {
                        setState(() {
                          _selectedFilter = 'הכל';
                          _filterType = 'all';
                          _searchQuery = '';
                          _searchController.clear();
                        });
                      },
                      icon: const Icon(Icons.clear),
                      label: const Text('נקה סינונים'),
                    ),
                  ],
                ),
              ),
              // Appointments List
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _filteredAppointments.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.calendar_today, size: 64, color: Colors.grey),
                                const SizedBox(height: 16),
                                const Text(
                                  'לא נמצאו תורים',
                                  style: TextStyle(fontSize: 18, color: Colors.grey),
                                ),
                              ],
                            ),
                          )
                        : _buildAppointmentsList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppointmentsList() {
    // Group by filter type
    if (_filterType == 'by_doctor') {
      return _buildGroupedByDoctor();
    } else if (_filterType == 'by_patient') {
      return _buildGroupedByPatient();
    } else {
      return _buildSimpleList();
    }
  }

  Widget _buildSimpleList() {
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: _filteredAppointments.length,
      itemBuilder: (context, index) {
        return _buildAppointmentCard(_filteredAppointments[index]);
      },
    );
  }

  Widget _buildGroupedByDoctor() {
    final grouped = <String, List<Map<String, dynamic>>>{};
    for (var apt in _filteredAppointments) {
      final doctorName = apt['doctorName'] ?? 'Unknown';
      grouped.putIfAbsent(doctorName, () => []);
      grouped[doctorName]!.add(apt);
    }

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: grouped.length,
      itemBuilder: (context, index) {
        final doctorName = grouped.keys.elementAt(index);
        final appointments = grouped[doctorName]!;
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: ExpansionTile(
            leading: const Icon(Icons.medical_services, color: Colors.green),
            title: Text(doctorName, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('${appointments.length} תורים'),
            children: appointments.map((apt) => _buildAppointmentCard(apt, compact: true)).toList(),
          ),
        );
      },
    );
  }

  Widget _buildGroupedByPatient() {
    final grouped = <String, List<Map<String, dynamic>>>{};
    for (var apt in _filteredAppointments) {
      final patientName = apt['patientName'] ?? 'Unknown';
      grouped.putIfAbsent(patientName, () => []);
      grouped[patientName]!.add(apt);
    }

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: grouped.length,
      itemBuilder: (context, index) {
        final patientName = grouped.keys.elementAt(index);
        final appointments = grouped[patientName]!;
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: ExpansionTile(
            leading: const Icon(Icons.person, color: Colors.blue),
            title: Text(patientName, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('${appointments.length} תורים'),
            children: appointments.map((apt) => _buildAppointmentCard(apt, compact: true)).toList(),
          ),
        );
      },
    );
  }

  Widget _buildAppointmentCard(Map<String, dynamic> apt, {bool compact = false}) {
    final status = apt['status'] ?? 'pending';
    final DateTime? appointmentDate = _parseAppointmentDate(apt);
    final String dateText = (apt['date']?.toString().isNotEmpty ?? false)
        ? apt['date'].toString()
        : _formatDate(appointmentDate);
    final String timeText = (apt['time']?.toString().isNotEmpty ?? false)
        ? apt['time'].toString()
        : _formatTime(appointmentDate);
    final String doctorName = (apt['doctorName']?.toString().isNotEmpty ?? false)
        ? apt['doctorName'].toString()
        : (apt['doctor_name']?.toString() ?? '');
    final String patientName = (apt['patientName']?.toString().isNotEmpty ?? false)
        ? apt['patientName'].toString()
        : (apt['patient_name']?.toString() ?? '');
    final String specialty = (apt['specialty']?.toString() ?? '');
    final statusColor = status == 'confirmed' ? Colors.green : 
                       status == 'pending' ? Colors.orange :
                       status == 'completed' ? Colors.blue : Colors.grey;
    final statusText = status == 'confirmed' ? 'מאושר' : 
                       status == 'pending' ? 'ממתין' :
                       status == 'completed' ? 'הושלם' : 'בוטל';

    return Card(
      margin: EdgeInsets.symmetric(horizontal: compact ? 8 : 0, vertical: 8),
      elevation: compact ? 1 : 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.medical_services, size: 20, color: Colors.green),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              doctorName,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.person, size: 20, color: Colors.blue),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              patientName,
                              style: const TextStyle(fontSize: 15),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        specialty,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    statusText,
                    style: const TextStyle(
                      color: Colors.white,
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
                const Icon(Icons.calendar_today, size: 18, color: Colors.grey),
                const SizedBox(width: 8),
                Text('$dateText בשעה $timeText'),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.location_on, size: 18, color: Colors.grey),
                const SizedBox(width: 8),
                Expanded(child: Text(apt['location']?.toString() ?? '')),
              ],
            ),
            if (!compact) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  if (status == 'pending' || status == 'confirmed') ...[
                    ElevatedButton.icon(
                      onPressed: () => _updateStatus(apt['id'], 'confirmed'),
                      icon: const Icon(Icons.check, size: 18),
                      label: const Text('אשר'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  OutlinedButton.icon(
                    onPressed: () => _updateStatus(apt['id'], 'cancelled'),
                    icon: const Icon(Icons.cancel, size: 18),
                    label: const Text('בטל'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deleteAppointment(apt['id']),
                    tooltip: 'מחק',
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () => _editAppointment(apt),
                    tooltip: 'ערוך/דחה',
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showFilterOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'סינון תורים',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.list),
              title: const Text('הצג הכל'),
              onTap: () {
                setState(() => _filterType = 'all');
                Navigator.pop(context);
              },
              selected: _filterType == 'all',
            ),
            ListTile(
              leading: const Icon(Icons.medical_services),
              title: const Text('קבץ לפי רופא'),
              onTap: () {
                setState(() => _filterType = 'by_doctor');
                Navigator.pop(context);
              },
              selected: _filterType == 'by_doctor',
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('קבץ לפי מטופל'),
              onTap: () {
                setState(() => _filterType = 'by_patient');
                Navigator.pop(context);
              },
              selected: _filterType == 'by_patient',
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _updateStatus(String? appointmentId, String newStatus) async {
    if (appointmentId == null) return;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('עדכון סטטוס'),
        content: Text('האם לעדכן את סטטוס התור ל-$newStatus?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ביטול'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                if (newStatus == 'confirmed') {
                  await _apiService.post('/appointments/$appointmentId/confirm', {});
                } else if (newStatus == 'cancelled') {
                  await _apiService.delete('/appointments/$appointmentId', {
                    'reason': 'Cancelled by admin',
                  });
                }
                // Reload appointments to get updated status
                await _loadAppointments();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('סטטוס עודכן ל: $newStatus'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('שגיאה בעדכון סטטוס: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('אשר'),
          ),
        ],
      ),
    );
  }

  Future<void> _editAppointment(Map<String, dynamic> apt) async {
    // Navigate to reschedule page
    final appointmentId = apt['id']?.toString();
    final appointmentDate = _parseAppointmentDate(apt);
    if (appointmentId == null || appointmentDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('לא ניתן לערוך תור זה')),
      );
      return;
    }
    
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ReschedulePage(
          appointmentId: appointmentId,
          doctorId: apt['doctor_id']?.toString() ?? '',
          doctorName: apt['doctorName']?.toString() ?? apt['doctor_name']?.toString() ?? 'רופא',
          specialty: apt['specialty']?.toString() ?? '',
          currentDate: appointmentDate,
          currentTimeSlot: _formatTime(appointmentDate),
        ),
      ),
    ).then((_) {
      // Reload appointments after rescheduling
      _loadAppointments();
    });
  }

  Future<void> _deleteAppointment(String? appointmentId) async {
    if (appointmentId == null) return;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('מחיקת תור'),
        content: const Text('האם אתה בטוח שברצונך למחוק תור זה? פעולה זו לא ניתנת לביטול.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ביטול'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await _apiService.delete('/appointments/$appointmentId', {
                  'reason': 'Deleted by admin',
                });
                await _loadAppointments();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('התור נמחק בהצלחה'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('שגיאה במחיקת תור: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('מחק'),
          ),
        ],
      ),
    );
  }

  DateTime? _parseAppointmentDate(Map<String, dynamic> apt) {
    final raw = apt['appointment_date'] ?? apt['appointmentDate'];
    if (raw == null) return null;
    return DateTime.tryParse(raw.toString());
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day/$month/${date.year}';
  }

  String _formatTime(DateTime? date) {
    if (date == null) return '';
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}


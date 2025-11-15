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
      final response = await _apiService.get('/appointments/all');
      if (response['success'] == true) {
        setState(() {
          _appointments = List<Map<String, dynamic>>.from(response['data'] ?? []);
          _isLoading = false;
        });
      } else {
        throw Exception(response['message']);
      }
    } catch (e) {
      // Show sample data if API fails
      setState(() {
        _appointments = [
          {
            'id': '1',
            'doctorName': 'ד"ר אברהם כהן',
            'patientName': 'לקוח ישראלי',
            'specialty': 'רופא משפחה',
            'date': '2024-01-15',
            'time': '09:00',
            'status': 'confirmed',
            'location': 'תל אביב',
            'address': 'תל אביב, רחוב רוטשילד 23',
          },
          {
            'id': '2',
            'doctorName': 'ד"ר שרה לוי',
            'patientName': 'שרה כהן',
            'specialty': 'קרדיולוג',
            'date': '2024-01-18',
            'time': '14:30',
            'status': 'pending',
            'location': 'ירושלים',
            'address': 'ירושלים, רחוב יפו 35',
          },
          {
            'id': '3',
            'doctorName': 'ד"ר דוד ישראלי',
            'patientName': 'דוד לוי',
            'specialty': 'אורתופד',
            'date': '2024-01-12',
            'time': '11:00',
            'status': 'completed',
            'location': 'חיפה',
            'address': 'חיפה, שדרות המגינים 47',
          },
          {
            'id': '4',
            'doctorName': 'ד"ר אברהם כהן',
            'patientName': 'מיכל לוי',
            'specialty': 'רופא משפחה',
            'date': '2024-01-20',
            'time': '10:30',
            'status': 'pending',
            'location': 'תל אביב',
            'address': 'תל אביב, רחוב רוטשילד 23',
          },
          {
            'id': '5',
            'doctorName': 'ד"ר שרה לוי',
            'patientName': 'יוסף כהן',
            'specialty': 'קרדיולוג',
            'date': '2024-01-22',
            'time': '15:00',
            'status': 'confirmed',
            'location': 'ירושלים',
            'address': 'ירושלים, רחוב יפו 35',
          },
        ];
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('מציג נתונים לדוגמה (שגיאת API: $e)'),
            backgroundColor: Colors.orange,
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
                              apt['doctorName'] ?? '',
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
                              apt['patientName'] ?? '',
                              style: const TextStyle(fontSize: 15),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        apt['specialty'] ?? '',
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
                Text('${apt['date']} בשעה ${apt['time']}'),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.location_on, size: 18, color: Colors.grey),
                const SizedBox(width: 8),
                Expanded(child: Text(apt['location'] ?? '')),
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
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () => _editAppointment(apt),
                    tooltip: 'ערוך',
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

  void _updateStatus(String? appointmentId, String newStatus) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('עדכון סטטוס'),
        content: Text('האם לעדכן את סטטוס התור?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ביטול'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                final index = _appointments.indexWhere((a) => a['id'] == appointmentId);
                if (index != -1) {
                  _appointments[index]['status'] = newStatus;
                }
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('סטטוס עודכן ל: $newStatus'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('אשר'),
          ),
        ],
      ),
    );
  }

  void _editAppointment(Map<String, dynamic> apt) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('פונקציית עריכה תתווסף בקרוב')),
    );
  }
}


import 'package:flutter/material.dart';
import '../../services/patient_service.dart';
import '../../services/doctor_service.dart';
import '../../services/appointment_service.dart';

/// Doctor/Therapist books an appointment for a patient.
/// Search by name / email (multi-option), select patient, then book for current doctor only.
class DoctorBookingPage extends StatefulWidget {
  const DoctorBookingPage({super.key});

  @override
  State<DoctorBookingPage> createState() => _DoctorBookingPageState();
}

class _DoctorBookingPageState extends State<DoctorBookingPage> {
  final PatientService _patientService = PatientService();
  final DoctorService _doctorService = DoctorService();
  final AppointmentService _appointmentService = AppointmentService();

  final _searchController = TextEditingController();
  List<Map<String, dynamic>> _patients = [];
  Map<String, dynamic>? _selectedPatient;
  String? _doctorId;
  bool _loadingPatients = false;
  bool _loadingSlots = false;
  List<DateTime> _availableDates = [];
  List<String> _timeSlots = [];
  DateTime? _pickedDate;
  String? _pickedTime;
  bool _booking = false;

  @override
  void initState() {
    super.initState();
    _loadMyDoctor();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadMyDoctor() async {
    try {
      final doctor = await _doctorService.getMyDoctorProfile();
      if (mounted) setState(() => _doctorId = doctor['id']?.toString());
    } catch (_) {
      if (mounted) setState(() => _doctorId = null);
    }
  }

  Future<void> _searchPatients() async {
    final q = _searchController.text.trim();
    if (q.isEmpty) {
      setState(() => _patients = []);
      return;
    }
    setState(() => _loadingPatients = true);
    try {
      final list = await _patientService.getPatients(search: q);
      if (mounted) setState(() {
        _patients = list;
        _loadingPatients = false;
        _selectedPatient = null;
      });
    } catch (e) {
      if (mounted) setState(() {
        _patients = [];
        _loadingPatients = false;
      });
    }
  }

  String _patientDisplay(Map<String, dynamic> p) {
    final first = p['first_name']?.toString() ?? '';
    final last = p['last_name']?.toString() ?? '';
    final name = '$first $last'.trim();
    final email = p['email']?.toString() ?? '';
    if (name.isNotEmpty) return '$name${email.isNotEmpty ? ' · $email' : ''}';
    return email.isNotEmpty ? email : 'מטופל';
  }

  Future<void> _loadSlots() async {
    if (_doctorId == null || _selectedPatient == null) return;
    setState(() {
      _loadingSlots = true;
      _availableDates = [];
      _timeSlots = [];
      _pickedDate = null;
      _pickedTime = null;
    });
    try {
      final now = DateTime.now();
      final end = now.add(const Duration(days: 60));
      final dates = await _appointmentService.getAvailableDates(_doctorId!, now, end);
      if (mounted) setState(() {
        _availableDates = dates;
        _loadingSlots = false;
      });
    } catch (e) {
      if (mounted) setState(() {
        _availableDates = [];
        _loadingSlots = false;
      });
    }
  }

  Future<void> _pickTime() async {
    if (_pickedDate == null || _doctorId == null) return;
    final times = await _appointmentService.getAvailableTimeSlots(_doctorId!, _pickedDate!);
    if (!mounted) return;
    if (times.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('אין שעות פנויות'), backgroundColor: Colors.orange),
      );
      return;
    }
    final t = await showDialog<String>(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text('בחר שעה'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: times.length,
              itemBuilder: (_, i) => ListTile(
                title: Text(times[i]),
                onTap: () => Navigator.of(context).pop(times[i]),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('ביטול'),
            ),
          ],
        ),
      ),
    );
    if (t != null && mounted) setState(() => _pickedTime = t);
  }

  Future<void> _confirmBook() async {
    if (_doctorId == null || _selectedPatient == null || _pickedDate == null || _pickedTime == null) return;
    final patientId = _selectedPatient!['id']?.toString();
    if (patientId == null) return;
    setState(() => _booking = true);
    try {
      final parts = _pickedTime!.split(':');
      final slot = DateTime(
        _pickedDate!.year,
        _pickedDate!.month,
        _pickedDate!.day,
        int.parse(parts[0]),
        parts.length > 1 ? int.parse(parts[1]) : 0,
      );
      await _appointmentService.bookAppointment(
        doctorId: _doctorId!,
        appointmentDate: slot,
        timeSlot: _pickedTime!,
        notes: 'תור שנקבע על ידי הרופא',
        patientId: patientId,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('התור נקבע בהצלחה'), backgroundColor: Colors.green),
      );
      setState(() {
        _selectedPatient = null;
        _pickedDate = null;
        _pickedTime = null;
        _booking = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _booking = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('שגיאה: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('קביעת תור למטופל'),
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
        ),
        body: _doctorId == null
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'חיפוש מטופל (שם / אימייל)',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            decoration: const InputDecoration(
                              hintText: 'הזן שם או אימייל',
                              border: OutlineInputBorder(),
                            ),
                            textDirection: TextDirection.rtl,
                            onSubmitted: (_) => _searchPatients(),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: _loadingPatients ? null : _searchPatients,
                          child: _loadingPatients
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Text('חפש'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (_patients.isNotEmpty) ...[
                      const Text('בחר מטופל', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      ..._patients.map((p) {
                        final id = p['id']?.toString() ?? '';
                        final selected = _selectedPatient?['id']?.toString() == id;
                        return Card(
                          child: ListTile(
                            title: Text(_patientDisplay(p)),
                            selected: selected,
                            onTap: () {
                              setState(() {
                                _selectedPatient = p;
                                _loadSlots();
                              });
                            },
                          ),
                        );
                      }),
                    ],
                    if (_selectedPatient != null) ...[
                      const SizedBox(height: 24),
                      const Text('בחר תאריך ושעה', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      if (_loadingSlots)
                        const Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator()))
                      else if (_availableDates.isEmpty)
                        const Padding(
                          padding: EdgeInsets.all(16),
                          child: Text('אין מועדים פנויים ב-60 הימים הקרובים'),
                        )
                      else ...[
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _availableDates.take(30).map((d) {
                            final str = '${d.day}/${d.month}/${d.year}';
                            final selected = _pickedDate == d;
                            return ChoiceChip(
                              label: Text(str),
                              selected: selected,
                              onSelected: (v) {
                                setState(() {
                                  _pickedDate = v ? d : null;
                                  _pickedTime = null;
                                });
                                if (v) _pickTime();
                              },
                            );
                          }).toList(),
                        ),
                        if (_pickedDate != null && _pickedTime != null) ...[
                          const SizedBox(height: 16),
                          Text('נבחר: ${_pickedDate!.day}/${_pickedDate!.month}/${_pickedDate!.year} $_pickedTime'),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: _booking ? null : _confirmBook,
                            child: _booking
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : const Text('אשר קביעת תור'),
                          ),
                        ],
                      ],
                    ],
                  ],
                ),
              ),
    ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'calendar_booking_page.dart';
import '../../services/doctor_service.dart';
import '../../services/specialty_management_service.dart';

class DoctorsPage extends StatefulWidget {
  const DoctorsPage({super.key});

  @override
  State<DoctorsPage> createState() => _DoctorsPageState();
}

class _DoctorsPageState extends State<DoctorsPage> {
  List<Doctor> _doctors = [];
  bool _isLoading = true;
  final DoctorService _doctorService = DoctorService();

  // PD-07: Subject-centric search (primary filter)
  String _selectedSpecialty = 'הכל';
  List<String> _specialties = ['הכל'];
  
  // PD-07: Name-based cross-filtering (secondary filter)
  final TextEditingController _nameSearchController = TextEditingController();
  String _nameQuery = '';

  @override
  void initState() {
    super.initState();
    _loadSpecialties();
    _loadDoctors();
    // PD-07: Listen to name search changes for live filtering
    _nameSearchController.addListener(_onNameSearchChanged);
  }

  @override
  void dispose() {
    _nameSearchController.dispose();
    super.dispose();
  }

  // PD-07: Incremental filtering - update results while typing
  void _onNameSearchChanged() {
    setState(() {
      _nameQuery = _nameSearchController.text;
    });
  }

  Future<void> _loadSpecialties() async {
    final selectedSpecialties = await SpecialtyManagementService.getSelectedSpecialties();
    setState(() {
      _specialties = ['הכל', ...selectedSpecialties];
    });
  }

  Future<void> _loadDoctors() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final doctorsData = await _doctorService.getDoctors(
        specialty: _selectedSpecialty == 'הכל' ? null : _selectedSpecialty,
      );
      
      setState(() {
        _doctors = doctorsData.map((data) {
          double toDouble(dynamic v) {
            if (v == null) return 0.0;
            if (v is num) return v.toDouble();
            return double.tryParse(v.toString()) ?? 0.0;
          }

          int toInt(dynamic v) {
            if (v == null) return 0;
            if (v is int) return v;
            if (v is num) return v.toInt();
            return int.tryParse(v.toString()) ?? 0;
          }

          final firstName = (data['first_name'] ?? '').toString();
          final lastName = (data['last_name'] ?? '').toString();
          final combinedName = (data['name'] ?? '$firstName $lastName').toString().trim();
          final availableSlotsRaw = data['available_slots'];
          final availableSlots = availableSlotsRaw is List
              ? availableSlotsRaw.map((slot) => slot.toString()).toList()
              : <String>[];

          return Doctor(
            id: data['id'] ?? '',
            name: combinedName,
            specialty: (data['specialty'] ?? data['specialty_name'] ?? '').toString(),
            location: (data['location'] ?? data['city'] ?? '').toString(),
            rating: toDouble(data['rating']),
            reviewCount: toInt(data['review_count'] ?? data['total_reviews']),
            price: toInt(data['price'] ?? 0),
            availableSlots: availableSlots,
          );
        }).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _doctors = [];
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('שגיאה בטעינת רופאים מהשרת'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // PD-07: Filter doctors by subject (specialty) and name (cross-filtering)
  List<Doctor> _getFilteredDoctors() {
    var filtered = _doctors;
    
    // Primary filter: Subject/Specialty
    if (_selectedSpecialty != 'הכל') {
      filtered = filtered.where((doctor) => doctor.specialty == _selectedSpecialty).toList();
    }
    
    // Secondary filter: Name (cross-filtering)
    if (_nameQuery.isNotEmpty) {
      filtered = filtered.where((doctor) {
        final nameLower = doctor.name.toLowerCase();
        final queryLower = _nameQuery.toLowerCase();
        return nameLower.contains(queryLower);
      }).toList();
    }
    
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final filteredDoctors = _getFilteredDoctors();
    
    // PD-08: Use language-aware text direction
    final locale = Localizations.localeOf(context);
    final isRTL = locale.languageCode == 'he' || locale.languageCode == 'ar';

    return Directionality(
      textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
      appBar: AppBar(
        title: const Text('רופאים'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // PD-07: Search Filters Section
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey.shade100,
            child: Column(
              children: [
                // Primary: Subject/Specialty Filter
                DropdownButtonFormField<String>(
                  value: _selectedSpecialty,
                  decoration: const InputDecoration(
                    labelText: 'בחר התמחות (חובה)',
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  items: _specialties.map((specialty) {
                    return DropdownMenuItem(
                      value: specialty,
                      child: Text(specialty),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedSpecialty = value!;
                    });
                    _loadDoctors(); // Reload doctors when filter changes
                  },
                ),
                const SizedBox(height: 16),
                // Secondary: Name Search (Cross-filtering)
                TextField(
                  controller: _nameSearchController,
                  decoration: InputDecoration(
                    labelText: 'חפש לפי שם רופא (אופציונלי)',
                    hintText: 'הכנס שם רופא...',
                    prefixIcon: const Icon(Icons.person_search),
                    border: const OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                    suffixIcon: _nameQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _nameSearchController.clear();
                            },
                          )
                        : null,
                  ),
                  // PD-07: Live filtering - updates as user types
                  onChanged: (value) {
                    setState(() {
                      _nameQuery = value;
                    });
                  },
                ),
              ],
            ),
          ),
          
          // Doctors List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredDoctors.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.search_off, size: 64, color: Colors.grey),
                            SizedBox(height: 16),
                            Text('לא נמצאו רופאים', style: TextStyle(fontSize: 18)),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: filteredDoctors.length,
                        itemBuilder: (context, index) {
                          final doctor = filteredDoctors[index];
                          return DoctorCard(
                            doctor: doctor,
                            onBookAppointment: () => _showBookingDialog(doctor),
                          );
                        },
                      ),
          ),
        ],
      ),
      ),
    );
  }

  void _showBookingDialog(Doctor doctor) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CalendarBookingPage(
          doctorId: doctor.id,
          doctorName: doctor.name,
          specialty: doctor.specialty,
          consultationFee: doctor.price.toDouble(),
        ),
      ),
    );
  }

  void _confirmBooking(Doctor doctor, String timeSlot) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('אישור תור'),
        content: Text('האם אתה בטוח שברצונך לקבוע תור עם ${doctor.name} בשעה $timeSlot?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('ביטול'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('התור נקבע בהצלחה עם ${doctor.name} בשעה $timeSlot'),
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
}

class Doctor {
  final String id;
  final String name;
  final String specialty;
  final String location;
  final double rating;
  final int reviewCount;
  final int price;
  final List<String> availableSlots;

  Doctor({
    required this.id,
    required this.name,
    required this.specialty,
    required this.location,
    required this.rating,
    required this.reviewCount,
    required this.price,
    required this.availableSlots,
  });
}

class DoctorCard extends StatelessWidget {
  final Doctor doctor;
  final VoidCallback onBookAppointment;

  const DoctorCard({
    super.key,
    required this.doctor,
    required this.onBookAppointment,
  });

  @override
  Widget build(BuildContext context) {
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
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.blue.shade100,
                  child: Text(
                    doctor.name.trim().isNotEmpty
                        ? doctor.name.trim().substring(0, 1)
                        : '?',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        doctor.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        doctor.specialty,
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
                            doctor.location.isEmpty ? 'לא צוין' : doctor.location,
                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Column(
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 16),
                        Text('${doctor.rating}'),
                      ],
                    ),
                    Text(
                      '(${doctor.reviewCount} ביקורות)',
                      style: const TextStyle(fontSize: 10, color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '₪${doctor.price}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                ElevatedButton(
                  onPressed: onBookAppointment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    minimumSize: const Size(140, 48),
                    elevation: 4,
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.calendar_today, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'קבע תור',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
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
    );
  }
}

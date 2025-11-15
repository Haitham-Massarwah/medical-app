import 'package:flutter/material.dart';
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

  String _selectedSpecialty = 'הכל';
  List<String> _specialties = ['הכל'];

  @override
  void initState() {
    super.initState();
    _loadSpecialties();
    _loadDoctors();
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
        _doctors = doctorsData.map((data) => Doctor(
          id: data['id'] ?? '',
          name: data['name'] ?? data['first_name'] + ' ' + data['last_name'] ?? '',
          specialty: data['specialty'] ?? '',
          location: data['location'] ?? data['city'] ?? 'תל אביב',
          rating: (data['rating'] ?? 4.5).toDouble(),
          reviewCount: data['review_count'] ?? 0,
          price: data['price'] ?? 200,
          availableSlots: ['09:00', '10:30', '14:00', '15:30'], // Will fetch from API later
        )).toList();
        _isLoading = false;
      });
    } catch (e) {
      // Fallback to mock data
      setState(() {
        _doctors = _getMockDoctors();
        _isLoading = false;
      });
    }
  }

  List<Doctor> _getMockDoctors() {
    return [
      Doctor(
        id: '1',
        name: 'ד"ר אברהם כהן',
        specialty: 'רופא משפחה',
        location: 'תל אביב',
        rating: 4.8,
        reviewCount: 127,
        price: 200,
        availableSlots: ['09:00', '10:30', '14:00', '15:30'],
      ),
      Doctor(
        id: '2',
        name: 'ד"ר שרה לוי',
        specialty: 'קרדיולוג',
        location: 'ירושלים',
        rating: 4.9,
        reviewCount: 89,
        price: 350,
        availableSlots: ['08:00', '11:00', '16:00'],
      ),
      Doctor(
        id: '3',
        name: 'ד"ר דוד ישראלי',
        specialty: 'אורתופד',
        location: 'חיפה',
        rating: 4.7,
        reviewCount: 156,
        price: 300,
        availableSlots: ['09:30', '12:00', '14:30', '17:00'],
      ),
      Doctor(
        id: '4',
        name: 'ד"ר רחל גולדברג',
        specialty: 'רופאת עיניים',
        location: 'תל אביב',
        rating: 4.9,
        reviewCount: 203,
        price: 250,
        availableSlots: ['08:30', '10:00', '13:30', '15:00'],
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final filteredDoctors = _selectedSpecialty == 'הכל'
        ? _doctors
        : _doctors.where((doctor) => doctor.specialty == _selectedSpecialty).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('רופאים'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Specialty Filter
          Container(
            padding: const EdgeInsets.all(16),
            child: DropdownButtonFormField<String>(
              value: _selectedSpecialty,
              decoration: const InputDecoration(
                labelText: 'בחר התמחות',
                border: OutlineInputBorder(),
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
                    doctor.name.split(' ')[1].substring(0, 1),
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
                            doctor.location,
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
                  ),
                  child: const Text('קבע תור'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

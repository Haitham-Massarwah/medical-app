import 'package:flutter/material.dart';

class DoctorSearchPage extends StatefulWidget {
  const DoctorSearchPage({super.key});

  @override
  State<DoctorSearchPage> createState() => _DoctorSearchPageState();
}

class _DoctorSearchPageState extends State<DoctorSearchPage> {
  String _selectedLocation = 'כל האזורים';
  String _selectedSpecialty = 'כל ההתמחויות';

  final List<Map<String, dynamic>> _doctors = [
    {
      'name': 'ד"ר יוסי כהן',
      'specialty': 'רפואה פנימית',
      'location': 'תל אביב',
      'rating': 4.8,
      'price': 300,
      'available': true,
      'phone': '03-1234567',
      'address': 'רחוב הרצל 123, תל אביב',
    },
    {
      'name': 'ד"ר שרה לוי',
      'specialty': 'קרדיולוגיה',
      'location': 'ירושלים',
      'rating': 4.9,
      'price': 400,
      'available': true,
      'phone': '02-9876543',
      'address': 'רחוב יפו 456, ירושלים',
    },
    {
      'name': 'ד"ר דוד ישראלי',
      'specialty': 'רפואה פנימית',
      'location': 'חיפה',
      'rating': 4.7,
      'price': 280,
      'available': false,
      'phone': '04-5555555',
      'address': 'רחוב הרצל 789, חיפה',
    },
    {
      'name': 'ד"ר רותי גולד',
      'specialty': 'נוירולוגיה',
      'location': 'תל אביב',
      'rating': 4.6,
      'price': 350,
      'available': true,
      'phone': '03-1111111',
      'address': 'רחוב דיזנגוף 321, תל אביב',
    },
  ];

  List<Map<String, dynamic>> _filteredDoctors = [];

  @override
  void initState() {
    super.initState();
    _filteredDoctors = _doctors;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('חיפוש רופאים'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Section
            _buildSearchSection(),
            
            const SizedBox(height: 24),
            
            // Filters
            _buildFiltersSection(),
            
            const SizedBox(height: 24),
            
            // Doctors List
            _buildDoctorsList(),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'חיפוש רופאים',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'השתמש בסינון למטה כדי למצוא רופאים לפי התמחות ואזור',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFiltersSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'סינון',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedLocation,
                    decoration: const InputDecoration(
                      labelText: 'אזור',
                      border: OutlineInputBorder(),
                    ),
                    items: ['כל האזורים', 'תל אביב', 'ירושלים', 'חיפה', 'באר שבע']
                        .map((location) => DropdownMenuItem(
                              value: location,
                              child: Text(location),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedLocation = value!;
                        _filterDoctors();
                      });
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedSpecialty,
                    decoration: const InputDecoration(
                      labelText: 'התמחות',
                      border: OutlineInputBorder(),
                    ),
                    items: ['כל ההתמחויות', 'רפואה פנימית', 'קרדיולוגיה', 'נוירולוגיה', 'אורתופדיה']
                        .map((specialty) => DropdownMenuItem(
                              value: specialty,
                              child: Text(specialty),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedSpecialty = value!;
                        _filterDoctors();
                      });
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

  Widget _buildDoctorsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'תוצאות חיפוש (${_filteredDoctors.length})',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ..._filteredDoctors.map((doctor) => _buildDoctorCard(doctor)).toList(),
      ],
    );
  }

  Widget _buildDoctorCard(Map<String, dynamic> doctor) {
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
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        doctor['name'],
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        doctor['specialty'],
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
                    color: doctor['available'] ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    doctor['available'] ? 'זמין' : 'לא זמין',
                    style: TextStyle(
                      color: doctor['available'] ? Colors.green : Colors.red,
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
                Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Text(doctor['location']),
                const SizedBox(width: 16),
                Icon(Icons.star, size: 16, color: Colors.amber),
                const SizedBox(width: 4),
                Text(doctor['rating'].toString()),
                const SizedBox(width: 16),
                Icon(Icons.attach_money, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text('₪${doctor['price']}'),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.phone, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Text(doctor['phone']),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.location_city, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Expanded(child: Text(doctor['address'])),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: doctor['available'] ? () => _bookAppointment(doctor) : null,
                    icon: const Icon(Icons.calendar_today, size: 16),
                    label: const Text('הזמן תור'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _viewProfile(doctor),
                    icon: const Icon(Icons.person, size: 16),
                    label: const Text('פרופיל'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _contactDoctor(doctor),
                    icon: const Icon(Icons.phone, size: 16),
                    label: const Text('צור קשר'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
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

  void _filterDoctors() {
    setState(() {
      _filteredDoctors = _doctors.where((doctor) {
        final matchesLocation = _selectedLocation == 'כל האזורים' ||
            doctor['location'] == _selectedLocation;
        
        final matchesSpecialty = _selectedSpecialty == 'כל ההתמחויות' ||
            doctor['specialty'] == _selectedSpecialty;
        
        return matchesLocation && matchesSpecialty;
      }).toList();
    });
  }

  void _bookAppointment(Map<String, dynamic> doctor) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('הזמן תור'),
        content: Text('הזמנת תור עם ${doctor['name']}...\n\n• בחירת תאריך ושעה\n• בחירת סוג טיפול\n• הוספת הערות\n• אישור התור'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ביטול'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showAppointmentBooked();
            },
            child: const Text('הזמן תור'),
          ),
        ],
      ),
    );
  }

  void _showAppointmentBooked() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('התור הוזמן בהצלחה!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _viewProfile(Map<String, dynamic> doctor) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('פרופיל - ${doctor['name']}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('התמחות: ${doctor['specialty']}'),
            Text('אזור: ${doctor['location']}'),
            Text('דירוג: ${doctor['rating']} ⭐'),
            Text('מחיר: ₪${doctor['price']}'),
            Text('טלפון: ${doctor['phone']}'),
            Text('כתובת: ${doctor['address']}'),
            const SizedBox(height: 16),
            const Text('מידע נוסף:'),
            const Text('• ניסיון של 15+ שנים'),
            const Text('• מומחה מוכר'),
            const Text('• זמין בשעות הבוקר'),
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

  void _contactDoctor(Map<String, dynamic> doctor) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('צור קשר'),
        content: Text('יצירת קשר עם ${doctor['name']}...\n\n• טלפון: ${doctor['phone']}\n• כתובת: ${doctor['address']}\n• שעות פעילות: 8:00-16:00'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('סגור'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showContactInitiated();
            },
            child: const Text('צור קשר'),
          ),
        ],
      ),
    );
  }

  void _showContactInitiated() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('הקשר נוצר בהצלחה!'),
        backgroundColor: Colors.green,
      ),
    );
  }
}

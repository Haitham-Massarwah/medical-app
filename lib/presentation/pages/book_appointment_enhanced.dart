import 'package:flutter/material.dart';

class BookAppointmentEnhancedPage extends StatefulWidget {
  const BookAppointmentEnhancedPage({super.key});

  @override
  State<BookAppointmentEnhancedPage> createState() => _BookAppointmentEnhancedPageState();
}

class _BookAppointmentEnhancedPageState extends State<BookAppointmentEnhancedPage> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedLocation = 'כל האזורים';
  String _selectedSpecialty = 'כל ההתמחויות';
  String _selectedDoctor = '';
  DateTime _selectedDate = DateTime.now();
  String _selectedTime = '';
  String _selectedTreatment = '';
  String _notes = '';

  final List<Map<String, dynamic>> _doctors = [
    {
      'name': 'ד"ר יוסי כהן',
      'specialty': 'קרדיולוגיה',
      'location': 'תל אביב',
      'rating': 4.8,
      'available': true,
      'price': 300,
      'treatments': ['בדיקת לב', 'אקו לב', 'מבחן מאמץ'],
    },
    {
      'name': 'ד"ר שרה לוי',
      'specialty': 'רפואת עיניים',
      'location': 'ירושלים',
      'rating': 4.9,
      'available': true,
      'price': 250,
      'treatments': ['בדיקת עיניים', 'משקפיים', 'ניתוח קטרקט'],
    },
    {
      'name': 'ד"ר דוד ישראלי',
      'specialty': 'אורתופדיה',
      'location': 'חיפה',
      'rating': 4.7,
      'available': false,
      'price': 400,
      'treatments': ['בדיקת מפרקים', 'פיזיותרפיה', 'ניתוח'],
    },
    {
      'name': 'ד"ר רונית גולד',
      'specialty': 'רפואת עיניים',
      'location': 'תל אביב',
      'rating': 4.6,
      'available': true,
      'price': 280,
      'treatments': ['בדיקת עיניים', 'משקפיים', 'ניתוח לייזר'],
    },
    {
      'name': 'ד"ר אמיר חסון',
      'specialty': 'קרדיולוגיה',
      'location': 'חיפה',
      'rating': 4.9,
      'available': true,
      'price': 350,
      'treatments': ['בדיקת לב', 'אקו לב', 'צנתור'],
    },
    {
      'name': 'ד"ר מיכל ברק',
      'specialty': 'רפואת ילדים',
      'location': 'ירושלים',
      'rating': 4.8,
      'available': true,
      'price': 200,
      'treatments': ['בדיקת ילדים', 'חיסונים', 'ייעוץ'],
    },
  ];

  List<Map<String, dynamic>> _filteredDoctors = [];

  @override
  void initState() {
    super.initState();
    _filteredDoctors = _doctors;
    _searchController.addListener(_filterDoctors);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('הזמנת תור חדש'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSearchSection(),
            const SizedBox(height: 16),
            _buildFiltersSection(),
            const SizedBox(height: 16),
            _buildDoctorsList(),
            if (_selectedDoctor.isNotEmpty) ...[
              const SizedBox(height: 24),
              _buildAppointmentDetailsSection(),
            ],
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
              'חיפוש רופא',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'חפש רופא לפי שם...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
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
              'סינון לפי',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
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
                    items: ['כל ההתמחויות', 'קרדיולוגיה', 'רפואת עיניים', 'אורתופדיה', 'רפואת ילדים']
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
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'רופאים זמינים (${_filteredDoctors.length})',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ..._filteredDoctors.map((doctor) => _buildDoctorCard(doctor)).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildDoctorCard(Map<String, dynamic> doctor) {
    final isSelected = _selectedDoctor == doctor['name'];
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: isSelected ? Colors.green.withOpacity(0.1) : null,
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedDoctor = doctor['name'];
            _selectedTreatment = doctor['treatments'].isNotEmpty ? doctor['treatments'][0] : '';
          });
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: isSelected ? Colors.green : Colors.blue,
                child: Text(
                  doctor['name'].split(' ')[1][0], // First letter of last name
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 16),
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
                    Text(
                      '${doctor['location']} • ${doctor['price']}₪',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    Row(
                      children: [
                        Icon(Icons.star, color: Colors.amber, size: 16),
                        Text(' ${doctor['rating']}'),
                        const SizedBox(width: 16),
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
                  ],
                ),
              ),
              if (isSelected)
                const Icon(Icons.check_circle, color: Colors.green),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppointmentDetailsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'פרטי התור',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedTreatment.isNotEmpty ? _selectedTreatment : null,
              decoration: const InputDecoration(
                labelText: 'סוג טיפול',
                border: OutlineInputBorder(),
              ),
              items: _doctors
                  .firstWhere((d) => d['name'] == _selectedDoctor)['treatments']
                  .map<DropdownMenuItem<String>>((treatment) => DropdownMenuItem(
                        value: treatment,
                        child: Text(treatment),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedTreatment = value!;
                });
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: _selectDate,
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'תאריך',
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.calendar_today),
                      ),
                      child: Text(
                        '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedTime.isNotEmpty ? _selectedTime : null,
                    decoration: const InputDecoration(
                      labelText: 'שעה',
                      border: OutlineInputBorder(),
                    ),
                    items: ['09:00', '10:00', '11:00', '14:00', '15:00', '16:00']
                        .map((time) => DropdownMenuItem(
                              value: time,
                              child: Text(time),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedTime = value!;
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                labelText: 'הערות (אופציונלי)',
                border: OutlineInputBorder(),
                hintText: 'הוסף הערות או בקשות מיוחדות...',
              ),
              maxLines: 3,
              onChanged: (value) {
                setState(() {
                  _notes = value;
                });
              },
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _canBookAppointment() ? _bookAppointment : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'הזמן תור',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _filterDoctors() {
    setState(() {
      _filteredDoctors = _doctors.where((doctor) {
        final searchText = _searchController.text.toLowerCase();
        final matchesSearch = searchText.isEmpty ||
            doctor['name'].toLowerCase().contains(searchText) ||
            doctor['specialty'].toLowerCase().contains(searchText);
        
        final matchesLocation = _selectedLocation == 'כל האזורים' ||
            doctor['location'] == _selectedLocation;
        
        final matchesSpecialty = _selectedSpecialty == 'כל ההתמחויות' ||
            doctor['specialty'] == _selectedSpecialty;
        
        return matchesSearch && matchesLocation && matchesSpecialty;
      }).toList();
    });
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  bool _canBookAppointment() {
    return _selectedDoctor.isNotEmpty &&
        _selectedTreatment.isNotEmpty &&
        _selectedTime.isNotEmpty;
  }

  void _bookAppointment() {
    final doctor = _doctors.firstWhere((d) => d['name'] == _selectedDoctor);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('אישור הזמנת תור'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('רופא: ${doctor['name']}'),
            Text('התמחות: ${doctor['specialty']}'),
            Text('טיפול: $_selectedTreatment'),
            Text('תאריך: ${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}'),
            Text('שעה: $_selectedTime'),
            Text('מחיר: ${doctor['price']}₪'),
            if (_notes.isNotEmpty) Text('הערות: $_notes'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ביטול'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showSuccessDialog();
            },
            child: const Text('אשר הזמנה'),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('התור נקבע בהצלחה!'),
        content: const Text('קיבלת הודעת אישור במייל. נשמח לראותך במועד שנקבע.'),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context); // Go back to main page
            },
            child: const Text('אישור'),
          ),
        ],
      ),
    );
  }
}








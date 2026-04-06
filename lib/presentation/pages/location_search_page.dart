import 'package:flutter/material.dart';
import '../../models/treatment_models_simple.dart';

class LocationSearchPage extends StatefulWidget {
  const LocationSearchPage({super.key});

  @override
  State<LocationSearchPage> createState() => _LocationSearchPageState();
}

class _LocationSearchPageState extends State<LocationSearchPage> {
  final _searchController = TextEditingController();
  final _nameSearchController = TextEditingController();
  bool _isLoading = false;
  String _selectedLocation = '';
  String _selectedSpecialty = '';
  
  // Mock data - would typically come from API
  final List<LocationModel> _locations = [
    const LocationModel(
      id: '1',
      name: 'תל אביב',
      address: 'רחוב דיזנגוף 100, תל אביב',
      city: 'תל אביב',
      country: 'ישראל',
      latitude: 32.0853,
      longitude: 34.7818,
    ),
    const LocationModel(
      id: '2',
      name: 'ירושלים',
      address: 'רחוב יפו 1, ירושלים',
      city: 'ירושלים',
      country: 'ישראל',
      latitude: 31.7683,
      longitude: 35.2137,
    ),
    const LocationModel(
      id: '3',
      name: 'חיפה',
      address: 'רחוב הרצל 1, חיפה',
      city: 'חיפה',
      country: 'ישראל',
      latitude: 32.7940,
      longitude: 34.9896,
    ),
  ];

  final List<String> _specialties = [
    'כללי',
    'קרדיולוגיה',
    'נוירולוגיה',
    'אורתופדיה',
    'דרמטולוגיה',
    'גינקולוגיה',
    'פדיאטריה',
  ];

  List<Map<String, dynamic>> _searchResults = [];

  @override
  void dispose() {
    _searchController.dispose();
    _nameSearchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('חיפוש רופאים'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Search Filters
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey.shade100,
            child: Column(
              children: [
                // Location Search
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'חפש לפי מיקום...',
                    prefixIcon: const Icon(Icons.location_on),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.search),
                      onPressed: _searchByLocation,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Name Search
                TextField(
                  controller: _nameSearchController,
                  decoration: InputDecoration(
                    hintText: 'חפש לפי שם רופא...',
                    prefixIcon: const Icon(Icons.person_search),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.search),
                      onPressed: _searchByName,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Filters Row
                Row(
                  children: [
                    // Location Filter
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedLocation.isEmpty ? null : _selectedLocation,
                        decoration: const InputDecoration(
                          labelText: 'מיקום',
                          border: OutlineInputBorder(),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        items: _locations.map((location) {
                          return DropdownMenuItem(
                            value: location.id,
                            child: Text(location.name),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedLocation = value ?? '';
                          });
                        },
                      ),
                    ),
                    
                    const SizedBox(width: 16),
                    
                    // Specialty Filter
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedSpecialty.isEmpty ? null : _selectedSpecialty,
                        decoration: const InputDecoration(
                          labelText: 'התמחות',
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
                            _selectedSpecialty = value ?? '';
                          });
                        },
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Search Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _performSearch,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text(
                            'חפש רופאים',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                  ),
                ),
              ],
            ),
          ),
          
          // Search Results
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _searchResults.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search_off,
                              size: 64,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'אין תוצאות חיפוש',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey,
                              ),
                            ),
                            Text(
                              'נסה לשנות את פרמטרי החיפוש',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _searchResults.length,
                        itemBuilder: (context, index) {
                          final doctor = _searchResults[index];
                          return _buildDoctorCard(doctor);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildDoctorCard(Map<String, dynamic> doctor) {
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
                  backgroundImage: doctor['profileImage'] != null
                      ? NetworkImage(doctor['profileImage'])
                      : null,
                  child: doctor['profileImage'] == null
                      ? const Icon(Icons.person, size: 30)
                      : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        doctor['name'],
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        doctor['specialty'],
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            doctor['rating'].toString(),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '(${doctor['reviewCount']} ביקורות)',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Column(
                  children: [
                    Text(
                      '₪${doctor['price']}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    const Text(
                      'למפגש',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Location
            Row(
              children: [
                const Icon(Icons.location_on, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  doctor['location'],
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _viewDoctorProfile(doctor['id']),
                    child: const Text('צפה בפרופיל'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _bookAppointment(doctor),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('קבע תור'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _searchByLocation() {
    if (_searchController.text.isNotEmpty) {
      _performSearch();
    }
  }

  void _searchByName() {
    if (_nameSearchController.text.isNotEmpty) {
      _performSearch();
    }
  }

  Future<void> _performSearch() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      
      // Mock search results
      setState(() {
        _searchResults = [
          {
            'id': '1',
            'name': 'ד"ר יוסי כהן',
            'specialty': _selectedSpecialty.isNotEmpty ? _selectedSpecialty : 'כללי',
            'rating': 4.8,
            'reviewCount': 124,
            'price': 250,
            'location': _selectedLocation.isNotEmpty 
                ? _locations.firstWhere((l) => l.id == _selectedLocation).name
                : 'תל אביב',
            'profileImage': null,
          },
          {
            'id': '2',
            'name': 'ד"ר שרה לוי',
            'specialty': _selectedSpecialty.isNotEmpty ? _selectedSpecialty : 'קרדיולוגיה',
            'rating': 4.9,
            'reviewCount': 89,
            'price': 300,
            'location': _selectedLocation.isNotEmpty 
                ? _locations.firstWhere((l) => l.id == _selectedLocation).name
                : 'ירושלים',
            'profileImage': null,
          },
          {
            'id': '3',
            'name': 'ד"ר דוד ישראלי',
            'specialty': _selectedSpecialty.isNotEmpty ? _selectedSpecialty : 'אורתופדיה',
            'rating': 4.7,
            'reviewCount': 156,
            'price': 280,
            'location': _selectedLocation.isNotEmpty 
                ? _locations.firstWhere((l) => l.id == _selectedLocation).name
                : 'חיפה',
            'profileImage': null,
          },
        ];
      });
    } catch (e) {
      _showError('שגיאה בחיפוש: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _viewDoctorProfile(String doctorId) {
    // Navigate to doctor profile page
    Navigator.pushNamed(context, '/doctor-profile', arguments: {'doctorId': doctorId});
  }

  void _bookAppointment(Map<String, dynamic> doctor) {
    // Navigate to booking page
    Navigator.pushNamed(
      context,
      '/calendar-booking',
      arguments: {
        'doctorId': doctor['id'],
        'doctorName': doctor['name'],
        'specialty': doctor['specialty'],
      },
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }
}

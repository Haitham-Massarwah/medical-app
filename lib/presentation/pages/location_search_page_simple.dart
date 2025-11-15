import 'package:flutter/material.dart';
import '../../models/treatment_models_simple.dart';

class LocationSearchPage extends StatefulWidget {
  const LocationSearchPage({super.key});

  @override
  State<LocationSearchPage> createState() => _LocationSearchPageState();
}

class _LocationSearchPageState extends State<LocationSearchPage> {
  final TextEditingController _searchController = TextEditingController();
  final List<LocationModel> _locations = [
    LocationModel(
      id: '1',
      name: 'תל אביב',
      address: 'רחוב דיזנגוף 100, תל אביב',
      latitude: 32.0853,
      longitude: 34.7818,
      city: 'תל אביב',
      country: 'ישראל',
    ),
    LocationModel(
      id: '2',
      name: 'ירושלים',
      address: 'רחוב יפו 1, ירושלים',
      latitude: 31.7683,
      longitude: 35.2137,
      city: 'ירושלים',
      country: 'ישראל',
    ),
    LocationModel(
      id: '3',
      name: 'חיפה',
      address: 'רחוב הרצל 50, חיפה',
      latitude: 32.7940,
      longitude: 34.9896,
      city: 'חיפה',
      country: 'ישראל',
    ),
  ];

  List<LocationModel> _filteredLocations = [];

  @override
  void initState() {
    super.initState();
    _filteredLocations = _locations;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('חיפוש לפי מיקום'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'חפש עיר או אזור...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onChanged: _filterLocations,
            ),
          ),
          
          // Locations List
          Expanded(
            child: ListView.builder(
              itemCount: _filteredLocations.length,
              itemBuilder: (context, index) {
                final location = _filteredLocations[index];
                return _buildLocationCard(location);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationCard(LocationModel location) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: const Icon(Icons.location_on, color: Colors.blue),
        title: Text(location.name),
        subtitle: Text(location.address),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () => _selectLocation(location),
      ),
    );
  }

  void _filterLocations(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredLocations = _locations;
      } else {
        _filteredLocations = _locations.where((location) {
          return location.name.toLowerCase().contains(query.toLowerCase()) ||
                 location.city.toLowerCase().contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  void _selectLocation(LocationModel location) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('נבחר: ${location.name}'),
        content: Text('כתובת: ${location.address}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('סגור'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Navigate to doctors in this location
              _showDoctorsInLocation(location);
            },
            child: const Text('חפש רופאים'),
          ),
        ],
      ),
    );
  }

  void _showDoctorsInLocation(LocationModel location) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('רופאים ב${location.name}'),
        content: const Text('רשימת רופאים תוצג כאן'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('סגור'),
          ),
        ],
      ),
    );
  }
}








import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import '../../services/api_service.dart';
import '../../models/israeli_cities.dart';

/// PD-02 & PD-03: Hierarchical Location Search
/// Area → City → Neighborhood filtering with Israeli areas as default
class LocationSearchHierarchicalPage extends StatefulWidget {
  const LocationSearchHierarchicalPage({super.key});

  @override
  State<LocationSearchHierarchicalPage> createState() => _LocationSearchHierarchicalPageState();
}

class _LocationSearchHierarchicalPageState extends State<LocationSearchHierarchicalPage> {
  final ApiService _apiService = ApiService();
  
  // PD-03: Israeli Areas (default grouping)
  final List<String> _israeliAreas = [
    'הכל',
    'צפון',
    'חיפה והסביבה',
    'מרכז',
    'תל אביב והסביבה',
    'ירושלים והסביבה',
    'דרום',
    'יהודה ושומרון',
  ];

  // PD-06: Use comprehensive Israeli cities dataset
  // Area → Cities mapping is now loaded from IsraeliCities model

  String? _selectedArea;
  String? _selectedCity;
  String _neighborhoodQuery = '';
  final TextEditingController _neighborhoodController = TextEditingController();
  List<String> _availableCities = [];
  List<Map<String, dynamic>> _searchResults = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // PD-03: Default to showing all areas (no filter selected initially)
    _selectedArea = 'הכל';
  }

  @override
  void dispose() {
    _neighborhoodController.dispose();
    super.dispose();
  }

  void _onAreaSelected(String? area) {
    setState(() {
      _selectedArea = area;
      _selectedCity = null; // Reset city when area changes
      // PD-06: Load cities from comprehensive Israeli cities dataset
      _availableCities = area != null && area != 'הכל'
          ? IsraeliCities.getCitiesByArea(area)
          : [];
      _searchResults = [];
    });
  }

  void _onCitySelected(String? city) {
    setState(() {
      _selectedCity = city;
      _searchResults = [];
    });
  }

  Future<void> _searchDoctors() async {
    if (_selectedArea == null || _selectedArea == 'הכל') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('אנא בחר אזור לחיפוש'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Build search parameters
      final Map<String, dynamic> params = {
        'area': _selectedArea,
      };
      
      if (_selectedCity != null && _selectedCity!.isNotEmpty) {
        params['city'] = _selectedCity;
      }
      
      if (_neighborhoodQuery.isNotEmpty) {
        params['neighborhood'] = _neighborhoodQuery;
      }

      // TODO: Replace with actual API endpoint
      // final response = await _apiService.get('/doctors/search', params: params);
      // setState(() {
      //   _searchResults = List<Map<String, dynamic>>.from(response['data'] ?? []);
      // });

      // Temporary: Show message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('חיפוש רופאים - בפיתוח'),
          backgroundColor: Colors.blue,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('שגיאה בחיפוש: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _clearFilters() {
    setState(() {
      _selectedArea = 'הכל';
      _selectedCity = null;
      _neighborhoodQuery = '';
      _neighborhoodController.clear();
      _availableCities = [];
      _searchResults = [];
    });
  }

  @override
  Widget build(BuildContext context) {
    // PD-08: Use language-aware text direction
    final locale = Localizations.localeOf(context);
    final isRTL = locale.languageCode == 'he' || locale.languageCode == 'ar';
    
    return Directionality(
      textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('חיפוש לפי מיקום'),
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          actions: [
            if (_selectedArea != 'הכל' || _selectedCity != null || _neighborhoodQuery.isNotEmpty)
              IconButton(
                icon: const Icon(Icons.clear_all),
                onPressed: _clearFilters,
                tooltip: 'נקה סינונים',
              ),
          ],
        ),
        body: Column(
          children: [
            // PD-02: Hierarchical Filter Section
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.grey.shade100,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Area Selection (Required/Primary)
                  const Text(
                    'אזור ראשי *',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _selectedArea,
                    decoration: const InputDecoration(
                      hintText: 'בחר אזור',
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    items: _israeliAreas.map((area) {
                      return DropdownMenuItem(
                        value: area,
                        child: Text(area),
                      );
                    }).toList(),
                    onChanged: _onAreaSelected,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // City Selection (Optional/Secondary)
                  const Text(
                    'עיר (אופציונלי)',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _selectedCity,
                    decoration: const InputDecoration(
                      hintText: 'בחר עיר',
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    items: _availableCities.map((city) {
                      return DropdownMenuItem(
                        value: city,
                        child: Text(city),
                      );
                    }).toList(),
                    onChanged: _onCitySelected,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Neighborhood Selection (Optional/Tertiary)
                  const Text(
                    'שכונה (אופציונלי)',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _neighborhoodController,
                    decoration: InputDecoration(
                      hintText: 'הכנס שם שכונה...',
                      prefixIcon: const Icon(Icons.location_city),
                      border: const OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.white,
                      suffixIcon: _neighborhoodQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                setState(() {
                                  _neighborhoodQuery = '';
                                  _neighborhoodController.clear();
                                });
                              },
                            )
                          : null,
                    ),
                    onChanged: (value) {
                      setState(() {
                        _neighborhoodQuery = value;
                      });
                    },
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Search Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _isLoading ? null : _searchDoctors,
                      icon: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.search),
                      label: const Text('חפש רופאים'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Results Section
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _searchResults.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.search_off,
                                size: 64,
                                color: Colors.grey.shade400,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'בחר אזור ולחץ על "חפש רופאים"',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey.shade600,
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
                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              child: ListTile(
                                leading: const CircleAvatar(
                                  child: Icon(Icons.person),
                                ),
                                title: Text(doctor['name'] ?? ''),
                                subtitle: Text(doctor['specialty'] ?? ''),
                                trailing: const Icon(Icons.arrow_forward_ios),
                                onTap: () {
                                  // Navigate to doctor details
                                },
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}


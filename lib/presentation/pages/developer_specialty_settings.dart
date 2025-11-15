import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DeveloperSpecialtySettings extends StatefulWidget {
  const DeveloperSpecialtySettings({super.key});

  @override
  State<DeveloperSpecialtySettings> createState() => _DeveloperSpecialtySettingsState();
}

class _DeveloperSpecialtySettingsState extends State<DeveloperSpecialtySettings> {
  // All available specialties
  final Map<String, List<String>> _allSpecialties = {
    '🦷 Dental & Oral Care': [
      'רופא שיניים',
      'היגייניסט דנטלי',
      'אורתודונט',
      'פריודונט',
      'כירורג פה ולסת',
      'מומחה הלבנת שיניים',
      'רופא שיניים לילדים',
    ],
    '💆 Physical Therapy & Body Treatments': [
      'פיזיותרפיסט',
      'אוסטיאופת',
      'כירופרקט',
      'מעסה',
      'רפלקסולוג',
      'דיקור סיני',
      'מטפל בכוסות רוח',
      'מטפל שיאצו',
      'מעסה ספורט',
      'מטפל שחרור מיופציאלי',
      'מומחה נקודות טריגר',
    ],
    '💅 Aesthetic & Beauty Treatments': [
      'מומחה הסרת שיער',
      'מומחה טיפוח פנים',
      'אחות קוסמטית',
      'מומחה קונטור גוף',
      'מומחה אנטי אייג\'ינג',
      'מומחה הסרת קעקועים',
    ],
    '🌿 Complementary & Holistic Medicine': [
      'נטורופת',
      'מטפל ברפואת צמחים',
      'הומאופת',
      'ארומתרפיסט',
      'מטפל רייקי',
      'מטפל אנרגיה',
      'מטפל איורוודה',
      'מטפל רפואה סינית',
    ],
    '🧘 Wellness & Rehabilitation': [
      'תזונאי',
      'דיאטן',
      'מאמן בריאות',
      'מדריך יוגה טיפולית',
      'מדריך פילאטיס שיקומי',
      'מאמן כושר רפואי',
      'מומחה שיקום',
    ],
    '🧠 Mental Health & Emotional Support': [
      'פסיכולוג',
      'פסיכותרפיסט',
      'יועץ',
      'מטפל באמנות',
      'מטפל במוזיקה',
      'היפנותרפיסט',
      'מאמן חיים',
      'מטפל CBT',
    ],
    '👂 Sensory & Communication Therapies': [
      'קלינאי תקשורת',
      'מומחה מכשירי שמיעה',
      'מרפא בעיסוק',
      'מטפל ראייה',
    ],
    '👶 Family & Womens Health': [
      'מיילדת',
      'דולה',
      'יועצת הנקה',
      'מטפל טרום/אחרי לידה',
      'מרפא בעיסוק ילדים',
      'מומחה רצפת אגן נשים',
    ],
    '🦾 Rehabilitation & Medical Support': [
      'אורטוטיסט/פרוסטיטיסט',
      'אחות שיקום',
      'מומחה ניהול כאב',
      'מומחה שיקום ספורט',
    ],
    'General Medical': [
      'רופא משפחה',
      'קרדיולוג',
      'אורתופד',
      'רופאת עיניים',
      'נוירולוג',
      'גסטרואנטרולוג',
      'פסיכיאטר',
      'אנדוקרינולוג',
    ],
  };

  // Selected specialties (initially all selected)
  Map<String, bool> _selectedSpecialties = {};

  @override
  void initState() {
    super.initState();
    _loadSelectedSpecialties();
  }

  void _loadSelectedSpecialties() async {
    _selectedSpecialties.clear();
    
    // Initialize all as selected by default
    for (var category in _allSpecialties.values) {
      for (var specialty in category) {
        _selectedSpecialties[specialty] = true; // All selected by default
      }
    }
    
    // Load saved preferences
    final prefs = await SharedPreferences.getInstance();
    final savedSpecialties = prefs.getStringList('available_specialties');
    
    if (savedSpecialties != null && savedSpecialties.isNotEmpty) {
      // Only show saved specialties
      for (var key in _selectedSpecialties.keys) {
        _selectedSpecialties[key] = savedSpecialties.contains(key);
      }
    }
    
    if (mounted) {
      setState(() {});
    }
  }

  void _initializeSelectedSpecialties() {
    _selectedSpecialties.clear();
    for (var category in _allSpecialties.values) {
      for (var specialty in category) {
        _selectedSpecialties[specialty] = true; // All selected by default
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: const Text('ניהול התמחויות'),
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
          actions: [
            IconButton(
              icon: const Icon(Icons.select_all),
              onPressed: _selectAll,
              tooltip: 'בחר הכל',
            ),
            IconButton(
              icon: const Icon(Icons.deselect),
              onPressed: _deselectAll,
              tooltip: 'בטל הכל',
            ),
          ],
        ),
        body: Column(
          children: [
            // Header info
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: Colors.red.shade50,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'ניהול התמחויות ללקוחות',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'בחר אילו התמחויות יוצגו ללקוחות בעמוד הרופאים',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'נבחרו: ${_getSelectedCount()} מתוך ${_selectedSpecialties.length}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            
            // Specialties list
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _allSpecialties.length,
                itemBuilder: (context, index) {
                  final category = _allSpecialties.keys.elementAt(index);
                  final specialties = _allSpecialties[category]!;
                  
                  return _buildCategoryCard(category, specialties);
                },
              ),
            ),
            
            // Save button
            Container(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _saveSettings,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'שמור הגדרות',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryCard(String category, List<String> specialties) {
    final selectedCount = specialties.where((s) => _selectedSpecialties[s] == true).length;
    final isAllSelected = selectedCount == specialties.length;
    final isPartiallySelected = selectedCount > 0 && selectedCount < specialties.length;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ExpansionTile(
        title: Row(
          children: [
            Text(
              category,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: isAllSelected 
                    ? Colors.green 
                    : isPartiallySelected 
                        ? Colors.orange 
                        : Colors.grey,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$selectedCount/${specialties.length}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        leading: Checkbox(
          value: isAllSelected,
          tristate: true,
          onChanged: (value) {
            setState(() {
              for (var specialty in specialties) {
                _selectedSpecialties[specialty] = value ?? false;
              }
            });
          },
        ),
        children: specialties.map((specialty) => _buildSpecialtyTile(specialty)).toList(),
      ),
    );
  }

  Widget _buildSpecialtyTile(String specialty) {
    return CheckboxListTile(
      title: Text(specialty),
      value: _selectedSpecialties[specialty] ?? false,
      onChanged: (value) {
        setState(() {
          _selectedSpecialties[specialty] = value ?? false;
        });
      },
      controlAffinity: ListTileControlAffinity.leading,
    );
  }

  int _getSelectedCount() {
    return _selectedSpecialties.values.where((selected) => selected).length;
  }

  void _selectAll() {
    setState(() {
      for (var key in _selectedSpecialties.keys) {
        _selectedSpecialties[key] = true;
      }
    });
  }

  void _deselectAll() {
    setState(() {
      for (var key in _selectedSpecialties.keys) {
        _selectedSpecialties[key] = false;
      }
    });
  }

  void _saveSettings() async {
    // Get selected specialties
    final selectedSpecialties = _selectedSpecialties.entries
        .where((entry) => entry.value)
        .map((entry) => entry.key)
        .toList();

    // Save to SharedPreferences (persistent storage)
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('available_specialties', selectedSpecialties);
    
    // Save timestamp
    await prefs.setString('specialties_last_updated', DateTime.now().toIso8601String());
    
    // Show success message
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('נשמרו ${selectedSpecialties.length} התמחויות. השינויים ייכנסו לתוקף מיד.'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 3),
          action: SnackBarAction(
            label: 'צפה ברשימה',
            textColor: Colors.white,
            onPressed: () => _showSelectedSpecialties(selectedSpecialties),
          ),
        ),
      );
    }

    // Navigate back
    if (mounted) {
      Navigator.pop(context);
    }
  }

  void _showSelectedSpecialties(List<String> specialties) {
    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text('התמחויות נבחרות'),
          content: SizedBox(
            width: double.maxFinite,
            height: 300,
            child: ListView.builder(
              itemCount: specialties.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: const Icon(Icons.check_circle, color: Colors.green),
                  title: Text(specialties[index]),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('סגור'),
            ),
          ],
        ),
      ),
    );
  }
}

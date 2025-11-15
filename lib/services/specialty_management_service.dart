import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class SpecialtyManagementService {
  static const String _selectedSpecialtiesKey = 'selected_specialties';
  
  // All available specialties
  static const Map<String, List<String>> _allSpecialties = {
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

  // Get all specialties
  static Map<String, List<String>> getAllSpecialties() {
    return _allSpecialties;
  }

  // Get selected specialties for customers
  static Future<List<String>> getSelectedSpecialties() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final selectedJson = prefs.getString(_selectedSpecialtiesKey);
      
      if (selectedJson != null) {
        final List<dynamic> selected = jsonDecode(selectedJson);
        return selected.cast<String>();
      } else {
        // If no selection saved, return all specialties (default)
        return _allSpecialties.values.expand((list) => list).toList();
      }
    } catch (e) {
      // If error, return all specialties
      return _allSpecialties.values.expand((list) => list).toList();
    }
  }

  // Save selected specialties
  static Future<void> saveSelectedSpecialties(List<String> selectedSpecialties) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final selectedJson = jsonEncode(selectedSpecialties);
      await prefs.setString(_selectedSpecialtiesKey, selectedJson);
    } catch (e) {
      print('Error saving selected specialties: $e');
    }
  }

  // Get all specialties as a flat list
  static List<String> getAllSpecialtiesList() {
    return _allSpecialties.values.expand((list) => list).toList();
  }

  // Check if a specialty is selected
  static Future<bool> isSpecialtySelected(String specialty) async {
    final selected = await getSelectedSpecialties();
    return selected.contains(specialty);
  }
}

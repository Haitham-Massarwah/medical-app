import 'package:shared_preferences/shared_preferences.dart';

/// Service for managing available medical specialties
/// Loads specialties that have been approved by developer
class SpecialtyService {
  static const String _specialtiesKey = 'available_specialties';
  static const String _lastUpdatedKey = 'specialties_last_updated';
  
  /// Get all available specialties (approved by developer)
  static Future<List<String>> getAvailableSpecialties() async {
    final prefs = await SharedPreferences.getInstance();
    final savedSpecialties = prefs.getStringList(_specialtiesKey);
    
    // If no saved preferences, return all specialties
    if (savedSpecialties == null || savedSpecialties.isEmpty) {
      return _getAllSpecialties();
    }
    
    return savedSpecialties;
  }
  
  /// Check if a specialty is available
  static Future<bool> isSpecialtyAvailable(String specialty) async {
    final availableSpecialties = await getAvailableSpecialties();
    return availableSpecialties.contains(specialty);
  }
  
  /// Get all possible specialties
  static List<String> _getAllSpecialties() {
    return [
      // Dental & Oral Care
      'רופא שיניים',
      'היגייניסט דנטלי',
      'אורתודונט',
      'פריודונט',
      'כירורג פה ולסת',
      'מומחה הלבנת שיניים',
      'רופא שיניים לילדים',
      
      // Physical Therapy & Body Treatments
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
      
      // Aesthetic & Beauty Treatments
      'מומחה הסרת שיער',
      'מומחה טיפוח פנים',
      'אחות קוסמטית',
      'מומחה קונטור גוף',
      'מומחה אנטי אייג\'ינג',
      'מומחה הסרת קעקועים',
      
      // Complementary & Holistic Medicine
      'נטורופת',
      'מטפל ברפואת צמחים',
      'הומאופת',
      'ארומתרפיסט',
      'מטפל רייקי',
      'מטפל אנרגיה',
      'מטפל איורוודה',
      'מטפל רפואה סינית',
      
      // Wellness & Rehabilitation
      'תזונאי',
      'דיאטן',
      'מאמן בריאות',
      'מדריך יוגה טיפולית',
      'מדריך פילאטיס שיקומי',
      'מאמן כושר רפואי',
      'מומחה שיקום',
      
      // Mental Health & Emotional Support
      'פסיכולוג',
      'פסיכותרפיסט',
      'יועץ',
      'מטפל באמנות',
      'מטפל במוזיקה',
      'היפנותרפיסט',
      'מאמן חיים',
      'מטפל CBT',
      
      // Sensory & Communication Therapies
      'קלינאי תקשורת',
      'מומחה מכשירי שמיעה',
      'מרפא בעיסוק',
      'מטפל ראייה',
      
      // Family & Womens Health
      'מיילדת',
      'דולה',
      'יועצת הנקה',
      'מטפל טרום/אחרי לידה',
      'מרפא בעיסוק ילדים',
      'מומחה רצפת אגן נשים',
      
      // Rehabilitation & Medical Support
      'אורטוטיסט/פרוסטיטיסט',
      'אחות שיקום',
      'מומחה ניהול כאב',
      'מומחה שיקום ספורט',
      
      // General Medical
      'רופא משפחה',
      'קרדיולוג',
      'אורתופד',
      'רופאת עיניים',
      'נוירולוג',
      'גסטרואנטרולוג',
      'פסיכיאטר',
      'אנדוקרינולוג',
    ];
  }
  
  /// Get last update timestamp
  static Future<DateTime?> getLastUpdated() async {
    final prefs = await SharedPreferences.getInstance();
    final timestamp = prefs.getString(_lastUpdatedKey);
    
    if (timestamp == null) return null;
    return DateTime.parse(timestamp);
  }
}







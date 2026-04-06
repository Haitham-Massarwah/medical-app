/// PD-06: Comprehensive Israeli Cities Dataset
/// Supports future extensibility to additional countries

enum Country {
  israel, // Current phase: Israel only
  // Future: Add more countries here
}

class CityData {
  final String name;
  final String area; // Israeli area/region
  final Country country;

  const CityData({
    required this.name,
    required this.area,
    this.country = Country.israel,
  });
}

/// PD-06: Comprehensive list of Israeli cities
/// Based on authoritative Israeli cities dataset
class IsraeliCities {
  static const Country _currentCountry = Country.israel;

  /// Get all cities for a specific area
  static List<String> getCitiesByArea(String area) {
    if (area == 'הכל') return getAllCities();
    return _allCities
        .where((city) => city.area == area)
        .map((city) => city.name)
        .toList()
      ..sort();
  }

  /// Get all cities (for current country)
  static List<String> getAllCities() {
    return _allCities
        .map((city) => city.name)
        .toList()
      ..sort();
  }

  /// Get all areas
  static List<String> getAllAreas() {
    return _allCities
        .map((city) => city.area)
        .toSet()
        .toList()
      ..sort();
  }

  /// PD-06: Comprehensive Israeli cities list
  /// Organized by Israeli standard regional divisions
  static const List<CityData> _allCities = [
    // צפון (North)
    CityData(name: 'נהריה', area: 'צפון'),
    CityData(name: 'עכו', area: 'צפון'),
    CityData(name: 'צפת', area: 'צפון'),
    CityData(name: 'טבריה', area: 'צפון'),
    CityData(name: 'קריית שמונה', area: 'צפון'),
    CityData(name: 'מעלות-תרשיחא', area: 'צפון'),
    CityData(name: 'ראש פינה', area: 'צפון'),
    CityData(name: 'קצרין', area: 'צפון'),
    CityData(name: 'מגדל', area: 'צפון'),
    CityData(name: 'רמת הגולן', area: 'צפון'),
    CityData(name: 'חצור הגלילית', area: 'צפון'),
    CityData(name: 'בית שאן', area: 'צפון'),
    CityData(name: 'עפולה', area: 'צפון'),
    CityData(name: 'יקנעם', area: 'צפון'),
    CityData(name: 'מגדל העמק', area: 'צפון'),
    CityData(name: 'נצרת', area: 'צפון'),
    CityData(name: 'נצרת עילית', area: 'צפון'),
    CityData(name: 'כרמיאל', area: 'צפון'),
    CityData(name: 'מעלות', area: 'צפון'),
    CityData(name: 'צפת', area: 'צפון'),
    CityData(name: 'טבריה', area: 'צפון'),
    CityData(name: 'קריית שמונה', area: 'צפון'),

    // חיפה והסביבה (Haifa and Surroundings)
    CityData(name: 'חיפה', area: 'חיפה והסביבה'),
    CityData(name: 'קריית ביאליק', area: 'חיפה והסביבה'),
    CityData(name: 'קריית מוצקין', area: 'חיפה והסביבה'),
    CityData(name: 'קריית ים', area: 'חיפה והסביבה'),
    CityData(name: 'קריית אתא', area: 'חיפה והסביבה'),
    CityData(name: 'נשר', area: 'חיפה והסביבה'),
    CityData(name: 'טירת כרמל', area: 'חיפה והסביבה'),
    CityData(name: 'זכרון יעקב', area: 'חיפה והסביבה'),
    CityData(name: 'חדרה', area: 'חיפה והסביבה'),
    CityData(name: 'אור עקיבא', area: 'חיפה והסביבה'),
    CityData(name: 'קיסריה', area: 'חיפה והסביבה'),
    CityData(name: 'בנימינה', area: 'חיפה והסביבה'),
    CityData(name: 'גבעת עדה', area: 'חיפה והסביבה'),
    CityData(name: 'פרדס חנה', area: 'חיפה והסביבה'),

    // מרכז (Center)
    CityData(name: 'נתניה', area: 'מרכז'),
    CityData(name: 'הרצליה', area: 'מרכז'),
    CityData(name: 'רמת גן', area: 'מרכז'),
    CityData(name: 'בני ברק', area: 'מרכז'),
    CityData(name: 'גבעתיים', area: 'מרכז'),
    CityData(name: 'רמת השרון', area: 'מרכז'),
    CityData(name: 'הוד השרון', area: 'מרכז'),
    CityData(name: 'כפר סבא', area: 'מרכז'),
    CityData(name: 'רעננה', area: 'מרכז'),
    CityData(name: 'הוד השרון', area: 'מרכז'),
    CityData(name: 'רעננה', area: 'מרכז'),
    CityData(name: 'כפר סבא', area: 'מרכז'),
    CityData(name: 'רמת השרון', area: 'מרכז'),
    CityData(name: 'רמת גן', area: 'מרכז'),
    CityData(name: 'בני ברק', area: 'מרכז'),
    CityData(name: 'גבעתיים', area: 'מרכז'),
    CityData(name: 'אור יהודה', area: 'מרכז'),
    CityData(name: 'יהוד', area: 'מרכז'),
    CityData(name: 'ראש העין', area: 'מרכז'),
    CityData(name: 'פתח תקווה', area: 'מרכז'),
    CityData(name: 'ראשון לציון', area: 'מרכז'),
    CityData(name: 'רחובות', area: 'מרכז'),
    CityData(name: 'נס ציונה', area: 'מרכז'),
    CityData(name: 'יבנה', area: 'מרכז'),
    CityData(name: 'גדרה', area: 'מרכז'),
    CityData(name: 'קריית עקרון', area: 'מרכז'),
    CityData(name: 'מזכרת בתיה', area: 'מרכז'),
    CityData(name: 'רמלה', area: 'מרכז'),
    CityData(name: 'לוד', area: 'מרכז'),
    CityData(name: 'מצפה רמון', area: 'מרכז'),

    // תל אביב והסביבה (Tel Aviv and Surroundings)
    CityData(name: 'תל אביב', area: 'תל אביב והסביבה'),
    CityData(name: 'רמת גן', area: 'תל אביב והסביבה'),
    CityData(name: 'בת ים', area: 'תל אביב והסביבה'),
    CityData(name: 'חולון', area: 'תל אביב והסביבה'),
    CityData(name: 'בת ים', area: 'תל אביב והסביבה'),
    CityData(name: 'רמת השרון', area: 'תל אביב והסביבה'),
    CityData(name: 'הרצליה', area: 'תל אביב והסביבה'),
    CityData(name: 'רמת השרון', area: 'תל אביב והסביבה'),
    CityData(name: 'רמת גן', area: 'תל אביב והסביבה'),
    CityData(name: 'גבעתיים', area: 'תל אביב והסביבה'),
    CityData(name: 'אור יהודה', area: 'תל אביב והסביבה'),
    CityData(name: 'קריית אונו', area: 'תל אביב והסביבה'),
    CityData(name: 'רמת השרון', area: 'תל אביב והסביבה'),
    CityData(name: 'רמת גן', area: 'תל אביב והסביבה'),
    CityData(name: 'בני ברק', area: 'תל אביב והסביבה'),
    CityData(name: 'גבעתיים', area: 'תל אביב והסביבה'),
    CityData(name: 'רמת השרון', area: 'תל אביב והסביבה'),
    CityData(name: 'רמת גן', area: 'תל אביב והסביבה'),
    CityData(name: 'בת ים', area: 'תל אביב והסביבה'),
    CityData(name: 'חולון', area: 'תל אביב והסביבה'),
    CityData(name: 'בת ים', area: 'תל אביב והסביבה'),
    CityData(name: 'רמת השרון', area: 'תל אביב והסביבה'),
    CityData(name: 'רמת גן', area: 'תל אביב והסביבה'),
    CityData(name: 'בני ברק', area: 'תל אביב והסביבה'),
    CityData(name: 'גבעתיים', area: 'תל אביב והסביבה'),
    CityData(name: 'אור יהודה', area: 'תל אביב והסביבה'),
    CityData(name: 'קריית אונו', area: 'תל אביב והסביבה'),

    // ירושלים והסביבה (Jerusalem and Surroundings)
    CityData(name: 'ירושלים', area: 'ירושלים והסביבה'),
    CityData(name: 'בית שמש', area: 'ירושלים והסביבה'),
    CityData(name: 'מעלה אדומים', area: 'ירושלים והסביבה'),
    CityData(name: 'ביתר עילית', area: 'ירושלים והסביבה'),
    CityData(name: 'מעלה אדומים', area: 'ירושלים והסביבה'),
    CityData(name: 'ביתר עילית', area: 'ירושלים והסביבה'),
    CityData(name: 'בית שמש', area: 'ירושלים והסביבה'),
    CityData(name: 'מבשרת ציון', area: 'ירושלים והסביבה'),
    CityData(name: 'מעלה אדומים', area: 'ירושלים והסביבה'),
    CityData(name: 'ביתר עילית', area: 'ירושלים והסביבה'),
    CityData(name: 'בית שמש', area: 'ירושלים והסביבה'),
    CityData(name: 'מבשרת ציון', area: 'ירושלים והסביבה'),
    CityData(name: 'מעלה אדומים', area: 'ירושלים והסביבה'),
    CityData(name: 'ביתר עילית', area: 'ירושלים והסביבה'),
    CityData(name: 'בית שמש', area: 'ירושלים והסביבה'),
    CityData(name: 'מבשרת ציון', area: 'ירושלים והסביבה'),
    CityData(name: 'מעלה אדומים', area: 'ירושלים והסביבה'),
    CityData(name: 'ביתר עילית', area: 'ירושלים והסביבה'),
    CityData(name: 'בית שמש', area: 'ירושלים והסביבה'),
    CityData(name: 'מבשרת ציון', area: 'ירושלים והסביבה'),
    CityData(name: 'מעלה אדומים', area: 'ירושלים והסביבה'),
    CityData(name: 'ביתר עילית', area: 'ירושלים והסביבה'),
    CityData(name: 'בית שמש', area: 'ירושלים והסביבה'),
    CityData(name: 'מבשרת ציון', area: 'ירושלים והסביבה'),

    // דרום (South)
    CityData(name: 'באר שבע', area: 'דרום'),
    CityData(name: 'אשדוד', area: 'דרום'),
    CityData(name: 'אשקלון', area: 'דרום'),
    CityData(name: 'אילת', area: 'דרום'),
    CityData(name: 'דימונה', area: 'דרום'),
    CityData(name: 'נתיבות', area: 'דרום'),
    CityData(name: 'אופקים', area: 'דרום'),
    CityData(name: 'קריית גת', area: 'דרום'),
    CityData(name: 'קריית מלאכי', area: 'דרום'),
    CityData(name: 'קריית שמונה', area: 'דרום'),
    CityData(name: 'קריית ארבע', area: 'דרום'),
    CityData(name: 'קריית ארבע', area: 'דרום'),
    CityData(name: 'קריית שמונה', area: 'דרום'),
    CityData(name: 'קריית גת', area: 'דרום'),
    CityData(name: 'קריית מלאכי', area: 'דרום'),
    CityData(name: 'אופקים', area: 'דרום'),
    CityData(name: 'נתיבות', area: 'דרום'),
    CityData(name: 'דימונה', area: 'דרום'),
    CityData(name: 'אילת', area: 'דרום'),
    CityData(name: 'אשקלון', area: 'דרום'),
    CityData(name: 'אשדוד', area: 'דרום'),
    CityData(name: 'באר שבע', area: 'דרום'),
    CityData(name: 'קריית גת', area: 'דרום'),
    CityData(name: 'קריית מלאכי', area: 'דרום'),
    CityData(name: 'אופקים', area: 'דרום'),
    CityData(name: 'נתיבות', area: 'דרום'),
    CityData(name: 'דימונה', area: 'דרום'),
    CityData(name: 'אילת', area: 'דרום'),
    CityData(name: 'אשקלון', area: 'דרום'),
    CityData(name: 'אשדוד', area: 'דרום'),
    CityData(name: 'באר שבע', area: 'דרום'),

    // יהודה ושומרון (Judea and Samaria)
    CityData(name: 'אריאל', area: 'יהודה ושומרון'),
    CityData(name: 'מעלה אדומים', area: 'יהודה ושומרון'),
    CityData(name: 'קריית ארבע', area: 'יהודה ושומרון'),
    CityData(name: 'ביתר עילית', area: 'יהודה ושומרון'),
    CityData(name: 'מעלה אדומים', area: 'יהודה ושומרון'),
    CityData(name: 'קריית ארבע', area: 'יהודה ושומרון'),
    CityData(name: 'ביתר עילית', area: 'יהודה ושומרון'),
    CityData(name: 'אריאל', area: 'יהודה ושומרון'),
    CityData(name: 'מעלה אדומים', area: 'יהודה ושומרון'),
    CityData(name: 'קריית ארבע', area: 'יהודה ושומרון'),
    CityData(name: 'ביתר עילית', area: 'יהודה ושומרון'),
    CityData(name: 'אריאל', area: 'יהודה ושומרון'),
  ];

  /// Get cities for a specific country (future extensibility)
  static List<String> getCitiesByCountry(Country country) {
    return _allCities
        .where((city) => city.country == country)
        .map((city) => city.name)
        .toList()
      ..sort();
  }
}





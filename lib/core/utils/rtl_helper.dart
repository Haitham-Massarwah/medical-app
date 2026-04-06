import 'package:flutter/material.dart';
import '../../services/language_service.dart';

/// PD-08: Helper for RTL/LTR language-aware UI
/// Ensures fields and UI elements are positioned according to selected language
class RTLHelper {
  /// Get text direction based on current locale
  static Future<TextDirection> getTextDirection() async {
    final locale = await LanguageService.getCurrentLocale();
    return _isRTL(locale) ? TextDirection.rtl : TextDirection.ltr;
  }

  /// Get text direction synchronously from locale
  static TextDirection getTextDirectionFromLocale(Locale locale) {
    return _isRTL(locale) ? TextDirection.rtl : TextDirection.ltr;
  }

  /// Check if locale is RTL
  static bool _isRTL(Locale locale) {
    const rtlLanguages = ['he', 'ar', 'fa', 'ur'];
    return rtlLanguages.contains(locale.languageCode);
  }

  /// Wrap widget with Directionality based on current locale
  static Widget wrapWithDirectionality(BuildContext context, Widget child) {
    final locale = Localizations.localeOf(context);
    return Directionality(
      textDirection: getTextDirectionFromLocale(locale),
      child: child,
    );
  }
}

/// PD-08: RTL/LTR-aware wrapper widget
class RTLWrapper extends StatelessWidget {
  final Widget child;

  const RTLWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context);
    final isRTL = RTLHelper.getTextDirectionFromLocale(locale) == TextDirection.rtl;
    
    return Directionality(
      textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
      child: child,
    );
  }
}





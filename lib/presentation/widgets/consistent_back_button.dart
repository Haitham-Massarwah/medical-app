import 'package:flutter/material.dart';
import '../../core/localization/app_localizations.dart';

/// PD-08: Consistent Back Button Placement
/// Respects RTL/LTR languages - Back button on right for RTL, left for LTR
class ConsistentBackButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Color? color;

  const ConsistentBackButton({
    super.key,
    this.onPressed,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    // Get current locale to determine text direction
    final locale = Localizations.localeOf(context);
    final isRTL = _isRTL(locale);

    // PD-08: Back button placement based on language direction
    // RTL → right side, LTR → left side
    return IconButton(
      icon: Icon(
        isRTL ? Icons.arrow_forward : Icons.arrow_back,
        color: color ?? Theme.of(context).iconTheme.color,
      ),
      onPressed: onPressed ?? () => Navigator.of(context).pop(),
      tooltip: MaterialLocalizations.of(context).backButtonTooltip,
    );
  }

  /// Determine if locale is RTL
  bool _isRTL(Locale locale) {
    // RTL languages
    const rtlLanguages = ['he', 'ar', 'fa', 'ur'];
    return rtlLanguages.contains(locale.languageCode);
  }
}

/// PD-08: Helper to get consistent AppBar with back button
class ConsistentAppBar extends AppBar {
  ConsistentAppBar({
    super.key,
    required super.title,
    super.backgroundColor,
    super.foregroundColor,
    super.actions,
    VoidCallback? onBackPressed,
    BuildContext? context,
  }) : super(
          leading: context != null
              ? ConsistentBackButton(
                  onPressed: onBackPressed,
                  color: foregroundColor,
                )
              : null,
        );
}





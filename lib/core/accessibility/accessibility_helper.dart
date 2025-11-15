import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';

class AccessibilityHelper {
  // Check if high contrast is needed
  static bool isHighContrastNeeded(BuildContext context) {
    return MediaQuery.of(context).platformBrightness == Brightness.dark;
  }
  
  // Get accessible color based on background
  static Color getAccessibleTextColor(Color backgroundColor) {
    // Calculate luminance
    final luminance = backgroundColor.computeLuminance();
    
    // Return black or white based on WCAG contrast requirements
    return luminance > 0.5 ? Colors.black : Colors.white;
  }
  
  // Wrap widget with semantics
  static Widget wrapWithSemantics({
    required Widget child,
    required String label,
    String? hint,
    bool? button,
    bool? header,
    VoidCallback? onTap,
  }) {
    return Semantics(
      label: label,
      hint: hint,
      button: button ?? false,
      header: header ?? false,
      onTap: onTap,
      child: child,
    );
  }
  
  // Announce message to screen reader
  static void announce(BuildContext context, String message) {
    SemanticsService.announce(message, TextDirection.rtl);
  }
  
  // Focus management
  static void requestFocus(BuildContext context, FocusNode node) {
    FocusScope.of(context).requestFocus(node);
  }
  
  // Check contrast ratio (WCAG AA requires 4.5:1 for normal text)
  static bool meetsContrastRequirements(Color foreground, Color background) {
    final ratio = _calculateContrastRatio(foreground, background);
    return ratio >= 4.5;
  }
  
  static double _calculateContrastRatio(Color color1, Color color2) {
    final lum1 = color1.computeLuminance();
    final lum2 = color2.computeLuminance();
    final lighter = lum1 > lum2 ? lum1 : lum2;
    final darker = lum1 > lum2 ? lum2 : lum1;
    return (lighter + 0.05) / (darker + 0.05);
  }
  
  // Get minimum touch target size (44x44 per WCAG)
  static const double minTouchTargetSize = 44.0;
  
  // Ensure widget is at least minimum size
  static Widget ensureMinimumTouchTarget({
    required Widget child,
    double? width,
    double? height,
  }) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        minWidth: width ?? minTouchTargetSize,
        minHeight: height ?? minTouchTargetSize,
      ),
      child: child,
    );
  }
}

// Accessible Button Widget
class AccessibleButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final Color? backgroundColor;
  final Color? textColor;
  final IconData? icon;

  const AccessibleButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.backgroundColor,
    this.textColor,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = backgroundColor ?? Theme.of(context).primaryColor;
    final fgColor = textColor ?? AccessibilityHelper.getAccessibleTextColor(bgColor);

    return Semantics(
      label: label,
      button: true,
      enabled: true,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: bgColor,
          foregroundColor: fgColor,
          minimumSize: const Size(
            AccessibilityHelper.minTouchTargetSize,
            AccessibilityHelper.minTouchTargetSize,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        child: icon != null
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon),
                  const SizedBox(width: 8),
                  Text(label),
                ],
              )
            : Text(label),
      ),
    );
  }
}

// Accessible Form Field
class AccessibleFormField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final bool obscureText;
  final IconData? prefixIcon;

  const AccessibleFormField({
    super.key,
    required this.label,
    required this.hint,
    this.controller,
    this.validator,
    this.keyboardType,
    this.obscureText = false,
    this.prefixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: label,
      hint: hint,
      textField: true,
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
          border: const OutlineInputBorder(),
          errorMaxLines: 3,
          helperMaxLines: 3,
        ),
        validator: validator,
      ),
    );
  }
}










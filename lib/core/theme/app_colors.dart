import 'package:flutter/material.dart';

/// New Design System Colors
class AppColors {
  // Primary Colors - Dark Teal
  static const primaryDark = Color(0xFF004d66);
  static const primaryMedium = Color(0xFF006B8F);
  static const primaryLight = Color(0xFF3B609C);
  
  // Accent Colors - Cyan/Teal
  static const accentCyan = Color(0xFF20B2AA);
  static const accentTeal = Color(0xFF00C6FB);
  static const accentPurple = Color(0xFF6A5ACD);
  
  // Background Colors
  static const backgroundLight = Color(0xFFF8F9FA);
  static const backgroundWhite = Color(0xFFFFFFFF);
  static const cardBackground = Color(0xFFFFFFFF);
  
  // Text Colors
  static const textPrimary = Color(0xFF1A2B48);
  static const textSecondary = Color(0xFF6C757D);
  static const textWhite = Color(0xFFFFFFFF);
  
  // Status Colors
  static const statusConfirmed = Color(0xFF28A745);
  static const statusPending = Color(0xFFFFA500);
  static const statusCancelled = Color(0xFFDC3545);
  
  // Gradient for buttons and cards
  static const tealGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accentTeal, accentCyan],
  );
  
  static const purpleGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF667EEA), accentPurple],
  );
}





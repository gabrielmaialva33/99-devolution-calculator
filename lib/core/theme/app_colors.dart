import 'package:flutter/material.dart';

class AppColors {
  // Modern 2025 Color Palette - Dark Mode with Vibrant Accents
  
  // Primary Colors - Deep Purple Gradient
  static const Color primaryDark = Color(0xFF1A1B3A);
  static const Color primaryMedium = Color(0xFF2D2F5F);
  static const Color primaryLight = Color(0xFF4A4E9B);
  
  // Accent Colors - Vibrant Neon
  static const Color accentPrimary = Color(0xFF00D4FF);  // Cyan Blue
  static const Color accentSecondary = Color(0xFF7B2FFF); // Electric Purple
  static const Color accentTertiary = Color(0xFFFF00F5);  // Magenta
  
  // Success/Error/Warning - Modern Palette
  static const Color success = Color(0xFF00FF94);        // Neon Green
  static const Color error = Color(0xFFFF3B5C);          // Vibrant Red
  static const Color warning = Color(0xFFFFB800);        // Golden Yellow
  static const Color info = Color(0xFF00B4D8);           // Info Blue
  
  // Background Colors - Dark Theme
  static const Color backgroundDark = Color(0xFF0F1014);
  static const Color backgroundCard = Color(0xFF1A1B21);
  static const Color backgroundElevated = Color(0xFF25262E);
  
  // Glass Effect Colors
  static const Color glassSurface = Color(0x1AFFFFFF);
  static const Color glassBorder = Color(0x33FFFFFF);
  
  // Text Colors
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB8BCC8);
  static const Color textMuted = Color(0xFF6C7293);
  
  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accentPrimary, accentSecondary],
  );
  
  static const LinearGradient darkGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [primaryDark, backgroundDark],
  );
  
  static const LinearGradient glassGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0x1AFFFFFF),
      Color(0x0DFFFFFF),
    ],
  );
  
  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accentPrimary, accentTertiary],
  );
}
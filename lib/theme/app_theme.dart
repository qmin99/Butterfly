import 'package:flutter/material.dart';

class AppTheme {
  // Core Colors - Modern & Futuristic
  static const Color backgroundColor = Color(0xFFF5F5F7);
  static const Color surfaceColor = Color(0xFFFFFFFF);
  static const Color primaryColor = Color(0xFF3B82F6);
  static const Color accentColor = Color(0xFFE5E7EB);
  static const Color textPrimary = Color(0xFF1A1A2E);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textMuted = Color(0xFF9CA3AF);
  
  // Gradient Colors
  static const List<Color> primaryGradient = [
    Color(0xFF3B82F6),
    Color(0xFF8B5CF6),
  ];
  
  static const List<Color> surfaceGradient = [
    Color(0xFFFFFFFF),
    Color(0xFFF9FAFB),
  ];
  
  static const List<Color> backgroundGradient = [
    Color(0xFFF5F5F7),
    Color(0xFFE5E7EB),
  ];

  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      fontFamily: 'SF Pro Display',
      scaffoldBackgroundColor: backgroundColor,
      
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 48,
          fontWeight: FontWeight.w100,
          color: textPrimary,
          letterSpacing: 2,
          height: 1.1,
        ),
        displayMedium: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w200,
          color: textPrimary,
          letterSpacing: 1,
          height: 1.2,
        ),
        displaySmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w300,
          color: textPrimary,
          letterSpacing: 0.5,
          height: 1.3,
        ),
        headlineLarge: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w400,
          color: textPrimary,
          height: 1.4,
        ),
        headlineMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: textSecondary,
          height: 1.4,
        ),
        bodyLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: textSecondary,
          height: 1.5,
        ),
        bodyMedium: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: textMuted,
          height: 1.5,
        ),
      ),
      
      colorScheme: const ColorScheme.light(
        primary: primaryColor,
        secondary: Color(0xFF8B5CF6),
        surface: surfaceColor,
        background: backgroundColor,
        onPrimary: textPrimary,
        onSecondary: textPrimary,
        onSurface: textPrimary,
        onBackground: textPrimary,
      ),
    );
  }

  // Custom Decorations for the new theme
  static BoxDecoration get glassContainer => BoxDecoration(
    color: surfaceColor.withOpacity(0.8),
    borderRadius: BorderRadius.circular(16),
    border: Border.all(
      color: Colors.black.withOpacity(0.05),
      width: 1,
    ),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.05),
        blurRadius: 20,
        offset: const Offset(0, 8),
      ),
    ],
  );

  static BoxDecoration get neuralContainer => BoxDecoration(
    color: surfaceColor,
    borderRadius: BorderRadius.circular(20),
    border: Border.all(
      color: primaryColor.withOpacity(0.1),
      width: 1,
    ),
    boxShadow: [
      BoxShadow(
        color: primaryColor.withOpacity(0.1),
        blurRadius: 24,
        offset: const Offset(0, 12),
      ),
    ],
  );

  static BoxDecoration get primaryButton => BoxDecoration(
    gradient: const LinearGradient(
      colors: primaryGradient,
    ),
    borderRadius: BorderRadius.circular(12),
    boxShadow: [
      BoxShadow(
        color: primaryColor.withOpacity(0.3),
        blurRadius: 16,
        offset: const Offset(0, 8),
      ),
    ],
  );

  // Animation Curves
  static const Curve primaryCurve = Curves.easeInOutCubic;
  static const Curve entranceCurve = Curves.easeOutExpo;
  static const Curve exitCurve = Curves.easeInExpo;
  
  // Durations
  static const Duration fastDuration = Duration(milliseconds: 200);
  static const Duration mediumDuration = Duration(milliseconds: 400);
  static const Duration slowDuration = Duration(milliseconds: 800);
}
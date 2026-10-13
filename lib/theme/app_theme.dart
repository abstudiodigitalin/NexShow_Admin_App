import 'package:flutter/material.dart';

/// NexShow Admin's black / neon pink / neon purple theme, matching the
/// NexShow brand.
class AppTheme {
  AppTheme._();

  static const Color background = Color(0xFF000000);
  static const Color surface = Color(0xFF121014);
  static const Color neonPink = Color(0xFFFF2E9A);
  static const Color neonPurple = Color(0xFF9B30FF);

  static const LinearGradient glowGradient = LinearGradient(
    colors: [neonPink, neonPurple],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static ThemeData get dark {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      colorScheme: const ColorScheme.dark(
        primary: neonPurple,
        secondary: neonPink,
        surface: surface,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: neonPurple,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }
}

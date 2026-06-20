import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  AppTheme._();

  // Weather condition gradient palettes
  static const Map<String, List<Color>> weatherGradients = {
    'clear': [Color(0xFFFF8C00), Color(0xFFFFD700)],
    'clouds': [Color(0xFF607D8B), Color(0xFF90A4AE)],
    'rain': [Color(0xFF1565C0), Color(0xFF42A5F5)],
    'drizzle': [Color(0xFF0288D1), Color(0xFF81D4FA)],
    'thunderstorm': [Color(0xFF1A237E), Color(0xFF512DA8)],
    'snow': [Color(0xFFB0BEC5), Color(0xFFECEFF1)],
    'mist': [Color(0xFF546E7A), Color(0xFFB0BEC5)],
    'default': [Color(0xFF1976D2), Color(0xFF64B5F6)],
  };

  static List<Color> getGradientForCondition(String condition) {
    final key = condition.toLowerCase();
    return weatherGradients[key] ?? weatherGradients['default']!;
  }

  static ThemeData get lightTheme => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1976D2),
          brightness: Brightness.light,
        ),
        textTheme: GoogleFonts.nunitoTextTheme(),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          foregroundColor: Colors.white,
        ),
        cardTheme: CardTheme(
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      );

  static ThemeData get darkTheme => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1976D2),
          brightness: Brightness.dark,
        ),
        textTheme: GoogleFonts.nunitoTextTheme(
          ThemeData(brightness: Brightness.dark).textTheme,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          foregroundColor: Colors.white,
        ),
        cardTheme: CardTheme(
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      );
}

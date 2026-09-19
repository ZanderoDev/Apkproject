import 'package:flutter/material.dart';

class AppTheme {
  static const crimson = Color(0xFFC6283D);
  static const crimsonDark = Color(0xFF991D30);
  static const softGray = Color(0xFFF5F6F8);
  static const text = Color(0xFF24252B);
  static const muted = Color(0xFF747984);

  static ThemeData get light {
    final scheme = ColorScheme.fromSeed(
      seedColor: crimson,
      primary: crimson,
      surface: Colors.white,
      brightness: Brightness.light,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: softGray,
      fontFamily: 'sans',
      appBarTheme: const AppBarTheme(
        backgroundColor: softGray,
        foregroundColor: text,
        elevation: 0,
        centerTitle: false,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: crimson, width: 1.5),
        ),
      ),
      cardTheme: CardTheme(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: crimson,
        foregroundColor: Colors.white,
      ),
    );
  }
}

import 'package:flutter/material.dart';

final ThemeData medicineAppTheme = ThemeData(
  brightness: Brightness.light,
  scaffoldBackgroundColor: const Color(0xFFF5F5F5),
  primaryColor: const Color(0xFF2196F3),
  primaryColorLight: const Color(0xFF64B5F6),
  primaryColorDark: const Color(0xFF1976D2),
  colorScheme: ColorScheme.fromSwatch().copyWith(
    primary: const Color(0xFF2196F3),
    secondary: const Color(0xFF4CAF50),
    surface: const Color(0xFFF5F5F5),
    error: const Color(0xFFEF5350),
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.white,
    elevation: 1,
    foregroundColor: Colors.black,
    titleTextStyle: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.bold,
      color: Colors.black,
    ),
  ),
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: Colors.white,
    selectedItemColor: Color(0xFF4CAF50),
    unselectedItemColor: Color(0xFFBDBDBD),
    elevation: 8,
    type: BottomNavigationBarType.fixed,
  ),
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: Color(0xFF2196F3),
    foregroundColor: Colors.white,
    elevation: 4,
  ),
  cardTheme: CardThemeData(
    elevation: 3,
    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    color: Colors.white,
    shadowColor: Colors.grey[300],
  ),
  textTheme: const TextTheme(
    titleLarge: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
    titleMedium: TextStyle(fontSize: 16.0, color: Colors.black87),
    bodyMedium: TextStyle(fontSize: 14.0, color: Colors.black54),
  ),
);


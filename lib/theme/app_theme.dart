import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Light theme
final ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: const Color(0xFF6C63FF),
  scaffoldBackgroundColor: const Color(0xFFF7F7F7),
  appBarTheme: const AppBarTheme(
    iconTheme: IconThemeData(color: Colors.white),
    backgroundColor: Color(0xFF6C63FF),
    titleTextStyle: TextStyle(
      color: Colors.white,
      fontSize: 20,
      fontWeight: FontWeight.bold,
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFF6C63FF),
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
    ),
  ),
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: Color(0xFF6C63FF),
  ),
  fontFamily: GoogleFonts.montserrat().fontFamily,
  textTheme: const TextTheme(
    titleLarge: TextStyle(color: Color(0xFF333333), fontSize: 32),
    titleMedium: TextStyle(color: Color(0xFF333333), fontSize: 24),
    titleSmall: TextStyle(color: Color(0xFF333333), fontSize: 20),
    bodyMedium: TextStyle(color: Color(0xFF333333), fontSize: 16),
    bodySmall: TextStyle(color: Color(0xFF333333), fontSize: 14),
  ),
  cardColor: const Color(0xFFCFCFCF),
  iconTheme: const IconThemeData(color: Color(0xFF6C63FF)),
);

/// Dark theme
final ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: const Color(0xFF6C63FF),
  scaffoldBackgroundColor: const Color(0xFF1C1C1C),
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFF6C63FF),
    titleTextStyle: TextStyle(
      color: Colors.white,
      fontSize: 20,
      fontWeight: FontWeight.bold,
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFF6C63FF),
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
    ),
  ),
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: Color(0xFF6C63FF),
  ),
  fontFamily: GoogleFonts.montserrat().fontFamily,
  textTheme: const TextTheme(
    titleLarge: TextStyle(color: Color(0xFFEAEAEA), fontSize: 32),
    titleMedium: TextStyle(color: Color(0xFFEAEAEA), fontSize: 24),
    titleSmall: TextStyle(color: Color(0xFFEAEAEA), fontSize: 20),
    bodyMedium: TextStyle(color: Color(0xFFEAEAEA), fontSize: 16),
    bodySmall: TextStyle(color: Color(0xFFEAEAEA), fontSize: 14),
  ),
  cardColor: const Color(0xFF2D2D2D),
  iconTheme: const IconThemeData(
    color: Color(0xFF6C63FF),
  ),
);

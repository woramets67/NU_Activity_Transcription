import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// สีและฟอนต์
const Color kOrange = Color(0xFFEE7424);
const Color kDark = Color(0xFF1C1C20);
const Color kBackground = Color(0xFFF6F5F2);
const Color kGrey = Color(0xFF6E6E76);
const Color kGreen = Color(0xFF1F9D55);
const Color kRed = Color(0xFFD64545);

ThemeData appTheme() {
  return ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(seedColor: kOrange, primary: kDark),
    scaffoldBackgroundColor: kBackground,
    textTheme: GoogleFonts.anuphanTextTheme(),
    appBarTheme: const AppBarTheme(
      backgroundColor: kBackground,
      foregroundColor: kDark,
      elevation: 0,
      scrolledUnderElevation: 0,
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(52),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(52)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    ),
  );
}

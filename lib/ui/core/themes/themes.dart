import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RoseBlushColors {
  // static const Color primary = Color(0xFFD8A7B1);
  static const Color primary = Color(0xFF8E4A58);
  static const Color secondary = Color(0xFFB5838D);
  static const Color background = Color(0xFFFFF1F3);
  static const Color surface = Color(0xFFFFE5EC);
  static const Color error = Color(0xFFB00020);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color onBackground = Color(0xFF1F1F1F);
  static const Color onSurface = Color(0xFF1F1F1F);
  static const Color onError = Color(0xFFFFFFFF);

  static const Color border = Color(0xFFB5838D);
  static const Color focusedBorder = Color(0xFF8E4A58);
  static const Color errorBorder = Color(0xFFB00020);
  static const Color focusedErrorBorder = Color(0xFFCF6679);
}

final ThemeData roseBlushTheme = ThemeData(
  colorScheme: const ColorScheme(
    brightness: Brightness.light,
    primary: RoseBlushColors.primary,
    onPrimary: RoseBlushColors.onPrimary,
    secondary: RoseBlushColors.secondary,
    onSecondary: RoseBlushColors.onSecondary,
    surface: RoseBlushColors.surface,
    onSurface: RoseBlushColors.onSurface,
    error: RoseBlushColors.error,
    onError: RoseBlushColors.onError,
  ),

  scaffoldBackgroundColor: RoseBlushColors.background,

  fontFamily: GoogleFonts.poppins().fontFamily,

  appBarTheme: const AppBarTheme(
    backgroundColor: RoseBlushColors.primary,
    foregroundColor: RoseBlushColors.onPrimary,
    elevation: 4,
    centerTitle: true,
  ),

  cardTheme: const CardTheme(
    color: RoseBlushColors.surface,
    elevation: 4,
    margin: EdgeInsets.all(12),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(12)),
    ),
  ),

  textTheme: const TextTheme(
    displayLarge: TextStyle(
      fontSize: 57,
      fontWeight: FontWeight.bold,
      color: RoseBlushColors.onBackground,
    ),
    displayMedium: TextStyle(
      fontSize: 45,
      fontWeight: FontWeight.bold,
      color: RoseBlushColors.onBackground,
    ),
    displaySmall: TextStyle(
      fontSize: 36,
      fontWeight: FontWeight.bold,
      color: RoseBlushColors.onBackground,
    ),

    headlineLarge: TextStyle(
      fontSize: 32,
      fontWeight: FontWeight.w700,
      color: RoseBlushColors.onBackground,
    ),
    headlineMedium: TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.w700,
      color: RoseBlushColors.onBackground,
    ),
    headlineSmall: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.w600,
      color: RoseBlushColors.onBackground,
    ),

    titleLarge: TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.w600,
      color: RoseBlushColors.onBackground,
    ),
    titleMedium: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      color: RoseBlushColors.onBackground,
    ),
    titleSmall: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: RoseBlushColors.onBackground,
    ),

    bodyLarge: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.normal,
      color: RoseBlushColors.onBackground,
    ),
    bodyMedium: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.normal,
      color: RoseBlushColors.onBackground,
    ),
    bodySmall: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.normal,
      color: RoseBlushColors.onBackground,
    ),

    labelLarge: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: RoseBlushColors.primary,
    ),
    labelMedium: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      color: RoseBlushColors.secondary,
    ),
    labelSmall: TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w400,
      color: RoseBlushColors.secondary,
    ),
  ),

  inputDecorationTheme: InputDecorationTheme(
    border: OutlineInputBorder(
      borderSide: const BorderSide(color: RoseBlushColors.border),
      borderRadius: BorderRadius.circular(12),
    ),
    enabledBorder: OutlineInputBorder(
      borderSide: const BorderSide(color: RoseBlushColors.border),
      borderRadius: BorderRadius.circular(12),
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: const BorderSide(
        color: RoseBlushColors.focusedBorder,
        width: 2,
      ),
      borderRadius: BorderRadius.circular(12),
    ),
    errorBorder: OutlineInputBorder(
      borderSide: const BorderSide(color: RoseBlushColors.errorBorder),
      borderRadius: BorderRadius.circular(12),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderSide: const BorderSide(
        color: RoseBlushColors.focusedErrorBorder,
        width: 2,
      ),
      borderRadius: BorderRadius.circular(12),
    ),
    floatingLabelStyle: const TextStyle(
      color: RoseBlushColors.focusedBorder,
      fontWeight: FontWeight.w600,
    ),
  ),

  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: RoseBlushColors.primary,
      foregroundColor: RoseBlushColors.onPrimary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
    ),
  ),

  filledButtonTheme: FilledButtonThemeData(
    style: FilledButton.styleFrom(
      backgroundColor: RoseBlushColors.primary,
      foregroundColor: RoseBlushColors.onPrimary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
    ),
  ),

  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: RoseBlushColors.secondary,
      textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
    ),
  ),
);

final ThemeData roseBlushDarkTheme = ThemeData(
  brightness: Brightness.dark,

  colorScheme: const ColorScheme(
    brightness: Brightness.dark,
    primary: RoseBlushColors.primary,
    onPrimary: RoseBlushColors.onPrimary,
    secondary: RoseBlushColors.secondary,
    onSecondary: RoseBlushColors.onSecondary,
    surface: Color(0xFF1E1E1E),
    onSurface: Colors.white,
    error: RoseBlushColors.error,
    onError: RoseBlushColors.onError,
  ),

  scaffoldBackgroundColor: const Color(0xFF121212),

  appBarTheme: const AppBarTheme(
    backgroundColor: RoseBlushColors.primary,
    foregroundColor: RoseBlushColors.onPrimary,
    elevation: 4,
    centerTitle: true,
  ),

  cardTheme: const CardTheme(
    color: Color(0xFF1E1E1E),
    elevation: 4,
    margin: EdgeInsets.all(12),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(12)),
    ),
  ),

  textTheme: const TextTheme(
    displayLarge: TextStyle(
      fontSize: 57,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    ),
    displayMedium: TextStyle(
      fontSize: 45,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    ),
    displaySmall: TextStyle(
      fontSize: 36,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    ),

    headlineLarge: TextStyle(
      fontSize: 32,
      fontWeight: FontWeight.w700,
      color: Colors.white,
    ),
    headlineMedium: TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.w700,
      color: Colors.white,
    ),
    headlineSmall: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.w600,
      color: Colors.white,
    ),

    titleLarge: TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.w600,
      color: Colors.white,
    ),
    titleMedium: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      color: Colors.white,
    ),
    titleSmall: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: Colors.white70,
    ),

    bodyLarge: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.normal,
      color: Colors.white,
    ),
    bodyMedium: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.normal,
      color: Colors.white70,
    ),
    bodySmall: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.normal,
      color: Colors.white60,
    ),

    labelLarge: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: RoseBlushColors.primary,
    ),
    labelMedium: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      color: RoseBlushColors.secondary,
    ),
    labelSmall: TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w400,
      color: RoseBlushColors.secondary,
    ),
  ),

  inputDecorationTheme: InputDecorationTheme(
    border: OutlineInputBorder(
      borderSide: const BorderSide(color: RoseBlushColors.border),
      borderRadius: BorderRadius.circular(12),
    ),
    enabledBorder: OutlineInputBorder(
      borderSide: const BorderSide(color: RoseBlushColors.border),
      borderRadius: BorderRadius.circular(12),
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: const BorderSide(
        color: RoseBlushColors.focusedBorder,
        width: 2,
      ),
      borderRadius: BorderRadius.circular(12),
    ),
    errorBorder: OutlineInputBorder(
      borderSide: const BorderSide(color: RoseBlushColors.errorBorder),
      borderRadius: BorderRadius.circular(12),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderSide: const BorderSide(
        color: RoseBlushColors.focusedErrorBorder,
        width: 2,
      ),
      borderRadius: BorderRadius.circular(12),
    ),
    floatingLabelStyle: const TextStyle(
      color: RoseBlushColors.focusedBorder,
      fontWeight: FontWeight.w600,
    ),
  ),

  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: RoseBlushColors.primary,
      foregroundColor: RoseBlushColors.onPrimary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
    ),
  ),

  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: RoseBlushColors.secondary,
      textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
    ),
  ),
);

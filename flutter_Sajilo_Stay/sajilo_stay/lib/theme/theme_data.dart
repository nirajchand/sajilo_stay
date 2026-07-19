import 'package:flutter/material.dart';
import 'package:sajilo_stay/core/constants/colors.dart';

ThemeData getApplicationDarkTheme() {
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: kBackgroundColor,
    primaryColor: kPrimaryColor,
    colorScheme: const ColorScheme.dark(
      primary: kPrimaryDimColor,
      onPrimary: kPrimaryColor,
      secondary: kSecondaryColor,
      onSecondary: kPrimaryColor,
      tertiary: kAccentColor,
      onTertiary: Colors.white,
      surface: kSurfaceLevel1,
      onSurface: Color(0xFFE3E2E2),
      error: kError,
      onError: Colors.white,
    ),
    fontFamily: 'Plus Jakarta Sans',
    textTheme: const TextTheme(
      // headline-xl (32px, Bold)
      displayLarge: TextStyle(
        fontFamily: 'Plus Jakarta Sans',
        fontSize: 32.0,
        fontWeight: FontWeight.w700,
        height: 1.2,
        letterSpacing: -0.64, // -0.02em
        color: kSecondaryColor,
      ),
      // headline-lg (24px, Bold)
      headlineLarge: TextStyle(
        fontFamily: 'Plus Jakarta Sans',
        fontSize: 24.0,
        fontWeight: FontWeight.w700,
        height: 1.3,
        color: kSecondaryColor,
      ),
      // headline-md (20px, SemiBold)
      headlineMedium: TextStyle(
        fontFamily: 'Plus Jakarta Sans',
        fontSize: 20.0,
        fontWeight: FontWeight.w600,
        height: 1.4,
        color: kSecondaryColor,
      ),
      // body-lg (16px, Regular)
      bodyLarge: TextStyle(
        fontFamily: 'Plus Jakarta Sans',
        fontSize: 16.0,
        fontWeight: FontWeight.w400,
        height: 1.6,
        color: Color(0xFFE3E2E2),
      ),
      // body-md (14px, Regular)
      bodyMedium: TextStyle(
        fontFamily: 'Plus Jakarta Sans',
        fontSize: 14.0,
        fontWeight: FontWeight.w400,
        height: 1.5,
        color: Color(0xFFC3C8C3),
      ),
      // label-lg (14px, SemiBold)
      labelLarge: TextStyle(
        fontFamily: 'Plus Jakarta Sans',
        fontSize: 14.0,
        fontWeight: FontWeight.w600,
        height: 1.2,
        color: kSecondaryColor,
      ),
      // label-sm (12px, Medium)
      labelSmall: TextStyle(
        fontFamily: 'Plus Jakarta Sans',
        fontSize: 12.0,
        fontWeight: FontWeight.w500,
        height: 1.2,
        color: kNeutralColor,
      ),
    ),
    cardTheme: CardThemeData(
      color: kSurfaceLevel1,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24.0), // radius-xl
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: kSecondaryColor,
        foregroundColor: kPrimaryColor,
        textStyle: const TextStyle(
          fontFamily: 'Plus Jakarta Sans',
          fontSize: 14.0,
          fontWeight: FontWeight.w600,
        ),
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0), // radius-lg
        ),
        elevation: 0,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: kSecondaryColor,
        side: const BorderSide(color: kNeutralColor, width: 1.0),
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: kSurfaceLevel1,
      hintStyle: const TextStyle(
        fontFamily: 'Plus Jakarta Sans',
        fontSize: 14.0,
        color: kNeutralColor,
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16.0),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16.0),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16.0),
        borderSide: const BorderSide(color: kPrimaryDimColor, width: 1.0),
      ),
    ),
  );
}

ThemeData getApplicationLightTheme() {
  // A fallback light theme that inherits basic characteristics
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: const Color(0xFFF9F9F9),
    primaryColor: const Color(0xFF0D9488),
    fontFamily: 'Plus Jakarta Sans',
    colorScheme: const ColorScheme.light(
      primary: Color(0xFF0D9488),
      secondary: Color(0xFF14B8A6),
      surface: Colors.white,
    ),
  );
}

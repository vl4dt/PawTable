import 'package:flutter/material.dart';
import 'colors.dart';
import 'typography.dart';

/// Light and dark theme definitions for PawTable
class PawThemes {
  PawThemes._();

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: PawTableColors.softOrange,
    scaffoldBackgroundColor: PawTableColors.cream,
    colorScheme: const ColorScheme.light(
      primary: PawTableColors.softOrange,
      secondary: PawTableColors.sageGreen,
      surface: PawTableColors.warmWhite,
      onPrimary: PawTableColors.warmWhite,
      onSecondary: PawTableColors.darkBrown,
      onSurface: PawTableColors.darkBrown,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: PawTableColors.cream,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: PawTypography.h3.copyWith(color: PawTableColors.darkBrown),
      iconTheme: IconThemeData(color: PawTableColors.darkBrown),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: PawTableColors.warmWhite,
      selectedItemColor: PawTableColors.softOrange,
      unselectedItemColor: PawTableColors.lightBrown,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),
    cardTheme: CardThemeData(
      color: PawTableColors.warmWhite,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: PawTableColors.lightGray,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: PawTableColors.softOrange,
        foregroundColor: PawTableColors.warmWhite,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: PawTypography.buttonText,
      ),
    ),
    textTheme: TextTheme(
      displayLarge: PawTypography.h1,
      displayMedium: PawTypography.h2,
      displaySmall: PawTypography.h3,
      bodyLarge: PawTypography.bodyLarge,
      bodyMedium: PawTypography.bodyMedium,
      bodySmall: PawTypography.caption,
    ),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: PawTableColors.vibrantOrange,
    scaffoldBackgroundColor: PawTableColors.darkBackground,
    colorScheme: const ColorScheme.dark(
      primary: PawTableColors.vibrantOrange,
      secondary: PawTableColors.darkGreen,
      surface: PawTableColors.darkSurface,
      onPrimary: PawTableColors.warmWhite,
      onSecondary: PawTableColors.darkBackground,
      onSurface: PawTableColors.warmWhite,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: PawTableColors.darkBackground,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: PawTypography.h3.copyWith(color: PawTableColors.warmWhite),
      iconTheme: IconThemeData(color: PawTableColors.warmWhite),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: PawTableColors.darkSurface,
      selectedItemColor: PawTableColors.vibrantOrange,
      unselectedItemColor: PawTableColors.lightBrown,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),
    cardTheme: CardThemeData(
      color: PawTableColors.darkSurface,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: PawTableColors.darkElevated,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: PawTableColors.vibrantOrange,
        foregroundColor: PawTableColors.warmWhite,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: PawTypography.buttonText,
      ),
    ),
    textTheme: TextTheme(
      displayLarge: PawTypography.h1.copyWith(color: PawTableColors.warmWhite),
      displayMedium: PawTypography.h2.copyWith(color: PawTableColors.warmWhite),
      displaySmall: PawTypography.h3.copyWith(color: PawTableColors.warmWhite),
      bodyLarge: PawTypography.bodyLarge.copyWith(color: PawTableColors.warmWhite),
      bodyMedium: PawTypography.bodyMedium.copyWith(color: PawTableColors.lightBrown),
      bodySmall: PawTypography.caption.copyWith(color: PawTableColors.lightBrown),
    ),
  );
}

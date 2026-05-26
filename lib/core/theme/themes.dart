import 'package:flutter/material.dart';
import 'colors.dart';
import 'typography.dart';
import 'design_tokens.dart';

/// PawTable theme definitions — light and dark mode
///
/// Both themes use the same design tokens (spacing, shadows, radii)
/// but adapt colors for brightness. Typography uses semantic color
/// roles that switch automatically via the theme.
class PawThemes {
  PawThemes._();

  // =========================================================================
  // LIGHT THEME
  // =========================================================================

  static ThemeData get lightTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: PawTableColors.background,
        primaryColor: PawTableColors.primary,
        secondaryHeaderColor: PawTableColors.success,

        // Color scheme — Material 3
        colorScheme: const ColorScheme.light(
          primary: PawTableColors.primary,
          onPrimary: PawTableColors.onPrimary,
          secondary: PawTableColors.success,
          onSecondary: PawTableColors.onSecondary,
          tertiary: PawTableColors.info,
          onTertiary: PawTableColors.onBackground,
          error: PawTableColors.error,
          onError: PawTableColors.onBackground,
          surface: PawTableColors.surface,
          onSurface: PawTableColors.onBackground,
          surfaceContainerHighest: PawTableColors.surfaceVariant,
        ),

        // Typography — Material 3 text styles mapped to our tokens
        textTheme: TextTheme(
          displayLarge: PawTypography.h1,
          displayMedium: PawTypography.h2,
          displaySmall: PawTypography.h3,
          headlineLarge: PawTypography.h1,
          headlineMedium: PawTypography.h2,
          headlineSmall: PawTypography.h3,
          titleLarge: PawTypography.h3,
          titleMedium: PawTypography.bodyLarge,
          titleSmall: PawTypography.caption,
          bodyLarge: PawTypography.bodyLarge,
          bodyMedium: PawTypography.bodyMedium,
          bodySmall: PawTypography.caption,
          labelLarge: PawTypography.buttonText,
          labelSmall: PawTypography.overline,
        ),

        // AppBar
        appBarTheme: AppBarTheme(
          backgroundColor: PawTableColors.background,
          elevation: 0,
          centerTitle: true,
          scrolledUnderElevation: 2,
          surfaceTintColor: Colors.transparent,
          titleTextStyle: PawTypography.h3,
          iconTheme: IconThemeData(color: PawTableColors.onBackground),
        ),

        // Bottom navigation bar
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: PawTableColors.surface,
          selectedItemColor: PawTableColors.primary,
          unselectedItemColor: PawTableColors.onSurfaceMuted,
          type: BottomNavigationBarType.fixed,
          elevation: 8,
          selectedLabelStyle: TextStyle(fontWeight: FontWeight.w600),
        ),

        // Cards
        cardTheme: CardThemeData(
          color: PawTableColors.surface,
          elevation: 2,
          shadowColor: Colors.black.withValues(alpha: 0.05),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(PawTokens.radiusLg),
          ),
        ),

        // Inputs
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: PawTableColors.surfaceVariant,
          contentPadding: const EdgeInsets.symmetric(horizontal: PawTokens.md, vertical: PawTokens.sm),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(PawTokens.radiusMd),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(PawTokens.radiusMd),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(PawTokens.radiusMd),
            borderSide: const BorderSide(color: PawTableColors.primary, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(PawTokens.radiusMd),
            borderSide: const BorderSide(color: PawTableColors.error, width: 2),
          ),
        ),

        // Elevated buttons
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: PawTableColors.primary,
            
            elevation: 2,
            padding: const EdgeInsets.symmetric(horizontal: PawTokens.lg, vertical: PawTokens.md),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(PawTokens.radiusMd),
            ),
            textStyle: PawTypography.buttonText,
            minimumSize: const Size(double.infinity, 48),
          ),
        ),

        // Outlined buttons
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: PawTokens.lg, vertical: PawTokens.md),
            side: const BorderSide(color: PawTableColors.primary, width: 1.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(PawTokens.radiusMd),
            ),
            textStyle: PawTypography.buttonText,
            minimumSize: const Size(double.infinity, 48),
          ),
        ),

        // Text buttons
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: PawTokens.md, vertical: PawTokens.sm),
            textStyle: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),

        // Icon buttons
        iconButtonTheme: IconButtonThemeData(
          style: IconButton.styleFrom(
            
            backgroundColor: Colors.transparent,
            padding: const EdgeInsets.all(PawTokens.sm),
            minimumSize: Size(PawTokens.xl, PawTokens.xl),
          ),
        ),

        // Snackbars
        snackBarTheme: SnackBarThemeData(
          backgroundColor: PawTableColors.onBackground,
          contentTextStyle: PawTypography.bodyMedium,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(PawTokens.radiusMd),
          ),
          behavior: SnackBarBehavior.floating,
        ),

        // Dialogs
        dialogTheme: DialogThemeData(
          backgroundColor: PawTableColors.surface,
          elevation: 2,
          shadowColor: Colors.black.withValues(alpha: 0.1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(PawTokens.radiusLg),
          ),
          titleTextStyle: PawTypography.h3,
          contentTextStyle: PawTypography.bodyMedium,
        ),

        // Chips
        chipTheme: ChipThemeData(
          backgroundColor: PawTableColors.surfaceVariant,
          labelStyle: PawTypography.bodyMedium,
          padding: const EdgeInsets.symmetric(horizontal: PawTokens.sm, vertical: PawTokens.xs),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(PawTokens.radiusFull),
          ),
        ),

        // Switches
        switchTheme: SwitchThemeData(
          thumbColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return PawTableColors.primary;
            }
            return PawTableColors.onSurfaceMuted;
          }),
          trackColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return PawTableColors.primary.withValues(alpha: 0.4);
            }
            return PawTableColors.onSurfaceMuted.withValues(alpha: 0.3);
          }),
        ),

        // Progress indicators
        progressIndicatorTheme: const ProgressIndicatorThemeData(
          color: PawTableColors.primary,
          linearTrackColor: PawTableColors.surfaceVariant,
        ),

        // List tiles
        listTileTheme: ListTileThemeData(
          titleTextStyle: PawTypography.bodyLarge,
          subtitleTextStyle: PawTypography.bodyMedium,
        ),
      );

  // =========================================================================
  // DARK THEME
  // =========================================================================

  static ThemeData get darkTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: PawTableColors.darkBackground,
        primaryColor: PawTableColors.primaryVibrant,
        secondaryHeaderColor: PawTableColors.successDark,

        // Color scheme — Material 3 dark
        colorScheme: const ColorScheme.dark(
          primary: PawTableColors.primaryVibrant,
          onPrimary: PawTableColors.onPrimary,
          secondary: PawTableColors.successDark,
          onSecondary: PawTableColors.darkBackground,
          tertiary: PawTableColors.infoDark,
          onTertiary: PawTableColors.darkBackground,
          error: PawTableColors.error,
          onError: PawTableColors.darkBackground,
          surface: PawTableColors.darkSurface,
          onSurface: PawTableColors.onPrimary,
          surfaceContainerHighest: PawTableColors.darkElevated,
        ),

        // Typography — dark mode overrides
        textTheme: TextTheme(
          displayLarge: PawTypography.darkH1,
          displayMedium: PawTypography.darkH2,
          displaySmall: PawTypography.darkH3,
          headlineLarge: PawTypography.darkH1,
          headlineMedium: PawTypography.darkH2,
          headlineSmall: PawTypography.darkH3,
          titleLarge: PawTypography.darkH3,
          titleMedium: PawTypography.darkBodyLarge,
          titleSmall: PawTypography.darkCaption,
          bodyLarge: PawTypography.darkBodyLarge,
          bodyMedium: PawTypography.darkBodyMedium,
          bodySmall: PawTypography.darkCaption,
          labelLarge: PawTypography.darkButtonText,
          labelSmall: PawTypography.darkOverline,
        ),

        // AppBar
        appBarTheme: AppBarTheme(
          backgroundColor: PawTableColors.darkBackground,
          elevation: 0,
          centerTitle: true,
          scrolledUnderElevation: 2,
          surfaceTintColor: Colors.transparent,
          titleTextStyle: PawTypography.darkH3,
          iconTheme: IconThemeData(color: PawTableColors.onPrimary),
        ),

        // Bottom navigation bar
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: PawTableColors.darkSurface,
          selectedItemColor: PawTableColors.primaryVibrant,
          unselectedItemColor: PawTableColors.onSurfaceMuted,
          type: BottomNavigationBarType.fixed,
          elevation: 8,
          selectedLabelStyle: TextStyle(fontWeight: FontWeight.w600),
        ),

        // Cards
        cardTheme: CardThemeData(
          color: PawTableColors.darkSurface,
          elevation: 2,
          shadowColor: Colors.black.withValues(alpha: 0.2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(PawTokens.radiusLg),
          ),
        ),

        // Inputs
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: PawTableColors.darkElevated,
          contentPadding: const EdgeInsets.symmetric(horizontal: PawTokens.md, vertical: PawTokens.sm),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(PawTokens.radiusMd),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(PawTokens.radiusMd),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(PawTokens.radiusMd),
            borderSide: const BorderSide(color: PawTableColors.primaryVibrant, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(PawTokens.radiusMd),
            borderSide: const BorderSide(color: PawTableColors.error, width: 2),
          ),
        ),

        // Elevated buttons
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: PawTableColors.primaryVibrant,
            
            elevation: 2,
            padding: const EdgeInsets.symmetric(horizontal: PawTokens.lg, vertical: PawTokens.md),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(PawTokens.radiusMd),
            ),
            textStyle: PawTypography.darkButtonText,
            minimumSize: const Size(double.infinity, 48),
          ),
        ),

        // Outlined buttons
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: PawTokens.lg, vertical: PawTokens.md),
            side: const BorderSide(color: PawTableColors.primaryVibrant, width: 1.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(PawTokens.radiusMd),
            ),
            textStyle: PawTypography.darkButtonText,
            minimumSize: const Size(double.infinity, 48),
          ),
        ),

        // Text buttons
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: PawTokens.md, vertical: PawTokens.sm),
            textStyle: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),

        // Icon buttons
        iconButtonTheme: IconButtonThemeData(
          style: IconButton.styleFrom(
            
            backgroundColor: Colors.transparent,
            padding: const EdgeInsets.all(PawTokens.sm),
            minimumSize: Size(PawTokens.xl, PawTokens.xl),
          ),
        ),

        // Snackbars
        snackBarTheme: SnackBarThemeData(
          backgroundColor: PawTableColors.darkElevated,
          contentTextStyle: PawTypography.darkBodyMedium,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(PawTokens.radiusMd),
          ),
          behavior: SnackBarBehavior.floating,
        ),

        // Dialogs
        dialogTheme: DialogThemeData(
          backgroundColor: PawTableColors.darkSurface,
          elevation: 8,
          shadowColor: Colors.black.withValues(alpha: 0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(PawTokens.radiusLg),
          ),
          titleTextStyle: PawTypography.darkH3,
          contentTextStyle: PawTypography.darkBodyMedium,
        ),

        // Chips
        chipTheme: ChipThemeData(
          backgroundColor: PawTableColors.darkElevated,
          labelStyle: PawTypography.darkBodyMedium,
          padding: const EdgeInsets.symmetric(horizontal: PawTokens.sm, vertical: PawTokens.xs),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(PawTokens.radiusFull),
          ),
        ),

        // Switches
        switchTheme: SwitchThemeData(
          thumbColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return PawTableColors.primaryVibrant;
            }
            return PawTableColors.onSurfaceMuted;
          }),
          trackColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return PawTableColors.primaryVibrant.withValues(alpha: 0.4);
            }
            return PawTableColors.onSurfaceMuted.withValues(alpha: 0.3);
          }),
        ),

        // Progress indicators
        progressIndicatorTheme: const ProgressIndicatorThemeData(
          color: PawTableColors.primaryVibrant,
          linearTrackColor: PawTableColors.darkElevated,
        ),

        // List tiles
        listTileTheme: ListTileThemeData(
          titleTextStyle: PawTypography.darkBodyLarge,
          subtitleTextStyle: PawTypography.darkBodyMedium,
        ),
      );
}

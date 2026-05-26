import 'package:flutter/material.dart';

/// PawTable color palette — warm pastels for emotional connection with pet owners
///
/// Based on UX research: warm tones create emotional connection with pet owners.
/// Colors are organized by semantic purpose, not hue.
class PawTableColors {
  PawTableColors._();

  // =========================================================================
  // PRIMARY — Brand identity
  // =========================================================================

  /// Primary action color — warm orange (primary brand)
  static const Color primary = Color(0xFFF4A261);

  /// Darker primary for hover/press states
  static const Color primaryDark = Color(0xFFE76F51);

  /// Vibrant primary for dark mode
  static const Color primaryVibrant = Color(0xFFF68B4A);

  // =========================================================================
  // SECONDARY — Wellness & success
  // =========================================================================

  /// Success / wellness — sage green
  static const Color success = Color(0xFFA8D5BA);

  /// Darker success for text/icons
  static const Color successDark = Color(0xFF52B788);

  // =========================================================================
  // ALERTS — Information states
  // =========================================================================

  /// Info / calm — soft blue
  static const Color info = Color(0xFFB5C9D9);

  /// Darker info
  static const Color infoDark = Color(0xFF85A3C7);

  /// Warning / caution — warm yellow
  static const Color warning = Color(0xFFF8E167);

  /// Error / danger — soft red
  static const Color error = Color(0xFFF2B8B8);

  // =========================================================================
  // PREMIUM — Upsell / AI features
  // =========================================================================

  /// Premium accent — lavender
  static const Color premium = Color(0xFFD4C5E2);

  /// Premium dark
  static const Color premiumDark = Color(0xFF9B8EC4);

  // =========================================================================
  // SURFACES — Backgrounds (light mode)
  // =========================================================================

  /// Main background — warm cream
  static const Color background = Color(0xFFFDF8F0);

  /// Card/surface — warm white
  static const Color surface = Color(0xFFFFFCF7);

  /// Input/field background
  static const Color surfaceVariant = Color(0xFFF5F0EB);

  // =========================================================================
  // SURFACES — Backgrounds (dark mode)
  // =========================================================================

  /// Dark mode main background
  static const Color darkBackground = Color(0xFF1A1D23);

  /// Dark mode card/surface
  static const Color darkSurface = Color(0xFF252830);

  /// Dark mode elevated surface
  static const Color darkElevated = Color(0xFF2F323A);

  // =========================================================================
  // TEXT — Semantic text colors
  // =========================================================================

  /// Primary text — dark brown
  static const Color onBackground = Color(0xFF3D3D3D);

  /// Secondary text — medium brown
  static const Color onSurfaceVariant = Color(0xFF6B6B6B);

  /// Tertiary/hint text — light brown
  static const Color onSurfaceMuted = Color(0xFFA0A0A0);

  /// On-primary text (always white for contrast)
  static const Color onPrimary = Color(0xFFFFFCF7);

  /// On-secondary text
  static const Color onSecondary = Color(0xFF3D3D3D);
}

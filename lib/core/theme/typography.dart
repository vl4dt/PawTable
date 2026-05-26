import 'package:flutter/material.dart';
import 'colors.dart';

/// PawTable typography scale — Poppins for headings, Inter for body
///
/// All text styles use semantic color names that adapt to light/dark mode.
/// Use these in widgets via `Theme.of(context).textTheme`.
class PawTypography {
  PawTypography._();

  // =========================================================================
  // LIGHT MODE TYPOGRAPHY
  // =========================================================================

  /// Display 1 — 32px Bold — App title, hero text
  static const TextStyle h1 = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: PawTableColors.onBackground,
    height: 1.2,
    letterSpacing: -0.5,
  );

  /// Display 2 — 24px SemiBold — Page titles
  static const TextStyle h2 = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: PawTableColors.onBackground,
    height: 1.3,
    letterSpacing: -0.3,
  );

  /// Display 3 — 18px SemiBold — Card titles, section headers
  static const TextStyle h3 = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: PawTableColors.onBackground,
    height: 1.3,
  );

  /// Body Large — 16px Medium — Primary body text
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: 'Inter',
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: PawTableColors.onBackground,
    height: 1.5,
  );

  /// Body Medium — 14px Regular — Secondary body text
  static const TextStyle bodyMedium = TextStyle(
    fontFamily: 'Inter',
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: PawTableColors.onSurfaceVariant,
    height: 1.5,
  );

  /// Caption — 12px Regular — Labels, metadata, timestamps
  static const TextStyle caption = TextStyle(
    fontFamily: 'Inter',
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: PawTableColors.onSurfaceMuted,
    height: 1.4,
  );

  /// Button text — 16px SemiBold
  static const TextStyle buttonText = TextStyle(
    fontFamily: 'Inter',
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: PawTableColors.onPrimary,
    height: 1.4,
  );

  /// Data / numbers — 20px Medium — Stats, counters
  static const TextStyle dataText = TextStyle(
    fontFamily: 'Inter',
    fontSize: 20,
    fontWeight: FontWeight.w500,
    color: PawTableColors.onBackground,
    height: 1.2,
  );

  /// Overline — 11px Medium — Section labels, badges
  static const TextStyle overline = TextStyle(
    fontFamily: 'Inter',
    fontSize: 11,
    fontWeight: FontWeight.w500,
    color: PawTableColors.onSurfaceMuted,
    height: 1.4,
    letterSpacing: 0.8,
  );

  // =========================================================================
  // DARK MODE OVERRIDES
  // =========================================================================

  /// Light typography adapted for dark mode
  static TextStyle darkH1 = h1.copyWith(color: PawTableColors.onPrimary);

  static TextStyle darkH2 = h2.copyWith(color: PawTableColors.onPrimary);

  static TextStyle darkH3 = h3.copyWith(color: PawTableColors.onPrimary);

  static TextStyle darkBodyLarge = bodyLarge.copyWith(color: PawTableColors.onPrimary);

  static TextStyle darkBodyMedium = bodyMedium.copyWith(color: PawTableColors.onSurfaceVariant);

  static TextStyle darkCaption = caption.copyWith(color: PawTableColors.onSurfaceMuted);

  static TextStyle darkButtonText = buttonText.copyWith(color: PawTableColors.onPrimary);

  static TextStyle darkDataText = dataText.copyWith(color: PawTableColors.onPrimary);

  static TextStyle darkOverline = overline.copyWith(color: PawTableColors.onSurfaceMuted);
}

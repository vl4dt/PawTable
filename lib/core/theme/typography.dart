import 'package:flutter/material.dart';
import 'colors.dart';

/// Typography scale using Poppins (headings) and Inter (body)
class PawTypography {
  PawTypography._();

  /// Headings — Poppins Bold
  static const TextStyle h1 = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: PawTableColors.darkBrown,
    height: 1.2,
  );

  /// Subheading — Poppins SemiBold
  static const TextStyle h2 = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: PawTableColors.darkBrown,
    height: 1.3,
  );

  /// Card title — Poppins SemiBold
  static const TextStyle h3 = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: PawTableColors.darkBrown,
    height: 1.3,
  );

  /// Body text — Inter Medium
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: 'Inter',
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: PawTableColors.darkBrown,
    height: 1.5,
  );

  /// Body text — Inter Regular
  static const TextStyle bodyMedium = TextStyle(
    fontFamily: 'Inter',
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: PawTableColors.mediumBrown,
    height: 1.5,
  );

  /// Caption / label — Inter Regular
  static const TextStyle caption = TextStyle(
    fontFamily: 'Inter',
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: PawTableColors.lightBrown,
    height: 1.4,
  );

  /// Button text — Inter SemiBold
  static const TextStyle buttonText = TextStyle(
    fontFamily: 'Inter',
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: PawTableColors.warmWhite,
    height: 1.4,
  );

  /// Data / numbers — Inter Medium
  static const TextStyle dataText = TextStyle(
    fontFamily: 'Inter',
    fontSize: 20,
    fontWeight: FontWeight.w500,
    color: PawTableColors.darkBrown,
    height: 1.2,
  );
}

import 'package:flutter/material.dart';

/// PawTable design tokens — spacing, shadows, border radii, animations
///
/// All visual constants are defined here to ensure consistency across
/// the app. Use these instead of magic numbers in widgets.
class PawTokens {
  PawTokens._();

  // =========================================================================
  // SPACING SCALE — 4px base grid
  // =========================================================================

  /// 4px — Tight spacing
  static const double xs = 4.0;

  /// 8px — Small spacing
  static const double sm = 8.0;

  /// 12px — Medium-small spacing
  static const double mdSm = 12.0;

  /// 16px — Medium spacing (default)
  static const double md = 16.0;

  /// 24px — Medium-large spacing
  static const double mdLg = 24.0;

  /// 32px — Large spacing
  static const double lg = 32.0;

  /// 48px — Extra large spacing
  static const double xl = 48.0;

  /// 64px — Massive spacing
  static const double xxl = 64.0;

  // =========================================================================
  // BORDER RADIUS
  // =========================================================================

  /// Small radius — chips, badges
  static const double radiusSm = 8.0;

  /// Default radius — cards, inputs, buttons
  static const double radiusMd = 12.0;

  /// Large radius — cards, dialogs
  static const double radiusLg = 16.0;

  /// Full radius — circular buttons, avatars
  static const double radiusFull = 999.0;

  // =========================================================================
  // SHADOWS — Elevation system
  // =========================================================================

  /// Level 0 — Flat
  static final List<BoxShadow> shadow0 = [];

  /// Level 1 — Subtle (cards)
  static final List<BoxShadow> shadow1 = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.05),
      blurRadius: 4,
      offset: const Offset(0, 2),
    ),
  ];

  /// Level 2 — Medium (elevated cards)
  static final List<BoxShadow> shadow2 = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.08),
      blurRadius: 8,
      offset: const Offset(0, 4),
    ),
  ];

  /// Level 3 — High (dialogs, bottom sheets)
  static final List<BoxShadow> shadow3 = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.12),
      blurRadius: 16,
      offset: const Offset(0, 8),
    ),
  ];

  /// Level 4 — Maximum (snackbars, menus)
  static final List<BoxShadow> shadow4 = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.16),
      blurRadius: 24,
      offset: const Offset(0, 12),
    ),
  ];

  /// Convenience: get shadow by elevation level
  static List<BoxShadow> shadow(int level) {
    switch (level) {
      case 1:
        return shadow1;
      case 2:
        return shadow2;
      case 3:
        return shadow3;
      case 4:
        return shadow4;
      default:
        return shadow0;
    }
  }

  // =========================================================================
  // ANIMATIONS
  // =========================================================================

  /// Standard duration — 200ms (quick interactions)
  static const Duration durationQuick = Duration(milliseconds: 200);

  /// Default duration — 300ms (page transitions)
  static const Duration durationDefault = Duration(milliseconds: 300);

  /// Extended duration — 500ms (elaborate animations)
  static const Duration durationExtended = Duration(milliseconds: 500);

  /// Curves
  static const Curve curveEmphasized = Curves.easeInOutCubic;
  static const Curve curveDecelerated = Curves.easeOut;
  static const Curve curveAccelerated = Curves.easeIn;
}

/// PawTable theme extension — access tokens from BuildContext
///
/// Usage: `PawTokens.of(context).spacing.md`
class PawTokenExtension extends ThemeExtension<PawTokenExtension> {
  final double spacing;

  const PawTokenExtension({
    this.spacing = 16.0,
  });

  @override
  PawTokenExtension copyWith({double? spacing}) {
    return PawTokenExtension(
      spacing: spacing ?? this.spacing,
    );
  }

  @override
  PawTokenExtension lerp(ThemeExtension<PawTokenExtension>? other, double t) {
    if (other is! PawTokenExtension) return this;
    return PawTokenExtension(
      spacing: spacing + (other.spacing - spacing) * t,
    );
  }
}

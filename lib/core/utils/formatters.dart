import 'package:intl/intl.dart';

/// PawTable formatters — numbers, weights, times, percentages
///
/// All formatters are locale-aware and produce human-readable output
/// suitable for display in UI widgets.
class Formatters {
  Formatters._();

  // =========================================================================
  // WEIGHT FORMATTING
  // =========================================================================

  /// Format weight in kg with unit ("5.2 kg")
  static String formatWeightKg(double? weight) {
    if (weight == null) return '—';
    return '${weight.toStringAsFixed(1)} kg';
  }

  /// Format weight in lbs with unit ("11.5 lbs")
  static String formatWeightLbs(double? weight) {
    if (weight == null) return '—';
    final lbs = weight * 2.20462;
    return '${lbs.toStringAsFixed(1)} lbs';
  }

  /// Format weight — auto-select unit based on magnitude
  static String formatWeight(double? weight, {bool useImperial = false}) {
    if (weight == null) return '—';
    if (useImperial) return formatWeightLbs(weight);
    return formatWeightKg(weight);
  }

  /// Format weight as a short string without unit ("5.2")
  static String formatWeightShort(double? weight) {
    if (weight == null) return '—';
    return weight.toStringAsFixed(1);
  }

  // =========================================================================
  // FOOD / AMOUNT FORMATTING
  // =========================================================================

  /// Format food amount ("50 g", "150 ml")
  static String formatAmount(double? amount, {String unit = 'g'}) {
    if (amount == null) return '—';
    return '${amount.toStringAsFixed(amount < 10 ? 1 : 0)} $unit';
  }

  /// Format food amount with a range ("50-60 g")
  static String formatAmountRange(double? min, double? max, {String unit = 'g'}) {
    if (min == null && max == null) return '—';
    if (min == max) return formatAmount(min, unit: unit);
    final minStr = (min != null) ? (min < 10 ? min.toStringAsFixed(1) : min.toStringAsFixed(0)) : '?';
    final maxStr = (max != null) ? (max < 10 ? max.toStringAsFixed(1) : max.toStringAsFixed(0)) : '?';
    return '$minStr–$maxStr $unit';
  }

  // =========================================================================
  // DOSAGE FORMATTING
  // =========================================================================

  /// Format medication dosage ("500 mg", "2.5 ml")
  static String formatDosage(double? dosage, {String unit = 'mg'}) {
    if (dosage == null) return '—';
    return '${dosage.toStringAsFixed(dosage < 1 ? 2 : (dosage < 10 ? 1 : 0))} $unit';
  }

  // =========================================================================
  // TIME FORMATTING
  // =========================================================================

  /// Format a Duration as "2h 30m" or "45m"
  static String formatDurationShort(Duration duration) {
    if (duration.inDays > 0) {
      return '${duration.inDays}d ${duration.inHours % 24}h';
    }
    if (duration.inHours > 0) {
      return '${duration.inHours}h ${duration.inMinutes % 60}m';
    }
    if (duration.inMinutes > 0) {
      return '${duration.inMinutes}m';
    }
    return '${duration.inSeconds}s';
  }

  /// Format a Duration as "2h 30m 15s" (full)
  static String formatDurationFull(Duration duration) {
    final days = duration.inDays;
    final hours = duration.inHours % 24;
    final minutes = duration.inMinutes % 60;
    final seconds = duration.inSeconds % 60;

    final parts = <String>[];
    if (days > 0) parts.add('${days}d');
    if (hours > 0) parts.add('${hours}h');
    if (minutes > 0) parts.add('${minutes}m');
    if (seconds > 0 || parts.isEmpty) parts.add('${seconds}s');

    return parts.join(' ');
  }

  // =========================================================================
  // NUMBER FORMATTING
  // =========================================================================

  /// Format a number with locale-aware grouping ("1,234.56")
  static String formatNumber(double number, {int decimals = 2}) {
    return NumberFormat.compact().format(number);
  }

  /// Format a number with exact decimal places
  static String formatDecimal(double number, {int decimals = 2}) {
    return number.toStringAsFixed(decimals);
  }

  /// Format a percentage ("75.5%")
  static String formatPercentage(double percentage) {
    return '${percentage.toStringAsFixed(1)}%';
  }

  /// Format a large number compactly ("1.2K", "3.5M")
  static String formatCompact(double number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    }
    if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toStringAsFixed(0);
  }

  // =========================================================================
  // PERCENTAGE CHANGES
  // =========================================================================

  /// Format weight change with arrow ("+0.3 kg ↑", "-0.2 kg ↓")
  static String formatWeightChange(double previous, double current) {
    final diff = current - previous;
    final sign = diff > 0 ? '+' : (diff < 0 ? '-' : '');
    return '$sign${diff.abs().toStringAsFixed(1)} kg ${diff > 0 ? '↑' : (diff < 0 ? '↓' : '—')}';
  }

  // =========================================================================
  // PET SPECIFIC FORMATTING
  // =========================================================================

  /// Format feeding schedule ("3x/day", "2x every 12h")
  static String formatFeedingFrequency(int timesPerDay) {
    if (timesPerDay == 1) return 'Once daily';
    if (timesPerDay == 2) return 'Twice daily';
    return '${timesPerDay}x/day';
  }

  /// Format medication schedule ("2x/day", "every 8h")
  static String formatMedicationFrequency(String frequency) {
    // Map frequency codes to readable strings
    switch (frequency.toLowerCase()) {
      case '1x/day':
      case 'once daily':
        return 'Once daily';
      case '2x/day':
      case 'twice daily':
        return 'Twice daily';
      case '3x/day':
      case 'three times daily':
        return 'Three times daily';
      case '4x/day':
      case 'q6h':
        return 'Every 6 hours';
      case 'q8h':
        return 'Every 8 hours';
      case 'q12h':
        return 'Every 12 hours';
      case 'weekly':
        return 'Once weekly';
      case 'monthly':
        return 'Once monthly';
      case 'as needed':
      case 'prn':
        return 'As needed';
      default:
        return frequency;
    }
  }

  // =========================================================================
  // STRING FORMATTING
  // =========================================================================

  /// Capitalize the first letter of each word
  static String capitalizeWords(String input) {
    if (input.isEmpty) return input;
    return input.split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

  /// Truncate a string with ellipsis
  static String truncate(String input, {int maxLength = 50}) {
    if (input.length <= maxLength) return input;
    return '${input.substring(0, maxLength)}…';
  }

  /// Truncate to a specific character count and add ellipsis
  static String truncateExact(String input, {int maxLength = 50}) {
    if (input.length <= maxLength) return input;
    return '${input.substring(0, maxLength - 3)}…';
  }

  /// Sanitize input — remove leading/trailing whitespace
  static String sanitize(String input) {
    return input.trim();
  }

  /// Slugify a string for URLs ("My Pet's Name" → "my-pets-name")
  static String slugify(String input) {
    return input
        .toLowerCase()
        .replaceAll(RegExp(r"[^a-z0-9\s-]"), '')
        .replaceAll(RegExp(r'\s+'), '-')
        .replaceAll(RegExp(r'-+'), '-')
        .replaceAll(RegExp(r'^-|-$'), '');
  }
}

/// Extension on [double] for convenient formatting
extension DoubleX on double {
  /// Format as weight in kg
  String get toWeightKg => Formatters.formatWeightKg(this);

  /// Format as weight in lbs
  String get toWeightLbs => Formatters.formatWeightLbs(this);

  /// Format as percentage
  String get toPercentage => Formatters.formatPercentage(this);

  /// Format compactly
  String get toCompact => Formatters.formatCompact(this);
}

/// Extension on [int] for convenient formatting
extension IntX on int {
  /// Format as feeding frequency
  String get toFeedingFrequency => Formatters.formatFeedingFrequency(this);

  /// Format compactly
  String get toCompact => Formatters.formatCompact(toDouble());
}

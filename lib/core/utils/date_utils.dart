import 'package:intl/intl.dart';

/// PawTable date and time formatting utilities
///
/// All date formatting uses [DateFormat] from the `intl` package for
/// locale-aware output. Constants define the format patterns used
/// throughout the app.
class DateUtils {
  DateUtils._();

  // =========================================================================
  // FORMAT PATTERNS
  // =========================================================================

  /// Full date — "June 25, 2025"
  static const String _fullDate = 'MMMM d, yyyy';

  /// Short date — "Jun 25"
  static const String _shortDate = 'MMM d';

  /// Time — "2:30 PM"
  static const String _time = 'h:mm a';

  /// Date + time — "Jun 25, 2:30 PM"
  static const String _dateTime = 'MMM d, h:mm a';

  /// ISO 8601 — "2025-06-25T14:30:00.000"
  static const String _iso8601 = "yyyy-MM-dd'T'HH:mm:ss.SSS";

  /// Date only — "2025-06-25"
  static const String _dateOnly = 'yyyy-MM-dd';

  /// Month/year — "June 2025"
  static const String _monthYear = 'MMMM yyyy';

  // =========================================================================
  // FORMATTING
  // =========================================================================

  /// Format a date using the full format ("June 25, 2025")
  static String formatDate(DateTime date, {String pattern = _fullDate}) {
    return DateFormat(pattern).format(date);
  }

  /// Format as short date ("Jun 25")
  static String formatShortDate(DateTime date) {
    return DateFormat(_shortDate).format(date);
  }

  /// Format as time ("2:30 PM")
  static String formatTime(DateTime time) {
    return DateFormat(_time).format(time);
  }

  /// Format as date + time ("Jun 25, 2:30 PM")
  static String formatDateTime(DateTime dateTime) {
    return DateFormat(_dateTime).format(dateTime);
  }

  /// Format as ISO 8601 string
  static String formatIso8601(DateTime date) {
    return DateFormat(_iso8601).format(date);
  }

  /// Format as date only ("2025-06-25")
  static String formatDateOnly(DateTime date) {
    return DateFormat(_dateOnly).format(date);
  }

  /// Format as month/year ("June 2025")
  static String formatMonthYear(DateTime date) {
    return DateFormat(_monthYear).format(date);
  }

  /// Format relative time ("Today", "Yesterday", "3 days ago")
  static String formatRelative(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) return 'Today';
    if (difference.inDays == 1) return 'Yesterday';
    if (difference.inDays == -1) return 'Tomorrow';
    if (difference.inDays.abs() < 7) {
      final days = difference.inDays.abs();
      return '$days ${days == 1 ? 'day' : 'days'} ${difference.isNegative ? 'from now' : 'ago'}';
    }

    return formatDate(date);
  }

  /// Format duration as human-readable string ("2h 30m", "1d 4h")
  static String formatDuration(Duration duration) {
    if (duration.inDays > 0) {
      return '${duration.inDays}d ${duration.inHours % 24}h';
    }
    if (duration.inHours > 0) {
      return '${duration.inHours}h ${duration.inMinutes % 60}m';
    }
    if (duration.inMinutes > 0) {
      return '${duration.inMinutes}m ${duration.inSeconds % 60}s';
    }
    return '${duration.inSeconds}s';
  }

  /// Format remaining time until a deadline ("In 3 days", "Overdue by 2 days")
  static String formatRemainingTime(DateTime deadline) {
    final now = DateTime.now();
    final difference = deadline.difference(now);

    if (difference.isNegative) {
      final days = (-difference.inDays).abs();
      if (days == 0) return 'Overdue today';
      return 'Overdue by ${days}d';
    }
    if (difference.inDays == 0) return 'Due today';
    if (difference.inDays == 1) return 'Due tomorrow';
    return 'In ${difference.inDays} days';
  }

  // =========================================================================
  // PARSING
  // =========================================================================

  /// Parse an ISO 8601 date string
  static DateTime? parseIso8601(String isoString) {
    try {
      return DateTime.parse(isoString);
    } catch (_) {
      return null;
    }
  }

  /// Parse a date string with a known format
  static DateTime? parseDate(String dateStr, {String pattern = _fullDate}) {
    try {
      return DateFormat(pattern).parse(dateStr);
    } catch (_) {
      return null;
    }
  }

  /// Parse a date-only string ("2025-06-25")
  static DateTime? parseDateOnly(String dateStr) {
    return parseDate(dateStr, pattern: _dateOnly);
  }

  // =========================================================================
  // GENERATION
  // =========================================================================

  /// Current date/time as ISO 8601 string
  static String isoNow() {
    return DateTime.now().toIso8601String();
  }

  /// Start of today (midnight)
  static DateTime startOfToday() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  /// End of today (23:59:59.999)
  static DateTime endOfToday() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, 23, 59, 59, 999);
  }

  /// Start of yesterday
  static DateTime startOfYesterday() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day - 1);
  }

  /// Start of tomorrow
  static DateTime startOfTomorrow() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day + 1);
  }

  /// Start of a given week (Monday)
  static DateTime startOfWeek(DateTime date, {int startDay = DateTime.monday}) {
    final daysSinceMonday = date.weekday - startDay;
    return DateUtils.toStartOfDay(date.subtract(Duration(days: daysSinceMonday)));
  }

  /// Start of a given month
  static DateTime startOfMonth(DateTime date) {
    return DateTime(date.year, date.month, 1);
  }

  /// End of a given month
  static DateTime endOfMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 0, 23, 59, 59, 999);
  }

  /// Start of a given year
  static DateTime startOfYear(DateTime date) {
    return DateTime(date.year, 1, 1);
  }

  /// End of a given year
  static DateTime endOfYear(DateTime date) {
    return DateTime(date.year, 12, 31, 23, 59, 59, 999);
  }

  // =========================================================================
  // DATE MATH
  // =========================================================================

  /// Add days to a date
  static DateTime addDays(DateTime date, int days) {
    return date.add(Duration(days: days));
  }

  /// Subtract days from a date
  static DateTime subtractDays(DateTime date, int days) {
    return date.subtract(Duration(days: days));
  }

  /// Add months to a date
  static DateTime addMonths(DateTime date, int months) {
    return DateTime(date.year + (date.month + months - 1) ~/ 12,
        (date.month + months - 1) % 12 + 1, date.day);
  }

  /// Get difference in days
  static int daysBetween(DateTime from, DateTime to) {
    return to.difference(from).inDays;
  }

  /// Get difference in months
  static int monthsBetween(DateTime from, DateTime to) {
    return (to.year - from.year) * 12 + (to.month - from.month);
  }

  // =========================================================================
  // PET-SPECIFIC HELPERS
  // =========================================================================

  /// Calculate pet age in years (approximate)
  static double calculateAgeInYears(DateTime birthdate) {
    final now = DateTime.now();
    final age = now.difference(birthdate);
    return age.inDays / 365.25;
  }

  /// Calculate pet age in months
  static int calculateAgeInMonths(DateTime birthdate) {
    final now = DateTime.now();
    return (now.year - birthdate.year) * 12 + (now.month - birthdate.month);
  }

  /// Determine life stage based on age and pet species
  static String getLifeStage({
    required double ageInYears,
    required String species, // 'dog', 'cat', 'rabbit', 'other'
  }) {
    switch (species) {
      case 'dog':
        if (ageInYears < 1) return 'Puppy';
        if (ageInYears < 2) return 'Young Adult';
        if (ageInYears < 7) return 'Adult';
        if (ageInYears < 10) return 'Mature';
        return 'Senior';
      case 'cat':
        if (ageInYears < 1) return 'Kitten';
        if (ageInYears < 2) return 'Young Adult';
        if (ageInYears < 7) return 'Adult';
        if (ageInYears < 10) return 'Mature';
        return 'Senior';
      case 'rabbit':
        if (ageInYears < 1) return 'Baby';
        if (ageInYears < 2) return 'Juvenile';
        if (ageInYears < 5) return 'Adult';
        if (ageInYears < 7) return 'Mature';
        return 'Senior';
      default:
        if (ageInYears < 1) return 'Baby';
        if (ageInYears < 2) return 'Juvenile';
        if (ageInYears < 5) return 'Adult';
        return 'Senior';
    }
  }

  /// Calculate next vaccination due date
  static DateTime? calculateNextDueDate({
    required DateTime issuedDate,
    required int monthsBetweenDoses,
  }) {
    return DateTime(
      issuedDate.year,
      issuedDate.month + monthsBetweenDoses,
      issuedDate.day,
    );
  }

  /// Calculate next vaccination due date from years
  static DateTime? calculateNextDueDateFromYears({
    required DateTime issuedDate,
    required int yearsBetweenDoses,
  }) {
    return calculateNextDueDate(
      issuedDate: issuedDate,
      monthsBetweenDoses: yearsBetweenDoses * 12,
    );
  }

  /// Check if a date is overdue (with optional grace period)
  static bool isOverdue(DateTime dueDate, {int graceDays = 7}) {
    final now = DateTime.now();
    final deadline = dueDate.add(Duration(days: graceDays));
    return now.isAfter(deadline);
  }

  /// Check if a date is due today (within 24 hours)
  static bool isDueToday(DateTime dueDate) {
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    return dueDate.isBefore(tomorrow) && dueDate.isAfter(startOfToday());
  }

  /// Check if a date is within a warning window (N days before due)
  static bool isUpcoming(DateTime dueDate, {int daysBefore = 7}) {
    final now = DateTime.now();
    final warningDate = dueDate.subtract(Duration(days: daysBefore));
    return dueDate.isAfter(now) && dueDate.isBefore(warningDate.add(Duration(days: daysBefore)));
  }

  // =========================================================================
  // UTILITY
  // =========================================================================

  /// Check if two dates are the same day (ignoring time)
  static bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  /// Truncate a DateTime to start of day
  static DateTime toStartOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  /// Truncate a DateTime to end of day
  static DateTime toEndOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day, 23, 59, 59, 999);
  }

  /// Get the number of days in a month
  static int daysInMonth(int year, int month) {
    return DateTime(year, month + 1, 0).day;
  }

  /// Get a list of dates in a range
  static List<DateTime> datesInRange(DateTime start, DateTime end) {
    final dates = <DateTime>[];
    var current = start.startOfDay;
    while (current.isBefore(end.startOfDay) || isSameDay(current, end)) {
      dates.add(current);
      current = current.add(Duration(days: 1));
    }
    return dates;
  }
}

/// Extension on [DateTime] for convenient date operations
extension DateTimeX on DateTime {
  /// Format this date using the default full format
  String toFormattedDate() => DateUtils.formatDate(this);

  /// Format as short date
  String toShortDate() => DateUtils.formatShortDate(this);

  /// Format as time
  String toTime() => DateUtils.formatTime(this);

  /// Format as date + time
  String toDateTime() => DateUtils.formatDateTime(this);

  /// Format relative to now
  String toRelative() => DateUtils.formatRelative(this);

  /// Check if this date is today
  bool get isToday => DateUtils.isSameDay(this, DateTime.now());

  /// Check if this date is yesterday
  bool get isYesterday => DateUtils.isSameDay(this, DateTime.now().subtract(const Duration(days: 1)));

  /// Check if this date is tomorrow
  bool get isTomorrow => DateUtils.isSameDay(this, DateTime.now().add(const Duration(days: 1)));

  /// Truncate to start of day
  DateTime get startOfDay => DateUtils.toStartOfDay(this);

  /// Truncate to end of day
  DateTime get endOfDay => DateUtils.toEndOfDay(this);

  /// Add days
  DateTime get plusDays => DateUtils.addDays(this, 1);

  /// Subtract days
  DateTime get minusDays => DateUtils.subtractDays(this, 1);
}

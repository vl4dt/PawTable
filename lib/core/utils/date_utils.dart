import 'package:intl/intl.dart';

/// Date formatting utilities for health logs, reminders, etc.
class DateUtils {
  DateUtils._();

  static const String _fullFormat = 'MMMM d, yyyy';
  static const String _shortFormat = 'MMM d';
  static const String _timeFormat = 'h:mm a';
  static const String _dateTimeFormat = 'MMM d, h:mm a';

  static String formatDate(DateTime date, {String format = _fullFormat}) {
    return DateFormat(format).format(date);
  }

  static String formatShortDate(DateTime date) {
    return DateFormat(_shortFormat).format(date);
  }

  static String formatTime(DateTime time) {
    return DateFormat(_timeFormat).format(time);
  }

  static String formatDateTime(DateTime dateTime) {
    return DateFormat(_dateTimeFormat).format(dateTime);
  }

  static String formatRelativeDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) return 'Today';
    if (difference.inDays == 1) return 'Yesterday';
    if (difference.inDays < 7) return '${difference.inDays} days ago';

    return formatDate(date);
  }

  static DateTime parseDate(String dateStr, {String format = _fullFormat}) {
    return DateFormat(format).parse(dateStr);
  }

  static String isoNow() {
    return DateTime.now().toIso8601String();
  }

  /// Calculate pet age in human years
  static double calculateAgeInYears(DateTime birthdate) {
    final now = DateTime.now();
    final age = now.difference(birthdate);
    return age.inDays / 365.25;
  }

  /// Get life stage based on age and pet type
  static String getLifeStage({
    required double ageInYears,
    required String petType, // 'dog', 'cat', 'small'
  }) {
    if (petType == 'dog') {
      if (ageInYears < 1) return 'Puppy';
      if (ageInYears < 2) return 'Young Adult';
      if (ageInYears < 7) return 'Adult';
      if (ageInYears < 10) return 'Mature';
      return 'Senior';
    } else if (petType == 'cat') {
      if (ageInYears < 1) return 'Kitten';
      if (ageInYears < 2) return 'Young Adult';
      if (ageInYears < 7) return 'Adult';
      if (ageInYears < 10) return 'Mature';
      return 'Senior';
    } else {
      // Small animals (rabbits, hamsters, etc.)
      if (ageInYears < 1) return 'Baby';
      if (ageInYears < 2) return 'Juvenile';
      if (ageInYears < 3) return 'Adult';
      return 'Senior';
    }
  }

  /// Calculate next due date for vaccination
  static DateTime? calculateNextDueDate({
    required DateTime issuedDate,
    required int yearsBetweenDoses,
  }) {
    return issuedDate.add(
      Duration(days: yearsBetweenDoses * 365),
    );
  }

  /// Check if a date is overdue (with grace period)
  static bool isOverdue(DateTime dueDate, {int graceDays = 7}) {
    final now = DateTime.now();
    final deadline = dueDate.add(Duration(days: graceDays));
    return now.isAfter(deadline);
  }
}

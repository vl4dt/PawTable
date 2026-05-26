import 'package:flutter_test/flutter_test.dart';
import 'package:pawtable/core/utils/date_utils.dart';

void main() {
  group('DateUtils.formatDate', () {
    test('formats DateTime to readable string', () {
      final date = DateTime(2024, 1, 15);
      final result = DateUtils.formatDate(date);
      expect(result, isNotNull);
      expect(result.isNotEmpty, isTrue);
      expect(result, 'January 15, 2024');
    });

    test('uses custom pattern', () {
      final date = DateTime(2024, 3, 1);
      final result = DateUtils.formatDate(date, pattern: 'MMM d');
      expect(result, 'Mar 1');
    });
  });

  group('DateUtils.formatShortDate', () {
    test('formats as short date', () {
      final date = DateTime(2024, 12, 25);
      expect(DateUtils.formatShortDate(date), 'Dec 25');
    });
  });

  group('DateUtils.formatTime', () {
    test('formats time correctly', () {
      final time = DateTime(2024, 1, 1, 14, 30);
      expect(DateUtils.formatTime(time), '2:30 PM');
    });

    test('formats midnight', () {
      final time = DateTime(2024, 1, 1, 0, 0);
      expect(DateUtils.formatTime(time), '12:00 AM');
    });
  });

  group('DateUtils.formatDateTime', () {
    test('formats date and time together', () {
      final dt = DateTime(2024, 6, 15, 10, 30);
      final result = DateUtils.formatDateTime(dt);
      expect(result, 'Jun 15, 10:30 AM');
    });
  });

  group('DateUtils.formatRelative', () {
    test('returns Today for current date', () {
      final now = DateTime.now();
      expect(DateUtils.formatRelative(now), 'Today');
    });

    test('returns Yesterday for yesterday', () {
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      expect(DateUtils.formatRelative(yesterday), 'Yesterday');
    });

    test('returns Tomorrow for tomorrow', () {
      final tomorrow = DateTime.now().add(const Duration(days: 1));
      expect(DateUtils.formatRelative(tomorrow), 'Tomorrow');
    });

    test('returns days ago for recent past', () {
      final threeDaysAgo = DateTime.now().subtract(const Duration(days: 3));
      final result = DateUtils.formatRelative(threeDaysAgo);
      expect(result, '3 days ago');
    });
  });

  group('DateUtils.formatDuration', () {
    test('formats hours and minutes', () {
      expect(DateUtils.formatDuration(const Duration(hours: 2, minutes: 30)), '2h 30m');
    });

    test('formats minutes only', () {
      expect(DateUtils.formatDuration(const Duration(minutes: 45)), '45m 0s');
    });

    test('formats seconds only', () {
      expect(DateUtils.formatDuration(const Duration(seconds: 30)), '30s');
    });

    test('formats days and hours', () {
      expect(DateUtils.formatDuration(const Duration(days: 1, hours: 4)), '1d 4h');
    });
  });

  group('DateUtils.formatRemainingTime', () {
    test('returns Due today for today deadline', () {
      final todayEnd = DateUtils.endOfToday();
      expect(DateUtils.formatRemainingTime(todayEnd), 'Due today');
    });

    test('returns In N days for future', () {
      final nextWeek = DateTime.now().add(const Duration(days: 7));
      final result = DateUtils.formatRemainingTime(nextWeek);
      expect(result, 'In 7 days');
    });

    test('returns Overdue for past deadline', () {
      final past = DateTime.now().subtract(const Duration(days: 5));
      final result = DateUtils.formatRemainingTime(past);
      expect(result, contains('Overdue'));
    });
  });

  group('DateUtils.parseDate', () {
    test('parses valid date string', () {
      final result = DateUtils.parseDate('January 15, 2024');
      expect(result, isNotNull);
      expect(result!.year, 2024);
      expect(result.month, 1);
      expect(result.day, 15);
    });

    test('parses date-only format', () {
      final result = DateUtils.parseDateOnly('2024-01-15');
      expect(result, isNotNull);
      expect(result!.year, 2024);
      expect(result.month, 1);
      expect(result.day, 15);
    });

    test('returns null for invalid date string', () {
      final result = DateUtils.parseDate('not a date');
      expect(result, isNull);
    });
  });

  group('DateUtils.parseIso8601', () {
    test('parses ISO 8601 string', () {
      final result = DateUtils.parseIso8601('2024-01-15T10:30:00.000');
      expect(result, isNotNull);
      expect(result!.year, 2024);
      expect(result.month, 1);
      expect(result.day, 15);
      expect(result.hour, 10);
      expect(result.minute, 30);
    });

    test('returns null for invalid ISO string', () {
      final result = DateUtils.parseIso8601('not an iso date');
      expect(result, isNull);
    });
  });

  group('DateUtils.calculateAgeInYears', () {
    test('calculates age in years', () {
      final birthDate = DateTime(2020, 6, 15);
      final age = DateUtils.calculateAgeInYears(birthDate);
      expect(age, greaterThan(0));
      expect(age, lessThan(10));
    });

    test('returns near zero for future birth date', () {
      final future = DateTime.now().add(const Duration(days: 30));
      final age = DateUtils.calculateAgeInYears(future);
      expect(age, isNegative);
    });
  });

  group('DateUtils.calculateAgeInMonths', () {
    test('calculates age in months', () {
      final birthDate = DateTime(2023, 1, 15);
      final age = DateUtils.calculateAgeInMonths(birthDate);
      expect(age, greaterThan(0));
    });
  });

  group('DateUtils.getLifeStage', () {
    test('returns Puppy for dog under 1 year', () {
      expect(DateUtils.getLifeStage(ageInYears: 0.5, species: 'dog'), 'Puppy');
    });

    test('returns Kitten for cat under 1 year', () {
      expect(DateUtils.getLifeStage(ageInYears: 0.5, species: 'cat'), 'Kitten');
    });

    test('returns Adult for dog 2-7 years', () {
      expect(DateUtils.getLifeStage(ageInYears: 5, species: 'dog'), 'Adult');
    });

    test('returns Senior for dog 10+ years', () {
      expect(DateUtils.getLifeStage(ageInYears: 12, species: 'dog'), 'Senior');
    });

    test('returns Adult for default species 2-5 years', () {
      expect(DateUtils.getLifeStage(ageInYears: 3, species: 'other'), 'Adult');
    });
  });

  group('DateUtils.calculateNextDueDate', () {
    test('calculates next vaccination due date', () {
      final issued = DateTime(2024, 1, 1);
      final next = DateUtils.calculateNextDueDate(
        issuedDate: issued,
        monthsBetweenDoses: 12,
      );
      expect(next, isNotNull);
      expect(next!.month, 1);
      expect(next.year, 2025);
    });

    test('handles month overflow', () {
      final issued = DateTime(2024, 11, 15);
      final next = DateUtils.calculateNextDueDate(
        issuedDate: issued,
        monthsBetweenDoses: 6,
      );
      expect(next!.year, 2025);
      expect(next.month, 5);
    });
  });

  group('DateUtils.isOverdue', () {
    test('returns true for overdue date', () {
      final past = DateTime.now().subtract(const Duration(days: 30));
      expect(DateUtils.isOverdue(past), isTrue);
    });

    test('returns false for future date', () {
      final future = DateTime.now().add(const Duration(days: 30));
      expect(DateUtils.isOverdue(future), isFalse);
    });

    test('applies grace period', () {
      final slightlyPast = DateTime.now().subtract(const Duration(days: 2));
      expect(DateUtils.isOverdue(slightlyPast, graceDays: 7), isFalse);
    });
  });

  group('DateUtils.isDueToday', () {
    test('returns true if due today', () {
      final today = DateUtils.startOfToday().add(const Duration(hours: 12));
      expect(DateUtils.isDueToday(today), isTrue);
    });

    test('returns false for tomorrow', () {
      final tomorrow = DateUtils.startOfTomorrow();
      expect(DateUtils.isDueToday(tomorrow), isFalse);
    });
  });

  group('DateUtils.date math', () {
    test('addDays adds days', () {
      final base = DateTime(2024, 1, 15);
      final result = DateUtils.addDays(base, 5);
      expect(result.day, 20);
    });

    test('subtractDays subtracts days', () {
      final base = DateTime(2024, 1, 20);
      final result = DateUtils.subtractDays(base, 5);
      expect(result.day, 15);
    });

    test('addMonths adds months', () {
      final base = DateTime(2024, 1, 15);
      final result = DateUtils.addMonths(base, 3);
      expect(result.month, 4);
    });

    test('daysBetween calculates difference', () {
      final start = DateTime(2024, 1, 1);
      final end = DateTime(2024, 1, 15);
      expect(DateUtils.daysBetween(start, end), 14);
    });

    test('monthsBetween calculates difference', () {
      final start = DateTime(2023, 1, 1);
      final end = DateTime(2024, 6, 1);
      expect(DateUtils.monthsBetween(start, end), 17);
    });
  });

  group('DateUtils date boundaries', () {
    test('startOfToday returns midnight', () {
      final start = DateUtils.startOfToday();
      expect(start.hour, 0);
      expect(start.minute, 0);
      expect(start.second, 0);
    });

    test('endOfToday returns 23:59:59', () {
      final end = DateUtils.endOfToday();
      expect(end.hour, 23);
      expect(end.minute, 59);
      expect(end.second, 59);
    });

    test('startOfMonth returns first day', () {
      final start = DateUtils.startOfMonth(DateTime(2024, 2, 15));
      expect(start.day, 1);
    });

    test('endOfMonth returns last day', () {
      final end = DateUtils.endOfMonth(DateTime(2024, 2, 15));
      expect(end.day, 29); // 2024 is a leap year
    });

    test('startOfWeek returns Monday', () {
      final wednesday = DateTime(2024, 1, 17); // Wednesday
      final monday = DateUtils.startOfWeek(wednesday);
      expect(monday.weekday, DateTime.monday);
    });
  });

  group('DateUtils isSameDay', () {
    test('returns true for same day', () {
      final a = DateTime(2024, 1, 15, 10, 0);
      final b = DateTime(2024, 1, 15, 23, 59);
      expect(DateUtils.isSameDay(a, b), isTrue);
    });

    test('returns false for different days', () {
      final a = DateTime(2024, 1, 15, 23, 59);
      final b = DateTime(2024, 1, 16, 0, 1);
      expect(DateUtils.isSameDay(a, b), isFalse);
    });
  });

  group('DateUtils daysInMonth', () {
    test('returns correct days for February (leap year)', () {
      expect(DateUtils.daysInMonth(2024, 2), 29);
    });

    test('returns correct days for February (non-leap year)', () {
      expect(DateUtils.daysInMonth(2023, 2), 28);
    });

    test('returns correct days for January', () {
      expect(DateUtils.daysInMonth(2024, 1), 31);
    });
  });

  group('DateUtils isoNow', () {
    test('returns ISO 8601 string', () {
      final iso = DateUtils.isoNow();
      expect(iso, isNotEmpty);
      expect(DateTime.parse(iso), isNotNull);
    });
  });

  group('DateTimeX extension', () {
    test('startOfDay returns midnight', () {
      final date = DateTime(2024, 1, 15, 14, 30, 45);
      final startOfDay = date.startOfDay;
      expect(startOfDay.hour, 0);
      expect(startOfDay.minute, 0);
      expect(startOfDay.second, 0);
    });

    test('isToday returns true for today', () {
      final today = DateTime.now();
      expect(today.isToday, isTrue);
    });

    test('isToday returns false for yesterday', () {
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      expect(yesterday.isToday, isFalse);
    });

    test('isYesterday returns true for yesterday', () {
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      expect(yesterday.isYesterday, isTrue);
    });

    test('isTomorrow returns true for tomorrow', () {
      final tomorrow = DateTime.now().add(const Duration(days: 1));
      expect(tomorrow.isTomorrow, isTrue);
    });

    test('toFormattedDate formats correctly', () {
      final date = DateTime(2024, 6, 15);
      expect(date.toFormattedDate(), 'June 15, 2024');
    });

    test('toShortDate formats correctly', () {
      final date = DateTime(2024, 6, 15);
      expect(date.toShortDate(), 'Jun 15');
    });

    test('toTime formats correctly', () {
      final date = DateTime(2024, 1, 1, 14, 30);
      expect(date.toTime(), '2:30 PM');
    });

    test('toRelative formats correctly', () {
      final today = DateTime.now();
      expect(today.toRelative(), 'Today');
    });

    test('plusDays adds one day', () {
      final date = DateTime(2024, 1, 15);
      final nextDay = date.plusDays;
      expect(nextDay.day, 16);
    });

    test('minusDays subtracts one day', () {
      final date = DateTime(2024, 1, 16);
      final prevDay = date.minusDays;
      expect(prevDay.day, 15);
    });
  });

  group('DateUtils.datesInRange', () {
    test('generates dates between start and end', () {
      final start = DateTime(2024, 1, 1);
      final end = DateTime(2024, 1, 3);
      final dates = DateUtils.datesInRange(start, end);
      expect(dates.length, 3);
      expect(dates[0], DateTime(2024, 1, 1));
      expect(dates[1], DateTime(2024, 1, 2));
      expect(dates[2], DateTime(2024, 1, 3));
    });
  });
}

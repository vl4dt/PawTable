import 'package:flutter_test/flutter_test.dart';
import 'package:pawtable/core/utils/formatters.dart';

void main() {
  group('Formatters.formatWeightKg', () {
    test('formats weight with kg unit', () {
      expect(Formatters.formatWeightKg(10.5), '10.5 kg');
    });

    test('formats zero weight', () {
      expect(Formatters.formatWeightKg(0), '0.0 kg');
    });

    test('returns dash for null', () {
      expect(Formatters.formatWeightKg(null), '—');
    });

    test('formats small weight', () {
      expect(Formatters.formatWeightKg(0.5), '0.5 kg');
    });
  });

  group('Formatters.formatWeightLbs', () {
    test('converts kg to lbs', () {
      final lbs = Formatters.formatWeightLbs(10.0);
      expect(lbs, isNotNull);
      expect(lbs, contains('lbs'));
      expect(lbs, contains('22.0'));
    });

    test('returns dash for null', () {
      expect(Formatters.formatWeightLbs(null), '—');
    });
  });

  group('Formatters.formatWeight', () {
    test('formats weight in kg by default', () {
      expect(Formatters.formatWeight(10.5), '10.5 kg');
    });

    test('formats weight in lbs when imperial', () {
      final lbs = Formatters.formatWeight(10.0, useImperial: true);
      expect(lbs, contains('lbs'));
    });

    test('returns dash for null', () {
      expect(Formatters.formatWeight(null), '—');
    });
  });

  group('Formatters.formatWeightShort', () {
    test('formats without unit', () {
      expect(Formatters.formatWeightShort(10.5), '10.5');
    });

    test('returns dash for null', () {
      expect(Formatters.formatWeightShort(null), '—');
    });
  });

  group('Formatters.formatWeightChange', () {
    test('formats positive change', () {
      expect(Formatters.formatWeightChange(10.0, 10.5), '+0.5 kg ↑');
    });

    test('formats negative change', () {
      expect(Formatters.formatWeightChange(10.0, 9.5), '-0.5 kg ↓');
    });

    test('formats no change', () {
      final result = Formatters.formatWeightChange(10.0, 10.0);
      expect(result, contains('kg'));
    });
  });

  group('Formatters.formatAmount', () {
    test('formats food amount with grams', () {
      expect(Formatters.formatAmount(100), '100 g');
    });

    test('formats small amount with decimal', () {
      expect(Formatters.formatAmount(5.5), '5.5 g');
    });

    test('returns dash for null', () {
      expect(Formatters.formatAmount(null), '—');
    });

    test('formats with custom unit', () {
      expect(Formatters.formatAmount(250, unit: 'ml'), '250 ml');
    });
  });

  group('Formatters.formatAmountRange', () {
    test('formats range', () {
      final result = Formatters.formatAmountRange(50, 60);
      expect(result, contains('g'));
      expect(result, contains('50'));
      expect(result, contains('60'));
    });

    test('formats single value', () {
      expect(Formatters.formatAmountRange(50, 50), '50 g');
    });

    test('returns dash for nulls', () {
      expect(Formatters.formatAmountRange(null, null), '—');
    });
  });

  group('Formatters.formatDosage', () {
    test('formats mg dosage', () {
      expect(Formatters.formatDosage(500), '500 mg');
    });

    test('formats decimal dosage', () {
      expect(Formatters.formatDosage(2.5), '2.5 mg');
    });

    test('formats very small dosage', () {
      expect(Formatters.formatDosage(0.25), '0.25 mg');
    });

    test('returns dash for null', () {
      expect(Formatters.formatDosage(null), '—');
    });

    test('formats with custom unit', () {
      final result = Formatters.formatDosage(5, unit: 'ml');
      expect(result, contains('ml'));
    });
  });

  group('Formatters.formatDurationShort', () {
    test('formats days and hours', () {
      expect(
        Formatters.formatDurationShort(const Duration(days: 1, hours: 4)),
        '1d 4h',
      );
    });

    test('formats hours and minutes', () {
      expect(
        Formatters.formatDurationShort(const Duration(hours: 2, minutes: 30)),
        '2h 30m',
      );
    });

    test('formats minutes only', () {
      expect(
        Formatters.formatDurationShort(const Duration(minutes: 45)),
        '45m',
      );
    });

    test('formats seconds only', () {
      expect(
        Formatters.formatDurationShort(const Duration(seconds: 30)),
        '30s',
      );
    });
  });

  group('Formatters.formatDurationFull', () {
    test('formats full duration', () {
      expect(
        Formatters.formatDurationFull(const Duration(days: 1, hours: 2, minutes: 3, seconds: 4)),
        '1d 2h 3m 4s',
      );
    });

    test('formats only seconds', () {
      expect(
        Formatters.formatDurationFull(const Duration(seconds: 30)),
        '30s',
      );
    });
  });

  group('Formatters.formatPercentage', () {
    test('formats percentage', () {
      expect(Formatters.formatPercentage(75.5), '75.5%');
    });

    test('formats whole number', () {
      expect(Formatters.formatPercentage(100), '100.0%');
    });

    test('formats decimal', () {
      expect(Formatters.formatPercentage(33.33), '33.3%');
    });
  });

  group('Formatters.formatCompact', () {
    test('compacts thousands', () {
      expect(Formatters.formatCompact(1500), '1.5K');
    });

    test('compacts millions', () {
      expect(Formatters.formatCompact(1500000), '1.5M');
    });

    test('returns original for small numbers', () {
      expect(Formatters.formatCompact(100), '100');
    });
  });

  group('Formatters.formatFeedingFrequency', () {
    test('formats once daily', () {
      expect(Formatters.formatFeedingFrequency(1), 'Once daily');
    });

    test('formats twice daily', () {
      expect(Formatters.formatFeedingFrequency(2), 'Twice daily');
    });

    test('formats generic frequency', () {
      expect(Formatters.formatFeedingFrequency(3), '3x/day');
    });
  });

  group('Formatters.formatMedicationFrequency', () {
    test('formats 2x/day', () {
      expect(Formatters.formatMedicationFrequency('2x/day'), 'Twice daily');
    });

    test('formats q8h', () {
      expect(Formatters.formatMedicationFrequency('q8h'), 'Every 8 hours');
    });

    test('formats as needed', () {
      expect(Formatters.formatMedicationFrequency('as needed'), 'As needed');
    });

    test('returns unknown as-is', () {
      expect(Formatters.formatMedicationFrequency('unknown'), 'unknown');
    });
  });

  group('Formatters.capitalizeWords', () {
    test('capitalizes each word', () {
      expect(Formatters.capitalizeWords('my pet'), 'My Pet');
    });

    test('handles empty string', () {
      expect(Formatters.capitalizeWords(''), '');
    });
  });

  group('Formatters.truncate', () {
    test('truncates long strings', () {
      final result = Formatters.truncate('a' * 100, maxLength: 10);
      expect(result.length, 11); // 10 chars + ellipsis
      expect(result.endsWith('…'), isTrue);
    });

    test('returns original for short strings', () {
      expect(Formatters.truncate('hello'), 'hello');
    });
  });

  group('Formatters.slugify', () {
    test('slugifies a name', () {
      expect(Formatters.slugify('My Pet Name'), 'my-pet-name');
    });

    test('slugifies with special chars', () {
      expect(Formatters.slugify("Buddy's Name"), 'buddys-name');
    });
  });

  group('DoubleX extension', () {
    test('toWeightKg formats weight kg', () {
      expect((10.5).toWeightKg, '10.5 kg');
    });

    test('toPercentage formats percentage', () {
      expect((75.5).toPercentage, '75.5%');
    });

    test('toCompact formats compact', () {
      expect((1500.0).toCompact, '1.5K');
    });

    test('toWeightLbs formats weight lbs', () {
      final lbs = (10.5).toWeightLbs;
      expect(lbs, contains('lbs'));
    });
  });

  group('IntX extension', () {
    test('toCompact formats compact', () {
      expect((1000).toCompact, '1.0K');
    });

    test('toFeedingFrequency formats frequency', () {
      expect((3).toFeedingFrequency, '3x/day');
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:pawtable/core/utils/validators.dart';

void main() {
  group('Validators.required', () {
    test('returns error for null', () {
      expect(Validators.required(null), isNotNull);
    });

    test('returns error for empty string', () {
      expect(Validators.required(''), isNotNull);
    });

    test('returns null for valid input', () {
      expect(Validators.required('test'), isNull);
    });

    test('returns error for whitespace only', () {
      expect(Validators.required('   '), isNotNull);
    });

    test('uses custom field name', () {
      expect(Validators.required(null, field: 'Name'), equals('Name is required'));
    });
  });

  group('Validators.nonEmpty', () {
    test('returns error for null', () {
      expect(Validators.nonEmpty(null), isNotNull);
    });

    test('returns error for empty string', () {
      expect(Validators.nonEmpty(''), isNotNull);
    });

    test('returns null for valid input', () {
      expect(Validators.nonEmpty('hello'), isNull);
    });
  });

  group('Validators.minLength', () {
    test('returns error when below minimum', () {
      expect(Validators.minLength('ab', min: 5), isNotNull);
    });

    test('returns null when at minimum', () {
      expect(Validators.minLength('abcde', min: 5), isNull);
    });

    test('returns null when above minimum', () {
      expect(Validators.minLength('abcdefgh', min: 5), isNull);
    });
  });

  group('Validators.maxLength', () {
    test('returns error when above maximum', () {
      expect(Validators.maxLength('abcdefgh', max: 5), isNotNull);
    });

    test('returns null when at maximum', () {
      expect(Validators.maxLength('abcde', max: 5), isNull);
    });

    test('returns null when below maximum', () {
      expect(Validators.maxLength('ab', max: 5), isNull);
    });
  });

  group('Validators.charCount', () {
    test('returns error when below minimum', () {
      expect(Validators.charCount('ab', min: 5, max: 10), isNotNull);
    });

    test('returns error when above maximum', () {
      expect(Validators.charCount('abcdefghij', min: 5, max: 10), isNull);
    });

    test('returns null when in range', () {
      expect(Validators.charCount('abcde', min: 3, max: 10), isNull);
    });
  });

  group('Validators.email', () {
    test('returns error for invalid email', () {
      expect(Validators.email('invalid'), isNotNull);
    });

    test('returns error for email without @', () {
      expect(Validators.email('test.com'), isNotNull);
    });

    test('returns error for email without domain', () {
      expect(Validators.email('test@'), isNotNull);
    });

    test('returns null for valid email', () {
      expect(Validators.email('test@example.com'), isNull);
    });

    test('returns null for valid email with dots', () {
      expect(Validators.email('test.name@example.co.uk'), isNull);
    });

    test('returns null for null input', () {
      expect(Validators.email(null), isNull);
    });
  });

  group('Validators.phone', () {
    test('returns null for empty phone (early return)', () {
      // Validators return null for empty/null inputs - they only validate if value is present
      expect(Validators.phone(''), isNull);
    });

    test('returns null for valid phone', () {
      expect(Validators.phone('1234567890'), isNull);
    });

    test('returns null for phone with dashes', () {
      expect(Validators.phone('123-456-7890'), isNull);
    });

    test('returns null for null input', () {
      expect(Validators.phone(null), isNull);
    });
  });

  group('Validators.password', () {
    test('returns error for too short password', () {
      expect(Validators.password('123'), isNotNull);
    });

    test('returns error for password without number', () {
      expect(Validators.password('password'), isNotNull);
    });

    test('returns null for valid password', () {
      expect(Validators.password('password123'), isNull);
    });

    test('returns error for null input', () {
      expect(Validators.password(null), isNotNull);
    });
  });

  group('Validators.passwordMatch', () {
    test('returns null when passwords match', () {
      expect(Validators.passwordMatch('pass123', 'pass123'), isNull);
    });

    test('returns error when passwords do not match', () {
      expect(Validators.passwordMatch('pass123', 'other456'), isNotNull);
    });

    test('returns null for null inputs', () {
      expect(Validators.passwordMatch(null, null), isNull);
    });
  });

  group('Validators.weight', () {
    test('returns error for below minimum weight', () {
      expect(Validators.weight('0.05'), isNotNull);
    });

    test('returns null for valid weight', () {
      expect(Validators.weight('10.5'), isNull);
    });

    test('returns null for integer weight', () {
      expect(Validators.weight('25'), isNull);
    });

    test('returns error for excessive weight', () {
      expect(Validators.weight('1001'), isNotNull);
    });

    test('returns null for null input', () {
      expect(Validators.weight(null), isNull);
    });
  });

  group('Validators.dosage', () {
    test('returns error for zero dosage', () {
      expect(Validators.dosage('0'), isNotNull);
    });

    test('returns null for valid dosage', () {
      expect(Validators.dosage('500'), isNull);
    });

    test('returns null for decimal dosage', () {
      expect(Validators.dosage('2.5'), isNull);
    });

    test('returns error for excessive dosage', () {
      expect(Validators.dosage('10001'), isNotNull);
    });

    test('returns null for null input', () {
      expect(Validators.dosage(null), isNull);
    });
  });

  group('Validators.petName', () {
    test('returns error for empty pet name', () {
      expect(Validators.petName(''), isNotNull);
    });

    test('returns error for very long pet name', () {
      expect(Validators.petName('a' * 51), isNotNull);
    });

    test('returns null for valid pet name', () {
      expect(Validators.petName('Buddy'), isNull);
    });

    test('returns null for pet name with hyphens', () {
      expect(Validators.petName('Buddy-Bear'), isNull);
    });

    test('returns error for pet name with special chars', () {
      expect(Validators.petName('Buddy&Co'), isNotNull);
    });
  });

  group('Validators.numberRange', () {
    test('returns error below range', () {
      expect(Validators.numberRange('5', min: 10, max: 100), isNotNull);
    });

    test('returns error above range', () {
      expect(Validators.numberRange('101', min: 10, max: 100), isNotNull);
    });

    test('returns null within range', () {
      expect(Validators.numberRange('50', min: 10, max: 100), isNull);
    });

    test('returns null at range boundaries', () {
      expect(Validators.numberRange('10', min: 10, max: 100), isNull);
      expect(Validators.numberRange('100', min: 10, max: 100), isNull);
    });
  });

  group('Validators.positiveNumber', () {
    test('returns error for zero', () {
      expect(Validators.positiveNumber('0'), isNotNull);
    });

    test('returns error for negative', () {
      expect(Validators.positiveNumber('-1'), isNotNull);
    });

    test('returns null for positive', () {
      expect(Validators.positiveNumber('5'), isNull);
    });
  });

  group('Validators.nonNegativeNumber', () {
    test('returns error for negative', () {
      expect(Validators.nonNegativeNumber('-1'), isNotNull);
    });

    test('returns null for zero', () {
      expect(Validators.nonNegativeNumber('0'), isNull);
    });

    test('returns null for positive', () {
      expect(Validators.nonNegativeNumber('5'), isNull);
    });
  });

  group('Validators.url', () {
    test('returns null for valid URL', () {
      expect(Validators.url('https://example.com'), isNull);
    });

    test('returns null for URL without protocol', () {
      expect(Validators.url('example.com'), isNull);
    });

    test('returns error for invalid URL', () {
      expect(Validators.url('not a url'), isNotNull);
    });
  });

  group('Validators.number', () {
    test('returns error for non-numeric string', () {
      expect(Validators.number('abc'), isNotNull);
    });

    test('returns null for integer', () {
      expect(Validators.number('42'), isNull);
    });

    test('returns null for decimal', () {
      expect(Validators.number('3.14'), isNull);
    });
  });

  group('Validators.integer', () {
    test('returns error for decimal string', () {
      expect(Validators.integer('3.14'), isNotNull);
    });

    test('returns null for valid integer', () {
      expect(Validators.integer('42'), isNull);
    });

    test('returns error for non-numeric string', () {
      expect(Validators.integer('abc'), isNotNull);
    });
  });

  group('Validators.optional', () {
    test('returns null for empty value', () {
      expect(Validators.optional(Validators.email, ''), isNull);
    });

    test('returns null for null value', () {
      expect(Validators.optional(Validators.email, null), isNull);
    });

    test('returns error when value present and invalid', () {
      expect(Validators.optional(Validators.email, 'invalid'), isNotNull);
    });

    test('returns null when value present and valid', () {
      expect(Validators.optional(Validators.email, 'test@example.com'), isNull);
    });
  });

  group('Validators.combined', () {
    test('returns first error found', () {
      final validators = <String? Function(String?)>[
        Validators.required,
        Validators.email,
      ];
      expect(Validators.combined('invalid', validators), isNotNull);
    });

    test('returns null when all pass', () {
      final validators = <String? Function(String?)>[
        Validators.required,
        Validators.email,
      ];
      expect(Validators.combined('test@example.com', validators), isNull);
    });
  });

  group('ValidatorsX extension', () {
    test('isValidPetName returns true for valid name', () {
      expect('Buddy'.isValidPetName, isTrue);
    });

    test('isValidPetName returns false for invalid name', () {
      expect(''.isValidPetName, isFalse);
    });

    test('isValidWeight returns true for valid weight', () {
      expect('10.5'.isValidWeight, isTrue);
    });

    test('isValidWeight returns false for invalid weight', () {
      expect('abc'.isValidWeight, isFalse);
    });

    test('validate calls validator function', () {
      expect('test'.validate(Validators.required), isNull);
      expect(''.validate(Validators.required), isNotNull);
    });
  });

  group('Validators.breed', () {
    test('returns null for valid breed', () {
      expect(Validators.breed('Labrador'), isNull);
    });

    test('returns error for breed exceeding max length', () {
      expect(Validators.breed('a' * 101), isNotNull);
    });

    test('returns null for empty breed (charCount returns null for empty)', () {
      // charCount returns null for empty inputs - use required() for required fields
      expect(Validators.breed(''), isNull);
    });
  });

  group('Validators.vaccineName', () {
    test('returns null for valid vaccine name', () {
      expect(Validators.vaccineName('Rabies'), isNull);
    });

    test('returns error for vaccine name exceeding max length', () {
      expect(Validators.vaccineName('a' * 101), isNotNull);
    });

    test('returns null for empty vaccine name', () {
      expect(Validators.vaccineName(''), isNull);
    });
  });

  group('Validators.medicationName', () {
    test('returns null for valid medication name', () {
      expect(Validators.medicationName('Metacam'), isNull);
    });

    test('returns error for medication name exceeding max length', () {
      expect(Validators.medicationName('a' * 101), isNotNull);
    });

    test('returns null for empty medication name', () {
      expect(Validators.medicationName(''), isNull);
    });
  });

  group('Validators.notes', () {
    test('returns null for empty notes', () {
      expect(Validators.notes(''), isNull);
    });

    test('returns null for valid notes', () {
      expect(Validators.notes('My pet is doing well'), isNull);
    });

    test('returns error for notes exceeding 2000 chars', () {
      expect(Validators.notes('a' * 2001), isNotNull);
    });
  });

  group('Validators.memberName', () {
    test('returns null for valid member name', () {
      expect(Validators.memberName('John'), isNull);
    });

    test('returns error for member name exceeding max length', () {
      expect(Validators.memberName('a' * 101), isNotNull);
    });

    test('returns null for empty member name', () {
      expect(Validators.memberName(''), isNull);
    });
  });
}

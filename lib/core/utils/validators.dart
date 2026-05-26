/// PawTable form validation utilities
///
/// All validators return `null` when the input is valid, or a string
/// error message when invalid. This matches the Flutter `TextFormField`
/// `validator` signature.
class Validators {
  Validators._();

  // =========================================================================
  // CORE VALIDATORS
  // =========================================================================

  /// Field is required (not null and not empty)
  static String? required(
    String? value, {
    String field = 'This field',
  }) {
    if (value == null || value.trim().isEmpty) {
      return '$field is required';
    }
    return null;
  }

  /// Field has non-empty trimmed content
  static String? nonEmpty(
    String? value, {
    String field = 'This field',
  }) {
    if (value == null || value.trim().isEmpty) {
      return '$field cannot be empty';
    }
    return null;
  }

  /// Minimum length check
  static String? minLength(
    String? value, {
    required int min,
    String field = 'This field',
  }) {
    if (value == null || value.trim().isEmpty) return null;
    if (value.trim().length < min) {
      return '$field must be at least $min characters';
    }
    return null;
  }

  /// Maximum length check
  static String? maxLength(
    String? value, {
    required int max,
    String field = 'This field',
  }) {
    if (value == null || value.trim().isEmpty) return null;
    if (value.trim().length > max) {
      return '$field must be less than $max characters';
    }
    return null;
  }

  /// Both min and max length in one check
  static String? charCount(
    String? value, {
    required int min,
    required int max,
    String field = 'This field',
  }) {
    if (value == null || value.trim().isEmpty) return null;
    if (value.trim().length < min) {
      return '$field must be at least $min characters';
    }
    if (value.trim().length > max) {
      return '$field must be less than $max characters';
    }
    return null;
  }

  // =========================================================================
  // PATTERN VALIDATORS
  // =========================================================================

  /// Email address format
  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  /// Phone number (basic format: digits, spaces, dashes, parentheses)
  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final phoneRegex = RegExp(
      r'^[\+]?[(]?[0-9]{1,4}[)]?[-\s\.]?[0-9]{1,4}[-\s\.]?[0-9]{1,9}$',
    );
    if (!phoneRegex.hasMatch(value.trim())) {
      return 'Please enter a valid phone number';
    }
    return null;
  }

  /// URL format
  static String? url(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final urlRegex = RegExp(
      r'^(https?:\/\/)?([\w-]+\.)+[\w]{2,}([\/\w .-]*)*\/?$',
    );
    if (!urlRegex.hasMatch(value.trim())) {
      return 'Please enter a valid URL';
    }
    return null;
  }

  /// Numeric value (allows decimals)
  static String? number(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    if (double.tryParse(value.trim()) == null) {
      return 'Please enter a valid number';
    }
    return null;
  }

  /// Integer value
  static String? integer(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    if (int.tryParse(value.trim()) == null) {
      return 'Please enter a valid integer';
    }
    return null;
  }

  // =========================================================================
  // NUMBER RANGE VALIDATORS
  // =========================================================================

  /// Positive number (> 0)
  static String? positiveNumber(
    String? value, {
    String field = 'Value',
  }) {
    if (value == null || value.trim().isEmpty) return null;
    final num = double.tryParse(value.trim());
    if (num == null) {
      return '$field must be a number';
    }
    if (num <= 0) {
      return '$field must be greater than 0';
    }
    return null;
  }

  /// Non-negative number (>= 0)
  static String? nonNegativeNumber(
    String? value, {
    String field = 'Value',
  }) {
    if (value == null || value.trim().isEmpty) return null;
    final num = double.tryParse(value.trim());
    if (num == null) {
      return '$field must be a number';
    }
    if (num < 0) {
      return '$field cannot be negative';
    }
    return null;
  }

  /// Number within a range
  static String? numberRange(
    String? value, {
    required double min,
    required double max,
    String field = 'Value',
  }) {
    if (value == null || value.trim().isEmpty) return null;
    final num = double.tryParse(value.trim());
    if (num == null) {
      return '$field must be a number';
    }
    if (num < min) {
      return '$field must be at least $min';
    }
    if (num > max) {
      return '$field must be at most $max';
    }
    return null;
  }

  // =========================================================================
  // PET-SPECIFIC VALIDATORS
  // =========================================================================

  /// Pet name: required, 1-50 chars, letters/numbers/spaces/hyphens only
  static String? petName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Pet name is required';
    }
    final trimmed = value.trim();
    if (trimmed.isEmpty) return 'Pet name is required';
    if (trimmed.length > 50) return 'Pet name must be 50 characters or less';
    // Allow letters, numbers, spaces, hyphens
    final allowedChars = RegExp(r'^[a-zA-Z0-9\s\-]+$');
    if (!allowedChars.hasMatch(trimmed)) {
      return 'Pet name can only contain letters, numbers, spaces, and hyphens';
    }
    return null;
  }

  /// Weight: positive number, 0.1–1000 kg
  static String? weight(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final num = double.tryParse(value.trim());
    if (num == null) return 'Weight must be a valid number';
    if (num < 0.1) return 'Weight must be at least 0.1 kg';
    if (num > 1000) return 'Weight must be at most 1000 kg';
    return null;
  }

  /// Dosage: positive number, 0.01–10000 mg
  static String? dosage(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final num = double.tryParse(value.trim());
    if (num == null) return 'Dosage must be a valid number';
    if (num <= 0) return 'Dosage must be greater than 0';
    if (num > 10000) return 'Dosage must be at most 10000';
    return null;
  }

  /// Food amount: positive number, 1–10000 g
  static String? foodAmount(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final num = double.tryParse(value.trim());
    if (num == null) return 'Amount must be a valid number';
    if (num <= 0) return 'Amount must be greater than 0';
    if (num > 10000) return 'Amount must be at most 10000 g';
    return null;
  }

  /// Breed name: required, 1-100 chars
  static String? breed(String? value) {
    return charCount(value, min: 1, max: 100, field: 'Breed');
  }

  /// Vaccine name: required, 1-100 chars
  static String? vaccineName(String? value) {
    return charCount(value, min: 1, max: 100, field: 'Vaccine name');
  }

  /// Medication name: required, 1-100 chars
  static String? medicationName(String? value) {
    return charCount(value, min: 1, max: 100, field: 'Medication name');
  }

  /// Notes/description: optional, max 2000 chars
  static String? notes(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    if (value.length > 2000) return 'Notes must be 2000 characters or less';
    return null;
  }

  // =========================================================================
  // FAMILY / USER VALIDATORS
  // =========================================================================

  /// Family member name: required, 1-100 chars
  static String? memberName(String? value) {
    return charCount(value, min: 1, max: 100, field: 'Name');
  }

  /// User password: required, min 8 chars, at least 1 letter and 1 number
  static String? password(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Password is required';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    if (!RegExp(r'[A-Za-z]').hasMatch(value)) {
      return 'Password must contain at least one letter';
    }
    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'Password must contain at least one number';
    }
    return null;
  }

  /// Password confirmation: must match the given password
  static String? passwordMatch(String? value, String? confirmPassword) {
    if (value == null || value.trim().isEmpty) return null;
    if (confirmPassword == null || confirmPassword.trim().isEmpty) return null;
    if (value.trim() != confirmPassword.trim()) {
      return 'Passwords do not match';
    }
    return null;
  }

  // =========================================================================
  // COMBINED VALIDATORS
  // =========================================================================

  /// Combine multiple validators — returns first error found
  static String? combined(
    String? value,
    List<String? Function(String?)> validators,
  ) {
    for (final validator in validators) {
      final error = validator(value);
      if (error != null) return error;
    }
    return null;
  }

  /// Validator that returns null for empty values but validates if present
  /// (useful for optional fields with format requirements)
  static String? optional(String? Function(String?) validator, String? value) {
    if (value == null || value.trim().isEmpty) return null;
    return validator(value);
  }
}

/// Extension on [String?] for convenient validation in widgets
extension ValidatorsX on String? {
  /// Validate this value with a validator function
  String? validate(String? Function(String?) validator) {
    return validator(this);
  }

  /// Check if this string is a valid pet name
  bool get isValidPetName => Validators.petName(this) == null;

  /// Check if this string is a valid weight
  bool get isValidWeight => Validators.weight(this) == null;
}
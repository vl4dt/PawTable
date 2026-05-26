/// Form validation utilities
class Validators {
  Validators._();

  static String? required(String? value, {String field = 'This field'}) {
    if (value == null || value.trim().isEmpty) {
      return '$field is required';
    }
    return null;
  }

  static String? nonEmpty(String? value, {String field = 'This field'}) {
    if (value == null || value.trim().isEmpty) {
      return '$field cannot be empty';
    }
    return null;
  }

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

  static String? positiveNumber(String? value, {String field = 'Value'}) {
    if (value == null || value.trim().isEmpty) return null;
    final num = double.tryParse(value);
    if (num == null) {
      return '$field must be a number';
    }
    if (num <= 0) {
      return '$field must be greater than 0';
    }
    return null;
  }

  static String? nonNegativeNumber(String? value, {String field = 'Value'}) {
    if (value == null || value.trim().isEmpty) return null;
    final num = double.tryParse(value);
    if (num == null) {
      return '$field must be a number';
    }
    if (num < 0) {
      return '$field cannot be negative';
    }
    return null;
  }

  static String? maxCharCount(
    String? value, {
    int max = 255,
    String field = 'This field',
  }) {
    if (value == null || value.trim().isEmpty) return null;
    if (value.length > max) {
      return '$field must be less than $max characters';
    }
    return null;
  }

  static String? petName(String? value) {
    return required(value, field: 'Pet name');
  }

  static String? weight(String? value) {
    return positiveNumber(value, field: 'Weight');
  }
}

/// Base model with common serialization utilities for all entities
///
/// All domain models should extend this to ensure consistent
/// serialization (toJson/fromJson) and equality across the app.
abstract class BaseModel {
  const BaseModel();

  /// Convert model to JSON map (for Hive/SQLite/storage)
  Map<String, dynamic> toJson();

  /// Create model from JSON map
  factory BaseModel.fromJson(Map<String, dynamic> json) {
    throw UnimplementedError(
      'fromJson must be overridden. Use typed subclasses instead.',
    );
  }

  /// Deep equality check (override in subclasses with all fields)
  bool deepEquals(Object other) => runtimeType == other.runtimeType;

  /// Hash code for equality (override in subclasses)
  @override
  int get hashCode => runtimeType.hashCode;

  /// Convert to string representation (useful for debugging)
  @override
  String toString() => '$runtimeType: $toJson()';
}

/// Extension for convenient JSON parsing
extension JsonParser on Map<String, dynamic> {
  /// Safely get a string value
  String? str(String key) => this[key] as String?;

  /// Safely get an int value
  int? intVal(String key) {
    final v = this[key];
    return v is int ? v : v is String ? int.tryParse(v) : null;
  }

  /// Safely get a double value
  double? doubleVal(String key) {
    final v = this[key];
    return v is double ? v : v is num ? v.toDouble() : null;
  }

  /// Safely get a bool value
  bool? boolVal(String key) => this[key] as bool?;

  /// Safely get a DateTime value (ISO 8601 string)
  DateTime? dateTime(String key) {
    final v = str(key);
    if (v == null) return null;
    try {
      return DateTime.tryParse(v);
    } catch (_) {
      return null;
    }
  }

  /// Safely get a List of strings
  List<String>? stringList(String key) {
    final v = this[key];
    if (v is List) return v.cast<String>();
    return null;
  }
}

/// Mixin that provides static JSON parsing helper methods
class JsonHelpers {
  JsonHelpers._();

  /// Safely get a string value
  static String? str(Map<String, dynamic> json, String key) => json[key] as String?;

  /// Safely get an int value
  static int? intVal(Map<String, dynamic> json, String key) {
    final v = json[key];
    return v is int ? v : v is String ? int.tryParse(v) : null;
  }

  /// Safely get a double value
  static double? doubleVal(Map<String, dynamic> json, String key) {
    final v = json[key];
    return v is double ? v : v is num ? v.toDouble() : null;
  }

  /// Safely get a bool value
  static bool? boolVal(Map<String, dynamic> json, String key) => json[key] as bool?;

  /// Safely get a DateTime value (ISO 8601 string)
  static DateTime? dateTime(Map<String, dynamic> json, String key) {
    final v = str(json, key);
    if (v == null) return null;
    try {
      return DateTime.tryParse(v);
    } catch (_) {
      return null;
    }
  }

  /// Safely get a List of strings
  static List<String>? stringList(Map<String, dynamic> json, String key) {
    final v = json[key];
    if (v is List) return v.cast<String>();
    return null;
  }
}

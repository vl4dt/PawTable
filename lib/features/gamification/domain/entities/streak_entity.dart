import 'package:equatable/equatable.dart';
import '../../../../core/models/base_model.dart';
import '../../../../core/models/base_model.dart' show JsonHelpers;

/// Activity type that contributes to a streak
///
/// Each type has a unique integer code used for display logic in the UI layer.
/// This keeps the domain layer UI-independent.
enum StreakActivityType {
  feeding(0, 'Feeding'),
  medication(1, 'Medication'),
  vaccination(2, 'Vaccination'),
  weight(3, 'Weight Check'),
  behavior(4, 'Behavior Log'),
  water(5, 'Water Intake');

  final int code;
  final String label;
  const StreakActivityType(this.code, this.label);
}

/// Utility for serializing [StreakActivityType] to/from strings
extension StreakActivityTypeSerializer on StreakActivityType {
  /// Serialize to string name (for database)
  String toName() {
    switch (this) {
      case StreakActivityType.feeding:
        return 'feeding';
      case StreakActivityType.medication:
        return 'medication';
      case StreakActivityType.vaccination:
        return 'vaccination';
      case StreakActivityType.weight:
        return 'weight';
      case StreakActivityType.behavior:
        return 'behavior';
      case StreakActivityType.water:
        return 'water';
    }
  }

  /// Deserialize from string name (from database)
  static StreakActivityType fromName(String name) {
    switch (name) {
      case 'feeding':
        return StreakActivityType.feeding;
      case 'medication':
        return StreakActivityType.medication;
      case 'vaccination':
        return StreakActivityType.vaccination;
      case 'weight':
        return StreakActivityType.weight;
      case 'behavior':
        return StreakActivityType.behavior;
      case 'water':
        return StreakActivityType.water;
      default:
        return StreakActivityType.feeding;
    }
  }
}

/// Streak log entry — records that a pet had activity on a given day
class StreakEntity extends Equatable {
  final String id;
  final String petId;
  final String date; // YYYY-MM-DD
  final StreakActivityType activityType;
  final DateTime createdAt;

  const StreakEntity({
    required this.id,
    required this.petId,
    required this.date,
    required this.activityType,
    required this.createdAt,
  });

  StreakEntity copyWith({
    String? id,
    String? petId,
    String? date,
    StreakActivityType? activityType,
    DateTime? createdAt,
  }) {
    return StreakEntity(
      id: id ?? this.id,
      petId: petId ?? this.petId,
      date: date ?? this.date,
      activityType: activityType ?? this.activityType,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Convert to JSON for database storage
  Map<String, dynamic> toJson() => {
        'id': id,
        'petId': petId,
        'date': date,
        'activityType': activityType.toName(),
        'createdAt': createdAt.toIso8601String(),
      };

  /// Create from JSON (database map)
  factory StreakEntity.fromJson(Map<String, dynamic> json) {
    return StreakEntity(
      id: json['id'] as String,
      petId: json['petId'] as String,
      date: json['date'] as String,
      activityType: StreakActivityTypeSerializer.fromName(
        json['activityType'] as String,
      ),
      createdAt: JsonHelpers.dateTime(json, 'createdAt') ?? DateTime.now(),
    );
  }

  /// Create from a database row (Map)
  factory StreakEntity.fromDbRow(Map<String, dynamic> row) {
    return StreakEntity(
      id: row['id'] as String,
      petId: row['petId'] as String,
      date: row['date'] as String,
      activityType: StreakActivityTypeSerializer.fromName(
        row['activityType'] as String,
      ),
      createdAt: DateTime.parse(row['createdAt'] as String),
    );
  }

  @override
  List<Object?> get props => [id, petId, date, activityType];
}

/// Streak summary — aggregated view of a pet's streak data
class StreakSummary extends Equatable {
  final String petId;
  final int currentStreak; // days
  final int longestStreak; // days
  final int totalActiveDays; // total logs
  final DateTime lastActiveDate; // most recent activity
  final DateTime? firstActiveDate; // earliest activity

  StreakSummary({
    required this.petId,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.totalActiveDays = 0,
    DateTime? lastActiveDate,
    this.firstActiveDate,
  }) : lastActiveDate = lastActiveDate ?? DateTime(1970, 1, 1);

  /// Create with a default last active date of now (runtime)
  factory StreakSummary.now({
    required String petId,
    int currentStreak = 0,
    int longestStreak = 0,
    int totalActiveDays = 0,
    DateTime? firstActiveDate,
  }) {
    return StreakSummary(
      petId: petId,
      currentStreak: currentStreak,
      longestStreak: longestStreak,
      totalActiveDays: totalActiveDays,
      lastActiveDate: DateTime.now(),
      firstActiveDate: firstActiveDate,
    );
  }

  /// Human-readable streak description
  String get streakDescription {
    if (currentStreak == 0) return 'No active streak — log something today!';
    if (currentStreak == 1) return '🔥 1-day streak! Keep it going!';
    return '🔥 $currentStreak-day streak! Amazing!';
  }

  /// Get a progress indicator (0.0 to 1.0) for current streak toward milestones
  double progressToNextMilestone() {
    if (currentStreak == 0) return 0.0;
    const milestones = [7, 14, 21, 30, 60, 90, 180, 365];
    for (final milestone in milestones) {
      if (currentStreak < milestone) {
        return currentStreak / milestone;
      }
    }
    return 1.0;
  }

  @override
  List<Object?> get props =>
      [petId, currentStreak, longestStreak, totalActiveDays, lastActiveDate];
}

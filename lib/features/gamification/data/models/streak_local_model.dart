import 'package:equatable/equatable.dart';
import '../../domain/entities/streak_entity.dart';

/// Local storage model for streak logs — maps to SQLite `streak_logs` table
class StreakLocalModel extends Equatable {
  final String id;
  final String petId;
  final String date; // YYYY-MM-DD
  final String activityType;
  final DateTime createdAt;

  const StreakLocalModel({
    required this.id,
    required this.petId,
    required this.date,
    required this.activityType,
    required this.createdAt,
  });

  /// Convert to entity
  StreakEntity toEntity() {
    return StreakEntity(
      id: id,
      petId: petId,
      date: date,
      activityType: StreakActivityTypeSerializer.fromName(activityType),
      createdAt: createdAt,
    );
  }

  /// Create from database row (Map)
  factory StreakLocalModel.fromDbRow(Map<String, dynamic> row) {
    return StreakLocalModel(
      id: row['id'] as String,
      petId: row['petId'] as String,
      date: row['date'] as String,
      activityType: row['activityType'] as String,
      createdAt: DateTime.parse(row['createdAt'] as String),
    );
  }

  /// Convert to database map
  Map<String, dynamic> toDbMap() => {
        'id': id,
        'petId': petId,
        'date': date,
        'activityType': activityType,
        'createdAt': createdAt.toIso8601String(),
      };

  @override
  List<Object?> get props => [id, petId, date, activityType, createdAt];
}

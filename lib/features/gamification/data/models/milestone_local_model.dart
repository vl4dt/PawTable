import 'package:equatable/equatable.dart';
import '../../domain/entities/milestone_entity.dart';

/// Local storage model for milestone achievements — maps to SQLite table
class MilestoneLocalModel extends Equatable {
  final String id;
  final String petId;
  final String milestoneId;
  final double progress;
  final bool unlocked;
  final DateTime? unlockedAt;

  const MilestoneLocalModel({
    required this.id,
    required this.petId,
    required this.milestoneId,
    this.progress = 0.0,
    this.unlocked = false,
    this.unlockedAt,
  });

  /// Convert to entity
  MilestoneAchievement toEntity() {
    return MilestoneAchievement(
      id: id,
      petId: petId,
      milestoneId: milestoneId,
      progress: progress,
      unlocked: unlocked,
      unlockedAt: unlockedAt,
    );
  }

  /// Create from database row
  factory MilestoneLocalModel.fromDbRow(Map<String, dynamic> row) {
    return MilestoneLocalModel(
      id: row['id'] as String,
      petId: row['petId'] as String,
      milestoneId: row['milestoneId'] as String,
      progress: (row['progress'] as num).toDouble(),
      unlocked: (row['unlocked'] as int) == 1,
      unlockedAt: row['unlockedAt'] != null
          ? DateTime.parse(row['unlockedAt'] as String)
          : null,
    );
  }

  /// Convert to database map
  Map<String, dynamic> toDbMap() => {
        'id': id,
        'petId': petId,
        'milestoneId': milestoneId,
        'progress': progress,
        'unlocked': unlocked ? 1 : 0,
        'unlockedAt': unlockedAt?.toIso8601String(),
      };

  @override
  List<Object?> get props => [id, petId, milestoneId, progress, unlocked];
}

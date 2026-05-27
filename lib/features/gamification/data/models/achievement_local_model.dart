import '../../domain/entities/achievement_entity.dart';

/// Local storage model for achievement events
class AchievementEventLocalModel {
  final String id;
  final String petId;
  final String achievementType;
  final String achievementId;
  final int currentCount;
  final DateTime unlockedAt;

  const AchievementEventLocalModel({
    required this.id,
    required this.petId,
    required this.achievementType,
    required this.achievementId,
    required this.currentCount,
    required this.unlockedAt,
  });

  /// Convert to entity
  AchievementEvent toEntity() {
    return AchievementEvent(
      id: id,
      petId: petId,
      type: _parseType(achievementType),
      achievementId: achievementId,
      currentCount: currentCount,
      unlockedAt: unlockedAt,
    );
  }

  /// Create from database row
  factory AchievementEventLocalModel.fromDbRow(Map<String, dynamic> row) {
    return AchievementEventLocalModel(
      id: row['id'] as String,
      petId: row['petId'] as String,
      achievementType: row['achievementType'] as String,
      achievementId: row['achievementId'] as String,
      currentCount: (row['currentCount'] as num).toInt(),
      unlockedAt: DateTime.parse(row['unlockedAt'] as String),
    );
  }

  /// Convert to database map
  Map<String, dynamic> toDbMap() => {
        'id': id,
        'petId': petId,
        'achievementType': achievementType,
        'achievementId': achievementId,
        'currentCount': currentCount,
        'unlockedAt': unlockedAt.toIso8601String(),
      };

  static AchievementType _parseType(String name) {
    return AchievementType.values.firstWhere(
      (e) => e.name == name,
      orElse: () => AchievementType.streak,
    );
  }
}

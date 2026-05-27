import '../../../../core/repository/base_repository.dart';
import '../entities/achievement_entity.dart';

/// Repository for achievement events (unlock history)
abstract class AchievementEventRepository extends BaseRepository {
  /// Get all achievement events for a pet
  Future<List<AchievementEvent>> getEventsByPetId(String petId);

  /// Get achievement events filtered by type
  Future<List<AchievementEvent>> getEventsByType(
    String petId,
    AchievementType type,
  );

  /// Save an achievement event
  Future<void> saveEvent(AchievementEvent event);

  /// Delete all achievement events for a pet
  Future<void> deleteByPetId(String petId);
}

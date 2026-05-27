import '../../../../core/repository/base_repository.dart';
import '../entities/milestone_entity.dart';

/// Repository for milestone achievements
///
/// Manages milestone definitions (static game design) and user achievement
/// tracking (progress toward milestones, unlock events).
abstract class MilestoneRepository extends BaseRepository {
  /// Get all predefined milestone definitions
  Future<List<MilestoneDefinition>> getDefinitions();

  /// Get all achievements for a pet
  Future<List<MilestoneAchievement>> getAchievementsByPetId(String petId);

  /// Get a specific achievement for a pet
  Future<MilestoneAchievement?> getAchievement(String petId, String milestoneId);

  /// Get the milestone summary for a pet (aggregated data)
  Future<MilestoneSummary> getSummary(String petId);

  /// Save or update an achievement record
  Future<void> saveAchievement(MilestoneAchievement achievement);

  /// Update progress for a milestone (and check for unlock)
  Future<MilestoneAchievement?> updateProgress(
    String petId,
    String milestoneId,
    double progress,
  );

  /// Unlock a milestone achievement
  Future<MilestoneAchievement> unlockAchievement(
    String petId,
    String milestoneId,
  );

  /// Check and unlock all milestones that are earned based on current streak
  Future<List<MilestoneAchievement>> checkAndUnlockAll(String petId, int streak);

  /// Delete all milestone achievements for a pet
  Future<void> deleteByPetId(String petId);
}

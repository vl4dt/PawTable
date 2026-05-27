import '../../../../core/repository/base_repository.dart';
import '../entities/streak_entity.dart';

/// Repository interface for streak tracking data
abstract class StreakRepository extends ListRepository<StreakEntity> {
  /// Get all streak dates for a pet (for streak calculation)
  Future<List<String>> getDatesByPetId(String petId);

  /// Get streak data within a date range
  Future<List<StreakEntity>> getByDateRange(
    String petId, {
    required DateTime from,
    required DateTime to,
  });

  /// Check if there's an activity on a specific date
  Future<bool> hasActivityOnDate(String petId, String date);

  /// Calculate current streak (consecutive days up to today)
  Future<int> getCurrentStreak(String petId);

  /// Calculate longest streak ever
  Future<int> getLongestStreak(String petId);

  /// Get total active days (total streak log count)
  Future<int> getTotalActiveDays(String petId);

  /// Get the last active date
  Future<DateTime?> getLastActiveDate(String petId);

  /// Get the first active date
  Future<DateTime?> getFirstActiveDate(String petId);

  /// Get streak summary (all aggregated data)
  Future<StreakSummary> getSummary(String petId);

  /// Log a daily activity for a pet
  Future<void> logActivity(String petId, StreakActivityType type);

  /// Delete all streak data for a pet
  Future<void> deleteByPetId(String petId);
}

import '../../../../core/repository/base_repository.dart';
import '../entities/activity_feed_entity.dart';

/// Repository for activity feed data
abstract class ActivityFeedRepository extends BaseRepository {
  /// Insert a new activity feed entry
  Future<ActivityFeedEntry> insertEntry({
    required String groupId,
    required String userId,
    required String userName,
    required String petId,
    required String petName,
    required ActivityFeedType type,
    required String title,
    String description = '',
    Map<String, dynamic>? metadata,
    DateTime? timestamp,
  });

  /// Insert multiple activity feed entries
  Future<int> insertEntriesBatch(List<ActivityFeedEntry> entries);

  /// Get activity feed entries for a group, ordered by timestamp desc
  Future<List<ActivityFeedEntry>> getEntriesByGroup(
    String groupId, {
    int limit = 50,
    int offset = 0,
  });

  /// Get activity feed entries for a specific user in a group
  Future<List<ActivityFeedEntry>> getEntriesByUser(
    String groupId,
    String userId, {
    int limit = 50,
    int offset = 0,
  });

  /// Get activity feed entries for a specific pet in a group
  Future<List<ActivityFeedEntry>> getEntriesByPet(
    String groupId,
    String petId, {
    int limit = 50,
    int offset = 0,
  });

  /// Get total count of entries for a group
  Future<int> getCount(String groupId);

  /// Get count of entries for a group filtered by type
  Future<int> getCountByType(String groupId, ActivityFeedType type);

  /// Delete a single activity feed entry
  Future<int> deleteEntry(String id);

  /// Delete all activity feed entries for a group
  Future<int> deleteByGroup(String groupId);

  /// Get today's activity count for a group
  Future<int> getTodayCount(String groupId);

  /// Get this week's activity count for a group
  Future<int> getWeekCount(String groupId);

  /// Get this month's activity count for a group
  Future<int> getMonthCount(String groupId);

  /// Get unique active user IDs for a group
  Future<List<String>> getActiveUserIds(String groupId);

  /// Get unique active pet IDs for a group
  Future<List<String>> getActivePetIds(String groupId);

  /// Get activity feed summary statistics
  Future<ActivityFeedSummary> getSummary(String groupId);
}

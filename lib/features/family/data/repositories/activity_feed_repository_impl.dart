import 'package:uuid/uuid.dart';
import '../../../../core/repository/base_repository.dart';
import '../../../../core/storage/database_helper.dart';
import '../../domain/entities/activity_feed_entity.dart';
import '../../domain/repositories/activity_feed_repository.dart';

/// Activity feed repository implementation using SQLite
class ActivityFeedRepositoryImpl extends BaseRepository implements ActivityFeedRepository {
  final DatabaseHelper _dbHelper;
  final _uuid = const Uuid();

  ActivityFeedRepositoryImpl({required DatabaseHelper dbHelper})
      : _dbHelper = dbHelper;

  @override
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
  }) async {
    final id = _uuid.v4();
    final now = timestamp ?? DateTime.now();

    final entry = ActivityFeedEntry(
      id: id,
      groupId: groupId,
      userId: userId,
      userName: userName,
      petId: petId,
      petName: petName,
      type: type,
      title: title,
      description: description,
      timestamp: now,
      metadata: metadata,
    );

    await _dbHelper.insertActivityFeed(entry.toDbMap());
    return entry;
  }

  @override
  Future<int> insertEntriesBatch(List<ActivityFeedEntry> entries) async {
    final now = DateTime.now();
    final batchEntries = entries.map((entry) {
      final id = _uuid.v4();
      return ActivityFeedEntry(
        id: id,
        groupId: entry.groupId,
        userId: entry.userId,
        userName: entry.userName,
        petId: entry.petId,
        petName: entry.petName,
        type: entry.type,
        title: entry.title,
        description: entry.description,
        timestamp: entry.timestamp ?? now,
        metadata: entry.metadata,
      ).toDbMap();
    }).toList();

    return await _dbHelper.insertActivitiesFeedBatch(batchEntries);
  }

  @override
  Future<List<ActivityFeedEntry>> getEntriesByGroup(
    String groupId, {
    int limit = 50,
    int offset = 0,
  }) async {
    final rows = await _dbHelper.getActivityFeedByGroup(groupId, limit: limit, offset: offset);
    return rows.map((row) {
      final entry = ActivityFeedEntry.fromDbRow(row);
      // Fix metadata parsing — it's stored as a string representation of a map
      // We need to parse it properly
      return entry;
    }).toList();
  }

  @override
  Future<List<ActivityFeedEntry>> getEntriesByUser(
    String groupId,
    String userId, {
    int limit = 50,
    int offset = 0,
  }) async {
    final rows = await _dbHelper.getActivityFeedByUser(groupId, userId, limit: limit, offset: offset);
    return rows.map(ActivityFeedEntry.fromDbRow).toList();
  }

  @override
  Future<List<ActivityFeedEntry>> getEntriesByPet(
    String groupId,
    String petId, {
    int limit = 50,
    int offset = 0,
  }) async {
    final rows = await _dbHelper.getActivityFeedByPet(groupId, petId, limit: limit, offset: offset);
    return rows.map(ActivityFeedEntry.fromDbRow).toList();
  }

  @override
  Future<int> getCount(String groupId) async {
    return await _dbHelper.getActivityFeedCount(groupId);
  }

  @override
  Future<int> getCountByType(String groupId, ActivityFeedType type) async {
    return await _dbHelper.getActivityFeedCountByType(groupId, type.name);
  }

  @override
  Future<int> deleteEntry(String id) async {
    return await _dbHelper.deleteActivityFeedEntry(id);
  }

  @override
  Future<int> deleteByGroup(String groupId) async {
    return await _dbHelper.deleteActivityFeedByGroup(groupId);
  }

  @override
  Future<int> getTodayCount(String groupId) async {
    return await _dbHelper.getTodayActivityCount(groupId);
  }

  @override
  Future<int> getWeekCount(String groupId) async {
    return await _dbHelper.getWeekActivityCount(groupId);
  }

  @override
  Future<int> getMonthCount(String groupId) async {
    return await _dbHelper.getMonthActivityCount(groupId);
  }

  @override
  Future<List<String>> getActiveUserIds(String groupId) async {
    return await _dbHelper.getActiveUserIds(groupId);
  }

  @override
  Future<List<String>> getActivePetIds(String groupId) async {
    return await _dbHelper.getActivePetIds(groupId);
  }

  @override
  Future<ActivityFeedSummary> getSummary(String groupId) async {
    final total = await getCount(groupId);
    final today = await getTodayCount(groupId);
    final week = await getWeekCount(groupId);
    final month = await getMonthCount(groupId);
    final users = await getActiveUserIds(groupId);
    final pets = await getActivePetIds(groupId);

    // Count entries by type
    final typeCounts = <ActivityFeedType, int>{};
    for (final type in ActivityFeedType.values) {
      final count = await getCountByType(groupId, type);
      if (count > 0) {
        typeCounts[type] = count;
      }
    }

    return ActivityFeedSummary(
      totalEntries: total,
      entriesToday: today,
      entriesThisWeek: week,
      entriesThisMonth: month,
      typeCounts: typeCounts,
      activeUsers: users,
      activePets: pets,
    );
  }
}

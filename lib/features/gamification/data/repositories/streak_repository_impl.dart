import 'package:uuid/uuid.dart';

import '../../../../core/storage/database_helper.dart';
import '../../../../core/repository/base_repository.dart';
import '../../domain/entities/streak_entity.dart';
import '../../domain/repositories/streak_repository.dart';
import '../models/streak_local_model.dart';

/// Streak repository implementation using SQLite
class StreakRepositoryImpl extends BaseRepository implements StreakRepository {
  final DatabaseHelper _dbHelper;
  final _uuid = const Uuid();

  StreakRepositoryImpl({
    required DatabaseHelper dbHelper,
  }) : _dbHelper = dbHelper;

  @override
  Future<List<StreakEntity>> getAll() async {
    final rows = await _dbHelper.database.then(
      (db) => db.query('streak_logs', orderBy: 'date DESC'),
    );
    return rows.map(StreakLocalModel.fromDbRow).map((m) => m.toEntity()).toList();
  }

  @override
  Future<StreakEntity?> getById(String id) async {
    final rows = await _dbHelper.database.then(
      (db) => db.query('streak_logs', where: 'id = ?', whereArgs: [id]),
    );
    if (rows.isEmpty) return null;
    return StreakLocalModel.fromDbRow(rows.first).toEntity();
  }

  @override
  Future<void> save(StreakEntity item) async {
    final model = StreakLocalModel(
      id: item.id,
      petId: item.petId,
      date: item.date,
      activityType: item.activityType.toName(),
      createdAt: item.createdAt,
    );
    await _dbHelper.insertStreakLog(model.toDbMap());
  }

  @override
  Future<void> update(StreakEntity item) async {
    final model = StreakLocalModel(
      id: item.id,
      petId: item.petId,
      date: item.date,
      activityType: item.activityType.toName(),
      createdAt: item.createdAt,
    );
    await _dbHelper.updateStreakLog(model.id, model.toDbMap());
  }

  @override
  Future<void> delete(String id) async {
    await _dbHelper.deleteStreakLog(id);
  }

  @override
  Future<List<StreakEntity>> search(String query) async {
    // Search across petId and date fields
    final rows = await _dbHelper.database.then(
      (db) => db.query(
        'streak_logs',
        where: 'petId LIKE ? OR date LIKE ?',
        whereArgs: ['%$query%', '%$query%'],
        orderBy: 'date DESC',
      ),
    );
    return rows.map(StreakLocalModel.fromDbRow).map((m) => m.toEntity()).toList();
  }

  // =========================================================================
  // STREAK-SPECIFIC QUERIES
  // =========================================================================

  @override
  Future<List<String>> getDatesByPetId(String petId) async {
    final rows = await _dbHelper.getStreakDatesByPet(petId);
    return rows;
  }

  @override
  Future<List<StreakEntity>> getByDateRange(
    String petId, {
    required DateTime from,
    required DateTime to,
  }) async {
    final rows = await _dbHelper.getStreakLogsByPet(petId, from: from, to: to);
    return rows
        .map((row) {
          final model = StreakLocalModel.fromDbRow(row);
          return model.toEntity();
        })
        .toList();
  }

  @override
  Future<bool> hasActivityOnDate(String petId, String date) async {
    return await _dbHelper.hasStreakOnDate(petId, date);
  }

  /// Calculate current streak: consecutive days ending today (or yesterday)
  ///
  /// The streak is valid if today or yesterday has activity. Then counts
  /// consecutive days backward from the most recent active day.
  @override
  Future<int> getCurrentStreak(String petId) async {
    final dates = await getDatesByPetId(petId);
    if (dates.isEmpty) return 0;

    // Parse dates and sort descending
    final dateSet = dates
        .map((d) => DateTime.parse(d))
        .toSet()
        .toList()
      ..sort((a, b) => b.compareTo(a));

    final today = DateTime.now();
    final lastActive = dateSet.first;

    // Streak must include today or yesterday to be "active"
    final dayDiff = today.difference(lastActive).inDays;
    if (dayDiff > 1) return 0; // Streak broken

    // Count consecutive days backward from the most recent
    int streak = 1;
    for (int i = 0; i < dateSet.length - 1; i++) {
      final diff = dateSet[i].difference(dateSet[i + 1]).inDays;
      if (diff == 1) {
        streak++;
      } else if (diff > 1) {
        break; // Gap found
      }
    }

    return streak;
  }

  /// Calculate longest streak ever
  @override
  Future<int> getLongestStreak(String petId) async {
    final dates = await getDatesByPetId(petId);
    if (dates.isEmpty) return 0;

    // Parse dates and sort descending, unique
    final dateList = dates
        .map((d) => DateTime.parse(d))
        .toSet()
        .toList()
      ..sort((a, b) => b.compareTo(a));

    int longest = 1;
    int current = 1;

    for (int i = 0; i < dateList.length - 1; i++) {
      final diff = dateList[i].difference(dateList[i + 1]).inDays;
      if (diff == 1) {
        current++;
        if (current > longest) longest = current;
      } else if (diff > 1) {
        current = 1; // Gap
      }
    }

    return longest;
  }

  @override
  Future<int> getTotalActiveDays(String petId) async {
    final dates = await getDatesByPetId(petId);
    // Return unique date count
    return dates.toSet().length;
  }

  @override
  Future<DateTime?> getLastActiveDate(String petId) async {
    final dates = await getDatesByPetId(petId);
    if (dates.isEmpty) return null;
    return dates
        .map((d) => DateTime.parse(d))
        .reduce((a, b) => a.isAfter(b) ? a : b);
  }

  @override
  Future<DateTime?> getFirstActiveDate(String petId) async {
    final dates = await getDatesByPetId(petId);
    if (dates.isEmpty) return null;
    return dates
        .map((d) => DateTime.parse(d))
        .reduce((a, b) => a.isBefore(b) ? a : b);
  }

  /// Get full streak summary for a pet
  @override
  Future<StreakSummary> getSummary(String petId) async {
    final lastActive = await getLastActiveDate(petId);
    return StreakSummary(
      petId: petId,
      currentStreak: await getCurrentStreak(petId),
      longestStreak: await getLongestStreak(petId),
      totalActiveDays: await getTotalActiveDays(petId),
      lastActiveDate: lastActive ?? DateTime.now(),
      firstActiveDate: await getFirstActiveDate(petId),
    );
  }

  /// Log a daily activity for a pet — deduplicates by date
  @override
  Future<void> logActivity(String petId, StreakActivityType type) async {
    final today = DateTime.now();
    final dateStr =
        '${today.year.toString().padLeft(4, '0')}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

    // Check if already logged today
    final hasToday = await hasActivityOnDate(petId, dateStr);
    if (hasToday) {
      // Update existing entry to this activity type (most recent activity wins)
      final rows = await _dbHelper.getStreakLogsByPet(petId,
          from: DateTime.parse(dateStr), to: DateTime.parse(dateStr));
      if (rows.isNotEmpty) {
        await _dbHelper.updateStreakLog(rows.first['id'] as String, {
          'activityType': type.name,
          'date': dateStr,
        });
      }
      return;
    }

    // Insert new entry
    await _dbHelper.insertStreakLog({
      'id': _uuid.v4(),
      'petId': petId,
      'date': dateStr,
      'activityType': type.name,
      'createdAt': today.toIso8601String(),
    });
  }

  @override
  Future<void> deleteByPetId(String petId) async {
    await _dbHelper.deleteStreakLogsByPet(petId);
  }
}

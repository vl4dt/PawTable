import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/storage/database_helper.dart';
import '../../../../core/repository/base_repository.dart';
import '../../domain/entities/milestone_entity.dart';
import '../../domain/repositories/milestone_repository.dart';
import '../models/milestone_local_model.dart';

/// Milestone repository implementation using SQLite
///
/// Manages milestone achievement tracking — progress, unlocks, and summaries.
/// Milestone definitions (game design) are static in the domain layer;
/// this layer only handles user progress and unlock events.
class MilestoneRepositoryImpl implements MilestoneRepository {
  @override
  bool get isSyncing => false;

  @override
  String get syncStatus => '';
  final DatabaseHelper _dbHelper;
  final _uuid = const Uuid();

  MilestoneRepositoryImpl({required DatabaseHelper dbHelper})
      : _dbHelper = dbHelper;

  // ──────────────────────────────────────────────────────────────────────────
  // DEFINITIONS — read-only (game design constants)
  // ──────────────────────────────────────────────────────────────────────────

  @override
  Future<List<MilestoneDefinition>> getDefinitions() async {
    return MilestoneDefinition.all;
  }

  // ──────────────────────────────────────────────────────────────────────────
  // ACHIEVEMENT CRUD
  // ──────────────────────────────────────────────────────────────────────────

  @override
  Future<List<MilestoneAchievement>> getAchievementsByPetId(String petId) async {
    final rows = await _dbHelper.database.then((db) => db.query(
          'milestone_achievements',
          where: 'petId = ?',
          whereArgs: [petId],
          orderBy: 'unlocked DESC, progress DESC',
        ));
    return rows.map(MilestoneLocalModel.fromDbRow).map((m) => m.toEntity()).toList();
  }

  @override
  Future<MilestoneAchievement?> getAchievement(
      String petId, String milestoneId) async {
    final rows = await _dbHelper.database.then((db) => db.query(
          'milestone_achievements',
          where: 'petId = ? AND milestoneId = ?',
          whereArgs: [petId, milestoneId],
        ));
    if (rows.isEmpty) return null;
    return MilestoneLocalModel.fromDbRow(rows.first).toEntity();
  }

  @override
  Future<MilestoneSummary> getSummary(String petId) async {
    final achievements = await getAchievementsByPetId(petId);
    final definitions = await getDefinitions();
    final unlocked = achievements.where((a) => a.unlocked).toList();

    // Calculate best streak from the longest streak in achievements
    // We need to look up the streak repository for this — for now,
    // we derive it from the highest milestone unlocked.
    int bestStreak = 0;
    for (final achievement in unlocked) {
      final def = MilestoneDefinition.byId(achievement.milestoneId);
      if (def != null && def.requiredDays > bestStreak) {
        bestStreak = def.requiredDays;
      }
    }

    return MilestoneSummary(
      petId: petId,
      totalUnlocked: unlocked.length,
      bestStreak: bestStreak,
      achievements: achievements,
    );
  }

  @override
  Future<void> saveAchievement(MilestoneAchievement achievement) async {
    final model = MilestoneLocalModel(
      id: achievement.id,
      petId: achievement.petId,
      milestoneId: achievement.milestoneId,
      progress: achievement.progress,
      unlocked: achievement.unlocked,
      unlockedAt: achievement.unlockedAt,
    );
    final db = await _dbHelper.database;
    await db.insert('milestone_achievements', model.toDbMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // ──────────────────────────────────────────────────────────────────────────
  // PROGRESS & UNLOCKS
  // ──────────────────────────────────────────────────────────────────────────

  @override
  Future<MilestoneAchievement?> updateProgress(
    String petId,
    String milestoneId,
    double progress,
  ) async {
    // Clamp progress between 0 and 1
    progress = progress.clamp(0.0, 1.0);
    bool unlocked = progress >= 1.0;

    // Check if already exists
    final existing = await getAchievement(petId, milestoneId);
    final now = DateTime.now();

    MilestoneAchievement achievement;
    if (existing != null) {
      achievement = existing.copyWith(
        progress: progress,
        unlocked: unlocked,
        unlockedAt: unlocked && !existing.unlocked ? now : existing.unlockedAt,
      );
    } else {
      achievement = MilestoneAchievement(
        id: _uuid.v4(),
        petId: petId,
        milestoneId: milestoneId,
        progress: progress,
        unlocked: unlocked,
        unlockedAt: unlocked ? now : null,
      );
    }

    await saveAchievement(achievement);
    return achievement;
  }

  @override
  Future<MilestoneAchievement> unlockAchievement(
    String petId,
    String milestoneId,
  ) async {
    final existing = await getAchievement(petId, milestoneId);
    final now = DateTime.now();

    if (existing != null) {
      final updated = existing.copyWith(
        progress: 1.0,
        unlocked: true,
        unlockedAt: existing.unlockedAt ?? now,
      );
      await saveAchievement(updated);
      return updated;
    }

    final achievement = MilestoneAchievement(
      id: _uuid.v4(),
      petId: petId,
      milestoneId: milestoneId,
      progress: 1.0,
      unlocked: true,
      unlockedAt: now,
    );
    await saveAchievement(achievement);
    return achievement;
  }

  /// Check all milestones against the current streak and unlock any earned
  ///
  /// Returns the list of newly unlocked achievements.
  @override
  Future<List<MilestoneAchievement>> checkAndUnlockAll(
      String petId, int streak) async {
    final definitions = await getDefinitions();
    final newlyUnlocked = <MilestoneAchievement>[];

    for (final definition in definitions) {
      if (streak >= definition.requiredDays) {
        final achievement = await getAchievement(petId, definition.id);
        if (achievement == null || !achievement.unlocked) {
          final unlocked = await unlockAchievement(petId, definition.id);
          newlyUnlocked.add(unlocked);
        } else {
          // Already unlocked — just update progress to 1.0
          await updateProgress(petId, definition.id, 1.0);
        }
      }
    }

    return newlyUnlocked;
  }

  @override
  Future<void> deleteByPetId(String petId) async {
    final db = await _dbHelper.database;
    await db.delete('milestone_achievements',
        where: 'petId = ?', whereArgs: [petId]);
  }
}

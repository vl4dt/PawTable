import 'package:uuid/uuid.dart';
import '../entities/achievement_entity.dart';
import '../entities/milestone_entity.dart';
import '../entities/streak_entity.dart';
import '../repositories/achievement_event_repository.dart';
import '../repositories/milestone_repository.dart';
import '../repositories/streak_repository.dart';

/// Service that checks achievement conditions and triggers unlocks
///
/// This is the core unlock logic engine. It:
/// - Checks current counts for all achievement types
/// - Compares against defined thresholds
/// - Triggers unlocks when conditions are met
/// - Logs achievement events for unlocks
/// - Updates milestone progress
///
/// Usage:
/// ```dart
/// final service = AchievementUnlockService(...);
/// final newUnlocks = await service.checkAndUnlockAll('pet-123');
/// ```
class AchievementUnlockService {
  final StreakRepository _streakRepo;
  final AchievementEventRepository _eventRepo;
  final MilestoneRepository _milestoneRepo;
  final _uuid = const Uuid();

  /// Counts from various data sources
  final FeedingCountProvider _feedingProvider;
  final HealthCountProvider _healthProvider;
  final MedicationCountProvider _medicationProvider;
  final WeightCountProvider _weightProvider;
  final BehaviorCountProvider _behaviorProvider;

  AchievementUnlockService({
    required StreakRepository streakRepo,
    required AchievementEventRepository eventRepo,
    required MilestoneRepository milestoneRepo,
    required FeedingCountProvider feedingProvider,
    required HealthCountProvider healthProvider,
    required MedicationCountProvider medicationProvider,
    required WeightCountProvider weightProvider,
    required BehaviorCountProvider behaviorProvider,
  })  : _streakRepo = streakRepo,
        _eventRepo = eventRepo,
        _milestoneRepo = milestoneRepo,
        _feedingProvider = feedingProvider,
        _healthProvider = healthProvider,
        _medicationProvider = medicationProvider,
        _weightProvider = weightProvider,
        _behaviorProvider = behaviorProvider;

  /// Check all achievement conditions and unlock any that are earned
  ///
  /// Returns list of newly unlocked achievements with their events.
  Future<List<AchievementEvent>> checkAndUnlockAll(String petId) async {
    final newEvents = <AchievementEvent>[];

    // Load streak data
    final streakSummary = await _streakRepo.getSummary(petId);

    // Check all achievement types
    newEvents.addAll(await _checkStreakAchievements(petId, streakSummary));
    newEvents.addAll(await _checkFeedingAchievements(petId));
    newEvents.addAll(await _checkHealthAchievements(petId));
    newEvents.addAll(await _checkMedicationAchievements(petId));
    newEvents.addAll(await _checkWeightAchievements(petId));
    newEvents.addAll(await _checkBehaviorAchievements(petId));
    newEvents.addAll(await _checkFirstTimeAchievements(petId, streakSummary));

    // Update milestone progress based on streak
    await _milestoneRepo.checkAndUnlockAll(petId, streakSummary.currentStreak);

    return newEvents;
  }

  // ──────────────────────────────────────────────────────────────────────
  // Streak Achievement Checks
  // ──────────────────────────────────────────────────────────────────────

  Future<List<AchievementEvent>> _checkStreakAchievements(
    String petId,
    StreakSummary summary,
  ) async {
    final events = <AchievementEvent>[];
    final streak = summary.currentStreak;

    // Check against all streak-based milestone definitions
    for (final def in MilestoneDefinition.all) {
      if (streak >= def.requiredDays) {
        // Streak achievement unlocked
        final event = AchievementEvent(
          id: _uuid.v4(),
          petId: petId,
          type: AchievementType.streak,
          achievementId: def.id,
          currentCount: streak,
          unlockedAt: DateTime.now(),
        );
        await _eventRepo.saveEvent(event);
        events.add(event);
      }
    }

    return events;
  }

  // ──────────────────────────────────────────────────────────────────────
  // Feeding Achievement Checks
  // ──────────────────────────────────────────────────────────────────────

  Future<List<AchievementEvent>> _checkFeedingAchievements(
    String petId,
  ) async {
    final events = <AchievementEvent>[];
    final count = await _feedingProvider.getFeedingCount(petId);

    for (final def in AchievementDefinition.all) {
      if (def.type == AchievementType.feeding &&
          count >= def.requiredCount &&
          !await _isAlreadyUnlocked(petId, AchievementType.feeding, def.id)) {
        final event = AchievementEvent(
          id: _uuid.v4(),
          petId: petId,
          type: AchievementType.feeding,
          achievementId: def.id,
          currentCount: count,
          unlockedAt: DateTime.now(),
        );
        await _eventRepo.saveEvent(event);
        events.add(event);
      }
    }

    return events;
  }

  // ──────────────────────────────────────────────────────────────────────
  // Health Achievement Checks
  // ──────────────────────────────────────────────────────────────────────

  Future<List<AchievementEvent>> _checkHealthAchievements(
    String petId,
  ) async {
    final events = <AchievementEvent>[];
    final count = await _healthProvider.getHealthRecordCount(petId);

    for (final def in AchievementDefinition.all) {
      if (def.type == AchievementType.health &&
          count >= def.requiredCount &&
          !await _isAlreadyUnlocked(petId, AchievementType.health, def.id)) {
        final event = AchievementEvent(
          id: _uuid.v4(),
          petId: petId,
          type: AchievementType.health,
          achievementId: def.id,
          currentCount: count,
          unlockedAt: DateTime.now(),
        );
        await _eventRepo.saveEvent(event);
        events.add(event);
      }
    }

    return events;
  }

  // ──────────────────────────────────────────────────────────────────────
  // Medication Achievement Checks
  // ──────────────────────────────────────────────────────────────────────

  Future<List<AchievementEvent>> _checkMedicationAchievements(
    String petId,
  ) async {
    final events = <AchievementEvent>[];
    final count = await _medicationProvider.getMedicationCount(petId);

    for (final def in AchievementDefinition.all) {
      if (def.type == AchievementType.medication &&
          count >= def.requiredCount &&
          !await _isAlreadyUnlocked(
              petId, AchievementType.medication, def.id)) {
        final event = AchievementEvent(
          id: _uuid.v4(),
          petId: petId,
          type: AchievementType.medication,
          achievementId: def.id,
          currentCount: count,
          unlockedAt: DateTime.now(),
        );
        await _eventRepo.saveEvent(event);
        events.add(event);
      }
    }

    return events;
  }

  // ──────────────────────────────────────────────────────────────────────
  // Weight Achievement Checks
  // ──────────────────────────────────────────────────────────────────────

  Future<List<AchievementEvent>> _checkWeightAchievements(
    String petId,
  ) async {
    final events = <AchievementEvent>[];
    final count = await _weightProvider.getWeightLogCount(petId);

    for (final def in AchievementDefinition.all) {
      if (def.type == AchievementType.weight &&
          count >= def.requiredCount &&
          !await _isAlreadyUnlocked(petId, AchievementType.weight, def.id)) {
        final event = AchievementEvent(
          id: _uuid.v4(),
          petId: petId,
          type: AchievementType.weight,
          achievementId: def.id,
          currentCount: count,
          unlockedAt: DateTime.now(),
        );
        await _eventRepo.saveEvent(event);
        events.add(event);
      }
    }

    return events;
  }

  // ──────────────────────────────────────────────────────────────────────
  // Behavior Achievement Checks
  // ──────────────────────────────────────────────────────────────────────

  Future<List<AchievementEvent>> _checkBehaviorAchievements(
    String petId,
  ) async {
    final events = <AchievementEvent>[];
    final count = await _behaviorProvider.getBehaviorLogCount(petId);

    for (final def in AchievementDefinition.all) {
      if (def.type == AchievementType.behavior &&
          count >= def.requiredCount &&
          !await _isAlreadyUnlocked(
              petId, AchievementType.behavior, def.id)) {
        final event = AchievementEvent(
          id: _uuid.v4(),
          petId: petId,
          type: AchievementType.behavior,
          achievementId: def.id,
          currentCount: count,
          unlockedAt: DateTime.now(),
        );
        await _eventRepo.saveEvent(event);
        events.add(event);
      }
    }

    return events;
  }

  // ──────────────────────────────────────────────────────────────────────
  // First-Time Achievement Checks
  // ──────────────────────────────────────────────────────────────────────

  Future<List<AchievementEvent>> _checkFirstTimeAchievements(
    String petId,
    StreakSummary streakSummary,
  ) async {
    final events = <AchievementEvent>[];

    // First feeding
    if (streakSummary.totalActiveDays > 0) {
      if (!await _isAlreadyUnlocked(
          petId, AchievementType.firstTime, 'first_feeding')) {
        final event = AchievementEvent(
          id: _uuid.v4(),
          petId: petId,
          type: AchievementType.firstTime,
          achievementId: 'first_feeding',
          currentCount: 1,
          unlockedAt: DateTime.now(),
        );
        await _eventRepo.saveEvent(event);
        events.add(event);
      }
    }

    return events;
  }

  // ──────────────────────────────────────────────────────────────────────
  // Helpers
  // ──────────────────────────────────────────────────────────────────────

  /// Check if an achievement has already been unlocked
  Future<bool> _isAlreadyUnlocked(
    String petId,
    AchievementType type,
    String achievementId,
  ) async {
    final events = await _eventRepo.getEventsByType(petId, type);
    return events.any((e) => e.achievementId == achievementId);
  }
}

// ──────────────────────────────────────────────────────────────────────────
/// Count provider interfaces — abstract data sources for achievement counts
/// ──────────────────────────────────────────────────────────────────────────

abstract class FeedingCountProvider {
  Future<int> getFeedingCount(String petId);
}

abstract class HealthCountProvider {
  Future<int> getHealthRecordCount(String petId);
}

abstract class MedicationCountProvider {
  Future<int> getMedicationCount(String petId);
}

abstract class WeightCountProvider {
  Future<int> getWeightLogCount(String petId);
}

abstract class BehaviorCountProvider {
  Future<int> getBehaviorLogCount(String petId);
}

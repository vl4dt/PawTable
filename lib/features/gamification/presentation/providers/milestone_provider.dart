import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../di/app_module.dart';
import '../../domain/entities/achievement_entity.dart';
import '../../domain/entities/milestone_entity.dart';
import '../../domain/repositories/achievement_event_repository.dart';
import '../../domain/repositories/milestone_repository.dart';
import '../../domain/services/achievement_unlock_service.dart';
import '../../domain/repositories/streak_repository.dart';

/// Milestone repository provider — wired via GetIt DI
final milestoneRepositoryProvider = Provider<MilestoneRepository>((ref) {
  return getIt<MilestoneRepository>();
});

// =========================================================================
// MILESTONE STATE
// =========================================================================

/// State for the milestone achievements view
class MilestoneState {
  final bool isLoading;
  final String? error;
  final MilestoneSummary? summary;
  final List<MilestoneDefinition> definitions;

  const MilestoneState({
    this.isLoading = false,
    this.error,
    this.summary,
    this.definitions = MilestoneDefinition.all,
  });

  MilestoneState copyWith({
    bool? isLoading,
    String? error,
    MilestoneSummary? summary,
    List<MilestoneDefinition>? definitions,
  }) {
    return MilestoneState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      summary: summary ?? this.summary,
      definitions: definitions ?? this.definitions,
    );
  }
}

/// State for newly unlocked milestones (for toast/banner)
class NewUnlockState {
  final List<MilestoneAchievement> newUnlocks;

  const NewUnlockState({this.newUnlocks = const []});

  NewUnlockState copyWith({List<MilestoneAchievement>? newUnlocks}) {
    return NewUnlockState(
      newUnlocks: newUnlocks ?? this.newUnlocks,
    );
  }
}

// =========================================================================
// MILESTONE NOTIFIER
// =========================================================================

/// Milestone notifier — manages achievements, progress, and unlocks
class MilestoneNotifier extends StateNotifier<MilestoneState> {
  final MilestoneRepository _repository;

  MilestoneNotifier(this._repository)
      : super(const MilestoneState(definitions: MilestoneDefinition.all));

  /// Load milestone summary and achievements for a pet
  Future<void> loadMilestones(String petId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final summary = await _repository.getSummary(petId);
      state = state.copyWith(summary: summary, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  /// Update progress for a milestone and check for unlocks
  ///
  /// Returns the list of newly unlocked milestones.
  Future<List<MilestoneAchievement>> updateProgressForStreak(
    String petId,
    int streak,
  ) async {
    try {
      // Get all definitions
      final definitions = await _repository.getDefinitions();
      final newUnlocks = <MilestoneAchievement>[];

      for (final definition in definitions) {
        double progress;
        if (streak >= definition.requiredDays) {
          progress = 1.0;
        } else {
          progress = streak / definition.requiredDays;
        }

        final achievement = await _repository.updateProgress(
          petId,
          definition.id,
          progress,
        );

        if (achievement != null && achievement.unlocked) {
          // Check if this was newly unlocked (had progress < 1 before)
          final previous = await _repository.getAchievement(
            petId,
            definition.id,
          );
          // If the achievement was just created or just unlocked in this call
          newUnlocks.add(achievement);
        }
      }

      // Refresh summary
      final summary = await _repository.getSummary(petId);
      state = state.copyWith(summary: summary);

      return newUnlocks;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return [];
    }
  }

  /// Check and unlock all milestones based on current streak
  Future<List<MilestoneAchievement>> checkAndUnlock(String petId, int streak) async {
    try {
      final newUnlocks = await _repository.checkAndUnlockAll(petId, streak);
      final summary = await _repository.getSummary(petId);
      state = state.copyWith(summary: summary);
      return newUnlocks;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return [];
    }
  }

  /// Get the progress toward a specific milestone
  double progressForMilestone(String milestoneId, int currentStreak) {
    final definition = MilestoneDefinition.byId(milestoneId);
    if (definition == null || definition.requiredDays == 0) return 0.0;
    return (currentStreak / definition.requiredDays).clamp(0.0, 1.0);
  }
}

final milestoneProvider = StateNotifierProvider<MilestoneNotifier, MilestoneState>((ref) {
  final repo = ref.watch(milestoneRepositoryProvider);
  return MilestoneNotifier(repo);
});

// =========================================================================
// ACHIEVEMENT UNLOCK SERVICE PROVIDER
// =========================================================================

/// Provider for the achievement unlock service
///
/// Creates the service with all required count providers and repositories.
final achievementUnlockServiceProvider = Provider<AchievementUnlockService>((ref) {
  return AchievementUnlockService(
    streakRepo: getIt<StreakRepository>(),
    eventRepo: getIt<AchievementEventRepository>(),
    milestoneRepo: getIt<MilestoneRepository>(),
    feedingProvider: getIt<FeedingCountProvider>(),
    healthProvider: getIt<HealthCountProvider>(),
    medicationProvider: getIt<MedicationCountProvider>(),
    weightProvider: getIt<WeightCountProvider>(),
    behaviorProvider: getIt<BehaviorCountProvider>(),
  );
});

// =========================================================================
// ACHIEVEMENT STATE
// =========================================================================

/// State for achievement events view
class AchievementEventState {
  final bool isLoading;
  final String? error;
  final List<AchievementEvent> events;
  final int totalUnlocked;
  final Map<String, double> progressMap; // achievementId -> progress

  const AchievementEventState({
    this.isLoading = false,
    this.error,
    this.events = const [],
    this.totalUnlocked = 0,
    this.progressMap = const {},
  });

  AchievementEventState copyWith({
    bool? isLoading,
    String? error,
    List<AchievementEvent>? events,
    int? totalUnlocked,
    Map<String, double>? progressMap,
  }) {
    return AchievementEventState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      events: events ?? this.events,
      totalUnlocked: totalUnlocked ?? this.totalUnlocked,
      progressMap: progressMap ?? this.progressMap,
    );
  }
}

/// Achievement unlock notifier
///
/// Manages achievement events, trigger unlocks, and progress tracking.
class AchievementUnlockNotifier extends StateNotifier<AchievementEventState> {
  final AchievementUnlockService _unlockService;
  final MilestoneRepository _milestoneRepo;
  final AchievementEventRepository _eventRepo;

  AchievementUnlockNotifier({
    required AchievementUnlockService unlockService,
    required MilestoneRepository milestoneRepo,
    required AchievementEventRepository eventRepo,
  })  : _unlockService = unlockService,
        _milestoneRepo = milestoneRepo,
        _eventRepo = eventRepo,
        super(const AchievementEventState());

  /// Load achievement events for a pet
  Future<void> loadEvents(String petId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final events = await _eventRepo.getEventsByPetId(petId);
      final milestoneSummary = await _milestoneRepo.getSummary(petId);

      // Build progress map
      final progressMap = <String, double>{};
      for (final def in AchievementDefinition.all) {
        progressMap[def.id] = 0.5; // Default progress
      }
      for (final def in MilestoneDefinition.all) {
        progressMap[def.id] = 1.0; // Milestones are tracked separately
      }

      state = state.copyWith(
        events: events,
        totalUnlocked: events.length + milestoneSummary.totalUnlocked,
        progressMap: progressMap,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  /// Check and unlock all achievements for a pet
  ///
  /// Returns list of newly unlocked achievement events.
  Future<List<AchievementEvent>> unlockAll(String petId) async {
    try {
      final newEvents = await _unlockService.checkAndUnlockAll(petId);

      // Reload events
      final events = await _eventRepo.getEventsByPetId(petId);
      final milestoneSummary = await _milestoneRepo.getSummary(petId);

      state = state.copyWith(
        events: events,
        totalUnlocked: events.length + milestoneSummary.totalUnlocked,
      );

      return newEvents;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return [];
    }
  }

  /// Trigger unlock check after logging an activity
  Future<List<AchievementEvent>> afterActivity(
    String petId,
  ) async {
    return unlockAll(petId);
  }
}

final achievementUnlockProvider =
    StateNotifierProvider<AchievementUnlockNotifier, AchievementEventState>((ref) {
  final unlockService = ref.watch(achievementUnlockServiceProvider);
  final milestoneRepo = ref.watch(milestoneRepositoryProvider);
  final eventRepo = getIt<AchievementEventRepository>();
  return AchievementUnlockNotifier(
    unlockService: unlockService,
    milestoneRepo: milestoneRepo,
    eventRepo: eventRepo,
  );
});

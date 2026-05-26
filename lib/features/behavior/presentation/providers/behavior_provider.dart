import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../di/app_module.dart';
import '../../domain/entities/behavior_entity.dart';
import '../../domain/repositories/behavior_repository.dart';

/// Behavior repository provider
final behaviorRepositoryProvider = Provider<BehaviorRepository>((ref) {
  return getIt<BehaviorRepository>();
});

/// Behavior list state
class BehaviorListState {
  final bool isLoading;
  final String? error;
  final List<BehaviorLogEntity> logs;

  const BehaviorListState({
    this.isLoading = false,
    this.error,
    this.logs = const [],
  });

  BehaviorListState copyWith({
    bool? isLoading,
    String? error,
    List<BehaviorLogEntity>? logs,
  }) =>
      BehaviorListState(
        isLoading: isLoading ?? this.isLoading,
        error: error ?? this.error,
        logs: logs ?? this.logs,
      );
}

/// Behavior list notifier
class BehaviorListNotifier extends StateNotifier<BehaviorListState> {
  final BehaviorRepository _repository;

  BehaviorListNotifier(this._repository) : super(const BehaviorListState());

  Future<void> loadLogs(String petId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final logs = await _repository.getByPetId(petId);
      state = state.copyWith(logs: logs, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<void> addLog(BehaviorLogEntity log) async {
    try {
      await _repository.save(log);
      final current = List<BehaviorLogEntity>.from(state.logs);
      current.add(log);
      state = state.copyWith(logs: current);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> deleteLog(String id) async {
    try {
      await _repository.delete(id);
      final current = List<BehaviorLogEntity>.from(state.logs);
      current.removeWhere((l) => l.id == id);
      state = state.copyWith(logs: current);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Get today's most recent mood
  Mood? getTodayMood() {
    final now = DateTime.now();
    for (final log in state.logs) {
      if (log.loggedAt.year == now.year &&
          log.loggedAt.month == now.month &&
          log.loggedAt.day == now.day) {
        return log.mood;
      }
    }
    return null;
  }

  /// Get mood distribution for the last 7 days
  Map<Mood, int> getWeeklyMoodDistribution() {
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));
    final weekLogs = state.logs.where((l) {
      return l.loggedAt.isAfter(weekAgo);
    }).toList();

    final Map<Mood, int> distribution = {};
    for (final log in weekLogs) {
      distribution[log.mood] = (distribution[log.mood] ?? 0) + 1;
    }
    return distribution;
  }

  /// Get average wellness score for the last 7 days
  double getAverageWellnessScore() {
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));
    final weekLogs = state.logs.where((l) {
      return l.loggedAt.isAfter(weekAgo);
    }).toList();

    if (weekLogs.isEmpty) return 0;
    final total = weekLogs.fold<int>(
      0,
      (sum, log) => sum + log.getWellnessScore(),
    );
    return total / weekLogs.length;
  }
}

final behaviorListProvider =
    StateNotifierProvider<BehaviorListNotifier, BehaviorListState>((ref) {
  final repo = ref.watch(behaviorRepositoryProvider);
  return BehaviorListNotifier(repo);
});

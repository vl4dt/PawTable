import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../di/app_module.dart';
import '../../domain/entities/streak_entity.dart';
import '../../domain/repositories/streak_repository.dart';

/// Streak repository provider — wired via GetIt DI
final streakRepositoryProvider = Provider<StreakRepository>((ref) {
  return getIt<StreakRepository>();
});

// =========================================================================
// STREAK STATE
// =========================================================================

/// State for the streak summary view
class StreakState {
  final bool isLoading;
  final String? error;
  final StreakSummary? summary;
  final Map<String, List<StreakActivityType>> calendarData;
  // calendarData maps 'YYYY-MM-DD' -> list of activity types logged that day

  const StreakState({
    this.isLoading = false,
    this.error,
    this.summary,
    this.calendarData = const {},
  });

  StreakState copyWith({
    bool? isLoading,
    String? error,
    StreakSummary? summary,
    Map<String, List<StreakActivityType>>? calendarData,
  }) {
    return StreakState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      summary: summary ?? this.summary,
      calendarData: calendarData ?? this.calendarData,
    );
  }
}

/// Streak list state — for showing individual streak log entries
class StreakListState {
  final bool isLoading;
  final String? error;
  final List<StreakEntity> logs;

  const StreakListState({
    this.isLoading = false,
    this.error,
    this.logs = const [],
  });

  StreakListState copyWith({
    bool? isLoading,
    String? error,
    List<StreakEntity>? logs,
  }) {
    return StreakListState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      logs: logs ?? this.logs,
    );
  }
}

// =========================================================================
// STREAK NOTIFIERS
// =========================================================================

/// Streak summary notifier — manages streak stats and calendar data
class StreakSummaryNotifier extends StateNotifier<StreakState> {
  final StreakRepository _repository;

  StreakSummaryNotifier(this._repository) : super(const StreakState());

  /// Load streak summary and calendar data for a pet
  Future<void> loadSummary(String petId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final summary = await _repository.getSummary(petId);
      final dates = await _repository.getDatesByPetId(petId);

      // Build calendar data map
      final calendarData = <String, List<StreakActivityType>>{};
      for (final dateStr in dates) {
        calendarData[dateStr] = [StreakActivityType.feeding]; // Default
      }

      // Load activity details for the calendar
      final today = DateTime.now();
      final from = DateTime(today.year, today.month - 1, 1);
      final to = DateTime(today.year, today.month + 1, 0);
      final logs = await _repository.getByDateRange(petId, from: from, to: to);

      for (final log in logs) {
        calendarData.putIfAbsent(log.date, () => []).add(log.activityType);
      }

      state = state.copyWith(
        summary: summary,
        calendarData: calendarData,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  /// Log an activity for today
  Future<void> logActivity(String petId, StreakActivityType type) async {
    try {
      await _repository.logActivity(petId, type);
      // Refresh summary
      await loadSummary(petId);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Check if a date is in the streak (consecutive from today/yesterday)
  bool isStreakDay(String dateStr, List<String> streakDates) {
    return streakDates.contains(dateStr);
  }

  /// Get the 30-day history for calendar display
  List<Map<String, dynamic>> get30DayHistory() {
    if (state.calendarData.isEmpty) return [];

    final today = DateTime.now();
    final history = <Map<String, dynamic>>[];

    for (int i = 29; i >= 0; i--) {
      final date = today.subtract(Duration(days: i));
      final dateStr =
          '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      final activities = state.calendarData[dateStr] ?? [];
      final isActive = activities.isNotEmpty;

      history.add({
        'date': dateStr,
        'activities': activities,
        'isActive': isActive,
        'activityCount': activities.length,
        'isToday': i == 0,
        'isFuture': i < 0,
      });
    }

    return history;
  }
}

final streakSummaryProvider =
    StateNotifierProvider<StreakSummaryNotifier, StreakState>((ref) {
  final repo = ref.watch(streakRepositoryProvider);
  return StreakSummaryNotifier(repo);
});

/// Streak list notifier — manages individual streak log entries
class StreakListNotifier extends StateNotifier<StreakListState> {
  final StreakRepository _repository;

  StreakListNotifier(this._repository) : super(const StreakListState());

  /// Load streak logs for a pet within a date range
  Future<void> loadLogs(String petId, {DateTime? from, DateTime? to}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final logs =
          await _repository.getByDateRange(petId, from: from ?? DateTime(2000), to: to ?? DateTime(2100));
      state = state.copyWith(logs: logs, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  /// Delete a streak log entry
  Future<void> deleteLog(String id) async {
    try {
      await _repository.delete(id);
      final current = List<StreakEntity>.from(state.logs);
      current.removeWhere((l) => l.id == id);
      state = state.copyWith(logs: current);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
}

final streakListProvider =
    StateNotifierProvider<StreakListNotifier, StreakListState>((ref) {
  final repo = ref.watch(streakRepositoryProvider);
  return StreakListNotifier(repo);
});

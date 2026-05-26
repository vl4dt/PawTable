import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../di/app_module.dart';
import '../../domain/entities/feeding_entity.dart';
import '../../domain/repositories/feeding_repository.dart';

/// Feeding repository provider — wired via GetIt DI
final feedingRepositoryProvider = Provider<FeedingRepository>((ref) {
  return getIt<FeedingRepository>();
});

/// Feeding list state
class FeedingListState {
  final bool isLoading;
  final String? error;
  final List<FeedingEntity> logs;

  const FeedingListState({
    this.isLoading = false,
    this.error,
    this.logs = const [],
  });

  FeedingListState copyWith({
    bool? isLoading,
    String? error,
    List<FeedingEntity>? logs,
  }) =>
      FeedingListState(
        isLoading: isLoading ?? this.isLoading,
        error: error ?? this.error,
        logs: logs ?? this.logs,
      );
}

/// Feeding list state notifier
class FeedingListNotifier extends StateNotifier<FeedingListState> {
  final FeedingRepository _repository;

  FeedingListNotifier(this._repository) : super(const FeedingListState());

  Future<void> loadLogs(String petId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final logs = await _repository.getByPetId(petId);
      state = state.copyWith(logs: logs, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<void> addLog(FeedingEntity log) async {
    try {
      await _repository.save(log);
      final current = List<FeedingEntity>.from(state.logs);
      current.add(log);
      state = state.copyWith(logs: current);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> deleteLog(String id) async {
    try {
      await _repository.delete(id);
      final current = List<FeedingEntity>.from(state.logs);
      current.removeWhere((l) => l.id == id);
      state = state.copyWith(logs: current);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Get today's feeding summary
  Map<String, dynamic> getTodaySummary(DateTime today) {
    final todayLogs = state.logs.where((log) {
      final logDate = log.fedAt;
      return logDate.year == today.year &&
          logDate.month == today.month &&
          logDate.day == today.day;
    }).toList();

    final totalGrams = todayLogs.fold<double>(
      0,
      (sum, log) => sum + log.amountGrams,
    );

    final mealTypes = todayLogs.map((l) => l.type.name).toList();

    return {
      'count': todayLogs.length,
      'totalGrams': totalGrams,
      'mealTypes': mealTypes,
    };
  }
}

final feedingListProvider =
    StateNotifierProvider<FeedingListNotifier, FeedingListState>((ref) {
  final repo = ref.watch(feedingRepositoryProvider);
  return FeedingListNotifier(repo);
});

/// Feed type for UI
enum FeedType {
  dry('Dry Food', Icons.grain),
  wet('Wet Food', Icons.dinner_dining),
  raw('Raw', Icons.waves),
  homemade('Homemade', Icons.kitchen),
  treat('Treat', Icons.cookie),
  supplement('Supplement', Icons.medication);

  final String label;
  final IconData icon;
  const FeedType(this.label, this.icon);
}

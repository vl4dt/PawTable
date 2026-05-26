import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../di/app_module.dart';
import '../../../../di/providers.dart';
import '../../domain/entities/medication_entity.dart';
import '../../domain/repositories/medication_repository.dart';

/// Medication repository provider
final medicationRepositoryProvider = Provider<MedicationRepository>((ref) {
  return getIt<MedicationRepository>();
});

/// Medication list state
class MedicationListState {
  final bool isLoading;
  final String? error;
  final List<MedicationEntity> records;

  const MedicationListState({
    this.isLoading = false,
    this.error,
    this.records = const [],
  });

  MedicationListState copyWith({
    bool? isLoading,
    String? error,
    List<MedicationEntity>? records,
  }) =>
      MedicationListState(
        isLoading: isLoading ?? this.isLoading,
        error: error ?? this.error,
        records: records ?? this.records,
      );
}

/// Medication list notifier
class MedicationListNotifier extends StateNotifier<MedicationListState> {
  final MedicationRepository _repository;

  MedicationListNotifier(this._repository)
      : super(const MedicationListState());

  Future<void> loadRecords(String petId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final records = await _repository.getByPetId(petId);
      state = state.copyWith(records: records, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<void> addRecord(MedicationEntity record) async {
    try {
      await _repository.save(record);
      final current = List<MedicationEntity>.from(state.records);
      current.add(record);
      state = state.copyWith(records: current);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> markTaken(String id) async {
    try {
      final current = List<MedicationEntity>.from(state.records);
      final index = current.indexWhere((r) => r.id == id);
      if (index >= 0) {
        current[index] = current[index].copyWith(
          taken: true,
          takenAt: DateTime.now(),
        );
        state = state.copyWith(records: current);
      }
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> markUntaken(String id) async {
    try {
      final current = List<MedicationEntity>.from(state.records);
      final index = current.indexWhere((r) => r.id == id);
      if (index >= 0) {
        current[index] = current[index].copyWith(taken: false, takenAt: null);
        state = state.copyWith(records: current);
      }
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> deleteRecord(String id) async {
    try {
      await _repository.delete(id);
      final current = List<MedicationEntity>.from(state.records);
      current.removeWhere((r) => r.id == id);
      state = state.copyWith(records: current);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Get active medications
  List<MedicationEntity> getActive() {
    final now = DateTime.now();
    return state.records.where((r) {
      return !r.taken &&
          (r.endDate == null || now.isBefore(r.endDate!));
    }).toList();
  }

  /// Get adherence rate
  double getAdherenceRate() {
    if (state.records.isEmpty) return 100;
    final taken = state.records.where((r) => r.taken).length;
    return (taken / state.records.length * 100);
  }

  /// Get today's adherence stats
  Map<String, dynamic> getTodayStats() {
    final now = DateTime.now();
    final todayRecords = state.records.where((r) {
      return r.scheduledAt.year == now.year &&
          r.scheduledAt.month == now.month &&
          r.scheduledAt.day == now.day;
    }).toList();

    final taken = todayRecords.where((r) => r.taken).length;

    return {
      'total': todayRecords.length,
      'taken': taken,
      'pending': todayRecords.length - taken,
      'adherence': todayRecords.isEmpty ? 100 : (taken / todayRecords.length * 100),
    };
  }
}

final medicationListProvider =
    StateNotifierProvider<MedicationListNotifier, MedicationListState>((ref) {
  final repo = ref.watch(medicationRepositoryProvider);
  return MedicationListNotifier(repo);
});

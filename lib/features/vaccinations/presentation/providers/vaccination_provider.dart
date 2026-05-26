import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../di/app_module.dart';
import '../../domain/entities/vaccination_entity.dart';
import '../../domain/repositories/vaccination_repository.dart';

/// Vaccination repository provider
final vaccinationRepositoryProvider = Provider<VaccinationRepository>((ref) {
  return getIt<VaccinationRepository>();
});

/// Vaccination list state
class VaccinationListState {
  final bool isLoading;
  final String? error;
  final List<VaccinationEntity> records;

  const VaccinationListState({
    this.isLoading = false,
    this.error,
    this.records = const [],
  });

  VaccinationListState copyWith({
    bool? isLoading,
    String? error,
    List<VaccinationEntity>? records,
  }) =>
      VaccinationListState(
        isLoading: isLoading ?? this.isLoading,
        error: error ?? this.error,
        records: records ?? this.records,
      );
}

/// Vaccination list notifier
class VaccinationListNotifier extends StateNotifier<VaccinationListState> {
  final VaccinationRepository _repository;

  VaccinationListNotifier(this._repository)
      : super(const VaccinationListState());

  Future<void> loadRecords(String petId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final records = await _repository.getByPetId(petId);
      state = state.copyWith(records: records, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<void> addRecord(VaccinationEntity record) async {
    try {
      await _repository.save(record);
      final current = List<VaccinationEntity>.from(state.records);
      current.add(record);
      state = state.copyWith(records: current);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> deleteRecord(String id) async {
    try {
      await _repository.delete(id);
      final current = List<VaccinationEntity>.from(state.records);
      current.removeWhere((r) => r.id == id);
      state = state.copyWith(records: current);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Get upcoming vaccinations
  List<VaccinationEntity> getUpcoming() {
    final now = DateTime.now();
    final oneYear = now.add(const Duration(days: 365));
    return state.records
        .where((r) =>
            r.nextDueDate != null &&
            r.nextDueDate!.isAfter(now) &&
            r.nextDueDate!.isBefore(oneYear))
        .toList()
      ..sort((a, b) => a.nextDueDate!.compareTo(b.nextDueDate!));
  }

  /// Get overdue vaccinations
  List<VaccinationEntity> getOverdue() {
    return state.records.where((r) => r.isDue).toList();
  }

  /// Get vaccination statistics
  Map<String, dynamic> getStats() {
    final now = DateTime.now();
    final overdue = getOverdue();
    final upcoming = getUpcoming();
    final total = state.records.length;

    int upToDose = 0;
    for (final r in state.records) {
      final due = r.nextDueDate;
      if (due != null) {
        final months = (now.year - due.year) * 12 + (now.month - due.month);
        if (months <= 0) upToDose++;
      }
    }

    return {
      'total': total,
      'overdue': overdue.length,
      'upcoming': upcoming.length,
      'upToDate': upToDose,
    };
  }
}

final vaccinationListProvider =
    StateNotifierProvider<VaccinationListNotifier, VaccinationListState>(
        (ref) {
  final repo = ref.watch(vaccinationRepositoryProvider);
  return VaccinationListNotifier(repo);
});

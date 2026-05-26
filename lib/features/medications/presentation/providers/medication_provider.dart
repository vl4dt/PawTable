import 'package:flutter_riverpod/flutter_riverpod.dart';

final medicationRepositoryProvider = Provider((ref) => throw UnimplementedError('Configure DI'));

class MedicationListState {
  final bool isLoading;
  final String? error;
  const MedicationListState({this.isLoading = false, this.error});
  MedicationListState copyWith({bool? isLoading, String? error}) =>
      MedicationListState(isLoading: isLoading ?? this.isLoading, error: error ?? this.error);
}

final medicationListProvider = StateNotifierProvider<StateNotifier<MedicationListState>, MedicationListState>((ref) {
  throw UnimplementedError('Configure DI');
});

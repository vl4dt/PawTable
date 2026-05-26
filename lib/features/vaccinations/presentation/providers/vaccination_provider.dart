import 'package:flutter_riverpod/flutter_riverpod.dart';

final vaccinationRepositoryProvider = Provider((ref) => throw UnimplementedError('Configure DI'));

class VaccinationListState {
  final bool isLoading;
  final String? error;
  const VaccinationListState({this.isLoading = false, this.error});
  VaccinationListState copyWith({bool? isLoading, String? error}) =>
      VaccinationListState(isLoading: isLoading ?? this.isLoading, error: error ?? this.error);
}

final vaccinationListProvider = StateNotifierProvider<StateNotifier<VaccinationListState>, VaccinationListState>((ref) {
  throw UnimplementedError('Configure DI');
});

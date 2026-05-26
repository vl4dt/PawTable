import 'package:flutter_riverpod/flutter_riverpod.dart';

final healthRepositoryProvider = Provider((ref) => throw UnimplementedError('Configure DI'));

class HealthListState {
  final bool isLoading;
  final String? error;
  const HealthListState({this.isLoading = false, this.error});
  HealthListState copyWith({bool? isLoading, String? error}) =>
      HealthListState(isLoading: isLoading ?? this.isLoading, error: error ?? this.error);
}

final healthListProvider = StateNotifierProvider<StateNotifier<HealthListState>, HealthListState>((ref) {
  throw UnimplementedError('Configure DI');
});

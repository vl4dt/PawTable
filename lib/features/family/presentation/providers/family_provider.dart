import 'package:flutter_riverpod/flutter_riverpod.dart';

final familyRepositoryProvider = Provider((ref) => throw UnimplementedError('Configure DI'));

class FamilyState {
  final bool isLoading;
  final String? error;
  const FamilyState({this.isLoading = false, this.error});
  FamilyState copyWith({bool? isLoading, String? error}) =>
      FamilyState(isLoading: isLoading ?? this.isLoading, error: error ?? this.error);
}

final familyListProvider = StateNotifierProvider<StateNotifier<FamilyState>, FamilyState>((ref) {
  throw UnimplementedError('Configure DI');
});

import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Feeding repository provider
final feedingRepositoryProvider = Provider((ref) => throw UnimplementedError('Configure DI'));

/// Feeding list state
class FeedingListState {
  final bool isLoading;
  final String? error;

  const FeedingListState({this.isLoading = false, this.error});

  FeedingListState copyWith({bool? isLoading, String? error}) =>
      FeedingListState(isLoading: isLoading ?? this.isLoading, error: error ?? this.error);
}

final feedingListProvider = StateNotifierProvider<StateNotifier<FeedingListState>, FeedingListState>((ref) {
  throw UnimplementedError('Configure DI');
});

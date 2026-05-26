import 'package:flutter_riverpod/flutter_riverpod.dart';

final trackingRepositoryProvider = Provider((ref) => throw UnimplementedError('Configure DI'));

class TrackingListState {
  final bool isLoading;
  final String? error;
  const TrackingListState({this.isLoading = false, this.error});
  TrackingListState copyWith({bool? isLoading, String? error}) =>
      TrackingListState(isLoading: isLoading ?? this.isLoading, error: error ?? this.error);
}

final trackingListProvider = StateNotifierProvider<StateNotifier<TrackingListState>, TrackingListState>((ref) {
  throw UnimplementedError('Configure DI');
});

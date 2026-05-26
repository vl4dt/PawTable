import 'package:flutter_riverpod/flutter_riverpod.dart';

final billingServiceProvider = Provider((ref) => throw UnimplementedError('Configure DI'));

class PremiumState {
  final bool isLoading;
  final bool isPremium;
  final bool isFamily;
  final String? error;

  const PremiumState({
    this.isLoading = false,
    this.isPremium = false,
    this.isFamily = false,
    this.error,
  });

  PremiumState copyWith({
    bool? isLoading,
    bool? isPremium,
    bool? isFamily,
    String? error,
  }) => PremiumState(
    isLoading: isLoading ?? this.isLoading,
    isPremium: isPremium ?? this.isPremium,
    isFamily: isFamily ?? this.isFamily,
    error: error ?? this.error,
  );
}

final premiumProvider = StateNotifierProvider<StateNotifier<PremiumState>, PremiumState>((ref) {
  throw UnimplementedError('Configure DI');
});

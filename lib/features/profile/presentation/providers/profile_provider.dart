import 'package:flutter_riverpod/flutter_riverpod.dart';

final profileProvider = StateNotifierProvider<StateNotifier<ProfileState>, ProfileState>((ref) {
  throw UnimplementedError('Configure DI');
});

class ProfileState {
  final String? displayName;
  final String? email;
  final String? avatarUri;
  final bool isLoading;
  final String? error;

  const ProfileState({
    this.displayName,
    this.email,
    this.avatarUri,
    this.isLoading = false,
    this.error,
  });

  ProfileState copyWith({
    String? displayName,
    String? email,
    String? avatarUri,
    bool? isLoading,
    String? error,
  }) => ProfileState(
    displayName: displayName ?? this.displayName,
    email: email ?? this.email,
    avatarUri: avatarUri ?? this.avatarUri,
    isLoading: isLoading ?? this.isLoading,
    error: error ?? this.error,
  );
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Global app state that persists across the entire app
class AppState {
  final ThemeMode themeMode;
  final String? selectedLanguage;
  final bool isOnboardingComplete;
  final int notificationReminderHours;

  const AppState({
    this.themeMode = ThemeMode.system,
    this.selectedLanguage,
    this.isOnboardingComplete = false,
    this.notificationReminderHours = 24,
  });

  AppState copyWith({
    ThemeMode? themeMode,
    String? selectedLanguage,
    bool? isOnboardingComplete,
    int? notificationReminderHours,
  }) {
    return AppState(
      themeMode: themeMode ?? this.themeMode,
      selectedLanguage: selectedLanguage ?? this.selectedLanguage,
      isOnboardingComplete: isOnboardingComplete ?? this.isOnboardingComplete,
      notificationReminderHours: notificationReminderHours ?? this.notificationReminderHours,
    );
  }
}

/// AsyncNotifier for app state
class AppStateNotifier extends AsyncNotifier<AppState> {
  @override
  Future<AppState> build() async {
    // TODO: Load from Hive/SharedPreferences
    return const AppState();
  }

  /// Toggle theme mode
  Future<void> toggleTheme() async {
    final current = state.when(
      data: (s) => s,
      loading: () => const AppState(),
      error: (_, __) => const AppState(),
    );
    final newTheme = current.themeMode == ThemeMode.light
        ? ThemeMode.dark
        : ThemeMode.light;
    state = AsyncData(current.copyWith(themeMode: newTheme));
    // TODO: Persist to storage
  }

  /// Set onboarding completion status
  Future<void> completeOnboarding() async {
    final current = state.when(
      data: (s) => s,
      loading: () => const AppState(),
      error: (_, __) => const AppState(),
    );
    state = AsyncData(current.copyWith(isOnboardingComplete: true));
    // TODO: Persist to storage
  }

  /// Set notification reminder interval
  Future<void> setReminderHours(int hours) async {
    final current = state.when(
      data: (s) => s,
      loading: () => const AppState(),
      error: (_, __) => const AppState(),
    );
    state = AsyncData(current.copyWith(notificationReminderHours: hours));
    // TODO: Persist to storage
  }
}

final appStateProvider = AsyncNotifierProvider<AppStateNotifier, AppState>(
  AppStateNotifier.new,
);

/// Convenience providers for common app state queries
final themeModeProvider = Provider<ThemeMode>((ref) {
  return ref.watch(appStateProvider).maybeWhen(
    data: (state) => state.themeMode,
    orElse: () => ThemeMode.system,
  );
});

final isOnboardingProvider = Provider<bool>((ref) {
  return ref.watch(appStateProvider).maybeWhen(
    data: (state) => state.isOnboardingComplete,
    orElse: () => false,
  );
});

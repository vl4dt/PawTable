import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/notification_engagement_strategy.dart';

// =========================================================================
// ENGAGEMENT SETTINGS
// =========================================================================

/// User's notification engagement preferences
class EngagementSettings {
  final QuietHoursConfig quietHours;
  final bool frequencyCapping;
  final bool personalizedReminders;
  final bool streakNotifications;
  final bool milestoneNotifications;
  final bool wellnessTips;
  final bool familyReminders;

  const EngagementSettings({
    this.quietHours = const QuietHoursConfig(),
    this.frequencyCapping = true,
    this.personalizedReminders = true,
    this.streakNotifications = true,
    this.milestoneNotifications = true,
    this.wellnessTips = true,
    this.familyReminders = true,
  });

  EngagementSettings copyWith({
    QuietHoursConfig? quietHours,
    bool? frequencyCapping,
    bool? personalizedReminders,
    bool? streakNotifications,
    bool? milestoneNotifications,
    bool? wellnessTips,
    bool? familyReminders,
  }) {
    return EngagementSettings(
      quietHours: quietHours ?? this.quietHours,
      frequencyCapping: frequencyCapping ?? this.frequencyCapping,
      personalizedReminders: personalizedReminders ?? this.personalizedReminders,
      streakNotifications: streakNotifications ?? this.streakNotifications,
      milestoneNotifications: milestoneNotifications ?? this.milestoneNotifications,
      wellnessTips: wellnessTips ?? this.wellnessTips,
      familyReminders: familyReminders ?? this.familyReminders,
    );
  }

  bool shouldSend(NotificationType type) {
    switch (type) {
      case NotificationType.feedingReminder:
      case NotificationType.medicationReminder:
      case NotificationType.vaccinationReminder:
      case NotificationType.weightCheckReminder:
      case NotificationType.healthCheckReminder:
        return true; // Core reminders always on
      case NotificationType.streakAlert:
        return streakNotifications;
      case NotificationType.milestoneAchieved:
      case NotificationType.achievementUnlocked:
        return milestoneNotifications;
      case NotificationType.wellnessTip:
        return wellnessTips;
      case NotificationType.winBackReminder:
        return true; // Always send win-back
      case NotificationType.familyReminder:
        return familyReminders;
    }
  }
}

// =========================================================================
// PROVIDER
// =========================================================================

/// State for notification engagement settings
class EngagementSettingsState {
  final EngagementSettings settings;
  final bool isLoading;

  const EngagementSettingsState({
    this.settings = const EngagementSettings(),
    this.isLoading = false,
  });

  EngagementSettingsState copyWith({
    EngagementSettings? settings,
    bool? isLoading,
  }) {
    return EngagementSettingsState(
      settings: settings ?? this.settings,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

/// Provider managing notification engagement settings
class EngagementSettingsNotifier extends StateNotifier<EngagementSettingsState> {
  EngagementSettingsNotifier() : super(const EngagementSettingsState());

  /// Update quiet hours
  void updateQuietHours(QuietHoursConfig config) {
    state = state.copyWith(
      settings: state.settings.copyWith(quietHours: config),
    );
  }

  /// Toggle frequency capping
  void toggleFrequencyCapping(bool enabled) {
    state = state.copyWith(
      settings: state.settings.copyWith(frequencyCapping: enabled),
    );
  }

  /// Toggle streak notifications
  void toggleStreakNotifications(bool enabled) {
    state = state.copyWith(
      settings: state.settings.copyWith(streakNotifications: enabled),
    );
  }

  /// Toggle milestone notifications
  void toggleMilestoneNotifications(bool enabled) {
    state = state.copyWith(
      settings: state.settings.copyWith(milestoneNotifications: enabled),
    );
  }

  /// Toggle wellness tips
  void toggleWellnessTips(bool enabled) {
    state = state.copyWith(
      settings: state.settings.copyWith(wellnessTips: enabled),
    );
  }

  /// Toggle family reminders
  void toggleFamilyReminders(bool enabled) {
    state = state.copyWith(
      settings: state.settings.copyWith(familyReminders: enabled),
    );
  }
}

final engagementSettingsProvider =
    StateNotifierProvider<EngagementSettingsNotifier, EngagementSettingsState>(
  (ref) => EngagementSettingsNotifier(),
);

// =========================================================================
// SCHEDULER PROVIDER
// =========================================================================

/// Provides a singleton NotificationScheduler instance
final notificationSchedulerProvider = Provider<NotificationScheduler>((ref) {
  return NotificationScheduler(
    quietHours: ref.watch(engagementSettingsProvider).settings.quietHours,
  );
});

// =========================================================================
// ENGAGEMENT NOTIFIER — orchestrates notification logic
// =========================================================================

/// High-level state for the engagement system
class EngagementState {
  final bool notificationsEnabled;
  final List<NotificationType> activeTypes;
  final int notificationsSentToday;
  final EngagementSettingsState settings;

  const EngagementState({
    this.notificationsEnabled = true,
    this.activeTypes = const [],
    this.notificationsSentToday = 0,
    this.settings = const EngagementSettingsState(),
  });

  EngagementState copyWith({
    bool? notificationsEnabled,
    List<NotificationType>? activeTypes,
    int? notificationsSentToday,
    EngagementSettingsState? settings,
  }) {
    return EngagementState(
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      activeTypes: activeTypes ?? this.activeTypes,
      notificationsSentToday: notificationsSentToday ?? this.notificationsSentToday,
      settings: settings ?? this.settings,
    );
  }
}

/// Orchestrates notification engagement across the app
class EngagementNotifier extends StateNotifier<EngagementState> {
  EngagementNotifier(super.state);

  /// Check if a notification type is active
  bool isActive(NotificationType type) {
    return state.notificationsEnabled &&
        (state.activeTypes.contains(type) ||
            state.settings.settings.shouldSend(type));
  }

  /// Record that a notification was sent
  void recordSent() {
    state = state.copyWith(
      notificationsSentToday: state.notificationsSentToday + 1,
    );
  }

  /// Update active notification types
  void setActiveTypes(List<NotificationType> types) {
    state = state.copyWith(activeTypes: types);
  }

  /// Toggle notification enabled/disabled
  void toggleNotifications(bool enabled) {
    state = state.copyWith(notificationsEnabled: enabled);
  }
}

final engagementNotifierProvider =
    StateNotifierProvider<EngagementNotifier, EngagementState>(
  (ref) => EngagementNotifier(
    const EngagementState(),
  ),
);

import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Notification permission and status
class NotificationState {
  final bool isGranted;
  final bool hasActiveSubscription;
  final int pendingReminders;
  final List<String> reminderTypes; // 'feeding', 'medication', 'vaccination', 'weight'

  const NotificationState({
    this.isGranted = false,
    this.hasActiveSubscription = false,
    this.pendingReminders = 0,
    this.reminderTypes = const [],
  });

  NotificationState copyWith({
    bool? isGranted,
    bool? hasActiveSubscription,
    int? pendingReminders,
    List<String>? reminderTypes,
  }) {
    return NotificationState(
      isGranted: isGranted ?? this.isGranted,
      hasActiveSubscription: hasActiveSubscription ?? this.hasActiveSubscription,
      pendingReminders: pendingReminders ?? this.pendingReminders,
      reminderTypes: reminderTypes ?? this.reminderTypes,
    );
  }
}

/// StateNotifier for notification management
class NotificationNotifier extends StateNotifier<NotificationState> {
  NotificationNotifier(super.state);

  /// Request notification permissions
  Future<void> requestPermissions() async {
    // TODO: Integrate with Firebase Messaging
    state = state.copyWith(isGranted: true);
  }

  /// Update pending reminders count
  void updateReminders(int count) {
    state = state.copyWith(pendingReminders: count);
  }

  /// Enable/disable specific reminder types
  void toggleReminderType(String type) {
    final types = List<String>.from(state.reminderTypes);
    if (types.contains(type)) {
      types.remove(type);
    } else {
      types.add(type);
    }
    state = state.copyWith(reminderTypes: types);
  }
}

final notificationProvider =
    StateNotifierProvider<NotificationNotifier, NotificationState>(
  (ref) => NotificationNotifier(const NotificationState()),
);

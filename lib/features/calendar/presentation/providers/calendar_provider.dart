/// PawTable calendar state provider.
///
/// Manages calendar state including selected date, events, and
/// pending reminders for a given pet.

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/storage/database_helper.dart';
import '../../../../di/app_module.dart';
import '../../domain/entities/calendar_event_entity.dart';
import '../../domain/repositories/calendar_repository.dart';
import '../../data/repositories/calendar_repository_impl.dart';

/// Calendar list state
class CalendarListState {
  final bool isLoading;
  final String? error;
  final List<CalendarEvent> events;
  final DateTime selectedDate;
  final int pendingReminders;
  final List<CalendarEvent> overdueEvents;

  CalendarListState({
    this.isLoading = false,
    this.error,
    this.events = const [],
    DateTime? selectedDate,
    this.pendingReminders = 0,
    this.overdueEvents = const [],
  }) : selectedDate = selectedDate ?? DateTime.now();

  CalendarListState copyWith({
    bool? isLoading,
    String? error,
    List<CalendarEvent>? events,
    DateTime? selectedDate,
    int? pendingReminders,
    List<CalendarEvent>? overdueEvents,
  }) =>
      CalendarListState(
        isLoading: isLoading ?? this.isLoading,
        error: error ?? this.error,
        events: events ?? this.events,
        selectedDate: selectedDate ?? this.selectedDate,
        pendingReminders: pendingReminders ?? this.pendingReminders,
        overdueEvents: overdueEvents ?? this.overdueEvents,
      );
}

/// Calendar list state notifier
class CalendarListNotifier extends StateNotifier<CalendarListState> {
  final DatabaseHelper _dbHelper;

  CalendarListNotifier(this._dbHelper) : super(CalendarListState());

  /// Load events for a specific pet and selected date
  Future<void> loadEvents(String petId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final from = DateTime(state.selectedDate.year, state.selectedDate.month, 1);
      final to = DateTime(state.selectedDate.year, state.selectedDate.month + 1, 0);
      final repository = CalendarRepositoryImpl(dbHelper: _dbHelper);
      final events = await repository.getEventsForPet(
        petId: petId,
        from: from,
        to: to,
      );
      final upcoming = await repository.getUpcomingEvents(petId: petId);
      final overdue = await repository.getOverdueEvents(petId: petId);

      state = state.copyWith(
        events: events,
        pendingReminders: upcoming.length,
        overdueEvents: overdue,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  /// Change selected date and reload events
  Future<void> setSelectedDate(DateTime date, String petId) async {
    state = state.copyWith(selectedDate: date);
    await loadEvents(petId);
  }

  /// Count events for a specific date
  int getEventsForDate(DateTime date) {
    return state.events.where((event) => event.isOn(date)).length;
  }

  /// Get events filtered by type
  List<CalendarEvent> getEventsByType(String type) {
    return state.events.where((e) => e.eventType == type).toList();
  }
}

/// Calendar provider
final calendarProvider =
    StateNotifierProvider<CalendarListNotifier, CalendarListState>((ref) {
  return CalendarListNotifier(getIt<DatabaseHelper>());
});

/// Notification state
class NotificationState {
  final bool isGranted;
  final bool hasActiveSubscription;
  final int pendingReminders;
  final List<String> reminderTypes;

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
  }) =>
      NotificationState(
        isGranted: isGranted ?? this.isGranted,
        hasActiveSubscription: hasActiveSubscription ?? this.hasActiveSubscription,
        pendingReminders: pendingReminders ?? this.pendingReminders,
        reminderTypes: reminderTypes ?? this.reminderTypes,
      );
}

/// Notification notifier
class NotificationNotifier extends StateNotifier<NotificationState> {
  NotificationNotifier() : super(const NotificationState());

  Future<void> requestPermissions() async {
    state = state.copyWith(isGranted: true);
  }

  void updateReminders(int count) {
    state = state.copyWith(pendingReminders: count);
  }

  void toggleReminderType(String type) {
    final types = List<String>.from(state.reminderTypes);
    if (types.contains(type)) {
      types.remove(type);
    } else {
      types.add(type);
    }
    state = state.copyWith(reminderTypes: types);
  }

  void setReminderTypes(List<String> types) {
    state = state.copyWith(reminderTypes: types);
  }
}

/// Notification provider
final notificationProvider =
    StateNotifierProvider<NotificationNotifier, NotificationState>(
  (ref) => NotificationNotifier(),
);

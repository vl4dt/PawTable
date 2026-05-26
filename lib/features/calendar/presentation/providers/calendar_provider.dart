import 'package:flutter_riverpod/flutter_riverpod.dart';

final calendarProvider = StateNotifierProvider<StateNotifier<List<dynamic>>, List<dynamic>>((ref) {
  throw UnimplementedError('Configure DI');
});

class CalendarState {
  final DateTime selectedDate;
  final List<dynamic> events;
  final bool isLoading;

  CalendarState({
    DateTime? selectedDate,
    List<dynamic>? events,
    this.isLoading = false,
  })  : selectedDate = selectedDate ?? DateTime.now(),
        events = events ?? const [];

  CalendarState copyWith({
    DateTime? selectedDate,
    List<dynamic>? events,
    bool? isLoading,
  }) => CalendarState(
    selectedDate: selectedDate ?? this.selectedDate,
    events: events ?? this.events,
    isLoading: isLoading ?? this.isLoading,
  );
}

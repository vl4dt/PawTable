/// PawTable calendar repository interface.
///
/// Aggregates events from feeding, vaccination, medication, weight,
/// and behavior data sources into a unified calendar view.

import '../entities/calendar_event_entity.dart';

abstract class CalendarRepository {
  /// Get all calendar events for a pet within a date range
  Future<List<CalendarEvent>> getEventsForPet({
    required String petId,
    required DateTime from,
    required DateTime to,
    String? eventType,
  });

  /// Get all events for a specific date
  Future<List<CalendarEvent>> getEventsForDate({
    required String petId,
    required DateTime date,
  });

  /// Get events that are upcoming (next 7 days) for reminders
  Future<List<CalendarEvent>> getUpcomingEvents({
    required String petId,
    int daysAhead = 7,
  });

  /// Get events that are overdue (past due vaccinations, etc.)
  Future<List<CalendarEvent>> getOverdueEvents({
    required String petId,
  });
}

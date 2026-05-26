/// PawTable calendar repository implementation.
///
/// Aggregates events from feeding, vaccination, medication, weight,
/// and behavior data sources into unified CalendarEvent objects.

import 'package:uuid/uuid.dart';

import '../../../../core/storage/database_helper.dart';
import '../../domain/entities/calendar_event_entity.dart';
import '../../domain/repositories/calendar_repository.dart';

/// Implementation of CalendarRepository using local SQLite storage
class CalendarRepositoryImpl implements CalendarRepository {
  final DatabaseHelper _dbHelper;
  final Uuid _uuid = const Uuid();

  CalendarRepositoryImpl({required DatabaseHelper dbHelper})
      : _dbHelper = dbHelper;

  @override
  Future<List<CalendarEvent>> getEventsForPet({
    required String petId,
    required DateTime from,
    required DateTime to,
    String? eventType,
  }) async {
    final events = <CalendarEvent>[];

    // Load feeding logs
    final feedingLogs = await _dbHelper.getFeedingLogsByPet(petId);
    for (final log in feedingLogs) {
      final time = DateTime.tryParse(log['time'] as String);
      if (time != null && time.isAfter(from) && time.isBefore(to)) {
        final mealType = log['mealType'] as String? ?? 'Feeding';
        events.add(CalendarEvent(
          id: _uuid.v7(),
          petId: petId,
          petName: 'Pet',
          eventType: CalendarEventType.feeding.value,
          title: mealType,
          description: log['notes'] as String?,
          date: time,
        ));
      }
    }

    // Load vaccinations
    final vaccinations = await _dbHelper.getVaccinationsByPet(petId);
    for (final vax in vaccinations) {
      final dateIssued = DateTime.tryParse(vax['dateIssued'] as String);
      if (dateIssued != null && dateIssued.isAfter(from) && dateIssued.isBefore(to)) {
        events.add(CalendarEvent(
          id: _uuid.v7(),
          petId: petId,
          petName: 'Pet',
          eventType: CalendarEventType.vaccination.value,
          title: vax['vaccineName'] as String? ?? 'Vaccination',
          description: vax['notes'] as String?,
          date: dateIssued,
        ));
      }
      final nextDue = DateTime.tryParse(vax['nextDueDate'] as String);
      if (nextDue != null && nextDue.isAfter(from) && nextDue.isBefore(to)) {
        events.add(CalendarEvent(
          id: _uuid.v7(),
          petId: petId,
          petName: 'Pet',
          eventType: CalendarEventType.vaccination.value,
          title: '${vax['vaccineName'] as String? ?? 'Vaccine'} - Due',
          description: 'Next vaccination due',
          date: nextDue,
        ));
      }
    }

    // Load medications
    final medications = await _dbHelper.getMedicationsByPet(petId);
    for (final med in medications) {
      final startDate = DateTime.tryParse(med['startDate'] as String);
      if (startDate != null && startDate.isAfter(from) && startDate.isBefore(to)) {
        final endDateStr = med['endDate'] as String?;
        final endDate = endDateStr != null ? DateTime.tryParse(endDateStr) : null;
        events.add(CalendarEvent(
          id: _uuid.v7(),
          petId: petId,
          petName: 'Pet',
          eventType: CalendarEventType.medication.value,
          title: med['name'] as String? ?? 'Medication',
          description: '${med['dosage'] as String? ?? ''} - ${med['frequency'] as String? ?? ''}',
          date: startDate,
          endDate: endDate,
          isRecurring: endDate != null,
        ));
      }
    }

    // Load weight logs
    final weightLogs = await _dbHelper.getWeightLogsByPet(petId);
    for (final wl in weightLogs) {
      final date = DateTime.tryParse(wl['date'] as String);
      if (date != null && date.isAfter(from) && date.isBefore(to)) {
        events.add(CalendarEvent(
          id: _uuid.v7(),
          petId: petId,
          petName: 'Pet',
          eventType: CalendarEventType.weight.value,
          title: 'Weight: ${wl['weight'] as String? ?? '?'}',
          description: wl['notes'] as String?,
          date: date,
        ));
      }
    }

    // Load behavior logs
    final behaviorLogs = await _dbHelper.getBehaviorLogsByPet(petId);
    for (final bl in behaviorLogs) {
      final date = DateTime.tryParse(bl['date'] as String);
      if (date != null && date.isAfter(from) && date.isBefore(to)) {
        events.add(CalendarEvent(
          id: _uuid.v7(),
          petId: petId,
          petName: 'Pet',
          eventType: CalendarEventType.behavior.value,
          title: '${bl['mood'] as String? ?? 'Behavior'} log',
          description: bl['notes'] as String?,
          date: date,
        ));
      }
    }

    // Filter by event type if specified
    if (eventType != null) {
      events.removeWhere((e) => e.eventType != eventType);
    }

    // Sort by date
    events.sort((a, b) => a.date.compareTo(b.date));

    return events;
  }

  @override
  Future<List<CalendarEvent>> getEventsForDate({
    required String petId,
    required DateTime date,
  }) async {
    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));
    return getEventsForPet(petId: petId, from: start, to: end);
  }

  @override
  Future<List<CalendarEvent>> getUpcomingEvents({
    required String petId,
    int daysAhead = 7,
  }) async {
    final now = DateTime.now();
    final to = now.add(Duration(days: daysAhead));
    return getEventsForPet(petId: petId, from: now, to: to);
  }

  @override
  Future<List<CalendarEvent>> getOverdueEvents({
    required String petId,
  }) async {
    final now = DateTime.now();
    // Look back 30 days for overdue items
    final from = now.subtract(const Duration(days: 30));
    final events = <CalendarEvent>[];

    // Check for overdue vaccinations
    final vaccinations = await _dbHelper.getVaccinationsByPet(petId);
    for (final vax in vaccinations) {
      final nextDue = DateTime.tryParse(vax['nextDueDate'] as String);
      if (nextDue != null && nextDue.isBefore(now)) {
        events.add(CalendarEvent(
          id: _uuid.v7(),
          petId: petId,
          petName: 'Pet',
          eventType: CalendarEventType.vaccination.value,
          title: '${vax['vaccineName'] as String? ?? 'Vaccine'} - OVERDUE',
          description: 'Vaccination was due on ${nextDue.toLocal().toString().split(' ').first}',
          date: nextDue,
        ));
      }
    }

    return events;
  }
}

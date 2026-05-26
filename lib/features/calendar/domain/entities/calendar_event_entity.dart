/// PawTable calendar event entity.
///
/// Unified event type that represents any schedulable item across
/// feeding, vaccination, medication, behavior, and weight logs.

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

/// Types of calendar events
class CalendarEventType {
  CalendarEventType._(this.value, this.label, this.icon);

  final String value;
  final String label;
  final IconData icon;

  static final CalendarEventType feeding = CalendarEventType._(
    'feeding',
    'Feeding',
    Icons.kitchen_rounded,
  );

  static final CalendarEventType vaccination = CalendarEventType._(
    'vaccination',
    'Vaccination',
    Icons.local_hospital_rounded,
  );

  static final CalendarEventType medication = CalendarEventType._(
    'medication',
    'Medication',
    Icons.medication_liquid_rounded,
  );

  static final CalendarEventType weight = CalendarEventType._(
    'weight',
    'Weight',
    Icons.scale_rounded,
  );

  static final CalendarEventType behavior = CalendarEventType._(
    'behavior',
    'Behavior',
    Icons.sentiment_satisfied_alt_rounded,
  );

  static final CalendarEventType vetVisit = CalendarEventType._(
    'vet_visit',
    'Vet Visit',
    Icons.pets_rounded,
  );

  static final List<CalendarEventType> values = [
    feeding,
    vaccination,
    medication,
    weight,
    behavior,
    vetVisit,
  ];

  static CalendarEventType fromString(String value) {
    return values.firstWhere(
      (e) => e.value == value,
      orElse: () => feeding,
    );
  }

  @override
  String toString() => value;
}

/// A unified calendar event
class CalendarEvent {
  final String id;
  final String petId;
  final String petName;
  final String eventType;
  final String title;
  final String? description;
  final DateTime date;
  final DateTime? endDate;
  final bool isRecurring;
  final String? recurringId;

  const CalendarEvent({
    required this.id,
    required this.petId,
    required this.petName,
    required this.eventType,
    required this.title,
    this.description,
    required this.date,
    this.endDate,
    this.isRecurring = false,
    this.recurringId,
  });

  CalendarEventType get type => CalendarEventType.fromString(eventType);

  bool isOn(DateTime day) {
    final dayStart = DateTime(day.year, day.month, day.day);
    final eventStart = DateTime(date.year, date.month, date.day);
    if (endDate != null) {
      final eventEnd = DateTime(endDate!.year, endDate!.month, endDate!.day);
      return dayStart.compareTo(eventStart) >= 0 &&
          dayStart.compareTo(eventEnd) <= 0;
    }
    if (isRecurring) {
      final diff = dayStart.difference(eventStart).inDays;
      return diff >= 0 && diff % 30 == 0; // Monthly recurring default
    }
    return dayStart == eventStart;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'petId': petId,
        'petName': petName,
        'eventType': eventType,
        'title': title,
        'description': description,
        'date': date.toIso8601String(),
        'endDate': endDate?.toIso8601String(),
        'isRecurring': isRecurring,
        'recurringId': recurringId,
      };

  factory CalendarEvent.fromJson(Map<String, dynamic> json) => CalendarEvent(
        id: json['id'] as String,
        petId: json['petId'] as String,
        petName: json['petName'] as String,
        eventType: json['eventType'] as String,
        title: json['title'] as String,
        description: json['description'] as String?,
        date: DateTime.parse(json['date'] as String),
        endDate: json['endDate'] != null
            ? DateTime.parse(json['endDate'] as String)
            : null,
        isRecurring: json['isRecurring'] as bool? ?? false,
        recurringId: json['recurringId'] as String?,
      );

  CalendarEvent copyWith({
    String? id,
    String? petId,
    String? petName,
    String? eventType,
    String? title,
    String? description,
    DateTime? date,
    DateTime? endDate,
    bool? isRecurring,
    String? recurringId,
  }) =>
      CalendarEvent(
        id: id ?? this.id,
        petId: petId ?? this.petId,
        petName: petName ?? this.petName,
        eventType: eventType ?? this.eventType,
        title: title ?? this.title,
        description: description ?? this.description,
        date: date ?? this.date,
        endDate: endDate ?? this.endDate,
        isRecurring: isRecurring ?? this.isRecurring,
        recurringId: recurringId ?? this.recurringId,
      );
}

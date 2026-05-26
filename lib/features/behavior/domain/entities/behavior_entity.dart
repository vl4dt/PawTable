import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import '../../../../core/models/base_model.dart' show JsonHelpers;

/// Mood enum for behavior logging
class Mood {
  final String name;
  final String label;
  final IconData icon;
  final Color color;
  const Mood(this.name, this.label, this.icon, this.color);

  static const Mood happy = Mood('happy', 'Happy', Icons.sentiment_satisfied, Colors.green);
  static const Mood playful = Mood('playful', 'Playful', Icons.sports_esports, Colors.orange);
  static const Mood sleepy = Mood('sleepy', 'Sleepy', Icons.bedtime, Colors.blue);
  static const Mood anxious = Mood('anxious', 'Anxious', Icons.psychology, Colors.amber);
  static const Mood tired = Mood('tired', 'Tired', Icons.nightlight, Colors.grey);
  static const Mood excited = Mood('excited', 'Excited', Icons.waving_hand, Colors.purple);
  static const Mood calm = Mood('calm', 'Calm', Icons.spa, Colors.teal);
  static const Mood hungry = Mood('hungry', 'Hungry', Icons.restaurant, Colors.red);
  static const Mood sick = Mood('sick', 'Unwell', Icons.medication, Colors.redAccent);
  static const Mood confused = Mood('confused', 'Confused', Icons.help_outline, Colors.brown);

  static const List<Mood> values = [
    happy, playful, sleepy, anxious, tired,
    excited, calm, hungry, sick, confused,
  ];

  static Mood byName(String name) => values.firstWhere(
    (m) => m.name == name,
    orElse: () => happy,
  );
}

/// Activity level enum
class ActivityLevel {
  final String name;
  final String label;
  final IconData icon;
  final int score;
  const ActivityLevel(this.name, this.label, this.icon, this.score);

  static const ActivityLevel sedentary = ActivityLevel('sedentary', 'Sedentary', Icons.accessibility_new, 0);
  static const ActivityLevel low = ActivityLevel('low', 'Low', Icons.directions_run, 1);
  static const ActivityLevel moderate = ActivityLevel('moderate', 'Moderate', Icons.directions_run, 2);
  static const ActivityLevel high = ActivityLevel('high', 'High', Icons.sports_soccer, 3);
  static const ActivityLevel extreme = ActivityLevel('extreme', 'Extreme', Icons.flash_on, 4);

  static const List<ActivityLevel> values = [
    sedentary, low, moderate, high, extreme,
  ];

  static ActivityLevel byName(String name) => values.firstWhere(
    (a) => a.name == name,
    orElse: () => moderate,
  );
}

/// Behavior log entity
class BehaviorLogEntity extends Equatable {
  final String id;
  final String petId;
  final Mood mood;
  final ActivityLevel activityLevel;
  final String? notes;
  final DateTime loggedAt;
  final DateTime createdAt;

  const BehaviorLogEntity({
    required this.id,
    required this.petId,
    required this.mood,
    required this.activityLevel,
    this.notes,
    required this.loggedAt,
    required this.createdAt,
  });

  /// Calculate wellness score from this log (0-100)
  int getWellnessScore() {
    int moodScore = 0;
    switch (mood.name) {
      case 'happy': moodScore = 100; break;
      case 'playful': moodScore = 90; break;
      case 'calm': moodScore = 85; break;
      case 'excited': moodScore = 80; break;
      case 'sleepy': moodScore = 70; break;
      case 'hungry': moodScore = 60; break;
      case 'tired': moodScore = 50; break;
      case 'anxious': moodScore = 40; break;
      case 'confused': moodScore = 35; break;
      case 'sick': moodScore = 20; break;
      default: moodScore = 50;
    }

    int activityScore = ((activityLevel.score / 4) * 100).round();
    return ((moodScore * 0.6) + (activityScore * 0.4)).round().clamp(0, 100);
  }

  
  Map<String, dynamic> toJson() => {
    'id': id,
    'petId': petId,
    'mood': mood.name,
    'activityLevel': activityLevel.name,
    'notes': notes,
    'loggedAt': loggedAt.toIso8601String(),
    'createdAt': createdAt.toIso8601String(),
  };

  factory BehaviorLogEntity.fromJson(Map<String, dynamic> json) {
    return BehaviorLogEntity(
      id: json['id'] as String,
      petId: json['petId'] as String,
      mood: Mood.byName(json['mood'] as String),
      activityLevel: ActivityLevel.byName(json['activityLevel'] as String),
      notes: json['notes'] as String?,
      loggedAt: JsonHelpers.dateTime(json, 'loggedAt') ?? DateTime.now(),
      createdAt: JsonHelpers.dateTime(json, 'createdAt') ?? DateTime.now(),
    );
  }

  
  @override
  List<Object?> get props => [id, petId, mood, activityLevel, loggedAt];
}

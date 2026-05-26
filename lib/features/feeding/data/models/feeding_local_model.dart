import 'package:equatable/equatable.dart';

/// Feeding log entry — local Hive/SQLite model
class FeedingLocalModel extends Equatable {
  final String id;
  final String petId;
  final String mealType;
  final double amount;
  final String unit;
  final String scheduledTime;
  final String? actualTime;
  final bool completed;
  final String? notes;

  const FeedingLocalModel({
    required this.id,
    required this.petId,
    required this.mealType,
    this.amount = 0.0,
    this.unit = 'g',
    required this.scheduledTime,
    this.actualTime,
    this.completed = false,
    this.notes,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'petId': petId,
        'mealType': mealType,
        'amount': amount,
        'unit': unit,
        'scheduledTime': scheduledTime,
        'actualTime': actualTime,
        'completed': completed,
        'notes': notes,
      };

  factory FeedingLocalModel.fromJson(Map<String, dynamic> json) {
    return FeedingLocalModel(
      id: json['id'] as String,
      petId: json['petId'] as String,
      mealType: json['mealType'] as String,
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      unit: json['unit'] as String? ?? 'g',
      scheduledTime: json['scheduledTime'] as String,
      actualTime: json['actualTime'] as String?,
      completed: json['completed'] as bool? ?? false,
      notes: json['notes'] as String?,
    );
  }

  @override
  List<Object?> get props => [id, petId, mealType, amount, unit, scheduledTime, actualTime, completed, notes];
}

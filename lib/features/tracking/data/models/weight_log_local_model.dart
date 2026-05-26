import 'package:equatable/equatable.dart';

/// Weight log entry — local Hive/SQLite model
class WeightLogLocalModel extends Equatable {
  final String id;
  final String petId;
  final double weight;
  final String date;
  final String? notes;

  const WeightLogLocalModel({
    required this.id,
    required this.petId,
    required this.weight,
    required this.date,
    this.notes,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'petId': petId,
        'weight': weight,
        'date': date,
        'notes': notes,
      };

  factory WeightLogLocalModel.fromJson(Map<String, dynamic> json) {
    return WeightLogLocalModel(
      id: json['id'] as String,
      petId: json['petId'] as String,
      weight: (json['weight'] as num).toDouble(),
      date: json['date'] as String,
      notes: json['notes'] as String?,
    );
  }

  @override
  List<Object?> get props => [id, petId, weight, date, notes];
}

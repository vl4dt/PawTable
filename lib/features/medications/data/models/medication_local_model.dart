import 'package:equatable/equatable.dart';

/// Medication record — local Hive/SQLite model
class MedicationLocalModel extends Equatable {
  final String id;
  final String petId;
  final String name;
  final String dosage;
  final String unit;
  final String frequency;
  final String startDate;
  final String? endDate;
  final String? instructions;
  final int completedDoses;
  final String? notes;

  const MedicationLocalModel({
    required this.id,
    required this.petId,
    required this.name,
    required this.dosage,
    this.unit = 'mg',
    required this.frequency,
    required this.startDate,
    this.endDate,
    this.instructions,
    this.completedDoses = 0,
    this.notes,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'petId': petId,
        'name': name,
        'dosage': dosage,
        'unit': unit,
        'frequency': frequency,
        'startDate': startDate,
        'endDate': endDate,
        'instructions': instructions,
        'completedDoses': completedDoses,
        'notes': notes,
      };

  factory MedicationLocalModel.fromJson(Map<String, dynamic> json) {
    return MedicationLocalModel(
      id: json['id'] as String,
      petId: json['petId'] as String,
      name: json['name'] as String,
      dosage: json['dosage'] as String,
      unit: json['unit'] as String? ?? 'mg',
      frequency: json['frequency'] as String,
      startDate: json['startDate'] as String,
      endDate: json['endDate'] as String?,
      instructions: json['instructions'] as String?,
      completedDoses: (json['completedDoses'] as num?)?.toInt() ?? 0,
      notes: json['notes'] as String?,
    );
  }

  @override
  List<Object?> get props =>
      [id, petId, name, dosage, unit, frequency, startDate, endDate, instructions, completedDoses, notes];
}

import 'package:equatable/equatable.dart';
import '../../../../core/models/base_model.dart' show JsonHelpers;

/// Medication entity
class MedicationEntity extends Equatable {
  final String id;
  final String petId;
  final String name;
  final double dosage;
  final String unit;
  final DateTime scheduledAt;
  final String? instructions;
  final String frequency;
  final DateTime startDate;
  final DateTime? endDate;
  final bool taken;
  final DateTime? takenAt;
  final DateTime createdAt;

  const MedicationEntity({
    required this.id,
    required this.petId,
    required this.name,
    required this.dosage,
    required this.unit,
    required this.scheduledAt,
    this.instructions,
    this.taken = false,
    this.takenAt,
    required this.createdAt,
    required this.frequency,
    required this.startDate,
    this.endDate,
  });

  
  Map<String, dynamic> toJson() => {
    'id': id, 'petId': petId, 'name': name,
    'dosage': dosage, 'unit': unit,
    'scheduledAt': scheduledAt.toIso8601String(),
    'frequency': frequency, 'startDate': startDate.toIso8601String(),
    'endDate': endDate?.toIso8601String(),
    'instructions': instructions, 'taken': taken, 'takenAt': takenAt?.toIso8601String(),
    'createdAt': createdAt.toIso8601String(),
  };

  factory MedicationEntity.fromJson(Map<String, dynamic> json) {
    return MedicationEntity(
      id: json['id'] as String, petId: json['petId'] as String,
      name: json['name'] as String,
      dosage: json['dosage'] as double? ?? 0,
      unit: json['unit'] as String? ?? 'mg',
      scheduledAt: JsonHelpers.dateTime(json, 'scheduledAt') ?? DateTime.now(),
      frequency: json['frequency'] as String? ?? 'Once daily',
      startDate: JsonHelpers.dateTime(json, 'startDate') ?? DateTime.now(),
      endDate: JsonHelpers.dateTime(json, 'endDate'),
      instructions: json['instructions'] as String?,
      taken: json['taken'] as bool? ?? false,
      takenAt: JsonHelpers.dateTime(json, 'takenAt'),
      createdAt: JsonHelpers.dateTime(json, 'createdAt') ?? DateTime.now(),
    );
  }

  MedicationEntity copyWith({
    String? id,
    String? petId,
    String? name,
    double? dosage,
    String? unit,
    DateTime? scheduledAt,
    String? frequency,
    DateTime? startDate,
    DateTime? endDate,
    String? instructions,
    bool? taken,
    DateTime? takenAt,
    DateTime? createdAt,
  }) {
    return MedicationEntity(
      id: id ?? this.id,
      petId: petId ?? this.petId,
      name: name ?? this.name,
      dosage: dosage ?? this.dosage,
      unit: unit ?? this.unit,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      frequency: frequency ?? this.frequency,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      instructions: instructions ?? this.instructions,
      taken: taken ?? this.taken,
      takenAt: takenAt ?? this.takenAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  
  @override
  List<Object?> get props => [id, petId, name, dosage, unit, scheduledAt, taken];
}

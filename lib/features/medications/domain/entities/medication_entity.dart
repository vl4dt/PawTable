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
  });

  
  Map<String, dynamic> toJson() => {
    'id': id, 'petId': petId, 'name': name,
    'dosage': dosage, 'unit': unit,
    'scheduledAt': scheduledAt.toIso8601String(),
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
      instructions: json['instructions'] as String?,
      taken: json['taken'] as bool? ?? false,
      takenAt: JsonHelpers.dateTime(json, 'takenAt'),
      createdAt: JsonHelpers.dateTime(json, 'createdAt') ?? DateTime.now(),
    );
  }

  
  @override
  List<Object?> get props => [id, petId, name, dosage, unit, scheduledAt, taken];
}

import 'package:equatable/equatable.dart';
import '../../../../core/models/base_model.dart' show JsonHelpers;

/// Vaccination entity
class VaccinationEntity extends Equatable {
  final String id;
  final String petId;
  final String name;
  final DateTime dateGiven;
  final DateTime? nextDueDate;
  final String? vetClinic;
  final String? notes;
  final DateTime createdAt;

  const VaccinationEntity({
    required this.id,
    required this.petId,
    required this.name,
    required this.dateGiven,
    this.nextDueDate,
    this.vetClinic,
    this.notes,
    required this.createdAt,
  });

  bool get isDue => nextDueDate != null && nextDueDate!.isBefore(DateTime.now());

  
  Map<String, dynamic> toJson() => {
    'id': id, 'petId': petId, 'name': name,
    'dateGiven': dateGiven.toIso8601String(),
    'nextDueDate': nextDueDate?.toIso8601String(),
    'vetClinic': vetClinic, 'notes': notes,
    'createdAt': createdAt.toIso8601String(),
  };

  factory VaccinationEntity.fromJson(Map<String, dynamic> json) {
    return VaccinationEntity(
      id: json['id'] as String, petId: json['petId'] as String,
      name: json['name'] as String,
      dateGiven: JsonHelpers.dateTime(json, 'dateGiven') ?? DateTime.now(),
      nextDueDate: JsonHelpers.dateTime(json, 'nextDueDate'),
      vetClinic: json['vetClinic'] as String?,
      notes: json['notes'] as String?,
      createdAt: JsonHelpers.dateTime(json, 'createdAt') ?? DateTime.now(),
    );
  }

  
  @override
  List<Object?> get props => [id, petId, name, dateGiven, nextDueDate];
}

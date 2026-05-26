import 'package:equatable/equatable.dart';

/// Vaccination record — local Hive/SQLite model
class VaccinationLocalModel extends Equatable {
  final String id;
  final String petId;
  final String vaccineName;
  final String dateIssued;
  final String? nextDueDate;
  final String? batchNumber;
  final String? notes;
  final bool completed;

  const VaccinationLocalModel({
    required this.id,
    required this.petId,
    required this.vaccineName,
    required this.dateIssued,
    this.nextDueDate,
    this.batchNumber,
    this.notes,
    this.completed = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'petId': petId,
        'vaccineName': vaccineName,
        'dateIssued': dateIssued,
        'nextDueDate': nextDueDate,
        'batchNumber': batchNumber,
        'notes': notes,
        'completed': completed,
      };

  factory VaccinationLocalModel.fromJson(Map<String, dynamic> json) {
    return VaccinationLocalModel(
      id: json['id'] as String,
      petId: json['petId'] as String,
      vaccineName: json['vaccineName'] as String,
      dateIssued: json['dateIssued'] as String,
      nextDueDate: json['nextDueDate'] as String?,
      batchNumber: json['batchNumber'] as String?,
      notes: json['notes'] as String?,
      completed: json['completed'] as bool? ?? false,
    );
  }

  @override
  List<Object?> get props => [id, petId, vaccineName, dateIssued, nextDueDate, batchNumber, notes, completed];
}

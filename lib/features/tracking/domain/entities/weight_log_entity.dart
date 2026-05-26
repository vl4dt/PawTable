import 'package:equatable/equatable.dart';
import '../../../../core/models/base_model.dart' show JsonHelpers;

/// Weight log entity
class WeightLogEntity extends Equatable {
  final String id;
  final String petId;
  final double weight;
  final String unit;
  final DateTime loggedAt;
  final DateTime createdAt;

  const WeightLogEntity({
    required this.id,
    required this.petId,
    required this.weight,
    this.unit = 'kg',
    required this.loggedAt,
    required this.createdAt,
  });

  
  Map<String, dynamic> toJson() => {
    'id': id, 'petId': petId, 'weight': weight,
    'unit': unit, 'loggedAt': loggedAt.toIso8601String(),
    'createdAt': createdAt.toIso8601String(),
  };

  factory WeightLogEntity.fromJson(Map<String, dynamic> json) {
    return WeightLogEntity(
      id: json['id'] as String, petId: json['petId'] as String,
      weight: json['weight'] as double? ?? 0,
      unit: json['unit'] as String? ?? 'kg',
      loggedAt: JsonHelpers.dateTime(json, 'loggedAt') ?? DateTime.now(),
      createdAt: JsonHelpers.dateTime(json, 'createdAt') ?? DateTime.now(),
    );
  }

  
  @override
  List<Object?> get props => [id, petId, weight, loggedAt];
}

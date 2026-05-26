import 'package:equatable/equatable.dart';
import '../../../../core/models/base_model.dart' show JsonHelpers;

/// Health log category
enum HealthCategory {
  general, appetite, energy, behavior, digestion, skin, dental, eyes, ears, other,
}

/// Health log entity
class HealthLogEntity extends Equatable {
  final String id;
  final String petId;
  final HealthCategory category;
  final String description;
  final String? severity;
  final DateTime loggedAt;
  final DateTime createdAt;

  const HealthLogEntity({
    required this.id,
    required this.petId,
    required this.category,
    required this.description,
    this.severity,
    required this.loggedAt,
    required this.createdAt,
  });

  
  Map<String, dynamic> toJson() => {
    'id': id, 'petId': petId, 'category': category.name,
    'description': description, 'severity': severity,
    'loggedAt': loggedAt.toIso8601String(), 'createdAt': createdAt.toIso8601String(),
  };

  factory HealthLogEntity.fromJson(Map<String, dynamic> json) {
    return HealthLogEntity(
      id: json['id'] as String, petId: json['petId'] as String,
      category: HealthCategory.values.byName(json['category'] as String),
      description: json['description'] as String,
      severity: json['severity'] as String?,
      loggedAt: JsonHelpers.dateTime(json, 'loggedAt') ?? DateTime.now(),
      createdAt: JsonHelpers.dateTime(json, 'createdAt') ?? DateTime.now(),
    );
  }

  
  @override
  List<Object?> get props => [id, petId, category, description, loggedAt];
}

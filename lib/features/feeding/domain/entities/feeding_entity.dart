import 'package:equatable/equatable.dart';
import '../../../../core/models/base_model.dart';
import '../../../../core/models/base_model.dart' show JsonHelpers;

/// Feeding type
enum FeedingType { dry, wet, raw, homemade, treat, supplement }

/// Feeding entity
class FeedingEntity extends Equatable {
  final String id;
  final String petId;
  final FeedingType type;
  final double amountGrams;
  final String? notes;
  final DateTime fedAt;
  final DateTime createdAt;

  const FeedingEntity({
    required this.id,
    required this.petId,
    required this.type,
    required this.amountGrams,
    this.notes,
    required this.fedAt,
    required this.createdAt,
  });

  FeedingEntity copyWith({
    String? id,
    String? petId,
    FeedingType? type,
    double? amountGrams,
    String? notes,
    DateTime? fedAt,
    DateTime? createdAt,
  }) {
    return FeedingEntity(
      id: id ?? this.id,
      petId: petId ?? this.petId,
      type: type ?? this.type,
      amountGrams: amountGrams ?? this.amountGrams,
      notes: notes ?? this.notes,
      fedAt: fedAt ?? this.fedAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  
  Map<String, dynamic> toJson() => {
    'id': id, 'petId': petId, 'type': type.name,
    'amountGrams': amountGrams, 'notes': notes,
    'fedAt': fedAt.toIso8601String(), 'createdAt': createdAt.toIso8601String(),
  };

  factory FeedingEntity.fromJson(Map<String, dynamic> json) {
    return FeedingEntity(
      id: json['id'] as String,
      petId: json['petId'] as String,
      type: FeedingType.values.byName(json['type'] as String),
      amountGrams: json['amountGrams'] as double? ?? 0,
      notes: json['notes'] as String?,
      fedAt: JsonHelpers.dateTime(json, 'fedAt') ?? DateTime.now(),
      createdAt: JsonHelpers.dateTime(json, 'createdAt') ?? DateTime.now(),
    );
  }

  
  @override
  List<Object?> get props => [id, petId, type, amountGrams, fedAt];
}

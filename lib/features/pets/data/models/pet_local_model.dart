import '../../../../core/models/base_model.dart';

/// Local (Hive/SQLite) data model for pets
///
/// Mirrors PetEntity but is specific to local storage format.
/// Converts to/from PetEntity for domain layer communication.
class PetLocalModel extends BaseModel {
  final String id;
  final String name;
  final String species;
  final String breed;
  final String? photoUri;
  final String? birthDate;
  final double? weight;
  final String? notes;
  final bool isNeutered;
  final bool isMicrochipped;
  final String? microchipId;
  final String createdAt;
  final String updatedAt;

  const PetLocalModel({
    required this.id,
    required this.name,
    required this.species,
    this.breed = '',
    this.photoUri,
    this.birthDate,
    this.weight,
    this.notes,
    this.isNeutered = false,
    this.isMicrochipped = false,
    this.microchipId,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Convert domain entity to local model
  factory PetLocalModel.fromEntity(dynamic entity) {
    final e = entity as dynamic;
    return PetLocalModel(
      id: e.id,
      name: e.name,
      species: e.species.name,
      breed: e.breed,
      photoUri: e.photoUri,
      birthDate: e.birthDate?.toIso8601String(),
      weight: e.weight,
      notes: e.notes,
      isNeutered: e.isNeutered,
      isMicrochipped: e.isMicrochipped,
      microchipId: e.microchipId,
      createdAt: e.createdAt.toIso8601String(),
      updatedAt: e.updatedAt.toIso8601String(),
    );
  }

  /// Convert local model to domain entity JSON.
  ///
  /// Returns a map that can be passed to [PetEntity.fromJson].
  /// Conversion is done at the repository layer to avoid circular imports.
  Map<String, dynamic> toEntityJson() {
    return {
      'id': id,
      'name': name,
      'species': species,
      'breed': breed,
      'photoUri': photoUri,
      'birthDate': birthDate,
      'weight': weight,
      'notes': notes,
      'isNeutered': isNeutered,
      'isMicrochipped': isMicrochipped,
      'microchipId': microchipId,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'species': species,
    'breed': breed,
    'photoUri': photoUri,
    'birthDate': birthDate,
    'weight': weight,
    'notes': notes,
    'isNeutered': isNeutered,
    'isMicrochipped': isMicrochipped,
    'microchipId': microchipId,
    'createdAt': createdAt,
    'updatedAt': updatedAt,
  };

  factory PetLocalModel.fromJson(Map<String, dynamic> json) {
    return PetLocalModel(
      id: json['id'] as String,
      name: json['name'] as String,
      species: json['species'] as String,
      breed: json['breed'] as String? ?? '',
      photoUri: json['photoUri'] as String?,
      birthDate: json['birthDate'] as String?,
      weight: json['weight'] as double?,
      notes: json['notes'] as String?,
      isNeutered: json['isNeutered'] as bool? ?? false,
      isMicrochipped: json['isMicrochipped'] as bool? ?? false,
      microchipId: json['microchipId'] as String?,
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String,
    );
  }
}

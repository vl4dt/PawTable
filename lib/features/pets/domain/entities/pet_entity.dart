import 'package:equatable/equatable.dart';
import '../../../../core/models/base_model.dart';
import '../../../../core/models/base_model.dart' show JsonHelpers;

/// Pet life stages
enum LifeStage {
  puppy('Puppy'),
  kitten('Kitten'),
  juvenile('Juvenile'),
  adult('Adult'),
  senior('Senior'),
  geriatric('Geriatric');

  final String label;
  const LifeStage(this.label);
}

/// Pet species
enum PetSpecies {
  dog('Dog'),
  cat('Cat'),
  bird('Bird'),
  rabbit('Rabbit'),
  fish('Fish'),
  reptile('Reptile'),
  hamster('Hamster'),
  horse('Horse'),
  other('Other');

  final String label;
  const PetSpecies(this.label);
}

/// Pet breed template (species-specific)
class BreedTemplate {
  final PetSpecies species;
  final List<String> breeds;

  const BreedTemplate({required this.species, required this.breeds});
}

/// Pet entity — domain-level model
///
/// This is the canonical representation of a pet, independent of
/// storage format or UI concerns.
class PetEntity extends Equatable {
  final String id;
  final String name;
  final PetSpecies species;
  final String breed;
  final String? photoUri;
  final DateTime? birthDate;
  final double? weight;
  final String? notes;
  final bool isNeutered;
  final bool isMicrochipped;
  final String? microchipId;
  final DateTime createdAt;
  final DateTime updatedAt;

  const PetEntity({
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

  /// Calculate pet's age in years (approximate)
  double get ageInYears {
    if (birthDate == null) return 0;
    final now = DateTime.now();
    return (now.difference(birthDate!).inDays / 365.25).toDouble();
  }

  /// Determine life stage based on age
  LifeStage get lifeStage {
    final age = ageInYears;
    if (species == PetSpecies.cat || species == PetSpecies.dog) {
      if (age < 1) return LifeStage.puppy; // or kitten
      if (age < 2) return LifeStage.juvenile;
      if (age < 7) return LifeStage.adult;
      if (age < 10) return LifeStage.senior;
      return LifeStage.geriatric;
    }
    if (species == PetSpecies.rabbit) {
      if (age < 1) return LifeStage.juvenile;
      if (age < 3) return LifeStage.adult;
      if (age < 5) return LifeStage.senior;
      return LifeStage.geriatric;
    }
    // Default: adult
    return LifeStage.adult;
  }

  PetEntity copyWith({
    String? id,
    String? name,
    PetSpecies? species,
    String? breed,
    String? photoUri,
    DateTime? birthDate,
    double? weight,
    String? notes,
    bool? isNeutered,
    bool? isMicrochipped,
    String? microchipId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PetEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      species: species ?? this.species,
      breed: breed ?? this.breed,
      photoUri: photoUri ?? this.photoUri,
      birthDate: birthDate ?? this.birthDate,
      weight: weight ?? this.weight,
      notes: notes ?? this.notes,
      isNeutered: isNeutered ?? this.isNeutered,
      isMicrochipped: isMicrochipped ?? this.isMicrochipped,
      microchipId: microchipId ?? this.microchipId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'species': species.name,
    'breed': breed,
    'photoUri': photoUri,
    'birthDate': birthDate?.toIso8601String(),
    'weight': weight,
    'notes': notes,
    'isNeutered': isNeutered,
    'isMicrochipped': isMicrochipped,
    'microchipId': microchipId,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  factory PetEntity.fromJson(Map<String, dynamic> json) {
    return PetEntity(
      id: json['id'] as String,
      name: json['name'] as String,
      species: PetSpecies.values.byName(json['species'] as String),
      breed: json['breed'] as String? ?? '',
      photoUri: json['photoUri'] as String?,
      birthDate: JsonHelpers.dateTime(json, 'birthDate'),
      weight: JsonHelpers.doubleVal(json, 'weight'),
      notes: json['notes'] as String?,
      isNeutered: json['isNeutered'] as bool? ?? false,
      isMicrochipped: json['isMicrochipped'] as bool? ?? false,
      microchipId: json['microchipId'] as String?,
      createdAt: JsonHelpers.dateTime(json, 'createdAt') ?? DateTime.now(),
      updatedAt: JsonHelpers.dateTime(json, 'updatedAt') ?? DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    species,
    breed,
    photoUri,
    birthDate,
    weight,
    notes,
    isNeutered,
    isMicrochipped,
    microchipId,
  ];
}

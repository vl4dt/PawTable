import 'dart:convert';

import 'package:equatable/equatable.dart';

import '../../../../core/models/base_model.dart' show JsonHelpers;
import '../../../../features/family/domain/entities/family_group_entity.dart';
import '../../../../features/pets/domain/entities/pet_entity.dart';

/// Shared pet profile — represents a pet shared within a family group
/// with role-based edit permissions
class SharedPetProfile extends Equatable {
  final String id;
  final String petId;
  final PetEntity pet;
  final String groupId;
  final String sharedBy;
  final String sharedByName;
  final DateTime sharedAt;
  final DateTime updatedAt;

  const SharedPetProfile({
    required this.id,
    required this.petId,
    required this.pet,
    required this.groupId,
    required this.sharedBy,
    required this.sharedByName,
    required this.sharedAt,
    required this.updatedAt,
  });

  /// Check if this profile can be edited by a given member
  bool canEdit(FamilyMemberEntity member) {
    return member.role == FamilyRole.owner ||
        member.role == FamilyRole.admin;
  }

  /// Check if this profile can be viewed by a given member
  bool canView(FamilyMemberEntity member) {
    // All members can view shared pets
    return true;
  }

  /// Check if this profile can be edited by a given member
  bool canEditLogs(FamilyMemberEntity member) {
    // Owner and admin can edit all logs
    if (member.role == FamilyRole.owner ||
        member.role == FamilyRole.admin) {
      return true;
    }
    // Member can edit some logs (feed, weight, behavior)
    if (member.role == FamilyRole.member) {
      return true;
    }
    // Pet sitter can only feed and log behavior
    if (member.role == FamilyRole.petSitter) {
      return true;
    }
    return false;
  }

  /// Create a copy with overridden fields
  SharedPetProfile copyWith({
    String? id,
    String? petId,
    PetEntity? pet,
    String? groupId,
    String? sharedBy,
    String? sharedByName,
    DateTime? sharedAt,
    DateTime? updatedAt,
  }) {
    return SharedPetProfile(
      id: id ?? this.id,
      petId: petId ?? this.petId,
      pet: pet ?? this.pet,
      groupId: groupId ?? this.groupId,
      sharedBy: sharedBy ?? this.sharedBy,
      sharedByName: sharedByName ?? this.sharedByName,
      sharedAt: sharedAt ?? this.sharedAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() => {
        'id': id,
        'petId': petId,
        'pet': pet.toJson(),
        'groupId': groupId,
        'sharedBy': sharedBy,
        'sharedByName': sharedByName,
        'sharedAt': sharedAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  /// Create from JSON
  factory SharedPetProfile.fromJson(Map<String, dynamic> json) {
    return SharedPetProfile(
      id: json['id'] as String,
      petId: json['petId'] as String,
      pet: PetEntity.fromJson(json['pet'] as Map<String, dynamic>),
      groupId: json['groupId'] as String,
      sharedBy: json['sharedBy'] as String,
      sharedByName: json['sharedByName'] as String,
      sharedAt:
          JsonHelpers.dateTime(json, 'sharedAt') ?? DateTime.now(),
      updatedAt:
          JsonHelpers.dateTime(json, 'updatedAt') ?? DateTime.now(),
    );
  }

  /// Create from database row
  factory SharedPetProfile.fromDbRow(Map<String, dynamic> row) {
    return SharedPetProfile(
      id: row['id'] as String,
      petId: row['petId'] as String,
      pet: PetEntity.fromJson(
        jsonDecode(row['petData'] as String),
      ),
      groupId: row['groupId'] as String,
      sharedBy: row['sharedBy'] as String,
      sharedByName: row['sharedByName'] as String,
      sharedAt: DateTime.parse(row['sharedAt'] as String),
      updatedAt: DateTime.parse(row['updatedAt'] as String),
    );
  }

  /// Create a placeholder profile for a pet that hasn't been shared yet
  factory SharedPetProfile.createPlaceholder({
    required String petId,
    required String groupId,
    required String sharedBy,
    required String sharedByName,
    PetEntity? pet,
  }) {
    return SharedPetProfile(
      id: '',
      petId: petId,
      pet: pet ??
          PetEntity(
            id: petId,
            name: 'Loading...',
            species: PetSpecies.other,
            breed: '',
            photoUri: null,
            birthDate: null,
            weight: null,
            notes: '',
            isNeutered: false,
            isMicrochipped: false,
            microchipId: null,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
      groupId: groupId,
      sharedBy: sharedBy,
      sharedByName: sharedByName,
      sharedAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  /// Convert to database map
  Map<String, dynamic> toDbMap() {
    return {
      'id': id,
      'petId': petId,
      'petData': pet.toJson(),
      'groupId': groupId,
      'sharedBy': sharedBy,
      'sharedByName': sharedByName,
      'sharedAt': sharedAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [id, petId, groupId];
}

/// Edit capability per log type
class LogEditCapability {
  final bool canFeed;
  final bool canVaccinate;
  final bool canMedicate;
  final bool canWeight;
  final bool canBehavior;
  final bool canHealth;
  final bool canView;

  const LogEditCapability({
    this.canFeed = false,
    this.canVaccinate = false,
    this.canMedicate = false,
    this.canWeight = false,
    this.canBehavior = false,
    this.canHealth = false,
    this.canView = false,
  });

  /// Owner can edit everything
  static const LogEditCapability owner = LogEditCapability(
    canFeed: true,
    canVaccinate: true,
    canMedicate: true,
    canWeight: true,
    canBehavior: true,
    canHealth: true,
    canView: true,
  );

  /// Admin can edit everything
  static const LogEditCapability admin = LogEditCapability(
    canFeed: true,
    canVaccinate: true,
    canMedicate: true,
    canWeight: true,
    canBehavior: true,
    canHealth: true,
    canView: true,
  );

  /// Member can feed, weight, behavior, health
  static const LogEditCapability member = LogEditCapability(
    canFeed: true,
    canWeight: true,
    canBehavior: true,
    canHealth: true,
    canView: true,
  );

  /// Pet sitter can feed and log behavior
  static const LogEditCapability petSitter = LogEditCapability(
    canFeed: true,
    canBehavior: true,
    canView: true,
  );

  /// Check if any logs can be edited
  bool get hasAnyEdit =>
      canFeed ||
      canVaccinate ||
      canMedicate ||
      canWeight ||
      canBehavior ||
      canHealth;

  @override
  String toString() {
    return 'LogEditCapability('
        'feed:$canFeed, '
        'vaccinate:$canVaccinate, '
        'medicate:$canMedicate, '
        'weight:$canWeight, '
        'behavior:$canBehavior, '
        'health:$canHealth, '
        'view:$canView)';
  }
}

/// Shared pet profile with edit capabilities
class SharedPetProfileWithCapabilities extends Equatable {
  final SharedPetProfile profile;
  final String currentUserId;
  final String currentUserName;
  final FamilyMemberEntity memberEntity;
  final LogEditCapability capabilities;

  const SharedPetProfileWithCapabilities({
    required this.profile,
    required this.currentUserId,
    required this.currentUserName,
    required this.memberEntity,
    required this.capabilities,
  });

  /// Check if current user can edit logs
  bool get canEditLogs => capabilities.hasAnyEdit;

  /// Check if current user can manage this shared profile
  bool get canManage =>
      memberEntity.role == FamilyRole.owner ||
      memberEntity.role == FamilyRole.admin;

  /// Check if current user is the pet owner
  bool get isPetOwner => profile.sharedBy == currentUserId;

  SharedPetProfileWithCapabilities copyWith({
    SharedPetProfile? profile,
    String? currentUserId,
    String? currentUserName,
    FamilyMemberEntity? memberEntity,
    LogEditCapability? capabilities,
  }) {
    return SharedPetProfileWithCapabilities(
      profile: profile ?? this.profile,
      currentUserId: currentUserId ?? this.currentUserId,
      currentUserName: currentUserName ?? this.currentUserName,
      memberEntity: memberEntity ?? this.memberEntity,
      capabilities: capabilities ?? this.capabilities,
    );
  }

  @override
  List<Object?> get props => [profile.id, currentUserId];
}

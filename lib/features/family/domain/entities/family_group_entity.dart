import 'package:equatable/equatable.dart';
import '../../../../core/models/base_model.dart';
import '../../../../core/models/base_model.dart' show JsonHelpers;

/// Family role
enum FamilyRole { owner, admin, member, petSitter }

/// Extension for role serialization
extension FamilyRoleSerializer on FamilyRole {
  String toName() {
    switch (this) {
      case FamilyRole.owner:
        return 'owner';
      case FamilyRole.admin:
        return 'admin';
      case FamilyRole.member:
        return 'member';
      case FamilyRole.petSitter:
        return 'petsitter';
    }
  }

  static FamilyRole fromName(String name) {
    switch (name) {
      case 'owner':
        return FamilyRole.owner;
      case 'admin':
        return FamilyRole.admin;
      case 'member':
        return FamilyRole.member;
      case 'petsitter':
        return FamilyRole.petSitter;
      default:
        return FamilyRole.member;
    }
  }

  String get displayName {
    switch (this) {
      case FamilyRole.owner:
        return 'Owner';
      case FamilyRole.admin:
        return 'Admin';
      case FamilyRole.member:
        return 'Member';
      case FamilyRole.petSitter:
        return 'Pet Sitter';
    }
  }

  /// Role code for UI layer icon mapping
  int get iconCode {
    switch (this) {
      case FamilyRole.owner:
        return 0;
      case FamilyRole.admin:
        return 1;
      case FamilyRole.member:
        return 2;
      case FamilyRole.petSitter:
        return 3;
    }
  }
}

/// Family group entity
class FamilyGroupEntity extends Equatable {
  final String id;
  final String name;
  final String ownerId;
  final DateTime createdAt;
  final DateTime updatedAt;

  const FamilyGroupEntity({
    required this.id,
    required this.name,
    required this.ownerId,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isOwner => false; // Checked against current user

  FamilyGroupEntity copyWith({
    String? id,
    String? name,
    String? ownerId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return FamilyGroupEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      ownerId: ownerId ?? this.ownerId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'ownerId': ownerId,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory FamilyGroupEntity.fromJson(Map<String, dynamic> json) {
    return FamilyGroupEntity(
      id: json['id'] as String,
      name: json['name'] as String,
      ownerId: json['ownerId'] as String,
      createdAt: JsonHelpers.dateTime(json, 'createdAt') ?? DateTime.now(),
      updatedAt: JsonHelpers.dateTime(json, 'updatedAt') ?? DateTime.now(),
    );
  }

  factory FamilyGroupEntity.fromDbRow(Map<String, dynamic> row) {
    return FamilyGroupEntity(
      id: row['id'] as String,
      name: row['name'] as String,
      ownerId: row['ownerId'] as String,
      createdAt: DateTime.parse(row['createdAt'] as String),
      updatedAt: DateTime.parse(row['updatedAt'] as String),
    );
  }

  @override
  List<Object?> get props => [id, name, ownerId, createdAt];
}

/// Family member entity
class FamilyMemberEntity extends Equatable {
  final String id;
  final String groupId;
  final String userId;
  final String displayName;
  final FamilyRole role;
  final DateTime joinedAt;

  const FamilyMemberEntity({
    required this.id,
    required this.groupId,
    required this.userId,
    required this.displayName,
    required this.role,
    required this.joinedAt,
  });

  bool get isOwner => role == FamilyRole.owner;
  bool get isAdmin => role == FamilyRole.admin;
  bool isAllowedToEdit() => role == FamilyRole.owner || role == FamilyRole.admin;

  FamilyMemberEntity copyWith({
    String? id,
    String? groupId,
    String? userId,
    String? displayName,
    FamilyRole? role,
    DateTime? joinedAt,
  }) {
    return FamilyMemberEntity(
      id: id ?? this.id,
      groupId: groupId ?? this.groupId,
      userId: userId ?? this.userId,
      displayName: displayName ?? this.displayName,
      role: role ?? this.role,
      joinedAt: joinedAt ?? this.joinedAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'groupId': groupId,
        'userId': userId,
        'displayName': displayName,
        'role': role.toName(),
        'joinedAt': joinedAt.toIso8601String(),
      };

  factory FamilyMemberEntity.fromJson(Map<String, dynamic> json) {
    return FamilyMemberEntity(
      id: json['id'] as String,
      groupId: json['groupId'] as String,
      userId: json['userId'] as String,
      displayName: json['displayName'] as String,
      role: FamilyRoleSerializer.fromName(json['role'] as String),
      joinedAt: JsonHelpers.dateTime(json, 'joinedAt') ?? DateTime.now(),
    );
  }

  factory FamilyMemberEntity.fromDbRow(Map<String, dynamic> row) {
    return FamilyMemberEntity(
      id: row['id'] as String,
      groupId: row['groupId'] as String,
      userId: row['userId'] as String,
      displayName: row['displayName'] as String,
      role: FamilyRoleSerializer.fromName(row['role'] as String),
      joinedAt: DateTime.parse(row['joinedAt'] as String),
    );
  }

  @override
  List<Object?> get props => [id, groupId, userId, displayName, role, joinedAt];
}

/// Pet-family link entity
class PetFamilyLinkEntity extends Equatable {
  final String id;
  final String petId;
  final String groupId;
  final String sharedBy;
  final DateTime sharedAt;

  const PetFamilyLinkEntity({
    required this.id,
    required this.petId,
    required this.groupId,
    required this.sharedBy,
    required this.sharedAt,
  });

  PetFamilyLinkEntity copyWith({
    String? id,
    String? petId,
    String? groupId,
    String? sharedBy,
    DateTime? sharedAt,
  }) {
    return PetFamilyLinkEntity(
      id: id ?? this.id,
      petId: petId ?? this.petId,
      groupId: groupId ?? this.groupId,
      sharedBy: sharedBy ?? this.sharedBy,
      sharedAt: sharedAt ?? this.sharedAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'petId': petId,
        'groupId': groupId,
        'sharedBy': sharedBy,
        'sharedAt': sharedAt.toIso8601String(),
      };

  factory PetFamilyLinkEntity.fromJson(Map<String, dynamic> json) {
    return PetFamilyLinkEntity(
      id: json['id'] as String,
      petId: json['petId'] as String,
      groupId: json['groupId'] as String,
      sharedBy: json['sharedBy'] as String,
      sharedAt: JsonHelpers.dateTime(json, 'sharedAt') ?? DateTime.now(),
    );
  }

  factory PetFamilyLinkEntity.fromDbRow(Map<String, dynamic> row) {
    return PetFamilyLinkEntity(
      id: row['id'] as String,
      petId: row['petId'] as String,
      groupId: row['groupId'] as String,
      sharedBy: row['sharedBy'] as String,
      sharedAt: DateTime.parse(row['sharedAt'] as String),
    );
  }

  @override
  List<Object?> get props => [id, petId, groupId, sharedBy];
}

/// Family summary — aggregated view
class FamilySummary extends Equatable {
  final FamilyGroupEntity group;
  final List<FamilyMemberEntity> members;
  final List<String> sharedPetIds;
  final int memberCount;
  final bool isPremium;

  const FamilySummary({
    required this.group,
    required this.members,
    this.sharedPetIds = const [],
    this.memberCount = 0,
    this.isPremium = false,
  });

  /// Free tier allows 2 members, premium allows 5
  int get maxMembers => isPremium ? 5 : 2;
  bool get hasRoomForMore => memberCount < maxMembers;

  @override
  List<Object?> get props => [group, members, sharedPetIds, memberCount];
}

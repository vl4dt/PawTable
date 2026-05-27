import 'package:equatable/equatable.dart';
import '../../domain/entities/family_group_entity.dart';

/// Local storage model for family members — maps to SQLite `family_members` table
class FamilyMemberLocalModel extends Equatable {
  final String id;
  final String groupId;
  final String userId;
  final String displayName;
  final String role;
  final String joinedAt;

  const FamilyMemberLocalModel({
    required this.id,
    required this.groupId,
    required this.userId,
    required this.displayName,
    required this.role,
    required this.joinedAt,
  });

  /// Convert to entity
  FamilyMemberEntity toEntity() {
    return FamilyMemberEntity(
      id: id,
      groupId: groupId,
      userId: userId,
      displayName: displayName,
      role: FamilyRoleSerializer.fromName(role),
      joinedAt: DateTime.parse(joinedAt),
    );
  }

  /// Create from database row (Map)
  factory FamilyMemberLocalModel.fromDbRow(Map<String, dynamic> row) {
    return FamilyMemberLocalModel(
      id: row['id'] as String,
      groupId: row['groupId'] as String,
      userId: row['userId'] as String,
      displayName: row['displayName'] as String,
      role: row['role'] as String,
      joinedAt: row['joinedAt'] as String,
    );
  }

  /// Convert to database map
  Map<String, dynamic> toDbMap() => {
        'id': id,
        'groupId': groupId,
        'userId': userId,
        'displayName': displayName,
        'role': role,
        'joinedAt': joinedAt,
      };

  @override
  List<Object?> get props => [id, groupId, userId, displayName, role, joinedAt];
}

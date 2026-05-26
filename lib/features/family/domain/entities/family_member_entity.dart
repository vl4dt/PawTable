import 'package:equatable/equatable.dart';
import '../../../../core/models/base_model.dart' show JsonHelpers;

/// Family member entity
class FamilyMemberEntity extends Equatable {
  final String id;
  final String userId;
  final String displayName;
  final String? avatarUri;
  final int role; // 0=owner, 1=admin, 2=member
  final DateTime joinedAt;
  final DateTime updatedAt;

  const FamilyMemberEntity({
    required this.id,
    required this.userId,
    required this.displayName,
    this.avatarUri,
    this.role = 2,
    required this.joinedAt,
    required this.updatedAt,
  });

  bool get isOwner => role == 0;
  bool get isAdmin => role == 1;

  
  Map<String, dynamic> toJson() => {
    'id': id, 'userId': userId, 'displayName': displayName,
    'avatarUri': avatarUri, 'role': role,
    'joinedAt': joinedAt.toIso8601String(), 'updatedAt': updatedAt.toIso8601String(),
  };

  factory FamilyMemberEntity.fromJson(Map<String, dynamic> json) {
    return FamilyMemberEntity(
      id: json['id'] as String, userId: json['userId'] as String,
      displayName: json['displayName'] as String,
      avatarUri: json['avatarUri'] as String?,
      role: json['role'] as int? ?? 2,
      joinedAt: JsonHelpers.dateTime(json, 'joinedAt') ?? DateTime.now(),
      updatedAt: JsonHelpers.dateTime(json, 'updatedAt') ?? DateTime.now(),
    );
  }

  
  @override
  List<Object?> get props => [id, userId, displayName, role];
}

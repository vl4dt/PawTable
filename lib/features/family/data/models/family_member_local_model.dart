import 'package:equatable/equatable.dart';

/// Family member record — local Hive/SQLite model
class FamilyMemberLocalModel extends Equatable {
  final String id;
  final String petId;
  final String userId;
  final String name;
  final String role;
  final String joinedAt;
  final String? avatarUrl;

  const FamilyMemberLocalModel({
    required this.id,
    required this.petId,
    required this.userId,
    required this.name,
    required this.role,
    required this.joinedAt,
    this.avatarUrl,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'petId': petId,
        'userId': userId,
        'name': name,
        'role': role,
        'joinedAt': joinedAt,
        'avatarUrl': avatarUrl,
      };

  factory FamilyMemberLocalModel.fromJson(Map<String, dynamic> json) {
    return FamilyMemberLocalModel(
      id: json['id'] as String,
      petId: json['petId'] as String,
      userId: json['userId'] as String,
      name: json['name'] as String,
      role: json['role'] as String,
      joinedAt: json['joinedAt'] as String,
      avatarUrl: json['avatarUrl'] as String?,
    );
  }

  @override
  List<Object?> get props => [id, petId, userId, name, role, joinedAt, avatarUrl];
}

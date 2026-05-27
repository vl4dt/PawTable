import 'package:equatable/equatable.dart';
import '../../domain/entities/invite_entity.dart';

/// Local storage model for invite tokens — maps to SQLite `invite_tokens` table
class InviteLocalModel extends Equatable {
  final String id;
  final String groupId;
  final String createdById;
  final String code;
  final String status;
  final int maxUses;
  final int usedCount;
  final String expiresAt;
  final String createdAt;

  const InviteLocalModel({
    required this.id,
    required this.groupId,
    required this.createdById,
    required this.code,
    this.status = 'active',
    this.maxUses = 1,
    this.usedCount = 0,
    required this.expiresAt,
    required this.createdAt,
  });

  /// Convert to domain entity
  InviteToken toEntity() {
    return InviteToken(
      id: id,
      groupId: groupId,
      createdById: createdById,
      code: code,
      status: InviteStatus.values.firstWhere(
        (s) => s.name == status,
        orElse: () => InviteStatus.active,
      ),
      maxUses: maxUses,
      usedCount: usedCount,
      expiresAt: DateTime.parse(expiresAt),
      createdAt: DateTime.parse(createdAt),
    );
  }

  /// Create from database row (Map)
  factory InviteLocalModel.fromDbRow(Map<String, dynamic> row) {
    return InviteLocalModel(
      id: row['id'] as String,
      groupId: row['groupId'] as String,
      createdById: row['createdById'] as String,
      code: row['code'] as String,
      status: row['status'] as String? ?? 'active',
      maxUses: row['maxUses'] as int? ?? 1,
      usedCount: row['usedCount'] as int? ?? 0,
      expiresAt: row['expiresAt'] as String,
      createdAt: row['createdAt'] as String,
    );
  }

  /// Convert to database map
  Map<String, dynamic> toDbMap() => {
        'id': id,
        'groupId': groupId,
        'createdById': createdById,
        'code': code,
        'status': status,
        'maxUses': maxUses,
        'usedCount': usedCount,
        'expiresAt': expiresAt,
        'createdAt': createdAt,
      };

  /// Create a copy with overridden fields
  InviteLocalModel copyWith({
    String? id,
    String? groupId,
    String? createdById,
    String? code,
    String? status,
    int? maxUses,
    int? usedCount,
    String? expiresAt,
    String? createdAt,
  }) {
    return InviteLocalModel(
      id: id ?? this.id,
      groupId: groupId ?? this.groupId,
      createdById: createdById ?? this.createdById,
      code: code ?? this.code,
      status: status ?? this.status,
      maxUses: maxUses ?? this.maxUses,
      usedCount: usedCount ?? this.usedCount,
      expiresAt: expiresAt ?? this.expiresAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        groupId,
        code,
        status,
        usedCount,
        maxUses,
        expiresAt,
      ];
}

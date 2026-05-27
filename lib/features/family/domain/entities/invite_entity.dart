import 'package:equatable/equatable.dart';
import '../../../../core/models/base_model.dart' show JsonHelpers;
import 'family_group_entity.dart';

/// Status of an invite token
enum InviteStatus {
  active,
  accepted,
  expired,
  cancelled,
}

/// Type of invite method
enum InviteMethod {
  link,   // Deep link
  email,  // Email invite
  code,   // Manual code entry
}

/// Invite token entity
class InviteToken extends Equatable {
  final String id;
  final String groupId;
  final String createdById;
  final String code;
  final InviteStatus status;
  final int maxUses;
  final int usedCount;
  final DateTime expiresAt;
  final DateTime createdAt;

  const InviteToken({
    required this.id,
    required this.groupId,
    required this.createdById,
    required this.code,
    this.status = InviteStatus.active,
    this.maxUses = 1,
    this.usedCount = 0,
    required this.expiresAt,
    required this.createdAt,
  });

  /// Whether the invite is currently usable
  bool get isUsable =>
      status == InviteStatus.active &&
      DateTime.now().isBefore(expiresAt) &&
      usedCount < maxUses;

  /// Whether the invite has expired
  bool get isExpired => DateTime.now().isAfter(expiresAt);

  /// Generate a short shareable link
  String toShareLink() => 'pawtable://join/$code';

  /// Generate a deep link URL
  String toDeepLinkUrl(String baseUrl) => '$baseUrl/join/$code';

  InviteToken copyWith({
    String? id,
    String? groupId,
    String? createdById,
    String? code,
    InviteStatus? status,
    int? maxUses,
    int? usedCount,
    DateTime? expiresAt,
    DateTime? createdAt,
  }) {
    return InviteToken(
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

  Map<String, dynamic> toJson() => {
        'id': id,
        'groupId': groupId,
        'createdById': createdById,
        'code': code,
        'status': status.name,
        'maxUses': maxUses,
        'usedCount': usedCount,
        'expiresAt': expiresAt.toIso8601String(),
        'createdAt': createdAt.toIso8601String(),
      };

  factory InviteToken.fromJson(Map<String, dynamic> json) {
    return InviteToken(
      id: json['id'] as String,
      groupId: json['groupId'] as String,
      createdById: json['createdById'] as String,
      code: json['code'] as String,
      status: InviteStatus.values.firstWhere(
        (s) => s.name == json['status'],
        orElse: () => InviteStatus.active,
      ),
      maxUses: json['maxUses'] as int? ?? 1,
      usedCount: json['usedCount'] as int? ?? 0,
      expiresAt: JsonHelpers.dateTime(json, 'expiresAt') ?? DateTime.now(),
      createdAt: JsonHelpers.dateTime(json, 'createdAt') ?? DateTime.now(),
    );
  }

  factory InviteToken.fromDbRow(Map<String, dynamic> row) {
    return InviteToken(
      id: row['id'] as String,
      groupId: row['groupId'] as String,
      createdById: row['createdById'] as String,
      code: row['code'] as String,
      status: InviteStatus.values.firstWhere(
        (s) => s.name == row['status'] as String,
        orElse: () => InviteStatus.active,
      ),
      maxUses: row['maxUses'] as int? ?? 1,
      usedCount: row['usedCount'] as int? ?? 0,
      expiresAt: DateTime.parse(row['expiresAt'] as String),
      createdAt: DateTime.parse(row['createdAt'] as String),
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

/// Invite action result
class InviteResult {
  final bool success;
  final String message;
  final FamilyMemberEntity? member;

  const InviteResult({
    required this.success,
    required this.message,
    this.member,
  });

  factory InviteResult.success({
    required String message,
    required FamilyMemberEntity member,
  }) {
    return InviteResult(
      success: true,
      message: message,
      member: member,
    );
  }

  factory InviteResult.failure(String message) {
    return InviteResult(
      success: false,
      message: message,
    );
  }

  factory InviteResult.expired() {
    return InviteResult(
      success: false,
      message: 'This invite link has expired.',
    );
  }

  factory InviteResult.alreadyUsed() {
    return InviteResult(
      success: false,
      message: 'This invite link has already been used.',
    );
  }

  factory InviteResult.invalid() {
    return InviteResult(
      success: false,
      message: 'This invite link is not valid.',
    );
  }
}

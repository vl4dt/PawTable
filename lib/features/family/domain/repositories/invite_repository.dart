import 'dart:async';

import '../entities/invite_entity.dart';

/// Repository for managing family invite tokens
abstract class InviteRepository {
  /// Create a new invite token for a family group
  Future<InviteToken> createInvite({
    required String groupId,
    required String createdById,
    int maxUses,
    Duration expiry,
  });

  /// Validate an invite token by its code
  Future<InviteToken?> validateInvite(String code);

  /// Accept an invite token — adds user to the group
  Future<InviteResult> acceptInvite({
    required String code,
    required String userId,
    required String displayName,
  });

  /// Cancel an existing invite
  Future<void> cancelInvite(String inviteId);

  /// Get all active invites for a group
  Stream<List<InviteToken>> streamActiveInvites(String groupId);

  /// Get a single invite by ID
  Future<InviteToken?> getInvite(String inviteId);

  /// Expire old invites
  Future<void> expireOldInvites();
}

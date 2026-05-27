import 'package:uuid/uuid.dart';
import '../../../../core/repository/base_repository.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/storage/database_helper.dart';
import '../../domain/entities/invite_entity.dart';
import '../../domain/entities/family_group_entity.dart';
import '../models/family_member_local_model.dart';
import '../../domain/repositories/invite_repository.dart';
import '../models/invite_local_model.dart';

/// Invite repository implementation using SQLite
class InviteRepositoryImpl extends BaseRepository implements InviteRepository {
  final DatabaseHelper _dbHelper;
  final _uuid = const Uuid();

  InviteRepositoryImpl({required DatabaseHelper dbHelper})
      : _dbHelper = dbHelper;

  @override
  Future<InviteToken> createInvite({
    required String groupId,
    required String createdById,
    int maxUses = 1,
    Duration expiry = const Duration(days: 7),
  }) async {
    try {
      final code = _generateInviteCode();
      final now = DateTime.now();
      final expiresAt = now.add(expiry);

      final model = InviteLocalModel(
        id: _uuid.v4(),
        groupId: groupId,
        createdById: createdById,
        code: code,
        status: 'active',
        maxUses: maxUses,
        usedCount: 0,
        expiresAt: expiresAt.toIso8601String(),
        createdAt: now.toIso8601String(),
      );

      await _dbHelper.insertInviteToken(model.toDbMap());

      return model.toEntity();
    } catch (e) {
      throw AppException(message: 'Failed to create invite', code: e.toString());
    }
  }

  @override
  Future<InviteToken?> validateInvite(String code) async {
    try {
      final row = await _dbHelper.getInviteTokenByCode(code);
      if (row == null) return null;

      final model = InviteLocalModel.fromDbRow(row);
      final entity = model.toEntity();

      if (!entity.isUsable) return entity;
      return entity;
    } catch (e) {
      throw AppException(message: 'Failed to validate invite', code: e.toString());
    }
  }

  @override
  Future<InviteResult> acceptInvite({
    required String code,
    required String userId,
    required String displayName,
  }) async {
    try {
      // Find the invite
      final row = await _dbHelper.getInviteTokenByCode(code);
      if (row == null) return InviteResult.invalid();

      final model = InviteLocalModel.fromDbRow(row);
      final entity = model.toEntity();

      if (entity.status == InviteStatus.expired) return InviteResult.expired();
      if (entity.status == InviteStatus.cancelled) return InviteResult.invalid();
      if (entity.usedCount >= entity.maxUses) return InviteResult.alreadyUsed();

      // Check if user is already in the group
      final members = await _dbHelper.getFamilyMembersByGroup(entity.groupId);
      for (final memberRow in members) {
        final member = FamilyMemberLocalModel.fromDbRow(memberRow);
        if (member.userId == userId) {
          return InviteResult.failure('You are already a member of this group.');
        }
      }

      // Update invite status
      final updated = model.copyWith(
        status: InviteStatus.accepted.name,
        usedCount: model.usedCount + 1,
      );
      await _dbHelper.updateInviteToken(updated.id, updated.toDbMap());

      return InviteResult.success(
        message: 'You have joined the group!',
        member: FamilyMemberEntity(
          id: _uuid.v4(),
          groupId: entity.groupId,
          userId: userId,
          displayName: displayName,
          role: FamilyRole.member,
          joinedAt: DateTime.now(),
        ),
      );
    } catch (e) {
      return InviteResult.failure('Failed to accept invite: $e');
    }
  }

  @override
  Future<void> cancelInvite(String inviteId) async {
    try {
      final row = await _dbHelper.getInviteToken(inviteId);
      if (row == null) return;

      final model = InviteLocalModel.fromDbRow(row);
      final updated = model.copyWith(status: InviteStatus.cancelled.name);
      await _dbHelper.updateInviteToken(inviteId, updated.toDbMap());
    } catch (e) {
      throw AppException(message: 'Failed to cancel invite', code: e.toString());
    }
  }

  @override
  Stream<List<InviteToken>> streamActiveInvites(String groupId) {
    try {
      return _dbHelper.getActiveInvitesByGroup(groupId).asStream().map(
        (rows) => rows.map((row) => InviteLocalModel.fromDbRow(row).toEntity()).toList(),
      );
    } catch (e) {
      return Stream.error(e);
    }
  }

  @override
  Future<InviteToken?> getInvite(String inviteId) async {
    try {
      final row = await _dbHelper.getInviteToken(inviteId);
      if (row == null) return null;
      return InviteLocalModel.fromDbRow(row).toEntity();
    } catch (e) {
      throw AppException(message: 'Failed to get invite', code: e.toString());
    }
  }

  @override
  Future<void> expireOldInvites() async {
    try {
      await _dbHelper.expireOldInvites();
    } catch (e) {
      throw AppException(message: 'Failed to expire old invites', code: e.toString());
    }
  }

  /// Generate a unique 8-character invite code
  String _generateInviteCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final uuid = _uuid.v4().replaceAll('-', '').toUpperCase();
    return uuid.substring(0, 8);
  }
}

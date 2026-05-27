import 'package:uuid/uuid.dart';

import '../../../../core/storage/database_helper.dart';
import '../../../../core/repository/base_repository.dart';
import '../../domain/entities/family_group_entity.dart';
import '../../domain/repositories/family_repository.dart';

/// Family repository implementation using SQLite
class FamilyRepositoryImpl extends BaseRepository implements FamilyRepository {
  final DatabaseHelper _dbHelper;
  final _uuid = const Uuid();

  FamilyRepositoryImpl({required DatabaseHelper dbHelper})
      : _dbHelper = dbHelper;

  // =========================================================================
  // FAMILY GROUPS
  // =========================================================================

  @override
  Future<List<FamilyGroupEntity>> getGroups() async {
    final rows = await _dbHelper.getAllFamilyGroups();
    return rows.map(FamilyGroupEntity.fromDbRow).toList();
  }

  @override
  Future<FamilyGroupEntity?> getGroup(String id) async {
    final row = await _dbHelper.getFamilyGroup(id);
    if (row == null) return null;
    return FamilyGroupEntity.fromDbRow(row);
  }

  @override
  Future<FamilyGroupEntity> createGroup(String name, String ownerId) async {
    final now = DateTime.now().toIso8601String();
    final id = _uuid.v4();
    await _dbHelper.insertFamilyGroup({
      'id': id,
      'name': name,
      'ownerId': ownerId,
      'createdAt': now,
      'updatedAt': now,
    });
    return FamilyGroupEntity(
      id: id,
      name: name,
      ownerId: ownerId,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  @override
  Future<void> updateGroup(FamilyGroupEntity group) async {
    await _dbHelper.updateFamilyGroup(group.id, {
      'name': group.name,
      'updatedAt': group.updatedAt.toIso8601String(),
    });
  }

  @override
  Future<void> deleteGroup(String id) async {
    await _dbHelper.deleteFamilyGroup(id);
  }

  // =========================================================================
  // FAMILY MEMBERS
  // =========================================================================

  @override
  Future<List<FamilyMemberEntity>> getMembers(String groupId) async {
    final rows = await _dbHelper.getFamilyMembersByGroup(groupId);
    return rows.map(FamilyMemberEntity.fromDbRow).toList();
  }

  @override
  Future<FamilyMemberEntity?> getMember(String id) async {
    final row = await _dbHelper.getFamilyMember(id);
    if (row == null) return null;
    return FamilyMemberEntity.fromDbRow(row);
  }

  @override
  Future<FamilyMemberEntity> addMember({
    required String groupId,
    required String userId,
    required String displayName,
    FamilyRole role = FamilyRole.member,
  }) {
    final id = _uuid.v4();
    final now = DateTime.now();
    return _dbHelper
        .insertFamilyMember({
          'id': id,
          'groupId': groupId,
          'userId': userId,
          'displayName': displayName,
          'role': role.toName(),
          'joinedAt': now.toIso8601String(),
        })
        .then((_) => FamilyMemberEntity(
              id: id,
              groupId: groupId,
              userId: userId,
              displayName: displayName,
              role: role,
              joinedAt: now,
            ));
  }

  @override
  Future<void> updateMember(FamilyMemberEntity member) async {
    await _dbHelper.updateFamilyMember(member.id, {
      'displayName': member.displayName,
      'role': member.role.toName(),
    });
  }

  @override
  Future<void> removeMember(String memberId) async {
    await _dbHelper.deleteFamilyMember(memberId);
  }

  // =========================================================================
  // PET FAMILY LINKS
  // =========================================================================

  @override
  Future<void> sharePet({
    required String petId,
    required String groupId,
    required String sharedBy,
  }) async {
    final now = DateTime.now().toIso8601String();
    final id = _uuid.v4();
    await _dbHelper.insertPetFamilyLink({
      'id': id,
      'petId': petId,
      'groupId': groupId,
      'sharedBy': sharedBy,
      'sharedAt': now,
    });
  }

  @override
  Future<void> unsharePet(String petId, String groupId) async {
    final rows = await _dbHelper.getPetFamilyLinksByGroup(groupId);
    for (final row in rows) {
      if (row['petId'] == petId) {
        await _dbHelper.deletePetFamilyLink(row['id'] as String);
        break;
      }
    }
  }

  @override
  Future<bool> isPetShared(String petId, String groupId) async {
    return await _dbHelper.isPetSharedWithGroup(petId, groupId);
  }

  @override
  Future<List<String>> getSharedPetIds(String groupId) async {
    final rows = await _dbHelper.getPetFamilyLinksByGroup(groupId);
    return rows.map((r) => r['petId'] as String).toList();
  }

  @override
  Future<List<String>> getSharedGroupIds(String petId) async {
    final rows = await _dbHelper.getPetFamilyLinksByPet(petId);
    return rows.map((r) => r['groupId'] as String).toList();
  }

  @override
  Future<FamilySummary> getSummary(String groupId) async {
    final group = await getGroup(groupId);
    if (group == null) {
      throw Exception('Family group not found: $groupId');
    }
    final members = await getMembers(groupId);
    final sharedPetIds = await getSharedPetIds(groupId);

    return FamilySummary(
      group: group,
      members: members,
      sharedPetIds: sharedPetIds,
      memberCount: members.length,
    );
  }
}

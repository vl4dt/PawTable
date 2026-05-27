import '../../../../core/repository/base_repository.dart';
import '../entities/family_group_entity.dart';

/// Repository for family collaboration data
abstract class FamilyRepository extends BaseRepository {
  /// Get all family groups the user belongs to
  Future<List<FamilyGroupEntity>> getGroups();

  /// Get a single family group by ID
  Future<FamilyGroupEntity?> getGroup(String id);

  /// Create a new family group
  Future<FamilyGroupEntity> createGroup(String name, String ownerId);

  /// Update a family group
  Future<void> updateGroup(FamilyGroupEntity group);

  /// Delete a family group
  Future<void> deleteGroup(String id);

  /// Get all members of a family group
  Future<List<FamilyMemberEntity>> getMembers(String groupId);

  /// Get a single family member
  Future<FamilyMemberEntity?> getMember(String id);

  /// Add a member to a family group
  Future<FamilyMemberEntity> addMember({
    required String groupId,
    required String userId,
    required String displayName,
    FamilyRole role = FamilyRole.member,
  });

  /// Update a family member's role
  Future<void> updateMember(FamilyMemberEntity member);

  /// Remove a member from a family group
  Future<void> removeMember(String memberId);

  /// Link a pet to a family group
  Future<void> sharePet({
    required String petId,
    required String groupId,
    required String sharedBy,
  });

  /// Unlink a pet from a family group
  Future<void> unsharePet(String petId, String groupId);

  /// Check if a pet is shared with a group
  Future<bool> isPetShared(String petId, String groupId);

  /// Get all pets shared with a group
  Future<List<String>> getSharedPetIds(String groupId);

  /// Get all groups a pet is shared with
  Future<List<String>> getSharedGroupIds(String petId);

  /// Get full family summary
  Future<FamilySummary> getSummary(String groupId);
}

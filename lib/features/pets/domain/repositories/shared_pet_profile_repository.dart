import '../../../../core/repository/base_repository.dart';
import '../entities/shared_pet_profile_entity.dart';

/// Repository interface for shared pet profiles
abstract class SharedPetProfileRepository extends BaseRepository {
  /// Get all shared pet profiles for a family group
  Future<List<SharedPetProfile>> getSharedProfiles(String groupId);

  /// Get a single shared pet profile by ID
  Future<SharedPetProfile?> getSharedProfile(String id);

  /// Get a shared pet profile by pet ID and group ID
  Future<SharedPetProfile?> getByPetIdAndGroup(String petId, String groupId);

  /// Share a pet with a family group
  Future<SharedPetProfile> sharePet({
    required String petId,
    required String groupId,
    required String sharedBy,
    required String sharedByName,
  });

  /// Unshare a pet from a family group
  Future<void> unsharePet(String id);

  /// Update a shared pet profile
  Future<void> updateSharedProfile(SharedPetProfile profile);

  /// Check if a pet is already shared with a group
  Future<bool> isPetShared(String petId, String groupId);

  /// Get all groups a pet is shared with
  Future<List<String>> getSharedGroupIds(String petId);

  /// Get edit capabilities for a member on a shared pet
  Future<LogEditCapability> getEditCapabilities(
    String sharedProfileId,
    String memberId,
  );

  /// Update the last-edited timestamp for a shared pet
  Future<void> touchSharedPet(String id);
}

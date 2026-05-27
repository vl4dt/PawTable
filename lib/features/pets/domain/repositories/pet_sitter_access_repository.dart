import '../../../../core/repository/base_repository.dart';
import '../entities/pet_sitter_access_entity.dart';

/// Repository interface for pet sitter access management
abstract class PetSitterAccessRepository extends BaseRepository {
  /// Get all active pet sitter access for a specific pet
  Future<List<PetSitterAccess>> getActiveAccess(String petId);

  /// Get all active pet sitter access for a group
  Future<List<PetSitterAccess>> getActiveAccessByGroup(String groupId);

  /// Get all pet sitter access (active, expired, revoked) for a group
  Future<List<PetSitterAccess>> getAllAccess(String groupId);

  /// Get a single access grant by ID
  Future<PetSitterAccess?> getAccess(String id);

  /// Create a new pet sitter access grant
  Future<PetSitterAccess> createAccess({
    required String petId,
    required String groupId,
    required String petSitterName,
    String? petSitterPhone,
    String? petSitterEmail,
    required String grantedBy,
    required String grantedByName,
    required SitterDuration duration,
  });

  /// Extend the expiry time for an existing access grant
  Future<void> extendAccess({
    required String accessId,
    required SitterDuration duration,
  });

  /// Revoke (cancel) an active access grant
  Future<void> revokeAccess(String id);

  /// Expire all access grants that have passed their expiry
  Future<int> expireExpiredAccess();

  /// Check if a pet has any active sitter access
  Future<bool> hasActiveSitterAccess(String petId);

  /// Get the count of active sitters for a pet
  Future<int> getActiveSitterCount(String petId);

  /// Delete an access grant (permanent removal)
  Future<void> deleteAccess(String id);
}

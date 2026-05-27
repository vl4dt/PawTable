import '../../../../core/storage/database_helper.dart';
import '../../domain/entities/shared_pet_profile_entity.dart';
import '../../domain/repositories/shared_pet_profile_repository.dart';

/// Shared pet profile repository implementation using SQLite
class SharedPetProfileRepositoryImpl implements SharedPetProfileRepository {
  final DatabaseHelper dbHelper;

  SharedPetProfileRepositoryImpl({required this.dbHelper});

  @override
  bool get isSyncing => false;

  @override
  String get syncStatus => '';

  @override
  Future<List<SharedPetProfile>> getSharedProfiles(String groupId) async {
    final rows = await dbHelper.getSharedProfilesByGroup(groupId);
    return rows.map(SharedPetProfile.fromDbRow).toList();
  }

  @override
  Future<SharedPetProfile?> getSharedProfile(String id) async {
    final row = await dbHelper.getSharedProfile(id);
    if (row == null) return null;
    return SharedPetProfile.fromDbRow(row);
  }

  @override
  Future<SharedPetProfile?> getByPetIdAndGroup(
    String petId,
    String groupId,
  ) async {
    final row =
        await dbHelper.getSharedProfileByPetAndGroup(petId, groupId);
    if (row == null) return null;
    return SharedPetProfile.fromDbRow(row);
  }

  @override
  Future<SharedPetProfile> sharePet({
    required String petId,
    required String groupId,
    required String sharedBy,
    required String sharedByName,
  }) async {
    // Check if already shared
    final exists = await isPetShared(petId, groupId);
    if (exists) {
      throw Exception('Pet is already shared with this group');
    }

    final profile = SharedPetProfile.createPlaceholder(
      petId: petId,
      groupId: groupId,
      sharedBy: sharedBy,
      sharedByName: sharedByName,
    );

    await dbHelper.insertSharedPetProfile(profile.toDbMap());
    return profile;
  }

  @override
  Future<void> unsharePet(String id) async {
    await dbHelper.deleteSharedPetProfile(id);
  }

  @override
  Future<void> updateSharedProfile(SharedPetProfile profile) async {
    await dbHelper.updateSharedPetProfile(profile.id, profile.toDbMap());
  }

  @override
  Future<bool> isPetShared(String petId, String groupId) async {
    final result =
        await dbHelper.getSharedPetProfileCount(petId, groupId);
    return result > 0;
  }

  @override
  Future<List<String>> getSharedGroupIds(String petId) async {
    return await dbHelper.getSharedGroupIds(petId);
  }

  @override
  Future<LogEditCapability> getEditCapabilities(
    String sharedProfileId,
    String memberId,
  ) async {
    // Default capability - would query family_members table in production
    return const LogEditCapability(
      canFeed: true,
      canWeight: true,
      canBehavior: true,
      canHealth: true,
      canView: true,
    );
  }

  @override
  Future<void> touchSharedPet(String id) async {
    final now = DateTime.now().toIso8601String();
    await dbHelper.touchSharedPetProfile(id, now);
  }
}

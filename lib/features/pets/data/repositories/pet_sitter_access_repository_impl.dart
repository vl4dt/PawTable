import '../../../../core/storage/database_helper.dart';
import '../../domain/entities/pet_sitter_access_entity.dart';
import '../../domain/repositories/pet_sitter_access_repository.dart';

/// Pet sitter access repository implementation using SQLite
class PetSitterAccessRepositoryImpl
    implements PetSitterAccessRepository {
  final DatabaseHelper dbHelper;

  PetSitterAccessRepositoryImpl({required this.dbHelper});

  @override
  bool get isSyncing => false;

  @override
  String get syncStatus => '';

  @override
  Future<List<PetSitterAccess>> getActiveAccess(
    String petId,
  ) async {
    final rows = await dbHelper.getActiveSitterAccess(petId);
    return rows.map(PetSitterAccess.fromDbRow).toList();
  }

  @override
  Future<List<PetSitterAccess>> getActiveAccessByGroup(
    String groupId,
  ) async {
    final rows = await dbHelper.getActiveSitterAccessByGroup(groupId);
    return rows.map(PetSitterAccess.fromDbRow).toList();
  }

  @override
  Future<List<PetSitterAccess>> getAllAccess(String groupId) async {
    final rows = await dbHelper.getAllSitterAccess(groupId);
    return rows.map(PetSitterAccess.fromDbRow).toList();
  }

  @override
  Future<PetSitterAccess?> getAccess(String id) async {
    final row = await dbHelper.getSitterAccess(id);
    if (row == null) return null;
    return PetSitterAccess.fromDbRow(row);
  }

  @override
  Future<PetSitterAccess> createAccess({
    required String petId,
    required String groupId,
    required String petSitterName,
    String? petSitterPhone,
    String? petSitterEmail,
    required String grantedBy,
    required String grantedByName,
    required SitterDuration duration,
  }) async {
    final now = DateTime.now();
    final expiresAt = duration.getExpiry(now);

    final access = PetSitterAccess(
      id: _generateId(),
      petId: petId,
      groupId: groupId,
      petSitterName: petSitterName,
      petSitterPhone: petSitterPhone,
      petSitterEmail: petSitterEmail,
      grantedBy: grantedBy,
      grantedByName: grantedByName,
      status: PetSitterAccessStatus.active,
      expiresAt: expiresAt,
      createdAt: now,
    );

    await dbHelper.insertPetSitterAccess(access.toDbMap());
    return access;
  }

  @override
  Future<void> extendAccess({
    required String accessId,
    required SitterDuration duration,
  }) async {
    final existing = await getAccess(accessId);
    if (existing == null) {
      throw Exception('Access grant not found');
    }

    final newExpiry = duration.getExpiry(existing.expiresAt);
    await dbHelper.updateSitterAccess(accessId, {
      'expiresAt': newExpiry.toIso8601String(),
      'status': PetSitterAccessStatus.active.name,
    });
  }

  @override
  Future<void> revokeAccess(String id) async {
    await dbHelper.updateSitterAccess(id, {
      'status': PetSitterAccessStatus.revoked.name,
    });
  }

  @override
  Future<int> expireExpiredAccess() async {
    return await dbHelper.expireExpiredAccess();
  }

  @override
  Future<bool> hasActiveSitterAccess(String petId) async {
    final count = await dbHelper.getActiveSitterCount(petId);
    return count > 0;
  }

  @override
  Future<int> getActiveSitterCount(String petId) async {
    return await dbHelper.getActiveSitterCount(petId);
  }

  @override
  Future<void> deleteAccess(String id) async {
    await dbHelper.deleteSitterAccess(id);
  }

  /// Generate a unique ID for access grants
  String _generateId() {
    return 'psa_${DateTime.now().millisecondsSinceEpoch}_${_randomString(8)}';
  }

  /// Generate a random string for ID uniqueness
  String _randomString(int length) {
    const chars =
        'abcdefghijklmnopqrstuvwxyz0123456789';
    final buffer = StringBuffer();
    final now = DateTime.now().millisecondsSinceEpoch;
    for (var i = 0; i < length; i++) {
      buffer.write(chars[now % chars.length]);
    }
    return buffer.toString();
  }
}

import '../../../../core/storage/database_helper.dart';
import '../../../../core/storage/storage_service.dart';
import '../models/pet_local_model.dart';

/// Local data source for pet operations
///
/// Handles Hive and SQLite operations for pets.
class PetLocalDataSource {
  final DatabaseHelper dbHelper;
  final StorageService storageService;

  PetLocalDataSource({
    required this.dbHelper,
    required this.storageService,
  });

  /// Save pet to Hive (fast) and SQLite (persistent)
  Future<void> savePet(PetLocalModel model) async {
    // Hive: store in pets box
    await storageService.petsBox.put(model.id, model.toJson());

    // SQLite: upsert
    await dbHelper.upsertPet(model.toJson());
  }

  /// Get all pets from Hive (primary cache)
  Future<List<PetLocalModel>> getAllPets() async {
    final keys = storageService.petsBox.keys.cast<String>().toList();
    return keys
        .map((key) => PetLocalModel.fromJson(storageService.petsBox.get(key)!))
        .toList();
  }

  /// Get single pet by ID
  Future<PetLocalModel?> getPet(String id) async {
    final data = storageService.petsBox.get(id);
    if (data == null) return null;
    return PetLocalModel.fromJson(data);
  }

  /// Delete pet from both stores
  Future<void> deletePet(String id) async {
    storageService.petsBox.delete(id);
    await dbHelper.deletePet(id);
  }

  /// Search pets by name
  Future<List<PetLocalModel>> searchPets(String query) async {
    final pets = await getAllPets();
    final lower = query.toLowerCase();
    return pets.where((p) => p.name.toLowerCase().contains(lower)).toList();
  }

  /// Delete all pets (for testing / reset)
  Future<void> deleteAllPets() async {
    final keys = storageService.petsBox.keys.cast<String>().toList();
    for (final key in keys) {
      await deletePet(key);
    }
  }
}

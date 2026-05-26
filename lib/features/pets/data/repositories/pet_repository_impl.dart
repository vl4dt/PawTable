import '../../domain/entities/pet_entity.dart';
import '../../domain/repositories/pet_repository.dart';
import '../data_sources/pet_local_data_source.dart';
import '../models/pet_local_model.dart';

/// Repository implementation for pet operations
///
/// Delegates to local data source for all operations.
/// Future: add sync with Firebase for family sharing.
class PetRepositoryImpl implements PetRepository {
  final PetLocalDataSource dataSource;

  PetRepositoryImpl({required this.dataSource});

  @override
  bool get isSyncing => false;

  @override
  String get syncStatus => '';

  PetEntity _toEntity(Map<String, dynamic> json) {
    return PetEntity.fromJson(json);
  }

  PetLocalModel _toLocal(PetEntity entity) {
    return PetLocalModel.fromEntity(entity);
  }

  @override
  Future<List<PetEntity>> getAll() async {
    final models = await dataSource.getAllPets();
    return models.map((m) => _toEntity(m.toJson())).toList();
  }

  @override
  Future<PetEntity?> getById(String id) async {
    final model = await dataSource.getPet(id);
    if (model == null) return null;
    return _toEntity(model.toJson());
  }

  @override
  Future<void> save(PetEntity item) async {
    final local = _toLocal(item);
    await dataSource.savePet(local);
  }

  @override
  Future<void> update(PetEntity item) async {
    final local = _toLocal(item);
    await dataSource.savePet(local);
  }

  @override
  Future<void> delete(String id) async {
    await dataSource.deletePet(id);
  }

  @override
  Future<List<PetEntity>> search(String query) async {
    final models = await dataSource.searchPets(query);
    return models.map((m) => _toEntity(m.toJson())).toList();
  }

  @override
  Future<bool> exceedsFreeLimit(int currentCount) async {
    // Free tier: 1 pet
    return currentCount >= 1;
  }

  @override
  Future<List<PetEntity>> getPetsWithReminders() async {
    // TODO: Join with vaccination/medication data
    return getAll();
  }

  @override
  Future<void> reorderPets(List<String> orderedIds) async {
    // Store order in Hive preferences
    // Not yet implemented
  }
}

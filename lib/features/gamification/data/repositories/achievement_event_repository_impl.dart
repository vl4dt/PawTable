import '../../../../core/storage/database_helper.dart';
import '../../../../core/repository/base_repository.dart';
import '../../domain/entities/achievement_entity.dart';
import '../../domain/repositories/achievement_event_repository.dart';
import '../models/achievement_local_model.dart';

/// Achievement event repository implementation
class AchievementEventRepositoryImpl implements AchievementEventRepository {
  final DatabaseHelper _dbHelper;

  AchievementEventRepositoryImpl({required DatabaseHelper dbHelper})
      : _dbHelper = dbHelper;

  @override
  bool get isSyncing => false;

  @override
  String get syncStatus => '';

  @override
  Future<List<AchievementEvent>> getEventsByPetId(String petId) async {
    final rows = await _dbHelper.getAchievementEventsByPet(petId);
    return rows
        .map((row) => AchievementEventLocalModel.fromDbRow(row).toEntity())
        .toList();
  }

  @override
  Future<List<AchievementEvent>> getEventsByType(
    String petId,
    AchievementType type,
  ) async {
    final rows = await _dbHelper.getAchievementEventsByType(
        petId, type.name);
    return rows
        .map((row) => AchievementEventLocalModel.fromDbRow(row).toEntity())
        .toList();
  }

  @override
  Future<void> saveEvent(AchievementEvent event) async {
    await _dbHelper.insertAchievementEvent(event.toDbMap());
  }

  @override
  Future<void> deleteByPetId(String petId) async {
    await _dbHelper.deleteAchievementEventsByPet(petId);
  }
}

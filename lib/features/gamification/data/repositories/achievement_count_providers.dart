import 'package:uuid/uuid.dart';
import '../../../../core/storage/database_helper.dart';
import '../../domain/services/achievement_unlock_service.dart';

/// UUID generator singleton for this file
final _uuid = const Uuid();

/// Implements FeedingCountProvider — counts feeding logs for a pet
class FeedingCountProviderImpl implements FeedingCountProvider {
  final DatabaseHelper _dbHelper;

  FeedingCountProviderImpl({required DatabaseHelper dbHelper})
      : _dbHelper = dbHelper;

  @override
  Future<int> getFeedingCount(String petId) async {
    final logs = await _dbHelper.getFeedingLogsByPet(petId);
    return logs.length;
  }
}

/// Implements HealthCountProvider — counts vaccination records for a pet
class HealthCountProviderImpl implements HealthCountProvider {
  final DatabaseHelper _dbHelper;

  HealthCountProviderImpl({required DatabaseHelper dbHelper})
      : _dbHelper = dbHelper;

  @override
  Future<int> getHealthRecordCount(String petId) async {
    final records = await _dbHelper.getVaccinationsByPet(petId);
    return records.length;
  }
}

/// Implements MedicationCountProvider — counts medication records for a pet
class MedicationCountProviderImpl implements MedicationCountProvider {
  final DatabaseHelper _dbHelper;

  MedicationCountProviderImpl({required DatabaseHelper dbHelper})
      : _dbHelper = dbHelper;

  @override
  Future<int> getMedicationCount(String petId) async {
    final records = await _dbHelper.getMedicationsByPet(petId);
    return records.length;
  }
}

/// Implements WeightCountProvider — counts weight logs for a pet
class WeightCountProviderImpl implements WeightCountProvider {
  final DatabaseHelper _dbHelper;

  WeightCountProviderImpl({required DatabaseHelper dbHelper})
      : _dbHelper = dbHelper;

  @override
  Future<int> getWeightLogCount(String petId) async {
    final logs = await _dbHelper.getWeightLogsByPet(petId);
    return logs.length;
  }
}

/// Implements BehaviorCountProvider — counts behavior logs for a pet
class BehaviorCountProviderImpl implements BehaviorCountProvider {
  final DatabaseHelper _dbHelper;

  BehaviorCountProviderImpl({required DatabaseHelper dbHelper})
      : _dbHelper = dbHelper;

  @override
  Future<int> getBehaviorLogCount(String petId) async {
    final logs = await _dbHelper.database.then((db) => db.query(
          'behavior_logs',
          where: 'petId = ?',
          whereArgs: [petId],
        ));
    return logs.length;
  }
}

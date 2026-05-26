import '../../../../core/repository/base_repository.dart';
import '../entities/health_log_entity.dart';

abstract class HealthRepository extends ListRepository<HealthLogEntity> {
  Future<List<HealthLogEntity>> getByPetId(String petId);
  Future<int> getWeeklyCount(String petId);
  Future<HealthLogEntity?> getMostRecent(String petId);
}

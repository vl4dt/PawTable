import '../../../../core/repository/base_repository.dart';
import '../entities/weight_log_entity.dart';

abstract class TrackingRepository extends ListRepository<WeightLogEntity> {
  Future<List<WeightLogEntity>> getByPetId(String petId);
  Future<double?> getLastWeight(String petId);
  Future<double?> getAverageWeight(String petId, int days);
  Future<WeightLogEntity?> getTodayLog(String petId);
}

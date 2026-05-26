import '../../../../core/repository/base_repository.dart';
import '../entities/behavior_entity.dart';

abstract class BehaviorRepository extends ListRepository<BehaviorLogEntity> {
  Future<List<BehaviorLogEntity>> getByPetId(String petId);
  Future<List<BehaviorLogEntity>> getByDateRange(
    String petId,
    DateTime from,
    DateTime to,
  );
  Future<BehaviorLogEntity?> getMostRecent(String petId);
}

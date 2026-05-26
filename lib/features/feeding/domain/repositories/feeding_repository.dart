import '../../../../core/repository/base_repository.dart';
import '../entities/feeding_entity.dart';

abstract class FeedingRepository extends ListRepository<FeedingEntity> {
  Future<List<FeedingEntity>> getByPetId(String petId);
  Future<double> getDailyTotal(String petId, DateTime day);
  Future<FeedingEntity?> getTodayFeeding(String petId);
}

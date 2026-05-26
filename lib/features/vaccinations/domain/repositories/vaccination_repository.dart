import '../../../../core/repository/base_repository.dart';
import '../entities/vaccination_entity.dart';

abstract class VaccinationRepository extends ListRepository<VaccinationEntity> {
  Future<List<VaccinationEntity>> getByPetId(String petId);
  Future<List<VaccinationEntity>> getUpcomingReminders();
  Future<VaccinationEntity?> getMostRecent(String petId, String name);
}

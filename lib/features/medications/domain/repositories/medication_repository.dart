import '../../../../core/repository/base_repository.dart';
import '../entities/medication_entity.dart';

abstract class MedicationRepository extends ListRepository<MedicationEntity> {
  Future<List<MedicationEntity>> getByPetId(String petId);
  Future<List<MedicationEntity>> getPending(String petId);
  Future<List<MedicationEntity>> getToday(String petId);
  Future<bool> markTaken(String medicationId, DateTime takenAt);
}

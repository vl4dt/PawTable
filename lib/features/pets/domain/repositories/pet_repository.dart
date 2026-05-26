import '../../../../core/repository/base_repository.dart';
import '../entities/pet_entity.dart';

/// Repository interface for pet operations
///
/// Domain layer depends on this. Data layer implements it.
abstract class PetRepository extends ListRepository<PetEntity> {
  /// Get pets owned by a specific user
  @override
  Future<List<PetEntity>> getAll();

  /// Check if pet count exceeds free tier limit
  Future<bool> exceedsFreeLimit(int currentCount);

  /// Get pets with their upcoming vaccination reminders
  Future<List<PetEntity>> getPetsWithReminders();

  /// Reorder pets (for drag-and-drop sorting)
  Future<void> reorderPets(List<String> orderedIds);
}

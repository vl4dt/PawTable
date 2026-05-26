import '../entities/pet_entity.dart';
import '../repositories/pet_repository.dart';

/// Use case: get all pets
class GetPetsUsecase {
  final PetRepository repository;

  GetPetsUsecase(this.repository);

  Future<List<PetEntity>> call() async {
    return repository.getAll();
  }
}

/// Use case: get a single pet by ID
class GetPetByIdUsecase {
  final PetRepository repository;

  GetPetByIdUsecase(this.repository);

  Future<PetEntity?> call(String id) async {
    return repository.getById(id);
  }
}

/// Use case: save a pet
class SavePetUsecase {
  final PetRepository repository;

  SavePetUsecase(this.repository);

  Future<void> call(PetEntity pet) async {
    return repository.save(pet);
  }
}

/// Use case: delete a pet
class DeletePetUsecase {
  final PetRepository repository;

  DeletePetUsecase(this.repository);

  Future<void> call(String id) async {
    return repository.delete(id);
  }
}

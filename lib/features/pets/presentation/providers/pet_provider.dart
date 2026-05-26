import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../pets/domain/entities/pet_entity.dart';
import '../../../pets/domain/repositories/pet_repository.dart';

/// Provider for PetRepository (injected from DI)
final petRepositoryProvider = Provider<PetRepository>((ref) {
  // TODO: wire up with Injectable / GetIt
  // For now, return a placeholder that will be overridden
  throw UnimplementedError('PetRepository not configured');
});

/// State for pet list operations
class PetListState {
  final List<PetEntity> pets;
  final bool isLoading;
  final String? error;
  final String? searchQuery;

  const PetListState({
    this.pets = const [],
    this.isLoading = false,
    this.error,
    this.searchQuery,
  });

  PetListState copyWith({
    List<PetEntity>? pets,
    bool? isLoading,
    String? error,
    String? searchQuery,
  }) {
    return PetListState(
      pets: pets ?? this.pets,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

/// AsyncNotifier for pet list
class PetListNotifier extends AsyncNotifier<List<PetEntity>> {
  late final PetRepository _repository;

  @override
  Future<List<PetEntity>> build() {
    _repository = ref.read(petRepositoryProvider);
    return Future.value(const []);
  }

  /// Refresh pets from repository
  Future<void> refresh() async {
    state = const AsyncLoading();
    try {
      final pets = await _repository.getAll();
      state = AsyncData(pets);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  /// Add a new pet
  Future<void> addPet(PetEntity pet) async {
    try {
      await _repository.save(pet);
      await refresh();
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  /// Update an existing pet
  Future<void> updatePet(PetEntity pet) async {
    try {
      await _repository.update(pet);
      await refresh();
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  /// Delete a pet by ID
  Future<void> deletePet(String id) async {
    try {
      await _repository.delete(id);
      await refresh();
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}

final petListProvider = AsyncNotifierProvider<PetListNotifier, List<PetEntity>>(
  PetListNotifier.new,
);

/// Provider to generate a unique pet ID
final petIdProvider = Provider<String>((ref) {
  return const Uuid().v4();
});

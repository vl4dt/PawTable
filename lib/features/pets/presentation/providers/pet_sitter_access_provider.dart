import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pawtable/di/app_module.dart';
import '../../domain/entities/pet_entity.dart';
import '../../domain/entities/pet_sitter_access_entity.dart';
import '../../domain/repositories/pet_sitter_access_repository.dart';

/// Provider for pet sitter access repository
final petSitterAccessRepositoryProvider =
    Provider<PetSitterAccessRepository>((ref) {
  return getIt<PetSitterAccessRepository>();
});

/// State for pet sitter access management
class PetSitterAccessState {
  final bool isLoading;
  final String? error;
  final List<PetSitterAccessSummary> activeAccess;
  final List<PetSitterAccess> allAccess;
  final String? currentPetId;
  final bool isCreating;
  final bool isRevoking;

  const PetSitterAccessState({
    this.isLoading = false,
    this.error,
    this.activeAccess = const [],
    this.allAccess = const [],
    this.currentPetId,
    this.isCreating = false,
    this.isRevoking = false,
  });

  PetSitterAccessState copyWith({
    bool? isLoading,
    String? error,
    List<PetSitterAccessSummary>? activeAccess,
    List<PetSitterAccess>? allAccess,
    String? currentPetId,
    bool? isCreating,
    bool? isRevoking,
  }) {
    return PetSitterAccessState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      activeAccess: activeAccess ?? this.activeAccess,
      allAccess: allAccess ?? this.allAccess,
      currentPetId: currentPetId ?? this.currentPetId,
      isCreating: isCreating ?? this.isCreating,
      isRevoking: isRevoking ?? this.isRevoking,
    );
  }

  /// Get active access for a specific pet
  bool hasActiveAccess(String petId) {
    return activeAccess.any((a) => a.pet.id == petId);
  }

  /// Get access count for a pet
  int getAccessCount(String petId) {
    return activeAccess.where((a) => a.pet.id == petId).length;
  }
}

/// Notifier for pet sitter access management
class PetSitterAccessNotifier
    extends StateNotifier<PetSitterAccessState> {
  final PetSitterAccessRepository _repository;

  PetSitterAccessNotifier(this._repository)
      : super(const PetSitterAccessState());

  /// Load active pet sitter access for a group
  Future<void> loadActiveAccess({
    required String groupId,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final accesses = await _repository.getActiveAccessByGroup(groupId);

      // We need pet data to build summaries - for now create placeholder pets
      final summaries = accesses.map((access) {
        final pet = PetEntity(
          id: access.petId,
          name: 'Pet',
          species: PetSpecies.other,
          breed: '',
          photoUri: null,
          birthDate: null,
          weight: null,
          notes: '',
          isNeutered: false,
          isMicrochipped: false,
          microchipId: null,
          createdAt: access.createdAt,
          updatedAt: access.createdAt,
        );

        return PetSitterAccessSummary(
          access: access,
          pet: pet,
        );
      }).toList();

      state = state.copyWith(
        activeAccess: summaries,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  /// Load all access (including expired/revoked) for a group
  Future<void> loadAllAccess({
    required String groupId,
  }) async {
    try {
      final accesses = await _repository.getAllAccess(groupId);
      state = state.copyWith(allAccess: accesses);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Create a new pet sitter access grant
  Future<bool> createAccess({
    required String petId,
    required String groupId,
    required String petSitterName,
    String? petSitterPhone,
    String? petSitterEmail,
    required String grantedBy,
    required String grantedByName,
    required SitterDuration duration,
  }) async {
    state = state.copyWith(isCreating: true, error: null);

    try {
      final access = await _repository.createAccess(
        petId: petId,
        groupId: groupId,
        petSitterName: petSitterName,
        petSitterPhone: petSitterPhone,
        petSitterEmail: petSitterEmail,
        grantedBy: grantedBy,
        grantedByName: grantedByName,
        duration: duration,
      );

      final pet = PetEntity(
        id: petId,
        name: 'Pet',
        species: PetSpecies.other,
        breed: '',
        photoUri: null,
        birthDate: null,
        weight: null,
        notes: '',
        isNeutered: false,
        isMicrochipped: false,
        microchipId: null,
        createdAt: access.createdAt,
        updatedAt: access.createdAt,
      );

      final summary = PetSitterAccessSummary(
        access: access,
        pet: pet,
      );

      state = state.copyWith(
        activeAccess: [...state.activeAccess, summary],
        isCreating: false,
      );
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString(), isCreating: false);
      return false;
    }
  }

  /// Revoke an active access grant
  Future<bool> revokeAccess(String accessId) async {
    state = state.copyWith(isRevoking: true, error: null);

    try {
      await _repository.revokeAccess(accessId);

      state = state.copyWith(
        activeAccess: state.activeAccess
            .where((a) => a.access.id != accessId)
            .toList(),
        isRevoking: false,
      );
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString(), isRevoking: false);
      return false;
    }
  }

  /// Extend an access grant
  Future<bool> extendAccess({
    required String accessId,
    required SitterDuration duration,
  }) async {
    try {
      await _repository.extendAccess(
        accessId: accessId,
        duration: duration,
      );
      // Reload to get updated state
      await loadActiveAccess(
        groupId: state.allAccess.isNotEmpty
            ? state.allAccess.first.groupId
            : '',
      );
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  /// Expire all expired access grants
  Future<void> expireExpired() async {
    try {
      await _repository.expireExpiredAccess();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
}

final petSitterAccessProvider =
    StateNotifierProvider<PetSitterAccessNotifier, PetSitterAccessState>(
        (ref) {
  final repo = ref.watch(petSitterAccessRepositoryProvider);
  return PetSitterAccessNotifier(repo);
});

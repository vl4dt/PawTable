import 'package:uuid/uuid.dart';

import '../../../../core/storage/storage_service.dart';
import '../../../pets/domain/entities/pet_entity.dart';
import '../models/onboarding_state.dart';

/// Service that manages onboarding business logic
class OnboardingService {
  final StorageService storageService;

  OnboardingService({
    required this.storageService,
  });

  /// Validate onboarding state
  bool validateState(OnboardingState state) {
    return state.isPetDataComplete && state.hasTrialConsent == true;
  }

  /// Create a PetEntity from onboarding state
  PetEntity createPetFromOnboarding(OnboardingState state) {
    final now = DateTime.now();
    return PetEntity(
      id: const Uuid().v4(),
      name: state.name!,
      species: _parseSpecies(state.species!),
      breed: state.breed!,
      createdAt: now,
      updatedAt: now,
    );
  }

  PetSpecies _parseSpecies(String species) {
    try {
      return PetSpecies.values
          .firstWhere((s) => s.name == species);
    } catch (_) {
      return PetSpecies.other;
    }
  }

  /// Complete onboarding by saving pet and marking onboarding done
  Future<String> completeOnboarding({
    required OnboardingState state,
    required String email,
  }) async {
    final pet = createPetFromOnboarding(state);
    await storageService.savePet(pet.id, pet.toJson());
    await storageService.setSettingBool('is_onboarding_complete', true);
    await storageService.setSettingString(
      'trial_start_date',
      state.trialStartDate?.toIso8601String() ?? '',
    );
    if (state.pushNotificationConsent != null) {
      await storageService.setSettingBool(
        'push_notification_consent',
        state.pushNotificationConsent!,
      );
    }
    return pet.id;
  }

  /// Skip onboarding with a demo pet
  Future<String> skipOnboarding() async {
    final demoPet = PetEntity(
      id: const Uuid().v4(),
      name: 'Demo Pup',
      species: PetSpecies.dog,
      breed: 'Golden Retriever',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    await storageService.savePet(demoPet.id, demoPet.toJson());
    await storageService.setSettingBool('is_onboarding_complete', true);
    return demoPet.id;
  }
}

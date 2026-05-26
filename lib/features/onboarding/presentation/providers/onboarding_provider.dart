import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../pets/domain/entities/pet_entity.dart';
import '../../domain/models/breed_database.dart';
import '../../domain/models/onboarding_state.dart';

final onboardingStateProvider = StateNotifierProvider<OnboardingStateNotifier, OnboardingState>(
  (ref) => OnboardingStateNotifier(),
);

class OnboardingStateNotifier extends StateNotifier<OnboardingState> {
  OnboardingStateNotifier() : super(const OnboardingState());

  void selectSpecies(PetSpecies species) {
    state = state.copyWith(species: species.name);
  }

  void selectBreed(String breed) {
    state = state.copyWith(breed: breed);
  }

  void setName(String name) {
    state = state.copyWith(name: name.trim());
  }

  void toggleNeutered(bool value) {
    state = state.copyWith(isNeutered: value);
  }

  void toggleMicrochipped(bool value) {
    state = state.copyWith(isMicrochipped: value);
  }

  void setTrialConsent(bool value) {
    state = state.copyWith(hasTrialConsent: value);
  }

  void setPushNotificationConsent(bool value) {
    state = state.copyWith(pushNotificationConsent: value);
  }

  bool canProceed() {
    return state.isPetDataComplete;
  }

  List<String> get availableBreeds {
    if (state.species == null) return [];
    try {
      final sp = PetSpecies.values.firstWhere((s) => s.name == state.species);
      return BreedDatabase.getBreedsForSpecies(sp);
    } catch (_) {
      return [];
    }
  }

  String get speciesEmoji {
    if (state.species == null) return '🐾';
    try {
      final sp = PetSpecies.values.firstWhere((s) => s.name == state.species);
      return BreedDatabase.speciesEmoji(sp);
    } catch (_) {
      return '🐾';
    }
  }
}

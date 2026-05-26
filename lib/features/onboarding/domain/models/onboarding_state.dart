/// Onboarding state data model
class OnboardingState {
  final int step;
  final String? species;
  final String? breed;
  final String? name;
  final bool? isNeutered;
  final bool? isMicrochipped;
  final bool? hasTrialConsent;
  final bool? pushNotificationConsent;
  final DateTime? trialStartDate;

  const OnboardingState({
    this.step = 1,
    this.species,
    this.breed,
    this.name,
    this.isNeutered,
    this.isMicrochipped,
    this.hasTrialConsent,
    this.pushNotificationConsent,
    this.trialStartDate,
  });

  bool get isPetDataComplete => species != null && breed != null && name != null && name!.isNotEmpty;

  OnboardingState copyWith({
    int? step,
    String? species,
    String? breed,
    String? name,
    bool? isNeutered,
    bool? isMicrochipped,
    bool? hasTrialConsent,
    bool? pushNotificationConsent,
    DateTime? trialStartDate,
  }) {
    return OnboardingState(
      step: step ?? this.step,
      species: species ?? this.species,
      breed: breed ?? this.breed,
      name: name ?? this.name,
      isNeutered: isNeutered ?? this.isNeutered,
      isMicrochipped: isMicrochipped ?? this.isMicrochipped,
      hasTrialConsent: hasTrialConsent ?? this.hasTrialConsent,
      pushNotificationConsent: pushNotificationConsent ?? this.pushNotificationConsent,
      trialStartDate: trialStartDate ?? this.trialStartDate,
    );
  }
}

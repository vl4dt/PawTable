import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/navigation/routes.dart';
import '../../../../di/providers.dart';
import '../../domain/models/onboarding_state.dart';
import '../providers/onboarding_provider.dart';
import 'welcome_screen.dart';
import 'pet_type_selection_screen.dart';
import 'breed_selection_screen.dart';
import 'pet_name_screen.dart';
import 'trial_activation_screen.dart';

class OnboardingView extends ConsumerWidget {
  const OnboardingView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(onboardingStateProvider);
    Widget screen;

    if (state.species == null) {
      screen = WelcomeScreen(
        onContinue: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => PetTypeSelectionScreen(onContinue: () {})),
          );
        },
        onSkip: () => _skipOnboarding(context, ref),
      );
    } else if (state.breed == null || state.breed!.isEmpty) {
      screen = BreedSelectionScreen(
        onBack: () => Navigator.of(context).pop(),
        onContinue: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => PetNameScreen(onBack: () => Navigator.of(context).pop(), onContinue: () {})),
          );
        },
      );
    } else if (state.name == null || state.name!.isEmpty) {
      screen = PetNameScreen(
        onBack: () => Navigator.of(context).pop(),
        onContinue: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => TrialActivationScreen(onBack: () => Navigator.of(context).pop())),
          );
        },
      );
    } else if (state.hasTrialConsent != true) {
      screen = TrialActivationScreen(onBack: () => Navigator.of(context).pop());
    } else {
      _completeOnboarding(context, ref, state);
      return const SizedBox.shrink();
    }

    return Scaffold(
      appBar: AppBar(title: const Text('PawTable'), centerTitle: true, elevation: 0),
      body: screen,
    );
  }

  Future<void> _completeOnboarding(BuildContext context, WidgetRef ref, OnboardingState state) async {
    final service = ref.read(onboardingServiceProvider);
    try {
      final petId = await service.completeOnboarding(state: state, email: '');
      if (!context.mounted) return;
      context.go('${AppRoutes.home}?firstPet=$petId');
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
    }
  }

  void _skipOnboarding(BuildContext context, WidgetRef ref) {
    final service = ref.read(onboardingServiceProvider);
    service.skipOnboarding().then((petId) {
      if (!context.mounted) return;
      context.go('${AppRoutes.home}?firstPet=$petId');
    });
  }
}

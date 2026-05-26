import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/colors.dart';
import '../../../../core/theme/design_tokens.dart';
import '../../../pets/domain/entities/pet_entity.dart';
import '../../domain/models/breed_database.dart';
import '../../domain/models/onboarding_state.dart';
import '../providers/onboarding_provider.dart';

class BreedSelectionScreen extends ConsumerWidget {
  final VoidCallback onBack;
  final VoidCallback onContinue;
  const BreedSelectionScreen({super.key, required this.onBack, required this.onContinue});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(onboardingStateProvider);
    final breeds = _getBreeds(state);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: PawTokens.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24),
              Text('What breed is your pet?', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold), textAlign: TextAlign.center),
              const SizedBox(height: 8),
              Text('Select the closest match to your pet\'s breed', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: PawTableColors.onSurfaceMuted), textAlign: TextAlign.center),
              const SizedBox(height: 32),
              Expanded(
                child: ListView.separated(
                  itemCount: breeds.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final breed = breeds[index];
                    final isSelected = state.breed == breed;
                    return _BreedTile(breed: breed, isSelected: isSelected, onTap: () {
                      ref.read(onboardingStateProvider.notifier).selectBreed(breed);
                      if (breed == 'Other' || breed == 'Mixed Breed') {
                        onContinue();
                      }
                    });
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<String> _getBreeds(OnboardingState state) {
    if (state.species == null) return [];
    try {
      final sp = PetSpecies.values.firstWhere((s) => s.name == state.species);
      return BreedDatabase.getBreedsForSpecies(sp);
    } catch (_) {
      return [];
    }
  }
}

class _BreedTile extends StatelessWidget {
  final String breed;
  final bool isSelected;
  final VoidCallback onTap;
  const _BreedTile({required this.breed, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: isSelected ? PawTableColors.primary.withOpacity(0.1) : Colors.transparent,
      borderRadius: BorderRadius.circular(PawTokens.radiusMd),
      child: InkWell(
        borderRadius: BorderRadius.circular(PawTokens.radiusMd),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          child: Row(
            children: [
              Icon(Icons.circle, size: 16, color: isSelected ? PawTableColors.primary : PawTableColors.surfaceVariant),
              const SizedBox(width: 12),
              Expanded(child: Text(breed, style: theme.textTheme.titleMedium?.copyWith(fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal))),
              if (isSelected) Icon(Icons.check, color: PawTableColors.primary, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}

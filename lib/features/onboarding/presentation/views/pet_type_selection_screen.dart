import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/colors.dart';
import '../../../../core/theme/design_tokens.dart';
import '../../../pets/domain/entities/pet_entity.dart';
import '../../domain/models/breed_database.dart';
import '../providers/onboarding_provider.dart';

class PetTypeSelectionScreen extends ConsumerWidget {
  final VoidCallback onContinue;
  const PetTypeSelectionScreen({super.key, required this.onContinue});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: PawTokens.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24),
              Text('What kind of pet do you have?', style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold), textAlign: TextAlign.center),
              const SizedBox(height: 8),
              Text('Select your pet type to get started', style: theme.textTheme.bodyMedium?.copyWith(color: PawTableColors.onSurfaceMuted), textAlign: TextAlign.center),
              const SizedBox(height: 32),
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  shrinkWrap: true,
                  childAspectRatio: 0.9,
                  physics: const NeverScrollableScrollPhysics(),
                  children: PetSpecies.values.where((s) => s != PetSpecies.other).map((species) {
                    return _SpeciesCard(species: species, onTap: () {
                      ref.read(onboardingStateProvider.notifier).selectSpecies(species);
                      onContinue();
                    });
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SpeciesCard extends StatelessWidget {
  final PetSpecies species;
  final VoidCallback onTap;
  const _SpeciesCard({required this.species, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(color: PawTableColors.primary.withOpacity(0.15), borderRadius: BorderRadius.circular(PawTokens.radiusLg), border: Border.all(color: PawTableColors.primary, width: 2), boxShadow: PawTokens.shadow2),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text(BreedDatabase.speciesEmoji(species), style: const TextStyle(fontSize: 48)),
          const SizedBox(height: 12),
          Text(species.label, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700, color: PawTableColors.primary)),
        ]),
      ),
    );
  }
}

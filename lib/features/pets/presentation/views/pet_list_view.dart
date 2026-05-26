import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/navigation/routes.dart';
import '../../../../core/theme/colors.dart';
import '../../../../shared/widgets/pet_avatar.dart';
import '../providers/pet_provider.dart';
import '../../../../core/billing/billing_service.dart' show isSubscribedProvider;

/// Main pet list view
///
/// Displays all pets with quick actions.
/// Shows "Add Pet" card at the top for first-time users.
/// Includes FAB to add pet and premium paywall for free tier limit.
class PetListView extends ConsumerWidget {
  const PetListView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final petsAsync = ref.watch(petListProvider);

    return petsAsync.when(
      data: (pets) {
        if (pets.isEmpty) {
          return const _EmptyState();
        }
        return Scaffold(
          body: _PetListContent(pets: pets),
          floatingActionButton: _AddPetFAB(ref),
        );
      },
      loading: () => const _LoadingState(),
      error: (e, _) => _ErrorState(message: e.toString()),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.pets,
                size: 80,
                color: PawTableColors.primary,
              ),
              const SizedBox(height: 24),
              Text(
                'No pets yet',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: PawTableColors.primary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Start by adding your first pet to begin tracking wellness, feeding, and health.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () => context.push(AppRoutes.addPet),
                icon: const Icon(Icons.add),
                label: const Text('Add Your Pet'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: PawTableColors.primary,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PetListContent extends StatelessWidget {
  final List<dynamic> pets;
  const _PetListContent({required this.pets});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: pets.length,
      itemBuilder: (context, index) {
        final pet = pets[index];
        return _PetCard(
          pet: pet,
          onTap: () {
            context.push(AppRoutes.petDetail, extra: pet.id);
          },
        );
      },
    );
  }
}

class _AddPetFAB extends ConsumerWidget {
  final WidgetRef ref;
  const _AddPetFAB(this.ref);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final petsAsync = ref.watch(petListProvider);
    final isSubscribed = ref.watch(isSubscribedProvider);

    return FloatingActionButton.extended(
      onPressed: () async {
        final petCount = petsAsync.when(
          data: (p) => p.length,
          loading: () => 0,
          error: (_, __) => 0,
        );

        final isPremium = isSubscribed.whenData((v) => v) ?? false;
        if (isPremium == false && petCount >= 1) {
          _showPremiumPaywall(context);
          return;
        }

        context.push(AppRoutes.addPet);
      },
      icon: const Icon(Icons.add),
      label: const Text('Add Pet'),
      backgroundColor: PawTableColors.primary,
    );
  }

  void _showPremiumPaywall(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.workspace_premium, color: PawTableColors.primary),
            const SizedBox(width: 8),
            const Text('Upgrade Required'),
          ],
        ),
        content: const Text(
          'You can only have 1 pet on the free plan. '
          'Upgrade to Premium for unlimited pets and unlock all features!',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Maybe Later'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(ctx).pop();
              context.push(AppRoutes.premium);
            },
            icon: const Icon(Icons.workspace_premium),
            label: const Text('Upgrade Now'),
            style: ElevatedButton.styleFrom(
              backgroundColor: PawTableColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

class _PetCard extends StatelessWidget {
  final dynamic pet;
  final VoidCallback onTap;
  const _PetCard({required this.pet, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        leading: PetAvatar(
          species: pet.species.name,
          size: 48,
          photoUri: pet.photoUri,
          backgroundColor: PawTableColors.primary,
        ),
        title: Text(
          pet.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          '${pet.species.label}${pet.breed.isNotEmpty ? ' • ${pet.breed}' : ''}${pet.birthDate != null ? ' • ${_getAgeDisplay(pet)}' : ''}',
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, size: 20),
              onPressed: () {
                context.push(AppRoutes.petEdit, extra: pet.id);
              },
              tooltip: 'Edit Pet',
            ),
            Icon(
              Icons.chevron_right,
              color: Theme.of(context).colorScheme.primary,
            ),
          ],
        ),
        onTap: onTap,
      ),
    );
  }

  String _getAgeDisplay(dynamic pet) {
    try {
      final age = pet.ageInYears;
      final years = age.floor();
      final months = ((age - years) * 12).toInt();
      if (years > 0 && months > 0) return '$years yr $months mo';
      if (years > 0) return '$years yr';
      return '$months mo';
    } catch (_) {
      return '';
    }
  }
}

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  const _ErrorState({required this.message});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text('Error: $message', textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

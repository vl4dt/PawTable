import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/navigation/routes.dart';
import '../../../../core/theme/colors.dart';
import '../../../pets/domain/entities/pet_entity.dart';
import '../../../pets/presentation/providers/pet_provider.dart';
import 'weight_history_view.dart';

/// Tracking view — shows weight history for the selected pet
class TrackingView extends ConsumerWidget {
  final String petId;
  const TrackingView({super.key, required this.petId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final petsAsync = ref.watch(petListProvider);

    return petsAsync.when(
      data: (pets) {
        final pet = pets.firstWhere(
          (p) => p.id == petId,
          orElse: () => PetEntity(
            id: '',
            name: '',
            species: PetSpecies.dog,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        );

        if (pet.id.isEmpty) {
          return Scaffold(
            appBar: AppBar(title: const Text('Tracking')),
            body: const Center(child: Text('Pet not found.')),
          );
        }

        return WeightHistoryView(
          petId: petId,
          petName: pet.name,
        );
      },
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(title: const Text('Tracking')),
        body: Center(child: Text('Error: $e')),
      ),
    );
  }
}

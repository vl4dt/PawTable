import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/pet_provider.dart';

/// Main pet list view
///
/// Displays all pets with quick actions.
/// Shows "Add Pet" card at the top for first-time users.
class PetListView extends ConsumerWidget {
  const PetListView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final petsAsync = ref.watch(petListProvider);

    return petsAsync.when(
      data: (pets) {
        if (pets.isEmpty) {
          return _emptyState(ref);
        }
        return _PetListContent(pets: pets);
      },
      loading: () => const _LoadingState(),
      error: (e, _) => _ErrorState(message: e.toString()),
    );
  }
}

Widget _emptyState(WidgetRef ref) {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.pets, size: 64, color: Colors.grey),
        const SizedBox(height: 16),
        Text(
          'Add your first pet',
          style: Theme.of(ref.context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 8),
        Text(
          'Start tracking feeding, health, and more',
          style: Theme.of(ref.context).textTheme.bodyMedium?.copyWith(
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: () {
            // TODO: Navigate to add pet screen
          },
          child: const Text('Add Pet'),
        ),
      ],
    ),
  );
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
        return _PetCard(pet: pet);
      },
    );
  }
}

class _PetCard extends StatelessWidget {
  final dynamic pet;
  const _PetCard({required this.pet});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primary,
          child: const Icon(Icons.pets, color: Colors.white),
        ),
        title: Text(pet.name),
        subtitle: Text('${pet.species.label} • ${pet.breed.isEmpty ? 'Unknown' : pet.breed}'),
        trailing: Icon(
          Icons.chevron_right,
          color: Theme.of(context).colorScheme.primary,
        ),
        onTap: () {
          // TODO: Navigate to pet detail
        },
      ),
    );
  }
}

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  const _ErrorState({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 16),
          Text('Error: $message', textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

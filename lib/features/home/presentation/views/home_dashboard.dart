import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/navigation/routes.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/utils/date_utils.dart' as app_date;
import '../../../../shared/widgets/pet_avatar.dart';
import '../../../../features/pets/domain/entities/pet_entity.dart';
import '../../../../features/pets/presentation/providers/pet_provider.dart';
import '../widgets/home_pet_card.dart';
import '../widgets/health_at_glance_card.dart';
import '../widgets/quick_log_row.dart';
import '../widgets/recent_activity_list.dart';

/// Home dashboard — main screen after onboarding
///
/// Displays:
/// - Welcome header with current date
/// - Quick-log button row (feeding, medication, weight, health)
/// - Pet cards (if multiple pets, allows switching)
/// - Health at a glance (upcoming vaccinations, medications due)
/// - Recent activity feed
class HomeDashboard extends ConsumerWidget {
  const HomeDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final petsAsync = ref.watch(petListProvider);
    final now = DateTime.now();

    return petsAsync.when(
      data: (pets) {
        if (pets.isEmpty) {
          return const _EmptyDashboard();
        }

        return NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              // Header
              SliverToBoxAdapter(
                child: _buildHeader(context, now),
              ),
              // Quick log row
              SliverToBoxAdapter(
                child: _buildQuickLogRow(context, ref),
              ),
              // Pet selector (if multiple pets)
              if (pets.length > 1)
                SliverToBoxAdapter(
                  child: _buildPetSelector(context, ref, pets),
                ),
            ];
          },
          body: pets.length == 1
              ? _SinglePetBody(pet: pets.first)
              : _MultiPetBody(pets: pets),
        );
      },
      loading: () => const _LoadingDashboard(),
      error: (e, _) => _ErrorDashboard(message: e.toString()),
    );
  }

  Widget _buildHeader(BuildContext context, DateTime now) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Good ${_getGreeting(now)}',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: PawTableColors.primary,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            app_date.DateUtils.formatDate(now),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
        ],
      ),
    );
  }

  String _getGreeting(DateTime now) {
    final hour = now.hour;
    if (hour < 12) return 'Morning';
    if (hour < 17) return 'Afternoon';
    if (hour < 21) return 'Evening';
    return 'Night';
  }

  Widget _buildQuickLogRow(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: QuickLogRow(
        buttons: [
          QuickLogButton(
            icon: Icons.restaurant,
            label: 'Feed',
            color: PawTableColors.primary,
            onTap: () {
              final pets = ref.read(petListProvider);
              pets.when(
                data: (pets) {
                  if (pets.isNotEmpty) {
                    context.push(AppRoutes.feeding, extra: pets.first.id);
                  }
                },
                loading: () {},
                error: (_, __) {},
              );
            },
          ),
          QuickLogButton(
            icon: Icons.medication,
            label: 'Meds',
            color: PawTableColors.info,
            onTap: () {
              final pets = ref.read(petListProvider);
              pets.when(
                data: (pets) {
                  if (pets.isNotEmpty) {
                    context.push(AppRoutes.medications, extra: pets.first.id);
                  }
                },
                loading: () {},
                error: (_, __) {},
              );
            },
          ),
          QuickLogButton(
            icon: Icons.trending_up,
            label: 'Weight',
            color: PawTableColors.success,
            onTap: () {
              final pets = ref.read(petListProvider);
              pets.when(
                data: (pets) {
                  if (pets.isNotEmpty) {
                    context.push(AppRoutes.tracking, extra: pets.first.id);
                  }
                },
                loading: () {},
                error: (_, __) {},
              );
            },
          ),
          QuickLogButton(
            icon: Icons.favorite,
            label: 'Health',
            color: PawTableColors.error,
            onTap: () {
              final pets = ref.read(petListProvider);
              pets.when(
                data: (pets) {
                  if (pets.isNotEmpty) {
                    context.push(AppRoutes.health, extra: pets.first.id);
                  }
                },
                loading: () {},
                error: (_, __) {},
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPetSelector(
    BuildContext context,
    WidgetRef ref,
    List<PetEntity> pets,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'My Pets',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 60,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: pets.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final pet = pets[index];
                return _PetChip(
                  pet: pet,
                  isActive: index == 0,
                  onTap: () {
                    // Scroll to this pet's section
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Header chip for pet selector
class _PetChip extends StatelessWidget {
  final PetEntity pet;
  final bool isActive;
  final VoidCallback onTap;

  const _PetChip({
    required this.pet,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? PawTableColors.primary : Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            PetAvatar(
              species: pet.species.name,
              size: 24,
              backgroundColor: isActive
                  ? PawTableColors.primary
                  : Theme.of(context).colorScheme.surface,
            ),
            const SizedBox(width: 8),
            Text(
              pet.name,
              style: TextStyle(
                color: isActive ? Colors.white : Colors.black87,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Dashboard when no pets exist yet
class _EmptyDashboard extends StatelessWidget {
  const _EmptyDashboard();

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
                'Welcome to PawTable',
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'Start by adding your first pet to begin tracking wellness, feeding, and health.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.grey[600],
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () {
                  // Navigate to pet creation
                  context.push(AppRoutes.pets);
                },
                icon: const Icon(Icons.add),
                label: const Text('Add Your Pet'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Loading state for dashboard
class _LoadingDashboard extends StatelessWidget {
  const _LoadingDashboard();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}

/// Error state for dashboard
class _ErrorDashboard extends StatelessWidget {
  final String message;
  const _ErrorDashboard({required this.message});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Something went wrong',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => ScaffoldMessenger.of(context).clearSnackBars(),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Dashboard body when single pet exists
class _SinglePetBody extends StatelessWidget {
  final PetEntity pet;
  const _SinglePetBody({required this.pet});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        // Pet info card
        SliverToBoxAdapter(
          child: HomePetCard(
            pet: pet,
            onTap: () {
              context.push(AppRoutes.petDetail, extra: pet.id);
            },
          ),
        ),
        // Health at a glance
        SliverToBoxAdapter(
          child: HealthAtGlanceCard(
            petId: pet.id,
          ),
        ),
        // Recent activity
        const SliverToBoxAdapter(
          child: RecentActivityList(),
        ),
        // Bottom padding
        const SliverToBoxAdapter(
          child: SizedBox(height: 80),
        ),
      ],
    );
  }
}

/// Dashboard body when multiple pets exist
class _MultiPetBody extends StatelessWidget {
  final List<PetEntity> pets;
  const _MultiPetBody({required this.pets});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        // Pet cards for each pet
        ...pets.map(
          (pet) => SliverToBoxAdapter(
            child: Column(
              children: [
                HomePetCard(
                  pet: pet,
                  onTap: () {
                    context.push(AppRoutes.petDetail, extra: pet.id);
                  },
                ),
                const SizedBox(height: 16),
                HealthAtGlanceCard(
                  petId: pet.id,
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
        // Recent activity (aggregated)
        const SliverToBoxAdapter(
          child: RecentActivityList(),
        ),
        const SliverToBoxAdapter(
          child: SizedBox(height: 80),
        ),
      ],
    );
  }
}

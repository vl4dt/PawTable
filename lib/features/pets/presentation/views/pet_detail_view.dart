import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/navigation/routes.dart';
import '../../../../core/theme/colors.dart';
import '../../../../shared/widgets/pet_avatar.dart';
import '../../domain/entities/pet_entity.dart';
import '../../presentation/providers/pet_provider.dart';

/// Pet detail view — shows pet info, quick stats, and quick-action buttons
///
/// Sections:
/// - Header: photo, name, species, breed, age, life stage
/// - Quick stats: weight, age, life stage
/// - Quick actions: feed, vaccinate, medication, weight, photos
/// - Pet info: neutered, microchip, notes
/// - Related logs: feeding, health, vaccinations, medications, tracking
class PetDetailView extends ConsumerWidget {
  final String petId;
  const PetDetailView({super.key, required this.petId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final petsAsync = ref.watch(petListProvider);

    return petsAsync.when(
      data: (pets) {
        final pet = pets.firstWhere(
          (p) => p.id == petId,
          orElse: () => _emptyPet,
        );

        if (pet.id.isEmpty) {
          return Scaffold(
            appBar: AppBar(title: const Text('Pet Not Found')),
            body: const Center(child: Text('Pet not found.')),
          );
        }

        return Scaffold(
          body: CustomScrollView(
            slivers: [
              // SliverAppBar with pet photo
              SliverAppBar(
                expandedHeight: 220,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    pet.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          PawTableColors.primary,
                          PawTableColors.primary.withValues(alpha: 0.7),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Stack(
                      children: [
                        Center(
                          child: PetAvatar(
                            species: pet.species.name,
                            size: 100,
                            photoUri: pet.photoUri,
                            backgroundColor: Colors.transparent,
                          ),
                        ),
                        Positioned(
                          bottom: 16,
                          right: 16,
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.9),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Text(
                                  pet.lifeStage.label,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: PawTableColors.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () {
                      context.push(AppRoutes.petEdit, extra: pet.id);
                    },
                    tooltip: 'Edit Pet',
                  ),
                  IconButton(
                    icon: const Icon(Icons.photo_library),
                    onPressed: () {
                      context.push(
                        '${AppRoutes.petPhotos}?name=${pet.name}',
                        extra: pet.id,
                      );
                    },
                    tooltip: 'Photos',
                  ),
                ],
              ),
              // Quick stats
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: _buildStatsSection(context, pet),
                ),
              ),
              // Quick actions
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _buildQuickActions(context),
                ),
              ),
              // Pet info
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _buildPetInfo(context, pet),
                ),
              ),
              // Related logs section header
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Text(
                    'Health & Activity',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              // Related logs quick links
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _buildRelatedLogs(context, pet.id),
                ),
              ),
              const SliverToBoxAdapter(
                child: SizedBox(height: 80),
              ),
            ],
          ),
        );
      },
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        body: Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _buildStatsSection(BuildContext context, PetEntity pet) {
    final ageStr = _formatAge(pet);
    return Row(
      children: [
        Expanded(
          child: _buildStatChip(
            context,
            icon: Icons.calendar_today,
            label: 'Age',
            value: ageStr,
            color: PawTableColors.primary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatChip(
            context,
            icon: Icons.monitor_weight,
            label: 'Weight',
            value: pet.weight != null ? '${pet.weight!.toStringAsFixed(1)} kg' : '—',
            color: PawTableColors.success,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatChip(
            context,
            icon: Icons.celebration,
            label: 'Life Stage',
            value: pet.lifeStage.label,
            color: PawTableColors.warning,
          ),
        ),
      ],
    );
  }

  Widget _buildStatChip(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Column(
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(fontSize: 11, color: Colors.grey[600]),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    final actions = [
      {'icon': Icons.restaurant, 'label': 'Feed'},
      {'icon': Icons.medical_services, 'label': 'Vaccinate'},
      {'icon': Icons.medication, 'label': 'Meds'},
      {'icon': Icons.monitor_weight, 'label': 'Weight'},
      {'icon': Icons.favorite, 'label': 'Health'},
    ];

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 5,
      childAspectRatio: 0.75,
      children: actions.map((a) {
        return _QuickActionButton(
          icon: a['icon'] as IconData,
          label: a['label'] as String,
          onTap: () {},
        );
      }).toList(),
    );
  }

  Widget _buildPetInfo(BuildContext context, PetEntity pet) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pet Information',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              context,
              icon: Icons.category,
              label: 'Species',
              value: pet.species.label,
            ),
            if (pet.breed.isNotEmpty)
              _buildInfoRow(
                context,
                icon: Icons.pets,
                label: 'Breed',
                value: pet.breed,
              ),
            if (pet.birthDate != null)
              _buildInfoRow(
                context,
                icon: Icons.cake,
                label: 'Birth Date',
                value: DateFormat('MMM dd, yyyy').format(pet.birthDate!),
              ),
            if (pet.isNeutered)
              _buildInfoRow(
                context,
                icon: Icons.pets,
                label: 'Status',
                value: 'Neutered/Spayed',
              ),
            if (pet.isMicrochipped)
              _buildInfoRow(
                context,
                icon: Icons.qr_code_2,
                label: 'Microchip',
                value: pet.microchipId ?? '—',
              ),
            if (pet.notes != null && pet.notes!.isNotEmpty)
              _buildInfoRow(
                context,
                icon: Icons.note,
                label: 'Notes',
                value: pet.notes!,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: PawTableColors.primary),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildRelatedLogs(BuildContext context, String petId) {
    final items = [
      {
        'icon': Icons.restaurant,
        'label': 'Feeding',
        'color': PawTableColors.primary,
        'route': AppRoutes.feeding,
        'extra': petId,
      },
      {
        'icon': Icons.medical_services,
        'label': 'Vaccinations',
        'color': PawTableColors.info,
        'route': AppRoutes.vaccinations,
        'extra': petId,
      },
      {
        'icon': Icons.medication,
        'label': 'Medications',
        'color': PawTableColors.warning,
        'route': AppRoutes.medications,
        'extra': petId,
      },
      {
        'icon': Icons.trending_up,
        'label': 'Weight History',
        'color': PawTableColors.success,
        'route': AppRoutes.tracking,
        'extra': petId,
      },
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quick Access',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              childAspectRatio: 2.5,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              children: items.map((item) {
                return InkWell(
                  onTap: () {
                    context.push(item['route'] as String, extra: item['extra'] as String);
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    decoration: BoxDecoration(
                      color: (item['color'] as Color).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: Icon(
                            item['icon'] as IconData,
                            color: item['color'] as Color,
                          ),
                        ),
                        Expanded(
                          child: Center(
                            child: Text(
                              item['label'] as String,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: Icon(
                            Icons.chevron_right,
                            size: 18,
                            color: Colors.grey[400],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  String _formatAge(PetEntity pet) {
    try {
      final age = pet.ageInYears;
      final years = age.floor();
      final months = ((age - years) * 12).toInt();
      if (years > 0 && months > 0) return '$years yr $months mo';
      if (years > 0) return '$years yr';
      return '$months mo';
    } catch (_) {
      return '—';
    }
  }
}

PetEntity get _emptyPet => PetEntity(
  id: '',
  name: '',
  species: PetSpecies.dog,
  createdAt: DateTime.now(),
  updatedAt: DateTime.now(),
);

typedef QuickActionCallback = void Function();

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final QuickActionCallback onTap;
  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

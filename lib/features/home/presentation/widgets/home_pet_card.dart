import 'package:flutter/material.dart';
import '../../../../core/theme/colors.dart';
import '../../../../shared/widgets/pet_avatar.dart';
import '../../../../features/pets/domain/entities/pet_entity.dart';

/// Pet card displayed on the home dashboard
///
/// Shows pet avatar, name, age, life stage, and quick actions.
class HomePetCard extends StatelessWidget {
  final PetEntity pet;
  final VoidCallback onTap;
  const HomePetCard({
    super.key,
    required this.pet,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Pet avatar
              PetAvatar(
                species: pet.species.name,
                size: 64,
                backgroundColor: PawTableColors.primary,
              ),
              const SizedBox(width: 16),
              // Pet info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pet.name,
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${pet.species.label} • ${pet.breed.isEmpty ? 'Mixed' : pet.breed}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[700],
                          ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        _InfoChip(
                          icon: Icons.cake,
                          label: 'Age: ${_formatAge(pet.ageInYears)}',
                        ),
                        const SizedBox(width: 8),
                        _InfoChip(
                          icon: Icons.tag,
                          label: pet.lifeStage.label,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Weight badge
              if (pet.weight != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${pet.weight!.toStringAsFixed(1)} kg',
                      style: Theme.of(context)
                          .textTheme
                          .titleSmall
                          ?.copyWith(
                            color: PawTableColors.primary,
                          ),
                    ),
                    Text(
                      'weight',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatAge(double years) {
    if (years < 1) {
      final months = (years * 12).toInt();
      return '$months mo';
    }
    if (years < 2) return '<1 yr';
    return '${years.toStringAsFixed(0)} yr';
  }
}

/// Small info chip for displaying metadata
class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: PawTableColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: PawTableColors.primary),
          const SizedBox(width: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: PawTableColors.primary,
                  fontWeight: FontWeight.w500,
                ),
          ),
        ],
      ),
    );
  }
}

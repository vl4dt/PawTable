import 'package:flutter/material.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/navigation/routes.dart';
import 'package:go_router/go_router.dart';

/// Health at a glance card
///
/// Shows upcoming tasks and health summary for a pet.
/// Note: Currently uses placeholder data — to be connected to
/// vaccination/medication providers when they are implemented.
class HealthAtGlanceCard extends StatelessWidget {
  final String petId;
  const HealthAtGlanceCard({
    super.key,
    required this.petId,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(
                  Icons.favorite,
                  color: PawTableColors.error,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Health at a Glance',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.chevron_right, size: 20),
                  onPressed: () {
                    context.push(AppRoutes.health, extra: petId);
                  },
                ),
              ],
            ),
            const Divider(height: 24),
            // Placeholder content — will be replaced with real data
            const _PlaceholderHealthData(),
          ],
        ),
      ),
    );
  }
}

/// Placeholder health data widget
class _PlaceholderHealthData extends StatelessWidget {
  const _PlaceholderHealthData();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              Icon(Icons.shield, size: 16, color: PawTableColors.primary),
              const SizedBox(width: 8),
              Text(
                'Upcoming Tasks',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: PawTableColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              Icon(Icons.schedule, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'No upcoming vaccinations',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ],
          ),
        ),
        const Padding(
          padding: EdgeInsets.only(top: 8),
          child: Center(
            child: Text(
              'All caught up — great job!',
              style: TextStyle(color: Colors.grey),
            ),
          ),
        ),
      ],
    );
  }
}

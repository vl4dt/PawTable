import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Pet detail view — shows pet info, quick stats, and quick-action buttons
///
/// Sections:
/// - Header: photo, name, species, breed, age
/// - Quick stats: weight, last feeding, next vaccination
/// - Quick actions: feed, vaccinate, medication, weight, notes
/// - Tabs: Feeding history | Health logs | Vaccinations | Settings
class PetDetailView extends ConsumerWidget {
  final String petId;
  const PetDetailView({super.key, required this.petId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // TODO: fetch pet data from provider
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // SliverAppBar with pet photo
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text('Pet Name'), // TODO: dynamic
              background: Container(
                color: Theme.of(context).colorScheme.primary,
                child: const Center(
                  child: Icon(Icons.pets, size: 80, color: Colors.white),
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  // TODO: open edit pet
                },
              ),
            ],
          ),
          // Quick stats section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStatsSection(context),
                  const SizedBox(height: 16),
                  _buildQuickActions(context),
                  const SizedBox(height: 16),
                  // Tab bar for detailed sections
                  _buildTabSection(context),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection(BuildContext context) {
    return Row(
      children: [
        _buildStatChip(context, '🍖 Last Feed', '2h ago'),
        _buildStatChip(context, '💉 Next Vacc', '30 days'),
        _buildStatChip(context, '⚖️ Weight', '5.2 kg'),
      ],
    );
  }

  Widget _buildStatChip(
    BuildContext context,
    String label,
    String value,
  ) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          child: Column(
            children: [
              Text(label, style: const TextStyle(fontSize: 12)),
              const SizedBox(height: 4),
              Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            ],
          ),
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
    ];

    return Row(
      children: actions.map((a) {
        return Expanded(
          child: _QuickActionButton(
            icon: a['icon'] as IconData,
            label: a['label'] as String,
            onTap: () {
              // TODO: quick log actions
            },
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTabSection(BuildContext context) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Pet Activity',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          const SizedBox(height: 16),
          Text('Feeding logs, health events, and vaccination history will appear here.', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey)),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

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

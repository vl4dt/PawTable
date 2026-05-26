import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/theme/colors.dart';
import '../../domain/entities/behavior_entity.dart';
import '../providers/behavior_provider.dart';

/// Behavior logging view
///
/// Allows logging mood and activity level.
/// Shows mood history, weekly mood distribution, and wellness score trend.
class BehaviorView extends ConsumerWidget {
  final String petId;
  const BehaviorView({super.key, required this.petId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(behaviorListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Behavior & Wellness'),
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.error != null
              ? _buildError(state.error!)
              : _buildContent(
                  petId: petId,
                  state: state,
                  context: context,
                  ref: ref,
                ),
      floatingActionButton: _LogBehaviorFAB(petId: petId),
    );
  }
}

class _LogBehaviorFAB extends ConsumerWidget {
  final String petId;
  const _LogBehaviorFAB({required this.petId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FloatingActionButton.extended(
      onPressed: () => _showLogDialog(context, petId, ref),
      icon: const Icon(Icons.add),
      label: const Text('Log Behavior'),
      backgroundColor: PawTableColors.primary,
    );
  }
}

void _showLogDialog(BuildContext context, String petId, WidgetRef ref) {
  Mood selectedMood = Mood.happy;
  ActivityLevel selectedActivity = ActivityLevel.moderate;
  final notesController = TextEditingController();

  showDialog(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (buildCtx, setState) => AlertDialog(
        title: const Text('Log Behavior'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('How is your pet feeling?',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: Mood.values.map((mood) {
                  final isSelected = selectedMood == mood;
                  return Chip(
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(mood.icon, size: 16, color: mood.color),
                        const SizedBox(width: 4),
                        Text(mood.label),
                      ],
                    ),
                    backgroundColor: isSelected
                        ? mood.color.withValues(alpha: 0.15)
                        : null,
                    side: isSelected
                        ? BorderSide(color: mood.color, width: 2)
                        : null,
                    onDeleted: () => setState(() => selectedMood = mood),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              const Text('Activity Level',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              SliderTheme(
                data: SliderThemeData(
                  activeTrackColor: PawTableColors.primary,
                  inactiveTrackColor: PawTableColors.primary.withValues(alpha: 0.3),
                  thumbColor: PawTableColors.primary,
                  overlayColor: PawTableColors.primary.withValues(alpha: 0.2),
                  trackHeight: 4,
                ),
                child: Slider(
                  value: selectedActivity.score.toDouble(),
                  min: 0,
                  max: 4,
                  divisions: 4,
                  label: selectedActivity.label,
                  onChanged: (v) {
                    setState(() {
                      selectedActivity = ActivityLevel.values[v.toInt()];
                    });
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    ActivityLevel.sedentary.label,
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                  Text(
                    selectedActivity.label,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    ActivityLevel.extreme.label,
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: notesController,
                decoration: const InputDecoration(
                  labelText: 'Notes (optional)',
                  prefixIcon: Icon(Icons.note),
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final log = BehaviorLogEntity(
                id: const Uuid().v7(),
                petId: petId,
                mood: selectedMood,
                activityLevel: selectedActivity,
                notes: notesController.text.isEmpty
                    ? null
                    : notesController.text,
                loggedAt: DateTime.now(),
                createdAt: DateTime.now(),
              );

              await ref
                  .read(behaviorListProvider.notifier)
                  .addLog(log);

              if (context.mounted) {
                Navigator.of(ctx).pop();
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    ),
  );
}

Widget _buildError(String error) {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.error_outline, size: 48, color: Colors.red),
        const SizedBox(height: 16),
        Text('Error: $error', textAlign: TextAlign.center),
      ],
    ),
  );
}

Widget _buildContent({
  required String petId,
  required BehaviorListState state,
  required BuildContext context,
  required WidgetRef ref,
}) {
  final todayMood = ref.read(behaviorListProvider.notifier).getTodayMood();
  final distribution = ref.read(behaviorListProvider.notifier).getWeeklyMoodDistribution();
  final avgScore = ref.read(behaviorListProvider.notifier).getAverageWellnessScore();

  return Column(
    children: [
      // Today's status card
      if (todayMood != null)
        Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [todayMood.color, todayMood.color.withValues(alpha: 0.7)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: todayMood.color.withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(todayMood.icon, color: Colors.white, size: 36),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Today\'s Mood',
                      style: const TextStyle(
                          color: Colors.white70, fontSize: 13),
                    ),
                    Text(
                      todayMood.label,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: Colors.white70),
            ],
          ),
        ),

      // Wellness score
      Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: PawTableColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _WellnessIndicator('Wellness', '${avgScore.toStringAsFixed(0)}%',
                Icons.favorite, avgScore >= 70 ? PawTableColors.successDark : avgScore >= 50 ? PawTableColors.warning : PawTableColors.error),
            _WellnessIndicator(
                'This Week', '${state.logs.length}', Icons.calendar_today, PawTableColors.primary),
          ],
        ),
      ),

      // Mood distribution
      if (distribution.isNotEmpty) ...[
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Icon(Icons.bar_chart, size: 18, color: Colors.grey[700]),
              const SizedBox(width: 8),
              Text(
                'Weekly Mood Distribution',
                style:
                    TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 60,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: distribution.entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      width: 32,
                      height: (entry.value * 12).toDouble().clamp(16.0, 44.0),
                      decoration: BoxDecoration(
                        color: entry.key.color,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Icon(entry.key.icon, size: 16),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 8),
      ],

      // Behavior history
      Expanded(
        child: state.logs.isEmpty
            ? const _EmptyBehaviorState()
            : ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: state.logs.length,
                itemBuilder: (context, index) {
                  final log = state.logs[index];
                  return _BehaviorHistoryCard(
                    log: log,
                    onDelete: () => ref
                        .read(behaviorListProvider.notifier)
                        .deleteLog(log.id),
                  );
                },
              ),
      ),
    ],
  );
}

class _WellnessIndicator extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _WellnessIndicator(
    this.label,
    this.value,
    this.icon,
    this.color,
  );

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 11, color: Colors.grey[600]),
        ),
      ],
    );
  }
}

class _EmptyBehaviorState extends StatelessWidget {
  const _EmptyBehaviorState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.sentiment_satisfied_alt,
              size: 64, color: PawTableColors.primary.withValues(alpha: 0.5)),
          const SizedBox(height: 16),
          Text(
            'No behavior logged yet',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(color: Colors.grey[700]),
          ),
          const SizedBox(height: 8),
          Text(
            'Track your pet\'s mood and activity to monitor wellness!',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[500],
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _BehaviorHistoryCard extends StatelessWidget {
  final BehaviorLogEntity log;
  final VoidCallback onDelete;

  const _BehaviorHistoryCard({required this.log, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 1,
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: log.mood.color.withValues(alpha: 0.1),
          child: Icon(log.mood.icon, color: log.mood.color),
        ),
        title: Text(log.mood.label,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 2),
            Row(
              children: [
                Icon(log.activityLevel.icon, size: 14),
                const SizedBox(width: 4),
                Text(
                  'Activity: ${log.activityLevel.label}',
                  style: const TextStyle(fontSize: 13),
                ),
              ],
            ),
            if (log.notes != null)
              Text(
                log.notes!,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                ),
              ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              DateFormat('h:mm a').format(log.loggedAt),
              style: const TextStyle(fontSize: 12),
            ),
            Text(
              _isSameDay(log.loggedAt, DateTime.now())
                  ? 'Today'
                  : DateFormat('MMM d').format(log.loggedAt),
              style: const TextStyle(fontSize: 10, color: Colors.grey),
            ),
          ],
        ),
        onLongPress: () async {
          final confirmed = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Delete Entry?'),
                  content: const Text('This cannot be undone.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(false),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.of(ctx).pop(true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: PawTableColors.error,
                      ),
                      child: const Text('Delete'),
                    ),
                  ],
                ),
              ) ??
              false;

          if (confirmed && context.mounted) {
            onDelete();
          }
        },
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}

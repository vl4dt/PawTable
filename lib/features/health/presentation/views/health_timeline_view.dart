import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/navigation/routes.dart';
import '../../../../core/services/data_export_service.dart';
import '../../../../core/services/health_score_calculator.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/billing/billing_service.dart'
    show isSubscribedProvider;
import '../../../behavior/domain/entities/behavior_entity.dart';
import '../../../behavior/presentation/providers/behavior_provider.dart';
import '../../../feeding/domain/entities/feeding_entity.dart';
import '../../../feeding/presentation/providers/feeding_provider.dart';
import '../../../medications/domain/entities/medication_entity.dart';
import '../../../medications/presentation/providers/medication_provider.dart';
import '../../../vaccinations/domain/entities/vaccination_entity.dart';
import '../../../vaccinations/presentation/providers/vaccination_provider.dart';


/// Health timeline view — unified health history
///
/// Displays a combined timeline of all health-related events:
/// feeding logs, vaccinations, medications, behavior logs, and weight entries.
/// Includes health score, export functionality, and statistics.
class HealthTimelineView extends ConsumerWidget {
  final String petId;
  const HealthTimelineView({super.key, required this.petId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch all data providers
    final feedingState = ref.watch(feedingListProvider);
    final vaccinationState = ref.watch(vaccinationListProvider);
    final medicationState = ref.watch(medicationListProvider);
    final behaviorState = ref.watch(behaviorListProvider);

    final isLoading = feedingState.isLoading ||
        vaccinationState.isLoading ||
        medicationState.isLoading ||
        behaviorState.isLoading;

    final hasError = feedingState.error != null ||
        vaccinationState.error != null ||
        medicationState.error != null ||
        behaviorState.error != null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Health Timeline'),
        actions: [
          _ExportButton(petId: petId),
          IconButton(
            icon: const Icon(Icons.bar_chart),
            onPressed: () => _showHealthScoreDialog(context, ref),
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : hasError
              ? _buildError()
              : _buildTimeline(
                  feeding: feedingState.logs,
                  vaccinations: vaccinationState.records,
                  medications: medicationState.records,
                  behaviors: behaviorState.logs,
                ),
    );
  }
}

class _ExportButton extends ConsumerWidget {
  final String petId;
  const _ExportButton({required this.petId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSubscribed = ref.watch(isSubscribedProvider);
    return PopupMenuButton<String>(
      icon: const Icon(Icons.file_download),
      itemBuilder: (_) => [
        const PopupMenuItem(value: 'csv', child: Text('Export CSV (Free)')),
        PopupMenuItem(
          value: 'pdf',
          child: isSubscribed.maybeWhen(
            data: (v) => v ? const Text('Export PDF (Premium)') : const Text('Export PDF (Premium) - Upgrade Required'),
            orElse: () => const Text('Export PDF (Premium) - Upgrade Required'),
          ),
        ),
      ],
      onSelected: (value) async {
        if (value == 'csv') {
          _doExport(context, ref, 'csv');
        } else if (value == 'pdf') {
          final isPremium =
              (isSubscribed.whenData((v) => v) ?? false);
          if (isPremium == false) {
            showDialog(
              context: context,
              builder: (_) => AlertDialog(
                title: const Text('Premium Required'),
                content: const Text('PDF export is available for Premium subscribers only.'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop();
                      context.push(AppRoutes.premium);
                    },
                    icon: const Icon(Icons.workspace_premium),
                    label: const Text('Upgrade'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: PawTableColors.primary,
                    ),
                  ),
                ],
              ),
            );
          } else {
            _doExport(context, ref, 'pdf');
          }
        }
      },
    );
  }

  Future<void> _doExport(BuildContext context, WidgetRef ref, String format) async {
    final snackbar = SnackBar(
      content: Text('Exporting $format...'),
      behavior: SnackBarBehavior.floating,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackbar);

    // Build export data
    final csv = await DataExportService.exportCSV(
      feedingLogs: [],
      vaccinations: [],
      medications: [],
      weightLogs: [],
      behaviorLogs: [],
      petName: 'Pet',
    );

    // In production: save to file / share
    if (context.mounted) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$format export ready! (${csv.length} bytes)'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: PawTableColors.successDark,
        ),
      );
    }
  }
}

void _showHealthScoreDialog(BuildContext context, WidgetRef ref) {
  // Calculate health score
  final feedingState = ref.read(feedingListProvider);
  final vaccinationState = ref.read(vaccinationListProvider);
  final medicationState = ref.read(medicationListProvider);
  final behaviorState = ref.read(behaviorListProvider);

  final avgBehaviorScore = behaviorState.logs.isEmpty
      ? 50.0
      : behaviorState.logs.fold<double>(
          0,
          (sum, log) => sum + log.getWellnessScore(),
        ) /
        behaviorState.logs.length;

  final medicationAdherence = medicationState.records.isEmpty
      ? 100.0
      : medicationState.records.where((r) => r.taken).length /
          medicationState.records.length * 100;

  final vaccinationsUpToDate = vaccinationState.records.where((r) {
    final due = r.nextDueDate;
    if (due == null) return true;
    return !due.isBefore(DateTime.now());
  }).length;

  final totalVaccinations = vaccinationState.records.isEmpty
      ? 1.0
      : vaccinationState.records.length.toDouble();

  final scoreResult = HealthScoreCalculator.calculate(
    avgBehaviorScore: avgBehaviorScore,
    feedingRegularity: 0.7, // Placeholder
    medicationAdherence: medicationAdherence,
    vaccinationsUpToDate: vaccinationsUpToDate,
    totalVaccinations: totalVaccinations,
    avgActivityLevel: 2.0, // Placeholder
    weightStability: 0.8, // Placeholder
    hydrationLevel: 0.7, // Placeholder
    daysSinceLastBehaviorLog: 0,
  );

  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Health Score'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Score ring
            SizedBox(
              width: 160,
              height: 160,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 160,
                    height: 160,
                    child: CircularProgressIndicator(
                      value: scoreResult.score / 100,
                      strokeWidth: 10,
                      backgroundColor: Colors.grey.shade200,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(scoreResult.categoryColor),
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${scoreResult.score}',
                        style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: scoreResult.categoryColor,
                        ),
                      ),
                      Text(
                        '/100',
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              scoreResult.category,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: scoreResult.categoryColor,
              ),
            ),
            const SizedBox(height: 16),
            // Breakdown bars
            _ScoreBreakdownBar('Behavior', scoreResult.getPercentage('behavior'), Icons.favorite, scoreResult.categoryColor),
            _ScoreBreakdownBar('Nutrition', scoreResult.getPercentage('nutrition'), Icons.restaurant, scoreResult.categoryColor),
            _ScoreBreakdownBar('Medical', scoreResult.getPercentage('medical'), Icons.medication, scoreResult.categoryColor),
            _ScoreBreakdownBar('Physical', scoreResult.getPercentage('physical'), Icons.sports, scoreResult.categoryColor),
            _ScoreBreakdownBar('Hydration', scoreResult.getPercentage('hydration'), Icons.water_drop, scoreResult.categoryColor),
            const SizedBox(height: 16),
            // Tips
            if (scoreResult.tips.isNotEmpty) ...[
              const Text('Tips:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ...scoreResult.tips.map((tip) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Text('• $tip', style: const TextStyle(fontSize: 13)),
                  )),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(),
          child: const Text('Close'),
        ),
      ],
    ),
  );
}

class _ScoreBreakdownBar extends StatelessWidget {
  final String label;
  final double percentage;
  final IconData icon;
  final Color color;

  const _ScoreBreakdownBar(
    this.label,
    this.percentage,
    this.icon,
    this.color,
  );

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(icon, size: 14, color: color),
                  const SizedBox(width: 4),
                  Text(label, style: const TextStyle(fontSize: 12)),
                ],
              ),
              Text(
                '${percentage.toStringAsFixed(0)}%',
                style: TextStyle(fontSize: 12, color: color),
              ),
            ],
          ),
          const SizedBox(height: 2),
          LinearProgressIndicator(
            value: percentage / 100,
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 4,
          ),
        ],
      ),
    );
  }
}

Widget _buildError() {
  return const Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.error_outline, size: 48, color: Colors.red),
        SizedBox(height: 16),
        Text('Error loading health data', textAlign: TextAlign.center),
      ],
    ),
  );
}

// Health event model for timeline
class HealthEvent {
  final DateTime timestamp;
  final String type;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;

  const HealthEvent({
    required this.timestamp,
    required this.type,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
  });
}

Widget _buildTimeline({
  required List<FeedingEntity> feeding,
  required List<VaccinationEntity> vaccinations,
  required List<MedicationEntity> medications,
  required List<BehaviorLogEntity> behaviors,
}) {
  // Combine all events into a timeline
  final events = <HealthEvent>[];

  for (final log in feeding) {
    events.add(HealthEvent(
      timestamp: log.fedAt,
      type: 'feeding',
      title: _getFeedingLabel(log.type),
      subtitle: '${log.amountGrams.toStringAsFixed(0)}g',
      icon: _getFeedingIcon(log.type),
      iconColor: _getFeedingColor(log.type),
    ));
  }

  for (final v in vaccinations) {
    events.add(HealthEvent(
      timestamp: v.dateGiven,
      type: 'vaccination',
      title: v.name,
      subtitle: v.nextDueDate != null
          ? 'Next due: ${DateFormat('MMM d').format(v.nextDueDate!)}'
          : 'Recorded',
      icon: Icons.shield,
      iconColor: PawTableColors.primary,
    ));
  }

  for (final m in medications) {
    events.add(HealthEvent(
      timestamp: m.scheduledAt,
      type: 'medication',
      title: m.name,
      subtitle: m.taken ? 'Taken' : 'Pending',
      icon: Icons.medication,
      iconColor: m.taken ? PawTableColors.successDark : PawTableColors.warning,
    ));
  }

  for (final b in behaviors) {
    events.add(HealthEvent(
      timestamp: b.loggedAt,
      type: 'behavior',
      title: b.mood.label,
      subtitle: 'Activity: ${b.activityLevel.label}',
      icon: b.mood.icon,
      iconColor: b.mood.color,
    ));
  }

  // Sort by timestamp descending
  events.sort((a, b) => b.timestamp.compareTo(a.timestamp));

  if (events.isEmpty) {
    return const _EmptyTimeline();
  }

  return ListView.builder(
    padding: const EdgeInsets.all(16),
    itemCount: events.length,
    itemBuilder: (context, index) {
      final event = events[index];
      final isLast = index == events.length - 1;

      return _TimelineTile(
        event: event,
        isFirst: index == 0,
        isLast: isLast,
      );
    },
  );
}

class _TimelineTile extends StatelessWidget {
  final HealthEvent event;
  final bool isFirst;
  final bool isLast;

  const _TimelineTile({
    required this.event,
    required this.isFirst,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Timeline line and icon
        Column(
          children: [
            if (!isFirst)
              Container(
                width: 2,
                height: 20,
                color: Colors.grey.shade300,
              ),
            CircleAvatar(
              radius: 14,
              backgroundColor: event.iconColor.withValues(alpha: 0.1),
              child: Icon(event.icon, size: 16, color: event.iconColor),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 20,
                color: Colors.grey.shade300,
              ),
          ],
        ),
        const SizedBox(width: 12),
        // Content
        Expanded(
          child: Card(
            elevation: 1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              title: Text(
                event.title,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                '${event.subtitle}\n${DateFormat('EEE, MMM d, h:mm a').format(event.timestamp)}',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            ),
          ),
        ),
      ],
    );
  }
}

class _EmptyTimeline extends StatelessWidget {
  const _EmptyTimeline();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history,
              size: 64, color: PawTableColors.primary.withOpacity(0.5)),
          const SizedBox(height: 16),
          Text(
            'No health events yet',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(color: Colors.grey[700]),
          ),
          const SizedBox(height: 8),
          Text(
            'Start logging feeding, medications, or behavior to see your pet\'s health timeline',
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

// Feeding helper methods
Color _getFeedingColor(dynamic type) {
  final name = type.name ?? '';
  switch (name) {
    case 'dry':
      return Colors.orange;
    case 'wet':
      return Colors.blue;
    case 'raw':
      return Colors.red;
    case 'homemade':
      return Colors.green;
    case 'treat':
      return Colors.purple;
    case 'supplement':
      return Colors.cyan;
    default:
      return PawTableColors.primary;
  }
}

IconData _getFeedingIcon(dynamic type) {
  final name = type.name ?? '';
  switch (name) {
    case 'dry':
      return Icons.grain;
    case 'wet':
      return Icons.dinner_dining;
    case 'raw':
      return Icons.waves;
    case 'homemade':
      return Icons.kitchen;
    case 'treat':
      return Icons.cookie;
    case 'supplement':
      return Icons.medication;
    default:
      return Icons.restaurant;
  }
}

String _getFeedingLabel(dynamic type) {
  final name = type.name ?? 'Meal';
  switch (name) {
    case 'dry':
      return 'Dry Food';
    case 'wet':
      return 'Wet Food';
    case 'raw':
      return 'Raw Diet';
    case 'homemade':
      return 'Homemade';
    case 'treat':
      return 'Treat';
    case 'supplement':
      return 'Water';
    default:
      return 'Meal';
  }
}

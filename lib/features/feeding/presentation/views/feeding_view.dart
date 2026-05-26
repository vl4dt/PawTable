import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/theme/colors.dart';
import '../../../../shared/widgets/celebration_animation.dart';
import '../../domain/entities/feeding_entity.dart';
import '../providers/feeding_provider.dart';
import '../../../../core/billing/billing_service.dart' show isSubscribedProvider;

/// Main feeding log view
///
/// Displays today's feeding summary, feeding history list,
/// and floating action button to add new feeding log.
class FeedingView extends ConsumerWidget {
  final String petId;
  const FeedingView({super.key, required this.petId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feedingState = ref.watch(feedingListProvider);
    final now = DateTime.now();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Feeding'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () {
              showDateRangePicker(
                context: context,
                firstDate: now.subtract(const Duration(days: 365)),
                lastDate: now,
              ).then((range) {
                if (range != null) {
                  // TODO: filter by date range
                }
              });
            },
          ),
        ],
      ),
      body: feedingState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : feedingState.error != null
              ? _buildError(feedingState.error!)
              : _buildContent(
                  petId: petId,
                  state: feedingState,
                  context: context,
                  ref: ref,
                  now: now,
                ),
      floatingActionButton: _AddFeedingFAB(petId: petId),
    );
  }
}

class _AddFeedingFAB extends ConsumerWidget {
  final String petId;
  const _AddFeedingFAB({required this.petId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FloatingActionButton.extended(
      onPressed: () => _showAddFeedingDialog(context, petId, ref),
      icon: const Icon(Icons.add),
      label: const Text('Log Meal'),
      backgroundColor: PawTableColors.primary,
    );
  }
}

void _showAddFeedingDialog(
  BuildContext context,
  String petId,
  WidgetRef ref,
) {
  final amountController = TextEditingController();
  final notesController = TextEditingController();
  FeedingType selectedType = FeedingType.dry;
  bool isWaterIntake = false;

  showDialog(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (buildCtx, setState) => AlertDialog(
        title: const Text('Log Feeding'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Feed type selector
              const Text('Type', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: FeedingType.values.map((type) {
                  final isSelected = selectedType == type;
                  return ChoiceChip(
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(type.icon, size: 18),
                        const SizedBox(width: 4),
                        Text(type.label),
                      ],
                    ),
                    selected: isSelected,
                    onSelected: (_) => setState(() => selectedType = type),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              // Water intake toggle
              SwitchListTile(
                title: const Text('Water Intake'),
                subtitle: const Text('Log water instead of food'),
                value: isWaterIntake,
                onChanged: (v) => setState(() => isWaterIntake = v),
              ),
              const SizedBox(height: 16),
              // Amount
              TextField(
                controller: amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: isWaterIntake ? 'Amount (ml)' : 'Amount (grams)',
                  prefixIcon: Icon(isWaterIntake
                      ? Icons.water_drop
                      : Icons.scale),
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              // Notes
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
              if (amountController.text.isEmpty) return;

              final amount = double.tryParse(amountController.text) ?? 0;
              final type = isWaterIntake
                  ? FeedingType.supplement
                  : selectedType;

              final log = FeedingEntity(
                id: const Uuid().v7(),
                petId: petId,
                type: type,
                amountGrams: amount,
                notes: notesController.text.isEmpty ? null : notesController.text,
                fedAt: DateTime.now(),
                createdAt: DateTime.now(),
              );

              await ref
                  .read(feedingListProvider.notifier)
                  .addLog(log);

              if (context.mounted) {
                _showCelebration(context);
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

void _showCelebration(BuildContext context) {
  final entry = OverlayEntry(
    builder: (context) => Positioned.fill(
      child: Material(
        color: Colors.transparent,
        child: Center(
          child: FadeTransition(
            opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
              CurvedAnimation(
                parent: AnimationController(
                  vsync: Scaffold.of(context),
                  duration: const Duration(milliseconds: 300),
                )..forward(),
                curve: Curves.easeInOut,
              ),
            ),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.95),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: PawTableColors.primary.withValues(alpha: 0.3),
                    blurRadius: 20,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check_circle,
                      size: 64, color: PawTableColors.successDark),
                  const SizedBox(height: 16),
                  Text(
                    'Feeding logged!',
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(
                      color: PawTableColors.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Great job keeping track of your pet\'s nutrition!',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );

  Overlay.of(context).insert(entry);
  Future.delayed(const Duration(seconds: 2), () {
    if (entry.mounted) entry.remove();
  });
}

Widget _buildError(String error) {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.error_outline, size: 48, color: Colors.red),
        const SizedBox(height: 16),
        Text('Error: $error', textAlign: TextAlign.center),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () {},
          child: const Text('Retry'),
        ),
      ],
    ),
  );
}

Widget _buildContent({
  required String petId,
  required FeedingListState state,
  required BuildContext context,
  required WidgetRef ref,
  required DateTime now,
}) {
  final summary = ref.read(feedingListProvider.notifier).getTodaySummary(now);
  final formattedDate = DateFormat('EEEE, MMMM d').format(now);

  return Column(
    children: [
      // Today's summary card
      Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [PawTableColors.primary, PawTableColors.primaryDark],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: PawTableColors.primary.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              formattedDate,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _summaryStat('Meals', '${summary['count']}', Icons.restaurant),
                const SizedBox(width: 24),
                _summaryStat('Total', '${(summary['totalGrams'] as double).toStringAsFixed(0)}g', Icons.grain),
              ],
            ),
            if ((summary['mealTypes'] as List).isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 6,
                children: (summary['mealTypes'] as List).map<Widget>((type) {
                  return Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      type,
                      style: const TextStyle(
                          color: Colors.white, fontSize: 12),
                    ),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),

      // Recent feeding history
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Feedings',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            Text(
              '${state.logs.length} total',
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
          ],
        ),
      ),
      const SizedBox(height: 8),

      Expanded(
        child: state.logs.isEmpty
            ? const _EmptyFeedingState()
            : ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: state.logs.length,
                itemBuilder: (context, index) {
                  final log = state.logs[index];
                  return _FeedingHistoryCard(
                    log: log,
                    onDelete: () => ref
                        .read(feedingListProvider.notifier)
                        .deleteLog(log.id),
                  );
                },
              ),
      ),
    ],
  );
}

Widget _summaryStat(String label, String value, IconData icon) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(width: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      Text(
        label,
        style: const TextStyle(color: Colors.white70, fontSize: 13),
      ),
    ],
  );
}

class _EmptyFeedingState extends StatelessWidget {
  const _EmptyFeedingState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.restaurant,
              size: 64, color: PawTableColors.primary.withValues(alpha: 0.5)),
          const SizedBox(height: 16),
          Text(
            'No meals logged yet',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(color: Colors.grey[700]),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the + button to log your pet\'s first meal!',
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

class _FeedingHistoryCard extends StatelessWidget {
  final FeedingEntity log;
  final VoidCallback onDelete;
  const _FeedingHistoryCard({required this.log, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final isToday = _isSameDay(log.fedAt, DateTime.now());
    final timeStr = _formatTime(log.fedAt);
    final amountDisplay = log.type == FeedingType.supplement
        ? '${log.amountGrams.toStringAsFixed(0)} ml (Water)'
        : '${log.amountGrams.toStringAsFixed(0)}g ${log.type.name}';

    return Dismissible(
      key: Key(log.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: PawTableColors.error,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (direction) async {
        return await showDialog<bool>(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text('Delete Feeding Log?'),
                content: const Text(
                    'This action cannot be undone. Are you sure?'),
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
      },
      onDismissed: (_) => onDelete(),
      child: Card(
        margin: const EdgeInsets.only(bottom: 8),
        elevation: 1,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12)),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: _getTypeColor(log.type).withValues(alpha: 0.1),
            child: Icon(
              _getTypeIcon(log.type),
              color: _getTypeColor(log.type),
            ),
          ),
          title: Text(_getTypeLabel(log.type)),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 2),
              Text(amountDisplay),
              if (log.notes != null) ...[
                const SizedBox(height: 2),
                Text(
                  log.notes!,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ],
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                timeStr,
                style: TextStyle(
                  color: isToday
                      ? PawTableColors.successDark
                      : Colors.grey[600],
                  fontSize: 12,
                  fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              Text(
                isToday ? 'Today' : _formatDateShort(log.fedAt),
                style: const TextStyle(fontSize: 10, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getTypeColor(FeedingType type) {
    switch (type) {
      case FeedingType.dry:
        return Colors.orange;
      case FeedingType.wet:
        return Colors.blue;
      case FeedingType.raw:
        return Colors.red;
      case FeedingType.homemade:
        return Colors.green;
      case FeedingType.treat:
        return Colors.purple;
      case FeedingType.supplement:
        return Colors.cyan;
    }
  }

  IconData _getTypeIcon(FeedingType type) {
    switch (type) {
      case FeedingType.dry:
        return Icons.grain;
      case FeedingType.wet:
        return Icons.dinner_dining;
      case FeedingType.raw:
        return Icons.waves;
      case FeedingType.homemade:
        return Icons.kitchen;
      case FeedingType.treat:
        return Icons.cookie;
      case FeedingType.supplement:
        return Icons.medication;
    }
  }

  String _getTypeLabel(FeedingType type) {
    switch (type) {
      case FeedingType.dry:
        return 'Dry Food';
      case FeedingType.wet:
        return 'Wet Food';
      case FeedingType.raw:
        return 'Raw Diet';
      case FeedingType.homemade:
        return 'Homemade';
      case FeedingType.treat:
        return 'Treat';
      case FeedingType.supplement:
        return 'Water Intake';
    }
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  String _formatTime(DateTime dt) {
    return DateFormat('h:mm a').format(dt);
  }

  String _formatDateShort(DateTime dt) {
    return DateFormat('MMM d').format(dt);
  }
}

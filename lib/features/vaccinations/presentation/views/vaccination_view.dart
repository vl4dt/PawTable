import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/theme/colors.dart';
import '../../domain/entities/vaccination_entity.dart';
import '../providers/vaccination_provider.dart';

/// Vaccination tracker view
///
/// Shows vaccination card (up-to-date status), vaccination history,
/// upcoming reminders, and ability to add new vaccination records.
class VaccinationView extends ConsumerWidget {
  final String petId;
  const VaccinationView({super.key, required this.petId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(vaccinationListProvider);
    final stats = ref.read(vaccinationListProvider.notifier).getStats();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Vaccinations'),
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
                  stats: stats,
                ),
      floatingActionButton: _AddVaccinationFAB(petId: petId),
    );
  }
}

class _AddVaccinationFAB extends ConsumerWidget {
  final String petId;
  const _AddVaccinationFAB({required this.petId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FloatingActionButton.extended(
      onPressed: () => _showAddDialog(context, petId, ref),
      icon: const Icon(Icons.add),
      label: const Text('Add Vaccination'),
      backgroundColor: PawTableColors.primary,
    );
  }
}

void _showAddDialog(BuildContext context, String petId, WidgetRef ref) {
  final nameController = TextEditingController();
  final clinicController = TextEditingController();
  final batchController = TextEditingController();
  final notesController = TextEditingController();
  DateTime? selectedDate;
  DateTime? nextDue;

  showDialog(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (buildCtx, setState) => AlertDialog(
        title: const Text('Add Vaccination'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Vaccine name
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Vaccine Name',
                  prefixIcon: Icon(Icons.medication),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              // Date given
              InkWell(
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime.now(),
                  );
                  if (date != null) {
                    setState(() => selectedDate = date);
                  }
                },
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Date Given',
                    prefixIcon: Icon(Icons.calendar_today),
                    border: OutlineInputBorder(),
                  ),
                  child: Text(
                    selectedDate != null
                        ? DateFormat('MMM d, yyyy').format(selectedDate!)
                        : 'Select date',
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Next due date
              InkWell(
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now().add(const Duration(days: 365)),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2040),
                  );
                  if (date != null) {
                    setState(() => nextDue = date);
                  }
                },
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Next Due Date (optional)',
                    prefixIcon: Icon(Icons.date_range),
                    border: OutlineInputBorder(),
                  ),
                  child: Text(
                    nextDue != null
                        ? DateFormat('MMM d, yyyy').format(nextDue!)
                        : 'Select date',
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Vet clinic
              TextField(
                controller: clinicController,
                decoration: const InputDecoration(
                  labelText: 'Vet Clinic',
                  prefixIcon: Icon(Icons.location_on),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              // Batch number
              TextField(
                controller: batchController,
                decoration: const InputDecoration(
                  labelText: 'Batch Number (optional)',
                  prefixIcon: Icon(Icons.tag),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              // Notes
              TextField(
                controller: notesController,
                decoration: const InputDecoration(
                  labelText: 'Notes',
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
              if (nameController.text.isEmpty || selectedDate == null) return;

              final record = VaccinationEntity(
                id: const Uuid().v7(),
                petId: petId,
                name: nameController.text,
                dateGiven: selectedDate!,
                nextDueDate: nextDue,
                vetClinic: clinicController.text.isEmpty
                    ? null
                    : clinicController.text,
                notes: notesController.text.isEmpty
                    ? null
                    : notesController.text,
                createdAt: DateTime.now(),
              );

              await ref
                  .read(vaccinationListProvider.notifier)
                  .addRecord(record);

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
  required VaccinationListState state,
  required BuildContext context,
  required WidgetRef ref,
  required Map<String, dynamic> stats,
}) {
  final overdue = state.records.where((r) => r.isDue).toList();
  final now = DateTime.now();
  final oneYear = now.add(const Duration(days: 365));
  final upcoming = state.records
      .where((r) =>
          r.nextDueDate != null &&
          r.nextDueDate!.isAfter(now) &&
          r.nextDueDate!.isBefore(oneYear))
      .toList();

  return Column(
    children: [
      // Status card
      _StatusCard(
        isUpToDate: stats['overdue'] == 0 && stats['total'] > 0,
        overdueCount: stats['overdue'],
        nextDueDate: upcoming.isNotEmpty
            ? upcoming.first.nextDueDate
            : null,
      ),

      // Stats row
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _StatBadge('Total', '${stats['total']}', Icons.medication),
            _StatBadge(
                'Overdue', '${stats['overdue']}', Icons.warning,
                color: overdue.isNotEmpty
                    ? PawTableColors.error
                    : PawTableColors.success),
            _StatBadge(
                'Due Soon', '${stats['upcoming']}', Icons.notifications),
          ],
        ),
      ),

      // Overdue vaccinations
      if (overdue.isNotEmpty) ...[
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: PawTableColors.error, size: 20),
              const SizedBox(width: 8),
              Text(
                'Overdue',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: PawTableColors.error,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
      ],

      // Vaccination history
      Expanded(
        child: state.records.isEmpty
            ? const _EmptyVaccinationState()
            : ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: state.records.length,
                itemBuilder: (context, index) {
                  final record = state.records[index];
                  final isOverdue = overdue.any((r) => r.id == record.id);
                  final isUpcoming = upcoming.any((r) => r.id == record.id);

                  return _VaccinationCard(
                    record: record,
                    isOverdue: isOverdue,
                    isUpcoming: isUpcoming,
                    onDelete: () => ref
                        .read(vaccinationListProvider.notifier)
                        .deleteRecord(record.id),
                  );
                },
              ),
      ),
    ],
  );
}

class _StatusCard extends StatelessWidget {
  final bool isUpToDate;
  final int overdueCount;
  final DateTime? nextDueDate;

  const _StatusCard({
    required this.isUpToDate,
    required this.overdueCount,
    this.nextDueDate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isUpToDate
              ? [PawTableColors.success, PawTableColors.successDark]
              : [PawTableColors.warning, Colors.orange],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: (isUpToDate
                    ? PawTableColors.success
                    : PawTableColors.warning)
                .withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isUpToDate
                  ? Icons.check_circle
                  : Icons.error_outline,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isUpToDate
                      ? 'All Vaccinations Up to Date'
                      : '$overdueCount Vaccination${overdueCount > 1 ? 's' : ''} Overdue',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (nextDueDate != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Next due: ${DateFormat('MMM d, yyyy').format(nextDueDate!)}',
                    style: const TextStyle(color: Colors.white70),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatBadge extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color? color;

  const _StatBadge(
    this.label,
    this.value,
    this.icon, {
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color ?? PawTableColors.primary, size: 20),
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

class _EmptyVaccinationState extends StatelessWidget {
  const _EmptyVaccinationState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.medication,
              size: 64, color: PawTableColors.primary.withValues(alpha: 0.5)),
          const SizedBox(height: 16),
          Text(
            'No vaccinations recorded',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(color: Colors.grey[700]),
          ),
          const SizedBox(height: 8),
          Text(
            'Add your pet\'s first vaccination record!',
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

class _VaccinationCard extends StatelessWidget {
  final VaccinationEntity record;
  final bool isOverdue;
  final bool isUpcoming;
  final VoidCallback onDelete;

  const _VaccinationCard({
    required this.record,
    required this.isOverdue,
    required this.isUpcoming,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final daysDiff = record.nextDueDate != null
        ? record.nextDueDate!.difference(DateTime.now()).inDays
        : null;

    Color statusColor;
    String statusText;
    if (isOverdue) {
      statusColor = PawTableColors.error;
      statusText = 'Overdue';
    } else if (isUpcoming) {
      statusColor = PawTableColors.warning;
      statusText = daysDiff != null
          ? 'Due in $daysDiff days'
          : 'Due soon';
    } else {
      statusColor = PawTableColors.successDark;
      statusText = 'Up to date';
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isOverdue
            ? const BorderSide(color: PawTableColors.error, width: 1.5)
            : BorderSide.none,
      ),
      child: Dismissible(
        key: Key(record.id),
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
                  title: const Text('Delete Record?'),
                  content:
                      const Text('This action cannot be undone.'),
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
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: statusColor.withValues(alpha: 0.1),
            child: Icon(
              isOverdue
                  ? Icons.error_outline
                  : isUpcoming
                      ? Icons.schedule
                      : Icons.check_circle,
              color: statusColor,
            ),
          ),
          title: Text(
            record.name,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 2),
              Text('Given: ${DateFormat('MMM d, yyyy').format(record.dateGiven)}'),
              if (record.nextDueDate != null)
                Text(
                  'Next due: ${DateFormat('MMM d, yyyy').format(record.nextDueDate!)}',
                ),
              if (record.vetClinic != null)
                Text(
                  'Clinic: ${record.vetClinic}',
                  style: const TextStyle(fontSize: 12),
                ),
            ],
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  statusText,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/navigation/routes.dart';
import '../../../../core/theme/colors.dart';
import '../../domain/entities/medication_entity.dart';
import '../providers/medication_provider.dart';

/// Medication tracker view
///
/// Shows active medications, adherence rate, schedule view,
/// and ability to add/complete/stop medications.
class MedicationView extends ConsumerWidget {
  final String petId;
  const MedicationView({super.key, required this.petId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(medicationListProvider);
    final notifier = ref.read(medicationListProvider.notifier);
    final todayStats = notifier.getTodayStats();
    final active = notifier.getActive();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Medications'),
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
                  todayStats: todayStats,
                  active: active,
                ),
      floatingActionButton: _AddMedicationFAB(petId: petId),
    );
  }
}

class _AddMedicationFAB extends ConsumerWidget {
  final String petId;
  const _AddMedicationFAB({required this.petId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FloatingActionButton.extended(
      onPressed: () => _showAddDialog(context, petId, ref),
      icon: const Icon(Icons.add),
      label: const Text('Add Medication'),
      backgroundColor: PawTableColors.primary,
    );
  }
}

void _showAddDialog(BuildContext context, String petId, WidgetRef ref) {
  final nameController = TextEditingController();
  final dosageController = TextEditingController();
  final unitController = TextEditingController(text: 'mg');
  final instructionsController = TextEditingController();
  DateTime? startDate;
  DateTime? endDate;
  String frequency = 'Once daily';

  showDialog(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (buildCtx, setState) => AlertDialog(
        title: const Text('Add Medication'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Medication Name',
                  prefixIcon: Icon(Icons.medication),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: dosageController,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'Dosage',
                        prefixIcon: Icon(Icons.scale),
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: TextField(
                      controller: unitController,
                      decoration: const InputDecoration(
                        labelText: 'Unit',
                        prefixIcon: Icon(Icons.straighten),
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: frequency,
                decoration: const InputDecoration(
                  labelText: 'Frequency',
                  prefixIcon: Icon(Icons.schedule),
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'Once daily', child: Text('Once daily')),
                  DropdownMenuItem(value: 'Twice daily', child: Text('Twice daily')),
                  DropdownMenuItem(value: 'Three times daily', child: Text('Three times daily')),
                  DropdownMenuItem(value: 'Weekly', child: Text('Weekly')),
                  DropdownMenuItem(value: 'As needed', child: Text('As needed')),
                  DropdownMenuItem(value: 'Monthly', child: Text('Monthly')),
                ],
                onChanged: (v) => setState(() => frequency = v!),
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime.now(),
                  );
                  if (date != null) setState(() => startDate = date);
                },
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Start Date',
                    prefixIcon: Icon(Icons.calendar_today),
                    border: OutlineInputBorder(),
                  ),
                  child: Text(
                    startDate != null
                        ? DateFormat('MMM d, yyyy').format(startDate!)
                        : 'Select date',
                  ),
                ),
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now().add(const Duration(days: 30)),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2040),
                  );
                  if (date != null) setState(() => endDate = date);
                },
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'End Date (optional)',
                    prefixIcon: Icon(Icons.date_range),
                    border: OutlineInputBorder(),
                  ),
                  child: Text(
                    endDate != null
                        ? DateFormat('MMM d, yyyy').format(endDate!)
                        : 'Select date',
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: instructionsController,
                decoration: const InputDecoration(
                  labelText: 'Instructions (optional)',
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
              if (nameController.text.isEmpty ||
                  dosageController.text.isEmpty ||
                  startDate == null) {
                return;
              }

              final record = MedicationEntity(
                id: const Uuid().v7(),
                petId: petId,
                name: nameController.text,
                dosage: double.tryParse(dosageController.text) ?? 0,
                unit: unitController.text.isEmpty ? 'mg' : unitController.text,
                scheduledAt: startDate!,
                frequency: frequency,
                startDate: startDate!,
                endDate: endDate,
                instructions: instructionsController.text.isEmpty
                    ? null
                    : instructionsController.text,
                taken: false,
                createdAt: DateTime.now(),
              );

              await ref
                  .read(medicationListProvider.notifier)
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
  required MedicationListState state,
  required BuildContext context,
  required WidgetRef ref,
  required Map<String, dynamic> todayStats,
  required List<MedicationEntity> active,
}) {
  final now = DateTime.now();

  return Column(
    children: [
      // Adherence rate card
      Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: todayStats['adherence'] >= 80
                ? [PawTableColors.success, PawTableColors.successDark]
                : todayStats['adherence'] >= 50
                    ? [PawTableColors.warning, Colors.orange]
                    : [PawTableColors.error, Colors.red.shade700],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: (todayStats['adherence'] >= 80
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
            SizedBox(
              width: 80,
              height: 80,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 80,
                    height: 80,
                    child: CircularProgressIndicator(
                      value: (todayStats['adherence'] as double) / 100,
                      strokeWidth: 6,
                      backgroundColor: Colors.white.withValues(alpha: 0.3),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                          Colors.white),
                    ),
                  ),
                  Text(
                    '${(todayStats['adherence'] as double).toStringAsFixed(0)}%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Adherence Rate',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${todayStats['taken']}/${todayStats['total']} taken today',
                    style: const TextStyle(color: Colors.white70),
                  ),
                  Text(
                    '${active.length} active medication${active.length != 1 ? 's' : ''}',
                    style: const TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

      // Active medications header
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Active Medications',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            Text(
              '${active.length} active',
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
          ],
        ),
      ),
      const SizedBox(height: 8),

      Expanded(
        child: state.records.isEmpty
            ? const _EmptyMedicationState()
            : ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: state.records.length,
                itemBuilder: (context, index) {
                  final record = state.records[index];
                  final isActive = record.taken == false &&
                      (record.endDate == null ||
                          now.isBefore(record.endDate!));

                  return _MedicationCard(
                    record: record,
                    isActive: isActive,
                    onMarkTaken: () => ref
                        .read(medicationListProvider.notifier)
                        .markTaken(record.id),
                    onMarkUntaken: () => ref
                        .read(medicationListProvider.notifier)
                        .markUntaken(record.id),
                    onDelete: () => ref
                        .read(medicationListProvider.notifier)
                        .deleteRecord(record.id),
                  );
                },
              ),
      ),
    ],
  );
}

class _EmptyMedicationState extends StatelessWidget {
  const _EmptyMedicationState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.medication_liquid,
              size: 64, color: PawTableColors.primary.withValues(alpha: 0.5)),
          const SizedBox(height: 16),
          Text(
            'No medications recorded',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(color: Colors.grey[700]),
          ),
          const SizedBox(height: 8),
          Text(
            'Add your pet\'s prescription medication!',
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

class _MedicationCard extends StatelessWidget {
  final MedicationEntity record;
  final bool isActive;
  final VoidCallback onMarkTaken;
  final VoidCallback onMarkUntaken;
  final VoidCallback onDelete;
  const _MedicationCard({
    required this.record,
    required this.isActive,
    required this.onMarkTaken,
    required this.onMarkUntaken,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final timeStr = DateFormat('h:mm a').format(record.scheduledAt);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: record.taken
            ? const BorderSide(color: PawTableColors.success, width: 1.5)
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
                  title: const Text('Remove Medication?'),
                  content: const Text('This action cannot be undone.'),
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
                      child: const Text('Remove'),
                    ),
                  ],
                ),
              ) ??
              false;
        },
        onDismissed: (_) => onDelete(),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: record.taken
                ? PawTableColors.success.withValues(alpha: 0.1)
                : isActive
                    ? PawTableColors.warning.withValues(alpha: 0.1)
                    : Colors.grey.withValues(alpha: 0.1),
            child: Icon(
              record.taken
                  ? Icons.check_circle
                  : isActive
                      ? Icons.schedule
                      : Icons.cancel,
              color: record.taken
                  ? PawTableColors.successDark
                  : isActive
                      ? PawTableColors.warning
                      : Colors.grey,
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
              Text(
                '${record.dosage} ${record.unit} — $timeStr — ${record.frequency}',
              ),
              if (record.instructions != null)
                Text(
                  record.instructions!,
                  style: const TextStyle(fontSize: 12),
                ),
              if (record.endDate != null)
                Text(
                  'Ends: ${DateFormat('MMM d').format(record.endDate!)}',
                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                ),
            ],
          ),
          trailing: !record.taken
              ? IconButton(
                  icon: Icon(Icons.check_circle_outline,
                      color: PawTableColors.successDark),
                  onPressed: onMarkTaken,
                  tooltip: 'Mark as taken',
                )
              : Tooltip(
                  message: 'Taken at ${record.takenAt != null ? DateFormat('MMM d h:mm a').format(record.takenAt!) : ""}',
                  child: Icon(Icons.check_circle, color: PawTableColors.successDark),
                ),
        ),
      ),
    );
  }
}

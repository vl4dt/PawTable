/// PawTable Calendar view.
///
/// Displays a monthly calendar grid with event indicators and a
/// day detail panel showing all events for the selected date.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/navigation/routes.dart';
import '../../../../core/theme/colors.dart';
import '../providers/calendar_provider.dart';
import '../../../pets/presentation/providers/pet_provider.dart';
import 'package:uuid/uuid.dart';
import 'notification_preferences_view.dart';
import '../../domain/entities/calendar_event_entity.dart';

/// Main calendar view — monthly grid with day detail panel
class CalendarView extends ConsumerWidget {
  const CalendarView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final petList = ref.watch(petListProvider);
    final selection = ref.watch(petSelectionProvider);
    String? selectedPetId = selection.selectedPetId;

    // Fallback: use first pet if none selected
    if (selectedPetId == null) {
      final pets = petList.when(
        data: (pets) => pets,
        loading: () => const [],
        error: (_, __) => const [],
      );
      if (pets.isNotEmpty) {
        selectedPetId = pets.first.id;
      }
    }

    if (selectedPetId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Calendar')),
        body: const Center(
          child: Text('Select a pet to view calendar'),
        ),
      );
    }

    return const _CalendarBody();
  }
}

class _CalendarBody extends ConsumerWidget {
  const _CalendarBody();

  String? _getSelectedPetId(WidgetRef ref) {
    final petList = ref.watch(petListProvider);
    final selection = ref.watch(petSelectionProvider);
    String? petId = selection.selectedPetId;

    if (petId == null) {
      petList.when(
        data: (pets) {
          if (pets.isNotEmpty) petId = pets.first.id;
        },
        loading: () {},
        error: (_, __) {},
      );
    }
    return petId;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final calendarState = ref.watch(calendarProvider);
    final notifier = ref.read(calendarProvider.notifier);
    final selectedPetId = _getSelectedPetId(ref);

    if (selectedPetId == null) {
      return const Center(child: Text('Select a pet to view calendar'));
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifier.loadEvents(selectedPetId);
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendar'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () => _showNotificationPreferences(context, ref),
            tooltip: 'Notification Preferences',
          ),
        ],
      ),
      body: calendarState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : calendarState.error != null
              ? _buildError(context, calendarState.error!)
              : Column(
                  children: [
                    _buildMonthNavigator(context, ref, calendarState.selectedDate),
                    _buildCalendarGrid(context, ref, calendarState.selectedDate, notifier),
                    const SizedBox(height: 8),
                    _buildEventsList(context, ref, selectedPetId, calendarState.selectedDate, calendarState),
                  ],
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showQuickAdd(context, ref, selectedPetId),
        icon: const Icon(Icons.add),
        label: const Text('Quick Add'),
        backgroundColor: PawTableColors.primary,
      ),
    );
  }

  Widget _buildError(BuildContext context, String error) {
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

  Widget _buildMonthNavigator(
    BuildContext context,
    WidgetRef ref,
    DateTime date,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () {
              final previous = DateTime(date.year, date.month - 1, 1);
              ref.read(calendarProvider.notifier)
                  .setSelectedDate(previous, _getSelectedPetId(ref)!);
            },
          ),
          Text(
            DateFormat.yMMMMd().format(date),
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: PawTableColors.primaryDark,
              fontWeight: FontWeight.bold,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () {
              final next = DateTime(date.year, date.month + 1, 1);
              ref.read(calendarProvider.notifier)
                  .setSelectedDate(next, _getSelectedPetId(ref)!);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarGrid(
    BuildContext context,
    WidgetRef ref,
    DateTime date,
    CalendarListNotifier notifier,
  ) {
    final firstDay = DateTime(date.year, date.month, 1);
    final lastDay = DateTime(date.year, date.month + 1, 0);
    final startWeekday = firstDay.weekday; // 1=Mon, 7=Sun
    final daysInMonth = lastDay.day;

    return Column(
      children: [
        // Weekday headers
        Row(
          children: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']
              .map((day) => Expanded(
                    child: Center(
                      child: Text(
                        day,
                        style: TextStyle(
                          color: PawTableColors.onSurfaceVariant,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ))
              .toList(),
        ),
        const Divider(height: 1),
        // Calendar days
        _buildCalendarDays(
          context,
          ref,
          firstDay,
          daysInMonth,
          startWeekday,
          notifier,
        ),
      ],
    );
  }

  Widget _buildCalendarDays(
    BuildContext context,
    WidgetRef ref,
    DateTime firstDay,
    int daysInMonth,
    int startWeekday,
    CalendarListNotifier notifier,
  ) {
    final today = DateTime.now();
    final selectedDate = DateTime.now();
    final cells = <Widget>[];
    final emptyCells = startWeekday - 1;

    // Empty cells for days before the 1st
    for (int i = 0; i < emptyCells; i++) {
      cells.add(const SizedBox.shrink());
    }

    // Day cells
    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(firstDay.year, firstDay.month, day);
      final eventCount = notifier.getEventsForDate(date);
      final isToday = date.year == today.year &&
          date.month == today.month &&
          date.day == today.day;
      final isSelected = date.year == selectedDate.year &&
          date.month == selectedDate.month &&
          date.day == selectedDate.day;

      cells.add(
        _CalendarDayCell(
          day: day,
          isToday: isToday,
          isSelected: isSelected,
          eventCount: eventCount,
          onTap: () {
            ref.read(calendarProvider.notifier)
                .setSelectedDate(date, _getSelectedPetId(ref)!);
          },
        ),
      );

      // End row on Sunday (weekday 7) or last day
      if ((startWeekday + day - 1) % 7 == 0 || day == daysInMonth) {
        // Pad remaining cells in row
        final remaining = 7 - ((cells.length - emptyCells) % 7);
        for (int i = 0; i < remaining && cells.length % 7 != 0; i++) {
          cells.add(const SizedBox.shrink());
        }
      }
    }

    // Wrap cells into rows
    final rows = <Widget>[];
    for (int i = 0; i < cells.length; i += 7) {
      rows.add(
        Expanded(
          child: Row(
            children: cells.sublist(
              i,
              i + 7 > cells.length ? cells.length : i + 7,
            ),
          ),
        ),
      );
    }

    return Expanded(child: Column(children: rows));
  }

  Widget _buildEventsList(
    BuildContext context,
    WidgetRef ref,
    String petId,
    DateTime date,
    CalendarListState state,
  ) {
    final events = state.events.where((e) => e.isOn(date)).toList();
    final today = DateFormat.yMMMEd().format(date);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: PawTableColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: PawTableColors.surfaceVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            today,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: PawTableColors.primaryDark,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          if (events.isEmpty)
            Text(
              'No events on this day',
              style: TextStyle(
                color: PawTableColors.onSurfaceVariant,
                fontStyle: FontStyle.italic,
              ),
            )
          else
            ...events.map((event) => _buildEventItem(context, event)),
        ],
      ),
    );
  }

  Widget _buildEventItem(BuildContext context, CalendarEvent event) {
    final color = _eventTypeColor(event.type);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 32,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.title,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                if (event.description != null)
                  Text(
                    event.description!,
                    style: TextStyle(
                      color: PawTableColors.onSurfaceVariant,
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          ),
          Icon(
            event.type.icon,
            size: 20,
            color: color,
          ),
        ],
      ),
    );
  }

  Color _eventTypeColor(CalendarEventType type) {
    switch (type.value) {
      case 'feeding':
        return PawTableColors.primary;
      case 'vaccination':
        return PawTableColors.successDark;
      case 'medication':
        return PawTableColors.infoDark;
      case 'weight':
        return PawTableColors.premiumDark;
      case 'behavior':
        return PawTableColors.warning;
      case 'vet_visit':
        return PawTableColors.error;
      default:
        return PawTableColors.onSurfaceVariant;
    }
  }

  void _showNotificationPreferences(BuildContext context, WidgetRef ref) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const NotificationPreferencesView(),
      ),
    );
  }

  void _showQuickAdd(BuildContext context, WidgetRef ref, String petId) {
    showDialog(
      context: context,
      builder: (_) => _QuickAddDialog(petId: petId),
    );
  }
}

/// Calendar day cell widget
class _CalendarDayCell extends StatelessWidget {
  final int day;
  final bool isToday;
  final bool isSelected;
  final int eventCount;
  final VoidCallback onTap;

  const _CalendarDayCell({
    required this.day,
    required this.isToday,
    required this.isSelected,
    required this.eventCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: isSelected
              ? PawTableColors.primary.withValues(alpha: 0.15)
              : isToday
                  ? PawTableColors.primary.withValues(alpha: 0.1)
                  : null,
          border: isSelected
              ? Border.all(color: PawTableColors.primary, width: 2)
              : isToday
                  ? Border.all(color: PawTableColors.primary, width: 1)
                  : null,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '$day',
              style: TextStyle(
                fontWeight: isToday || isSelected
                    ? FontWeight.bold
                    : FontWeight.normal,
                color: isSelected
                    ? PawTableColors.primaryDark
                    : PawTableColors.onBackground,
              ),
            ),
            if (eventCount > 0)
              SizedBox(
                width: 20,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(
                    eventCount > 3 ? 3 : eventCount,
                    (_) => Container(
                      margin: const EdgeInsets.symmetric(horizontal: 0.5),
                      width: 4,
                      height: 4,
                      decoration: const BoxDecoration(
                        color: PawTableColors.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Quick-add dialog for adding events from calendar
class _QuickAddDialog extends ConsumerWidget {
  final String petId;

  const _QuickAddDialog({required this.petId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final typeController = TextEditingController();
    final notesController = TextEditingController();

    return AlertDialog(
      title: const Text('Quick Add Event'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Event Type:'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: CalendarEventType.values
                  .map((type) => FilterChip(
                        label: Text(type.label),
                        selected: typeController.text == type.value,
                        onSelected: (_) =>
                            typeController.text = type.value,
                        backgroundColor: PawTableColors.surface,
                        selectedColor: PawTableColors.primary.withValues(alpha: 0.2),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: notesController,
              decoration: const InputDecoration(
                labelText: 'Notes (optional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            // TODO: Save event to database
            if (context.mounted) Navigator.of(context).pop();
          },
          child: const Text('Add'),
        ),
      ],
    );
  }
}

/// PawTable notification preferences view.
///
/// Allows users to manage notification settings, reminder types,
/// and permission status.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/colors.dart';
import '../providers/calendar_provider.dart';

/// Notification preferences screen
class NotificationPreferencesView extends ConsumerWidget {
  const NotificationPreferencesView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationState = ref.watch(notificationProvider);
    final notifier = ref.read(notificationProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Preferences'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Permission status
            _buildPermissionSection(context, notificationState, notifier),
            const Divider(height: 32),
            // Reminder types
            Text(
              'Reminder Types',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: PawTableColors.primaryDark,
              ),
            ),
            const SizedBox(height: 12),
            ..._buildReminderTypeTiles(context, notificationState, notifier),
            const Divider(height: 32),
            // Test notification
            _buildTestNotificationButton(context, notifier),
          ],
        ),
      ),
    );
  }

  Widget _buildPermissionSection(
    BuildContext context,
    NotificationState state,
    NotificationNotifier notifier,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: state.isGranted
            ? PawTableColors.success.withValues(alpha: 0.2)
            : PawTableColors.warning.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            state.isGranted
                ? Icons.notifications_active_rounded
                : Icons.notifications_off_rounded,
            color: state.isGranted
                ? PawTableColors.successDark
                : PawTableColors.warning,
            size: 32,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  state.isGranted ? 'Notifications Enabled' : 'Notifications Disabled',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  state.isGranted
                      ? 'You will receive reminders for feeding, medications, and vaccinations.'
                      : 'Enable notifications to receive important reminders.',
                  style: TextStyle(
                    fontSize: 13,
                    color: state.isGranted
                        ? PawTableColors.onBackground
                        : PawTableColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          if (!state.isGranted)
            ElevatedButton(
              onPressed: () => notifier.requestPermissions(),
              child: const Text('Enable'),
              style: ElevatedButton.styleFrom(
                backgroundColor: PawTableColors.primary,
              ),
            ),
        ],
      ),
    );
  }

  List<Widget> _buildReminderTypeTiles(
    BuildContext context,
    NotificationState state,
    NotificationNotifier notifier,
  ) {
    final reminderTypes = [
      ('feeding', 'Feeding Reminders', Icons.kitchen_rounded),
      ('medication', 'Medication Reminders', Icons.medication_liquid_rounded),
      ('vaccination', 'Vaccination Reminders', Icons.local_hospital_rounded),
      ('weight', 'Weight Check Reminders', Icons.scale_rounded),
    ];

    return reminderTypes.map((item) {
      final type = item.$1;
      final label = item.$2;
      final icon = item.$3;
      final isEnabled = state.reminderTypes.contains(type);

      return Card(
        margin: const EdgeInsets.only(bottom: 8),
        child: ListTile(
          leading: Icon(icon, color: PawTableColors.primary),
          title: Text(label),
          subtitle: Text(
            isEnabled
                ? 'Reminders are active'
                : 'Tap to enable reminders',
            style: TextStyle(
              fontSize: 12,
              color: PawTableColors.onSurfaceVariant,
            ),
          ),
          trailing: Switch(
            value: isEnabled,
            onChanged: (_) => notifier.toggleReminderType(type),
            activeColor: PawTableColors.primary,
          ),
        ),
      );
    }).toList();
  }

  Widget _buildTestNotificationButton(
    BuildContext context,
    NotificationNotifier notifier,
  ) {
    return Center(
      child: OutlinedButton.icon(
        onPressed: () {
          // TODO: Show test notification
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Test notification sent!')),
            );
          }
        },
        icon: const Icon(Icons.notification_add),
        label: const Text('Send Test Notification'),
      ),
    );
  }
}

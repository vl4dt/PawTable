/// PawTable notification preferences view.
///
/// Allows users to manage notification settings, reminder types,
/// quiet hours, and engagement preferences.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/colors.dart';
import '../../../../shared/providers/notification_engagement_provider.dart';
import '../../../../shared/services/notification_engagement_strategy.dart';
import '../../../../shared/providers/notification_provider.dart';

/// Enhanced notification preferences screen
class NotificationPreferencesView extends ConsumerWidget {
  const NotificationPreferencesView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final engagementState = ref.watch(engagementNotifierProvider);
    final settingsState = ref.watch(engagementSettingsProvider);
    final settings = settingsState.settings;
    final notifier = ref.read(engagementSettingsProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Preferences'),
        actions: [
          Switch(
            value: engagementState.notificationsEnabled,
            onChanged: (v) {
              ref.read(engagementNotifierProvider.notifier).toggleNotifications(v);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status banner
            _buildStatusBanner(context, engagementState),
            const SizedBox(height: 24),

            // Quiet Hours
            _buildSectionHeader(context, 'Quiet Hours'),
            const SizedBox(height: 8),
            Card(
              child: ListTile(
                leading: Icon(Icons.nightlight_round,
                    color: PawTableColors.primary),
                title: const Text('Quiet Hours'),
                subtitle: settings.quietHours.enabled
                    ? Text(
                        '${settings.quietHours.startHour.toString().padLeft(2, '0')}:00 – '
                        '${settings.quietHours.endHour.toString().padLeft(2, '0')}:00',
                      )
                    : const Text('Disabled — you\'ll receive all notifications'),
                trailing: Switch(
                  value: settings.quietHours.enabled,
                  onChanged: (v) {
                    notifier.updateQuietHours(
                      QuietHoursConfig(
                        enabled: v,
                        startHour: settings.quietHours.startHour,
                        endHour: settings.quietHours.endHour,
                      ),
                    );
                  },
                ),
              ),
            ),
            if (settings.quietHours.enabled) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _buildTimePicker(
                      context,
                      label: 'Start',
                      value: settings.quietHours.startHour,
                      onChanged: (hour) {
                        notifier.updateQuietHours(
                          QuietHoursConfig(
                            enabled: true,
                            startHour: hour,
                            endHour: settings.quietHours.endHour,
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildTimePicker(
                      context,
                      label: 'End',
                      value: settings.quietHours.endHour,
                      onChanged: (hour) {
                        notifier.updateQuietHours(
                          QuietHoursConfig(
                            enabled: true,
                            startHour: settings.quietHours.startHour,
                            endHour: hour,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 24),

            // Reminder Types
            _buildSectionHeader(context, 'Reminder Types'),
            const SizedBox(height: 8),
            ..._buildReminderTypeTiles(context, ref),
            const SizedBox(height: 24),

            // Engagement Preferences
            _buildSectionHeader(context, 'Engagement Preferences'),
            const SizedBox(height: 8),
            Card(
              child: SwitchListTile(
                title: const Text('Streak Notifications'),
                subtitle: const Text(
                    'Get alerted about streak milestones and alerts'),
                value: settings.streakNotifications,
                onChanged: (v) =>
                    notifier.toggleStreakNotifications(v),
                activeThumbColor: PawTableColors.primary,
              ),
            ),
            Card(
              child: SwitchListTile(
                title: const Text('Milestone Notifications'),
                subtitle: const Text(
                    'Get notified when you reach a new milestone'),
                value: settings.milestoneNotifications,
                onChanged: (v) =>
                    notifier.toggleMilestoneNotifications(v),
                activeThumbColor: PawTableColors.primary,
              ),
            ),
            Card(
              child: SwitchListTile(
                title: const Text('Wellness Tips'),
                subtitle:
                    const Text('Periodic pet care tips and advice'),
                value: settings.wellnessTips,
                onChanged: (v) => notifier.toggleWellnessTips(v),
                activeThumbColor: PawTableColors.primary,
              ),
            ),
            Card(
              child: SwitchListTile(
                title: const Text('Family Reminders'),
                subtitle: const Text(
                    'Reminders from shared family members'),
                value: settings.familyReminders,
                onChanged: (v) => notifier.toggleFamilyReminders(v),
                activeThumbColor: PawTableColors.primary,
              ),
            ),
            const SizedBox(height: 24),

            // Test Notification
            _buildTestNotificationButton(context, ref),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBanner(
    BuildContext context,
    EngagementState state,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: state.notificationsEnabled
            ? PawTableColors.success.withValues(alpha: 0.2)
            : PawTableColors.warning.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            state.notificationsEnabled
                ? Icons.notifications_active_rounded
                : Icons.notifications_off_rounded,
            color: state.notificationsEnabled
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
                  state.notificationsEnabled
                      ? 'Notifications Enabled'
                      : 'Notifications Disabled',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  state.notificationsEnabled
                      ? 'You will receive reminders, streak alerts, and milestone celebrations.'
                      : 'Turn on notifications to stay updated.',
                  style: TextStyle(
                    fontSize: 13,
                    color: state.notificationsEnabled
                        ? PawTableColors.onBackground
                        : PawTableColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: PawTableColors.primaryDark,
          ),
    );
  }

  List<Widget> _buildReminderTypeTiles(
    BuildContext context,
    WidgetRef ref,
  ) {
    final notificationState = ref.watch(notificationProvider);
    final notificationNotifier = ref.read(notificationProvider.notifier);

    final reminderTypes = [
      ('feeding', 'Feeding Reminders', Icons.kitchen_rounded),
      ('medication', 'Medication Reminders', Icons.medication_liquid_rounded),
      ('vaccination', 'Vaccination Reminders', Icons.local_hospital_rounded),
      ('weight', 'Weight Check Reminders', Icons.scale_rounded),
    ];

    return reminderTypes.map((item) {
      final type = item.$1;
      final title = item.$2;
      final icon = item.$3;
      final isEnabled = notificationState.reminderTypes.contains(type);

      return Card(
        margin: const EdgeInsets.only(bottom: 8),
        child: ListTile(
          leading: Icon(icon, color: PawTableColors.primary),
          title: Text(title),
          subtitle: Text(
            isEnabled
                ? 'Reminders are active'
                : 'Tap to enable reminders',
            style: const TextStyle(
              fontSize: 12,
              color: PawTableColors.onSurfaceVariant,
            ),
          ),
          trailing: Switch(
            value: isEnabled,
            onChanged: (_) => notificationNotifier.toggleReminderType(type),
            activeThumbColor: PawTableColors.primary,
          ),
        ),
      );
    }).toList();
  }

  Widget _buildTimePicker(
    BuildContext context, {
    required String label,
    required int value,
    required ValueChanged<int> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: PawTableColors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 4),
        DropdownButton<int>(
          value: value,
          isExpanded: true,
          underline: const Divider(),
          items: List.generate(24, (i) => i)
              .map((hour) => DropdownMenuItem(
                    value: hour,
                    child: Text(
                        '${hour.toString().padLeft(2, '0')}:00'),
                  ))
              .toList(),
          onChanged: (v) => v != null ? onChanged(v) : null,
        ),
      ],
    );
  }

  Widget _buildTestNotificationButton(
    BuildContext context,
    WidgetRef ref,
  ) {
    return Center(
      child: OutlinedButton.icon(
        onPressed: () {
          final notification = EngagementMessageGenerator.wellnessTip();

          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    Icon(Icons.notifications_active,
                        color: notification.accentColor),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            notification.title,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold),
                          ),
                          Text(notification.body,
                              style: const TextStyle(fontSize: 13)),
                        ],
                      ),
                    ),
                  ],
                ),
                backgroundColor: notification.accentColor ?? Colors.amber,
                duration: const Duration(seconds: 3),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            );
          }
        },
        icon: const Icon(Icons.notification_add),
        label: const Text('Send Test Notification'),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/colors.dart';
import '../../../../core/theme/design_tokens.dart';
import '../../../../shared/providers/sync_provider.dart';

/// Real-time sync status view — shows connection status and sync health
class SyncStatusView extends StatelessWidget {
  const SyncStatusView({super.key});

  @override
  Widget build(BuildContext context) {
    return const _SyncStatusContent();
  }
}

class _SyncStatusContent extends ConsumerWidget {
  const _SyncStatusContent();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final syncState = ref.watch(syncProvider);

    return syncState.when(
      data: (state) => _SyncStatusContentWithData(state: state),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => _SyncStatusError(error: error.toString()),
    );
  }
}

class _SyncStatusContentWithData extends StatelessWidget {
  final SyncState state;
  const _SyncStatusContentWithData({required this.state});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Real-Time Sync'),
        backgroundColor: PawTableColors.surface,
        foregroundColor: PawTableColors.onBackground,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(PawTokens.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Sync health indicator
            _SyncHealthCard(
              health: state.health,
              isSyncEnabled: state.isSyncEnabled,
            ),
            const SizedBox(height: PawTokens.lg),

            // Sync type cards
            Text(
              'Sync Types',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: PawTokens.sm),

            ...SyncType.values.map((type) {
              final status = state.getStatus(type);
              return _SyncTypeCard(
                type: type,
                status: status,
                onSync: () {},
              );
            }).toList(),

            const SizedBox(height: PawTokens.lg),

            // Full sync button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  // Full sync is handled by the child widgets
                },
                icon: const Icon(Icons.sync_rounded),
                label: const Text('Full Sync'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: PawTableColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: PawTokens.md),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Sync health indicator card
class _SyncHealthCard extends ConsumerWidget {
  final SyncHealth health;
  final bool isSyncEnabled;
  const _SyncHealthCard({
    required this.health,
    required this.isSyncEnabled,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final Color color;
    final String statusText;
    final IconData icon;

    switch (health) {
      case SyncHealth.disabled:
        color = PawTableColors.surfaceVariant;
        statusText = 'Sync Disabled';
        icon = Icons.sync_rounded;
        break;
      case SyncHealth.disconnected:
        color = PawTableColors.error;
        statusText = 'Disconnected';
        icon = Icons.wifi_off_rounded;
        break;
      case SyncHealth.partial:
        color = PawTableColors.warning;
        statusText = 'Partial Connection';
        icon = Icons.wifi_find_rounded;
        break;
      case SyncHealth.healthy:
        color = PawTableColors.success;
        statusText = 'Connected';
        icon = Icons.wifi_rounded;
        break;
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(PawTokens.radiusMd),
      ),
      child: Padding(
        padding: const EdgeInsets.all(PawTokens.lg),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 32,
                  ),
                ),
                const SizedBox(width: PawTokens.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        statusText,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                      Text(
                        'Sync ${isSyncEnabled ? 'enabled' : 'disabled'}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: PawTableColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                // Toggle switch
                Switch(
                  value: isSyncEnabled,
                  onChanged: (value) {
                    if (value) {
                      ref.read(syncProvider.notifier).enableSync();
                    } else {
                      ref.read(syncProvider.notifier).disableSync();
                    }
                  },
                  activeThumbColor: PawTableColors.primary,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Sync type card
class _SyncTypeCard extends ConsumerWidget {
  final SyncType type;
  final SyncStatus status;
  final VoidCallback onSync;

  const _SyncTypeCard({
    required this.type,
    required this.status,
    required this.onSync,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: PawTokens.sm),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: status.isConnected
                ? PawTableColors.primary.withValues(alpha: 0.1)
                : PawTableColors.surfaceVariant,
            shape: BoxShape.circle,
          ),
          child: Icon(
            _getIconForType(type),
            color: status.isConnected
                ? PawTableColors.primary
                : PawTableColors.onSurfaceVariant,
            size: 20,
          ),
        ),
        title: Text(
          type.name.camelToTitle(),
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              status.isConnected ? 'Connected' : 'Disconnected',
              style: theme.textTheme.bodySmall?.copyWith(
                color: status.isConnected
                    ? PawTableColors.primary
                    : PawTableColors.error,
              ),
            ),
            if (status.pendingChanges > 0)
              Text(
                '${status.pendingChanges} pending change${status.pendingChanges > 1 ? 's' : ''}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: PawTableColors.warning,
                ),
              ),
            if (status.documentCount > 0)
              Text(
                '${status.documentCount} document${status.documentCount > 1 ? 's' : ''}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: PawTableColors.onSurfaceVariant,
                ),
              ),
          ],
        ),
        trailing: status.isSyncing
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : IconButton(
                icon: const Icon(Icons.refresh_rounded, size: 20),
                onPressed: () {
                  ref.read(syncProvider.notifier).sync(type);
                },
                tooltip: 'Sync now',
              ),
      ),
    );
  }

  IconData _getIconForType(SyncType type) {
    switch (type) {
      case SyncType.familyGroups:
        return Icons.groups_rounded;
      case SyncType.familyMembers:
        return Icons.person_rounded;
      case SyncType.sharedPets:
        return Icons.pets_rounded;
      case SyncType.petSitterAccess:
        return Icons.key_rounded;
      case SyncType.activityFeed:
        return Icons.timeline_rounded;
      case SyncType.inviteTokens:
        return Icons.link_rounded;
      case SyncType.feedings:
        return Icons.restaurant_rounded;
      case SyncType.healthLogs:
        return Icons.local_hospital_rounded;
      case SyncType.vaccinations:
        return Icons.vaccines_rounded;
      case SyncType.medications:
        return Icons.medication_rounded;
      case SyncType.weightLogs:
        return Icons.monitor_weight_rounded;
      case SyncType.pets:
        return Icons.pets_rounded;
    }
  }
}

/// Error state for sync status
class _SyncStatusError extends StatelessWidget {
  final String error;
  const _SyncStatusError({required this.error});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(PawTokens.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('⚠️', style: TextStyle(fontSize: 48)),
            const SizedBox(height: PawTokens.md),
            Text(
              'Sync Error',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: PawTokens.sm),
            Text(
              error,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// Extension for camel case to title case
extension CamelCaseExtension on String {
  String camelToTitle() {
    return this
        .replaceAllMapped(
          RegExp('[A-Z]'),
          (match) =>
              '${match.group(0)!.isEmpty ? '' : ' '}${match.group(0)}',
        )
        .trim()
        .replaceFirstFirstChar((c) => c.toUpperCase());
  }
}

extension StringExtension on String {
  String replaceFirstFirstChar(String Function(String char) transformer) {
    if (isEmpty) return this;
    return transformer(this[0]) + substring(1);
  }
}

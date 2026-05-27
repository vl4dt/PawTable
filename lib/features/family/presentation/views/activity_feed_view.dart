import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/colors.dart';
import '../../../../core/theme/design_tokens.dart';
import '../../../../core/storage/database_helper.dart';
import '../../domain/entities/activity_feed_entity.dart';
import '../providers/activity_feed_provider.dart';

/// Activity feed view — displays a chronological stream of all family activities
class ActivityFeedView extends ConsumerStatefulWidget {
  final String groupId;
  final String? currentUserId;
  final String? currentUserName;

  const ActivityFeedView({
    super.key,
    required this.groupId,
    this.currentUserId,
    this.currentUserName,
  });

  @override
  ConsumerState<ActivityFeedView> createState() => _ActivityFeedViewState();
}

class _ActivityFeedViewState extends ConsumerState<ActivityFeedView> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(activityFeedProvider.notifier)
          .loadFeed(widget.groupId, refresh: true);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.8) {
      ref.read(activityFeedProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(activityFeedProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Activity Feed'),
        backgroundColor: PawTableColors.surface,
        foregroundColor: PawTableColors.onBackground,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => ref
                .read(activityFeedProvider.notifier)
                .loadFeed(widget.groupId, refresh: true),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: state.isLoading && state.entries.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : state.error != null
              ? _ErrorState(error: state.error!)
              : _ActivityFeedContent(
                  state: state,
                  groupId: widget.groupId,
                  currentUserId: widget.currentUserId,
                  onScroll: _onScroll,
                  scrollController: _scrollController,
                ),
    );
  }
}

/// Main activity feed content
class _ActivityFeedContent extends ConsumerWidget {
  final ActivityFeedState state;
  final String groupId;
  final String? currentUserId;
  final VoidCallback onScroll;
  final ScrollController scrollController;

  const _ActivityFeedContent({
    required this.state,
    required this.groupId,
    required this.currentUserId,
    required this.onScroll,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        // Summary bar
        if (state.summary != null) _SummaryBar(summary: state.summary!),

        // Activity entries
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async {
              await ref
                  .read(activityFeedProvider.notifier)
                  .loadFeed(groupId, refresh: true);
            },
            child: ListView.builder(
              controller: scrollController,
              padding: const EdgeInsets.all(PawTokens.md),
              itemCount: state.entries.length + (state.hasMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index >= state.entries.length) {
                  return _LoadingMore();
                }
                final entry = state.entries[index];
                return _ActivityFeedItem(entry: entry);
              },
            ),
          ),
        ),
      ],
    );
  }
}

/// Summary bar showing activity statistics
class _SummaryBar extends StatelessWidget {
  final ActivityFeedSummary summary;
  const _SummaryBar({required this.summary});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.all(PawTokens.md),
      padding: const EdgeInsets.all(PawTokens.md),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            PawTableColors.primary.withValues(alpha: 0.15),
            PawTableColors.primary.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(PawTokens.radiusLg),
        border: Border.all(color: PawTableColors.primary.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _StatItem(
            value: summary.entriesToday.toString(),
            label: 'Today',
            icon: Icons.today_rounded,
          ),
          _StatItem(
            value: summary.entriesThisWeek.toString(),
            label: 'This Week',
            icon: Icons.date_range_rounded,
          ),
          _StatItem(
            value: summary.entriesThisMonth.toString(),
            label: 'This Month',
            icon: Icons.calendar_today_rounded,
          ),
          _StatItem(
            value: summary.totalEntries.toString(),
            label: 'Total',
            icon: Icons.analytics_rounded,
          ),
        ],
      ),
    );
  }
}

/// Individual stat item
class _StatItem extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  const _StatItem({
    required this.value,
    required this.label,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Icon(icon, color: PawTableColors.primary, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: PawTableColors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

/// Activity feed item
class _ActivityFeedItem extends StatelessWidget {
  final ActivityFeedEntry entry;
  const _ActivityFeedItem({required this.entry});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: PawTokens.sm),
      padding: const EdgeInsets.all(PawTokens.md),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(PawTokens.radiusLg),
        boxShadow: PawTokens.shadow1,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _getIconColor().withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(
                _getIcon(),
                color: _getIconColor(),
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: PawTokens.md),
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header row
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        entry.userName,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Text(
                      entry.relativeTime,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: PawTableColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                // Title
                Text(
                  entry.title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (entry.description.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    entry.description,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: PawTableColors.onSurfaceVariant,
                    ),
                  ),
                ],
                const SizedBox(height: 4),
                // Pet name badge
                if (entry.petName.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: PawTokens.sm,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: PawTableColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(PawTokens.radiusSm),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.pets_rounded,
                          size: 12,
                          color: PawTableColors.primary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          entry.petName,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: PawTableColors.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIcon() {
    switch (entry.type) {
      case ActivityFeedType.feeding:
        return Icons.pets_rounded;
      case ActivityFeedType.vaccination:
        return Icons.medical_services_rounded;
      case ActivityFeedType.medication:
        return Icons.medication_rounded;
      case ActivityFeedType.weight:
        return Icons.monitor_weight_rounded;
      case ActivityFeedType.behavior:
        return Icons.emoji_emotions_rounded;
      case ActivityFeedType.memberJoined:
        return Icons.person_add_rounded;
      case ActivityFeedType.memberLeft:
        return Icons.person_remove_rounded;
      case ActivityFeedType.memberPromoted:
        return Icons.arrow_upward_rounded;
      case ActivityFeedType.memberDemoted:
        return Icons.arrow_downward_rounded;
      case ActivityFeedType.petShared:
        return Icons.share_rounded;
      case ActivityFeedType.petUnshared:
        return Icons.link_off_rounded;
      case ActivityFeedType.inviteCreated:
        return Icons.link_rounded;
      case ActivityFeedType.inviteAccepted:
        return Icons.check_circle_rounded;
      case ActivityFeedType.inviteExpired:
        return Icons.schedule_rounded;
      case ActivityFeedType.inviteCancelled:
        return Icons.cancel_rounded;
      case ActivityFeedType.groupCreated:
        return Icons.group_add_rounded;
      case ActivityFeedType.groupUpdated:
        return Icons.edit_rounded;
      case ActivityFeedType.streakMaintained:
        return Icons.local_fire_department_rounded;
      case ActivityFeedType.milestoneAchieved:
        return Icons.emoji_events_rounded;
      case ActivityFeedType.achievementUnlocked:
        return Icons.workspace_premium_rounded;
      case ActivityFeedType.custom:
        return Icons.note_rounded;
    }
  }

  Color _getIconColor() {
    switch (entry.type) {
      case ActivityFeedType.feeding:
        return PawTableColors.successDark;
      case ActivityFeedType.vaccination:
        return PawTableColors.info;
      case ActivityFeedType.medication:
        return PawTableColors.info;
      case ActivityFeedType.weight:
        return PawTableColors.primary;
      case ActivityFeedType.behavior:
        return PawTableColors.warning;
      case ActivityFeedType.memberJoined:
      case ActivityFeedType.memberPromoted:
      case ActivityFeedType.inviteAccepted:
      case ActivityFeedType.groupCreated:
      case ActivityFeedType.streakMaintained:
      case ActivityFeedType.milestoneAchieved:
      case ActivityFeedType.achievementUnlocked:
        return PawTableColors.successDark;
      case ActivityFeedType.memberLeft:
      case ActivityFeedType.memberDemoted:
      case ActivityFeedType.inviteExpired:
      case ActivityFeedType.inviteCancelled:
      case ActivityFeedType.petUnshared:
        return PawTableColors.error;
      case ActivityFeedType.petShared:
      case ActivityFeedType.inviteCreated:
      case ActivityFeedType.groupUpdated:
        return PawTableColors.primary;
      case ActivityFeedType.custom:
        return PawTableColors.onSurfaceVariant;
    }
  }
}

/// Loading more indicator
class _LoadingMore extends StatelessWidget {
  const _LoadingMore();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(PawTokens.md),
      child: Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
    );
  }
}

/// Error state
class _ErrorState extends StatelessWidget {
  final String error;
  const _ErrorState({required this.error});

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
              'Failed to load activity feed',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
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

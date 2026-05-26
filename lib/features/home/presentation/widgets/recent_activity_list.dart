import 'package:flutter/material.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/utils/date_utils.dart' as app_date;

/// Recent activity list — shows latest logging entries
///
/// Aggregates feeding, medication, health, and weight entries
/// into a unified timeline.
class RecentActivityList extends StatelessWidget {
  const RecentActivityList({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(
                  Icons.history,
                  color: PawTableColors.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Recent Activity',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.chevron_right, size: 20),
                  onPressed: () {
                    // TODO: Navigate to full calendar view
                  },
                ),
              ],
            ),
            const Divider(height: 24),
            // Activity items
            _buildActivityItems(context),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityItems(BuildContext context) {
    // Placeholder data — will be replaced with real data from providers
    final sampleActivities = [
      _ActivityEntry(
        icon: Icons.restaurant,
        iconColor: PawTableColors.primary,
        title: 'Fed Whiskers',
        subtitle: 'Morning meal — 1/2 cup dry food',
        time: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      _ActivityEntry(
        icon: Icons.medication,
        iconColor: PawTableColors.info,
        title: 'Medication given',
        subtitle: 'Heartworm prevention — 1 tablet',
        time: DateTime.now().subtract(const Duration(hours: 24)),
      ),
      _ActivityEntry(
        icon: Icons.trending_up,
        iconColor: PawTableColors.success,
        title: 'Weight recorded',
        subtitle: '4.2 kg (was 4.1 kg)',
        time: DateTime.now().subtract(const Duration(days: 2)),
      ),
      _ActivityEntry(
        icon: Icons.favorite,
        iconColor: PawTableColors.error,
        title: 'Health check',
        subtitle: 'Energy level: Good • Mood: Happy',
        time: DateTime.now().subtract(const Duration(days: 3)),
      ),
    ];

    return Column(
      children: sampleActivities.map((activity) {
        final index = sampleActivities.indexOf(activity);
        return Column(
          children: [
            _ActivityTile(activity: activity),
            if (index < sampleActivities.length - 1)
              const Padding(
                padding: EdgeInsets.only(left: 44),
                child: Divider(height: 24),
              ),
          ],
        );
      }).toList(),
    );
  }
}

/// Individual activity entry
class _ActivityEntry {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final DateTime time;

  const _ActivityEntry({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.time,
  });
}

/// Activity tile widget
class _ActivityTile extends StatelessWidget {
  final _ActivityEntry activity;
  const _ActivityTile({required this.activity});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          // Icon circle
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: activity.iconColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(activity.icon, size: 20, color: activity.iconColor),
          ),
          const SizedBox(width: 12),
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity.title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                Text(
                  activity.subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
              ],
            ),
          ),
          // Time
          Text(
            _formatTime(activity.time),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[500],
                ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    }
    if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    }
    if (diff.inDays < 7) {
      return '${diff.inDays}d ago';
    }
    return app_date.DateUtils.formatShortDate(time);
  }
}

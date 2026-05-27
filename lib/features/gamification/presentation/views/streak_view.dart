import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/colors.dart';
import '../../../../core/theme/design_tokens.dart';
import '../../domain/entities/streak_entity.dart';
import '../providers/streak_provider.dart';

/// Streak tracking view — main gamification screen
///
/// Shows: current streak, calendar heatmap, activity log buttons, stats
class StreakView extends ConsumerWidget {
  final String petId;

  const StreakView({super.key, required this.petId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(streakSummaryProvider);

    // Auto-load streak data for this pet
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (state.summary == null && state.error == null) {
        ref.read(streakSummaryProvider.notifier).loadSummary(petId);
      }
    });

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App bar
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: PawTableColors.primary,
            foregroundColor: PawTableColors.onPrimary,
            title: const Text(
              'Streaks',
              style: TextStyle(
                color: PawTableColors.onPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: _StreakHeroWidget(petId: petId),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.info_outline),
                onPressed: () => _showStreakInfo(context),
              ),
            ],
          ),

          // Content
          SliverToBoxAdapter(
            child: state.isLoading
                ? const _LoadingSkeleton()
                : state.error != null
                    ? _ErrorState(error: state.error!)
                    : _StreakContent(
                        petId: petId,
                        summary: state.summary!,
                        calendarData: state.calendarData,
                      ),
          ),
        ],
      ),
    );
  }

  void _showStreakInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('How Streaks Work'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '🔥 Build streaks by logging activities for your pet every day!',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 12),
              Text(
                'Activities that count toward a streak:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('• Feeding meals & water intake'),
              Text('• Medication administration'),
              Text('• Vaccination records'),
              Text('• Weight checks'),
              Text('• Behavior & mood logging'),
              SizedBox(height: 16),
              Text(
                'Streaks reset if you miss a day. Log something every day to keep the fire burning!',
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Got it!'),
          ),
        ],
      ),
    );
  }
}

/// Hero widget for the streak view — animated fire + streak count
class _StreakHeroWidget extends ConsumerWidget {
  final String petId;
  const _StreakHeroWidget({required this.petId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(streakSummaryProvider);
    final summary = state.summary;

    if (summary == null) {
      return const SizedBox.shrink();
    }

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            PawTableColors.primary.withValues(alpha: 0.6),
            PawTableColors.primaryDark.withValues(alpha: 0.8),
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedCrossFade(
              firstChild: const _FireAnimation(),
              secondChild: const _FlameEmoji(size: 80),
              crossFadeState: summary.currentStreak >= 3
                  ? CrossFadeState.showFirst
                  : CrossFadeState.showSecond,
              duration: PawTokens.durationQuick,
            ),
            const SizedBox(height: 8),
            Text(
              '${summary.currentStreak}',
              style: const TextStyle(
                fontSize: 56,
                fontWeight: FontWeight.bold,
                color: PawTableColors.onPrimary,
                shadows: [
                  Shadow(
                    color: Colors.black26,
                    blurRadius: 8,
                  ),
                ],
              ),
            ),
            Text(
              summary.currentStreak >= 3
                  ? 'Day Streak!'
                  : summary.currentStreak == 1
                      ? 'Day Streak!'
                      : 'No streak yet',
              style: TextStyle(
                fontSize: 18,
                color: PawTableColors.onPrimary.withValues(alpha: 0.9),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Animated fire widget — for streaks >= 3
class _FireAnimation extends ConsumerStatefulWidget {
  const _FireAnimation();

  @override
  ConsumerState<_FireAnimation> createState() => _FireAnimationState();
}

class _FireAnimationState extends ConsumerState<_FireAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
      reverseDuration: const Duration(milliseconds: 400),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 80,
      height: 80,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer glow
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Transform.scale(
                scale: 1.0 + _controller.value * 0.15,
                child: Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        PawTableColors.warning.withValues(alpha: 0.4),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          // Inner fire
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Transform.scale(
                scale: 0.85 + _controller.value * 0.15,
                child: const Text(
                  '🔥',
                  style: TextStyle(fontSize: 60),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

/// Simple flame emoji — for streaks < 3
class _FlameEmoji extends StatelessWidget {
  final double size;
  const _FlameEmoji({required this.size});

  @override
  Widget build(BuildContext context) {
    return Text(
      '🔥',
      style: TextStyle(fontSize: size),
    );
  }
}

/// Loading skeleton for streak view
class _LoadingSkeleton extends StatelessWidget {
  const _LoadingSkeleton();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(PawTokens.md),
      child: Column(
        children: [
          // Streak count skeleton
          Container(
            height: 60,
            width: 100,
            decoration: BoxDecoration(
              color: PawTableColors.surfaceVariant,
              borderRadius: BorderRadius.circular(PawTokens.radiusMd),
            ),
          ),
          const SizedBox(height: PawTokens.lg),
          // Calendar skeleton
          _CalendarSkeleton(),
          const SizedBox(height: PawTokens.lg),
          // Activity buttons skeleton
          Wrap(
            spacing: PawTokens.sm,
            runSpacing: PawTokens.sm,
            children: List.generate(
              6,
              (_) => Container(
                height: 50,
                width: 100,
                decoration: BoxDecoration(
                  color: PawTableColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(PawTokens.radiusMd),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CalendarSkeleton extends StatelessWidget {
  const _CalendarSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(PawTokens.sm),
      decoration: BoxDecoration(
        color: PawTableColors.surfaceVariant,
        borderRadius: BorderRadius.circular(PawTokens.radiusLg),
      ),
      child: Column(
        children: List.generate(6, (_) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(7, (_) {
                return Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: PawTableColors.surface,
                    borderRadius: BorderRadius.circular(PawTokens.radiusSm),
                  ),
                );
              }),
            ),
          );
        }),
      ),
    );
  }
}

/// Error state for streak view
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
              'Failed to load streak data',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: PawTokens.sm),
            Text(
              error,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: PawTokens.md),
            ElevatedButton(
              onPressed: () {
                // Will be reloaded on next frame
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Main content widget after loading
class _StreakContent extends StatelessWidget {
  final String petId;
  final StreakSummary summary;
  final Map<String, List<StreakActivityType>> calendarData;

  const _StreakContent({
    required this.petId,
    required this.summary,
    required this.calendarData,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(PawTokens.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Milestone progress card
          _MilestoneProgressCard(summary: summary),
          const SizedBox(height: PawTokens.md),

          // Calendar heatmap
          Text(
            'Activity Calendar',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: PawTokens.sm),
          _CalendarHeatmap(
            calendarData: calendarData,
            petId: petId,
          ),
          const SizedBox(height: PawTokens.lg),

          // Activity log buttons
          Text(
            "Log Today's Activity",
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: PawTokens.sm),
          _ActivityLogButtons(petId: petId, calendarData: calendarData),
          const SizedBox(height: PawTokens.lg),

          // Stats grid
          _StatsGrid(summary: summary),
          const SizedBox(height: PawTokens.md),
        ],
      ),
    );
  }
}

/// Milestone progress card
class _MilestoneProgressCard extends StatelessWidget {
  final StreakSummary summary;
  const _MilestoneProgressCard({required this.summary});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final nextMilestone = _getNextMilestone(summary.currentStreak);
    final progress = summary.progressToNextMilestone();

    return Container(
      padding: const EdgeInsets.all(PawTokens.md),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(PawTokens.radiusLg),
        boxShadow: PawTokens.shadow1,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Next Milestone',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: PawTableColors.onSurfaceVariant,
                ),
              ),
              Text(
                '$nextMilestone days',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: PawTableColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: PawTokens.sm),
          LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
            backgroundColor: PawTableColors.surfaceVariant,
            valueColor: const AlwaysStoppedAnimation<Color>(PawTableColors.primary),
          ),
          const SizedBox(height: PawTokens.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                summary.streakDescription,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: PawTableColors.onSurfaceMuted,
                ),
              ),
              if (summary.longestStreak > 0)
                Text(
                  'Best: ${summary.longestStreak} days',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: PawTableColors.successDark,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  int _getNextMilestone(int currentStreak) {
    const milestones = [7, 14, 21, 30, 60, 90, 180, 365];
    for (final m in milestones) {
      if (currentStreak < m) return m;
    }
    return 365;
  }
}

/// Calendar heatmap — month view with colored dots for activity
class _CalendarHeatmap extends ConsumerWidget {
  final Map<String, List<StreakActivityType>> calendarData;
  final String petId;
  const _CalendarHeatmap({
    required this.calendarData,
    required this.petId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Build the 30-day history
    final history = ref
        .read(streakSummaryProvider.notifier)
        .get30DayHistory();

    // Group by week for display
    final weeks = <List<Map<String, dynamic>>>[];
    List<Map<String, dynamic>> currentWeek = [];

    for (int i = 0; i < history.length; i++) {
      final item = history[i];
      final dayOfWeek = DateTime.parse(item['date'] as String).weekday;

      // Start new week on Monday
      if (currentWeek.isEmpty && dayOfWeek != DateTime.monday) {
        // Pad with empty cells
        for (int d = DateTime.monday; d < dayOfWeek; d++) {
          currentWeek.add({
            'date': '',
            'activities': <StreakActivityType>[],
            'isActive': false,
            'activityCount': 0,
            'isToday': false,
            'isFuture': false,
          });
        }
      }

      currentWeek.add(item);

      if (dayOfWeek == DateTime.sunday || i == history.length - 1) {
        weeks.add(currentWeek);
        currentWeek = [];
      }
    }

    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(PawTokens.sm),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(PawTokens.radiusLg),
        boxShadow: PawTokens.shadow1,
      ),
      child: Column(
        children: [
          // Day headers
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: const ['M', 'T', 'W', 'T', 'F', 'S', 'S']
                .map((d) => Expanded(
                      child: Center(
                        child: Text(
                          d,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: PawTableColors.onSurfaceMuted,
                          ),
                        ),
                      ),
                    ))
                .toList(),
          ),
          const Divider(height: PawTokens.sm),
          ...weeks.map((week) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: week.map((day) {
                    final isActive = day['isActive'] as bool;
                    final isToday = day['isToday'] as bool;

                    return Expanded(
                      child: Center(
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: isActive
                                ? PawTableColors.primary
                                : isToday
                                    ? PawTableColors.primary.withValues(alpha: 0.2)
                                    : Colors.transparent,
                            borderRadius: BorderRadius.circular(PawTokens.radiusSm),
                            border: isToday && !isActive
                                ? Border.all(
                                    color: PawTableColors.primary,
                                    width: 1.5,
                                  )
                                : null,
                          ),
                          child: isActive
                              ? _ActivityIndicator(
                                  activities: day['activities'] as List<StreakActivityType>,
                                )
                              : null,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              )),
        ],
      ),
    );
  }
}

/// Colorful indicator for activity on a calendar day
class _ActivityIndicator extends StatelessWidget {
  final List<StreakActivityType> activities;
  const _ActivityIndicator({required this.activities});

  @override
  Widget build(BuildContext context) {
    // Show colored dot(s) based on activity count
    if (activities.length == 1) {
      return Container(
        width: 12,
        height: 12,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: _getActivityColor(activities.first),
        ),
      );
    }
    // Multiple activities — show dots
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: activities.take(3).map((a) {
        return Padding(
          padding: const EdgeInsets.only(right: 2),
          child: Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _getActivityColor(a),
            ),
          ),
        );
      }).toList(),
    );
  }

  Color _getActivityColor(StreakActivityType type) {
    switch (type) {
      case StreakActivityType.feeding:
        return PawTableColors.primary;
      case StreakActivityType.medication:
        return PawTableColors.premiumDark;
      case StreakActivityType.vaccination:
        return PawTableColors.successDark;
      case StreakActivityType.weight:
        return PawTableColors.infoDark;
      case StreakActivityType.behavior:
        return PawTableColors.warning;
      case StreakActivityType.water:
        return PawTableColors.info;
    }
  }
}

/// Activity log buttons — tap to log an activity for today
class _ActivityLogButtons extends ConsumerWidget {
  final String petId;
  final Map<String, List<StreakActivityType>> calendarData;
  const _ActivityLogButtons({
    required this.petId,
    required this.calendarData,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activities = StreakActivityType.values;

    return Wrap(
      spacing: PawTokens.sm,
      runSpacing: PawTokens.sm,
      children: activities.map((type) {
        final today = DateTime.now();
        final dateStr =
            '${today.year.toString().padLeft(4, '0')}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
        final isLogged = calendarData.containsKey(dateStr) &&
            (calendarData[dateStr]?.contains(type) ?? false);

        return _ActivityLogButton(
          activityType: type,
          isLogged: isLogged,
          onTap: () {
            ref
                .read(streakSummaryProvider.notifier)
                .logActivity(petId, type);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${type.label} logged for today!'),
                backgroundColor: PawTableColors.successDark,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(PawTokens.radiusMd)),
              ),
            );
          },
        );
      }).toList(),
    );
  }
}

/// Individual activity log button
class _ActivityLogButton extends StatelessWidget {
  final StreakActivityType activityType;
  final bool isLogged;
  final VoidCallback onTap;
  const _ActivityLogButton({
    required this.activityType,
    required this.isLogged,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: isLogged
          ? PawTableColors.success
          : PawTableColors.primary.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(PawTokens.radiusMd),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(PawTokens.radiusMd),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: PawTokens.md,
            vertical: PawTokens.sm,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                activityType.code == 0
                    ? Icons.restaurant_rounded
                    : activityType.code == 1
                        ? Icons.medication_rounded
                        : activityType.code == 2
                            ? Icons.shield_rounded
                            : activityType.code == 3
                                ? Icons.trending_up_rounded
                                : activityType.code == 4
                                    ? Icons.pets_rounded
                                    : Icons.water_drop_rounded,
                color: isLogged
                    ? PawTableColors.successDark
                    : PawTableColors.primary,
                size: 20,
              ),
              const SizedBox(width: PawTokens.sm),
              Text(
                activityType.label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isLogged
                      ? PawTableColors.successDark
                      : PawTableColors.primary,
                  fontWeight: isLogged ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
              if (isLogged) ...[
                const SizedBox(width: PawTokens.sm),
                const Icon(Icons.check_circle, size: 16, color: PawTableColors.successDark),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Stats grid — shows longest streak, total active days, etc.
class _StatsGrid extends StatelessWidget {
  final StreakSummary summary;
  const _StatsGrid({required this.summary});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(PawTokens.md),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(PawTokens.radiusLg),
        boxShadow: PawTokens.shadow1,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Statistics',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: PawTokens.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _StatItem(
                icon: Icons.local_fire_department,
                label: 'Longest Streak',
                value: '${summary.longestStreak} days',
                color: PawTableColors.primaryDark,
              ),
              _StatItem(
                icon: Icons.calendar_today,
                label: 'Total Active',
                value: '${summary.totalActiveDays} days',
                color: PawTableColors.successDark,
              ),
              if (summary.firstActiveDate != null)
                _StatItem(
                  icon: Icons.flag,
                  label: 'Started',
                  value: _formatDate(summary.firstActiveDate!),
                  color: PawTableColors.infoDark,
                ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }
}

/// Single stat item in the grid
class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}

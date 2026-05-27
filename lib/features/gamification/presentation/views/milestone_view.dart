import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/colors.dart';
import '../../../../core/theme/design_tokens.dart';
import '../../domain/entities/milestone_entity.dart';
import '../providers/milestone_provider.dart';

/// Milestone achievements view — badges, progress bars, unlock tracker
///
/// Shows all milestones as a grid/list of cards with:
/// - Badge icon (mapped from iconCode in domain)
/// - Title and description
/// - Progress bar toward next milestone
/// - Unlocked/locked state
class MilestoneView extends ConsumerWidget {
  final String petId;

  const MilestoneView({super.key, required this.petId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(milestoneProvider);

    // Auto-load milestone data for this pet
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (state.summary == null && state.error == null) {
        ref.read(milestoneProvider.notifier).loadMilestones(petId);
      }
    });

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App bar with gradient
          SliverAppBar(
            expandedHeight: 160,
            pinned: true,
            backgroundColor: PawTableColors.premiumDark,
            foregroundColor: PawTableColors.onPrimary,
            title: const Text(
              'Achievements',
              style: TextStyle(
                color: PawTableColors.onPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: _MilestoneHeroWidget(petId: petId),
            ),
          ),

          // Content
          if (state.isLoading)
            const SliverToBoxAdapter(child: _LoadingSkeleton())
          else if (state.error != null)
            SliverToBoxAdapter(child: _ErrorState(error: state.error!))
          else if (state.summary != null)
            SliverPadding(
              padding: const EdgeInsets.all(PawTokens.md),
              sliver: _MilestoneContent(
                petId: petId,
                summary: state.summary!,
                definitions: state.definitions,
              ),
            )
          else
            const SliverToBoxAdapter(
              child: _EmptyMilestoneState(),
            ),
        ],
      ),
    );
  }
}

/// Hero widget — overall milestone progress
class _MilestoneHeroWidget extends ConsumerWidget {
  final String petId;
  const _MilestoneHeroWidget({required this.petId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(milestoneProvider);
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
            PawTableColors.premiumDark.withValues(alpha: 0.7),
            PawTableColors.premiumDark.withValues(alpha: 0.95),
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${summary.totalUnlocked}/${summary.totalPossible}',
              style: const TextStyle(
                fontSize: 48,
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
            const SizedBox(height: 4),
            Text(
              'Milestones Earned',
              style: TextStyle(
                fontSize: 16,
                color: PawTableColors.onPrimary.withValues(alpha: 0.9),
              ),
            ),
            const SizedBox(height: 12),
            // Progress bar
            Container(
              width: 200,
              child: LinearProgressIndicator(
                value: summary.unlockRate,
                minHeight: 6,
                borderRadius: BorderRadius.circular(3),
                backgroundColor: PawTableColors.onPrimary.withValues(alpha: 0.2),
                valueColor: const AlwaysStoppedAnimation<Color>(PawTableColors.warning),
              ),
            ),
            if (summary.bestStreak > 0) ...[
              const SizedBox(height: 8),
              Text(
                'Best streak: ${summary.bestStreak} days',
                style: TextStyle(
                  fontSize: 14,
                  color: PawTableColors.warning.withValues(alpha: 0.9),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Main milestone content — overview + individual badges
class _MilestoneContent extends StatelessWidget {
  final String petId;
  final MilestoneSummary summary;
  final List<MilestoneDefinition> definitions;

  const _MilestoneContent({
    required this.petId,
    required this.summary,
    required this.definitions,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final achievements = summary.achievements;

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          if (index == 0) {
            // Overall stats card
            return _OverallStatsCard(summary: summary, definitions: definitions);
          }
          // Individual milestone badges (index - 1 to skip stats card)
          final defIndex = index - 1;
          if (defIndex >= definitions.length) return null;

          final definition = definitions[defIndex];
          final achievement = achievements
              .where((a) => a.milestoneId == definition.id)
              .firstOrNull;

          return _MilestoneBadgeCard(
            petId: petId,
            definition: definition,
            achievement: achievement,
          );
        },
        childCount: 1 + definitions.length,
      ),
    );
  }
}

/// Overall stats card
class _OverallStatsCard extends StatelessWidget {
  final MilestoneSummary summary;
  final List<MilestoneDefinition> definitions;

  const _OverallStatsCard({
    required this.summary,
    required this.definitions,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tierBreakdown = _getTierBreakdown();

    return Container(
      margin: const EdgeInsets.only(bottom: PawTokens.md),
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
            'Achievement Breakdown',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: PawTokens.md),
          ...tierBreakdown.entries.map((entry) => _TierRow(
                tier: entry.key,
                color: entry.value,
                count: _getTierCount(entry.key),
                total: definitions.where((d) => d.tier == entry.key).length,
              )),
          if (summary.allUnlocked) ...[
            const SizedBox(height: PawTokens.md),
            Container(
              padding: const EdgeInsets.all(PawTokens.sm),
              decoration: BoxDecoration(
                color: PawTableColors.warning.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(PawTokens.radiusMd),
              ),
              child: Row(
                children: [
                  const Text('🎉', style: TextStyle(fontSize: 24)),
                  const SizedBox(width: PawTokens.sm),
                  Expanded(
                    child: Text(
                      'All milestones unlocked! You are a legendary pet caregiver!',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: PawTableColors.warning,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Map<String, Color> _getTierBreakdown() {
    return {
      'bronze': PawTableColors.primary,
      'silver': PawTableColors.info,
      'gold': PawTableColors.warning,
      'diamond': PawTableColors.premiumDark,
    };
  }

  int _getTierCount(String tier) {
    return summary.achievements
        .where((a) => a.unlocked)
        .where((a) => a.definition?.tier == tier)
        .length;
  }
}

/// Tier row showing count
class _TierRow extends StatelessWidget {
  final String tier;
  final Color color;
  final int count;
  final int total;

  const _TierRow({
    required this.tier,
    required this.color,
    required this.count,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: PawTokens.sm),
          Text(
            tier.toUpperCase(),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: PawTokens.md),
          Expanded(
            child: LinearProgressIndicator(
              value: total > 0 ? count / total : 0,
              minHeight: 4,
              borderRadius: BorderRadius.circular(2),
              backgroundColor: PawTableColors.surfaceVariant,
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
          const SizedBox(width: PawTokens.sm),
          Text(
            '$count/$total',
            style: theme.textTheme.bodySmall?.copyWith(
              color: PawTableColors.onSurfaceMuted,
            ),
          ),
        ],
      ),
    );
  }
}

/// Individual milestone badge card
class _MilestoneBadgeCard extends ConsumerWidget {
  final String petId;
  final MilestoneDefinition definition;
  final MilestoneAchievement? achievement;

  const _MilestoneBadgeCard({
    required this.petId,
    required this.definition,
    required this.achievement,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final unlocked = achievement?.unlocked ?? false;
    final progress = achievement?.progress ?? 0.0;
    final isLocked = !unlocked && progress < 1.0;
    final isNear = progress >= 0.7 && !unlocked;

    // Map iconCode to actual Icons
    IconData iconData;
    switch (definition.iconCode) {
      case 0:
        iconData = Icons.emoji_events;
      case 1:
        iconData = Icons.emoji_events_outlined;
      case 2:
        iconData = Icons.workspace_premium;
      case 3:
        iconData = Icons.workspace_premium_outlined;
      case 4:
        iconData = Icons.stars;
      case 5:
        iconData = Icons.star_rounded;
      case 6:
        iconData = Icons.diamond_rounded;
      default:
        iconData = Icons.diamond_outlined;
    }

    Color badgeBg;
    switch (definition.tier) {
      case 'bronze':
        badgeBg = PawTableColors.primary.withValues(alpha: 0.15);
      case 'silver':
        badgeBg = PawTableColors.info.withValues(alpha: 0.15);
      case 'gold':
        badgeBg = PawTableColors.warning.withValues(alpha: 0.15);
      case 'diamond':
        badgeBg = PawTableColors.premiumDark.withValues(alpha: 0.15);
      default:
        badgeBg = PawTableColors.surfaceVariant;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: PawTokens.sm),
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(PawTokens.radiusLg),
          border: Border.all(
            color: unlocked
                ? definition.tier == 'diamond'
                    ? PawTableColors.premiumDark
                    : definition.tier == 'gold'
                        ? PawTableColors.warning
                        : definition.tier == 'silver'
                            ? PawTableColors.info
                            : PawTableColors.primary
                : PawTableColors.surfaceVariant,
            width: unlocked ? 2 : 1,
          ),
          boxShadow: isNear
              ? [
                  BoxShadow(
                    color: PawTableColors.warning.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : PawTokens.shadow1,
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.all(PawTokens.md),
          leading: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: badgeBg,
              borderRadius: BorderRadius.circular(PawTokens.radiusMd),
            ),
            child: Center(
              child: Icon(
                isLocked && progress == 0
                    ? Icons.lock_outline
                    : iconData,
                size: 32,
                color: unlocked
                    ? _getTierColor(definition.tier)
                    : PawTableColors.onSurfaceMuted,
              ),
            ),
          ),
          title: Row(
            children: [
              Expanded(
                child: Text(
                  unlocked ? definition.title : '???',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: unlocked
                        ? PawTableColors.onBackground
                        : PawTableColors.onSurfaceMuted,
                  ),
                ),
              ),
              if (unlocked)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: PawTokens.sm,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: _getTierColor(definition.tier),
                    borderRadius: BorderRadius.circular(PawTokens.radiusSm),
                  ),
                  child: Text(
                    definition.tier,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
            ],
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(
                unlocked
                    ? definition.description
                    : 'Reach a ${definition.requiredDays}-day streak to unlock',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: unlocked
                      ? PawTableColors.onSurfaceMuted
                      : PawTableColors.onSurfaceMuted,
                ),
              ),
              const SizedBox(height: 8),
              // Progress bar
              Stack(
                children: [
                  LinearProgressIndicator(
                    value: progress,
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(4),
                    backgroundColor: PawTableColors.surfaceVariant,
                    valueColor: AlwaysStoppedAnimation(
                      unlocked
                          ? _getTierColor(definition.tier)
                          : PawTableColors.primary,
                    ),
                  ),
                  Positioned(
                    right: 0,
                    top: 0,
                    bottom: 0,
                    child: Center(
                      child: Text(
                        unlocked
                            ? '✅ Unlocked!'
                            : '${(progress * 100).toInt()}%',
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: unlocked
                              ? _getTierColor(definition.tier)
                              : PawTableColors.onBackground,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getTierColor(String tier) {
    switch (tier) {
      case 'bronze':
        return PawTableColors.primary;
      case 'silver':
        return PawTableColors.info;
      case 'gold':
        return PawTableColors.warning;
      case 'diamond':
        return PawTableColors.premiumDark;
      default:
        return PawTableColors.onSurfaceMuted;
    }
  }
}

/// Loading skeleton
class _LoadingSkeleton extends StatelessWidget {
  const _LoadingSkeleton();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(PawTokens.md),
      child: Column(
        children: List.generate(
          8,
          (_) => Padding(
            padding: const EdgeInsets.only(bottom: PawTokens.sm),
            child: Container(
              height: 80,
              decoration: BoxDecoration(
                color: PawTableColors.surfaceVariant,
                borderRadius: BorderRadius.circular(PawTokens.radiusLg),
              ),
            ),
          ),
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
    return SliverToBoxAdapter(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(PawTokens.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('⚠️', style: TextStyle(fontSize: 48)),
              const SizedBox(height: PawTokens.md),
              Text(
                'Failed to load achievements',
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
      ),
    );
  }
}

/// Empty state — no milestones yet
class _EmptyMilestoneState extends StatelessWidget {
  const _EmptyMilestoneState();

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(PawTokens.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.emoji_events, size: 80, color: PawTableColors.primary),
              const SizedBox(height: PawTokens.md),
              Text(
                'No Milestones Yet',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: PawTokens.sm),
              Text(
                'Start logging activities to earn achievements!\nBuild streaks to unlock badges.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: PawTableColors.onSurfaceVariant,
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/re_engagement_service.dart';

// =========================================================================
// RE-ENGAGEMENT STATE
// =========================================================================

/// UI state for re-engagement
class ReEngagementState {
  final InactivityStatus status;
  final Map<String, dynamic>? pendingWinBack;
  final bool isLoading;

  ReEngagementState({
    InactivityStatus? status,
    this.pendingWinBack,
    this.isLoading = false,
  }) : status = status ?? InactivityStatus(
          isActive: true,
          daysInactive: 0,
          tier: InactivityTier.all[0],
        );

  ReEngagementState copyWith({
    InactivityStatus? status,
    Map<String, dynamic>? pendingWinBack,
    bool? isLoading,
  }) {
    return ReEngagementState(
      status: status ?? this.status,
      pendingWinBack: pendingWinBack ?? this.pendingWinBack,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

// =========================================================================
// PROVIDER
// =========================================================================

/// Provider managing re-engagement state
class ReEngagementNotifier extends StateNotifier<ReEngagementState> {
  ReEngagementNotifier() : super(
        ReEngagementState(
          status: InactivityStatus(
            isActive: true,
            daysInactive: 0,
            tier: InactivityTier.all[0],
          ),
        ),
      );

  /// Record an activity event
  void recordActivity(ActivityEvent event) {
    final newStatus = _calculateStatus(event);
    state = state.copyWith(status: newStatus);
  }

  /// Check for pending win-back notifications
  void checkWinBack({
    required String userId,
    required String petName,
    int? currentStreak,
  }) {
    state = state.copyWith(isLoading: true);

    // Use 2 days ago as default last activity for demo
    final lastActivity = DateTime.now().subtract(const Duration(days: 2));
    final status = _calculateStatus(ActivityEvent(
      type: ActivityEventType.appOpen,
      timestamp: lastActivity,
    ));
    final shouldShow = status.hasWinBackTier && status.daysInactive >= 1;

    if (shouldShow) {
      final message = WinBackMessageGenerator.generateWinBackMessage(
        tier: status.tier,
        petName: petName,
        currentStreak: currentStreak,
        daysInactive: status.daysInactive,
      );
      state = state.copyWith(
        status: status,
        pendingWinBack: message,
        isLoading: false,
      );
    } else {
      state = state.copyWith(
        status: status,
        pendingWinBack: null,
        isLoading: false,
      );
    }
  }

  /// Dismiss the win-back notification
  void dismissWinBack() {
    state = state.copyWith(pendingWinBack: null);
  }

  /// Record that the user has become active again
  void activate() {
    state = state.copyWith(
      status: InactivityStatus(
        isActive: true,
        daysInactive: 0,
        tier: InactivityTier.all[0],
      ),
      pendingWinBack: null,
    );
  }

  InactivityStatus _calculateStatus(ActivityEvent? lastEvent) {
    final lastActivity = lastEvent?.timestamp ?? DateTime.now().subtract(
      const Duration(days: 2),
    );
    final days = DateTime.now().difference(lastActivity).inDays;

    InactivityTier tier;
    if (days <= 0) {
      tier = InactivityTier(
        id: 'active',
        label: 'Active',
        minDays: 0,
        maxDays: 0,
        subject: '',
        body: '',
        icon: Icons.check_circle_rounded,
        accentColor: Colors.green,
      );
    } else {
      tier = InactivityTier.all.firstWhere(
        (t) => t.isForDuration(days),
        orElse: () => InactivityTier(
          id: 'tier_5',
          label: 'Long-term Absence',
          minDays: 31,
          maxDays: 365,
          subject: 'Your pet needs you!',
          body: '{petName} is waiting.',
          icon: Icons.home_rounded,
          accentColor: const Color(0xFFF4A261),
        ),
      );
    }

    return InactivityStatus(
      isActive: tier.minDays == 0,
      daysInactive: days,
      tier: tier,
      missedTiers: _getMissedTiers(days),
    );
  }

  List<InactivityTier> _getMissedTiers(int days) {
    final missed = <InactivityTier>[];
    for (final tier in InactivityTier.all) {
      if (tier.maxDays < days && tier.minDays > 0) {
        missed.add(tier);
      }
    }
    return missed;
  }
}

final reEngagementProvider =
    StateNotifierProvider<ReEngagementNotifier, ReEngagementState>(
  (ref) => ReEngagementNotifier(),
);

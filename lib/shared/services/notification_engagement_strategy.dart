import 'dart:async';
import 'package:flutter/material.dart';

/// Priority levels for notification scheduling
enum NotificationPriority {
  /// Immediate — feeding, medication deadlines
  high,

  /// Soon — streak reminders, upcoming events
  medium,

  /// Gentle — milestones, wellness tips
  low,
}

/// Types of engagement notifications
enum NotificationType {
  /// Daily feeding reminder
  feedingReminder,

  /// Medication due reminder
  medicationReminder,

  /// Vaccination due reminder
  vaccinationReminder,

  /// Weight check reminder
  weightCheckReminder,

  /// Streak alert — about to lose or just reached milestone
  streakAlert,

  /// Milestone achievement unlocked
  milestoneAchieved,

  /// Achievement unlocked
  achievementUnlocked,

  /// Health check reminder
  healthCheckReminder,

  /// Pet wellness tip
  wellnessTip,

  /// Inactivity win-back (used by d8b.5)
  winBackReminder,

  /// Family collaboration reminder
  familyReminder,
}

/// Personalized notification content
class EngagementNotification {
  final NotificationType type;
  final String title;
  final String body;
  final NotificationPriority priority;
  final IconData icon;
  final Color? accentColor;
  final Map<String, dynamic> payload;
  final Duration? quietHoursOverride;

  const EngagementNotification({
    required this.type,
    required this.title,
    required this.body,
    this.priority = NotificationPriority.low,
    this.icon = Icons.notifications_rounded,
    this.accentColor,
    this.payload = const {},
    this.quietHoursOverride,
  });
}

// =========================================================================
// QUIET HOURS — user preference window for no notifications
// =========================================================================

/// Quiet hours configuration
class QuietHoursConfig {
  final int startHour; // 0-23
  final int endHour;   // 0-23 (inclusive)
  final bool enabled;

  const QuietHoursConfig({
    this.startHour = 22,
    this.endHour = 7,
    this.enabled = true,
  });

  /// Check if the given time falls within quiet hours
  bool isWithinQuietHours(DateTime time, {QuietHoursConfig? override}) {
    if (!enabled && override?.enabled != true) return false;

    final config = override ?? this;
    if (config.startHour > config.endHour) {
      // Spans midnight (e.g., 22:00 → 07:00)
      return time.hour >= config.startHour || time.hour < config.endHour;
    } else {
      // Within same day (e.g., 01:00 → 05:00 for daytime naps)
      return time.hour >= config.startHour && time.hour < config.endHour;
    }
  }
}

// =========================================================================
// ENGAGEMENT WINDOW — optimal times for notifications
// =========================================================================

/// Engagement window for each time block
class EngagementWindow {
  final String label;
  final int startHour;
  final int endHour;
  final double engagementScore; // 0.0 - 1.0
  final List<NotificationType> preferredTypes;

  const EngagementWindow({
    required this.label,
    required this.startHour,
    required this.endHour,
    this.engagementScore = 0.5,
    this.preferredTypes = const [],
  });

  static const List<EngagementWindow> defaultWindows = [
    EngagementWindow(
      label: 'Morning',
      startHour: 7,
      endHour: 10,
      engagementScore: 0.9,
      preferredTypes: [
        NotificationType.feedingReminder,
        NotificationType.healthCheckReminder,
        NotificationType.wellnessTip,
      ],
    ),
    EngagementWindow(
      label: 'Midday',
      startHour: 11,
      endHour: 14,
      engagementScore: 0.6,
      preferredTypes: [
        NotificationType.feedingReminder,
        NotificationType.medicationReminder,
      ],
    ),
    EngagementWindow(
      label: 'Afternoon',
      startHour: 15,
      endHour: 18,
      engagementScore: 0.5,
      preferredTypes: [
        NotificationType.wellnessTip,
      ],
    ),
    EngagementWindow(
      label: 'Evening',
      startHour: 19,
      endHour: 21,
      engagementScore: 0.8,
      preferredTypes: [
        NotificationType.feedingReminder,
        NotificationType.medicationReminder,
        NotificationType.weightCheckReminder,
      ],
    ),
    EngagementWindow(
      label: 'Night',
      startHour: 22,
      endHour: 6,
      engagementScore: 0.1,
      preferredTypes: [],
    ),
  ];
}

// =========================================================================
// FREQUENCY CAPPING
// =========================================================================

/// Rate limiter for notification types
class FrequencyCap {
  final NotificationType type;
  final int maxPerDay;
  final Duration minInterval;
  final bool allowOverride;

  const FrequencyCap({
    required this.type,
    required this.maxPerDay,
    this.minInterval = const Duration(hours: 1),
    this.allowOverride = false,
  });

  static const List<FrequencyCap> defaultCaps = [
    FrequencyCap(type: NotificationType.feedingReminder, maxPerDay: 6),
    FrequencyCap(type: NotificationType.medicationReminder, maxPerDay: 8),
    FrequencyCap(type: NotificationType.vaccinationReminder, maxPerDay: 3),
    FrequencyCap(type: NotificationType.weightCheckReminder, maxPerDay: 2),
    FrequencyCap(type: NotificationType.streakAlert, maxPerDay: 1),
    FrequencyCap(type: NotificationType.milestoneAchieved, maxPerDay: 3),
    FrequencyCap(type: NotificationType.achievementUnlocked, maxPerDay: 5),
    FrequencyCap(type: NotificationType.healthCheckReminder, maxPerDay: 2),
    FrequencyCap(type: NotificationType.wellnessTip, maxPerDay: 3),
    FrequencyCap(type: NotificationType.winBackReminder, maxPerDay: 1),
    FrequencyCap(type: NotificationType.familyReminder, maxPerDay: 5),
  ];
}

// =========================================================================
// SMART SCHEDULER
// =========================================================================

/// Manages notification scheduling with engagement optimization
///
/// Features:
/// - Time-of-day intelligence (quiet hours, engagement windows)
/// - Frequency capping per notification type
/// - Deduplication to prevent duplicate notifications
/// - Priority-based scheduling
/// - Personalization hooks for future data-driven optimization
class NotificationScheduler {
  final QuietHoursConfig quietHours;
  final List<FrequencyCap> frequencyCaps;
  late final Map<NotificationType, int> _sentTodayCounts;
  final List<String> _recentNotificationIds;
  Timer? _dailyResetTimer;

  NotificationScheduler({
    this.quietHours = const QuietHoursConfig(),
    this.frequencyCaps = FrequencyCap.defaultCaps,
  }) : _recentNotificationIds = [] {
    // Initialize sent today counts from frequency caps
    _sentTodayCounts = {
      for (final cap in frequencyCaps) cap.type: 0
    }.cast<NotificationType, int>();
    // Reset daily counter at midnight
    _scheduleDailyReset();
  }

  /// Schedule a daily reset at midnight
  void _scheduleDailyReset() {
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    final midnight = DateTime(
      tomorrow.year,
      tomorrow.month,
      tomorrow.day,
    );

    final delay = midnight.difference(now);
    _dailyResetTimer = Timer(delay, _resetDailyCounts);
  }

  /// Reset daily counters and reschedule
  void _resetDailyCounts() {
    _sentTodayCounts.clear();
    for (var cap in frequencyCaps) {
      _sentTodayCounts[cap.type] = 0;
    }
    _recentNotificationIds.clear();
    _scheduleDailyReset();
  }

  /// Check if a notification should be sent right now
  bool shouldSchedule({
    required NotificationType type,
    required String notificationId,
    required DateTime scheduledTime,
    NotificationPriority priority = NotificationPriority.low,
  }) {
    // 1. Quiet hours check (allow high priority override)
    if (quietHours.isWithinQuietHours(scheduledTime)) {
      if (priority != NotificationPriority.high) return false;
    }

    // 2. Frequency cap check
    final cap = frequencyCaps.firstWhere(
      (c) => c.type == type,
      orElse: () => const FrequencyCap(
        type: NotificationType.wellnessTip,
        maxPerDay: 3,
      ),
    );

    if (_sentTodayCounts[type]! >= cap.maxPerDay && !cap.allowOverride) {
      return false;
    }

    // 3. Deduplication — avoid scheduling the same ID recently
    if (_recentNotificationIds.contains(notificationId)) return false;
    if (_recentNotificationIds.length > 50) {
      _recentNotificationIds.removeRange(0, 20);
    }

    return true;
  }

  /// Record a notification as scheduled
  void recordScheduled(NotificationType type, String notificationId) {
    _sentTodayCounts[type] = (_sentTodayCounts[type] ?? 0) + 1;
    _recentNotificationIds.add(notificationId);
    if (_recentNotificationIds.length > 100) {
      _recentNotificationIds.removeRange(0, 50);
    }
  }

  /// Get the best engagement window for a notification type
  EngagementWindow? getBestEngagementWindow(NotificationType type) {
    final windows = EngagementWindow.defaultWindows;
    EngagementWindow? best;
    double bestScore = 0;

    for (final window in windows) {
      if (window.preferredTypes.contains(type) &&
          window.engagementScore > bestScore) {
        best = window;
        bestScore = window.engagementScore;
      }
    }

    return best ?? windows.firstWhere(
      (w) => w.engagementScore > 0.4,
      orElse: () => const EngagementWindow(
        label: 'General',
        startHour: 9,
        endHour: 18,
        engagementScore: 0.5,
      ),
    );
  }

  /// Clean up resources
  void dispose() {
    _dailyResetTimer?.cancel();
  }
}

// =========================================================================
// ENGAGEMENT MESSAGE GENERATOR
// =========================================================================

/// Generates personalized notification messages based on context
///
/// Uses pet data, streak info, and milestones to create
/// contextually relevant notifications.
class EngagementMessageGenerator {
  static const List<String> _wellnessTips = [
    '💧 Make sure your pet has fresh water today!',
    '🐾 A short walk can boost their mood and health.',
    '🧹 Don\'t forget to clean their bedding this week.',
    '✂️ Time for a quick nail trim check.',
    '🦷 Oral health matters — a tooth treat can help!',
    '☀️ A little sun and fresh air is good for them.',
    '🧸 Playing strengthens your bond — try 10 minutes today.',
    '🌿 Indoor plants — keep them out of reach!',
  ];

  static const List<String> _streakEncouragements = [
    'You\'re on a {streak} day streak! Keep it up! 🎯',
    '{streak} days of great pet care — you\'re amazing! 🌟',
    'Wow {streak} days! Your pet loves you! 💛',
    'Almost at {target}! {streak} days and counting! 🔥',
  ];

  static const List<String> _milestoneMessages = [
    'You hit {milestone}! Your pet is thriving! 🏆',
    '{milestone} — what a journey! 🎉',
    'Congratulations on reaching {milestone}! 🥇',
  ];

  /// Generate a feeding reminder
  static EngagementNotification feedingReminder({
    required String petName,
    int? streakDays,
  }) {
    return EngagementNotification(
      type: NotificationType.feedingReminder,
      title: 'Feeding time for $petName!',
      body: streakDays != null && streakDays >= 7
          ? _pick(_streakEncouragements)
              .replaceAll('{streak}', streakDays.toString())
              .replaceAll('{target}', '30')
          : 'Time to log $petName\'s meal.',
      priority: NotificationPriority.high,
      icon: Icons.restaurant_rounded,
      accentColor: const Color(0xFFF4A261),
      payload: {'type': 'feeding_reminder', 'petName': petName},
    );
  }

  /// Generate a medication reminder
  static EngagementNotification medicationReminder({
    required String petName,
    required String medicationName,
  }) {
    return EngagementNotification(
      type: NotificationType.medicationReminder,
      title: 'Medication for $petName',
      body: 'Time to give $petName their $medicationName.',
      priority: NotificationPriority.high,
      icon: Icons.medication_liquid_rounded,
      accentColor: const Color(0xFFF2B8B8),
      payload: {
        'type': 'medication_reminder',
        'petName': petName,
        'medication': medicationName,
      },
    );
  }

  /// Generate a streak alert
  static EngagementNotification streakAlert({
    required int currentStreak,
    required String type,
  }) {
    final isHighStreak = currentStreak >= 30;
    final encouragements = isHighStreak
        ? ['You\'re on a {streak} day {type} streak! Legend! 🏆']
        : [
            '{streak} days of {type} — you\'re on fire! 🔥',
            '{streak} day {type} streak! Keep it going! 💪',
          ];
    final emoji = isHighStreak ? '🏆' : '🔥';

    return EngagementNotification(
      type: NotificationType.streakAlert,
      title: '$emoji $currentStreak Day $type Streak!',
      body: _pick(encouragements)
          .replaceAll('{streak}', currentStreak.toString())
          .replaceAll('{type}', type),
      priority: isHighStreak
          ? NotificationPriority.high
          : NotificationPriority.medium,
      icon: Icons.local_fire_department_rounded,
      accentColor: const Color(0xFFF8E167),
      payload: {
        'type': 'streak_alert',
        'streak': currentStreak,
        'streakType': type,
      },
    );
  }

  /// Generate a milestone achievement notification
  static EngagementNotification milestoneAchieved({
    required String milestoneName,
  }) {
    return EngagementNotification(
      type: NotificationType.milestoneAchieved,
      title: '🏆 Milestone Unlocked!',
      body: _pick(_milestoneMessages).replaceAll('{milestone}', milestoneName),
      priority: NotificationPriority.high,
      icon: Icons.emoji_events_rounded,
      accentColor: const Color(0xFFD4C5E2),
      payload: {
        'type': 'milestone_achieved',
        'milestoneName': milestoneName,
      },
    );
  }

  /// Generate a wellness tip
  static EngagementNotification wellnessTip() {
    return EngagementNotification(
      type: NotificationType.wellnessTip,
      title: '💛 Pet Wellness Tip',
      body: _pick(_wellnessTips),
      priority: NotificationPriority.low,
      icon: Icons.favorite_rounded,
      accentColor: const Color(0xFFA8D5BA),
      payload: {'type': 'wellness_tip'},
    );
  }

  /// Generate a vaccination reminder
  static EngagementNotification vaccinationReminder({
    required String petName,
    required String vaccineName,
  }) {
    return EngagementNotification(
      type: NotificationType.vaccinationReminder,
      title: 'Vaccination due for $petName',
      body: "$petName's $vaccineName vaccination is due.",
      priority: NotificationPriority.high,
      icon: Icons.local_hospital_rounded,
      accentColor: const Color(0xFFF2B8B8),
      payload: {
        'type': 'vaccination_reminder',
        'petName': petName,
        'vaccine': vaccineName,
      },
    );
  }

  /// Generate a weight check reminder
  static EngagementNotification weightCheckReminder({
    required String petName,
  }) {
    return EngagementNotification(
      type: NotificationType.weightCheckReminder,
      title: 'Weight check for $petName',
      body: "Time to log $petName's weight.",
      priority: NotificationPriority.medium,
      icon: Icons.scale_rounded,
      accentColor: const Color(0xFFB5C9D9),
      payload: {'type': 'weight_check', 'petName': petName},
    );
  }

  /// Pick a random message from a list
  static String _pick(List<String> messages) {
    return messages[DateTime.now().millisecondsSinceEpoch % messages.length];
  }
}

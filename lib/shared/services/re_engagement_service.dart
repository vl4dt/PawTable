import 'package:flutter/material.dart';

/// Inactivity tier — determines the win-back strategy
class InactivityTier {
  final String id;
  final String label;
  final int minDays;
  final int maxDays;
  final String subject;
  final String body;
  final IconData icon;
  final Color accentColor;

  const InactivityTier({
    required this.id,
    required this.label,
    required this.minDays,
    required this.maxDays,
    required this.subject,
    required this.body,
    required this.icon,
    required this.accentColor,
  });

  /// Check if a given inactivity duration falls within this tier
  bool isForDuration(int days) => days >= minDays && days <= maxDays;

  /// Create a copy with overridden fields
  InactivityTier copyWith({
    String? id,
    String? label,
    int? minDays,
    int? maxDays,
    String? subject,
    String? body,
    IconData? icon,
    Color? accentColor,
  }) {
    return InactivityTier(
      id: id ?? this.id,
      label: label ?? this.label,
      minDays: minDays ?? this.minDays,
      maxDays: maxDays ?? this.maxDays,
      subject: subject ?? this.subject,
      body: body ?? this.body,
      icon: icon ?? this.icon,
      accentColor: accentColor ?? this.accentColor,
    );
  }

  static final List<InactivityTier> all = [
    InactivityTier(
      id: 'tier_1',
      label: 'Brief Absence',
      minDays: 1,
      maxDays: 3,
      subject: 'Your pet misses you!',
      body: 'Quick check-in — {petName}\'s feeding is due today. Tap to log.',
      icon: Icons.hotel_rounded,
      accentColor: const Color(0xFFB5C9D9),
    ),
    InactivityTier(
      id: 'tier_2',
      label: 'Streak at Risk',
      minDays: 4,
      maxDays: 7,
      subject: 'Your streak is about to end!',
      body:
          'You were on a {streak} day streak for {petName}. One more log and it\'s back!',
      icon: Icons.local_fire_department_rounded,
      accentColor: const Color(0xFFF8E167),
    ),
    InactivityTier(
      id: 'tier_3',
      label: 'We Miss You',
      minDays: 8,
      maxDays: 14,
      subject: 'We\'ve missed seeing you!',
      body:
          '{petName} hasn\'t been fed in a while. Come back and check in today — it only takes a minute.',
      icon: Icons.favorite_rounded,
      accentColor: const Color(0xFFA8D5BA),
    ),
    InactivityTier(
      id: 'tier_4',
      label: 'Special Return',
      minDays: 15,
      maxDays: 30,
      subject: 'A warm welcome back!',
      body:
          'It\'s been {days} days! Your pet health logs and milestones are waiting. Tap to jump back in.',
      icon: Icons.waves_rounded,
      accentColor: const Color(0xFFD4C5E2),
    ),
    InactivityTier(
      id: 'tier_5',
      label: 'Come Home',
      minDays: 31,
      maxDays: 365,
      subject: 'Your pet needs you!',
      body:
          'It\'s been {days} days since you last checked in. {petName} is counting on you. Open PawTable to start fresh.',
      icon: Icons.home_rounded,
      accentColor: const Color(0xFFF4A261),
    ),
  ];
}

/// User activity events tracked for inactivity detection
enum ActivityEventType {
  feedingLog,
  healthCheck,
  medicationLog,
  weightLog,
  behaviorLog,
  streakMaintained,
  milestoneReached,
  achievementUnlocked,
  appOpen,
  petProfileView,
}

/// Record of a single activity event
class ActivityEvent {
  final ActivityEventType type;
  final DateTime timestamp;
  final Map<String, dynamic> payload;

  const ActivityEvent({
    required this.type,
    required this.timestamp,
    this.payload = const {},
  });
}

// =========================================================================
// INACTIVITY DETECTOR
// =========================================================================

/// Detects how long a user has been inactive and determines their tier
///
/// Tracks activity by timestamp and calculates:
/// - Days since last activity
/// - Inactivity tier (1-5)
/// - Recommended win-back message
class InactivityDetector {
  final List<ActivityEvent> _activityLog;
  final int inactivityThresholdDays;
  DateTime? _lastKnownActivity;

  InactivityDetector({
    List<ActivityEvent>? activityLog,
    this.inactivityThresholdDays = 1,
  }) : _activityLog = List.from(activityLog ?? []) {
    _lastKnownActivity = _activityLog.isEmpty
        ? null
        : _activityLog.map((e) => e.timestamp).reduce(
            (a, b) => a.isAfter(b) ? a : b,
          );
  }

  /// Record a new activity event
  void recordEvent(ActivityEvent event) {
    _activityLog.add(event);
    if (_lastKnownActivity == null || event.timestamp.isAfter(_lastKnownActivity!)) {
      _lastKnownActivity = event.timestamp;
    }
  }

  /// Clear all activity (e.g., user logged out)
  void clear() {
    _activityLog.clear();
    _lastKnownActivity = null;
  }

  /// Get days since last activity
  int getDaysSinceLastActivity() {
    if (_lastKnownActivity == null) return 999;
    return DateTime.now().difference(_lastKnownActivity!).inDays;
  }

  /// Get the current inactivity tier
  InactivityTier get currentTier {
    final days = getDaysSinceLastActivity();
    if (days < inactivityThresholdDays) {
      return InactivityTier.all[0].copyWith(minDays: 0, maxDays: 0);
    }

    for (final tier in InactivityTier.all) {
      if (tier.isForDuration(days)) return tier;
    }

    // Beyond tier 5
    return InactivityTier(
      id: 'tier_5+',
      label: 'Long-term Absence',
      minDays: 366,
      maxDays: 9999,
      subject: 'Your pet really needs you!',
      body: 'It\'s been a long time. {petName} is waiting for you.',
      icon: Icons.home_rounded,
      accentColor: const Color(0xFFF4A261),
    );
  }

  /// Get all tiers that have passed (for win-back campaigns)
  List<InactivityTier> getMissedTiers() {
    final days = getDaysSinceLastActivity();
    if (days <= 0) return [];

    final missed = <InactivityTier>[];
    for (final tier in InactivityTier.all) {
      if (tier.maxDays < days && tier.minDays > 0) {
        missed.add(tier);
      }
    }
    return missed;
  }
}

// =========================================================================
// WIN-BACK MESSAGE GENERATOR
// =========================================================================

/// Generates personalized win-back messages based on inactivity tier
///
/// Uses pet data, streak info, and historical engagement to craft
/// messages that encourage return.
class WinBackMessageGenerator {
  static const List<String> _fallbackMessages = [
    'Your pet needs a friend. Come back! 💛',
    'The home screen is empty without you. 🏠',
    'Every pet lover needs a break — but {petName} is waiting! 🐾',
    'Your streak starts with one tap. Come back! 🔥',
  ];

  /// Generate a win-back notification for the current inactivity tier
  static Map<String, dynamic> generateWinBackMessage({
    required InactivityTier tier,
    required String petName,
    int? currentStreak,
    int? daysInactive,
  }) {
    final effectiveDays = daysInactive ?? tier.maxDays;
    final pet = petName.isNotEmpty ? petName : 'Your pet';

    String body = tier.body
        .replaceAll('{petName}', pet)
        .replaceAll('{streak}', currentStreak?.toString() ?? 'a')
        .replaceAll('{days}', effectiveDays.toString());

    // If body still has placeholders, use fallback
    if (body.contains('{') && body.contains('}')) {
      body = _fallbackMessages[
          DateTime.now().millisecondsSinceEpoch % _fallbackMessages.length];
    }

    return {
      'type': 'win_back_notification',
      'tier': tier.id,
      'title': tier.subject,
      'body': body,
      'icon': tier.icon,
      'accentColor': tier.accentColor,
      'priority': tier.maxDays <= 7 ? 'medium' : 'high',
      'payload': {
        'tierId': tier.id,
        'daysInactive': effectiveDays,
        'petName': petName,
        'currentStreak': currentStreak,
      },
    };
  }

  /// Generate a summary of all missed tiers for a win-back campaign
  static String generateMissedTiersSummary(List<InactivityTier> tiers) {
    if (tiers.isEmpty) return '';

    final tierNames = tiers.map((t) => t.label).join(', ');
    return 'You missed $tierNames. Start fresh today!';
  }
}

// =========================================================================
// WIN-BACK CAMPAIGN — manages the sequence of win-back messages
// =========================================================================

/// Manages the win-back campaign: which messages to send, when, and to whom
///
/// Campaign rules:
/// - Tier 1 (1-3 days): 1 notification per day
/// - Tier 2 (4-7 days): 1 notification per day
/// - Tier 3 (8-14 days): 1 notification every 2 days
/// - Tier 4 (15-30 days): 1 notification every 3 days
/// - Tier 5 (30+ days): 1 notification per week
class WinBackCampaign {
  final Map<String, DateTime> _sentMessages; // key = tierId + userId

  WinBackCampaign({
    Map<String, DateTime>? sentMessages,
  }) : _sentMessages = Map.from(sentMessages ?? {});

  /// Check if a win-back message should be sent for a given tier
  bool shouldSend({
    required String tierId,
    required String userId,
    required DateTime lastActivity,
  }) {
    final key = '$tierId:$userId';
    final lastSent = _sentMessages[key];

    if (lastSent == null) return true;

    final timeSinceLastSend = DateTime.now().difference(lastSent);

    int minIntervalHours;
    switch (tierId) {
      case 'tier_1':
      case 'tier_2':
        minIntervalHours = 24;
      case 'tier_3':
        minIntervalHours = 48;
      case 'tier_4':
        minIntervalHours = 72;
      case 'tier_5':
        minIntervalHours = 168;
      default:
        minIntervalHours = 24;
    }

    return timeSinceLastSend.inHours >= minIntervalHours;
  }

  /// Record that a win-back message was sent
  void recordSent(String tierId, String userId) {
    _sentMessages['$tierId:$userId'] = DateTime.now();
  }

  /// Get count of sent messages
  int get sentCount => _sentMessages.length;

  /// Clear sent records
  void clear() {
    _sentMessages.clear();
  }

  /// Serialize for persistence
  Map<String, dynamic> serialize() {
    return {
      'sentMessages': _sentMessages.map(
        (key, value) => MapEntry(key, value.toIso8601String()),
      ),
    };
  }

  /// Deserialize from persisted data
  factory WinBackCampaign.deserialize(Map<String, dynamic> data) {
    final sentMap = data['sentMessages'] as Map<dynamic, dynamic>?;
    final sent = sentMap?.map(
      (key, value) => MapEntry(key as String, DateTime.parse(value as String)),
    ) ?? {};
    return WinBackCampaign(sentMessages: sent);
  }
}

// =========================================================================
// RE-ENGAGEMENT SERVICE
// =========================================================================

/// High-level service that orchestrates inactivity detection and win-back campaigns
///
/// This is the main entry point for re-engagement logic in the app.
class ReEngagementService {
  final InactivityDetector _detector;
  final WinBackCampaign _campaign;
  final List<String> _deliveredTierIds;

  ReEngagementService({
    InactivityDetector? detector,
    WinBackCampaign? campaign,
  })  : _detector = detector ?? InactivityDetector(),
        _campaign = campaign ?? WinBackCampaign(),
        _deliveredTierIds = [];

  /// Record that the user performed an activity (app open, log, etc.)
  void recordActivity(ActivityEvent event) {
    _detector.recordEvent(event);
  }

  /// Get the user's current inactivity status
  InactivityStatus getStatus() {
    final tier = _detector.currentTier;
    final days = _detector.getDaysSinceLastActivity();

    return InactivityStatus(
      isActive: tier.minDays == 0,
      daysInactive: days,
      tier: tier,
      missedTiers: _detector.getMissedTiers(),
    );
  }

  /// Generate a win-back notification if one should be sent
  Map<String, dynamic>? getWinBackNotification({
    required String userId,
    required String petName,
    int? currentStreak,
  }) {
    final status = getStatus();

    // Active user — no win-back needed
    if (status.isActive) return null;

    // Check if we should send a notification for this tier
    final lastActivity = DateTime.now().subtract(Duration(days: status.daysInactive));
    if (!_campaign.shouldSend(
      tierId: status.tier.id,
      userId: userId,
      lastActivity: lastActivity,
    )) {
      return null;
    }

    final message = WinBackMessageGenerator.generateWinBackMessage(
      tier: status.tier,
      petName: petName,
      currentStreak: currentStreak,
      daysInactive: status.daysInactive,
    );

    // Record that we sent this
    _campaign.recordSent(status.tier.id, userId);
    if (!_deliveredTierIds.contains(status.tier.id)) {
      _deliveredTierIds.add(status.tier.id);
    }

    return message;
  }

  /// Reset the inactivity detector (user has become active again)
  void reset() {
    _detector.clear();
    _campaign.clear();
    _deliveredTierIds.clear();
  }

  /// Serialize for persistence
  Map<String, dynamic> serialize() {
    return {
      'campaign': _campaign.serialize(),
    };
  }

  /// Deserialize from persisted data
  factory ReEngagementService.deserialize(Map<String, dynamic> data) {
    final campaignData = data['campaign'] as Map<String, dynamic>? ?? {};
    final campaign = WinBackCampaign.deserialize(campaignData);
    return ReEngagementService(campaign: campaign);
  }
}

// =========================================================================
// INACTIVITY STATUS — returned to UI
// =========================================================================

/// Current inactivity status for display in the UI
class InactivityStatus {
  final bool isActive;
  final int daysInactive;
  final InactivityTier tier;
  final List<InactivityTier> missedTiers;

  const InactivityStatus({
    this.isActive = false,
    this.daysInactive = 0,
    required this.tier,
    this.missedTiers = const [],
  });

  /// Whether the user has an active tier (needs a win-back)
  bool get hasWinBackTier => !isActive && daysInactive >= 1;

  /// Whether the user lost their streak
  bool get streakLost => daysInactive > 0 && !isActive;
}

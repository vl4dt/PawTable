import 'package:equatable/equatable.dart';
import '../../../../core/models/base_model.dart' show JsonHelpers;

/// Types of achievements that can be unlocked
enum AchievementType {
  /// Streak-based achievements (e.g., 7-day streak)
  streak,

  /// Feeding milestone achievements (e.g., feed 100 times)
  feeding,

  /// Health milestone achievements (e.g., 30 vaccinations logged)
  health,

  /// Medication milestone achievements (e.g., 30 days medication adherence)
  medication,

  /// Weight milestone achievements (e.g., track weight 60 days)
  weight,

  /// Behavior milestone achievements (e.g., log behavior 30 days)
  behavior,

  /// Combined achievements (e.g., log all types in one day)
  combined,

  /// First-time achievements (e.g., first feeding, first vaccination)
  firstTime,
}

/// Predefined achievement definitions with conditions
///
/// Each achievement has:
/// - A type (streak, feeding, health, etc.)
/// - A threshold/condition
/// - An icon, title, description
/// - Tier (bronze, silver, gold, diamond)
class AchievementDefinition extends Equatable {
  final String id;
  final AchievementType type;
  final String title;
  final String description;
  final String icon;
  final int requiredCount;
  final String tier;
  final int tierPriority; // For sorting within tier

  const AchievementDefinition({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.icon,
    required this.requiredCount,
    required this.tier,
    this.tierPriority = 0,
  });

  @override
  List<Object?> get props =>
      [id, type, title, description, icon, requiredCount, tier];

  // ──────────────────────────────────────────────────────────────────────
  // Predefined achievement definitions
  // ──────────────────────────────────────────────────────────────────────

  static const List<AchievementDefinition> all = [
    // Feeding milestones
    AchievementDefinition(
      id: 'feed_10',
      type: AchievementType.feeding,
      title: 'First Meal',
      description: 'Logged your pet\'s first meal',
      icon: '🍽️',
      requiredCount: 1,
      tier: 'bronze',
      tierPriority: 0,
    ),
    AchievementDefinition(
      id: 'feed_50',
      type: AchievementType.feeding,
      title: 'Regular Feeder',
      description: 'Fed your pet 50 times',
      icon: '🐾',
      requiredCount: 50,
      tier: 'bronze',
      tierPriority: 1,
    ),
    AchievementDefinition(
      id: 'feed_100',
      type: AchievementType.feeding,
      title: 'Dedicated Feeder',
      description: 'Fed your pet 100 times',
      icon: '🍖',
      requiredCount: 100,
      tier: 'silver',
      tierPriority: 2,
    ),
    AchievementDefinition(
      id: 'feed_500',
      type: AchievementType.feeding,
      title: 'Feeding Champion',
      description: 'Fed your pet 500 times',
      icon: '🏆',
      requiredCount: 500,
      tier: 'gold',
      tierPriority: 3,
    ),
    AchievementDefinition(
      id: 'feed_1000',
      type: AchievementType.feeding,
      title: 'Feeding Legend',
      description: 'Fed your pet 1000 times',
      icon: '⭐',
      requiredCount: 1000,
      tier: 'diamond',
      tierPriority: 4,
    ),

    // Health milestones
    AchievementDefinition(
      id: 'health_1',
      type: AchievementType.health,
      title: 'First Checkup',
      description: 'Recorded your first vaccination',
      icon: '💉',
      requiredCount: 1,
      tier: 'bronze',
      tierPriority: 0,
    ),
    AchievementDefinition(
      id: 'health_10',
      type: AchievementType.health,
      title: 'Health Tracker',
      description: 'Logged 10 health records',
      icon: '🏥',
      requiredCount: 10,
      tier: 'bronze',
      tierPriority: 1,
    ),
    AchievementDefinition(
      id: 'health_50',
      type: AchievementType.health,
      title: 'Health Guardian',
      description: 'Logged 50 health records',
      icon: '🛡️',
      requiredCount: 50,
      tier: 'silver',
      tierPriority: 2,
    ),

    // Medication milestones
    AchievementDefinition(
      id: 'med_1',
      type: AchievementType.medication,
      title: 'First Dose',
      description: 'Administered the first medication',
      icon: '💊',
      requiredCount: 1,
      tier: 'bronze',
      tierPriority: 0,
    ),
    AchievementDefinition(
      id: 'med_30',
      type: AchievementType.medication,
      title: 'Medication Adherent',
      description: 'Administered medication 30 times',
      icon: '💉',
      requiredCount: 30,
      tier: 'silver',
      tierPriority: 1,
    ),
    AchievementDefinition(
      id: 'med_100',
      type: AchievementType.medication,
      title: 'Medication Master',
      description: 'Administered medication 100 times',
      icon: '🎯',
      requiredCount: 100,
      tier: 'gold',
      tierPriority: 2,
    ),

    // Weight milestones
    AchievementDefinition(
      id: 'weight_1',
      type: AchievementType.weight,
      title: 'First Weigh-in',
      description: 'Recorded your pet\'s first weight',
      icon: '⚖️',
      requiredCount: 1,
      tier: 'bronze',
      tierPriority: 0,
    ),
    AchievementDefinition(
      id: 'weight_30',
      type: AchievementType.weight,
      title: 'Weight Watcher',
      description: 'Tracked weight for 30 days',
      icon: '📊',
      requiredCount: 30,
      tier: 'silver',
      tierPriority: 1,
    ),
    AchievementDefinition(
      id: 'weight_90',
      type: AchievementType.weight,
      title: 'Weight Champion',
      description: 'Tracked weight for 90 days',
      icon: '📈',
      requiredCount: 90,
      tier: 'gold',
      tierPriority: 2,
    ),

    // Behavior milestones
    AchievementDefinition(
      id: 'behavior_1',
      type: AchievementType.behavior,
      title: 'Behavior Observer',
      description: 'Logged your pet\'s first behavior',
      icon: '🧠',
      requiredCount: 1,
      tier: 'bronze',
      tierPriority: 0,
    ),
    AchievementDefinition(
      id: 'behavior_30',
      type: AchievementType.behavior,
      title: 'Behavior Analyst',
      description: 'Logged behavior for 30 days',
      icon: '🔬',
      requiredCount: 30,
      tier: 'silver',
      tierPriority: 1,
    ),

    // Combined milestones
    AchievementDefinition(
      id: 'combined_3',
      type: AchievementType.combined,
      title: 'Balanced Caregiver',
      description: 'Logged all care types in one day (3 types)',
      icon: '⚖️',
      requiredCount: 1,
      tier: 'silver',
      tierPriority: 0,
    ),
    AchievementDefinition(
      id: 'combined_10',
      type: AchievementType.combined,
      title: 'Dedicated Guardian',
      description: 'Logged all care types in 10 different days',
      icon: '🏅',
      requiredCount: 10,
      tier: 'gold',
      tierPriority: 1,
    ),

    // First time achievements
    AchievementDefinition(
      id: 'first_feeding',
      type: AchievementType.firstTime,
      title: 'First Feeding',
      description: 'Logged your pet\'s first feeding',
      icon: '🍽️',
      requiredCount: 1,
      tier: 'bronze',
      tierPriority: 0,
    ),
    AchievementDefinition(
      id: 'first_vaccination',
      type: AchievementType.firstTime,
      title: 'First Vaccination',
      description: 'Recorded your pet\'s first vaccination',
      icon: '💉',
      requiredCount: 1,
      tier: 'bronze',
      tierPriority: 0,
    ),
    AchievementDefinition(
      id: 'first_medication',
      type: AchievementType.firstTime,
      title: 'First Medication',
      description: 'Administered your pet\'s first medication',
      icon: '💊',
      requiredCount: 1,
      tier: 'bronze',
      tierPriority: 0,
    ),
  ];

  /// Lookup by ID
  static AchievementDefinition? byId(String id) {
    return all.where((a) => a.id == id).firstOrNull;
  }
}

/// An achievement event — records when an achievement is unlocked
///
/// This is the audit trail for achievement unlocks, used for
/// notifications, history, and analytics.
class AchievementEvent extends Equatable {
  final String id;
  final String petId;
  final AchievementType type;
  final String achievementId;
  final int currentCount; // Count at time of unlock
  final DateTime unlockedAt;

  const AchievementEvent({
    required this.id,
    required this.petId,
    required this.type,
    required this.achievementId,
    required this.currentCount,
    required this.unlockedAt,
  });

  /// The achievement definition for this event
  AchievementDefinition? get definition =>
      AchievementDefinition.byId(achievementId);

  /// Create from database row
  factory AchievementEvent.fromDbRow(Map<String, dynamic> row) {
    return AchievementEvent(
      id: row['id'] as String,
      petId: row['petId'] as String,
      type: _achievementTypeFromName(row['achievementType'] as String),
      achievementId: row['achievementId'] as String,
      currentCount: (row['currentCount'] as num).toInt(),
      unlockedAt: DateTime.parse(row['unlockedAt'] as String),
    );
  }

  /// Convert to database map
  Map<String, dynamic> toDbMap() => {
        'id': id,
        'petId': petId,
        'achievementType': _achievementTypeToName(type),
        'achievementId': achievementId,
        'currentCount': currentCount,
        'unlockedAt': unlockedAt.toIso8601String(),
      };

  static AchievementType _achievementTypeFromName(String name) {
    return AchievementType.values.firstWhere(
      (e) => e.name == name,
      orElse: () => AchievementType.streak,
    );
  }

  static String _achievementTypeToName(AchievementType type) {
    return type.name;
  }

  @override
  List<Object?> get props => [id, petId, type, achievementId, currentCount];
}

/// Achievement unlock state for a specific achievement
class AchievementUnlockState extends Equatable {
  final String petId;
  final String achievementId;
  final int currentCount;
  final bool unlocked;
  final int requiredCount;

  const AchievementUnlockState({
    required this.petId,
    required this.achievementId,
    this.currentCount = 0,
    this.unlocked = false,
    required this.requiredCount,
  });

  /// Progress toward unlock (0.0 to 1.0)
  double get progress =>
      (currentCount / requiredCount).clamp(0.0, 1.0);

  /// Whether this is close to being unlocked (>= 70%)
  bool get isClose => progress >= 0.7 && !unlocked;

  @override
  List<Object?> get props =>
      [petId, achievementId, currentCount, unlocked, requiredCount];
}

import 'package:equatable/equatable.dart';
import '../../../../core/models/base_model.dart';
import '../../../../core/models/base_model.dart' show JsonHelpers;

/// Predefined milestone definitions — the game design constants
///
/// Each milestone has a code, threshold, badge icon code, title, and description.
/// The iconCode maps to UI layer Icons (not in domain to keep it UI-independent).
class MilestoneDefinition extends Equatable {
  /// Milestone identifier (e.g., 'streak_7')
  final String id;

  /// Daily activity streak days threshold
  final int requiredDays;

  /// Badge icon code for UI layer mapping
  final int iconCode;

  /// Badge title shown to user
  final String title;

  /// Badge description
  final String description;

  /// Tier badge — bronze, silver, gold, diamond
  final String tier;

  /// Color code for UI (hex without #)
  final String colorCode;

  const MilestoneDefinition({
    required this.id,
    required this.requiredDays,
    required this.iconCode,
    required this.title,
    required this.description,
    required this.tier,
    required this.colorCode,
  });

  @override
  List<Object?> get props => [id, requiredDays, iconCode, title, tier, colorCode];

  // ──────────────────────────────────────────────────────────────────────────
  // Predefined milestones
  // ──────────────────────────────────────────────────────────────────────────

  static const List<MilestoneDefinition> all = [
    MilestoneDefinition(
      id: 'streak_7',
      requiredDays: 7,
      iconCode: 0,
      title: 'First Week',
      description: 'Logged your pet daily for 7 days straight',
      tier: 'bronze',
      colorCode: 'CD7F32',
    ),
    MilestoneDefinition(
      id: 'streak_14',
      requiredDays: 14,
      iconCode: 1,
      title: 'Fortnight Fighter',
      description: 'Two weeks of dedicated pet care',
      tier: 'bronze',
      colorCode: 'CD7F32',
    ),
    MilestoneDefinition(
      id: 'streak_30',
      requiredDays: 30,
      iconCode: 2,
      title: 'Monthly Caregiver',
      description: 'A full month of consistent pet care',
      tier: 'silver',
      colorCode: 'C0C0C0',
    ),
    MilestoneDefinition(
      id: 'streak_60',
      requiredDays: 60,
      iconCode: 3,
      title: 'Dedicated Guardian',
      description: '60 days of outstanding pet care',
      tier: 'silver',
      colorCode: 'C0C0C0',
    ),
    MilestoneDefinition(
      id: 'streak_90',
      requiredDays: 90,
      iconCode: 4,
      title: 'Quarterly Champion',
      description: '3 months straight — you are a true caregiver',
      tier: 'gold',
      colorCode: 'FFD700',
    ),
    MilestoneDefinition(
      id: 'streak_180',
      requiredDays: 180,
      iconCode: 5,
      title: 'Semi-Annual Legend',
      description: 'Half a year of unwavering dedication',
      tier: 'gold',
      colorCode: 'FFD700',
    ),
    MilestoneDefinition(
      id: 'streak_365',
      requiredDays: 365,
      iconCode: 6,
      title: 'Annual Hero',
      description: 'One full year — the ultimate pet guardian',
      tier: 'diamond',
      colorCode: 'B9F2FF',
    ),
    MilestoneDefinition(
      id: 'streak_730',
      requiredDays: 730,
      iconCode: 7,
      title: 'Pet Legend',
      description: 'Two years — you are a legendary caregiver',
      tier: 'diamond',
      colorCode: 'B9F2FF',
    ),
  ];

  /// Lookup by ID
  static MilestoneDefinition? byId(String id) {
    return all.where((m) => m.id == id).firstOrNull;
  }

  /// Find the next milestone the user hasn't reached yet
  MilestoneDefinition? get nextMilestone {
    return all.where((m) => m.requiredDays > requiredDays).firstOrNull;
  }
}

/// A milestone achievement record for a specific pet
///
/// Tracks the user's progress toward and unlock status of each milestone.
class MilestoneAchievement extends Equatable {
  final String id;
  final String petId;
  final String milestoneId;
  final double progress; // 0.0 to 1.0 (percentage toward milestone)
  final bool unlocked;
  final DateTime? unlockedAt;

  const MilestoneAchievement({
    required this.id,
    required this.petId,
    required this.milestoneId,
    this.progress = 0.0,
    this.unlocked = false,
    this.unlockedAt,
  });

  /// The milestone definition for this achievement
  MilestoneDefinition? get definition => MilestoneDefinition.byId(milestoneId);

  /// Days achieved for this milestone
  int get daysAchieved {
    final def = definition;
    if (def == null) return 0;
    return (progress * def.requiredDays).toInt();
  }

  /// Copy with new values
  MilestoneAchievement copyWith({
    String? id,
    String? petId,
    String? milestoneId,
    double? progress,
    bool? unlocked,
    DateTime? unlockedAt,
  }) {
    return MilestoneAchievement(
      id: id ?? this.id,
      petId: petId ?? this.petId,
      milestoneId: milestoneId ?? this.milestoneId,
      progress: progress ?? this.progress,
      unlocked: unlocked ?? this.unlocked,
      unlockedAt: unlockedAt ?? this.unlockedAt,
    );
  }

  /// Convert to DB map
  Map<String, dynamic> toDbMap() => {
        'id': id,
        'petId': petId,
        'milestoneId': milestoneId,
        'progress': progress,
        'unlocked': unlocked ? 1 : 0,
        'unlockedAt': unlockedAt?.toIso8601String(),
      };

  /// Create from DB row
  factory MilestoneAchievement.fromDbRow(Map<String, dynamic> row) {
    return MilestoneAchievement(
      id: row['id'] as String,
      petId: row['petId'] as String,
      milestoneId: row['milestoneId'] as String,
      progress: (row['progress'] as num).toDouble(),
      unlocked: (row['unlocked'] as int) == 1,
      unlockedAt: row['unlockedAt'] != null
          ? DateTime.parse(row['unlockedAt'] as String)
          : null,
    );
  }

  @override
  List<Object?> get props => [id, petId, milestoneId, progress, unlocked];
}

/// Aggregated milestone summary for a pet
class MilestoneSummary extends Equatable {
  final String petId;
  final int totalUnlocked;
  final int bestStreak;
  final List<MilestoneAchievement> achievements;
  final int totalPossible;

  MilestoneSummary({
    required this.petId,
    this.totalUnlocked = 0,
    this.bestStreak = 0,
    this.achievements = const [],
  }) : totalPossible = MilestoneDefinition.all.length;

  /// Percentage of milestones unlocked
  double get unlockRate {
    if (totalPossible == 0) return 0.0;
    return totalUnlocked / totalPossible;
  }

  /// Whether all milestones are unlocked
  bool get allUnlocked => totalUnlocked >= totalPossible;

  @override
  List<Object?> get props =>
      [petId, totalUnlocked, totalPossible, bestStreak, achievements];
}

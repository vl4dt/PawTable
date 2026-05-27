import 'package:equatable/equatable.dart';

/// Types of activities that can appear in the family feed
enum ActivityFeedType {
  feeding,
  vaccination,
  medication,
  weight,
  behavior,
  memberJoined,
  memberLeft,
  memberPromoted,
  memberDemoted,
  petShared,
  petUnshared,
  inviteCreated,
  inviteAccepted,
  inviteExpired,
  inviteCancelled,
  groupCreated,
  groupUpdated,
  streakMaintained,
  milestoneAchieved,
  achievementUnlocked,
  custom,
}

/// Icon code mapping for activity types (avoids Flutter dependency in domain)
extension ActivityFeedTypeExtension on ActivityFeedType {
  int get iconCode {
    switch (this) {
      case ActivityFeedType.feeding:
        return 0xe934; // Icons.pets_rounded
      case ActivityFeedType.vaccination:
        return 0xe86e; // Icons.medical_services_rounded
      case ActivityFeedType.medication:
        return 0xf05b0; // Icons.medication_rounded
      case ActivityFeedType.weight:
        return 0xe44c; // Icons.monitor_weight_rounded
      case ActivityFeedType.behavior:
        return 0xe848; // Icons.emoji_emotions_rounded
      case ActivityFeedType.memberJoined:
        return 0xe84b; // Icons.person_add_rounded
      case ActivityFeedType.memberLeft:
        return 0xe156; // Icons.person_remove_rounded
      case ActivityFeedType.memberPromoted:
        return 0xf0542; // Icons.arrow_upward_rounded
      case ActivityFeedType.memberDemoted:
        return 0xf0541; // Icons.arrow_downward_rounded
      case ActivityFeedType.petShared:
        return 0xf00b8; // Icons.share_rounded
      case ActivityFeedType.petUnshared:
        return 0xf00b9; // Icons.unshare_rounded
      case ActivityFeedType.inviteCreated:
        return 0xe0ca; // Icons.link_rounded
      case ActivityFeedType.inviteAccepted:
        return 0xf04ee; // Icons.check_circle_rounded
      case ActivityFeedType.inviteExpired:
        return 0xe00c; // Icons.schedule_rounded
      case ActivityFeedType.inviteCancelled:
        return 0xe007; // Icons.cancel_rounded
      case ActivityFeedType.groupCreated:
        return 0xe857; // Icons.group_add_rounded
      case ActivityFeedType.groupUpdated:
        return 0xe3c9; // Icons.edit_rounded
      case ActivityFeedType.streakMaintained:
        return 0xe4c9; // Icons.local_fire_department_rounded
      case ActivityFeedType.milestoneAchieved:
        return 0xe3e8; // Icons.emoji_events_rounded
      case ActivityFeedType.achievementUnlocked:
        return 0xf04f0; // Icons.workspace_premium_rounded
      case ActivityFeedType.custom:
        return 0xe2c4; // Icons.note_rounded
    }
  }

  String get label {
    switch (this) {
      case ActivityFeedType.feeding:
        return 'Feeding';
      case ActivityFeedType.vaccination:
        return 'Vaccination';
      case ActivityFeedType.medication:
        return 'Medication';
      case ActivityFeedType.weight:
        return 'Weight';
      case ActivityFeedType.behavior:
        return 'Behavior';
      case ActivityFeedType.memberJoined:
        return 'Member Joined';
      case ActivityFeedType.memberLeft:
        return 'Member Left';
      case ActivityFeedType.memberPromoted:
        return 'Member Promoted';
      case ActivityFeedType.memberDemoted:
        return 'Member Demoted';
      case ActivityFeedType.petShared:
        return 'Pet Shared';
      case ActivityFeedType.petUnshared:
        return 'Pet Unshared';
      case ActivityFeedType.inviteCreated:
        return 'Invite Created';
      case ActivityFeedType.inviteAccepted:
        return 'Invite Accepted';
      case ActivityFeedType.inviteExpired:
        return 'Invite Expired';
      case ActivityFeedType.inviteCancelled:
        return 'Invite Cancelled';
      case ActivityFeedType.groupCreated:
        return 'Group Created';
      case ActivityFeedType.groupUpdated:
        return 'Group Updated';
      case ActivityFeedType.streakMaintained:
        return 'Streak Maintained';
      case ActivityFeedType.milestoneAchieved:
        return 'Milestone Achieved';
      case ActivityFeedType.achievementUnlocked:
        return 'Achievement Unlocked';
      case ActivityFeedType.custom:
        return 'Custom';
    }
  }
}

/// A unified activity entry for the family activity feed
/// Aggregates different log types into a single displayable format
class ActivityFeedEntry extends Equatable {
  final String id;
  final String groupId;
  final String userId;
  final String userName;
  final String petId;
  final String petName;
  final ActivityFeedType type;
  final String title;
  final String description;
  final DateTime timestamp;
  final Map<String, dynamic>? metadata;

  const ActivityFeedEntry({
    required this.id,
    required this.groupId,
    required this.userId,
    required this.userName,
    required this.petId,
    required this.petName,
    required this.type,
    required this.title,
    required this.description,
    required this.timestamp,
    this.metadata,
  });

  /// Format the timestamp relative to now
  String get relativeTime {
    final now = DateTime.now();
    final diff = now.difference(timestamp);

    if (diff.inSeconds < 60) {
      return 'Just now';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}d ago';
    } else if (diff.inDays < 30) {
      return '${(diff.inDays / 7).floor()}w ago';
    } else {
      return '${(diff.inDays / 30).floor()}mo ago';
    }
  }

  /// Format the timestamp as a full date
  String get fullDate {
    return timestamp.toLocal().toString().split('.').first;
  }

  /// Check if this entry belongs to a specific user
  bool belongsToUser(String userId) => this.userId == userId;

  /// Check if this entry belongs to a specific pet
  bool belongsToPet(String petId) => this.petId == petId;

  /// Convert from a database row (Map)
  factory ActivityFeedEntry.fromDbRow(Map<String, dynamic> row) {
    return ActivityFeedEntry(
      id: row['id'] as String,
      groupId: row['groupId'] as String,
      userId: row['userId'] as String,
      userName: row['userName'] as String,
      petId: row['petId'] as String,
      petName: row['petName'] as String,
      type: ActivityFeedType.values.firstWhere(
        (t) => t.name == row['type'] as String,
        orElse: () => ActivityFeedType.custom,
      ),
      title: row['title'] as String? ?? '',
      description: row['description'] as String? ?? '',
      timestamp: DateTime.parse(row['timestamp'] as String),
      metadata: row['metadata'] != null
          ? row['metadata'] as Map<String, dynamic>
          : null,
    );
  }

  /// Convert to a database map
  Map<String, dynamic> toDbMap() {
    return {
      'id': id,
      'groupId': groupId,
      'userId': userId,
      'userName': userName,
      'petId': petId,
      'petName': petName,
      'type': type.name,
      'title': title,
      'description': description,
      'timestamp': timestamp.toIso8601String(),
      'metadata': metadata?.toString() ?? '{}',
    };
  }

  /// Create a copy with overridden fields
  ActivityFeedEntry copyWith({
    String? id,
    String? groupId,
    String? userId,
    String? userName,
    String? petId,
    String? petName,
    ActivityFeedType? type,
    String? title,
    String? description,
    DateTime? timestamp,
    Map<String, dynamic>? metadata,
  }) {
    return ActivityFeedEntry(
      id: id ?? this.id,
      groupId: groupId ?? this.groupId,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      petId: petId ?? this.petId,
      petName: petName ?? this.petName,
      type: type ?? this.type,
      title: title ?? this.title,
      description: description ?? this.description,
      timestamp: timestamp ?? this.timestamp,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  List<Object?> get props => [
        id,
        groupId,
        userId,
        petId,
        type,
        timestamp,
      ];
}

/// Activity feed summary statistics
class ActivityFeedSummary {
  final int totalEntries;
  final int entriesToday;
  final int entriesThisWeek;
  final int entriesThisMonth;
  final Map<ActivityFeedType, int> typeCounts;
  final List<String> activeUsers;
  final List<String> activePets;

  const ActivityFeedSummary({
    this.totalEntries = 0,
    this.entriesToday = 0,
    this.entriesThisWeek = 0,
    this.entriesThisMonth = 0,
    this.typeCounts = const {},
    this.activeUsers = const [],
    this.activePets = const [],
  });

  /// Create an empty summary
  static const ActivityFeedSummary empty = ActivityFeedSummary();
}

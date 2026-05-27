import 'package:equatable/equatable.dart';

import '../../../../core/models/base_model.dart' show JsonHelpers;
import '../../../../features/pets/domain/entities/pet_entity.dart';

/// Status of a pet sitter access grant
enum PetSitterAccessStatus {
  active,
  expired,
  revoked,
}

/// Duration preset for pet sitter access
enum SitterDuration {
  fourHours('4 hours', Duration(hours: 4)),
  eightHours('8 hours', Duration(hours: 8)),
  oneDay('1 day', Duration(days: 1)),
  threeDays('3 days', Duration(days: 3)),
  oneWeek('1 week', Duration(days: 7)),
  custom('Custom', null);

  final String label;
  final Duration? duration;

  const SitterDuration(this.label, this.duration);

  /// Get expiry date from start time
  DateTime getExpiry(DateTime start) {
    final duration = this.duration;
    if (duration == null) {
      // Custom — assume 1 day default
      return start.add(Duration(days: 1));
    }
    return start.add(duration);
  }
}

/// Pet sitter access grant — time-limited access for sitters
class PetSitterAccess extends Equatable {
  final String id;
  final String petId;
  final String groupId;
  final String petSitterName;
  final String? petSitterPhone;
  final String? petSitterEmail;
  final String grantedBy;
  final String grantedByName;
  final PetSitterAccessStatus status;
  final DateTime expiresAt;
  final DateTime createdAt;

  const PetSitterAccess({
    required this.id,
    required this.petId,
    required this.groupId,
    required this.petSitterName,
    this.petSitterPhone,
    this.petSitterEmail,
    required this.grantedBy,
    required this.grantedByName,
    this.status = PetSitterAccessStatus.active,
    required this.expiresAt,
    required this.createdAt,
  });

  /// Whether the access is currently valid
  bool get isActive =>
      status == PetSitterAccessStatus.active &&
      DateTime.now().isBefore(expiresAt);

  /// Whether the access has expired
  bool get isExpired => DateTime.now().isAfter(expiresAt);

  /// Seconds remaining until expiry
  int get secondsRemaining {
    if (!isActive) return 0;
    return expiresAt.difference(DateTime.now()).inSeconds;
  }

  /// Human-readable time remaining
  String get timeRemainingText {
    if (!isActive) return 'Expired';
    final now = DateTime.now();
    if (expiresAt.difference(now).inHours < 1) {
      return '${expiresAt.difference(now).inMinutes} minutes';
    }
    if (expiresAt.difference(now).inDays < 1) {
      return '${expiresAt.difference(now).inHours} hours';
    }
    return '${expiresAt.difference(now).inDays} days';
  }

  /// Create a copy with overridden fields
  PetSitterAccess copyWith({
    String? id,
    String? petId,
    String? groupId,
    String? petSitterName,
    String? petSitterPhone,
    String? petSitterEmail,
    String? grantedBy,
    String? grantedByName,
    PetSitterAccessStatus? status,
    DateTime? expiresAt,
    DateTime? createdAt,
  }) {
    return PetSitterAccess(
      id: id ?? this.id,
      petId: petId ?? this.petId,
      groupId: groupId ?? this.groupId,
      petSitterName: petSitterName ?? this.petSitterName,
      petSitterPhone: petSitterPhone ?? this.petSitterPhone,
      petSitterEmail: petSitterEmail ?? this.petSitterEmail,
      grantedBy: grantedBy ?? this.grantedBy,
      grantedByName: grantedByName ?? this.grantedByName,
      status: status ?? this.status,
      expiresAt: expiresAt ?? this.expiresAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() => {
        'id': id,
        'petId': petId,
        'groupId': groupId,
        'petSitterName': petSitterName,
        'petSitterPhone': petSitterPhone,
        'petSitterEmail': petSitterEmail,
        'grantedBy': grantedBy,
        'grantedByName': grantedByName,
        'status': status.name,
        'expiresAt': expiresAt.toIso8601String(),
        'createdAt': createdAt.toIso8601String(),
      };

  /// Create from JSON
  factory PetSitterAccess.fromJson(Map<String, dynamic> json) {
    return PetSitterAccess(
      id: json['id'] as String,
      petId: json['petId'] as String,
      groupId: json['groupId'] as String,
      petSitterName: json['petSitterName'] as String,
      petSitterPhone: json['petSitterPhone'] as String?,
      petSitterEmail: json['petSitterEmail'] as String?,
      grantedBy: json['grantedBy'] as String,
      grantedByName: json['grantedByName'] as String,
      status: PetSitterAccessStatus.values.firstWhere(
        (s) => s.name == json['status'],
        orElse: () => PetSitterAccessStatus.active,
      ),
      expiresAt:
          JsonHelpers.dateTime(json, 'expiresAt') ?? DateTime.now(),
      createdAt:
          JsonHelpers.dateTime(json, 'createdAt') ?? DateTime.now(),
    );
  }

  /// Create from database row
  factory PetSitterAccess.fromDbRow(Map<String, dynamic> row) {
    return PetSitterAccess(
      id: row['id'] as String,
      petId: row['petId'] as String,
      groupId: row['groupId'] as String,
      petSitterName: row['petSitterName'] as String,
      petSitterPhone: row['petSitterPhone'] as String?,
      petSitterEmail: row['petSitterEmail'] as String?,
      grantedBy: row['grantedBy'] as String,
      grantedByName: row['grantedByName'] as String,
      status: PetSitterAccessStatus.values.firstWhere(
        (s) => s.name == row['status'] as String,
        orElse: () => PetSitterAccessStatus.active,
      ),
      expiresAt: DateTime.parse(row['expiresAt'] as String),
      createdAt: DateTime.parse(row['createdAt'] as String),
    );
  }

  /// Convert to database map
  Map<String, dynamic> toDbMap() {
    return {
      'id': id,
      'petId': petId,
      'groupId': groupId,
      'petSitterName': petSitterName,
      'petSitterPhone': petSitterPhone,
      'petSitterEmail': petSitterEmail,
      'grantedBy': grantedBy,
      'grantedByName': grantedByName,
      'status': status.name,
      'expiresAt': expiresAt.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
        id,
        petId,
        groupId,
        petSitterName,
        status,
        expiresAt,
      ];
}

/// Pet sitter access summary for UI display
class PetSitterAccessSummary extends Equatable {
  final PetSitterAccess access;
  final PetEntity pet;

  const PetSitterAccessSummary({
    required this.access,
    required this.pet,
  });

  /// Whether the pet sitter has active access
  bool get hasActiveAccess => access.isActive;

  /// Days until expiry (or days since expiry if negative)
  int get daysUntilExpiry {
    if (!access.isActive) {
      return -DateTime.now()
          .difference(access.expiresAt)
          .inDays;
    }
    return access.expiresAt.difference(DateTime.now()).inDays;
  }

  PetSitterAccessSummary copyWith({
    PetSitterAccess? access,
    PetEntity? pet,
  }) {
    return PetSitterAccessSummary(
      access: access ?? this.access,
      pet: pet ?? this.pet,
    );
  }

  @override
  List<Object?> get props => [access.id, pet.id];
}

import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Sync operation types
enum SyncType {
  feedings,
  healthLogs,
  vaccinations,
  medications,
  weightLogs,
  familyMembers,
  pets,
}

/// Sync status for an operation
class SyncStatus {
  final SyncType type;
  final bool isSyncing;
  final String? lastError;
  final DateTime? lastSync;
  final int pendingChanges;

  const SyncStatus({
    required this.type,
    this.isSyncing = false,
    this.lastError,
    this.lastSync,
    this.pendingChanges = 0,
  });

  SyncStatus copyWith({
    bool? isSyncing,
    String? lastError,
    DateTime? lastSync,
    int? pendingChanges,
  }) {
    return SyncStatus(
      type: type,
      isSyncing: isSyncing ?? this.isSyncing,
      lastError: lastError ?? this.lastError,
      lastSync: lastSync ?? this.lastSync,
      pendingChanges: pendingChanges ?? this.pendingChanges,
    );
  }
}

/// Global sync state managing all sync operations
class SyncState {
  final Map<SyncType, SyncStatus> statuses;
  final bool isFullSync;
  final String? lastFullSync;

  const SyncState({
    this.statuses = const {},
    this.isFullSync = false,
    this.lastFullSync,
  });

  SyncStatus getStatus(SyncType type) =>
      statuses[type] ?? SyncStatus(type: type);

  SyncState copyWith({
    Map<SyncType, SyncStatus>? statuses,
    bool? isFullSync,
    String? lastFullSync,
  }) {
    return SyncState(
      statuses: statuses ?? this.statuses,
      isFullSync: isFullSync ?? this.isFullSync,
      lastFullSync: lastFullSync ?? this.lastFullSync,
    );
  }
}

/// AsyncNotifier for sync management
class SyncNotifier extends AsyncNotifier<SyncState> {
  @override
  Future<SyncState> build() async {
    return const SyncState();
  }

  /// Start sync for a specific type
  Future<void> sync(SyncType type) async {
    final current = state.when(
      data: (s) => s,
      loading: () => const SyncState(),
      error: (_, __) => const SyncState(),
    );
    state = const AsyncLoading();

    final updatedStatus = current.getStatus(type).copyWith(
      isSyncing: true,
    );

    // TODO: Implement actual sync logic with Firebase

    final newStatus = updatedStatus.copyWith(
      isSyncing: false,
      lastSync: DateTime.now(),
    );

    final newStatuses = Map<SyncType, SyncStatus>.from(current.statuses);
    newStatuses[type] = newStatus;

    state = AsyncData(
      current.copyWith(statuses: newStatuses),
    );
  }

  /// Full sync of all data
  Future<void> fullSync() async {
    state = const AsyncLoading();
    // TODO: Implement full sync

    state = AsyncData(
      const SyncState().copyWith(
        isFullSync: true,
        lastFullSync: DateTime.now().toIso8601String(),
      ),
    );
  }

  /// Add pending change
  void addPendingChange(SyncType type) {
    final current = state.when(
      data: (s) => s,
      loading: () => const SyncState(),
      error: (_, __) => const SyncState(),
    );

    final status = current.getStatus(type);
    final newStatus = status.copyWith(
      pendingChanges: status.pendingChanges + 1,
    );

    final newStatuses = Map<SyncType, SyncStatus>.from(current.statuses);
    newStatuses[type] = newStatus;

    state = AsyncData(current.copyWith(statuses: newStatuses));
  }
}

final syncProvider = AsyncNotifierProvider<SyncNotifier, SyncState>(
  SyncNotifier.new,
);
